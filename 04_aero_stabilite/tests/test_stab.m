%TEST_STAB  Recoupements des fonctions de la phase 4.
%   Lancement : runtests('test_stab') depuis le dossier tests/.
%   Chaque section %% est un test indépendant.

racine = fileparts(fileparts(mfilename('fullpath')));
rac3   = fullfile(fileparts(racine), '03_predimensionnement');
addpath(fullfile(racine, 'fonctions'), racine, rac3, fullfile(rac3, 'fonctions'));
p = params_v1();

%% MAC : intégrale numérique = formule du trapèze de la skill (C2 p.64)
g = geometrie_aile(p, 27, -3);
assert(abs(g.MAC / g.MAC_sk - 1) < 1e-6, 'MAC intégrale = formule skill');
assert(abs(g.Ymac / g.Ymac_sk - 1) < 1e-6, 'Ymac intégrale = formule skill');
assert(abs(g.Xmac / g.Xmac_sk - 1) < 1e-6, 'Xmac = tan(flèche)·Ymac');
assert(abs(g.S - p.geo.S) < 1e-9, 'S retrouvée');
assert(abs(g.MAC - p.geo.MAC) < 5e-4, 'MAC du cahier (arrondie au mm)');

%% MAC : cas limites de la skill (rectangle : MAC = ci, Ymac = b/4)
q = p;  q.geo.c_ext = q.geo.c_emp;
g = geometrie_aile(q, 0, 0);
assert(abs(g.MAC - q.geo.c_emp) < 1e-9 && abs(g.Ymac - q.geo.b/4) < 1e-6, 'aile rectangulaire');

%% Vrillage linéaire : 0 à l'emplanture, valeur demandée au saumon
g = geometrie_aile(p, 27, -3);
assert(g.vr(1) == 0 && abs(g.vr(end) + 3) < 1e-12, 'vrillage aux stations');

%% Profils : l'épaisseur lue retrouve celle annoncée dans l'en-tête UIUC
annonce = struct('mh45', 9.85, 'mh60', 10.08, 'mh61', 10.26, 'naca0008', 8.00);
for nom = string(fieldnames(annonce))'
    pf = lire_profil_dat(fullfile(racine, 'profils', nom + ".dat"));
    assert(abs(100 * pf.t - annonce.(nom)) < 0.05, 'épaisseur de %s', nom);
end

%% Centrage : la batterie à la position trouvée ramène le CG sur la cible
M = table("a", 0.3, 0.2, 0, 0, 'VariableNames', {'Nom', 'm', 'x', 'y', 'z'});
mb = [0.223 0.292];  xCG = 0.155;
xb = position_batterie(M, mb, xCG);
xg = (sum(M.m .* M.x) + mb .* xb) ./ (sum(M.m) + mb);
assert(max(abs(xg - xCG)) < 1e-12, 'CG recalculé = cible');

%% Polaire 2D : lecture d'un export réel xflr5 v6.62 (MH 45, Re 170 000)
P = lire_polaire_2d(fullfile(racine, p.xfl.dossier_pol2d, "MH 45  9.85%_T1_Re0.170_M0.00_N9.0.txt"));
assert(P.profil == "MH 45 9.85%" && P.Re == 170000 && P.Ncrit == 9 && P.Mach == 0, 'en-tête');
assert(isequal(P.xtr, [1 1]) && numel(P.alpha) == 41, 'transition et nombre de points');
assert(P.alpha(1) == -6 && P.CL(1) == -0.5170 && P.CD(1) == 0.02779 && P.Cm(1) == -0.0239, 'première ligne');
assert(P.alpha(end) == 14 && P.xtr_bas(end) == 1, 'dernière ligne');

