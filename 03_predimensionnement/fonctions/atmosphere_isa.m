function [T, pr, rho, a, sigma] = atmosphere_isa(H, dT, c)
%ATMOSPHERE_ISA  Atmosphère standard ISA (troposphère) avec décalage ΔT.
%
%   [T, pr, rho, a, sigma] = atmosphere_isa(H, dT, c)
%     H  : altitude géopotentielle [m], 0 ≤ H ≤ 11 000 (troposphère)
%     dT : écart de température à l'ISA [K] (0 pour l'ISA)
%     c  : structure des constantes (p.const de params_v1)
%   Sorties : T [K], pr [Pa], rho [kg/m³], a [m/s], sigma = rho/rho0 [-]
%
%   Source : skill /aircraft-design, atmosphere-airspeeds.md (C1 p.36-40).
%   Modèle ISA+ΔT : la pression suit la loi ISA de l'altitude (inchangée),
%   seule la température est décalée ; la masse volumique en découle par la
%   loi des gaz parfaits. C'est l'approche « hot-and-high » recommandée par
%   la skill (« Validity » : utiliser des offsets ISA+ΔT).

if any(H < 0 | H > 11000)
    error('atmosphere_isa:domaine', 'Modèle limité à la troposphère (0-11 000 m).');
end

% Température ISA : T(H) = T0 + T_H·H (C1 p.37), puis décalage ΔT
T_isa = c.T0 + c.TH .* H;
T     = T_isa + dT;

% Pression, couche à gradient (C1 p.38-39) :
%   p(H) = p0·(1 + T_H·H/T0)^(−g0/(R·T_H))
pr = c.p0 .* (1 + c.TH .* H ./ c.T0) .^ (-c.g ./ (c.R .* c.TH));

% Masse volumique : loi des gaz parfaits p = ρ·R·T (C1 p.36)
rho = pr ./ (c.R .* T);

% Vitesse du son a = √(γ·R·T) (C1 p.40) et rapport de densité σ = ρ/ρ0
a     = sqrt(c.gam .* c.R .* T);
sigma = rho ./ c.rho0;
end
