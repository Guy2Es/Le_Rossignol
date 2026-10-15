function A = clmax_equilibre(mg, q1, vr, dx, mode, D, CL_lim, d_lim, nIt)
%CLMAX_EQUILIBRE  CL maximal de l'aile équilibrée par les élevons (méthode de la bande critique).
%
%   A = clmax_equilibre(mg, q1, vr, dx, mode, D, CL_lim, d_lim, nIt)
%     mg : poids [N] ; q1 = ρ·S/2 [kg/m] : la vitesse vaut sqrt(mg/(q1·CL))
%     vr, dx, mode, D : comme delta_equilibre ; CL_lim = [CL faisable, CL de départ haut]
%     d_lim : plage de braquage ; nIt : pas de dichotomie
%   Un CL est faisable si l'équilibre existe dans d_lim et si chaque bande reste sous le Clmax
%   de sa polaire XFoil (à son braquage et à son Re, prolongé linéairement au-delà des
%   braquages calculés). Dichotomie sur le plus grand CL faisable.
%   Sortie : A.CL, A.dg, A.V au dernier CL faisable ; A.R (cm_elevons) ; A.iB (bande de marge
%   minimale) ; A.cause au premier CL non faisable : "bande" (une bande dépasse son Clmax),
%   "polaires" (Cl hors des polaires pendant la recherche), "braquage" (pas d'équilibre dans
%   d_lim) ; A.borne = true si CL_lim(2) est encore faisable.
%   HORS SKILL : la VLM n'est pas valable près du décrochage ; la bande critique est un
%   indicateur classique, pas une prédiction du décrochage.

[ok, dg, R, cause] = faisable(CL_lim(1), mg, q1, vr, dx, mode, D, 0, d_lim);
assert(ok, 'clmax_equilibre:depart', 'CL de départ %.3f non faisable (%s)', CL_lim(1), cause);
A = struct('CL', CL_lim(1), 'dg', dg, 'V', sqrt(mg / (q1 * CL_lim(1))), 'R', R, 'iB', 0, 'cause', "", 'borne', false);
[okH, dgH, RH, causeH] = faisable(CL_lim(2), mg, q1, vr, dx, mode, D, round(dg), d_lim);
if okH
    A = struct('CL', CL_lim(2), 'dg', dgH, 'V', sqrt(mg / (q1 * CL_lim(2))), 'R', RH, 'iB', 0, 'cause', "", 'borne', true);
    [~, A.iB] = min(RH.marge);
    return
end
lo = CL_lim(1);  hi = CL_lim(2);  A.cause = causeH;
for it = 1:nIt
    mi = (lo + hi) / 2;
    [okM, dgM, RM, causeM] = faisable(mi, mg, q1, vr, dx, mode, D, round(A.dg), d_lim);
    if okM
        lo = mi;  A.CL = mi;  A.dg = dgM;  A.R = RM;  A.V = sqrt(mg / (q1 * mi));
    else
        hi = mi;  A.cause = causeM;
    end
end
if ~isempty(A.R.marge), [~, A.iB] = min(A.R.marge); end
end

function [ok, dg, R, cause] = faisable(CL, mg, q1, vr, dx, mode, D, d0, d_lim)
V = sqrt(mg / (q1 * CL));
cause = "";
try
    [dg, R] = delta_equilibre(CL, V, vr, dx, mode, D, d0, d_lim);
catch err
    if ~strcmp(err.identifier, 'cm_elevons:convergence'), rethrow(err); end
    dg = NaN;  R = struct('hors', true);
end
if isnan(dg)
    ok = false;
    if R.hors, cause = "polaires"; else, cause = "braquage"; end
    return
end
ok = isempty(R.marge) || all(R.marge >= 0);
if ~ok, cause = "bande"; end
end