%% Caractéristiques d'une polaire synthétique (valeurs connues)
a = (-4:0.5:10)';
Q.alpha = a;  Q.CL = 0.1 * (a + 2);  Q.Cm = -0.02 + 0.01 * Q.CL;  Q.CD = 0.01 + 0.01 * (Q.CL - 0.4).^2;
k = carac_polaire(Q, 0.10, 0.5, [0.1 0.6]);
assert(abs(k.Cm0 + 0.02) < 1e-12 && abs(k.a0 + 2) < 1e-12 && k.n0 == 1, 'Cm0 et alpha0');
assert(abs(k.Cm0_fit + 0.02) < 1e-12 && abs(k.pente - 0.01) < 1e-12, 'droite Cm(Cl)');
assert(abs(k.Cdmin - 0.01) < 1e-12 && abs(k.Cl_Cdmin - 0.4) < 1e-12, 'Cd min');
assert(abs(k.creux_larg - 2*sqrt(0.1)) < 1e-2, 'creux (bords interpolés linéairement)');
assert(abs(k.Cd_op - (0.01 + 0.01*0.01)) < 1e-6 && k.Clmax_borne, 'Cd au Cl de vol ; Clmax borné');

%% Garde de l'hélice : bord de fuite en flèche recalculé à la main, garde sur le disque ≤ garde à la station
g = geometrie_aile(p, 27, -3);
G = garde_helice(p, g);
xBF_main = tand(27) * G.y_ctrl + p.geo.c_emp + (p.geo.c_ext - p.geo.c_emp) * G.y_ctrl / (p.geo.b/2);
assert(abs(G.xBF_ctrl - xBF_main) < 1e-12, 'bord de fuite à la station de contrôle');
assert(abs(G.garde_ctrl - (p.stab.x_helice - xBF_main)) < 1e-12, 'garde à la station');
assert(G.garde_min <= G.garde_ctrl + 1e-12 && abs(G.R - 4 * p.const.in) < 1e-12, 'garde sur le disque et rayon');
q = p;  q.stab.x_helice = G.xBF_max;
assert(abs(garde_helice(q, g).garde_min) < 1e-12, 'garde nulle quand l''hélice touche le bord de fuite');

%% Positions du 13 octobre : l'ESC et le câblage avancés à 130 mm, profils 3D et vrillage
bm  = budget_masse(p);
mot = constantes_moteur(p.motX.KV, "motX", p);
[~, gp] = masse_option(mot, [bm.total_3S bm.total_4S] / 1000, p);
B = budget_reaffecte(gp, p);
M = masses_composants(p, geometrie_aile(p, 27, -3), B, gp);
iE = contains(M.Nom, "ESC");  iC = contains(M.Nom, "Câblage");
assert(abs(M.x(iE) - 0.13) < 1e-12 && abs(M.x(iC) - 0.13) < 1e-12, 'ESC et câblage à 130 mm');
assert(isequal(p.xfl.profils_3d, ["mh45" "s5010"]) && p.geo4.vrillage_plage(2) == -7, 'décisions du 13/10/2026');

%% Polaire T2 : lecture de l'export réel xflr5 v6.62 (gabarit avec winglets)
dT2 = fullfile(racine, 'xflr5', 'exports', 'gabarits_T2');
P = lire_polaire_T2(fullfile(dT2, 'T2_polaire.txt'));
assert(P.avion == "Plane_Etape2" && P.polaire == "T2-VLM1" && isequal(P.alpha, [2; 3; 4; 5]), 'en-tête et alpha');
assert(P.CL(3) == 0.318258 && P.Cm(3) == -0.109884 && P.XCP(3) == 0.1892 && P.QInf(3) == 12.6901, 'ligne alpha = 4°');

%% Point neutre : pente de Cm et pente de XCP·CL concordent, et retrouvent le XNP affiché par xflr5
P = lire_polaire_T2(fullfile(racine, 'xflr5', 'exports', 'gabarits_T2', 'T2_polaire.txt'));
N = xnp_polaire(P, 0.1, 0.257);                 % CG et MAC du gabarit (panneau xflr5)
assert(N.stable && abs(N.x_NP_xcp - 0.188) < 5e-4, 'XNP xflr5 affiché : 0,188 m');
assert(abs(N.x_NP_Cm - N.x_NP_xcp) < 2e-3, 'les deux méthodes à moins de 2 mm');
assert(N.ecart_Cm < 1e-4 && N.ecart_xcp < 1e-4, 'polaire linéaire (VLM)');

%% Cl local : lecture de l'export réel (aile sur toute l'envergure, winglets à part)
C = lire_cl_local(fullfile(racine, 'xflr5', 'exports', 'gabarits_T2', 'T2_Cl_local.txt'));
assert(C.methode == "VLM1" && C.alpha == 4 && C.V == 12.69, 'titre');
assert(numel(C.y_aile) == 44 && numel(C.y_wl) == 14 && all(abs(C.y_wl) > 0.5), 'stations aile et winglets');
assert(abs(C.y_bout - 0.4583333) < 1e-7 && C.Cl_bout == 0.3485493, 'station de bout d''aile');

