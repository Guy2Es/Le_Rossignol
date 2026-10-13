function sauver_figure(fig, nom, dossier, dpi)
%SAUVER_FIGURE  Enregistre une figure en PNG et en .fig, puis la ferme.
%
%   sauver_figure(fig, nom, dossier, dpi)
%   Les figures sont créées invisibles (exécution d'un bloc) ; on force la
%   visibilité à la réouverture du .fig via CreateFcn.

exportgraphics(fig, fullfile(dossier, nom + ".png"), 'Resolution', dpi);
set(fig, 'CreateFcn', 'set(gcbo, ''Visible'', ''on'')');
savefig(fig, fullfile(dossier, nom + ".fig"));
close(fig);
end
