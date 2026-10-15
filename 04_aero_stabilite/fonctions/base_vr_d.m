function X = base_vr_d(vr, d, centre, echelle)
%BASE_VR_D  Base du modèle quadratique en (vrillage, braquage) des T2 non visqueux.
%
%   X = base_vr_d(vr, d, centre, echelle)
%     vr, d   : vrillage au saumon et braquage des élevons [deg] (vecteurs de même taille)
%     centre  : vrillage central [deg] ; echelle : [demi-plage du vrillage, |δ| max] [deg]
%   Sortie : n × 6, colonnes 1, u, w, u², u·w, w² avec u = (vr − centre)/echelle(1),
%   w = d/echelle(2) (variables centrées réduites : même base pour l'ajustement, X\Y,
%   et l'évaluation, X·β).

u = (vr(:) - centre) / echelle(1);
w = d(:) / echelle(2);
X = [ones(numel(u), 1), u, w, u.^2, u.*w, w.^2];
end
