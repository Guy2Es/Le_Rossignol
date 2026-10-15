function I = index_exports_xflr5(dossier)
%INDEX_EXPORTS_XFLR5  Reconnaît les exports xflr5 v6.62 d'un dossier par leur en-tête.
%
%   I = index_exports_xflr5(dossier)
%   Les noms de fichiers choisis à l'export ne sont pas utilisés : seul le contenu compte.
%   Sortie : table, une ligne par fichier .txt, colonnes
%     fichier : chemin complet
%     type    : "polaire" (polaire d'avion, lire_polaire_T2), "point" (point de
%               fonctionnement, lire_point_xflr5) ou "autre" (graphe, polaire 2D...)
%     avion, analyse : noms écrits par xflr5 ("" pour "autre")
%     alpha   : incidence du point [deg] (NaN sauf pour "point")

f = dir(fullfile(dossier, '*.txt'));
n = numel(f);
I = table('Size', [n 5], 'VariableTypes', ["string" "string" "string" "string" "double"], ...
          'VariableNames', {'fichier', 'type', 'avion', 'analyse', 'alpha'});
for k = 1:n
    fk = string(fullfile(f(k).folder, f(k).name));
    L = strtrim(string(readlines(fk)));
    L(end+1:6) = "";                                   % fichiers courts : en-tête complété à vide
    I(k, :) = {fk, "autre", "", "", NaN};
    if ~startsWith(L(1), "xflr5"), continue; end
    if startsWith(L(3), "Plane name")
        I.type(k) = "polaire";
        I.avion(k) = strtrim(extractAfter(L(3), ":"));
        I.analyse(k) = strtrim(extractAfter(L(4), ":"));
    elseif startsWith(L(6), "Alpha")
        I.type(k) = "point";
        I.avion(k) = L(3);
        I.analyse(k) = L(4);
        I.alpha(k) = str2double(strtrim(extractAfter(L(6), "=")));
    end
end
end
