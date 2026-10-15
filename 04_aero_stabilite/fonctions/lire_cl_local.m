function C = lire_cl_local(fichier)
%LIRE_CL_LOCAL  Cl local le long de l'envergure, exporté d'un point de fonctionnement xflr5.
%
%   C = lire_cl_local(fichier)
%   Le fichier a une ligne de titre « VLM1 - 4.0°-12.69m/s » (alpha, vitesse),
%   puis 4 colonnes : y et Cl de l'aile principale (toute l'envergure, de −y à +y),
%   y et Cl des winglets (y = 0,5 m + hauteur, côté gauche puis côté droit).
%   Sortie :
%     C.methode, C.alpha [deg], C.V [m/s]
%     C.y_aile, C.Cl_aile   : stations de l'aile, croissantes en y
%     C.y_wl, C.Cl_wl       : stations des winglets (vides si absents)
%     C.y_bout, C.Cl_bout   : station la plus extérieure de l'aile, et Cl moyen des
%                             deux côtés à cette station (pas d'extrapolation à y = b/2 :
%                             les stations VLM sont au centre des panneaux)

L = readlines(fichier);
Lt = string(L);
h = strtrim(Lt(1));
t = regexp(h, '^(\w+)\s*-\s*(-?\d+\.?\d*)\D*?-\s*(\d+\.?\d*)\s*m/s', 'tokens', 'once');
assert(~isempty(t), 'lire_cl_local:titre', 'titre non reconnu : %s', h);
C.methode = string(t{1});
C.alpha = str2double(t{2});
C.V = str2double(t{3});

M = NaN(0, 4);
for k = 2:numel(Lt)
    s = strtrim(Lt(k));
    if strlength(s) == 0, continue; end
    v = sscanf(char(s), '%f').';
    assert(numel(v) == 2 || numel(v) == 4, 'lire_cl_local:colonnes', ...
           'ligne %d : %d valeurs', k, numel(v));
    ligne = NaN(1, 4);                  % les colonnes absentes restent NaN (pas 0)
    ligne(1:numel(v)) = v;
    M(end+1, :) = ligne; %#ok<AGROW>
end
ia = ~isnan(M(:, 1));
C.y_aile  = M(ia, 1);   C.Cl_aile = M(ia, 2);
iw = ~isnan(M(:, 3));
C.y_wl    = M(iw, 3);   C.Cl_wl   = M(iw, 4);
assert(issorted(C.y_aile), 'lire_cl_local:ordre', 'y de l''aile non croissant');

C.y_bout = max(abs(C.y_aile));
C.Cl_bout = mean(C.Cl_aile(abs(abs(C.y_aile) - C.y_bout) < 1e-9));
end