%% Exploitation T2 : Cl local reconstruit exact aux deux alpha exportés, Cm0 et marge cohérents
dE = fullfile(racine, p.xfl.dossier_T2);
P = lire_polaire_T2(fullfile(dE, 'T2inv_V1_S5010_vr7.txt'));
Ca = lire_cl_local(fullfile(dE, 'Cl_V1_S5010_vr7_a4.0.txt'));
Cb = lire_cl_local(fullfile(dE, 'Cl_V1_S5010_vr7_a12.0.txt'));
E = exploite_T2(P, Ca, Cb, 0.1565, 0.2565, [P.CL(P.alpha == 4), P.CL(P.alpha == 12)]);
assert(max(abs(E.Cl(:, 1) - Ca.Cl_aile)) < 1e-12 && max(abs(E.Cl(:, 2) - Cb.Cl_aile)) < 1e-12, 'Cl local aux alpha exportés');
assert(abs(E.Cl_bout(1) - Ca.Cl_bout) < 1e-12, 'Cl au saumon');
assert(abs(E.Cm0 - interp1(P.CL, P.Cm, 0, 'linear', 'extrap')) < 1e-3 && E.ecart_Cm0 < 1e-3, 'Cm0 = Cm extrapolé à CL = 0');
assert(abs(E.MS_ref * 0.2565 - (E.N.x_NP_Cm - 0.1565)) < 1e-12, 'marge = (x_NP − x_cg) / MAC');

%% Générateurs XML : même structure que les exports réels, valeurs de la géométrie et des masses
dG = fullfile(racine, 'xflr5', 'gabarits');
bm  = budget_masse(p);
mot = constantes_moteur(p.motX.KV, "motX", p);
[~, gp] = masse_option(mot, [bm.total_3S bm.total_4S] / 1000, p);
g = geometrie_aile(p, 27, -5);
M = masses_composants(p, g, budget_reaffecte(gp, p), gp);
fA = [tempname '.xml'];  fT = [tempname '.xml'];
ecrire_avion_xml(fA, "essai", g, "s5010", M, p);
ecrire_analyse_xml(fT, "T2-essai", "essai", struct('methode', "VLM2", 'rho', 1.225, 'nu', 1.46e-5, ...
    'S', 0.25, 'b', 1, 'MAC', 0.2565, 'm', 0.8, 'cg', [0.15 0 0]));
G = readstruct(fullfile(dG, 'avion_winglet.xml'));  A = readstruct(fA);
GT = readstruct(fullfile(dG, 'analyse_T2.xml'));    AT = readstruct(fT);
champs = @(s) sort(string(fieldnames(s)));
assert(isequal(champs(G.Plane), champs(A.Plane)) && isequal(champs(G.Plane.wing(1)), champs(A.Plane.wing(1))), 'structure avion');
assert(isequal(champs(G.Plane.wing(1).Sections.Section(1)), champs(A.Plane.wing(1).Sections.Section(1))), 'structure section');
assert(isequal(champs(G.Plane.Inertia.Point_Mass(1)), champs(A.Plane.Inertia.Point_Mass(1))), 'structure masse');
assert(isequal(champs(GT.Polar), champs(AT.Polar)) && AT.Polar.Use_VLM1 == "false", 'structure analyse, VLM2');
fI = [tempname '.xml'];
ecrire_analyse_xml(fI, "T2inv-essai", "essai", struct('methode', "VLM2", 'rho', 1.225, 'nu', 1.46e-5, ...
    'S', 0.25, 'b', 1, 'MAC', 0.2565, 'm', 0.8, 'cg', [0.15 0 0], 'visqueux', false));
