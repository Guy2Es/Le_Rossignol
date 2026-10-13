function r = point_propulsif(mot, hel, ns, V_ocv, rho, V, mode, val, p)
%POINT_PROPULSIF  Point de fonctionnement batterie / ESC / moteur / hélice à la vitesse V.
%
%   r = point_propulsif(mot, hel, ns, V_ocv, rho, V, mode, val, p)
%     mot   : constantes moteur (constantes_moteur.m)
%     hel   : [diamètre, pas] [pouces] ; ns : cellules en série (1P)
%     V_ocv : tension à vide d'une cellule [V] ; rho [kg/m³] ; V : vitesse vraie [m/s]
%     mode  : "gaz"     -> val = rapport cyclique imposé d (0 à 1)
%             "poussee" -> val = poussée imposée T [N] (palier : T = traînée)
%     p     : paramètres (params_v1)
%   Sortie : structure r (régime, poussée, courants, tensions, puissances,
%            rapport cyclique d, rendements détaillés, faisabilité d ≤ 1).
%
%   HORS SKILL, modèle volontairement simple, à recaler au banc (phase 9) :
%   - hélice   : T = Ct(J)·ρ·n²·D⁴, P_arbre = Cp(J)·ρ·n³·D⁵  (coeffs_helice.m)
%   - moteur   : Q = P_arbre/ω,  I_m = Q·Kv + I0,  U_m = ω/Kv + I_m·Rm
%   - ESC      : P_in = U_m·I_m + I_m²·R_esc + P_esc0  (conduction + pertes fixes)
%                rapport cyclique : d·U_b = U_m + I_m·R_esc
%   - batterie : U_b = ns·V_ocv − I_b·ns·R_dc et P_in = U_b·I_b
%                => I_b = (E − √(E² − 4·R_b·P_in)) / (2·R_b)
%   Le régime n est l'unique inconnue, trouvée par fzero.
%   Rendement global sur la même base énergétique que autonomie_distance.m
%   (énergie = ns·Q·V_nominal, donc pertes internes de la batterie comprises) :
%     η_global = T·V / (ns·V_ocv·I_b) = η_hélice·η_moteur·η_ESC·η_batterie

D  = hel(1) * 0.0254;                                % m
E  = ns * V_ocv;                                     % V, f.é.m. de la batterie
Rb = ns * p.batt.R_dc;                               % Ω
[~, ~, ~, J_T] = coeffs_helice(hel, 0, p);
n_T0 = V / (D * J_T);                                % tr/s, poussée nulle
n_hi = mot.Kv * E / (2*pi) * 1.5;                    % tr/s, au-delà du régime à vide

switch mode
    case "gaz"
        f  = @(n) etat(n).d - val;
        n0 = max(n_T0, 1e-3);
        if f(n0) > 0
            r = etat(n0);  r.faisable = false;  return  % gaz trop faible pour pousser
        end
        n = fzero(f, [n0, n_hi]);
    case "poussee"
        Ct0 = p.hel.a_t + p.hel.b_t * (hel(2)/hel(1) - 0.5);
        n_sup = 2 * (n_T0 + sqrt(val / (rho * D^4 * Ct0))) + 1;   % T(n_sup) > val
        n = fzero(@(n) etat(n).T - val, [max(n_T0, 1e-3), n_sup]);
    otherwise
        error('mode inconnu : %s', mode);
end
r = etat(n);
r.faisable = r.d <= 1 && isreal(r.I);

    function s = etat(n)
        % Toutes les grandeurs pour un régime n [tr/s]
        J = V / (n * D);
        [Ct, Cp, eta_h] = coeffs_helice(hel, J, p);
        s.n = n;  s.rpm = 60 * n;  s.J = J;
        s.T       = Ct * rho * n^2 * D^4;            % N
        s.P_arbre = Cp * rho * n^3 * D^5;            % W
        w   = 2*pi*n;                                % rad/s
        I_m = s.P_arbre / w * mot.Kv + mot.I0;       % A, courant moteur
        U_m = w / mot.Kv + I_m * mot.Rm;             % V, tension moteur
        P_m = U_m * I_m;                             % W, puissance électrique moteur
        P_in = P_m + I_m^2 * p.mot.R_esc + p.mot.P_esc0;   % W, entrée ESC
        disc = E^2 - 4 * Rb * P_in;
        if disc < 0                                  % batterie incapable de fournir P_in
            s.I = NaN;  s.U_batt = NaN;  s.d = 10;   % d fictif > 1 pour borner fzero
        else
            s.I = (E - sqrt(disc)) / (2 * Rb);       % A, courant batterie = cellule (1P)
            s.U_batt = E - s.I * Rb;                 % V
            s.d = (U_m + I_m * p.mot.R_esc) / s.U_batt;
        end
        s.I_mot  = I_m;   s.U_mot = U_m;
        s.P_elec = P_in;                             % W, tirée aux bornes de la batterie
        s.eta_h   = eta_h;
        s.eta_mot = s.P_arbre / P_m;
        s.eta_esc = P_m / P_in;
        s.eta_bat = s.U_batt / E;
        s.eta_glob = s.T * V / (E * s.I);
        s.V_pas = n * hel(2) * 0.0254;               % m/s
    end
end
