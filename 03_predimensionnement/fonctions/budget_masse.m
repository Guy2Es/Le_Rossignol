function bm = budget_masse(p)
%BUDGET_MASSE  Budget de masse poste par poste (cahier) et marges.
%
%   bm = budget_masse(p)
%   Reprend le tableau du cahier des charges (p.masse.postes, en grammes),
%   recalcule les sous-totaux et les marges sous 800 g (V1-MAS-01), sous
%   520 g sans batterie (V1-MAS-02) et sous 320 g de structure (V1-MAS-03).
%   Ajoute le cas « cellules à 70,0 g » (masse maximale de la fiche
%   Molicel) au lieu des 69 g du cahier.

P = p.masse.postes;
m = double(P(:, 3));
bm.postes      = table(P(:, 1), P(:, 2), m, 'VariableNames', {'Poste', 'Groupe', 'Masse_g'});
bm.structure   = sum(m(P(:, 2) == "structure"));
bm.systemes    = sum(m(P(:, 2) == "systèmes"));
bm.sans_batt   = bm.structure + bm.systemes;
bm.total_3S    = bm.sans_batt + p.masse.batt_3S;
bm.total_4S    = bm.sans_batt + p.masse.batt_4S;
bm.marge_3S    = p.masse.MTOW - bm.total_3S;
bm.marge_4S    = p.masse.MTOW - bm.total_4S;
bm.marge_sans_batt = p.masse.max_sans_batt - bm.sans_batt;
bm.marge_struct    = p.masse.max_struct    - bm.structure;
bm.marge_seuil330  = p.masse.seuil_struct  - bm.structure;

% Sensibilité à la masse réelle des cellules (fiche : 70,0 g max)
dm_cell = (p.batt.m_cell_fiche - p.batt.m_cell) * 1000;      % g par cellule
bm.total_4S_fiche = bm.total_4S + 4 * dm_cell;
bm.total_3S_fiche = bm.total_3S + 3 * dm_cell;
bm.marge_4S_fiche = p.masse.MTOW - bm.total_4S_fiche;
end
