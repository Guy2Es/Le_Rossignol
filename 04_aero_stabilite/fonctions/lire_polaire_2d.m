function P = lire_polaire_2d(fichier)
%LIRE_POLAIRE_2D  Lit une polaire de profil exportée par xflr5 v6.62 (format texte XFoil).
%
%   P = lire_polaire_2d(fichier)
%   Sortie (structure) :
%     profil : nom du profil (ligne « Calculated polar for: »)
%     Re, Mach, Ncrit, xtr = [extrados intrados]
%     alpha [deg], CL, CD, CDp, Cm (quart avant), xtr_haut, xtr_bas : colonnes
%   Seules les 7 premières colonnes sont lues : la v6.62 écrit 13 valeurs par
%   ligne pour 10 intitulés, les colonnes suivantes ne sont pas utilisées.
%   Erreur si l'en-tête ne commence pas par « alpha CL CD CDp Cm ».

L = strtrim(readlines(fichier));

i = find(startsWith(L, "Calculated polar for:"), 1);
assert(~isempty(i), 'lire_polaire_2d:entete', '%s : nom du profil introuvable', fichier);
P.profil = normaliser(extractAfter(L(i), "Calculated polar for:"));

i = find(contains(L, "Ncrit ="), 1);
t = regexp(L(i), 'Mach\s*=\s*([\d.]+)\s+Re\s*=\s*([\d.]+)\s*e\s*(\d+)\s+Ncrit\s*=\s*([\d.]+)', 'tokens', 'once');
assert(numel(t) == 4, 'lire_polaire_2d:entete', '%s : ligne Mach/Re/Ncrit illisible', fichier);
v = str2double(t);
P.Mach = v(1);  P.Re = round(v(2) * 10^v(3));  P.Ncrit = v(4);

i = find(startsWith(L, "xtrf"), 1);
P.xtr = str2double(regexp(L(i), '[\d.]+', 'match'));

i = find(startsWith(L, "alpha"), 1);
h = split(L(i));
assert(numel(h) >= 5 && all(h(1:5)' == ["alpha" "CL" "CD" "CDp" "Cm"]), ...
       'lire_polaire_2d:colonnes', '%s : colonnes inattendues', fichier);

d = L(i+2:end);                          % saute la ligne de tirets
d = d(strlength(d) > 0);
X = zeros(numel(d), 7);
for k = 1:numel(d)
    x = sscanf(d(k), '%f')';
    assert(numel(x) >= 7, 'lire_polaire_2d:ligne', '%s : ligne %d incomplète', fichier, k);
    X(k, :) = x(1:7);
end
P.alpha = X(:, 1);  P.CL = X(:, 2);  P.CD = X(:, 3);  P.CDp = X(:, 4);  P.Cm = X(:, 5);
P.xtr_haut = X(:, 6);  P.xtr_bas = X(:, 7);
assert(issorted(P.alpha, 'strictascend'), 'lire_polaire_2d:alpha', '%s : alpha non croissant', fichier);
end

function s = normaliser(s)
% Espaces multiples réduits à un seul (« MH 45  9.85% » → « MH 45 9.85% »)
s = strtrim(regexprep(s, '\s+', ' '));
end
