%TEST_PREDIM  Recoupements des fonctions avec les exemples chiffrés de la skill.
%   Lancement : runtests('test_predim') depuis le dossier tests/.
%   Chaque section %% est un test indépendant.

racine = fileparts(fileparts(mfilename('fullpath')));
addpath(fullfile(racine, 'fonctions'), racine);
p = params_v1();
c = p.const;

%% ISA FL350 — exemple chiffré de atmosphere-airspeeds.md
[T, ~, rho, a, sigma] = atmosphere_isa(10668, 0, c);
assert(abs(T - 218.8) < 0.1, 'T(FL350)');
assert(abs(rho - 0.3796) < 1e-3, 'rho(FL350)');
assert(abs(sigma - 0.310) < 1e-3, 'sigma(FL350)');
assert(abs(a - 296.5) < 0.5, 'a(FL350)');

%% ISA recoupée avec atmosisa (Aerospace Toolbox)
H = [0 200 1000 5000];
[T, pr, rho] = atmosphere_isa(H, 0, c);
[Tm, ~, Pm, rhom] = atmosisa(H);
assert(max(abs(T ./ Tm - 1)) < 1e-4, 'T vs atmosisa');
assert(max(abs(pr ./ Pm - 1)) < 1e-4, 'p vs atmosisa');
assert(max(abs(rho ./ rhom - 1)) < 1e-4, 'rho vs atmosisa');

%% Points remarquables — exemple de performance.md (60 t, S = 120 m²)
aero = struct('type', "parabolique", 'CD0', 0.020, 'e', 0.80, 'lambda', 9, 'CLmax', 2);
pr = points_remarquables(60000, 120, aero, c);
assert(abs(pr.f_max - 16.81) < 0.01, 'f_max = 16,81');
assert(abs(pr.Tn_min.CD / aero.CD0 - 2) < 1e-12, 'CD = 2·CD0 à fmax');
assert(abs(pr.TnV_min.f / pr.Pn_min.f - 1) < 1e-9, 'même finesse Tn/V min et Pn min');
assert(pr.Pn_min.EV < pr.Tn_min.EV && pr.Tn_min.EV < pr.TnV_min.EV, 'ordre des vitesses');

%% Puissance requise cohérente avec Tn min (C1 p.50 et p.57)
aero = struct('type', "parabolique", 'CD0', 0.020, 'e', 0.80, 'lambda', 9, 'CLmax', 2);
pr = points_remarquables(60000, 120, aero, c);
[~, Pn] = puissance_requise(pr.Tn_min.EV, 60000, c.rho0, 120, aero, 1, 0, c);
Tn_min = 2 * 60000 * c.g * sqrt(pr.k * aero.CD0);
assert(abs(Pn / (Tn_min * pr.Tn_min.EV) - 1) < 1e-9, 'Pn = Tn_min·V à fmax');

%% Décrochage — exemple de initial-sizing.md (61 kt, CZmax 2,1 => 1268 N/m²)
q = p;
q.req.Vs_max = 31.4;
aero = q.aero;  aero.CLmax = 2.1;
cc = contraintes_PW(100, 1.225, q, aero);
assert(abs(cc.WS_max - 1268.2) < 0.1, 'W/S décrochage = 1268,2 N/m²');

%% Contraintes via polaire() identiques aux formules fermées de C3 p.77 et p.79
aero = p.aero;
WS = 15:5:45;  rho = c.rho0;
cc = contraintes_PW(WS, rho, p, aero);
k  = 1 / (pi * aero.lambda * aero.e);
V  = p.req.V_cr;
TWc = rho * V^2 * aero.CD0 ./ (2 * WS) + 2 * k * WS / (rho * V^2);       % C3 p.79
assert(max(abs(cc.croisiere.TW - TWc)) < 1e-12, 'croisière = C3 p.79');
qd = 0.5 * rho * p.req.V_virage^2;  n = 1 / cosd(45);
TWv = qd * (aero.CD0 ./ WS + k * (n / qd)^2 * WS);                         % C3 p.77
assert(max(abs(cc.virage.TW - TWv)) < 1e-12, 'virage = C3 p.77');

%% Froude : avec FM = 1 et rendements = 1, P = T^1,5/√(2ρA)
P = poussee_statique(10, 1.225, 0.3, 1, 1, 1);
assert(abs(P - 10^1.5 / sqrt(2 * 1.225 * pi * 0.3^2 / 4)) < 1e-9, 'Froude');

