function D = cm_visqueux_bandes(y, Cl, c, Re, pol, Re_lot, Cm_ref, S, MAC)
%CM_VISQUEUX_BANDES  Correction visqueuse du Cm de l'aile, bande par bande.
%
%   D = cm_visqueux_bandes(y, Cl, c, Re, pol, Re_lot, Cm_ref, S, MAC)
%     y      : stations en envergure [m] (aile entière, n × 1)
%     Cl     : Cl local (n × k, une colonne par point de vol)
%     c      : corde locale [m] (n × 1)
%     Re     : Reynolds local (n × k)
%     pol    : polaires XFoil du profil (cellule, une par Re de Re_lot)
%     Re_lot : Re des polaires
%     Cm_ref : Cm au quart avant de la ligne moyenne (profils minces), celui que
%              porte la VLM non visqueuse
%     S, MAC : références de l'aile
%   Sortie (structure) :
%     dCm : 1 × k, ΔCm de l'aile = (1/(S·MAC))·∫ (Cm_XFoil(Re, Cl) − Cm_ref)·c² dy
%     Cm_xf : n × k, Cm XFoil interpolé (linéaire en Cl, puis en log Re)
%   Le moment de bande est un couple pur : il s'ajoute au Cm de l'aile quel que
%   soit le point de référence. HORS SKILL (théorie des bandes) : la redistribution
%   de portance due à la viscosité est négligée.
%   Erreur si un Cl local ou un Re sort des polaires (pas d'extrapolation).

[n, k] = size(Cl);
nR = numel(Re_lot);
assert(all(Re(:) >= min(Re_lot) & Re(:) <= max(Re_lot)), 'cm_visqueux_bandes:Re', ...
       'Re local hors du lot (%.0f à %.0f)', min(Re(:)), max(Re(:)));
CmR = zeros(n, k, nR);
for j = 1:nR
    q = pol{j};
    [~, iM] = max(q.CL);                       % branche montante jusqu'au Clmax
    [cl, u] = unique(q.CL(1:iM));
    cm = q.Cm(u);
    CmR(:, :, j) = interp1(cl, cm, Cl, 'linear', NaN);
end
assert(~any(isnan(CmR), 'all'), 'cm_visqueux_bandes:Cl', 'Cl local hors des polaires XFoil');
D.Cm_xf = zeros(n, k);
lR = log(Re_lot(:));
for a = 1:n
    for b = 1:k
        D.Cm_xf(a, b) = interp1(lR, squeeze(CmR(a, b, :)), log(Re(a, b)));
    end
end
D.dCm = trapz(y(:), (D.Cm_xf - Cm_ref) .* c(:).^2, 1) / (S * MAC);
end
