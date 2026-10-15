function [Re, nu] = reynolds(V, c, rho, T, k)
%REYNOLDS  Nombre de Reynolds sur une corde.
%
%   [Re, nu] = reynolds(V, c, rho, T, k)
%     V   : vitesse vraie [m/s] ; c : corde [m] (tableaux compatibles)
%     rho : masse volumique [kg/m³] ; T : température [K]
%     k   : constantes (p.const : mu_S, T_S)
%   Sorties : Re = V·c/ν [-], ν viscosité cinématique [m²/s]
%
%   HORS SKILL : viscosité par la loi de Sutherland, μ = μ_S·T^1,5/(T + T_S),
%   comme dans estimation_cd0_e.m (phase 3).

mu = k.mu_S * T^1.5 / (T + k.T_S);   % Pa·s
nu = mu / rho;                       % m²/s
Re = V .* c ./ nu;
end
