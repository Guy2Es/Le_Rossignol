function a = autonomie_distance(V, m, ns, rho, p, aero, eta)
%AUTONOMIE_DISTANCE  Autonomie et distance d'un avion électrique à batterie.
%
%   a = autonomie_distance(V, m, ns, rho, p, aero, eta)
%     V   : vitesses vraies [m/s] (vecteur) ; m : masse [kg] ; ns : cellules
%     rho : masse volumique [kg/m³] ; p : paramètres ; aero : modèle aéro
%     eta : rendement global de propulsion [-]
%   Sortie : structure a (P_elec, autonomies théorique et réelle, distances,
%            optimums numériques).
%
%   Batterie = masse CONSTANTE en vol : la formule de Breguet (C1 p.75)
%   ne s'applique pas, car elle intègre une perte de masse (hypothèse 3 :
%   CL constant avec V ∝ √m). On écrit directement le bilan d'énergie :
%     E_batt = ns·Q·V_nom                         (énergie nominale du pack)
%     t      = E_batt·f_utile·(1 − réserve)/P_elec(V)
%     R      = V·t                                (sans vent, V_sol = V_air)
%   avec P_elec(V) = Pn(V)/η + P_av (puissance_requise.m, C1 p.57).
%   Réel : t_réel = t·(1 − pertes), pertes = 20 et 30 % (cahier).

E   = ns * p.batt.Q_Ah * p.batt.V_nom * 3600;          % J
E_u = E * p.batt.f_utile * (1 - p.batt.reserve);        % J utilisables avant réserve

[P, ~, CL] = puissance_requise(V, m, rho, p.geo.S, aero, eta, p.prop.P_av, p.const);
t = E_u ./ P;                                           % s

a.V       = V;
a.CL      = CL;
a.P_elec  = P;
a.E_Wh    = E / 3600;
a.Eu_Wh   = E_u / 3600;
a.t_min   = t / 60;                                     % théorique
a.t_reel  = (1 - p.batt.pertes(:)) * a.t_min;           % [2 × N] : −20 % puis −30 %
a.R_km    = V .* t / 1000;
a.R_reel  = (1 - p.batt.pertes(:)) * a.R_km;

% Vitesse de décrochage et vitesse minimale d'utilisation (1,2·Vs)
a.Vs     = sqrt(2 * m * p.const.g / (rho * p.geo.S * aero.CLmax));
a.V_min  = p.req.k_Vmin_op * a.Vs;

% Optimums numériques (incluent P_av, contrairement aux formules de C1)
ok = V >= a.V_min & isfinite(P);
[~, i] = max(a.t_min .* ok);   a.V_tmax = V(i);   a.t_max = a.t_min(i);
[~, i] = max(a.R_km  .* ok);   a.V_Rmax = V(i);   a.R_max = a.R_km(i);
% Le maximum est-il collé à la borne 1,2·Vs ? (=> endurance limitée par le décrochage)
a.tmax_en_butee = a.V_tmax <= min(V(ok)) + 1e-9;
end
