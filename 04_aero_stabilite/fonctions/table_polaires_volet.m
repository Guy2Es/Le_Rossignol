function T = table_polaires_volet(pols, d, Re_lot, pas_Cl)
%TABLE_POLAIRES_VOLET  Polaires XFoil d'un profil à plusieurs braquages, en grille (δ, Cl, Re).
%
%   T = table_polaires_volet(pols, d, Re_lot, pas_Cl)
%     pols   : cellule nD × nR de polaires 2D (lire_polaire_2d) : ligne j = braquage d(j)
%              (0 = profil de base), colonne r = Re_lot(r)
%     d      : braquages [deg], croissants
%     Re_lot : Re des polaires, croissants
%     pas_Cl : pas de la grille de Cl
%   Chaque polaire est prise sur sa branche attachée (du Cl minimal au Cl maximal) et
%   rééchantillonnée linéairement en Cl. Hors de cette branche : NaN (pas d'extrapolation).
%   Sortie : T.d, T.Cl, T.lRe (log Re) ; T.F.Cm, T.F.alpha, T.F.CD : griddedInterpolant
%   linéaires en (δ, Cl, log Re). Lecture : interp_polaires_volet.
%   T.Clmax (nD × nR) : Cl maximal de chaque polaire ; T.F.Clmax : linéaire en (δ, log Re) ;
%   T.fin (nD × nR) : Cl maximal atteint au dernier α calculé (borne basse du Clmax).

[nD, nR] = size(pols);
assert(nD == numel(d) && nR == numel(Re_lot) && issorted(d, 'strictascend') && issorted(Re_lot, 'strictascend'), ...
       'table_polaires_volet:taille', 'cellule, braquages et Re incohérents');
br = cell(nD, nR);
lim = [Inf -Inf];
T.Clmax = zeros(nD, nR);  T.fin = false(nD, nR);
for j = 1:nD
    for r = 1:nR
        q = pols{j, r};
        [~, iM] = max(q.CL);
        [~, im] = min(q.CL(1:iM));
        k = im:iM;
        [cl, u] = unique(q.CL(k));
        br{j, r} = struct('Cl', cl, 'Cm', q.Cm(k(u)), 'alpha', q.alpha(k(u)), 'CD', q.CD(k(u)));
        lim = [min(lim(1), cl(1)), max(lim(2), cl(end))];
        T.Clmax(j, r) = q.CL(iM);
        T.fin(j, r) = iM == numel(q.CL);
    end
end
T.d = d(:).';
T.Cl = (floor(lim(1) / pas_Cl) : ceil(lim(2) / pas_Cl)) * pas_Cl;
T.lRe = log(Re_lot(:).');
for champ = ["Cm" "alpha" "CD"]
    V = NaN(nD, numel(T.Cl), nR);
    for j = 1:nD
        for r = 1:nR
            V(j, :, r) = interp1(br{j, r}.Cl, br{j, r}.(champ), T.Cl, 'linear', NaN);
        end
    end
    T.F.(champ) = griddedInterpolant({T.d, T.Cl, T.lRe}, V, 'linear', 'none');
end
T.F.Clmax = griddedInterpolant({T.d, T.lRe}, T.Clmax, 'linear', 'none');
end
