function [Ct, Cp, eta_h, J_T] = coeffs_helice(hel, J, p)
%COEFFS_HELICE  Coefficients de poussée et de puissance d'une hélice en vol.
%
%   [Ct, Cp, eta_h, J_T] = coeffs_helice(hel, J, p)
%     hel : [diamètre, pas] [pouces] ; J : paramètre d'avancement V/(n·D) [-]
%     p   : paramètres (params_v1)
%   Sorties : Ct = T/(ρ n² D⁴), Cp = P/(ρ n³ D⁵), rendement η = J·Ct/Cp,
%             J_T = avancement à poussée nulle.
%
%   HORS SKILL (la skill exclut l'analyse propulsive détaillée). Modèle
%   d'ordre de grandeur (hélices fines, données UIUC), à recaler au banc :
%     point fixe : Ct0 = a_t + b_t·(P/D − 0,5),  Cp0 = a_p + b_p·(P/D − 0,5)
%     en vol     : Ct = Ct0·(1 − (J/J_T)²),  J_T = k_JT·P/D
%                  Cp = Cp0·(1 − (J/J_P)²),  J_P = k_JP·J_T
%   À J = 0 on retrouve exactement le modèle de point fixe.

PsurD = hel(2) / hel(1);
Ct0 = p.hel.a_t + p.hel.b_t * (PsurD - 0.5);
Cp0 = p.hel.a_p + p.hel.b_p * (PsurD - 0.5);
J_T = p.hel.k_JT * PsurD;
J_P = p.hel.k_JP * J_T;
Ct  = Ct0 * (1 - (J ./ J_T).^2);
Cp  = Cp0 * (1 - (J ./ J_P).^2);
eta_h = J .* Ct ./ Cp;
end
