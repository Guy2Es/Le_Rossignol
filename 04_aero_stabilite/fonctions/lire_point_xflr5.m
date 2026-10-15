function Q = lire_point_xflr5(fichier)
%LIRE_POINT_XFLR5  Point de fonctionnement d'un avion exporté par xflr5 v6.62 (fichier texte).
%
%   Q = lire_point_xflr5(fichier)
%   Le fichier commence par « xflr5 v6.62 », le nom de l'avion, le nom de l'analyse,
%   puis des lignes « Nom = valeur » (QInf, Alpha, CL, Cd, ICd, Cm, XCP...), puis une
%   table par surface : « Main Wing » (avec, si l'aile a des volets, les lignes
%   « Flap k moment = x N.m ») et « Fin » (winglets), suivies des coefficients de Cp
%   (non lus).
%   Sortie (structure) :
%     avion, analyse        : noms écrits par xflr5
%     V [m/s], alpha [deg], CL, CD, CDi, Cm, XCP [m] : valeurs globales de l'en-tête
%     moment_volet [N·m]    : moments de charnière des volets (vide sans volet)
%     aile, wl              : tables des bandes (une ligne par bande, y croissant) :
%                             y [m], c [m], Ai [deg], Cl, PCd, ICd, CmGeom, CmAirf
%                             (moment de section au quart avant de la corde locale)

L = strtrim(string(readlines(fichier)));
assert(numel(L) > 4 && startsWith(L(1), "xflr5"), 'lire_point_xflr5:format', ...
       '%s : pas un export de point xflr5', fichier);
Q.avion = L(3);
Q.analyse = L(4);
Q.V     = valeur(L, "QInf");
Q.alpha = valeur(L, "Alpha");
Q.CL    = valeur(L, "CL");
Q.CD    = valeur(L, "Cd");
Q.CDi   = valeur(L, "ICd");
Q.Cm    = valeur(L, "Cm");
Q.XCP   = valeur(L, "XCP");

t = regexp(L, 'Flap\s+\d+\s+moment\s*=\s*(-?[\d.eE+-]+)', 'tokens', 'once');
t = t(~cellfun(@isempty, t));
Q.moment_volet = cellfun(@(s) str2double(s{1}), t);

Q.aile = table_bandes(L, "Main Wing");
Q.wl   = table_bandes(L, "Fin");
end

function v = valeur(L, nom)
% Première valeur « nom = x » de l'en-tête (le nom doit être suivi d'espaces puis de « = »)
t = regexp(L, "(^|\s)" + nom + "\s*=\s*(-?[\d.eE+-]+)", 'tokens', 'once');
k = find(~cellfun(@isempty, t), 1);
assert(~isempty(k), 'lire_point_xflr5:entete', 'valeur %s introuvable', nom);
v = str2double(t{k}{2});
end

function T = table_bandes(L, surface)
% Table des bandes d'une surface : ligne de titre, puis l'intitulé « y-span ... », puis
% les lignes numériques jusqu'à la première ligne vide
noms = {'y', 'c', 'Ai', 'Cl', 'PCd', 'ICd', 'CmGeom', 'CmAirf'};
i0 = find(startsWith(L, surface) & ~contains(L, "Cp"), 1);
assert(~isempty(i0), 'lire_point_xflr5:surface', 'surface « %s » introuvable', surface);
iH = i0 + find(startsWith(L(i0+1:end), "y-span"), 1);
assert(~isempty(iH), 'lire_point_xflr5:surface', 'intitulés de « %s » introuvables', surface);
k = iH + 1;
M = zeros(0, numel(noms));
while k <= numel(L) && strlength(L(k)) > 0
    v = sscanf(char(L(k)), '%f').';
    assert(numel(v) >= numel(noms), 'lire_point_xflr5:colonnes', 'ligne %d : %d valeurs', k, numel(v));
    M(end+1, :) = v(1:numel(noms)); %#ok<AGROW>
    k = k + 1;
end
assert(~isempty(M), 'lire_point_xflr5:vide', 'aucune bande pour « %s »', surface);
T = array2table(M, 'VariableNames', noms);
assert(issorted(T.y), 'lire_point_xflr5:ordre', 'y non croissant pour « %s »', surface);
end
