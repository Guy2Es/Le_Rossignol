function pf = lire_profil_dat(fichier)
%LIRE_PROFIL_DAT  Lit un profil au format Selig (.dat UIUC) et le caractérise.
%
%   pf = lire_profil_dat(fichier)
%     fichier : .dat au format Selig : 1re ligne = nom, puis x y du bord de
%               fuite à l'extrados, au bord d'attaque, puis à l'intrados
%   Sortie : structure pf
%     nom, x, y        : coordonnées lues (corde normalisée à 1)
%     xs               : grille de x/c commune (cosinus)
%     yu, yl           : extrados et intrados interpolés sur xs
%     t, xt            : épaisseur relative maximale et sa position x/c
%     f, xf            : cambrure relative maximale et sa position x/c
%     epaisseur(xc)    : fonction : épaisseur relative à la position xc
%     reflexe          : vrai si la ligne moyenne remonte vers le bord de fuite
%                        (cambrure de la dernière partie inférieure au maximum
%                        du dernier quart, signe d'un profil autostable)
%
%   Lecture seule de données numériques : toute ligne non numérique après la
%   première est une erreur.

txt = readlines(fichier);
txt = strtrim(txt(strlength(strtrim(txt)) > 0));
pf.nom = regexprep(txt(1), '\s+', ' ');      % même forme que lire_polaire_2d (appariement)
v = str2double(split(regexprep(txt(2:end), '\s+', ' '), ' '));
if any(isnan(v), 'all') || size(v, 2) ~= 2
    error('lire_profil_dat:format', '%s : coordonnées non numériques', fichier);
end
x = v(:, 1);  y = v(:, 2);

% Normalisation de la corde (bord d'attaque en 0, bord de fuite en 1)
[~, iBA] = min(x);
x0 = x(iBA);  c = max(x) - x0;
x = (x - x0) / c;  y = (y - y(iBA)) / c;
pf.x = x;  pf.y = y;

% Séparation extrados (du BF au BA) et intrados (du BA au BF)
xu = flipud(x(1:iBA));  yu = flipud(y(1:iBA));
xl = x(iBA:end);        yl = y(iBA:end);
if mean(yu) < mean(yl)
    error('lire_profil_dat:ordre', '%s : ordre Selig attendu (extrados d''abord)', fichier);
end
[xu, iu] = unique(xu);  yu = yu(iu);
[xl, il] = unique(xl);  yl = yl(il);

pf.xs = (1 - cos(linspace(0, pi, 401)')) / 2;
pf.yu = interp1(xu, yu, pf.xs, 'pchip');
pf.yl = interp1(xl, yl, pf.xs, 'pchip');
t = pf.yu - pf.yl;
cam = (pf.yu + pf.yl) / 2;
[pf.t, i] = max(t);   pf.xt = pf.xs(i);
[pf.f, i] = max(cam); pf.xf = pf.xs(i);
xs = pf.xs;
pf.epaisseur = @(xc) interp1(xs, t, xc, 'pchip');

% Réflexe : la ligne moyenne remonte entre son minimum du dernier tiers et le BF
arr = xs > 0.67;
pf.reflexe = any(diff(cam(arr)) > 0);
end
