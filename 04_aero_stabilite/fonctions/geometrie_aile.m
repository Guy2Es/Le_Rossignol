function g = geometrie_aile(p, fleche, vrillage)
%GEOMETRIE_AILE  Géométrie de l'aile trapézoïdale en flèche (phase 4).
%
%   g = geometrie_aile(p, fleche, vrillage)
%     p        : paramètres (p.geo, p.geo4)
%     fleche   : flèche du bord d'attaque [deg]
%     vrillage : vrillage au saumon [deg] (négatif = piqueur)
%   Sortie : structure g (m, deg), demi-aile droite, origine au bord
%   d'attaque de l'emplanture, x vers l'arrière :
%     y, c, xBA, vr       : stations p.geo4.y_sec (envergure, corde, BA, vrillage)
%     cf(y), xBAf(y), vrf(y) : lois continues
%     S, MAC, Ymac, Xmac  : intégrales numériques (aerodynamic-model.md, C2 p.62-64)
%     MAC_sk, Ymac_sk, Xmac_sk : formules du trapèze de la skill (C2 p.64)
%     xF_sk               : foyer de l'aile seule estimé par la skill :
%                           X_mac + 0,25·MAC (aerodynamic-model.md ; 25 % de la
%                           MAC, C2 p.59-62). Estimation de recoupement : la
%                           skill ne traite ni la flèche ni les winglets
%                           (VLM hors de son domaine).
%     wl                  : winglet (pied et tête : x, z, corde)

b2 = p.geo.b / 2;
ci = p.geo.c_emp;  ce = p.geo.c_ext;
E  = ce / ci;                                   % effilement (notation unifiée de la skill)
tL = tand(fleche);

g.fleche = fleche;  g.vrillage = vrillage;
g.cf   = @(y) ci + (ce - ci) .* y ./ b2;
g.xBAf = @(y) tL .* y;
switch p.geo4.loi_vrillage
    case "lineaire"
        g.vrf = @(y) vrillage .* y ./ b2;
    otherwise
        error('geometrie_aile:vrillage', 'loi de vrillage inconnue : %s', p.geo4.loi_vrillage);
end
g.y   = p.geo4.y_sec(:);
g.c   = g.cf(g.y);
g.xBA = g.xBAf(g.y);
g.vr  = g.vrf(g.y);

% Intégrales numériques (aile entière = 2 × demi-aile)
yy = linspace(0, b2, 2001);
cc = g.cf(yy);
g.S    = 2 * trapz(yy, cc);
g.MAC  = 2 / g.S * trapz(yy, cc.^2);                 % MAC = (2/S)∫c² dy
g.Ymac = 2 / g.S * trapz(yy, cc .* yy);              % station de la MAC (centroïde)
g.Xmac = 2 / g.S * trapz(yy, cc .* g.xBAf(yy));      % BA de la MAC

% Formules du trapèze (skill, aerodynamic-model.md, C2 p.64)
g.MAC_sk  = 2/3 * ci * (1 + E + E^2) / (1 + E);
g.Ymac_sk = b2 / 3 * (1 + 2*E) / (1 + E);
g.Xmac_sk = tL * g.Ymac_sk;
g.xF_sk   = g.Xmac_sk + 0.25 * g.MAC_sk;

% Winglet (dérive verticale au saumon)
w.h = p.geo4.wl_h;
w.c_pied = p.geo4.wl_c_pied;  w.c_tete = p.geo4.wl_c_tete;
w.x_pied = g.xBAf(b2);
w.x_tete = w.x_pied + tand(p.geo4.wl_fleche) * w.h;
w.y = b2;
g.wl = w;
end
