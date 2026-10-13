function [P_elec, Pn, CL, CD] = puissance_requise(V, m, rho, S, aero, eta, P_av, c)
%PUISSANCE_REQUISE  Puissance nécessaire au vol horizontal stabilisé.
%
%   [P_elec, Pn, CL, CD] = puissance_requise(V, m, rho, S, aero, eta, P_av, c)
%     V    : vitesse vraie (TAS) [m/s], scalaire ou tableau
%     m    : masse [kg] ; rho : masse volumique [kg/m³] ; S : surface [m²]
%     aero : modèle aéro (passé à polaire.m) ; eta : rendement global de
%            propulsion [-] ; P_av : puissance avionique [W] ; c = p.const
%   Sorties :
%     P_elec : puissance électrique tirée de la batterie [W]
%     Pn     : puissance aérodynamique nécessaire Pn = D·V [W]
%     CL, CD : coefficients au point de vol (CD = NaN sous le décrochage)
%
%   Équations (skill, performance.md) :
%     équilibre vertical  m·g = ½·ρ·V²·S·CL           (C1 p.46)
%     traînée             D   = ½·ρ·V²·S·CD(CL)        (C1 p.46, polaire.m)
%     puissance           Pn  = D·V_TAS                (C1 p.57)
%   Passage à l'électrique (hypothèse du cahier, rendement constant) :
%     P_elec = Pn/η + P_av
%   Écrit en TAS avec ρ local, ce qui équivaut à la forme EAS de C1 p.57
%   (√σ·Pn = A·EV³ + B/EV).

q  = 0.5 .* rho .* V.^2;            % pression dynamique [Pa]
CL = m .* c.g ./ (q .* S);          % portance = poids
CD = polaire(CL, aero);             % seul appel au modèle aérodynamique
Pn = q .* S .* CD .* V;             % Pn = D·V
P_elec = Pn ./ eta + P_av;
end