%% Modèle moteur : équilibre des couples et bilan de puissance
r = motorisation(1000, [8 5], 4, 3.6, 1.225, p);
assert(r.I > r.I0 && r.P_arbre < r.P_elec, 'bilan de puissance');
assert(abs(r.T / (r.Ct0 * 1.225 * (r.rpm / 60)^2 * 0.2032^4) - 1) < 1e-9, 'poussée');

%% Hélice en vol : à J = 0, on retrouve le modèle de point fixe
[Ct, Cp] = coeffs_helice([8 6], 0, p);
assert(abs(Ct - (p.hel.a_t + p.hel.b_t * 0.25)) < 1e-15 && abs(Cp - (p.hel.a_p + p.hel.b_p * 0.25)) < 1e-15, 'Ct0, Cp0');

%% Hélice en vol : rendement maximal plausible pour une 8x6 (ordre de grandeur UIUC)
[~, ~, eh] = coeffs_helice([8 6], 0:0.005:1, p);
assert(max(eh) > 0.6 && max(eh) < 0.85, 'eta hélice max 8x6 hors de 0,6-0,85');

%% Point propulsif : aller-retour gaz imposé puis poussée imposée
mot = constantes_moteur(1000, "mot", p);
r1 = point_propulsif(mot, [8 6], 4, 3.6, 1.225, 15, "gaz", 0.6, p);
r2 = point_propulsif(mot, [8 6], 4, 3.6, 1.225, 15, "poussee", r1.T, p);
assert(abs(r2.d - 0.6) < 1e-6, 'rapport cyclique retrouvé');

%% Point propulsif : rendement global = produit des rendements
mot = constantes_moteur(1000, "mot", p);
r = point_propulsif(mot, [7 5], 4, 3.6, 1.225, 15.28, "poussee", 1.3, p);
assert(abs(r.eta_glob - r.eta_h * r.eta_mot * r.eta_esc * r.eta_bat) < 1e-12, 'produit des rendements');
assert(r.faisable, 'croisière faisable');

%% Groupe propulsif : le poste du budget est remplacé par moteur + pales + moyeu-cône
mot = constantes_moteur(980, "motX", p);
[m, gp] = masse_option(mot, [0.728 0.796], p);
assert(abs(gp.total - 1000 * (mot.m + p.gp.m_pales + p.gp.m_moyeu)) < 1e-9, 'somme du groupe propulsif');
assert(max(abs(1000 * m - ([728 796] + gp.total - gp.budget))) < 1e-9, 'masse = budget − poste + groupe réel');

%% Cas d'erreur : 4S sans bridage = point fixe plein gaz du solveur
mot = constantes_moteur(980, "motX", p);
E = cas_erreur(mot, [8 6], 0.8, 1.225, p);
r = point_propulsif(mot, [8 6], 4, p.batt.V_plein, 1.225, 0, "gaz", 1, p);
assert(abs(E(2).P - r.P_elec) < 1e-9 && E(1).P < E(2).P, 'erreur sans bridage = plein gaz');

%% Budget réaffecté : le bilan boucle (masse = budget du cahier + écarts) et la structure cible tient 800 g
mot = constantes_moteur(980, "motX", p);
[~, gp] = masse_option(mot, [0.728 0.796], p);
B = budget_reaffecte(gp, p);
bm = budget_masse(p);
assert(abs(B.sans_batt - (bm.sans_batt + sum(B.postes.Ecart_g))) < 1e-9, 'sans batterie = cahier + écarts');
assert(abs(B.gain - (-(sum(B.postes.Ecart_g) - gp.ecart))) < 1e-9, 'gain = écarts des postes du plan');
assert(B.cible_4S_fiche <= p.masse.MTOW + 1e-9 && B.cible_sans_batt <= p.masse.max_sans_batt + 1e-9, 'la cible tient V1-MAS-01 et 02');

%% Import xflr5 : une polaire parabolique écrite en CSV doit être relue sans écart
aero = p.aero;
alpha = (-4:0.5:14)';
CL = 0.06 * (alpha + 1);                       % pente fictive, CL max atteint à 14°
aero_large = aero;  aero_large.CLmax = 2;      % pour écrire toute la table sans NaN
CD = polaire(CL, aero_large);
Cm = 0.01 * ones(size(alpha));
f = [tempname '.csv'];
writetable(table(alpha, CL, CD, Cm), f);
ax = import_polaire_xflr5(f, aero);
delete(f);
CLt = 0.1:0.05:0.8;
% pchip ne reproduit pas exactement une parabole : écart relatif ~5e-5 attendu
assert(max(abs(polaire(CLt, ax) ./ polaire(CLt, aero) - 1)) < 1e-4, 'xflr5 = parabolique');
assert(abs(ax.CLmax - max(CL)) < 1e-12, 'CLmax importé');
