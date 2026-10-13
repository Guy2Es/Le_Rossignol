function [P_elec, P_ideal, P_arbre] = poussee_statique(T, rho, D, FM, eta_mot, eta_esc)
%POUSSEE_STATIQUE  Puissance électrique nécessaire pour une poussée au point fixe.
%
%   [P_elec, P_ideal, P_arbre] = poussee_statique(T, rho, D, FM, eta_mot, eta_esc)
%     T   : poussée statique demandée [N]
%     rho : masse volumique [kg/m³] ; D : diamètre d'hélice [m]
%     FM  : figure of merit de l'hélice au point fixe [-]
%     eta_mot, eta_esc : rendements moteur et ESC au point fixe [-]
%
%   HORS SKILL (la skill exclut l'analyse propulsive détaillée) : théorie de
%   la quantité de mouvement de Froude (disque actuateur), au point fixe.
%     Vitesse induite dans le plan du disque : v_i = √(T/(2·ρ·A))
%     Puissance idéale : P_ideal = T·v_i = T^(3/2)/√(2·ρ·A),  A = π·D²/4
%     Puissance à l'arbre : P_arbre = P_ideal/FM (FM ≈ 0,5-0,6 pour une
%       petite hélice ; FM = 1 serait un disque parfait)
%     Puissance électrique : P_elec = P_arbre/(η_moteur·η_ESC)
%   Conséquence : à poussée donnée, une grande hélice demande moins de
%   puissance (P ∝ 1/D) ; c'est pourquoi le diamètre est un paramètre.

A       = pi * D.^2 / 4;                         % aire du disque [m²]
P_ideal = T.^1.5 ./ sqrt(2 .* rho .* A);         % Froude, point fixe
P_arbre = P_ideal ./ FM;
P_elec  = P_arbre ./ (eta_mot .* eta_esc);
end
