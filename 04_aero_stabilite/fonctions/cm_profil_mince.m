function [Cm_c4, alpha0] = cm_profil_mince(pf)
%CM_PROFIL_MINCE  Cm au quart avant et incidence de portance nulle de la ligne moyenne
%   (théorie des profils minces).
%
%   [Cm_c4, alpha0] = cm_profil_mince(pf)
%     pf : profil lu par lire_profil_dat (grille pf.xs, extrados pf.yu, intrados pf.yl)
%   Sorties :
%     Cm_c4  : Cm au quart avant, indépendant de Cl = π/4·(A2 − A1)
%     alpha0 : incidence de portance nulle [deg] = −1/π·∫ dz/dx·(cos θ − 1) dθ
%   avec x/c = (1 − cos θ)/2 et An = 2/π·∫ dz/dx·cos(nθ) dθ.
%   HORS SKILL (la skill ne donne que l'estimation C2 p.69, sans réflexe) : sert de
%   référence non visqueuse, la VLM de xflr5 portant la même ligne moyenne.

z  = (pf.yu + pf.yl) / 2;
th = acos(1 - 2*pf.xs);
dz = gradient(z, pf.xs);
dz([1 end]) = dz([2 end-1]);              % pentes infinies aux bords sur la grille en cosinus
A1 = 2/pi * trapz(th, dz .* cos(th));
A2 = 2/pi * trapz(th, dz .* cos(2*th));
Cm_c4  = pi/4 * (A2 - A1);
alpha0 = -1/pi * trapz(th, dz .* (cos(th) - 1)) * 180/pi;
end