assert(AT.Polar.Viscous_Analysis == "true" && readstruct(fI).Polar.Viscous_Analysis == "false", 'analyse non visqueuse');
delete(fI);
s = A.Plane.wing(1).Sections.Section;
assert(max(abs([s.Twist] - g.vr.')) < 1e-4 && max(abs([s.xOffset] - g.xBA.')) < 1e-6 && all([s.Left_Side_FoilName] == "S5010"), 'aile');
w = A.Plane.wing(2);
assert(w.isDoubleFin == "true" && all([w.Sections.Section.Left_Side_FoilName] == "NACA 0008"), 'winglets');
assert(A.Plane.wing(1).Tilt_angle == 0 && abs(w.Tilt_angle - g.vr(end)) < 1e-3, 'winglet incliné du vrillage du saumon');
assert(abs(sum([A.Plane.Inertia.Point_Mass.Mass]) - sum(M.m)) < 1e-5, 'masse totale');
delete(fA, fT);
% Élevons : transition centrée sur le début des élevons, géométrie interpolée sur les lois
ecrire_avion_xml(fA, "essai_elv", g, "s5010", M, p, "S5010 elv-6");
s = readstruct(fA).Plane.wing(1).Sections.Section;
ye = p.geo4.y_elevon(1);  d = p.xfl.dy_elevon / 2;
assert(isequal(round([s.y_position], 9), round([0, ye - d, ye + d, p.geo.b/2], 9)), 'sections des élevons');
assert(isequal([s.Right_Side_FoilName], ["S5010" "S5010" "S5010 elv-6" "S5010 elv-6"]) && s(2).y_number_of_panels == 1, 'profils des élevons');
assert(max(abs([s.Chord] - g.cf([s.y_position]))) < 1e-6 && max(abs([s.Twist] - g.vrf([s.y_position]))) < 1e-4 && ...
       max(abs([s.xOffset] - g.xBAf([s.y_position]))) < 1e-6, 'géométrie des sections ajoutées');
delete(fA);

