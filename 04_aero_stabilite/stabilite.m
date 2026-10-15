%STABILITE  Phase 4 — aérodynamique et stabilité de l'aile volante V1 (xflr5).
%
%   Script principal, exécuté d'un bloc. xflr5 v6.62 est piloté par
%   l'utilisateur ; ce script prépare ses entrées et dépouille ses exports.
%     §1 Atmosphère, masses, géométrie de départ
%     §2 Profils : contrôle géométrique (épaisseur, longeron, réflexe)
%     §3 Reynolds de vol de chaque corde : plage du lot XFoil
%     §4 Masses ponctuelles et premier indicateur de centrage (estimation skill)
%     §5 Polaires 2D XFoil (étape 1) : caractéristiques des profils, V1-STAB-01
%     §6 Étape 2 : génération des avions et des analyses T2 (xflr5/genere/)
%     §7 Étape 2 : dépouillement des T2 non visqueux (point neutre, Cm0, équilibre,
%        centrage et V1-STAB-03, traînée induite et Cl local selon le vrillage)
%     §8 Section C : contrôle visqueux du Cm de l'aile, en bandes (XFoil contre ligne moyenne)
%     §9 T2 à élevons braqués : génération des avions (choix du vrillage)
%     §10 Polaires XFoil des profils à volet : efficacité visqueuse des élevons
%     §11 T2 à élevons : braquage d'équilibre δ_trim(V), critère des élevons, MOD-04 en
%         visqueux et choix du vrillage sur la traînée équilibrée (ou arrêt). Critère de
%         l'arrêt B, gardé pour la trace : remplacé le 15/10/2026 (elevons_variantes.m)
%
%   Tous les paramètres sont dans ../03_predimensionnement/params_v1.m.
%   Physique : skill /aircraft-design ; les écarts sont signalés en commentaire.
%   Sorties : figures/*.png et *.fig, resultats/tableaux_auto.md, resultats/phase4.mat

clear; close all;
racine = fileparts(mfilename('fullpath'));
rac3   = fullfile(fileparts(racine), '03_predimensionnement');
addpath(fullfile(racine, 'fonctions'), rac3, fullfile(rac3, 'fonctions'));
dFig = fullfile(racine, 'figures');
dRes = fullfile(racine, 'resultats');
if ~isfolder(dFig), mkdir(dFig); end
if ~isfolder(dRes), mkdir(dRes); end

p = params_v1();
c = p.const;

% Palette catégorielle (même ordre qu'en phase 3) et encre des textes
C = ["#2a78d6" "#eb6834" "#1baf7a" "#eda100" "#e87ba4" "#008300" "#6250d6" "#e34948"];
GRIS = "#52514e";

fprintf('\n===== PHASE 4 — AÉRODYNAMIQUE ET STABILITÉ =====\n');

%% §1 Atmosphère (ISA et jour chaud, comme en phase 3)
nA = numel(p.atm);
atm = struct('nom', {}, 'T', {}, 'rho', {});
for i = 1:nA
    [T, ~, rho] = atmosphere_isa(p.atm(i).H, p.atm(i).dT, c);
    atm(i).nom = p.atm(i).nom;  atm(i).T = T;  atm(i).rho = rho;
end

%% §1 Masses : budget réaffecté de la phase 3 (configuration F, plan d'allègement)
bm  = budget_masse(p);
mot = constantes_moteur(p.motX.KV, "motX", p);
[~, gp] = masse_option(mot, [bm.total_3S bm.total_4S] / 1000, p);
B = budget_reaffecte(gp, p);
dm_cell = 1000 * (p.batt.m_cell_fiche - p.batt.m_cell);          % g par cellule
mb = [p.masse.batt_3S + 3*dm_cell, p.masse.batt_4S + 4*dm_cell] / 1000;   % kg, cellules à 70 g (fiche)
mTot = B.sans_batt / 1000 + mb;                                  % kg, 3S1P et 4S1P
fprintf('Masses (cellules 70 g) : sans batterie %.1f g ; 3S1P %.1f g ; 4S1P %.1f g\n', ...
        B.sans_batt, 1000*mTot(1), 1000*mTot(2));

%% §1 Géométrie de départ : MAC numérique contre formule de la skill (C2 p.64)
g0 = geometrie_aile(p, p.geo4.fleche_BA, p.geo4.vrillage);
fprintf(['Géométrie de départ (flèche %.0f°, vrillage %.0f°) : S = %.4f m2 ; MAC = %.4f m ' ...
         '(skill %.4f, cahier %.3f) ; Ymac = %.4f m ; Xmac = %.4f m\n'], ...
        g0.fleche, g0.vrillage, g0.S, g0.MAC, g0.MAC_sk, p.geo.MAC, g0.Ymac, g0.Xmac);

%% §2 Profils : contrôle géométrique
nP = numel(p.xfl.profils);
pf = cell(1, nP);
for i = 1:nP
    pf{i} = lire_profil_dat(fullfile(racine, p.xfl.dossier_profils, p.xfl.profils(i) + ".dat"));
end
% Place du longeron au saumon (corde la plus faible de la demi-aile) : HYPOTHÈSE
% x_longeron = 25 % de corde ; besoin = diamètre + 2 parois
e_besoin = p.geo4.d_longeron + 2 * p.geo4.e_peau;               % m
lignesP = strings(nP, 8);
for i = 1:nP
    q = pf{i};
    e_long = q.epaisseur(p.geo4.x_longeron) * p.geo.c_ext;       % m, au saumon
    lignesP(i, :) = [q.nom, fr(100*q.t, '%.2f'), fr(100*q.xt, '%.1f'), fr(100*q.f, '%.2f'), ...
        fr(100*q.xf, '%.1f'), ternaire(q.reflexe, "oui", "non"), fr(1000*e_long, '%.1f'), ...
        fr(1000*(e_long - e_besoin), '%+.1f')];
    fprintf('%-12s t = %5.2f %% à %4.1f %% ; f = %4.2f %% à %4.1f %% ; réflexe : %s ; épaisseur au longeron (saumon) %.1f mm (marge %+.1f mm)\n', ...
        q.nom, 100*q.t, 100*q.xt, 100*q.f, 100*q.xf, ternaire(q.reflexe, "oui", "non"), ...
        1000*e_long, 1000*(e_long - e_besoin));
end

fig = figure('Visible', 'off', 'Position', [100 100 1000 420]);
ax = axes(fig); hold(ax, 'on'); grid(ax, 'on'); axis(ax, 'equal');
for i = 1:nP
    plot(ax, pf{i}.x, pf{i}.y, 'Color', C(i), 'LineWidth', 1.5, 'DisplayName', pf{i}.nom);
end
xline(ax, p.geo4.x_longeron, '--', 'longeron (hyp.)', 'Color', GRIS, 'HandleVisibility', 'off');
xline(ax, p.geo4.charniere, ':', 'charnière élevon', 'Color', GRIS, 'HandleVisibility', 'off');
xlabel(ax, 'x/c'); ylabel(ax, 'y/c'); title(ax, 'Profils réflexes comparés (UIUC)');
legend(ax, 'Location', 'southoutside', 'Orientation', 'horizontal');
sauver_figure(fig, "fig01_profils", dFig, p.sortie.dpi);

%% §3 Reynolds de vol (plage du lot XFoil)
% Vitesse de décrochage de chaque masse avec le CLmax de la phase 3 (hypothèse
% 0,8, à remplacer par la valeur xflr5) : Vs = sqrt(2·m·g/(ρ·S·CLmax)) (C1 p.18)
Vs = zeros(nA, 2);
for j = 1:nA
    Vs(j, :) = sqrt(2 * mTot * c.g ./ (atm(j).rho * p.geo.S * p.aero.CLmax));
end
cordes = [p.geo.c_emp, p.geo.c_ext, p.geo4.wl_c_tete];              % m : emplanture, saumon, tête de winglet
nomC   = ["emplanture", "saumon", "tête de winglet"];
Re_min = inf; Re_max = 0;
lignesR = strings(numel(cordes) * nA, 6);
r = 0;
for j = 1:nA
    for k = 1:numel(cordes)
        Rlo = reynolds(min(Vs(j, :)), cordes(k), atm(j).rho, atm(j).T, c);
        Rhi = reynolds(p.xfl.V_max, cordes(k), atm(j).rho, atm(j).T, c);
        R38 = reynolds(38/3.6, cordes(k), atm(j).rho, atm(j).T, c);
        R55 = reynolds(55/3.6, cordes(k), atm(j).rho, atm(j).T, c);
        r = r + 1;
        lignesR(r, :) = [atm(j).nom, nomC(k) + " (" + fr(1000*cordes(k), '%.0f') + " mm)", ...
            fr(Rlo, '%.0f'), fr(R38, '%.0f'), fr(R55, '%.0f'), fr(Rhi, '%.0f')];
        Re_min = min(Re_min, Rlo);  Re_max = max(Re_max, Rhi);
    end
end
R_MAC = [reynolds(38/3.6, p.geo.MAC, atm(1).rho, atm(1).T, c), reynolds(55/3.6, p.geo.MAC, atm(1).rho, atm(1).T, c)];
fprintf('Reynolds de la MAC (ISA) : %.0f à 38 km/h, %.0f à 55 km/h (énoncé : 170 000 et 260 000)\n', R_MAC);
fprintf('Plage de vol : Re de %.0f (Vs %.1f km/h, tête de winglet, jour chaud) à %.0f (%.0f km/h, emplanture, ISA)\n', ...
        Re_min, 3.6*min(Vs(:)), Re_max, 3.6*p.xfl.V_max);
% Lots XFoil : un pour les profils de l'aile (cordes du saumon à l'emplanture),
% un pour le profil des winglets (tête à pied). La plage de l'énoncé est
% étendue si le vol en sort, avec une marge p.xfl.Re_marge (signalé).
Re_aile_min = Inf;  Re_wl_min = Inf;  Re_wl_max = 0;
for j = 1:nA
    Re_aile_min = min(Re_aile_min, reynolds(min(Vs(j, :)), p.geo.c_ext, atm(j).rho, atm(j).T, c));
    Re_wl_min = min(Re_wl_min, reynolds(min(Vs(j, :)), p.geo4.wl_c_tete, atm(j).rho, atm(j).T, c));
    Re_wl_max = max(Re_wl_max, reynolds(p.xfl.V_max, p.geo4.wl_c_pied, atm(j).rho, atm(j).T, c));
end
% Plage régulière (saisie directe dans xflr5) : début arrondi à pas/2 sous
% Re_marge·Re_min (et sous le bas de l'énoncé), pas p.xfl.Re_pas, fin ≥ Re max
pasR = p.xfl.Re_pas;
lot = @(lo, hi) (pasR/2 * floor(lo / (pasR/2))) : pasR : (pasR/2 * floor(lo / (pasR/2)) + pasR * ceil((hi - pasR/2 * floor(lo / (pasR/2))) / pasR));
Re_lot    = lot(min(p.xfl.Re_marge * Re_aile_min, p.xfl.Re_min), max(Re_max, p.xfl.Re_max));
Re_lot_wl = lot(p.xfl.Re_marge * Re_wl_min, Re_wl_max);
fprintf('Lot XFoil des profils d''aile : Re de %.0f à %.0f (%d polaires par profil) ; énoncé : %.0f à %.0f\n', ...
        Re_lot(1), Re_lot(end), numel(Re_lot), p.xfl.Re_min, p.xfl.Re_max);
fprintf('Lot XFoil du winglet (%s) : Re de %.0f à %.0f (%d polaires)\n', ...
        p.geo4.wl_profil, Re_lot_wl(1), Re_lot_wl(end), numel(Re_lot_wl));

%% §4 Masses ponctuelles et premier indicateur de centrage
M0 = masses_composants(p, g0, B, gp);
[~, x0] = position_batterie(M0, mb(1), 0);
fprintf('CG sans batterie (positions hypothétiques) : x0 = %.1f mm du BA de l''emplanture\n', 1000*x0);
% Indicateur AVANT xflr5 : foyer de l'aile seule estimé par la skill
% (X_mac + 0,25·MAC). ÉCART : la skill ne traite ni la flèche ni les
% winglets ; xflr5 (étape 2) remplace cette valeur.
nMS = numel(p.stab.MS_vol1);
xb_ind = zeros(nMS, 2);  xCG_ind = zeros(nMS, 1);
for i = 1:nMS
    xCG_ind(i) = g0.xF_sk - p.stab.MS_vol1(i) * g0.MAC;
    xb_ind(i, :) = position_batterie(M0, mb, xCG_ind(i));
end
ecart_ind = abs(xb_ind(:, 2) - xb_ind(:, 1));
fprintf('Foyer estimé (skill) : %.1f mm\n', 1000*g0.xF_sk);
for i = 1:nMS
    fprintf('  MS %2.0f %% : CG %.1f mm ; batterie 3S1P %.1f mm, 4S1P %.1f mm ; écart %.1f mm (V1-STAB-03 : ≤ %.0f mm)\n', ...
        100*p.stab.MS_vol1(i), 1000*xCG_ind(i), 1000*xb_ind(i, 1), 1000*xb_ind(i, 2), 1000*ecart_ind(i), 2000*p.stab.plage_batt);
end

% Garde de l'hélice propulsive face au bord de fuite en flèche (décision du 13/10/2026)
GH = garde_helice(p, g0);
fprintf(['Garde hélice (flèche %.0f°) : bord de fuite à y = ±%.0f mm : %.1f mm ; sur le disque (R = %.1f mm) : %.1f mm au plus en arrière ; ' ...
         'hélice à %.1f mm → garde %.1f mm (station) et %.1f mm (disque) ; moteur à %.1f mm, %.1f mm devant le plan de l''hélice, bord de fuite de l''emplanture à %.1f mm\n'], ...
        g0.fleche, 1000*GH.y_ctrl, 1000*GH.xBF_ctrl, 1000*GH.R, 1000*GH.xBF_max, 1000*p.stab.x_helice, ...
        1000*GH.garde_ctrl, 1000*GH.garde_min, 1000*p.stab.x_moteur, 1000*(p.stab.x_helice - p.stab.x_moteur), 1000*GH.xBF_0);

% Figure : vue de dessus, masses et batteries (indicateur)
fig = figure('Visible', 'off', 'Position', [100 100 1000 560]);
ax = axes(fig); hold(ax, 'on'); grid(ax, 'on'); axis(ax, 'equal');
yb = [0 p.geo.b/2];
xBAd = g0.xBAf(yb);  xBFd = xBAd + g0.cf(yb);
ye = p.geo4.y_elevon;
xc = g0.xBAf(ye) + p.geo4.charniere * g0.cf(ye);  xf = g0.xBAf(ye) + g0.cf(ye);
for s = [1 -1]
    vis = ternaire(s == 1, 'on', 'off');
    patch(ax, 1000*s*[yb fliplr(yb)], 1000*[xBAd fliplr(xBFd)], [0.9 0.9 0.9], 'EdgeColor', GRIS, ...
          'HandleVisibility', vis, 'DisplayName', 'aile');
    patch(ax, 1000*s*[ye fliplr(ye)], 1000*[xc fliplr(xf)], [0.8 0.85 1], 'EdgeColor', C(1), ...
          'HandleVisibility', vis, 'DisplayName', 'élevons');
end
scatter(ax, 1000*M0.y, 1000*M0.x, 400*M0.m/max(M0.m) + 15, 'filled', 'MarkerFaceColor', C(2), ...
        'MarkerEdgeColor', C(2), 'DisplayName', 'masses (hyp.)');
for i = 1:nMS
    plot(ax, [0 0], 1000*xb_ind(i, :), '-', 'Color', C(2+i), 'LineWidth', 3, ...
         'DisplayName', sprintf('batterie 3S→4S, MS %.0f %% (indicateur skill)', 100*p.stab.MS_vol1(i)));
end
plot(ax, 0, 1000*g0.xF_sk, 'kp', 'MarkerSize', 12, 'MarkerFaceColor', 'k', 'DisplayName', 'foyer estimé (skill)');
set(ax, 'YDir', 'reverse');
xlabel(ax, 'y [mm]'); ylabel(ax, 'x depuis le BA de l''emplanture [mm]');
title(ax, sprintf('Vue de dessus, flèche %.0f°, positions hypothétiques (arrêt A)', g0.fleche));
legend(ax, 'Location', 'eastoutside');
sauver_figure(fig, "fig02_masses_vue_dessus", dFig, p.sortie.dpi);

%% §5 Polaires 2D XFoil (étape 1) : caractéristiques des profils, V1-STAB-01
d2  = fullfile(racine, p.xfl.dossier_pol2d);
fic = dir(fullfile(d2, '*.txt'));
assert(~isempty(fic), 'aucune polaire dans %s', d2);
pol = cell(numel(fic), 1);
for i = 1:numel(fic)
    pol{i} = lire_polaire_2d(fullfile(fic(i).folder, fic(i).name));
end
nomPol = string(cellfun(@(q) char(q.profil), pol, 'UniformOutput', false));
RePol  = cellfun(@(q) q.Re, pol);
% Contrôle des exports : jeu complet, réglages du lot
assert(all(cellfun(@(q) q.Ncrit == p.xfl.Ncrit && q.Mach == 0 && all(q.xtr == 1), pol)), ...
       'polaires : Ncrit, Mach ou transition différents du lot demandé');
nR = numel(Re_lot);
ip = zeros(nP, nR);                                  % indice de la polaire (profil, Re)
for i = 1:nP
    for r = 1:nR
        j = find(nomPol == pf{i}.nom & RePol == Re_lot(r));
        assert(isscalar(j), 'polaire manquante ou en double : %s, Re = %.0f', pf{i}.nom, Re_lot(r));
        ip(i, r) = j;
    end
end
nPts = cellfun(@(q) numel(q.alpha), pol(ip));
nPts_th = numel(p.xfl.alpha(1):p.xfl.alpha(3):p.xfl.alpha(2));
fprintf('Polaires 2D : %d fichiers, %d profils × %d Re ; points convergés : %d à %d sur %d\n', ...
        numel(fic), nP, nR, min(nPts(:)), max(nPts(:)), nPts_th);

% Points de vol associés aux Re de comparaison (énoncé) : vitesse où la MAC
% atteint ce Re (ISA), puis CL d'équilibre de la masse 4S1P (C1 p.18).
% HYPOTHÈSE : Cl du profil ≈ CL de l'aile (charge 2D = 3D), pour lire Cd et Cm.
[~, nu1] = reynolds(1, 1, atm(1).rho, atm(1).T, c);
V_cmp  = p.xfl.Re_vol * nu1 / g0.MAC;                              % m/s
CL_cmp = 2 * mTot(2) * c.g ./ (atm(1).rho * V_cmp.^2 * p.geo.S);
nV = numel(p.xfl.Re_vol);

champs = ["Cm0" "Cm0_fit" "pente" "Clmax" "LDmax" "Cl_LD" "P15max" "Cl_P15" "Cdmin" "creux_larg" "da0"];
K = struct();
for f = champs, K.(f) = zeros(nP, nR); end
K.borne = false(nP, nR);  K.n0 = zeros(nP, nR);
K.Cd_op = zeros(nP, nR, nV);  K.Cm_op = K.Cd_op;  K.a_op = K.Cd_op;
for i = 1:nP
    for r = 1:nR
        k = carac_polaire(pol{ip(i, r)}, p.xfl.creux_tol, CL_cmp, p.xfl.Cl_fit_Cm0);
        for f = champs, K.(f)(i, r) = k.(f); end
        K.borne(i, r) = k.Clmax_borne;  K.n0(i, r) = k.n0;
        K.Cd_op(i, r, :) = k.Cd_op;  K.Cm_op(i, r, :) = k.Cm_op;  K.a_op(i, r, :) = k.a_op;
    end
end
% Valeurs aux Re de comparaison : interpolation linéaire en log(Re) entre les
% deux polaires voisines du lot (260 000 tombe entre 250 000 et 270 000)
aRe = @(Y) interp1(log(Re_lot), Y.', log(p.xfl.Re_vol)).';         % nP × nV
V = struct();
for f = champs, V.(f) = aRe(K.(f)); end
V.Cd_op = zeros(nP, nV);  V.Cm_op = V.Cd_op;
for v = 1:nV
    t = aRe(K.Cd_op(:, :, v));  V.Cd_op(:, v) = t(:, v);
    t = aRe(K.Cm_op(:, :, v));  V.Cm_op(:, v) = t(:, v);
end
Cm0_min = min(K.Cm0, [], 2);
[~, rMin] = min(K.Cm0, [], 2);
okSTAB01 = all(V.Cm0 >= p.stab.Cm0_min, 2);
% Recoupement : estimation de la skill par la ligne moyenne (C2 p.69),
% Cm,c/4 = −(Y/C)·(4·X/C + 0,7). ÉCART : la formule ignore le réflexe du
% bord de fuite ; elle borne ce qu'un profil de même cambrure donnerait sans réflexe.
Cm0_sk = cellfun(@(q) -q.f * (4*q.xf + 0.7), pf(:));
% Ordre de grandeur du réflexe manquant : volet de bord de fuite fixe à la
% charnière des élevons, théorie des profils minces (HORS SKILL, signalé) :
% dCm,c/4/dδ = −½·sin θh·(1 − cos θh), cos θh = 1 − 2·x_h/c  (δ > 0 vers le bas)
[tau_v, dCm_dd] = volet_mince(p.geo4.charniere);                 % dCm_dd par degré ; τ pour le §10
d_reflexe = -min(V.Cm0, [], 2) / dCm_dd;                          % deg, < 0 = relevé
d_reflexe(okSTAB01) = 0;
fprintf('Points de comparaison (4S1P, ISA, MAC) : Re %s → V %s km/h, CL %s\n', ...
        mat2str(p.xfl.Re_vol), mat2str(round(3.6*V_cmp, 1)), mat2str(round(CL_cmp, 3)));
for i = 1:nP
    fprintf('%-14s Cm0 = %+.4f / %+.4f (Re %s) ; min du lot %+.4f à Re %.0f ; V1-STAB-01 : %s\n', ...
            pf{i}.nom, V.Cm0(i, :), mat2str(p.xfl.Re_vol), Cm0_min(i), Re_lot(rMin(i)), ...
            ternaire(okSTAB01(i), "conforme", "NON conforme (exigence de profil du cahier, remplacée par MOD-04 validée)"));
end
if any(K.borne(:)), fprintf('  Clmax au dernier alpha calculé (borne inférieure) : %d polaires\n', nnz(K.borne)); end
if any(K.n0(:) ~= 1), fprintf('  Plusieurs passages de Cl par 0 : %d polaires (dernier passage retenu)\n', nnz(K.n0 ~= 1)); end

% Figure : polaires aux Re du lot les plus proches au-dessus des Re de comparaison
rF = arrayfun(@(R) find(Re_lot >= R, 1), p.xfl.Re_vol);
fig = figure('Visible', 'off', 'Position', [100 100 1300 760]);
tl = tiledlayout(fig, nV, 3, 'TileSpacing', 'compact');
for v = 1:nV
    ax = gobjects(1, 3);
    for t = 1:3, ax(t) = nexttile(tl); hold(ax(t), 'on'); grid(ax(t), 'on'); end
    for i = 1:nP
        q = pol{ip(i, rF(v))};
        plot(ax(1), q.CD, q.CL, '.-', 'Color', C(i), 'DisplayName', pf{i}.nom);
        plot(ax(2), q.alpha, q.CL, '.-', 'Color', C(i), 'HandleVisibility', 'off');
        plot(ax(3), q.CL, q.Cm, '.-', 'Color', C(i), 'HandleVisibility', 'off');
    end
    yline(ax(1), CL_cmp(v), ':', sprintf('CL 4S1P à %.0f km/h', 3.6*V_cmp(v)), 'Color', GRIS, 'HandleVisibility', 'off');
    yline(ax(3), 0, '-', 'Color', GRIS, 'HandleVisibility', 'off');
    xline(ax(3), 0, '-', 'Color', GRIS, 'HandleVisibility', 'off');
    xlim(ax(1), [0 0.04]);
    xlabel(ax(1), 'Cd'); ylabel(ax(1), 'Cl'); xlabel(ax(2), '\alpha [°]'); ylabel(ax(2), 'Cl');
    xlabel(ax(3), 'Cl'); ylabel(ax(3), 'Cm (quart avant)');
    title(ax(1), sprintf('Re = %s', fr(Re_lot(rF(v)), '%.0f')));
    title(ax(3), 'Cm0 = Cm à Cl = 0');
    if v == 1, legend(ax(1), 'Location', 'southeast'); end
end
title(tl, sprintf('Polaires XFoil, Ncrit %.0f, transition libre', p.xfl.Ncrit));
sauver_figure(fig, "fig03_polaires_2d", dFig, p.sortie.dpi);

fig = figure('Visible', 'off', 'Position', [100 100 1300 420]);
tl = tiledlayout(fig, 1, 3, 'TileSpacing', 'compact');
Y = {K.Cm0, K.LDmax, K.Clmax};  nomY = ["Cm0", "(Cl/Cd)max", "Clmax"];
for t = 1:3
    ax = nexttile(tl); hold(ax, 'on'); grid(ax, 'on');
    xregion(ax, Re_aile_min, Re_max, 'FaceColor', [0.9 0.9 0.9], 'DisplayName', 'Re de vol de l''aile');
    for i = 1:nP
        plot(ax, Re_lot, Y{t}(i, :), '.-', 'Color', C(i), 'DisplayName', pf{i}.nom);
    end
    xline(ax, p.xfl.Re_vol, ':', 'Color', GRIS, 'HandleVisibility', 'off');
    if t == 1
        yline(ax, p.stab.Cm0_min, '-', 'V1-STAB-01', 'Color', C(8), 'HandleVisibility', 'off');
        legend(ax, 'Location', 'best');
    end
    xlabel(ax, 'Re'); ylabel(ax, nomY(t)); title(ax, nomY(t) + " selon Re");
end
sauver_figure(fig, "fig04_profils_selon_Re", dFig, p.sortie.dpi);

%% §6 Étape 2 : génération des avions et des analyses T2 (xflr5/genere/)
% Matrice décidée le 13/10/2026 : profils p.xfl.profils_3d × vrillages
% p.geo4.vrillage_matrice, flèche p.geo4.fleche_BA. Masse 4S1P (la plus lourde) ;
% batterie à la position provisoire qui donne MS = p.stab.MS_T2 avec le foyer
% estimé par la skill (X_NP et Cm(CL = 0) n'en dépendent pas).
dGen = fullfile(racine, p.xfl.dossier_genere);
if ~isfolder(dGen), mkdir(dGen); end
vrM = p.geo4.vrillage_matrice;
nG = numel(p.xfl.profils_3d) * numel(vrM);
gen = table('Size', [nG 9], 'VariableTypes', ["string" "string" "double" "string" "string" "double" "double" "double" "double"], ...
    'VariableNames', {'avion', 'profil', 'vrillage', 'xml_avion', 'xml_T2', 'm', 'x_batt', 'x_cg', 'z_cg'});
r = 0;
for i = 1:numel(p.xfl.profils_3d)
    for v = 1:numel(vrM)
        r = r + 1;
        cle = p.xfl.profils_3d(i);
        gk = geometrie_aile(p, p.geo4.fleche_BA, vrM(v));
        Mk = masses_composants(p, gk, B, gp);
        xb = position_batterie(Mk, mb(2), gk.xF_sk - p.stab.MS_T2 * gk.MAC);
        MkB = [Mk; cell2table({"Batterie 4S1P (position provisoire)", mb(2), xb, 0, 0}, ...
                              'VariableNames', Mk.Properties.VariableNames)];
        nomA = sprintf('V1_%s_vr%d', upper(cle), abs(vrM(v)));
        fA = "avion_" + nomA + ".xml";  fT = "analyse_T2_" + nomA + ".xml";
        ecrire_avion_xml(fullfile(dGen, fA), nomA, gk, cle, MkB, p);
        a = struct('methode', p.xfl.methode_T2, 'rho', atm(1).rho, 'nu', nu1, 'S', gk.S, 'b', p.geo.b, ...
                   'MAC', gk.MAC, 'm', sum(MkB.m), 'cg', [sum(MkB.m .* MkB.x), 0, sum(MkB.m .* MkB.z)] / sum(MkB.m));
        ecrire_analyse_xml(fullfile(dGen, fT), "T2-" + p.xfl.methode_T2, nomA, a);
        a.visqueux = false;                      % même analyse sans viscosité : aucun point rejeté par les polaires
        ecrire_analyse_xml(fullfile(dGen, "analyse_T2inv_" + nomA + ".xml"), "T2inv-" + p.xfl.methode_T2, nomA, a);
        gen(r, :) = {nomA, p.xfl.nom_xflr5.(cle), vrM(v), fA, fT, a.m, xb, a.cg(1), a.cg(3)};
    end
end
% Couverture des vitesses à vérifier sur les T2 : CL de 35 km/h à 70 km/h (4S1P, ISA)
V_T2  = [p.stab.V_trim(1), p.xfl.V_max];
CL_T2 = 2 * mTot(2) * c.g ./ (atm(1).rho * V_T2.^2 * p.geo.S);
fprintf('Étape 2 : %d avions générés dans %s (méthode %s, ν = %.4e m²/s, ρ = %.4f kg/m³)\n', nG, dGen, p.xfl.methode_T2, nu1, atm(1).rho);
fprintf('  masse %.1f g ; CG attendu dans xflr5 : x = %.1f mm (batterie à %.1f mm), z = %.1f mm\n', ...
        1000*gen.m(1), 1000*gen.x_cg(1), 1000*gen.x_batt(1), 1000*gen.z_cg(1));
fprintf('  CL à couvrir : %.3f (%.0f km/h) à %.3f (%.0f km/h)\n', CL_T2(2), 3.6*V_T2(2), CL_T2(1), 3.6*V_T2(1));

%% §7 Étape 2 : dépouillement des T2 non visqueux (VLM2, winglets inclinés)
% ÉCART : la VLM est hors du domaine de la skill ; elle ne dit rien du décrochage
% ni de la traînée de profil. Le Cl local est un indicateur de risque, pas une prédiction.
dT2 = fullfile(racine, p.xfl.dossier_T2);
V7  = [p.stab.V_trim(1), p.stab.V_trim_ref, p.stab.V_trim(2), p.xfl.V_max];   % m/s : 35, 45, 55, 70 km/h
CL7 = 2 * mTot(:) * c.g ./ (atm(1).rho * p.geo.S * V7.^2);                    % 2 × 4 (3S1P ; 4S1P), ISA
iRef = 2;                                         % colonne de 45 km/h
CLc = [CL7(2, :), CL7(1, end)];                   % CL relevés : 4S1P à 35/45/55/70 km/h, 3S1P à 70 km/h
lam = p.geo.b^2 / p.geo.S;                        % allongement sans les winglets
MS = p.stab.MS_vol1;  nM = numel(MS);
T7 = table('Size', [nG 9], 'VariableTypes', repmat("double", 1, 9), 'VariableNames', ...
    {'xNP_Cm', 'xNP_xcp', 'MS_ref', 'Cm0', 'ecart_Cm0', 'CLmin', 'CLmax', 'CL_wl_max', 'CLint_ecart'});
CDi7 = zeros(nG, numel(CLc));  Clb7 = CDi7;  rap7 = CDi7;  yrap7 = CDi7;  Clloc = cell(nG, 1);
CLeq = zeros(nG, nM);  Veq = zeros(nG, nM, 2);  dCm_ref = zeros(nG, nM, 2);
xCG7 = zeros(nG, nM);  xb7 = zeros(nG, nM, 2);  xb7_xcp = xb7;
corde = @(y) p.geo.c_emp + (p.geo.c_ext - p.geo.c_emp) * abs(y) / (p.geo.b/2);
for r = 1:nG
    nomA = gen.avion(r);
    P7 = lire_polaire_T2(fullfile(dT2, "T2inv_" + nomA + ".txt"));
    assert(P7.avion == nomA && P7.polaire == "T2inv-" + p.xfl.methode_T2, 'polaire inattendue : %s / %s', P7.avion, P7.polaire);
    Ca = lire_cl_local(fullfile(dT2, sprintf('Cl_%s_a%.1f.txt', nomA, p.xfl.alpha_Cl(1))));
    Cb = lire_cl_local(fullfile(dT2, sprintf('Cl_%s_a%.1f.txt', nomA, p.xfl.alpha_Cl(2))));
    gk = geometrie_aile(p, p.geo4.fleche_BA, gen.vrillage(r));
    E = exploite_T2(P7, Ca, Cb, gen.x_cg(r), gk.MAC, CLc);
    % Contrôle : CL de l'aile intégré (Σ Cl·c / S) contre CL de la polaire aux deux alpha
    ka = abs(P7.alpha - Ca.alpha) < 1e-6;  kb = abs(P7.alpha - Cb.alpha) < 1e-6;
    eI = [trapz(Ca.y_aile, Ca.Cl_aile .* corde(Ca.y_aile)) / gk.S - P7.CL(ka), ...
          trapz(Cb.y_aile, Cb.Cl_aile .* corde(Cb.y_aile)) / gk.S - P7.CL(kb)];
    T7(r, :) = {E.N.x_NP_Cm, E.N.x_NP_xcp, E.MS_ref, E.Cm0, E.ecart_Cm0, E.CL_plage(1), E.CL_plage(2), ...
                max(abs([Ca.Cl_wl; Cb.Cl_wl])), max(abs(eI))};
    CDi7(r, :) = E.CDi;  Clb7(r, :) = E.Cl_bout;  rap7(r, :) = E.rapport_max;  yrap7(r, :) = E.y_max;
    Clloc{r} = struct('y', E.y, 'Cl', E.Cl);
    % Équilibre sans braquage : Cm(CL) = Cm0 − MS·CL = 0 → CL_eq = Cm0 / MS (MOD-04, validée)
    Mk = masses_composants(p, gk, B, gp);
    for i = 1:nM
        CLeq(r, i) = E.Cm0 / MS(i);
        Veq(r, i, :) = sqrt(2 * mTot * c.g / (atm(1).rho * p.geo.S * CLeq(r, i)));
        dCm_ref(r, i, :) = MS(i) * CL7(:, iRef) - E.Cm0;   % ΔCm cabreur que les élevons doivent fournir à 45 km/h
        xCG7(r, i) = E.N.x_NP_Cm - MS(i) * gk.MAC;
        xb7(r, i, :) = position_batterie(Mk, mb, xCG7(r, i));
        xb7_xcp(r, i, :) = position_batterie(Mk, mb, E.N.x_NP_xcp - MS(i) * gk.MAC);
    end
end
ecart7 = abs(xb7(:, :, 2) - xb7(:, :, 1));              % nG × nM, V1-STAB-03
ecart7_xcp = abs(xb7_xcp(:, :, 2) - xb7_xcp(:, :, 1));
e7 = CLc.^2 ./ (pi * lam * CDi7);
assert(all(T7.CLmin <= min(CLc)) && all(T7.CLmax >= max(CL7(:))), 'T2 : plage de CL non couverte');

% Selon le vrillage, par profil : Cm0 linéaire (droite sur les 3 points), CDi quadratique
% (parabole passant par les 3 points). Vrillage qui donne δ = 0 à 45 km/h : extrapolation
% de la droite, signalée hors de la plage décidée.
nPr = numel(p.xfl.profils_3d);
vr_eq = zeros(nPr, nM, 2);  cCm0 = zeros(nPr, 2);  resCm0 = zeros(nPr, 1);  cCDi = zeros(nPr, 3);  vr_CDi = zeros(nPr, 1);
for i = 1:nPr
    k = gen.profil == p.xfl.nom_xflr5.(p.xfl.profils_3d(i));
    cCm0(i, :) = polyfit(gen.vrillage(k), T7.Cm0(k), 1);
    resCm0(i) = max(abs(T7.Cm0(k) - polyval(cCm0(i, :), gen.vrillage(k))));
    cCDi(i, :) = polyfit(gen.vrillage(k), CDi7(k, iRef), 2);
    vr_CDi(i) = -cCDi(i, 2) / (2 * cCDi(i, 1));
    for j = 1:nM
        vr_eq(i, j, :) = (MS(j) * CL7(:, iRef) - cCm0(i, 2)) / cCm0(i, 1);
    end
end
fprintf('Étape 2 (T2 non visqueux, %s) : CL à 35/45/55/70 km/h : 3S1P %s ; 4S1P %s\n', p.xfl.dossier_T2, ...
        mat2str(round(CL7(1, :), 3)), mat2str(round(CL7(2, :), 3)));
for r = 1:nG
    fprintf(['  %-13s x_NP %.1f mm (Cm) / %.1f mm (XCP·CL) ; MS au CG de l''analyse %.1f %% ; Cm0 %+.4f ; ' ...
             'CL_eq MS 8 %% %.3f (4S %.1f km/h), MS 10 %% %.3f (4S %.1f km/h) ; écart 3S/4S %.1f / %.1f mm\n'], ...
            gen.avion(r), 1000*T7.xNP_Cm(r), 1000*T7.xNP_xcp(r), 100*T7.MS_ref(r), T7.Cm0(r), ...
            CLeq(r, 1), 3.6*Veq(r, 1, 2), CLeq(r, nM), 3.6*Veq(r, nM, 2), 1000*ecart7(r, 1), 1000*ecart7(r, nM));
end
for i = 1:nPr
    fprintf('  %s : Cm0 = %+.5f %+.5f·vrillage (écart max %.1e) ; vrillage pour δ = 0 à 45 km/h (4S) : MS 8 %% %.1f°, MS 10 %% %.1f° ; min de CDi à 45 km/h : %.1f°\n', ...
            p.xfl.profils_3d(i), cCm0(i, 2), cCm0(i, 1), resCm0(i), vr_eq(i, 1, 2), vr_eq(i, nM, 2), vr_CDi(i));
end
okEcart = all(ecart7 <= 2 * p.stab.plage_batt, 'all');
fprintf('  V1-STAB-03 (écart 3S/4S ≤ %.0f mm) avec le foyer xflr5 : %s (max %.1f mm)\n', 2000*p.stab.plage_batt, ...
        ternaire(okEcart, "tenu", "NON TENU : ARRÊT, leviers à présenter"), 1000*max(ecart7(:)));
% MOD-05 (brouillon) : ± 18 mm, sans déplacement de masses. Marge = 36 mm − écart.
okEcart05 = ecart7 <= 2 * p.stab.plage_batt_MOD05;
marge05 = 2 * p.stab.plage_batt_MOD05 - ecart7;
% Encombrement (contrainte phase 5) : avant de la batterie 3S1P (cellules couchées selon x)
% face au Raspberry Pi + caméra
xPi = M0.x(M0.Nom == "Raspberry Pi Zero 2 W + Camera Module 3 + microSD");
avant3S = xb7(:, :, 1) - p.batt.L_x / 2;
fprintf('  MOD-05 (brouillon, écart ≤ %.0f mm) : %s ; marge minimale %.1f mm (XCP : %.1f mm)\n', 2000*p.stab.plage_batt_MOD05, ...
        ternaire(all(okEcart05, 'all'), "tenu par les 6", "NON TENU"), 1000*min(marge05(:)), ...
        1000*min(2*p.stab.plage_batt_MOD05 - ecart7_xcp(:)));
kS = gen.profil == p.xfl.nom_xflr5.(p.xfl.profil_retenu);
fprintf('  Batterie 3S1P à MS %.0f %% (%s) : centre %.1f à %.1f mm, avant %.1f à %.1f mm du BA ; Pi + caméra à %.1f mm\n', ...
        100*MS(nM), p.xfl.profil_retenu, 1000*min(xb7(kS, nM, 1)), 1000*max(xb7(kS, nM, 1)), ...
        1000*min(avant3S(kS, nM)), 1000*max(avant3S(kS, nM)), 1000*xPi);

% Figures de l'étape 2
coulV = @(vr) C(find(vrM == vr, 1));                  % couleur par vrillage
styP  = @(pr) ternaire(pr == p.xfl.nom_xflr5.s5010, '-', '--');
fig = figure('Visible', 'off', 'Position', [100 100 1100 460]);
tl = tiledlayout(fig, 1, 2, 'TileSpacing', 'compact');
ax = nexttile(tl); hold(ax, 'on'); grid(ax, 'on');
for r = 1:nG
    P7 = lire_polaire_T2(fullfile(dT2, "T2inv_" + gen.avion(r) + ".txt"));
    plot(ax, P7.CL, P7.Cm, styP(gen.profil(r)), 'Color', coulV(gen.vrillage(r)), 'LineWidth', 1.4, 'DisplayName', gen.avion(r));
end
xline(ax, CL7(2, 1:3), ':', compose('%.0f km/h', 3.6*V7(1:3)), 'Color', GRIS, 'HandleVisibility', 'off');
yline(ax, 0, '-', 'Color', GRIS, 'HandleVisibility', 'off');
xlabel(ax, 'CL'); ylabel(ax, sprintf('Cm au CG de l''analyse (x = %.1f mm)', 1000*gen.x_cg(1)));
title(ax, 'Cm(CL), T2 non visqueux'); legend(ax, 'Location', 'southwest');
ax = nexttile(tl); hold(ax, 'on'); grid(ax, 'on');
for r = 1:nG
    plot(ax, Clloc{r}.y, Clloc{r}.Cl(:, 1) / CLc(1), styP(gen.profil(r)), 'Color', coulV(gen.vrillage(r)), 'LineWidth', 1.4, 'DisplayName', gen.avion(r));
end
xlabel(ax, 'y [m]'); ylabel(ax, 'Cl local / CL de l''avion');
title(ax, sprintf('Répartition à %.0f km/h (4S1P, CL = %.3f), reconstruite', 3.6*V7(1), CLc(1)));
sauver_figure(fig, "fig05_T2_Cm_et_Cl_local", dFig, p.sortie.dpi);

fig = figure('Visible', 'off', 'Position', [100 100 1400 440]);
tl = tiledlayout(fig, 1, 3, 'TileSpacing', 'compact');
vrF = linspace(min(vrM) - 1, max(vrM) + 1, 50);
ax = gobjects(1, 3);
for t = 1:3, ax(t) = nexttile(tl); hold(ax(t), 'on'); grid(ax(t), 'on'); end
for t = 1:3
    xregion(ax(t), min(p.geo4.vrillage_panknin), max(p.geo4.vrillage_panknin), 'FaceColor', [0.92 0.92 0.92], ...
            'DisplayName', 'indication Panknin (hors skill)', 'HandleVisibility', ternaire(t == 1, 'on', 'off'));
end
for i = 1:nPr
    k = gen.profil == p.xfl.nom_xflr5.(p.xfl.profils_3d(i));
    st = ternaire(i == 1, '--', '-');
    plot(ax(1), gen.vrillage(k), T7.Cm0(k), 'o', 'Color', C(i), 'HandleVisibility', 'off');
    plot(ax(1), vrF, polyval(cCm0(i, :), vrF), st, 'Color', C(i), 'DisplayName', p.xfl.profils_3d(i));
    plot(ax(2), gen.vrillage(k), 1e4 * CDi7(k, iRef), 'o', 'Color', C(i), 'HandleVisibility', 'off');
    plot(ax(2), vrF, 1e4 * polyval(cCDi(i, :), vrF), st, 'Color', C(i), 'DisplayName', p.xfl.profils_3d(i));
    plot(ax(3), gen.vrillage(k), Clb7(k, 1), ['o' st], 'Color', C(i), 'DisplayName', p.xfl.profils_3d(i) + sprintf(', %.0f km/h 4S1P', 3.6*V7(1)));
    plot(ax(3), gen.vrillage(k), Clb7(k, end), ['s' st], 'Color', C(i), 'DisplayName', p.xfl.profils_3d(i) + sprintf(', %.0f km/h 3S1P', 3.6*V7(end)));
end
for j = 1:nM
    yline(ax(1), MS(j) * CL7(2, iRef), ':', sprintf('δ = 0 à 45 km/h, 4S1P, MS %.0f %%', 100*MS(j)), 'Color', GRIS, 'HandleVisibility', 'off');
end
yline(ax(1), p.stab.Cm0_aile_min, '-', 'MOD-04', 'Color', C(8), 'HandleVisibility', 'off');
yline(ax(3), 0, '-', 'Color', GRIS, 'HandleVisibility', 'off');
for t = 1:3, xlabel(ax(t), 'vrillage au saumon [°]'); end
ylabel(ax(1), 'Cm(CL = 0) de l''aile'); ylabel(ax(2), 'CDi [1e-4]'); ylabel(ax(3), 'Cl local au saumon');
title(ax(1), 'Cm0 de l''aile complète'); title(ax(2), sprintf('Traînée induite à 45 km/h (4S1P, CL %.3f)', CL7(2, iRef)));
title(ax(3), 'Cl au saumon (dernière station)');
legend(ax(1), 'Location', 'east'); legend(ax(3), 'Location', 'east');
sauver_figure(fig, "fig06_T2_selon_vrillage", dFig, p.sortie.dpi);

%% §8 Section C : contrôle visqueux du Cm, en bandes (profil retenu ; HORS SKILL)
% La VLM non visqueuse porte la ligne moyenne du profil : le moment de chaque bande y
% est celui des profils minces. XFoil (étape 1) donne le Cm visqueux à chaque (Re, Cl).
% L'écart, intégré sur l'envergure avec le Cl local reconstruit du T2, corrige le Cm de
% l'aile (couple pur, indépendant du point de référence). La redistribution de portance
% due à la viscosité est négligée. Le winglet (profil symétrique) n'est pas corrigé.
iPr = find(p.xfl.profils == p.xfl.profil_retenu);
[Cm_mince, a0_mince] = cm_profil_mince(pf{iPr});
kR = find(gen.profil == p.xfl.nom_xflr5.(p.xfl.profil_retenu)).';
nKR = numel(kR);
Vv = p.xfl.V_visc;  nVv = numel(Vv);
CLv = 2 * mTot(:) * c.g ./ (atm(1).rho * p.geo.S * Vv.^2);          % 2 × nVv (3S1P ; 4S1P), ISA
dCmV = zeros(nKR, 2, nVv);  dCmV0 = zeros(nKR, 1);
dCmReq = zeros(nKR, nM, 2, nVv);                                     % ΔCm cabreur à fournir par les élevons
for a = 1:nKR
    r = kR(a);
    P7 = lire_polaire_T2(fullfile(dT2, "T2inv_" + gen.avion(r) + ".txt"));
    Ca = lire_cl_local(fullfile(dT2, sprintf('Cl_%s_a%.1f.txt', gen.avion(r), p.xfl.alpha_Cl(1))));
    Cb = lire_cl_local(fullfile(dT2, sprintf('Cl_%s_a%.1f.txt', gen.avion(r), p.xfl.alpha_Cl(2))));
    gk = geometrie_aile(p, p.geo4.fleche_BA, gen.vrillage(r));
    cy = corde(Ca.y_aile);
    for m = 1:2
        E = exploite_T2(P7, Ca, Cb, gen.x_cg(r), gk.MAC, CLv(m, :));
        D = cm_visqueux_bandes(E.y, E.Cl, cy, cy * Vv / nu1, pol(ip(iPr, :)), Re_lot, Cm_mince, gk.S, gk.MAC);
        dCmV(a, m, :) = D.dCm;
        for i = 1:nM
            dCmReq(a, i, m, :) = MS(i) * CLv(m, :) - T7.Cm0(r) - D.dCm;
        end
    end
    % Cm(CL = 0) visqueux (critère de la MOD-04) : Cl local extrapolé linéairement à
    % CL = 0 (VLM linéaire en alpha), Re de la plus grande vitesse du contrôle
    ka = abs(P7.alpha - Ca.alpha) < 1e-6;  kb = abs(P7.alpha - Cb.alpha) < 1e-6;
    Cl0 = Ca.Cl_aile + (Cb.Cl_aile - Ca.Cl_aile) * (0 - P7.CL(ka)) / (P7.CL(kb) - P7.CL(ka));
    D0 = cm_visqueux_bandes(Ca.y_aile, Cl0, cy, cy * Vv(end) / nu1, pol(ip(iPr, :)), Re_lot, Cm_mince, gk.S, gk.MAC);
    dCmV0(a) = D0.dCm;
end
% Section C2 : xflr5 visqueux contre non visqueux sur le même avion, aux mêmes alpha. Le
% rapport à la correction en bandes (même CL, même vitesse) dit si xflr5 reprend déjà le Cm
% des polaires XFoil. Si oui, la correction en bandes compterait la viscosité deux fois : elle
% est remplacée par la droite ΔCm(CL) mesurée par xflr5.
fC2 = fullfile(dT2, "T2vis_" + p.xfl.avion_C2 + ".txt");
C2 = struct('fait', isfile(fC2), 'mode', "en attente");
if C2.fait
    rC2 = find(gen.avion == p.xfl.avion_C2);
    Pv = lire_polaire_T2(fC2);
    Pn = lire_polaire_T2(fullfile(dT2, "T2inv_" + p.xfl.avion_C2 + ".txt"));
    assert(Pv.avion == p.xfl.avion_C2 && Pv.polaire == "T2-" + p.xfl.methode_T2 && any(Pv.CDv > 0), ...
           'C2 : polaire visqueuse attendue (%s / %s)', Pv.avion, Pv.polaire);
    [C2.alpha, iv, in] = intersect(round(Pv.alpha, 3), round(Pn.alpha, 3));
    assert(numel(C2.alpha) >= 2, 'C2 : moins de 2 alpha communs');
    C2.CL = Pn.CL(in);  C2.dCL = Pv.CL(iv) - Pn.CL(in);  C2.V = Pn.QInf(in);
    C2.dCm_xflr5 = Pv.Cm(iv) - Pn.Cm(in);
    Ca = lire_cl_local(fullfile(dT2, sprintf('Cl_%s_a%.1f.txt', p.xfl.avion_C2, p.xfl.alpha_Cl(1))));
    Cb = lire_cl_local(fullfile(dT2, sprintf('Cl_%s_a%.1f.txt', p.xfl.avion_C2, p.xfl.alpha_Cl(2))));
    gk = geometrie_aile(p, p.geo4.fleche_BA, gen.vrillage(rC2));
    E = exploite_T2(Pn, Ca, Cb, gen.x_cg(rC2), gk.MAC, C2.CL);
    cy = corde(Ca.y_aile);
    D = cm_visqueux_bandes(E.y, E.Cl, cy, cy * C2.V.' / nu1, pol(ip(iPr, :)), Re_lot, Cm_mince, gk.S, gk.MAC);
    C2.dCm_bandes = D.dCm(:);
    C2.rapport = median(C2.dCm_xflr5 ./ C2.dCm_bandes);
    if C2.rapport < p.xfl.C2_seuils(1)
        C2.mode = "bandes";
    elseif C2.rapport > p.xfl.C2_seuils(2)
        C2.mode = "xflr5";
    else
        C2.mode = "ambigu";
    end
    fprintf(['Section C2 (%s, %d alpha communs, %.1f à %.1f km/h) : ΔCm xflr5 visqueux − non visqueux %s ; ' ...
             'en bandes %s ; rapport médian %.2f → %s ; ΔCL max %.4f\n'], p.xfl.avion_C2, numel(C2.alpha), ...
            3.6*min(C2.V), 3.6*max(C2.V), mat2str(round(C2.dCm_xflr5.', 4)), mat2str(round(C2.dCm_bandes.', 4)), ...
            C2.rapport, C2.mode, max(abs(C2.dCL)));
    assert(C2.mode ~= "ambigu", 'Section C2 : rapport %.2f entre les seuils %s : ARRÊT, à présenter', ...
           C2.rapport, mat2str(p.xfl.C2_seuils));
    if C2.mode == "xflr5"
        % Double comptage évité : ΔCm(CL) de xflr5 (droite sur les points communs) à la place
        % des bandes, pour les 3 vrillages (les bandes donnent le même ΔCm à ±0,0001 près)
        cX = polyfit(C2.CL, C2.dCm_xflr5, 1);
        fprintf('  correction en bandes NON appliquée ; ΔCm = %+.4f %+.4f·CL (xflr5), CL mesuré de %.3f à %.3f\n', ...
                cX(2), cX(1), min(C2.CL), max(C2.CL));
        for a = 1:nKR
            for m = 1:2
                dCmV(a, m, :) = polyval(cX, CLv(m, :));
                for i = 1:nM
                    dCmReq(a, i, m, :) = MS(i) * CLv(m, :) - T7.Cm0(kR(a)) - squeeze(dCmV(a, m, :)).';
                end
            end
            dCmV0(a) = cX(2);
        end
    end
else
    fprintf('Section C2 : %s absent : correction en bandes provisoire (double comptage non exclu)\n', fC2);
end
Cm0V = T7.Cm0(kR) + dCmV0;
% Le ΔCm visqueux varie avec CL : il déplace le point neutre. Pente de ΔCm(CL) sur la
% plage d'équilibre (35 à 55 km/h, les deux masses) : x_NP visqueux = x_NP − pente·MAC,
% puis CG, batteries et écart 3S/4S refaits avec ce point neutre.
kV = Vv >= p.stab.V_trim(1) - 1e-9 & Vv <= p.stab.V_trim(2) + 1e-9;
penteV = zeros(nKR, 1);  xNPV = penteV;  xbV = zeros(nKR, nM, 2);  ecartV = zeros(nKR, nM);
for a = 1:nKR
    r = kR(a);
    gk = geometrie_aile(p, p.geo4.fleche_BA, gen.vrillage(r));
    cV = polyfit(reshape(CLv(:, kV), [], 1), reshape(squeeze(dCmV(a, :, kV)), [], 1), 1);
    penteV(a) = cV(1);
    xNPV(a) = T7.xNP_Cm(r) - penteV(a) * gk.MAC;
    Mk = masses_composants(p, gk, B, gp);
    for i = 1:nM
        xbV(a, i, :) = position_batterie(Mk, mb, xNPV(a) - MS(i) * gk.MAC);
    end
    ecartV(a, :) = abs(xbV(a, :, 2) - xbV(a, :, 1));
end
iP3 = find(p.xfl.profils_3d == p.xfl.profil_retenu);
vrEqV = -dCmV / cCm0(iP3, 1);                                        % vrillage équivalent [deg] (négatif = plus de vrillage)
fprintf('Section C (bandes, %s) : Cm de la ligne moyenne (profils minces) %+.4f, α0 %+.2f° ; XFoil au Re et Cl locaux\n', ...
        p.xfl.profil_retenu, Cm_mince, a0_mince);
for a = 1:nKR
    r = kR(a);
    fprintf(['  %-13s ΔCm visqueux 3S1P %s / 4S1P %s (à %s km/h) ; Cm(CL = 0) %+.4f → %+.4f (MOD-04 : %s) ; ' ...
             'ΔCm élevons à 45 km/h MS 8 %% 4S1P %+.4f → %+.4f\n'], gen.avion(r), ...
            mat2str(round(squeeze(dCmV(a, 1, :)).', 4)), mat2str(round(squeeze(dCmV(a, 2, :)).', 4)), mat2str(round(3.6*Vv)), ...
            T7.Cm0(r), Cm0V(a), ternaire(Cm0V(a) >= p.stab.Cm0_aile_min, "tenue", "NON TENUE en visqueux"), ...
            dCm_ref(r, 1, 2), dCmReq(a, 1, 2, abs(Vv - p.stab.V_trim_ref) < 1e-9));
    fprintf('                pente de ΔCm(CL) %+.4f → x_NP %.1f → %.1f mm ; écart 3S/4S MS 8 / 10 %% : %.1f / %.1f mm (MOD-05 : marge %.1f mm)\n', ...
            penteV(a), 1000*T7.xNP_Cm(r), 1000*xNPV(a), 1000*ecartV(a, 1), 1000*ecartV(a, nM), ...
            1000*(2*p.stab.plage_batt_MOD05 - max(ecartV(a, :))));
end

%% §9 T2 à élevons braqués : choix du vrillage sur la traînée équilibrée (arrêt B)
% Avec les 3 T2 à δ = 0, les points [vrillage δ] de p.xfl.elevon_T2 déterminent
% exactement, pour chaque coefficient de Cm(CL) et de CDi(CL), un polynôme de degré 2
% en (vrillage, δ) : 1, vr, δ, vr², vr·δ, δ² (6 inconnues, 6 avions). Contrôles : la
% pente de Cm et le terme en CL² de CDi doivent rester à peu près constants.
% Le T2 de p.xfl.elevon_T2_controle (décidé le 13/10/2026) isole l'effet du maillage à élevons.
% Profil à volet : créé dans xflr5 (Set Flap), nommé "<profil> elv<δ>".
nomPr = p.xfl.nom_xflr5.(p.xfl.profil_retenu);
EL = [p.xfl.elevon_T2; p.xfl.elevon_T2_controle];
nE = height(EL);
genE = table('Size', [nE 7], 'VariableTypes', ["string" "double" "double" "string" "string" "string" "logical"], ...
    'VariableNames', {'avion', 'vrillage', 'delta', 'profil_elevon', 'xml_avion', 'xml_T2', 'controle'});
for e = 1:nE
    vr = EL(e, 1);  d = EL(e, 2);
    r = find(kS & gen.vrillage == vr);
    assert(isscalar(r), 'T2 à élevons : pas de T2 à δ = 0 au vrillage %g°', vr);
    gk = geometrie_aile(p, p.geo4.fleche_BA, vr);
    Mk = masses_composants(p, gk, B, gp);
    MkB = [Mk; cell2table({"Batterie 4S1P (position provisoire)", mb(2), gen.x_batt(r), 0, 0}, ...
                          'VariableNames', Mk.Properties.VariableNames)];
    cgE = [sum(MkB.m .* MkB.x), 0, sum(MkB.m .* MkB.z)] / sum(MkB.m);
    assert(abs(cgE(1) - gen.x_cg(r)) < 1e-9, 'T2 à élevons : CG différent du T2 à δ = 0');
    pe = ternaire(d == 0, nomPr, sprintf('%s elv%d', nomPr, d));
    nomA = sprintf('V1_%s_vr%d_e%d', upper(p.xfl.profil_retenu), abs(vr), abs(d));
    fA = "avion_" + nomA + ".xml";  fT = "analyse_T2inv_" + nomA + ".xml";
    ecrire_avion_xml(fullfile(dGen, fA), nomA, gk, p.xfl.profil_retenu, MkB, p, pe);
    a = struct('methode', p.xfl.methode_T2, 'rho', atm(1).rho, 'nu', nu1, 'S', gk.S, 'b', p.geo.b, ...
               'MAC', gk.MAC, 'm', sum(MkB.m), 'cg', cgE, 'visqueux', false);
    ecrire_analyse_xml(fullfile(dGen, fT), "T2inv-" + p.xfl.methode_T2, nomA, a);
    genE(e, :) = {nomA, vr, d, pe, fA, fT, e > height(p.xfl.elevon_T2)};
end
% Conditionnement du plan d'expérience (6 avions obligatoires) : matrice de Vandermonde en
% variables centrées réduites
X6 = [gen.vrillage(kS), zeros(nnz(kS), 1); p.xfl.elevon_T2];
u6 = (X6(:, 1) - mean(vrM)) / (range(vrM) / 2);  w6 = X6(:, 2) / max(abs(p.xfl.elevon_T2(:, 2)));
V6 = [ones(6, 1), u6, w6, u6.^2, u6.*w6, w6.^2];
condE = cond(V6);
% Profils à volet exportés par l'utilisateur (facultatif) : braquage mesuré sur la ligne
% moyenne derrière la charnière, contre le profil de base
dE = p.xfl.d_volet;
d_mes = NaN(size(dE));
for j = 1:numel(dE)
    fE = fullfile(racine, p.xfl.dossier_profils, sprintf('%s_elv%d.dat', p.xfl.profil_retenu, dE(j)));
    if isfile(fE)
        qE = lire_profil_dat(fE);
        dz = (qE.yu + qE.yl) / 2 - (pf{iPr}.yu + pf{iPr}.yl) / 2;
        arr = qE.xs > p.geo4.charniere + 0.05 & qE.xs < 0.98;
        cP = polyfit(qE.xs(arr) - p.geo4.charniere, dz(arr), 1);
        d_mes(j) = -atand(cP(1));
    end
end
fprintf('§9 : %d avions à élevons générés (%d + 1 contrôle), conditionnement du plan %.1f ; profils à volet mesurés : %s\n', ...
        nE, height(p.xfl.elevon_T2), condE, ternaire(all(isnan(d_mes)), "aucun export", mat2str(round(d_mes, 2))));

%% §10 Polaires XFoil des profils à volet : efficacité visqueuse des élevons
% À Cl fixé, l'écart profil braqué − profil de base donne ΔCm (quart avant), Δα et ΔCd.
% Référence : théorie des profils minces pour un volet de bord de fuite (HORS SKILL, déjà
% utilisée au §5) : ΔCm,c/4 = dCm_dd·δ et Δα = −τ·δ, τ = 1 − θh/π + sin θh/π.
% Rapport XFoil / profils minces = efficacité visqueuse du volet (η).
dPV = fullfile(racine, p.xfl.dossier_pol_volet);
ficV = dir(fullfile(dPV, '*.txt'));
polV = cell(numel(ficV), 1);
for i = 1:numel(ficV), polV{i} = lire_polaire_2d(fullfile(ficV(i).folder, ficV(i).name)); end
nomV = string(cellfun(@(q) char(q.profil), polV, 'UniformOutput', false));
ReV  = cellfun(@(q) q.Re, polV);
assert(all(cellfun(@(q) q.Ncrit == p.xfl.Ncrit && q.Mach == 0 && all(q.xtr == 1), polV)), ...
       'polaires à volet : Ncrit, Mach ou transition différents du lot');
nD = numel(p.xfl.d_volet);
ipV = zeros(nD, nR);
for j = 1:nD
    for r = 1:nR
        k = find(nomV == sprintf('%s elv%d', nomPr, p.xfl.d_volet(j)) & ReV == Re_lot(r));
        assert(isscalar(k), 'polaire à volet manquante ou en double : δ = %d°, Re = %.0f', p.xfl.d_volet(j), Re_lot(r));
        ipV(j, r) = k;
    end
end
nPtsV = cellfun(@(q) numel(q.alpha), polV(ipV));
% Le profil de base réexporté avec le lot doit retomber sur l'étape 1
dBase = 0;
for k = find(nomV == nomPr).'
    q1 = pol{ip(iPr, Re_lot == ReV(k))};
    [~, ia, ib] = intersect(polV{k}.alpha, q1.alpha);
    dBase = max([dBase; abs(polV{k}.CL(ia) - q1.CL(ib)); abs(polV{k}.Cm(ia) - q1.Cm(ib))]);
end
% Re des élevons en vol : cordes de début et de fin des élevons, 35 et 55 km/h (ISA)
ReElv = [p.stab.V_trim(1) * corde(p.geo4.y_elevon(2)), p.stab.V_trim(2) * corde(p.geo4.y_elevon(1))] / nu1;
ReT = p.xfl.Re_volet_tab;  ClT = p.xfl.Cl_volet_tab;
nRT = numel(ReT);  nCT = numel(ClT);
EV = struct('dCm', zeros(nRT, nD, nCT), 'da', zeros(nRT, nD, nCT), 'dCd', zeros(nRT, nD, nCT));
for a = 1:nRT
    rr = find(Re_lot == ReT(a));
    assert(isscalar(rr), 'Re du tableau hors du lot : %.0f', ReT(a));
    q0 = pol{ip(iPr, rr)};
    for j = 1:nD
        q = polV{ipV(j, rr)};
        EV.dCm(a, j, :) = branche(q, 'Cm', ClT) - branche(q0, 'Cm', ClT);
        EV.da(a, j, :)  = branche(q, 'alpha', ClT) - branche(q0, 'alpha', ClT);
        EV.dCd(a, j, :) = branche(q, 'CD', ClT) - branche(q0, 'CD', ClT);
    end
end
dV3 = reshape(p.xfl.d_volet, 1, nD);
EV.eta_m = EV.dCm ./ (dCm_dd * dV3);                      % ΔCm XFoil / profils minces
EV.eta_a = EV.da ./ (-tau_v * dV3);                       % Δα XFoil / profils minces
fprintf(['§10 polaires à volet : %d fichiers (%d profils à volet × %d Re), points %d à %d sur %d ; ' ...
         'profil de base contre étape 1 : écart max %.1e\n'], numel(ficV), nD, nR, min(nPtsV(:)), max(nPtsV(:)), nPts_th, dBase);
fprintf('  Re des élevons de 35 à 55 km/h : %.0f à %.0f ; profils minces : dCm/dδ %+.5f /°, τ %.3f\n', ...
        min(ReElv), max(ReElv), dCm_dd, tau_v);
fprintf('  efficacité visqueuse : η_m de %.2f à %.2f, η_α de %.2f à %.2f (Re %s, Cl %s)\n', ...
        min(EV.eta_m(:)), max(EV.eta_m(:)), min(EV.eta_a(:)), max(EV.eta_a(:)), mat2str(ReT), mat2str(ClT));

%% §11 T2 à élevons : braquage d'équilibre, critère des élevons et choix du vrillage (arrêt B, E4)
% Les exports sont reconnus par leur en-tête (index_exports_xflr5), pas par leur nom.
% 1) Modèle VLM : sur la plage de CL d'équilibre (35 à 55 km/h, 3S1P et 4S1P), chaque polaire
%    donne Cm = Cm0 + s·CL (point de référence des T2) et CDi = a0 + a1·CL + a2·CL² ; les 6
%    avions du §9 déterminent exactement un polynôme de degré 2 en (vrillage, δ) pour chacun.
% 2) Bandes : les 4 avions maillés à élevons (2 points chacun) donnent, bande par bande,
%    Cl = A·[1 CL vr δ] (VLM linéaire), et le moment de section de la VLM (colonne CmAirf).
% 3) cm_elevons : correction visqueuse en bandes (§8, étendue aux élevons avec les polaires
%    à volet du §10) et, en "complet", perte de portance du volet (η_α).
% 4) CG à x_NP − MS·MAC, x_NP tiré du même modèle à δ = 0 (visqueux, sauf en "vlm"), comme
%    les positions de batterie du §8. La marge est celle des élevons au neutre.
% ÉCARTS (HORS SKILL) : VLM, théorie des bandes, théorie des profils minces pour le volet.
assert(C2.fait && C2.mode == "bandes", '§11 : la correction en bandes suppose la section C2 tranchée en « bandes »');
IX = index_exports_xflr5(dT2);
anaE = "T2inv-" + p.xfl.methode_T2;
cherche = @(typ, nom, a) IX.fichier(IX.type == typ & IX.avion == nom & IX.analyse == anaE & ...
                                    (isnan(a) | abs(IX.alpha - a) < 1e-6));
xref = gen.x_cg(find(kS, 1));
assert(all(abs(gen.x_cg(kS) - xref) < 1e-12), '§11 : CG différents entre les T2 à δ = 0');
nVg = round(diff(p.stab.V_trim) / p.stab.pas_V_trim) + 1;
Vg  = linspace(p.stab.V_trim(1), p.stab.V_trim(2), nVg);                 % m/s
CLg = 2 * mTot(:) * c.g ./ (atm(1).rho * p.geo.S * Vg.^2);              % 2 × nVg (3S1P ; 4S1P), ISA
CLmm = [min(CLg(:)), max(CLg(:))];
gE = geometrie_aile(p, p.geo4.fleche_BA, mean(vrM));                     % S, MAC, lois en plan (sans effet du vrillage)

% 1) Polaires des 7 avions (3 à δ = 0 du §7, 3 à élevons, 1 de contrôle) sur la plage de CL
nom11 = [gen.avion(kS); genE.avion];
X11 = [gen.vrillage(kS), zeros(nnz(kS), 1); genE.vrillage, genE.delta];
ctl11 = [false(nnz(kS), 1); genE.controle];
n11 = numel(nom11);
Y11 = zeros(n11, 5);  res11 = zeros(n11, 2);  P11 = cell(n11, 1);
for i = 1:n11
    f = cherche("polaire", nom11(i), NaN);
    assert(isscalar(f), '§11 : %d polaire(s) %s pour %s', numel(f), anaE, nom11(i));
    P = lire_polaire_T2(f);
    assert(issorted(P.CL), '§11 : CL non croissant (%s)', nom11(i));
    k = find(P.CL >= CLmm(1) & P.CL <= CLmm(2));
    k = max(k(1) - 1, 1) : min(k(end) + 1, numel(P.CL));              % un point de part et d'autre
    assert(P.CL(k(1)) <= CLmm(1) && P.CL(k(end)) >= CLmm(2), '§11 : %s ne couvre pas CL %.3f à %.3f', nom11(i), CLmm);
    fCm = polyfit(P.CL(k), P.Cm(k), 1);  fCDi = polyfit(P.CL(k), P.CDi(k), 2);
    Y11(i, :) = [fCm(2), fCm(1), fCDi(3), fCDi(2), fCDi(1)];
    res11(i, :) = [max(abs(P.Cm(k) - polyval(fCm, P.CL(k)))), max(abs(P.CDi(k) - polyval(fCDi, P.CL(k))))];
    P11{i} = P;
end
i6 = find(~ctl11);
assert(numel(i6) == 6, '§11 : 6 avions attendus pour le modèle');
cE = mean(vrM);  eE = [range(vrM)/2, max(abs(p.xfl.elevon_T2(:, 2)))];   % variables réduites du §9
betaE = base_vr_d(X11(i6, 1), X11(i6, 2), cE, eE) \ Y11(i6, :);
coefE = @(vr, d) base_vr_d(vr, d, cE, eE) * betaE;                      % [Cm0 s a0 a1 a2]
cmE   = @(vr, d, CL) [1, CL, 0, 0, 0] * coefE(vr, d).';                 % Cm VLM au point de référence
CmdE  = @(vr, d, CL) cmE(vr, d + 0.5, CL) - cmE(vr, d - 0.5, CL);       % Cm_δ VLM à CL fixé [/deg]
% Contrôle du maillage : avion de contrôle contre l'avion à δ = 0 du même vrillage
iC = find(ctl11);
iC0 = find(~ctl11 & X11(:, 1) == X11(iC, 1) & X11(:, 2) == 0);
dY = Y11(iC, :) - Y11(iC0, :);
dCmMail = dY(1) + dY(2) * CLmm;                                         % aux deux bouts de la plage de CL
dEqMail = dCmMail ./ [CmdE(X11(iC, 1), 0, CLmm(1)), CmdE(X11(iC, 1), 0, CLmm(2))];
dCDiMail = dY(3) + dY(4) * CLmm + dY(5) * CLmm.^2;

% 2) Bandes : points de fonctionnement des avions maillés à élevons
iE = find(X11(:, 2) ~= 0 | ctl11);
nQ = 2 * numel(iE);
Qe = cell(nQ, 1);  Xq = zeros(nQ, 4);  eQ = zeros(nQ, 1);
for a = 1:numel(iE)
    for b = 1:2
        f = cherche("point", nom11(iE(a)), p.xfl.alpha_Cl_elv(b));
        assert(isscalar(f), '§11 : %d point(s) à α = %g° pour %s', numel(f), p.xfl.alpha_Cl_elv(b), nom11(iE(a)));
        q = 2*(a - 1) + b;
        Qe{q} = lire_point_xflr5(f);
        kq = abs(P11{iE(a)}.alpha - Qe{q}.alpha) < 1e-6;
        assert(nnz(kq) == 1, '§11 : α du point absent de la polaire (%s)', nom11(iE(a)));
        eQ(q) = abs(P11{iE(a)}.CL(kq) - Qe{q}.CL);
        Xq(q, :) = [1, Qe{q}.CL, X11(iE(a), 1), X11(iE(a), 2)];
    end
end
assert(max(eQ) < 1e-5, '§11 : CL des points différent de la polaire (%.1e)', max(eQ));
yB = Qe{1}.aile.y;  cB = Qe{1}.aile.c;  nB = numel(yB);
assert(all(cellfun(@(Q) height(Q.aile) == nB && max(abs(Q.aile.y - yB)) < 1e-6 && max(abs(Q.aile.c - cB)) < 1e-6, Qe)), ...
       '§11 : bandes différentes entre les points exportés');
eCorde = max(abs(cB - gE.cf(abs(yB))));
bB  = [-p.geo.b/2; (yB(1:end-1) + yB(2:end)) / 2; p.geo.b/2];
wyB = diff(bB);                                                         % largeur des bandes (Σ = b)
weB = min(max((abs(yB) - (p.geo4.y_elevon(1) - p.xfl.dy_elevon/2)) / p.xfl.dy_elevon, 0), 1);   % part braquée
iTr = weB > 0 & weB < 1;                                                % bandes de transition
ClQ = cell2mat(cellfun(@(Q) Q.aile.Cl.', Qe, 'UniformOutput', false));  % nQ × nB
AB  = (Xq \ ClQ).';                                                     % nB × 4
resB = max(abs(Xq * AB.' - ClQ), [], 1).';
SecQ = cellfun(@(Q) sum(Q.aile.CmAirf .* Q.aile.c.^2 .* wyB), Qe) / (gE.S * gE.MAC);
sig = Xq \ SecQ;                                                        % moment de section = [1 CL vr δ]·sig
resSec = max(abs(Xq * sig - SecQ));
Ksec_mince = dCm_dd * sum(weB .* cB.^2 .* wyB) / (gE.S * gE.MAC);
Sec0_mince = Cm_mince * sum(cB.^2 .* wyB) / (gE.S * gE.MAC);
xc4 = gE.xBAf(abs(yB)) + cB / 4;                                        % quart avant des bandes (vrillage négligé)
eCmRec = max(abs(cellfun(@(Q) sum((Q.aile.CmAirf .* Q.aile.c - Q.aile.Cl .* (xc4 - xref)) .* Q.aile.c .* wyB) ...
                  / (gE.S * gE.MAC) - Q.Cm, Qe)));
eCLint = max(abs(cellfun(@(Q) sum(Q.aile.Cl .* Q.aile.c .* wyB) / gE.S / Q.CL - 1, Qe)));

% 3) Polaires XFoil en grille (δ, Cl, Re) et données de cm_elevons
[dTab, o] = sort([p.xfl.d_volet, 0]);
polT = [polV(ipV); reshape(pol(ip(iPr, :)), 1, [])];
TV = table_polaires_volet(polT(o, :), dTab, Re_lot, p.xfl.pas_Cl_volet);
DE = struct('beta', betaE, 'centre', cE, 'echelle', eE, 'A', AB, 'y', yB, 'c', cB, 'wy', wyB, 'we', weB, ...
            'Ksec', sig(4), 'T', TV, 'Cm_mince', Cm_mince, 'dCm_dd', dCm_dd, 'tau', tau_v, ...
            'S', gE.S, 'MAC', gE.MAC, 'nu', nu1);
% Recoupement avec le §8 : correction visqueuse à δ = 0 (autres exports, autre maillage)
e8 = 0;
for a = 1:nKR
    for m = 1:2
        for iv = 1:nVv
            R = cm_elevons(0, CLv(m, iv), Vv(iv), gen.vrillage(kR(a)), "bandes", DE);
            e8 = max(e8, abs(R.dCm - dCmV(a, m, iv)));
        end
    end
end

% 4) Grille de vrillages : point neutre (δ = 0) et MOD-04 en visqueux
nVr = round(range(vrM) / p.stab.pas_vr) + 1;
vrG = linspace(max(vrM), min(vrM), nVr);
xNPv11 = zeros(1, nVr);  xNPl11 = xNPv11;  Cm0v11 = xNPv11;
for v = 1:nVr
    cm0 = zeros(2, nVg);
    for m = 1:2
        for iv = 1:nVg
            R = cm_elevons(0, CLg(m, iv), Vg(iv), vrG(v), "bandes", DE);
            cm0(m, iv) = R.Cm;
        end
    end
    fCm = polyfit(CLg(:), cm0(:), 1);
    xNPv11(v) = xref - gE.MAC * fCm(1);
    k = coefE(vrG(v), 0);
    xNPl11(v) = xref - gE.MAC * k(2);
    R = cm_elevons(0, 0, Vv(end), vrG(v), "bandes", DE);                % CL = 0, Re de la plus grande vitesse (§8)
    Cm0v11(v) = R.Cm;
end
[okG, iM11] = ismembertol(vrM, vrG, 1e-9);
assert(all(okG), '§11 : vrillages des T2 hors de la grille');
eNP8 = max(abs(xNPv11(iM11) - xNPV(:).'));
eCm08 = max(abs(Cm0v11(iM11) - Cm0V(:).'));
ok04 = Cm0v11(:) >= p.stab.Cm0_aile_min;
vr04 = NaN;                                                             % vrillage où Cm(CL = 0) visqueux = 0
if any(ok04) && any(~ok04), vr04 = interp1(Cm0v11, vrG, p.stab.Cm0_aile_min); end

% 5) δ_trim(V) : 3 modèles × vrillages × 4 configurations × vitesses
modes = ["vlm" "bandes" "complet"];  nMo = numel(modes);
iCo = find(modes == p.stab.mode_verdict);  iBa = find(modes == "bandes");  iVl = find(modes == "vlm");
cfg = [repmat((1:2).', nM, 1), repelem((1:nM).', 2)];                  % [batterie, indice de MS]
nC = height(cfg);
labC = compose("%dS1P, MS %.0f %%", 2 + cfg(:, 1), 100 * MS(cfg(:, 2)).');
dxC = @(v, ic, mo) (ternaire(mo == iVl, xNPl11(v), xNPv11(v)) - MS(cfg(ic, 2)) * gE.MAC - xref) / gE.MAC;
dT11 = NaN(nVr, nC, nVg, nMo);  hors11 = false(nVr, nC, nVg, nMo);
de11 = NaN(nVr, nC, nVg);  CD11 = NaN(nVr, nC, nVg, 2);  ext11 = false(nVr, nC, nVg);
for v = 1:nVr
    for ic = 1:nC
        m = cfg(ic, 1);
        for mo = 1:nMo
            for iv = 1:nVg
                d0 = 0;
                if mo > 1 && ~isnan(dT11(v, ic, iv, 1)), d0 = round(dT11(v, ic, iv, 1)); end
                [dT11(v, ic, iv, mo), R] = delta_equilibre(CLg(m, iv), Vg(iv), vrG(v), dxC(v, ic, mo), modes(mo), DE, d0, p.stab.d_lim);
                hors11(v, ic, iv, mo) = R.hors;
                if mo == iCo && ~isnan(dT11(v, ic, iv, mo))
                    de11(v, ic, iv) = R.de;  CD11(v, ic, iv, :) = [R.CDi, R.CDp];  ext11(v, ic, iv) = R.ext;
                end
            end
        end
    end
end
dWin = p.stab.d_trim;
dMin = reshape(min(dT11, [], 3, 'includenan'), nVr, nC, nMo);
dMax = reshape(max(dT11, [], 3, 'includenan'), nVr, nC, nMo);
okC = dMin >= dWin(1) & dMax <= dWin(2);                                % nVr × nC × nMo (NaN : non tenu)
okVr  = ok04 & all(okC(:, :, iCo), 2);                                  % critère dans les 4 configurations
okVrB = ok04 & all(okC(:, :, iBa), 2);
okVr8 = ok04 & all(okC(:, cfg(:, 2) == 1, iCo), 2);                    % MS 8 % seule (option de premier vol)
fen11 = [min(dMin(:, :, iCo), [], 2), max(dMax(:, :, iCo), [], 2)];    % fenêtre requise par vrillage
course11 = p.stab.d_reserve - dT11(:, :, 1, iCo);                       % débattement à cabrer requis à 35 km/h (P5-04)
% Réflexe fixe (option de l'arrêt) : couple pur constant ΔCm qui ramène tous les cas dans la
% fenêtre : Cm_G(δ min) + ΔCm ≥ 0 et Cm_G(δ max) + ΔCm ≤ 0 (Cm_G décroît avec δ)
dCmRfx = [-Inf(nVr, 1), Inf(nVr, 1)];
for v = 1:nVr
    for ic = 1:nC
        m = cfg(ic, 1);
        for iv = 1:nVg
            R1 = cm_elevons(dWin(1), CLg(m, iv), Vg(iv), vrG(v), p.stab.mode_verdict, DE);
            R2 = cm_elevons(dWin(2), CLg(m, iv), Vg(iv), vrG(v), p.stab.mode_verdict, DE);
            dx = dxC(v, ic, iCo);
            dCmRfx(v, :) = [max(dCmRfx(v, 1), -(R1.Cm + CLg(m, iv) * dx)), min(dCmRfx(v, 2), -(R2.Cm + CLg(m, iv) * dx))];
        end
    end
end
% Efficacité des élevons à 45 km/h, 4S1P, MS 8 % : Cm_δ de chaque modèle à l'équilibre
[okT, iT] = ismembertol(p.stab.vr_tableau, vrG, 1e-9);
assert(all(okT), '§11 : vrillages des tableaux hors de la grille');
ic48 = find(cfg(:, 1) == 2 & cfg(:, 2) == 1);
iv45 = find(abs(Vg - p.stab.V_trim_ref) < 1e-9);
effT = NaN(numel(iT), nMo + 2);
for t = 1:numel(iT)
    v = iT(t);
    for mo = 1:nMo
        dg = dT11(v, ic48, iv45, mo);
        if isnan(dg), continue; end
        Rp = cm_elevons(dg + 0.5, CLg(2, iv45), Vg(iv45), vrG(v), modes(mo), DE);
        Rm = cm_elevons(dg - 0.5, CLg(2, iv45), Vg(iv45), vrG(v), modes(mo), DE);
        effT(t, mo) = Rp.Cm - Rm.Cm;
        if mo == iCo
            R = cm_elevons(dg, CLg(2, iv45), Vg(iv45), vrG(v), modes(mo), DE);
            effT(t, nMo + (1:2)) = [R.eta_a, R.eta_m];
        end
    end
end

% 6) Traînée équilibrée (modèle du verdict) : induite (VLM, winglets compris) + profil de l'aile
% (bandes ; winglets et nacelle exclus, communs à tous les vrillages au premier ordre)
[okV, iVc] = ismembertol(p.stab.V_choix_vr, Vg, 1e-9);
assert(all(okV), '§11 : vitesses du choix hors de la grille');
nS = numel(iVc);
Dr = zeros(nVr, nC, nS);
for s = 1:nS
    Dr(:, :, s) = 0.5 * atm(1).rho * Vg(iVc(s))^2 * p.geo.S * sum(CD11(:, :, iVc(s), :), 4);
end
Dr2 = reshape(Dr, nVr, []);                                              % colonnes : configuration, puis vitesse
Dmoy = mean(Dr2, 2);
[~, iOptCas] = min(Dr2, [], 1);                                         % optimum de chaque cas, sans contrainte
[~, iOptLibre] = min(Dmoy);
iOpt = [];  bordOpt = false;
if any(okVr)
    Dok = Dmoy;  Dok(~okVr) = Inf;
    [~, iOpt] = min(Dok);
    bordOpt = iOpt == 1 || iOpt == nVr;
end
arret11 = isempty(iOpt);

fprintf(['§11 T2 à élevons (%s) : %d polaires et %d points reconnus par l''en-tête ; CL d''équilibre %.3f à %.3f\n' ...
         '  ajustements par avion sur cette plage : résidus Cm %.1e, CDi %.1e ; pente dCm/dCL de %.4f à %.4f (x_NP sur %.2f mm)\n'], ...
        p.xfl.dossier_T2, n11, nQ, CLmm, max(res11(:, 1)), max(res11(:, 2)), min(Y11(:, 2)), max(Y11(:, 2)), 1000*range(Y11(:, 2))*gE.MAC);
fprintf('  maillage à élevons (%s − %s) : ΔCm %s, soit δ équivalent %s° ; Δx_NP %.3f mm ; ΔCDi %s\n', nom11(iC), nom11(iC0), ...
        mat2str(dCmMail, 2), mat2str(dEqMail, 2), -1000*dY(2)*gE.MAC, mat2str(dCDiMail, 2));
fprintf(['  bandes (%d) : Cl = A·[1 CL vr δ], résidu %.4f (transition, %.0f mm) et %.4f ailleurs ; cordes à %.1e m de la loi en plan\n' ...
         '  moment de section VLM : %+.5f par degré de δ (profils minces : %+.5f) ; recomposition du Cm %.1e ; CL des bandes à %.1f %%\n' ...
         '  recoupement §8 à δ = 0 : ΔCm visqueux à %.1e ; x_NP visqueux à %.2f mm ; Cm(CL = 0) visqueux à %.1e\n'], ...
        nB, max(resB(iTr)), 1000*p.xfl.dy_elevon, max(resB(~iTr)), eCorde, sig(4), Ksec_mince, eCmRec, 100*eCLint, e8, 1000*eNP8, eCm08);
fprintf('  MOD-04 en visqueux (Cm(CL = 0) ≥ %g) : tenue de %.2f° à %.2f° ; limite %s\n', p.stab.Cm0_aile_min, ...
        max(vrG(ok04)), min(vrG(ok04)), ternaire(isnan(vr04), "hors de la grille", sprintf('%.2f°', vr04)));
fprintf('  δ_trim de %.0f à %.0f km/h [°] (min / max ; fenêtre %+.0f à %+.0f°), modèle %s (bandes) [VLM] :\n', ...
        3.6*Vg(1), 3.6*Vg(end), dWin, p.stab.mode_verdict);
for t = 1:numel(iT)
    v = iT(t);
    lig = compose('%s %+.1f / %+.1f (%+.1f / %+.1f) [%+.1f / %+.1f]', labC, dMin(v, :, iCo).', dMax(v, :, iCo).', ...
                  dMin(v, :, iBa).', dMax(v, :, iBa).', dMin(v, :, iVl).', dMax(v, :, iVl).');
    fprintf('    vrillage %+.0f° : %s\n', vrG(v), strjoin(lig, ' ; '));
end
if arret11
    fprintf(['  ARRÊT (règle de l''arrêt B) : aucun vrillage ne tient la fenêtre dans les 4 configurations (%s) ; ' ...
             'en « bandes » : %d vrillage(s) ; MS 8 %% seule : %d vrillage(s)\n' ...
             '  amplitude de δ_trim de %.0f à %.0f km/h dans une configuration : %.1f à %.1f° (fenêtre : %.0f°) ; ' ...
             'réflexe fixe (couple constant) possible pour %d vrillage(s)\n'], p.stab.mode_verdict, nnz(okVrB), nnz(okVr8), ...
            3.6*Vg(1), 3.6*Vg(end), min(dMax(:, :, iCo) - dMin(:, :, iCo), [], 'all'), max(dMax(:, :, iCo) - dMin(:, :, iCo), [], 'all'), ...
            diff(dWin), nnz(dCmRfx(:, 1) <= dCmRfx(:, 2)));
else
    fprintf('  vrillage retenu par la règle : %.2f° (traînée moyenne %.3f N)%s\n', vrG(iOpt), Dmoy(iOpt), ...
            ternaire(bordOpt, " — EN BORD DE PLAGE", ""));
end
fprintf(['  traînée équilibrée moyenne des %d cas : minimum %.3f N à %.2f° (sans contrainte) ; δ_trim hors des polaires à volet ' ...
         '(%+.0f à %+.0f°, prolongement linéaire) : %d points sur %d\n'], nC*nS, Dmoy(iOptLibre), vrG(iOptLibre), ...
        min(p.xfl.d_volet), 0, nnz(ext11), numel(ext11));

fig = figure('Visible', 'off', 'Position', [100 100 1400 520]);
tl = tiledlayout(fig, 1, 2, 'TileSpacing', 'compact');
ax = nexttile(tl); hold(ax, 'on'); grid(ax, 'on');
yregion(ax, dWin(1), dWin(2), 'FaceColor', [0.92 0.92 0.92], 'DisplayName', 'fenêtre du critère');
vrF = [max(vrM) cE min(vrM)];  styF = ["-" "--" ":"];
for t = 1:numel(vrF)
    v = abs(vrG - vrF(t)) < 1e-9;
    for ic = 1:nC
        plot(ax, 3.6*Vg, squeeze(dT11(v, ic, :, iCo)), styF(t), 'Color', C(ic), 'LineWidth', 1.4, ...
             'DisplayName', labC(ic) + sprintf(', vrillage %.0f°', vrF(t)));
    end
end
xlabel(ax, 'V [km/h] (ISA)'); ylabel(ax, 'δ_{trim} [°] (< 0 : bord de fuite vers le haut)');
title(ax, sprintf('Braquage d''équilibre, modèle « %s »', p.stab.mode_verdict));
legend(ax, 'Location', 'southoutside', 'NumColumns', 3);
ax = nexttile(tl); hold(ax, 'on'); grid(ax, 'on');
yregion(ax, dWin(1), dWin(2), 'FaceColor', [0.92 0.92 0.92], 'DisplayName', 'fenêtre du critère');
if any(~ok04)
    xregion(ax, min(vrG(~ok04)), max(vrG(~ok04)), 'FaceColor', [0.98 0.86 0.86], 'DisplayName', 'MOD-04 non tenue (visqueux)');
end
for ic = 1:nC
    plot(ax, vrG, dT11(:, ic, 1, iCo), '-', 'Color', C(ic), 'LineWidth', 1.4, 'DisplayName', labC(ic) + sprintf(', %.0f km/h', 3.6*Vg(1)));
    plot(ax, vrG, dT11(:, ic, end, iCo), '--', 'Color', C(ic), 'LineWidth', 1.4, 'DisplayName', labC(ic) + sprintf(', %.0f km/h', 3.6*Vg(end)));
end
xlabel(ax, 'vrillage au saumon [°]'); ylabel(ax, 'δ_{trim} [°]');
title(ax, 'Bouts de la plage de vitesse selon le vrillage');
legend(ax, 'Location', 'southoutside', 'NumColumns', 2);
sauver_figure(fig, "fig07_elevons_delta_trim", dFig, p.sortie.dpi);

fig = figure('Visible', 'off', 'Position', [100 100 1400 520]);
tl = tiledlayout(fig, 1, 2, 'TileSpacing', 'compact');
ax = nexttile(tl); hold(ax, 'on'); grid(ax, 'on');
if any(~ok04)
    xregion(ax, min(vrG(~ok04)), max(vrG(~ok04)), 'FaceColor', [0.98 0.86 0.86], 'DisplayName', 'MOD-04 non tenue (visqueux)');
end
plot(ax, vrG, Dmoy, '-', 'Color', C(1), 'LineWidth', 1.6, 'DisplayName', sprintf('moyenne des %d cas', nC*nS));
if any(okVr)
    plot(ax, vrG(okVr), Dmoy(okVr), 'o', 'Color', C(3), 'DisplayName', 'critère des élevons tenu (4 configurations)');
end
xlabel(ax, 'vrillage au saumon [°]'); ylabel(ax, 'traînée de l''aile équilibrée [N]');
title(ax, sprintf('Induite (VLM) + profil de l''aile (bandes), %s km/h', strjoin(compose('%.0f', 3.6*Vg(iVc)), ' et ')));
legend(ax, 'Location', 'best');
ax = nexttile(tl); hold(ax, 'on'); grid(ax, 'on');
styS = ["-" "--"];
for s = 1:nS
    for ic = 1:nC
        j = ic + nC*(s - 1);
        plot(ax, vrG, Dr2(:, j), styS(s), 'Color', C(ic), 'LineWidth', 1.2, 'DisplayName', labC(ic) + sprintf(', %.0f km/h', 3.6*Vg(iVc(s))));
        plot(ax, vrG(iOptCas(j)), Dr2(iOptCas(j), j), 'x', 'Color', C(ic), 'MarkerSize', 9, 'HandleVisibility', 'off');
    end
end
xlabel(ax, 'vrillage au saumon [°]'); ylabel(ax, 'traînée de l''aile équilibrée [N]');
title(ax, 'Chaque cas (× : minimum du cas)');
legend(ax, 'Location', 'southoutside', 'NumColumns', 2);
sauver_figure(fig, "fig08_elevons_trainee_equilibree", dFig, p.sortie.dpi);

%% Écriture des tableaux
fid = fopen(fullfile(dRes, 'tableaux_auto.md'), 'w', 'n', 'UTF-8');
fprintf(fid, '# Phase 4 — tableaux générés par stabilite.m\n\nNe pas éditer : réécrit à chaque exécution.\n');
tableau_md(fid, "Géométrie de départ", ["Grandeur", "Valeur"], [ ...
    "Flèche du BA / vrillage au saumon", fr(g0.fleche, '%.0f') + "° / " + fr(g0.vrillage, '%.0f') + "°";
    "S (intégrale)", fr(g0.S, '%.4f') + " m²";
    "MAC (intégrale) / formule skill C2 p.64 / cahier", fr(g0.MAC, '%.4f') + " / " + fr(g0.MAC_sk, '%.4f') + " / " + fr(p.geo.MAC, '%.3f') + " m";
    "Y_mac / X_mac (BA de la MAC)", fr(1000*g0.Ymac, '%.1f') + " / " + fr(1000*g0.Xmac, '%.1f') + " mm";
    "Foyer de l'aile seule, estimation skill (X_mac + 0,25·MAC)", fr(1000*g0.xF_sk, '%.1f') + " mm"]);
tableau_md(fid, "Profils : géométrie (cordes en % ; longeron au saumon, hypothèse x/c = " + fr(p.geo4.x_longeron, '%.2f') + ", besoin " + fr(1000*e_besoin, '%.1f') + " mm)", ...
    ["Profil", "t max [%]", "à x/c [%]", "Cambrure max [%]", "à x/c [%]", "Réflexe", "Épaisseur au longeron [mm]", "Marge [mm]"], lignesP);
tableau_md(fid, "Reynolds de vol (Vs avec CLmax = " + fr(p.aero.CLmax, '%.1f') + ", hypothèse de la phase 3)", ...
    ["Atmosphère", "Corde", "Re à Vs min", "Re à 38 km/h", "Re à 55 km/h", "Re à " + fr(3.6*p.xfl.V_max, '%.0f') + " km/h"], lignesR);
tableau_md(fid, "Lots XFoil", ["Grandeur", "Valeur"], [ ...
    "Re min de vol : aile (saumon) / winglet (tête)", fr(Re_aile_min, '%.0f') + " / " + fr(Re_min, '%.0f');
    "Re max de vol : aile (emplanture) / winglet (pied)", fr(Re_max, '%.0f') + " / " + fr(Re_wl_max, '%.0f');
    "Lot des profils d'aile", strjoin(fr(Re_lot, '%.0f'), " ; ");
    "Lot du winglet (" + p.geo4.wl_profil + ")", strjoin(fr(Re_lot_wl, '%.0f'), " ; ");
    "Énoncé", fr(p.xfl.Re_min, '%.0f') + " à " + fr(p.xfl.Re_max, '%.0f') + ", Ncrit = " + fr(p.xfl.Ncrit, '%.0f')]);
lignesM = [M0.Nom, fr(1000*M0.m, '%.1f'), fr(1000*M0.x, '%.1f'), fr(1000*M0.y, '%.0f'), fr(1000*M0.z, '%.0f')];
tableau_md(fid, "Masses ponctuelles sans batterie (positions HYPOTHÉTIQUES, arrêt A)", ...
    ["Poste", "m [g]", "x [mm]", "y [mm]", "z [mm]"], [lignesM; "**Total / CG**", fr(1000*sum(M0.m), '%.1f'), fr(1000*x0, '%.1f'), "", ""]);
lignesI = strings(nMS, 5);
for i = 1:nMS
    lignesI(i, :) = [fr(100*p.stab.MS_vol1(i), '%.0f') + " %", fr(1000*xCG_ind(i), '%.1f'), ...
        fr(1000*xb_ind(i, 1), '%.1f'), fr(1000*xb_ind(i, 2), '%.1f'), fr(1000*ecart_ind(i), '%.1f')];
end
tableau_md(fid, "Indicateur de centrage AVANT xflr5 (foyer de l'aile seule à X_mac + 0,25·MAC, skill ; ni winglets ni nacelle)", ...
    ["MS", "CG [mm]", "Batterie 3S1P [mm]", "Batterie 4S1P [mm]", "Écart 3S/4S [mm]"], lignesI);
tableau_md(fid, "Garde de l'hélice face au bord de fuite (flèche " + fr(g0.fleche, '%.0f') + "°, hypothèses de position ; élevons non braqués, moyeu non compté)", ...
    ["Grandeur", "Valeur"], [ ...
    "Bord de fuite à y = ±" + fr(1000*GH.y_ctrl, '%.0f') + " mm", fr(1000*GH.xBF_ctrl, '%.1f') + " mm";
    "Plan de l'hélice (CG hélice + adaptateur) : garde à cette station", fr(1000*p.stab.x_helice, '%.1f') + " mm : " + fr(1000*GH.garde_ctrl, '%.1f') + " mm";
    "Bord de fuite le plus en arrière sur le disque (R = " + fr(1000*GH.R, '%.1f') + " mm) : garde", fr(1000*GH.xBF_max, '%.1f') + " mm : " + fr(1000*GH.garde_min, '%.1f') + " mm";
    "Moteur (CG) : distance au bord de fuite de l'emplanture", fr(1000*p.stab.x_moteur, '%.1f') + " mm : " + fr(1000*GH.gap_moteur_0, '%.1f') + " mm"]);
tableau_md(fid, "Étape 2 : avions générés pour les T2 (" + p.xfl.dossier_genere + ", méthode " + p.xfl.methode_T2 + ", masse 4S1P, batterie provisoire à MS " + fr(100*p.stab.MS_T2, '%.0f') + " % sur le foyer skill)", ...
    ["Avion", "Profil (nom xflr5)", "Vrillage au saumon [°]", "Masse [g]", "Batterie x [mm]", "CG attendu x / z [mm]", "Fichiers"], ...
    [gen.avion, gen.profil, fr(gen.vrillage, '%.0f'), fr(1000*gen.m, '%.1f'), fr(1000*gen.x_batt, '%.1f'), ...
     fr(1000*gen.x_cg, '%.1f') + " / " + fr(1000*gen.z_cg, '%.1f'), gen.xml_avion + " ; " + gen.xml_T2]);
tableau_md(fid, "Étape 2 : réglages des T2", ["Grandeur", "Valeur"], [ ...
    "ρ / ν (ISA, Sutherland)", fr(atm(1).rho, '%.4f') + " kg/m³ / " + fr(nu1, '%.4e') + " m²/s";
    "Plage d'alpha à saisir dans xflr5", fr(p.xfl.T2_alpha(1), '%.1f') + "° à " + fr(p.xfl.T2_alpha(2), '%.1f') + "°, pas " + fr(p.xfl.T2_alpha(3), '%.1f') + "°";
    "CL à couvrir (4S1P, ISA)", fr(CL_T2(2), '%.3f') + " (" + fr(3.6*V_T2(2), '%.0f') + " km/h) à " + fr(CL_T2(1), '%.3f') + " (" + fr(3.6*V_T2(1), '%.0f') + " km/h)"]);
tableau_md(fid, "Polaires 2D : contrôle des exports", ["Grandeur", "Valeur"], [ ...
    "Fichiers lus / attendus", fr(numel(fic), '%d') + " / " + fr(nP*nR, '%d');
    "Ncrit / Mach / transition forcée", fr(p.xfl.Ncrit, '%.0f') + " / 0 / x/c = 1 (libre) : vérifiés dans chaque fichier";
    "Points convergés par polaire (min / max / demandés)", fr(min(nPts(:)), '%d') + " / " + fr(max(nPts(:)), '%d') + " / " + fr(nPts_th, '%d');
    "Clmax au dernier alpha calculé (valeur = borne inférieure)", fr(nnz(K.borne), '%d') + " polaires";
    "Polaires à plusieurs passages de Cl par 0", fr(nnz(K.n0 ~= 1), '%d');
    "Plus grand écart d'alpha autour de Cl = 0", fr(max(K.da0(:)), '%.1f') + "° (pas demandé " + fr(p.xfl.alpha(3), '%.1f') + "°)"]);
hRe = "Re " + fr(p.xfl.Re_vol, '%.0f');
lignesA = strings(nP, 10);
for i = 1:nP
    lignesA(i, :) = [pf{i}.nom, fr(V.Cm0(i, 1), '%+.4f'), fr(V.Cm0(i, 2), '%+.4f'), ...
        fr(Cm0_min(i), '%+.4f') + " (Re " + fr(Re_lot(rMin(i)), '%.0f') + ")", ...
        fr(V.Cm0_fit(i, 1), '%+.4f') + " / " + fr(V.Cm0_fit(i, 2), '%+.4f'), ...
        fr(0.25 - V.pente(i, 1), '%.3f') + " / " + fr(0.25 - V.pente(i, 2), '%.3f'), ...
        fr(Cm0_sk(i), '%+.4f'), fr(d_reflexe(i), '%+.1f') + "°", ...
        fr(V.Cm_op(i, 1), '%+.4f') + " / " + fr(V.Cm_op(i, 2), '%+.4f'), ...
        ternaire(okSTAB01(i), "conforme", "NON conforme (exigence de profil du cahier, remplacée par MOD-04 validée)")];
end
tableau_md(fid, "V1-STAB-01 : Cm0 du profil (Cm au quart avant à Cl = 0, XFoil ; interpolé en log Re)", ...
    ["Profil", "Cm0 à " + hRe(1), "Cm0 à " + hRe(2), "Cm0 minimal sur le lot (70 000 à 430 000)", ...
     "Contrôle : droite Cm(Cl) sur Cl " + fr(p.xfl.Cl_fit_Cm0(1), '%.1f') + "–" + fr(p.xfl.Cl_fit_Cm0(2), '%.1f') + " extrapolée à Cl = 0 (" + hRe(1) + " / " + hRe(2) + ")", ...
     "x_ac/c (" + hRe(1) + " / " + hRe(2) + ")", "Skill C2 p.69, sans réflexe", ...
     "Volet fixe pour Cm0 = 0 (profil mince, charnière " + fr(100*p.geo4.charniere, '%.0f') + " %, HORS SKILL)", ...
     "Cm au Cl de vol 4S1P (" + hRe(1) + " : Cl " + fr(CL_cmp(1), '%.3f') + " / " + hRe(2) + " : Cl " + fr(CL_cmp(2), '%.3f') + ")", ...
     "V1-STAB-01 du cahier (Cm0 du profil ≥ 0 aux Re de vol)"], lignesA);
for v = 1:nV
    lignesB = strings(nP, 7);
    for i = 1:nP
        lignesB(i, :) = [pf{i}.nom, fr(V.Clmax(i, v), '%.3f'), ...
            fr(V.LDmax(i, v), '%.1f') + " (Cl " + fr(V.Cl_LD(i, v), '%.2f') + ")", ...
            fr(V.P15max(i, v), '%.1f') + " (Cl " + fr(V.Cl_P15(i, v), '%.2f') + ")", ...
            fr(1e4*V.Cdmin(i, v), '%.1f'), fr(V.creux_larg(i, v), '%.3f'), ...
            fr(1e4*V.Cd_op(i, v), '%.1f') + " / " + fr(V.Cm_op(i, v), '%+.4f')];
    end
    tableau_md(fid, "Performances du profil à " + hRe(v) + " (≈ " + fr(3.6*V_cmp(v), '%.1f') + " km/h sur la MAC, ISA ; Cl de vol 4S1P = " + fr(CL_cmp(v), '%.3f') + ")", ...
        ["Profil", "Clmax", "(Cl/Cd)max", "(Cl^1,5/Cd)max", "Cd min [1e-4]", "Largeur du creux ΔCl (Cd ≤ " + fr(1 + p.xfl.creux_tol, '%.2f') + "·Cd min)", "Cd [1e-4] / Cm au Cl de vol"], lignesB);
end
tableau_md(fid, "Étape 2 : T2 non visqueux (" + p.xfl.methode_T2 + ", winglets inclinés du vrillage du saumon) : contrôles et point neutre (estimation skill : " + fr(1000*g0.xF_sk, '%.1f') + " mm)", ...
    ["Avion", "x_NP pente de Cm [mm]", "x_NP pente de XCP·CL [mm]", "MS au CG de l'analyse (" + fr(1000*gen.x_cg(1), '%.1f') + " mm)", ...
     "Cm(CL = 0) de l'aile", "Écart max à la droite Cm(CL)", "CL couvert", "|Cl| max des winglets", "CL intégré de l'aile − CL polaire (max)"], ...
    [gen.avion, fr(1000*T7.xNP_Cm, '%.1f'), fr(1000*T7.xNP_xcp, '%.1f'), fr(100*T7.MS_ref, '%.1f') + " %", fr(T7.Cm0, '%+.4f'), ...
     fr(T7.ecart_Cm0, '%.1e'), fr(T7.CLmin, '%.3f') + " à " + fr(T7.CLmax, '%.3f'), fr(T7.CL_wl_max, '%.2f'), fr(T7.CLint_ecart, '%.3f')]);
lignesE = strings(nG, 1 + 2*nM);
for r = 1:nG
    lignesE(r, 1) = gen.avion(r);
    for i = 1:nM
        lignesE(r, 1 + i) = fr(CLeq(r, i), '%.3f') + " : " + fr(3.6*Veq(r, i, 1), '%.1f') + " / " + fr(3.6*Veq(r, i, 2), '%.1f') + " km/h";
        lignesE(r, 1 + nM + i) = fr(dCm_ref(r, i, 1), '%+.4f') + " / " + fr(dCm_ref(r, i, 2), '%+.4f');
    end
end
tableau_md(fid, "Étape 2 : équilibre sans braquage d'élevons (Cm0 − MS·CL = 0, ISA) et ΔCm cabreur à fournir par les élevons à 45 km/h", ...
    ["Avion", "CL_eq : V_eq 3S1P / 4S1P, MS " + fr(100*MS, '%.0f') + " %", "ΔCm à 45 km/h 3S1P / 4S1P, MS " + fr(100*MS, '%.0f') + " %"], lignesE);
lignesC = strings(nG * nM, 9);
for r = 1:nG
    for i = 1:nM
        lignesC((r-1)*nM + i, :) = [gen.avion(r), fr(100*MS(i), '%.0f') + " %", fr(1000*xCG7(r, i), '%.1f'), ...
            fr(1000*xb7(r, i, 1), '%.1f') + " (avant : " + fr(1000*avant3S(r, i), '%.1f') + ")", fr(1000*xb7(r, i, 2), '%.1f'), ...
            fr(1000*ecart7(r, i), '%.1f') + " (XCP : " + fr(1000*ecart7_xcp(r, i), '%.1f') + ")", ...
            ternaire(ecart7(r, i) <= 2*p.stab.plage_batt, "tenu", "**NON TENU**"), ...
            ternaire(okEcart05(r, i), "tenu", "**NON TENU**"), fr(1000*marge05(r, i), '%.1f')];
    end
end
tableau_md(fid, "Étape 2 : centrage avec le foyer xflr5 (pente de Cm) ; V1-STAB-03 : écart 3S/4S ≤ " + fr(2000*p.stab.plage_batt, '%.0f') + ...
    " mm (cahier), ≤ " + fr(2000*p.stab.plage_batt_MOD05, '%.0f') + " mm (MOD-05, brouillon) ; Pi + caméra à " + fr(1000*xPi, '%.0f') + " mm", ...
    ["Avion", "MS", "CG [mm]", "Batterie 3S1P [mm] (avant, " + fr(1000*p.batt.L_x, '%.0f') + " mm de long)", "Batterie 4S1P [mm]", ...
     "Écart 3S/4S [mm]", "V1-STAB-03 (cahier)", "MOD-05 (brouillon)", "Marge MOD-05 [mm]"], lignesC);
lignesD = strings(nG, 6);
for r = 1:nG
    lignesD(r, :) = [gen.avion(r), strjoin(fr(1e4*CDi7(r, 1:3), '%.1f'), " / "), strjoin(fr(e7(r, 1:3), '%.2f'), " / "), ...
        strjoin(fr(Clb7(r, :), '%+.3f'), " / "), fr(rap7(r, 1), '%.2f') + " à |y| = " + fr(1000*yrap7(r, 1), '%.0f') + " mm", ...
        fr(rap7(r, end), '%.2f') + " à |y| = " + fr(1000*yrap7(r, end), '%.0f') + " mm"];
end
tableau_md(fid, "Étape 2 : traînée induite et Cl local (reconstruit entre α = " + fr(p.xfl.alpha_Cl(1), '%.0f') + "° et " + fr(p.xfl.alpha_Cl(2), '%.0f') + "° ; indicateur, pas une prédiction de décrochage)", ...
    ["Avion", "CDi [1e-4] à 35 / 45 / 55 km/h (4S1P)", "e = CL²/(π·λ·CDi), λ = " + fr(lam, '%.0f'), ...
     "Cl au saumon : 35 / 45 / 55 / 70 km/h 4S1P, 70 km/h 3S1P", "max Cl/CL à 35 km/h (4S1P)", "max Cl/CL à 70 km/h (3S1P)"], lignesD);
lignesV = strings(nPr, 5);
for i = 1:nPr
    lignesV(i, :) = [p.xfl.profils_3d(i), fr(cCm0(i, 2), '%+.5f') + " " + fr(cCm0(i, 1), '%+.5f') + "·vr (écart " + fr(resCm0(i), '%.1e') + ")", ...
        fr(vr_eq(i, 1, 1), '%.1f') + "° / " + fr(vr_eq(i, 1, 2), '%.1f') + "°", fr(vr_eq(i, nM, 1), '%.1f') + "° / " + fr(vr_eq(i, nM, 2), '%.1f') + "°", ...
        fr(vr_CDi(i), '%.1f') + "°"];
end
tableau_md(fid, "Étape 2 : selon le vrillage (droite de Cm0 sur 3 points ; parabole de CDi par 3 points ; hors de " + fr(max(vrM), '%.0f') + "° à " + fr(min(vrM), '%.0f') + "° = extrapolation)", ...
    ["Profil", "Cm0(vrillage)", "Vrillage pour δ = 0 à 45 km/h, MS " + fr(100*MS(1), '%.0f') + " % (3S1P / 4S1P)", ...
     "Idem, MS " + fr(100*MS(nM), '%.0f') + " %", "Sommet de la parabole CDi(vrillage) à 45 km/h"], lignesV);
iV45 = find(abs(Vv - p.stab.V_trim_ref) < 1e-9);  iV35 = find(abs(Vv - p.stab.V_trim(1)) < 1e-9);
lignesS = strings(nKR, 8);
for a = 1:nKR
    r = kR(a);
    lignesS(a, :) = [gen.avion(r), fr(T7.Cm0(r), '%+.4f') + " → " + fr(Cm0V(a), '%+.4f') + " (" + ...
        ternaire(Cm0V(a) >= p.stab.Cm0_aile_min, "tenue", "**non tenue**") + ")", ...
        strjoin(fr(squeeze(dCmV(a, 1, :)).', '%+.4f'), " / "), strjoin(fr(squeeze(dCmV(a, 2, :)).', '%+.4f'), " / "), ...
        fr(dCm_ref(r, 1, 2), '%+.4f') + " → " + fr(dCmReq(a, 1, 2, iV45), '%+.4f') + " ; " + ...
        fr(dCm_ref(r, nM, 2), '%+.4f') + " → " + fr(dCmReq(a, nM, 2, iV45), '%+.4f'), ...
        fr(dCmReq(a, 1, 2, iV35), '%+.4f') + " / " + fr(dCmReq(a, nM, 2, iV35), '%+.4f'), ...
        fr(penteV(a), '%+.4f') + " : " + fr(1000*T7.xNP_Cm(r), '%.1f') + " → " + fr(1000*xNPV(a), '%.1f'), ...
        fr(1000*ecartV(a, 1), '%.1f') + " / " + fr(1000*ecartV(a, nM), '%.1f') + " (marge " + ...
        fr(1000*(2*p.stab.plage_batt_MOD05 - max(ecartV(a, :))), '%.1f') + ")"];
end
if C2.fait
    tableau_md(fid, "Section C2 : xflr5 visqueux − non visqueux (" + p.xfl.avion_C2 + ", mêmes alpha) contre la correction en bandes ; rapport médian " + ...
        fr(C2.rapport, '%.2f') + " → " + C2.mode, ["alpha [°]", "V [km/h]", "CL", "ΔCm xflr5", "ΔCm en bandes", "ΔCL xflr5"], ...
        [fr(C2.alpha, '%.1f'), fr(3.6*C2.V, '%.1f'), fr(C2.CL, '%.3f'), fr(C2.dCm_xflr5, '%+.4f'), fr(C2.dCm_bandes, '%+.4f'), fr(C2.dCL, '%+.4f')]);
end
tableau_md(fid, "Section C : contrôle visqueux du Cm (" + ternaire(C2.mode == "xflr5", "droite ΔCm(CL) de xflr5, bandes non appliquées", ...
    "en bandes, C2 : " + C2.mode) + ") (" + p.xfl.profil_retenu + ", XFoil Ncrit " + fr(p.xfl.Ncrit, '%.0f') + ...
    " contre ligne moyenne en profils minces : Cm " + fr(Cm_mince, '%+.4f') + " ; HORS SKILL, redistribution de portance négligée)", ...
    ["Avion", "Cm(CL = 0) non visqueux → visqueux (MOD-04), Re à " + fr(3.6*Vv(end), '%.0f') + " km/h", ...
     "ΔCm visqueux 3S1P à " + strjoin(fr(3.6*Vv, '%.0f'), " / ") + " km/h", "Idem 4S1P", ...
     "ΔCm à fournir par les élevons à 45 km/h, 4S1P : MS 8 % ; MS 10 % (non visqueux → visqueux)", ...
     "Idem visqueux à 35 km/h, 4S1P : MS 8 % / MS 10 %", ...
     "Pente de ΔCm(CL) (" + fr(3.6*p.stab.V_trim(1), '%.0f') + " à " + fr(3.6*p.stab.V_trim(2), '%.0f') + " km/h) : x_NP [mm] non visqueux → visqueux", ...
     "Écart 3S/4S avec x_NP visqueux, MS 8 % / 10 % [mm] (marge MOD-05)"], lignesS);
tableau_md(fid, "§9 : T2 à élevons braqués à générer (" + p.xfl.profil_retenu + ", δ convention xflr5 : < 0 = vers le haut ; élevons de y = " + ...
    fr(1000*p.geo4.y_elevon(1), '%.0f') + " à " + fr(1000*p.geo4.y_elevon(2), '%.0f') + " mm, charnière à " + fr(100*p.geo4.charniere, '%.0f') + ...
    " % ; conditionnement du plan " + fr(condE, '%.1f') + ")", ...
    ["Avion", "Vrillage [°]", "δ [°]", "Profil des élevons (nom xflr5)", "Fichiers", "Statut"], ...
    [genE.avion, fr(genE.vrillage, '%.0f'), fr(genE.delta, '%+.0f'), genE.profil_elevon, genE.xml_avion + " ; " + genE.xml_T2, ...
     arrayfun(@(f) ternaire(f, "contrôle du maillage (décidé)", "obligatoire"), genE.controle)]);
lignesF = strings(nRT * nD, 5);
for a = 1:nRT
    for j = 1:nD
        lignesF((a-1)*nD + j, :) = [fr(ReT(a), '%.0f'), fr(p.xfl.d_volet(j), '%+.0f') + "°", ...
            strjoin(fr(squeeze(EV.dCm(a, j, :)).', '%+.4f'), " / ") + " (mince " + fr(dCm_dd * p.xfl.d_volet(j), '%+.4f') + ") : η " + ...
            strjoin(fr(squeeze(EV.eta_m(a, j, :)).', '%.2f'), " / "), ...
            strjoin(fr(squeeze(EV.da(a, j, :)).', '%+.2f'), " / ") + " (mince " + fr(-tau_v * p.xfl.d_volet(j), '%+.2f') + ") : η " + ...
            strjoin(fr(squeeze(EV.eta_a(a, j, :)).', '%.2f'), " / "), strjoin(fr(1e4 * squeeze(EV.dCd(a, j, :)).', '%.1f'), " / ")];
    end
end
tableau_md(fid, "§10 : efficacité visqueuse des élevons (" + nomPr + " à volet, charnière " + fr(100*p.geo4.charniere, '%.0f') + ...
    " %, XFoil Ncrit " + fr(p.xfl.Ncrit, '%.0f') + ", contre profils minces HORS SKILL ; Re des élevons de 35 à 55 km/h : " + ...
    fr(min(ReElv), '%.0f') + " à " + fr(max(ReElv), '%.0f') + ")", ...
    ["Re", "δ (xflr5, < 0 = haut)", "ΔCm,c/4 à Cl " + strjoin(fr(ClT, '%.1f'), " / "), "Δα [°] à Cl égal", "ΔCd [1e-4] à Cl égal"], lignesF);
tableau_md(fid, "§11 : T2 à élevons, contrôles (exports reconnus par leur en-tête ; plage de CL d'équilibre " + fr(CLmm(1), '%.3f') + ...
    " à " + fr(CLmm(2), '%.3f') + ", 35 à 55 km/h, 3S1P et 4S1P, ISA)", ["Contrôle", "Valeur"], [ ...
    "Polaires / points de fonctionnement lus", fr(n11, '%d') + " / " + fr(nQ, '%d') + " (α = " + strjoin(fr(p.xfl.alpha_Cl_elv, '%.0f'), " et ") + "°)";
    "Ajustement par avion sur la plage de CL : résidu max Cm (droite) / CDi (parabole)", fr(max(res11(:, 1)), '%.1e') + " / " + fr(max(res11(:, 2)), '%.1e');
    "Pente dCm/dCL des 7 avions (point neutre VLM correspondant)", fr(min(Y11(:, 2)), '%.4f') + " à " + fr(max(Y11(:, 2)), '%.4f') + " (" + fr(1000*range(Y11(:, 2))*gE.MAC, '%.2f') + " mm)";
    "Maillage à élevons (" + nom11(iC) + " − " + nom11(iC0) + ") : ΔCm aux deux bouts de la plage", strjoin(fr(dCmMail, '%+.1e'), " / ") + " (δ équivalent " + strjoin(fr(dEqMail, '%+.3f'), " / ") + "°)";
    "Maillage à élevons : Δx_NP / ΔCDi", fr(-1000*dY(2)*gE.MAC, '%+.3f') + " mm / " + strjoin(fr(dCDiMail, '%+.1e'), " / ");
    "Bandes de l'aile ; cordes exportées contre loi en plan", fr(nB, '%d') + " ; écart " + fr(eCorde, '%.1e') + " m";
    "Cl local = A·[1 CL vr δ] (8 points) : résidu max, bande de transition (" + fr(1000*p.xfl.dy_elevon, '%.0f') + " mm) / ailleurs", fr(max(resB(iTr)), '%.4f') + " / " + fr(max(resB(~iTr)), '%.4f');
    "Recomposition du Cm par les bandes (CmAirf, Cl) / CL des bandes contre CL", fr(eCmRec, '%.1e') + " / " + fr(100*eCLint, '%.1f') + " %";
    "Moment de section de la VLM, dérivée en δ (par degré) : VLM / profils minces sur les élevons", fr(sig(4), '%+.5f') + " / " + fr(Ksec_mince, '%+.5f');
    "Moment de section de la VLM à δ = 0 (vrillage " + fr(cE, '%.0f') + "°, CL " + fr(CLg(2, iv45), '%.3f') + ") / ligne moyenne 2D", ...
        fr([1, CLg(2, iv45), cE, 0] * sig, '%+.4f') + " / " + fr(Sec0_mince, '%+.4f') + " (effet 3D de la flèche ; la correction en bandes n'ajoute que l'écart visqueux 2D)";
    "Recoupement §8 à δ = 0 : ΔCm visqueux / x_NP visqueux / Cm(CL = 0) visqueux", fr(e8, '%.1e') + " / " + fr(1000*eNP8, '%.2f') + " mm / " + fr(eCm08, '%.1e')]);
lignesG = strings(numel(iT), 7);
for t = 1:numel(iT)
    lignesG(t, :) = [fr(vrG(iT(t)), '%+.0f') + "°", fr(dT11(iT(t), ic48, iv45, iVl), '%+.2f') + "° : " + fr(effT(t, iVl), '%+.5f'), ...
        fr(dT11(iT(t), ic48, iv45, iBa), '%+.2f') + "° : " + fr(effT(t, iBa), '%+.5f'), fr(dT11(iT(t), ic48, iv45, iCo), '%+.2f') + "° : " + fr(effT(t, iCo), '%+.5f'), ...
        fr(effT(t, nMo + 1), '%.2f'), fr(effT(t, nMo + 2), '%.2f'), fr(effT(t, iCo) / effT(t, iVl), '%.2f')];
end
tableau_md(fid, "§11 : efficacité des élevons à l'équilibre, " + labC(ic48) + ", " + fr(3.6*Vg(iv45), '%.0f') + " km/h (Cm_δ à CL fixé, par degré ; HORS SKILL)", ...
    ["Vrillage", "VLM : δ_trim : Cm_δ", "Bandes (méthode E4) : δ_trim : Cm_δ", "Complet (verdict) : δ_trim : Cm_δ", ...
     "η_α (portance du volet, XFoil / profils minces)", "η_m (moment de section)", "Cm_δ complet / VLM"], lignesG);
lignesH = strings(numel(iT) * nC, 9);
for t = 1:numel(iT)
    v = iT(t);
    for ic = 1:nC
        dV = squeeze(dT11(v, ic, :, iCo));
        lignesH((t-1)*nC + ic, :) = [fr(vrG(v), '%+.0f') + "°", labC(ic), ...
            strjoin(fr(dV(ismember(round(3.6*Vg), [35 40 45 55])).', '%+.1f'), " / "), ...
            fr(dMin(v, ic, iCo), '%+.1f') + " à " + fr(dMax(v, ic, iCo), '%+.1f') + " (amplitude " + fr(dMax(v, ic, iCo) - dMin(v, ic, iCo), '%.1f') + "°)", ...
            ternaire(okC(v, ic, iCo), "tenu", "**non tenu**"), ...
            fr(dMin(v, ic, iBa), '%+.1f') + " à " + fr(dMax(v, ic, iBa), '%+.1f') + " (" + ternaire(okC(v, ic, iBa), "tenu", "non tenu") + ")", ...
            fr(dMin(v, ic, iVl), '%+.1f') + " à " + fr(dMax(v, ic, iVl), '%+.1f'), fr(course11(v, ic), '%.1f') + "°", ...
            ternaire(any(ext11(v, ic, :)), "oui", "non")];
    end
end
tableau_md(fid, "§11 : braquage d'équilibre δ_trim [°] de " + fr(3.6*Vg(1), '%.0f') + " à " + fr(3.6*Vg(end), '%.0f') + " km/h (ISA ; < 0 = vers le haut) ; critère : de " + ...
    fr(dWin(1), '%+.0f') + " à " + fr(dWin(2), '%+.0f') + "° sur toute la plage (seuils provisoires du 13/10/2026) ; verdict sur le modèle « " + p.stab.mode_verdict + " »", ...
    ["Vrillage", "Configuration", "δ_trim à 35 / 40 / 45 / 55 km/h", "Plage de 35 à 55 km/h", "Critère", "Bandes (méthode E4)", "VLM seule", ...
     "Débattement à cabrer requis (δ_trim à 35 km/h + " + fr(p.stab.d_reserve, '%.0f') + "°, P5-04)", "Braquage hors des polaires à volet (−9 à 0°)"], lignesH);
lignesK = strings(numel(iT), 8);
for t = 1:numel(iT)
    v = iT(t);
    lignesK(t, :) = [fr(vrG(v), '%+.0f') + "°", fr(Cm0v11(v), '%+.4f') + " (" + ternaire(ok04(v), "tenue", "**non tenue**") + ")", ...
        ternaire(okVr(v), "oui", "non") + " / " + ternaire(okVrB(v), "oui", "non") + " / " + ternaire(okVr8(v), "oui", "non"), ...
        fr(fen11(v, 1), '%+.1f') + " à " + fr(fen11(v, 2), '%+.1f') + "°", ...
        "≥ " + fr(dCmRfx(v, 1), '%+.4f') + " et ≤ " + fr(dCmRfx(v, 2), '%+.4f') + ternaire(dCmRfx(v, 1) <= dCmRfx(v, 2), "", " : **impossible**"), ...
        fr(1000*xNPv11(v), '%.1f') + " (VLM " + fr(1000*xNPl11(v), '%.1f') + ")", fr(Dmoy(v), '%.3f'), ...
        strjoin(fr(Dr2(v, :), '%.3f'), " / ")];
end
tableau_md(fid, "§11 : choix du vrillage (règle de l'arrêt B : critère tenu dans les 4 configurations et MOD-04 tenue en visqueux, puis traînée équilibrée moyenne minimale ; grille de " + ...
    fr(p.stab.pas_vr, '%.2f') + "°)", ...
    ["Vrillage", "Cm(CL = 0) visqueux (MOD-04)", "Critère tenu : complet / bandes / MS 8 % seule", "Fenêtre requise (4 configurations)", ...
     "Réflexe fixe : couple ΔCm constant qui met tous les cas dans la fenêtre (≥ : cas le plus cabré à " + fr(dWin(1), '%+.0f') + "° ; ≤ : cas le moins cabré à " + fr(dWin(2), '%+.0f') + "°)", "x_NP visqueux [mm]", "Traînée équilibrée moyenne [N]", ...
     "Traînée [N] : " + strjoin(labC.' + " ", " / ") + " à " + fr(3.6*Vg(iVc(1)), '%.0f') + " km/h, puis à " + fr(3.6*Vg(iVc(end)), '%.0f') + " km/h"], lignesK);
lignesO = [compose("%s, %.0f km/h", repmat(labC, nS, 1), repelem(3.6*Vg(iVc).', nC)), fr(vrG(iOptCas).', '%+.2f') + "°"];
lignesO = [lignesO; "Moyenne des " + fr(nC*nS, '%d') + " cas, sans contrainte", fr(vrG(iOptLibre), '%+.2f') + "°"; ...
           "**Règle de l'arrêt B**", ternaire(arret11, "**ARRÊT : aucun vrillage ne tient le critère dans les 4 configurations**", ...
           fr(vrG(iOpt), '%+.2f') + "°" + ternaire(bordOpt, " (**en bord de plage**)", ""))];
tableau_md(fid, "§11 : minimum de traînée équilibrée par cas (grille de " + fr(p.stab.pas_vr, '%.2f') + "°, de " + fr(max(vrM), '%.0f') + " à " + fr(min(vrM), '%.0f') + "°)", ...
    ["Cas", "Vrillage du minimum"], lignesO);
fclose(fid);

save(fullfile(dRes, 'phase4.mat'), 'p', 'atm', 'B', 'gp', 'mb', 'mTot', 'g0', 'pf', 'Vs', 'Re_lot', 'Re_lot_wl', 'M0', 'x0', 'xb_ind', 'xCG_ind', 'GH', ...
     'pol', 'ip', 'K', 'V', 'V_cmp', 'CL_cmp', 'okSTAB01', 'gen', 'CL_T2', 'V_T2', ...
     'V7', 'CL7', 'CLc', 'T7', 'CDi7', 'Clb7', 'e7', 'Clloc', 'CLeq', 'Veq', 'dCm_ref', 'xCG7', 'xb7', 'ecart7', ...
     'cCm0', 'cCDi', 'vr_eq', 'vr_CDi', 'okEcart05', 'marge05', 'avant3S', 'xPi', ...
     'Cm_mince', 'a0_mince', 'kR', 'Vv', 'CLv', 'dCmV', 'dCmV0', 'Cm0V', 'dCmReq', 'vrEqV', 'penteV', 'xNPV', 'xbV', 'ecartV', 'C2', 'EV', 'polV', 'ipV', 'ReElv', 'tau_v', 'dBase', 'genE', 'condE', 'd_mes', ...
     'dCm_dd', 'nu1', 'xref', 'Vg', 'CLg', 'nom11', 'X11', 'Y11', 'res11', 'betaE', 'cE', 'eE', 'dY', 'dEqMail', 'DE', 'resB', 'sig', ...
     'Ksec_mince', 'e8', 'eNP8', 'eCm08', 'vrG', 'xNPv11', 'xNPl11', 'Cm0v11', 'ok04', 'vr04', 'modes', 'cfg', 'labC', ...
     'dT11', 'hors11', 'de11', 'CD11', 'ext11', 'okC', 'okVr', 'okVrB', 'okVr8', 'fen11', 'course11', 'dCmRfx', 'effT', ...
     'Dr', 'Dmoy', 'iOptCas', 'iOptLibre', 'iOpt', 'bordOpt', 'arret11');
fprintf('Résultats : %s\n', dRes);

%% Fonctions locales
function s = fr(x, fmt)
% Nombre(s) formaté(s) avec la virgule décimale française
s = string(strrep(compose(fmt, x), '.', ','));
end

function v = branche(q, champ, Cl)
% Valeur d'une colonne de polaire 2D à Cl donné, sur la branche montante (jusqu'au Clmax)
[~, iM] = max(q.CL);
[cl, u] = unique(q.CL(1:iM));
y = q.(champ)(1:iM);
v = interp1(cl, y(u), Cl);
assert(~any(isnan(v)), 'branche : Cl hors de la polaire %s à Re %.0f', q.profil, q.Re);
end

function s = ternaire(cond, a, b)
if cond, s = a; else, s = b; end
end
