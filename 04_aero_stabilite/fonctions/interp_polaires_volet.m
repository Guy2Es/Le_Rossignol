function [v, ext] = interp_polaires_volet(T, champ, d, Cl, Re)
%INTERP_POLAIRES_VOLET  Valeur d'une colonne de polaire XFoil à (δ, Cl, Re) donnés.
%
%   [v, ext] = interp_polaires_volet(T, champ, d, Cl, Re)
%     T     : table_polaires_volet
%     champ : "Cm", "alpha", "CD", ou "Clmax" (Cl maximal de la polaire, Cl ignoré)
%     d, Cl, Re : braquage [deg], Cl local, Reynolds (tableaux de même taille, ou d scalaire)
%   Linéaire en δ, en Cl et en log Re. Hors de la plage des braquages, prolongement
%   linéaire en δ par les deux braquages extrêmes (ext = true, à signaler). Erreur si un
%   Cl ou un Re sort des polaires.

if isscalar(d), d = repmat(d, size(Cl)); end
n = numel(d);
lRe = log(Re(:)) .* ones(n, 1);
Clc = Cl(:) .* ones(n, 1);
if champ == "Clmax"
    F = @(dd, k) T.F.Clmax(dd, lRe(k));
else
    F = @(dd, k) T.F.(champ)(dd, Clc(k), lRe(k));
end
dv = d(:);
v = F(min(max(dv, T.d(1)), T.d(end)), true(n, 1));
lo = dv < T.d(1);
hi = dv > T.d(end);
if any(lo)
    v1 = F(repmat(T.d(2), nnz(lo), 1), lo);
    v(lo) = v(lo) + (dv(lo) - T.d(1)) .* (v1 - v(lo)) / (T.d(2) - T.d(1));
end
if any(hi)
    v1 = F(repmat(T.d(end-1), nnz(hi), 1), hi);
    v(hi) = v(hi) + (dv(hi) - T.d(end)) .* (v(hi) - v1) / (T.d(end) - T.d(end-1));
end
v = reshape(v, size(d));
ext = reshape(lo | hi, size(d));
assert(~any(isnan(v), 'all'), 'interp_polaires_volet:hors', ...
       '%s : Cl (%.3f à %.3f) ou Re (%.0f à %.0f) hors des polaires', champ, min(Cl(:)), max(Cl(:)), min(Re(:)), max(Re(:)));
end
