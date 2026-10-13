function cc = contraintes_PW(WS, rho, p, aero)
%CONTRAINTES_PW  Diagramme de contraintes en puissance électrique massique.
%
%   cc = contraintes_PW(WS, rho, p, aero)
%     WS   : charges alaires balayées [N/m²] (vecteur ligne)
%     rho  : masse volumique du cas atmosphérique [kg/m³]
%     p    : paramètres (params_v1) ; aero : modèle aérodynamique
%   Sortie : structure cc ; pour chaque contrainte, T/W [-] et P/W [W/kg],
%   P/W étant la puissance ÉLECTRIQUE de propulsion par kg de masse au
%   décollage (l'avionique est exclue : elle ne dimensionne pas le moteur).
%
%   Méthode : skill, initial-sizing.md (C3 p.73-83), où chaque exigence
%   devient une courbe T/W = f(W/S). Adaptation à l'électrique :
%     P_elec/m = (T/W)·g·V/η          (puissance utile T·V, rendement η)
%   Les vitesses des exigences sont des vitesses VRAIES (TAS) : le lancer,
%   le vent et la croisière se jouent par rapport à l'air réel. ρ est donc
%   celle du cas étudié (ISA ou jour chaud).
%   Les formules de C3 sont écrites sous la forme équivalente
%     T/W = q·CD(CL)/(W/S),  CL = n·(W/S)/q
%   pour passer par polaire.m ; pour la polaire parabolique c'est
%   EXACTEMENT C3 p.77/79 (vérifié dans tests/test_predim.m).

g = p.const.g;
S = p.geo.S;

%% 1. Décrochage — V1-PERF-01 (C3 p.83) : CLmax = 2·(W/S)/(ρ·Vs²)
%   => W/S_max = ½·ρ·Vs_max²·CLmax : droite verticale.
cc.WS_max   = 0.5 * rho * p.req.Vs_max^2   * aero.CLmax;
cc.WS_cible = 0.5 * rho * p.req.Vs_cible^2 * aero.CLmax;

%% 2. Montée ≥ 3 m/s — V1-PERF-07 (C3 p.75, avec cos γ de C1 p.78)
%   Vitesse de montée : V = k·Vs(W/S), k = 1,3. La skill prend V_Y = vitesse
%   de puissance minimale (C1 p.79) ; ici ce point est au-delà de CLmax
%   (voir points_remarquables), d'où 1,3·Vs : marge au décrochage après
%   un lancer main, CL de montée = CLmax/1,3² ≈ 0,47.
%   Équilibre (C1 p.78) : portance = m·g·cos γ ; poussée = traînée + m·g·sin γ
%   => T/W = sin γ + q·CD(CL)/(W/S), CL = cos γ·(W/S)/q, sin γ = Vz/V.
%   Pour cos γ ≈ 1, c'est la formule de C3 p.75.
Vs  = sqrt(2 .* WS ./ (rho .* aero.CLmax));
Vm  = p.req.k_Vmontee .* Vs;
sg  = p.req.Vz_min ./ Vm;
cg  = sqrt(1 - sg.^2);
qm  = 0.5 .* rho .* Vm.^2;
TWm = sg + qm .* polaire(cg .* WS ./ qm, aero) ./ WS;
cc.montee.V     = Vm;
cc.montee.gamma = asind(sg);
cc.montee.TW    = TWm;
cc.montee.PW    = TWm .* g .* Vm ./ p.prop.eta_montee;

%% 3. Virage stabilisé à 45° à 45 km/h (C3 p.77) : n = 1/cos φ (C1 p.89)
%   T/W = q·[CD0/(W/S) + k·(n/q)²·(W/S)] = q·CD(n·(W/S)/q)/(W/S)
n   = 1 / cosd(p.req.phi_virage);
Vv  = p.req.V_virage;
qv  = 0.5 * rho * Vv^2;
TWv = qv .* polaire(n .* WS ./ qv, aero) ./ WS;
cc.virage.n      = n;
cc.virage.TW     = TWv;
cc.virage.PW     = TWv .* g .* Vv ./ p.prop.eta_montee;
cc.virage.WS_max = 0.5 * rho * Vv^2 * aero.CLmax / n;   % au-delà : décrochage en virage

%% 4. Croisière à 55 km/h — V1-PERF-02 (C3 p.79)
%   T/W = ρV²·CD0/(2·W/S) + 2k·(W/S)/(ρV²) = q·CD((W/S)/q)/(W/S)
Vc  = p.req.V_cr;
qc  = 0.5 * rho * Vc^2;
TWc = qc .* polaire(WS ./ qc, aero) ./ WS;
cc.croisiere.TW = TWc;
cc.croisiere.PW = TWc .* g .* Vc ./ p.prop.eta;

%% 5. Lancer main : poussée statique ≥ 0,5·poids — V1-PERF-08 (hors skill)
%   S est figée par la géométrie V1 : la masse varie le long de l'axe,
%   m = (W/S)·S/g. Conversion poussée -> puissance par Froude (poussee_statique.m).
m  = WS .* S ./ g;
Ts = p.req.TsurW_stat .* m .* g;
D  = p.prop.D_pouces(:) * 0.0254;                   % une ligne par diamètre
Pstat = poussee_statique(Ts, rho, D, p.prop.FM, p.prop.eta_mot, p.prop.eta_esc);
cc.statique.D  = D;
cc.statique.PW = Pstat ./ m;                        % [nD × nWS]
iD = find(p.prop.D_pouces == p.prop.D_nominal, 1);
cc.statique.PW_nominal = cc.statique.PW(iD, :);

%% Enveloppe : P/W minimal qui satisfait toutes les contraintes
%   (C3 p.73 : le plus contraignant l'emporte). NaN (décrochage) => Inf.
toutes = [cc.montee.PW; cc.virage.PW; cc.croisiere.PW; cc.statique.PW_nominal];
toutes(isnan(toutes)) = Inf;
[cc.enveloppe, cc.active] = max(toutes, [], 1);
cc.enveloppe(WS > cc.WS_max) = Inf;                 % interdit par le décrochage
cc.noms = ["Montée 3 m/s", "Virage 45°", "Croisière 55 km/h", "Lancer main T/W ≥ 0,5"];
end
