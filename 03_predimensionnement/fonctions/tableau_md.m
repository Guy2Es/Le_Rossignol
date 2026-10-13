function tableau_md(fid, titre, entetes, cellules)
%TABLEAU_MD  Écrit un tableau Markdown dans un fichier ouvert.
%
%   tableau_md(fid, titre, entetes, cellules)
%     fid      : identifiant de fichier (fopen) ; 1 pour la console
%     titre    : titre du tableau (ligne « ### ») ; "" pour aucun
%     entetes  : tableau de chaînes (1 × nc)
%     cellules : tableau de chaînes (nl × nc), déjà formatées

if strlength(titre) > 0
    fprintf(fid, '\n### %s\n\n', titre);
end
fprintf(fid, '| %s |\n', strjoin(entetes, ' | '));
fprintf(fid, '|%s\n', repmat(' --- |', 1, numel(entetes)));
for i = 1:size(cellules, 1)
    fprintf(fid, '| %s |\n', strjoin(cellules(i, :), ' | '));
end
fprintf(fid, '\n');
end
