function aero = import_polaire_xflr5(fichier, aero_base)
%IMPORT_POLAIRE_XFLR5  Importe une polaire xflr5 (CSV) pour polaire.m.
%
%   aero = import_polaire_xflr5(fichier, aero_base)
%     fichier   : CSV exporté depuis xflr5 avec au moins les colonnes
%                 alpha, CL, CD, Cm (en-têtes reconnus sans tenir compte de
%                 la casse ; sinon les 4 premières colonnes numériques sont
%                 prises dans cet ordre)
%     aero_base : structure aero existante (p.aero), dont on garde lambda
%                 et e pour information
%   Sortie : structure aero de type "xflr5", utilisable telle quelle par
%            polaire(CL, aero) et donc par tout le reste du code.
%
%   ÉBAUCHE pour la phase 4. À vérifier sur un vrai export xflr5 : lignes
%   d'en-tête, séparateur décimal, nom exact des colonnes (CL, CD ou
%   CDtot / TCd selon le type d'analyse). Pour une analyse 3D (type 1 ou 2
%   en xflr5), la traînée de la nacelle et des winglets n'est pas incluse :
%   il faudra l'ajouter (ΔCD0) avant de remplacer la polaire parabolique.

M = readtable(fichier, 'VariableNamingRule', 'preserve');
noms = lower(string(M.Properties.VariableNames));

% Colonnes repérées par leur nom, sinon par leur position
col = @(cible, rang) colonne(M, noms, cible, rang);
alpha = col("alpha", 1);
CL    = col("cl", 2);
CD    = col("cd", 3);
Cm    = col("cm", 4);

ok = all(isfinite([alpha CL CD Cm]), 2);
alpha = alpha(ok); CL = CL(ok); CD = CD(ok); Cm = Cm(ok);

% On ne garde que la branche avant décrochage : jusqu'au CL maximal
[CLmax, iMax] = max(CL);
alpha_decro = alpha(iMax);          % incidence de CL maximal
garde = alpha <= alpha_decro;
alpha = alpha(garde); CL = CL(garde); CD = CD(garde); Cm = Cm(garde);

% Table triée par CL croissant, sans doublon (nécessaire à interp1)
[CLu, iu] = unique(CL);
aero = aero_base;
aero.type  = "xflr5";
aero.table = table(alpha(iu), CLu, CD(iu), Cm(iu), ...
                   'VariableNames', {'alpha', 'CL', 'CD', 'Cm'});
aero.CLmax = CLmax;
aero.CD0   = min(CD);   % traînée minimale, pour information seulement
aero.source = string(fichier);
end

function v = colonne(M, noms, cible, rang)
% Renvoie la colonne dont le nom vaut exactement « cible », sinon celle de rang « rang »
i = find(noms == cible, 1);
if isempty(i)
    i = rang;
end
v = M{:, i};
end
