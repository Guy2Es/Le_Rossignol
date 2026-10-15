function k = carac_polaire(P, tol_creux, cl_op, cl_fit)
%CARAC_POLAIRE  Caractéristiques d'une polaire de profil (lire_polaire_2d).
%
%   k = carac_polaire(P, tol_creux, cl_op, cl_fit)
%     P         : polaire (lire_polaire_2d)
%     tol_creux : creux de traînée = plage de Cl où Cd ≤ (1 + tol_creux)·Cd_min
%     cl_op     : Cl de fonctionnement où lire Cd, Cm et alpha (vecteur, optionnel)
%     cl_fit    : [Cl_bas Cl_haut] de la droite Cm(Cl) (optionnel) :
%                 Cm0_fit = ordonnée à l'origine, pente = dCm/dCl au quart avant
%                 (= 0,25 − x_ac/c, skill C2 p.56–61), sur la branche avant décrochage
%   Sortie (structure) :
%     Clmax, a_Clmax, Clmax_borne (vrai si le max est au dernier alpha calculé :
%       le vrai Clmax est alors au moins cette valeur)
%     Cm0, a0     : Cm et alpha à Cl = 0, interpolés linéairement entre les deux
%                   points qui encadrent Cl = 0 sur la branche avant décrochage
%     da0         : écart d'alpha entre ces deux points (trou de convergence si > pas)
%     n0          : nombre de passages de Cl par 0 sur cette branche (1 attendu)
%     LDmax, Cl_LD, P15max, Cl_P15 : (Cl/Cd)max et (Cl^1,5/Cd)max, sur Cl > 0
%     Cdmin, Cl_Cdmin, creux = [Cl_bas Cl_haut], creux_larg
%     Cd_op, Cm_op, a_op : valeurs à cl_op (NaN si cl_op est hors de la branche)

if nargin < 3, cl_op = []; end
if nargin < 4, cl_fit = []; end
a = P.alpha;  cl = P.CL;  cd = P.CD;  cm = P.Cm;

% Décrochage : maximum de Cl ; la branche utile va du début à ce point
[k.Clmax, iM] = max(cl);
k.a_Clmax = a(iM);
k.Clmax_borne = iM == numel(cl);
b = 1:iM;

% Cm0 : passage de Cl par zéro sur la branche
s = find(cl(b(1:end-1)) <= 0 & cl(b(2:end)) > 0);
k.n0 = numel(s);
if isempty(s)
    k.Cm0 = NaN;  k.a0 = NaN;  k.da0 = NaN;
else
    s = s(end);                                     % passage le plus proche du domaine utile
    w = -cl(s) / (cl(s+1) - cl(s));
    k.Cm0 = cm(s) + w * (cm(s+1) - cm(s));
    k.a0  = a(s)  + w * (a(s+1) - a(s));
    k.da0 = a(s+1) - a(s);
end

% Contrôle de Cm0 hors de la bulle de Cl ≈ 0 : droite Cm(Cl) extrapolée
k.Cm0_fit = NaN;  k.pente = NaN;
if ~isempty(cl_fit)
    u = b(cl(b) >= cl_fit(1) & cl(b) <= cl_fit(2));
    if numel(u) >= 3
        cf = polyfit(cl(u), cm(u), 1);
        k.pente = cf(1);  k.Cm0_fit = cf(2);
    end
end

% Finesse et facteur d'endurance du profil, sur Cl > 0
u = cl > 0;
[k.LDmax, j]  = max(cl(u) ./ cd(u));   clu = cl(u);  k.Cl_LD = clu(j);
[k.P15max, j] = max(cl(u).^1.5 ./ cd(u));          k.Cl_P15 = clu(j);

% Creux de traînée, sur la branche, bords interpolés en Cl
[k.Cdmin, im] = min(cd(b));
k.Cl_Cdmin = cl(im);
seuil = (1 + tol_creux) * k.Cdmin;
lo = im;  while lo > 1  && cd(lo-1) <= seuil, lo = lo - 1; end
hi = im;  while hi < iM && cd(hi+1) <= seuil, hi = hi + 1; end
k.creux = [bord(lo, lo-1), bord(hi, hi+1)];
k.creux_larg = diff(k.creux);

% Valeurs au Cl de fonctionnement (premier passage croissant au-dessus de Cl = 0)
k.Cd_op = NaN(size(cl_op));  k.Cm_op = k.Cd_op;  k.a_op = k.Cd_op;
d0 = max([s; 1]);
for n = 1:numel(cl_op)
    j = find(cl(d0:iM-1) <= cl_op(n) & cl(d0+1:iM) > cl_op(n), 1) + d0 - 1;
    if ~isempty(j)
        w = (cl_op(n) - cl(j)) / (cl(j+1) - cl(j));
        k.Cd_op(n) = cd(j) + w * (cd(j+1) - cd(j));
        k.Cm_op(n) = cm(j) + w * (cm(j+1) - cm(j));
        k.a_op(n)  = a(j)  + w * (a(j+1) - a(j));
    end
end

    function c = bord(dedans, dehors)
        % Cl où Cd croise le seuil entre un point dans le creux et son voisin dehors
        if dehors < 1 || dehors > iM
            c = cl(dedans);                         % creux ouvert : borné par les données
        else
            w2 = (seuil - cd(dedans)) / (cd(dehors) - cd(dedans));
            c = cl(dedans) + w2 * (cl(dehors) - cl(dedans));
        end
    end
end
