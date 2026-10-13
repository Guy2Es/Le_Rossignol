function B = budget_reaffecte(gp, p)
%BUDGET_REAFFECTE  Budget de masse réaffecté (plan d'allègement) et structure cible.
%
%   B = budget_reaffecte(gp, p)
%     gp : groupe propulsif de l'option retenue (masse_option.m), en grammes
%     p  : paramètres (p.masse.postes, p.allg)
%   Sortie : structure B (grammes)
%     postes   : table Poste, Groupe, Cahier_g, Reaffecte_g, Ecart_g, Piece
%     gain     : somme des économies du plan (postes p.allg), > 0
%     structure, systemes, sans_batt, total_3S, total_4S (cellules 69 g),
%     total_4S_fiche (cellules 70 g) : avec la structure du cahier
%     struct_max_4S : structure maximale pour 4S1P ≤ 800 g, cellules 70 g
%     struct_max_sb : structure maximale pour V1-MAS-02 (≤ 520 g sans batterie)
%     struct_cible  : min(V1-MAS-03, structures maximales), arrondie au gramme inférieur
%     mod03         : vrai si la cible passe sous la valeur de V1-MAS-03
%
%   Bilan : le poste « moteur + hélice + cône » (62 g) est remplacé par le
%   groupe propulsif réel, et chaque poste de p.allg par la pièce relevée
%   (somme de ses composants). Les autres postes du cahier sont inchangés.
%   Structure maximale : masse limite − systèmes réaffectés − batterie.

P = p.masse.postes;
m0 = double(P(:, 3));
m1 = m0;
piece = repmat("cahier", size(P, 1), 1);
% Groupe propulsif réel
i = find(P(:, 1) == p.gp.poste, 1);
m1(i) = gp.total;
piece(i) = "groupe propulsif réel (moteur de fiche + pales + moyeu-cône)";
% Pièces du plan d'allègement
for k = 1:size(p.allg.postes, 1)
    i = find(P(:, 1) == p.allg.postes(k, 1), 1);
    assert(~isempty(i), 'poste « %s » absent du budget', p.allg.postes(k, 1));
    m1(i) = sum(p.allg.m{k});                        % g, somme des composants
    piece(i) = p.allg.postes(k, 2);
end
B.postes = table(P(:, 1), P(:, 2), m0, m1, m1 - m0, piece, ...
    'VariableNames', {'Poste', 'Groupe', 'Cahier_g', 'Reaffecte_g', 'Ecart_g', 'Piece'});
iPlan = ismember(P(:, 1), p.allg.postes(:, 1));
B.gain = -sum(m1(iPlan) - m0(iPlan));               % g économisés par le plan

estS = P(:, 2) == "structure";
B.structure = sum(m1(estS));                        % g, structure du cahier
B.systemes  = sum(m1(~estS));                       % g, systèmes réaffectés
B.sans_batt = B.structure + B.systemes;             % g, V1-MAS-02
dm_cell = 1000 * (p.batt.m_cell_fiche - p.batt.m_cell);   % g par cellule
batt4_fiche = p.masse.batt_4S + 4 * dm_cell;        % g, 4S1P avec cellules à 70 g
B.total_3S = B.sans_batt + p.masse.batt_3S;
B.total_4S = B.sans_batt + p.masse.batt_4S;
B.total_4S_fiche = B.sans_batt + batt4_fiche;

% Structure maximale admissible (V1-MAS-01 avec cellules à 70 g ; V1-MAS-02)
B.struct_max_4S = p.masse.MTOW - B.systemes - batt4_fiche;
B.struct_max_sb = p.masse.max_sans_batt - B.systemes;
B.struct_cible  = floor(min([p.masse.max_struct, B.struct_max_4S, B.struct_max_sb]));
B.mod03 = B.struct_cible < p.masse.max_struct;
% Totaux à la structure cible
B.cible_4S_fiche = B.struct_cible + B.systemes + batt4_fiche;
B.cible_sans_batt = B.struct_cible + B.systemes;
end
