function P = lire_polaire_T2(fichier)
%LIRE_POLAIRE_T2  Polaire de plan xflr5 v6.62 exportée en .txt (analyse de type 2).
%
%   P = lire_polaire_T2(fichier)
%   Sortie : P.avion, P.polaire, et un vecteur colonne par colonne du fichier,
%   sous le nom écrit par xflr5 (la casse compte : CL est la portance de l'avion,
%   Cl le moment de roulis) :
%     alpha, Beta [deg] ; CL, CDi, CDv, CD, CY, Cl, Cm, Cn, Cni [-] ;
%     QInf [m/s] ; XCP [m]
%   Cm est pris au point de référence des moments de xflr5 (le CG de l'inertie du plan).
%   L'export ne contient pas de colonne XNP : voir xnp_polaire.

L = readlines(fichier);
Lt = strtrim(L);
iA = find(startsWith(Lt, "Plane name"), 1);
iP = find(startsWith(Lt, "Polar name"), 1);
iH = find(startsWith(Lt, "alpha"), 1);
assert(~isempty(iA) && ~isempty(iP) && ~isempty(iH), 'lire_polaire_T2:format', ...
       'en-tête non reconnu dans %s', fichier);
P.avion   = strtrim(extractAfter(Lt(iA), ":"));
P.polaire = strtrim(extractAfter(Lt(iP), ":"));
noms = cellstr(split(Lt(iH)).');
n = numel(noms);

k = iH + 1;
M = zeros(0, n);
while k <= numel(Lt) && strlength(Lt(k)) > 0
    v = sscanf(char(Lt(k)), '%f').';
    assert(numel(v) == n, 'lire_polaire_T2:colonnes', ...
           'ligne %d : %d valeurs pour %d colonnes', k, numel(v), n);
    M(end+1, :) = v; %#ok<AGROW>
    k = k + 1;
end
assert(~isempty(M), 'lire_polaire_T2:vide', 'aucun point dans %s', fichier);
for j = 1:n
    P.(noms{j}) = M(:, j);
end
assert(issorted(P.alpha, 'strictascend'), 'lire_polaire_T2:ordre', 'alpha non croissant');
end