%% Profils minces : NACA 2412 analytique (Cm,c/4 = −0,053 ; α0 = −2,08°, valeurs classiques)
q.xs = (1 - cos(linspace(0, pi, 2001)')) / 2;
m = 0.02;  pp = 0.4;  x = q.xs;
z = (x < pp) .* m/pp^2 .* (2*pp*x - x.^2) + (x >= pp) .* m/(1-pp)^2 .* ((1 - 2*pp) + 2*pp*x - x.^2);
q.yu = z + 0.01;  q.yl = z - 0.01;
[Cm4, a0] = cm_profil_mince(q);
assert(abs(Cm4 + 0.053) < 5e-4 && abs(a0 + 2.08) < 0.02, 'profils minces NACA 2412');

%% Correction visqueuse en bandes : Cm XFoil constant → ΔCm de l'aile = Cm − Cm_ref (∫c² dy = S·MAC)
g = geometrie_aile(p, 27, -3);
y = linspace(-0.5, 0.5, 201)';  cy = g.cf(abs(y));
q = struct('CL', (-0.5:0.1:1.2)', 'Cm', -0.02 * ones(18, 1));
D = cm_visqueux_bandes(y, 0.3 * ones(201, 2), cy, 2e5 * ones(201, 2), {q, q}, [1e5 3e5], 0.008, g.S, g.MAC);
assert(max(abs(D.dCm - (-0.02 - 0.008))) < 1e-4, 'ΔCm de l''aile');
try
    cm_visqueux_bandes(y, 1.5 * ones(201, 1), cy, 2e5 * ones(201, 1), {q, q}, [1e5 3e5], 0.008, g.S, g.MAC);
    error('test:hors', 'Cl hors polaire non détecté');
catch err
    assert(err.identifier == "cm_visqueux_bandes:Cl", 'Cl hors polaire');
end

%% Masses ponctuelles : la somme retombe sur le budget sans batterie
bm  = budget_masse(p);
mot = constantes_moteur(p.motX.KV, "motX", p);
[~, gp] = masse_option(mot, [bm.total_3S bm.total_4S] / 1000, p);
B = budget_reaffecte(gp, p);
M = masses_composants(p, geometrie_aile(p, 27, -3), B, gp);
assert(abs(1000 * sum(M.m) - B.sans_batt) < 1e-9, 'somme des masses');

%% Point de fonctionnement : export réel d'un avion à élevons, reconnu par son en-tête
I = index_exports_xflr5(fullfile(racine, p.xfl.dossier_T2));
f = I.fichier(I.type == "point" & I.avion == "V1_S5010_vr5_e3" & abs(I.alpha - 6) < 1e-6);
assert(isscalar(f) && nnz(I.type == "polaire" & I.avion == "V1_S5010_vr5_e3") == 1, 'exports reconnus par leur en-tête');
Q = lire_point_xflr5(f);
assert(Q.avion == "V1_S5010_vr5_e3" && Q.analyse == "T2inv-VLM2" && Q.CL == 0.258071 && Q.Cm == 0.00724364, 'valeurs globales');
assert(height(Q.aile) == 50 && height(Q.wl) == 14 && isequal(Q.moment_volet, [0.0065; 0.0065]), 'bandes, winglets, volets');
assert(Q.aile.c(1) == 0.1806 && Q.aile.CmAirf(1) == 0.025449, 'première bande');
g = geometrie_aile(p, 27, -5);
assert(max(abs(Q.aile.c - g.cf(abs(Q.aile.y)))) < 1e-4, 'cordes = loi en plan');

%% Modèle (vrillage, δ) : un polynôme de degré 2 est retrouvé exactement par les 6 avions
X = [-3 0; -5 0; -7 0; -3 -6; -7 -6; -5 -3];
fq = @(vr, d) 0.01 - 0.002*vr - 0.006*d + 1e-4*vr.^2 + 2e-4*vr.*d - 3e-5*d.^2;
b6 = base_vr_d(X(:, 1), X(:, 2), -5, [2 6]) \ fq(X(:, 1), X(:, 2));
assert(abs(base_vr_d(-4.3, -2.2, -5, [2 6]) * b6 - fq(-4.3, -2.2)) < 1e-12, 'polynôme retrouvé');

%% Polaires à volet en grille, puis élevons : braquage efficace, bandes et équilibre (cas synthétique exact)
% Polaires linéaires retrouvées, prolongement linéaire en δ, Cl hors polaire
dl = [-9 -6 -3 0];  ReL = [1e5 2e5];  a = (-6:0.5:14)';
pols = cell(4, 2);
for j = 1:4
    for r = 1:2
        cl = 0.1 * (a - (-0.5 - 0.4*dl(j)));         % α0 = −0,5 − 0,4·δ
        pols{j, r} = struct('alpha', a, 'CL', cl, 'Cm', (0.005 - 0.008*dl(j) + 0.001*r) * ones(size(a)), 'CD', 0.01 + 0.01*cl.^2);
    end
end
T = table_polaires_volet(pols, dl, ReL, 0.005);
assert(abs(interp_polaires_volet(T, "Cm", -4.5, 0.3, 1e5) - (0.005 + 0.036 + 0.001)) < 1e-12, 'Cm interpolé en δ');
assert(abs(interp_polaires_volet(T, "alpha", -4.5, 0.3, 1e5) - (3 - 0.5 + 1.8)) < 1e-9, 'alpha à Cl donné');
assert(abs(interp_polaires_volet(T, "Cm", 0, 0.3, sqrt(2)*1e5) - (0.005 + 0.0015)) < 1e-12, 'interpolation en log Re');
[v, e] = interp_polaires_volet(T, "Cm", [-12 2], [0.3 0.3], [1e5 1e5]);
assert(max(abs(v - (0.005 + 0.001 - 0.008*[-12 2]))) < 1e-12 && all(e), 'prolongement linéaire signalé');
try
    interp_polaires_volet(T, "Cm", -3, 5, 1e5);
    error('test:hors', 'Cl hors polaire non détecté');
catch err
    assert(err.identifier == "interp_polaires_volet:hors", 'Cl hors polaire');
end

% Élevons : Cm VLM = 0,01 − 0,006·δ − 0,08·CL ; 4 bandes (2 braquées) à Cl 0,3 ; polaires du test précédent
beta = zeros(6, 5);  beta(1, 1) = 0.01;  beta(3, 1) = -0.006 * 6;  beta(1, 2) = -0.08;  beta(1, 3) = 0.001;  beta(1, 5) = 0.075;
D = struct('beta', beta, 'centre', -5, 'echelle', [2 6], 'A', repmat([0.3 0 0 0], 4, 1), 'c', 0.2*ones(4, 1), ...
           'wy', 0.25*ones(4, 1), 'we', [1; 0; 0; 1], 'Ksec', -0.003, 'T', T, 'Cm_mince', 0.0081, 'dCm_dd', -0.01134, ...
           'tau', 0.6, 'S', 0.2, 'MAC', 0.2, 'nu', 1.5e-5);
tR = log(10 * 0.2 / 1.5e-5 / 1e5) / log(2);              % position du Re des bandes entre les deux polaires
cmx = @(d) 0.005 - 0.008*d + 0.001*(1 + tR);
dCm = @(d) 0.25 * (2*(cmx(d) - 0.0081 - (-0.01134)*d) + 2*(cmx(0) - 0.0081));   % c²·wy/(S·MAC) = 0,25 par bande
R = cm_elevons(-6, 0.4, 10, -5, "complet", D);
assert(abs(R.de - (-4)) < 1e-9 && abs(R.eta_a - 2/3) < 1e-9, 'braquage efficace : −τ·δe = Δα XFoil');
assert(abs(R.Cm - (0.01 + 0.006*4 - 0.08*0.4 - 0.003*(-6 + 4) + dCm(-6))) < 1e-9, 'Cm complet');
R = cm_elevons(-6, 0.4, 10, -5, "bandes", D);
assert(abs(R.Cm - (0.01 + 0.006*6 - 0.08*0.4 + dCm(-6))) < 1e-9 && R.de == -6, 'Cm en bandes');
dg = delta_equilibre(0.4, 10, -5, 0.05, "vlm", D, 0, [-30 15]);
assert(abs(dg - (0.01 - 0.08*0.4 + 0.4*0.05) / 0.006) < 1e-6, 'équilibre VLM analytique');
[dg, R] = delta_equilibre(0.4, 10, -5, 0.05, "complet", D, 0, [-30 15]);
assert(abs(R.Cm + 0.4*0.05) < 1e-9 && dg < 0, 'équilibre complet : Cm au CG nul');

% Variante identique aux élevons des T2 : cm_elevons inchangé dans les 3 modèles
yb4 = [-0.5; -0.25; 0; 0.25; 0.5];
W4 = weissinger(yb4, @(y) 0.2 + 0*y, @(y) 0*y, 0, 0.2, 0.2);
D0 = D;  [D0.tau, D0.dCm_dd] = volet_mince(0.75);            % volet des T2 cohérent avec la charnière
Dv = D0;  Dv.var = variante_elevons(D0, 0.75, 0.75, 0.25, 0.25, yb4, W4, 1);
for mo = ["vlm" "bandes" "complet"]
    R1 = cm_elevons(-6, 0.4, 10, -5, mo, D0);  R2 = cm_elevons(-6, 0.4, 10, -5, mo, Dv);
    assert(abs(R1.Cm - R2.Cm) < 1e-12 && abs(R1.de - R2.de) < 1e-12, 'variante des T2 : Cm inchangé (%s)', mo);
end
% Charnière à 65 %, même envergure : VLM au braquage rt·δ, moment de section ramené à rm·δ
[t0, m0] = volet_mince(0.75);  [t1, m1] = volet_mince(0.65);
Dv.var = variante_elevons(D, 0.65, 0.75, 0.25, 0.25, yb4, W4, 1);
R = cm_elevons(-6, 0.4, 10, -5, "vlm", Dv);
assert(abs(R.Cm - (0.01 + 0.006*6*t1/t0 - 0.08*0.4 - 0.003*(m1/m0 - t1/t0)*(-6))) < 1e-12, 'variante : VLM mise à l''échelle');
% Prolongement jusqu'à y = 0,125 m : moitié des bandes intérieures braquée, moment de section au prorata de c²·wy
[var, info] = variante_elevons(D, 0.65, 0.75, 0.125, 0.25, yb4, W4, 1);
assert(max(abs(info.dwe - [0; 0.5; 0.5; 0])) < 1e-12 && abs(var.Ksec_ext - (-0.003)*m1/m0*0.5) < 1e-12, 'prolongement');
assert(abs(sum(var.Aext .* D.c .* D.wy)) < 1e-12, 'prolongement à CL constant : ΣCl·c·wy = 0');
% Traînée induite du prolongement (Trefftz) : nulle sans braquage ; sinon écart des deux répartitions
var0 = variante_elevons(D, 0.65, 0.75, 0.25, 0.25, yb4, W4, 1);
assert(isempty(var0.Ktr) && isequal(var.Ktr, W4.Ktr), 'Ktr avec prolongement seulement');
Dv.var = var;
R1 = cm_elevons(0, 0.4, 10, -5, "vlm", Dv);  R2 = cm_elevons(0, 0.4, 10, -5, "vlm", D);
assert(R1.CDi == R2.CDi, 'sans braquage : pas de traînée du prolongement');
R1 = cm_elevons(-6, 0.4, 10, -5, "vlm", Dv);
k = base_vr_d(-5, R1.de, D.centre, D.echelle) * D.beta;
Cl0 = D.A * [1; 0.4; -5; R1.de];
assert(abs(R1.CDi - (k(3) + k(4)*0.4 + k(5)*0.16) - (W4.CDi(Cl0 + var.Aext*(-6)) - W4.CDi(Cl0))) < 1e-15, 'traînée induite du prolongement');
% Polaires propres à la variante : pas de mise à l'échelle des incréments XFoil
var0 = variante_elevons(D, 0.65, 0.75, 0.25, 0.25, yb4, W4, 1, true);
assert(isequal(var0.kv, [1 1]), 'polaires propres : kv = [1 1]');
% Cm0 du profil plus élevé : couple pur ΔCm0·Σc²·wy/(S·MAC) (= ΔCm0 ici), dans les 3 modèles
Dz = D;  Dz.dCm0 = 0.01;
for mo = ["vlm" "bandes" "complet"]
    R1 = cm_elevons(-6, 0.4, 10, -5, mo, Dz);  R2 = cm_elevons(-6, 0.4, 10, -5, mo, D);
    assert(abs(R1.Cm - R2.Cm - 0.01) < 1e-12, 'ΔCm0 (%s)', mo);
end

% CLmax équilibré : en VLM, butée de braquage atteinte au CL analytique ; avec les polaires, une
% bande reste sous son Clmax au dernier CL faisable
[cx, ex] = interp_polaires_volet(T, "Clmax", [-12; 0], [0; 0], [1.5e5; 1.5e5]);
assert(max(abs(cx - [1.09 - 0.12; 1.45])) < 1e-12 && isequal(ex, [true; false]), 'Clmax prolongé en δ');
A = clmax_equilibre(84, 1, -5, 0.05, "vlm", D, [0.4 1.6], [-2 15], 14);
assert(abs(A.CL - 0.022/0.03) < 1e-4 && A.cause == "braquage" && abs(A.dg + 2) < 0.01, 'CL à la butée de braquage');
Dc = D;  Dc.A = repmat([0 1 0 0], 4, 1);                   % Cl de chaque bande = CL
A = clmax_equilibre(84, 1, -5, 0.05, "bandes", Dc, [0.4 1.6], [-30 15], 14);
assert(abs(A.R.Cm + A.CL*0.05) < 1e-9 && min(A.R.marge) >= 0 && A.cause ~= "", 'CLmax équilibré : dernier CL équilibré et non décroché');

%% Weissinger : exemple 7.2 de Bertin (AR 5, flèche 45°, effilement 1, 8 panneaux : CLα = 3,443 /rad)
b = 1;  cw = b/5;
W = weissinger(linspace(-b/2, b/2, 9).', @(y) cw + 0*y, @(y) tand(45)*y, 0, b*cw, cw);
assert(abs(W.CLa - 3.443) < 2e-3, 'Weissinger : CLα de l''exemple 7.2 de Bertin');
W = weissinger(linspace(-b/2, b/2, 41).', @(y) cw + 0*y, @(y) 0*y, 0, b*cw, cw);
assert(abs(-W.Cma / W.CLa - 0.25) < 1e-9, 'aile droite rectangulaire : foyer au quart avant');
da = zeros(40, 1);  da(1:8) = 0.01;
Ra = W.reponse(da);  Rb = W.reponse(flipud(da));  Rc = W.a_CL(da);
assert(max(abs(Ra.Cl - flipud(Rb.Cl))) < 1e-12 && abs(Rc.CL) < 1e-12, 'symétrie et réponse à CL constant');
% Traînée induite de Trefftz : répartition elliptique, CDi → CL²/(π·λ) (200 bandes : à 0,5 % près)
W = weissinger(linspace(-b/2, b/2, 201).', @(y) cw + 0*y, @(y) 0*y, 0, b*cw, cw);
Cl = sqrt(1 - (2*W.y/b).^2) ./ W.c;
CL = sum(Cl .* W.c .* W.wy) / (b*cw);
assert(abs(W.CDi(Cl) / (CL^2 / (pi * b/cw)) - 1) < 5e-3, 'Trefftz : répartition elliptique');

%% Volet en profils minces : τ et moment de section au quart avant (maximal à 25 % de corde)
[t, m] = volet_mince([0 0.5 0.75 1]);
assert(max(abs(t - [1, 0.5 + 1/pi, 1/3 + sqrt(3)/(2*pi), 0])) < 1e-12, 'τ = 1 − θh/π + sin θh/π');
assert(abs(m(3) - (-0.5*sin(2*pi/3)*1.5*pi/180)) < 1e-15 && m(1) == 0 && abs(m(4)) < 1e-15, 'dCm/dδ');
[~, m2] = volet_mince([0.74 0.76]);
assert(all(abs(m2) < abs(m(3))), 'moment de section maximal à la charnière 0,75');

%% Polaires d'un dossier : jeu complet des profils à volet (exports réels), manquantes listées
d75 = fullfile(racine, p.xfl.dossier_pol_volet);
[P, manque] = polaires_dossier(d75, compose("S5010 elv%d", [-9 -3]), [70000 430000], p.xfl.Ncrit);
assert(isempty(manque) && P{1, 1}.Re == 70000 && P{2, 2}.Re == 430000 && P{2, 1}.profil == "S5010 elv-3", 'jeu complet');
[P, manque] = polaires_dossier(d75, "S5010 elv-3", [50000 70000], p.xfl.Ncrit);
assert(isequal(manque, "S5010 elv-3, Re 50000") && isempty(P{1}) && ~isempty(P{2}), 'polaire manquante listée');
[~, manque] = polaires_dossier(fullfile(racine, "dossier_inexistant"), "S5010", 70000, p.xfl.Ncrit);
assert(manque == "dossier absent", 'dossier absent');

%% Masses en bandes (T7) : même masse et même CG que les masses centrées, inertie de roulis accrue
bm  = budget_masse(p);
mot = constantes_moteur(p.motX.KV, "motX", p);
[~, gp] = masse_option(mot, [bm.total_3S bm.total_4S] / 1000, p);
B = budget_reaffecte(gp, p);
g = geometrie_aile(p, 27, -3.5);
M0 = masses_composants(p, g, B, gp);
M1 = masses_composants(p, g, B, gp, p.clo.n_bandes);
assert(abs(sum(M1.m) - sum(M0.m)) < 1e-12 && abs(sum(M1.m .* M1.x) - sum(M0.m .* M0.x)) < 1e-12, 'masse et moment statique conservés');
assert(abs(sum(M1.m .* M1.y)) < 1e-12 && sum(M1.m .* M1.y.^2) > sum(M0.m .* M0.y.^2), 'symétrie, Ixx accru');
assert(all(abs(M1.y) <= p.geo.b/2), 'bandes dans l''envergure');
%% Analyse de stabilité (T7) : même structure que le gabarit réel, type STABILITYPOLAR, non visqueuse
dG = fullfile(racine, 'xflr5', 'gabarits');
champs = @(s) sort(string(fieldnames(s)));
f7 = [tempname '.xml'];
ecrire_analyse_xml(f7, "T7-essai", "essai", struct('methode', "VLM2", 'rho', 1.225, 'nu', 1.46e-5, ...
    'S', 0.25, 'b', 1, 'MAC', 0.2565, 'm', 0.8, 'cg', [0.15 0 0], 'visqueux', false, 'stabilite', true));
G7 = readstruct(fullfile(dG, 'analyse_T7.xml'));  A7 = readstruct(f7);
assert(isequal(champs(G7.Polar), champs(A7.Polar)) && isequal(champs(G7.Polar.Angle_gains), champs(A7.Polar.Angle_gains)), 'structure T7');
assert(A7.Polar.Type == "STABILITYPOLAR" && A7.Polar.Viscous_Analysis == "false" && A7.Polar.Ignore_Body_Panels == "false", 'type et réglages T7');
delete(f7);
