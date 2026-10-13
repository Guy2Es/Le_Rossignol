%DIMENSIONNEMENT  Phase 3 — pré-dimensionnement V1 de l'aile volante 1 m.
%
%   Script principal : enchaîne tout le calcul d'un bloc.
%     §1 Organisation, atmosphère, géométrie, masses, polaire
%     §2 Diagramme de contraintes P/W = f(W/S) et point de conception
%     §3 Motorisation 2212 : options KV / hélice en 3S et 4S
%     §4 Autonomie et distance en fonction de la vitesse
%     §4b Rendement en croisière calculé et classement des options moteur
%     §4c Configuration retenue, montée, groupe propulsif, plan d'allègement
%     §5 Vent et budget de masse
%     §6 Sensibilité
%     §7 Vérification des exigences et écriture des résultats
%
%   Tous les paramètres sont dans params_v1.m. Toute la physique suit la
%   skill /aircraft-design (C1 = Flight Mechanics, C3 = Aircraft Design) ;
%   les extensions hors skill sont signalées dans les fonctions.
%   Sorties : figures/*.png et *.fig, resultats/phase3.mat,
%             resultats/tableaux_auto.md, resultats/options_motorisation_toutes.csv

clear; close all;
racine = fileparts(mfilename('fullpath'));
addpath(fullfile(racine, 'fonctions'));
dFig = fullfile(racine, 'figures');
dRes = fullfile(racine, 'resultats');
if ~isfolder(dFig), mkdir(dFig); end
if ~isfolder(dRes), mkdir(dRes); end

p = params_v1();
c = p.const;
g = c.g;
S = p.geo.S;

% Palette catégorielle (ordre fixe) et encre des textes
C = ["#2a78d6" "#eb6834" "#1baf7a" "#eda100" "#e87ba4" "#008300" "#6250d6" "#e34948"];
GRIS = "#52514e";

fprintf('\n===== PHASE 3 — PRÉ-DIMENSIONNEMENT V1 =====\n');

%% §1 Atmosphère (C1 p.36-40, ISA+ΔT)
nA = numel(p.atm);
atm = struct('nom', {}, 'T', {}, 'p', {}, 'rho', {}, 'sigma', {});
for i = 1:nA
    [T, pr, rho, ~, sigma] = atmosphere_isa(p.atm(i).H, p.atm(i).dT, c);
    atm(i).nom = p.atm(i).nom;  atm(i).T = T;  atm(i).p = pr;
    atm(i).rho = rho;           atm(i).sigma = sigma;
    fprintf('%-28s  T = %6.2f K  p = %8.0f Pa  rho = %.4f kg/m3  sigma = %.4f\n', ...
            atm(i).nom, T, pr, rho, sigma);
end
rhoI = atm(1).rho;   % ISA niveau de la mer
rhoH = atm(2).rho;   % jour chaud

%% §1 Géométrie : vérification de la MAC (C2 p.64) et de S
E   = p.geo.c_ext / p.geo.c_emp;                              % effilement E = c_e/c_i
MAC = 2/3 * p.geo.c_emp * (1 + E + E^2) / (1 + E);            % C2 p.64
S_trap = p.geo.b / 2 * (p.geo.c_emp + p.geo.c_ext);           % aire du trapèze
fprintf('Géométrie : lambda = %.2f, S(trapèze) = %.4f m2, MAC(C2 p.64) = %.4f m (cahier %.3f)\n', ...
        p.geo.lambda, S_trap, MAC, p.geo.MAC);

%% §1 Masses (budget du cahier)
bm  = budget_masse(p);
m3S = bm.total_3S / 1000;
m4S = bm.total_4S / 1000;
mTO = p.masse.MTOW / 1000;
m_ns = [m3S m4S];
fprintf('Masses : 3S1P %.0f g, 4S1P %.0f g, sans batterie %.0f g\n', ...
        bm.total_3S, bm.total_4S, bm.sans_batt);

%% §1 Polaire : estimation de CD0 (C3 p.85) et points remarquables (C1 p.49-60)
est = estimation_cd0_e(p, rhoI, atm(1).T);
fprintf('CD0 skill (Cfe = %.4f, Swet/S = %.2f) = %.4f ; corrigé Reynolds (Re = %.2e, Cfe = %.4f) = %.4f\n', ...
        p.cd0est.Cfe_ref, est.Swet_sur_S, est.CD0_skill, est.Re_cr, est.Cfe_corr, est.CD0_corrige);

nC = numel(p.aero.CD0_bal);
aeroC = repmat(p.aero, 1, nC);
for i = 1:nC
    aeroC(i).CD0 = p.aero.CD0_bal(i);
end
iNom = find(p.aero.CD0_bal == p.aero.CD0, 1);   % indice du CD0 nominal

PR = cell(1, nC);
for i = 1:nC
    PR{i} = points_remarquables(m4S, S, aeroC(i), c);
    fprintf('CD0 = %.3f : f_max = %.2f ; Pn min : CL = %.3f (%s) EV = %.2f m/s ; fmax : CL = %.3f EV = %.2f m/s\n', ...
        aeroC(i).CD0, PR{i}.f_max, PR{i}.Pn_min.CL, ternaire(PR{i}.Pn_min.faisable, 'faisable', 'AU-DELÀ DE CLmax'), ...
        PR{i}.Pn_min.EV, PR{i}.Tn_min.CL, PR{i}.Tn_min.EV);
end

% Figure 1 : polaire et finesse
CLv = linspace(0, p.aero.CLmax, 200);
fig = figure('Visible', 'off', 'Position', [100 100 1000 420]);
tl = tiledlayout(fig, 1, 2, 'TileSpacing', 'compact');
ax1 = nexttile(tl); hold(ax1, 'on'); grid(ax1, 'on');
ax2 = nexttile(tl); hold(ax2, 'on'); grid(ax2, 'on');
for i = 1:nC
    CD = polaire(CLv, aeroC(i));
    plot(ax1, CD, CLv, 'Color', C(i), 'LineWidth', 2, 'DisplayName', sprintf('C_{D0} = %.3f', aeroC(i).CD0));
    plot(ax2, CLv, CLv ./ CD, 'Color', C(i), 'LineWidth', 2, 'DisplayName', sprintf('C_{D0} = %.3f', aeroC(i).CD0));
    plot(ax2, PR{i}.Tn_min.CL, PR{i}.f_max, 'o', 'Color', C(i), 'MarkerFaceColor', C(i), 'MarkerSize', 8, 'HandleVisibility', 'off');
end
xlabel(ax1, 'C_D'); ylabel(ax1, 'C_L'); title(ax1, 'Polaire parabolique (C1 p.18)');
yline(ax1, p.aero.CLmax, '--', 'C_{L max}', 'Color', GRIS, 'HandleVisibility', 'off');
legend(ax1, 'Location', 'southeast');
xlabel(ax2, 'C_L'); ylabel(ax2, 'Finesse C_L/C_D'); title(ax2, 'Finesse (point : f_{max}, C1 p.50)');
legend(ax2, 'Location', 'southeast');
sauver_figure(fig, "fig01_polaire_finesse", dFig, p.sortie.dpi);

%% §2 Diagramme de contraintes (C3 p.73-83), une figure par CD0
WS = p.bal.WS;
CC = cell(nC, nA);
for i = 1:nC
    for j = 1:nA
        CC{i, j} = contraintes_PW(WS, atm(j).rho, p, aeroC(i));
    end
end

% Points de conception
%  a) Optimum au sens de la skill (C3 p.73) : W/S max admissible (décrochage,
%     cas le plus contraignant ISA / jour chaud), puis P/W mini à cette W/S.
%  b) Point RETENU : géométrie V1 figée (S = 0,25 m²) à la masse maximale de
%     800 g (V1-MAS-01, V1-PERF-01 « à 800 g »), pire cas ISA / jour chaud.
WS_ret = mTO * g / S;
DP = struct('CD0', cell(1, nC));
for i = 1:nC
    WS_opt = min(CC{i, 1}.WS_max, CC{i, 2}.WS_max);
    DP(i).CD0    = aeroC(i).CD0;
    DP(i).WS_opt = WS_opt;
    [DP(i).PW_opt, ~]       = pire_cas(WS_opt, atm, p, aeroC(i));
    [DP(i).PW_ret, DP(i).actif, DP(i).detail] = pire_cas(WS_ret, atm, p, aeroC(i));
    DP(i).WS_ret = WS_ret;
    DP(i).P_ret  = DP(i).PW_ret * mTO;            % W électriques de propulsion
end
fprintf('\nPoint retenu : W/S = %.2f N/m2 (%.2f kg/m2)\n', WS_ret, WS_ret / g);
for i = 1:nC
    fprintf('  CD0 = %.3f : P/W requis = %.1f W/kg -> P = %.1f W (contrainte active : %s) ; optimum skill W/S = %.1f N/m2, P/W = %.1f W/kg\n', ...
        DP(i).CD0, DP(i).PW_ret, DP(i).P_ret, DP(i).actif, DP(i).WS_opt, DP(i).PW_opt);
end

for i = 1:nC
    fig = figure('Visible', 'off', 'Position', [100 100 1100 640]);
    ax = nexttile(tiledlayout(fig, 1, 1)); hold(ax, 'on'); grid(ax, 'on'); box(ax, 'on');
    cI = CC{i, 1};  cH = CC{i, 2};
    env = max(cI.enveloppe, cH.enveloppe);
    WSlim = min(cI.WS_max, cH.WS_max);
    yMax = 260;
    msk = WS <= WSlim & isfinite(env) & env < yMax;
    fill(ax, [WS(msk) fliplr(WS(msk))], [env(msk) yMax * ones(1, nnz(msk))], hex2rgb(C(3)), ...
         'FaceAlpha', 0.15, 'EdgeColor', 'none', 'DisplayName', 'Zone admissible (ISA et jour chaud)');
    courbes = {cI.montee.PW, cH.montee.PW; cI.virage.PW, cH.virage.PW; ...
               cI.croisiere.PW, cH.croisiere.PW; cI.statique.PW_nominal, cH.statique.PW_nominal};
    for k = 1:4
        plot(ax, WS, courbes{k, 1}, '-',  'Color', C(k), 'LineWidth', 2, 'DisplayName', cI.noms(k) + " (ISA)");
        plot(ax, WS, courbes{k, 2}, '--', 'Color', C(k), 'LineWidth', 1.5, 'DisplayName', cI.noms(k) + " (jour chaud)");
    end
    for d = 1:numel(p.prop.D_pouces)
        if p.prop.D_pouces(d) ~= p.prop.D_nominal
            plot(ax, WS, cI.statique.PW(d, :), ':', 'Color', C(4), 'LineWidth', 1.2, ...
                 'DisplayName', sprintf('Lancer main, hélice %d pouces (ISA)', p.prop.D_pouces(d)));
        end
    end
    % Puissance installée (V1-PROP-02) : P/W = P/m, avec m = (W/S)·S/g
    for Pm = p.prop.P_max_req
        plot(ax, WS, Pm ./ (WS * S / g), '-.', 'Color', GRIS, 'LineWidth', 1, ...
             'DisplayName', sprintf('Moteur %d W (V1-PROP-02)', Pm));
    end
    xline(ax, cI.WS_max, '-', 'Décrochage 32 km/h (ISA)', 'Color', C(8), 'LineWidth', 2, ...
          'LabelVerticalAlignment', 'bottom', 'DisplayName', 'Décrochage ≤ 32 km/h (ISA)');
    xline(ax, cH.WS_max, '--', 'jour chaud', 'Color', C(8), 'LineWidth', 1.5, ...
          'LabelVerticalAlignment', 'bottom', 'DisplayName', 'Décrochage ≤ 32 km/h TAS (jour chaud)');
    % Points 3S1P, 4S1P, 800 g et point de conception
    WS3 = m3S * g / S;  WS4 = m4S * g / S;
    plot(ax, WS3, interp1(WS, env, WS3), 's', 'MarkerSize', 10, 'Color', 'k', 'MarkerFaceColor', C(1), ...
         'DisplayName', sprintf('3S1P %.0f g', bm.total_3S));
    plot(ax, WS4, interp1(WS, env, WS4), 'd', 'MarkerSize', 10, 'Color', 'k', 'MarkerFaceColor', C(2), ...
         'DisplayName', sprintf('4S1P %.0f g', bm.total_4S));
    plot(ax, DP(i).WS_ret, DP(i).PW_ret, 'p', 'MarkerSize', 16, 'Color', 'k', 'MarkerFaceColor', C(7), ...
         'DisplayName', sprintf('Point retenu : %.1f N/m², %.0f W/kg', DP(i).WS_ret, DP(i).PW_ret));
    plot(ax, DP(i).WS_opt, DP(i).PW_opt, 'h', 'MarkerSize', 12, 'Color', 'k', 'MarkerFaceColor', GRIS, ...
         'DisplayName', sprintf('Optimum skill (W/S max) : %.1f N/m²', DP(i).WS_opt));
    xlim(ax, [WS(1) WS(end)]); ylim(ax, [0 yMax]);
    xlabel(ax, 'Charge alaire W/S [N/m²]');
    ylabel(ax, 'P_{élec}/m [W/kg de masse au décollage]');
    % Deux lignes vides sous le titre : place pour l'axe secondaire en kg/m²
    title(ax, {sprintf('Diagramme de contraintes — C_{D0} = %.3f, e = %.2f, η = %.2f', ...
          aeroC(i).CD0, p.aero.e, p.prop.eta), '', ''});
    legend(ax, 'Location', 'eastoutside', 'FontSize', 8);
    % Axe secondaire en kg/m² (même grandeur, simple conversion d'unité)
    axk = axes(fig, 'Position', ax.Position, 'XAxisLocation', 'top', 'YAxisLocation', 'right', ...
               'Color', 'none', 'YTick', [], 'XLim', ax.XLim / g, 'Box', 'off');
    xlabel(axk, 'W/S [kg/m²]');
    sauver_figure(fig, sprintf("fig02_contraintes_CD0_%03d", round(1000 * aeroC(i).CD0)), dFig, p.sortie.dpi);
end

%% §3 Motorisation 2212 (hors skill) — options KV / hélice
[opt, toutes] = options_motorisation(p, rhoI, rhoH, m_ns);
writetable(toutes, fullfile(dRes, 'options_motorisation_toutes.csv'));
fprintf('\nOptions moteur retenues (ISA) :\n');
disp(opt(:, {'KV', 'Batterie', 'Helice', 'U_plein_V', 'U_nom_V', 'I_max_A', 'I_lim_A', ...
             'P_plein_W', 'P_nom_W', 'V_pas_sur_Vcr', 'T_stat_N', 'T_sur_W', 'T_sur_W_chaud', 'eta_bat_arbre'}));

% Figure 6 : options retenues
fig = figure('Visible', 'off', 'Position', [100 100 1100 460]);
tl = tiledlayout(fig, 1, 3, 'TileSpacing', 'compact');
lab = categorical(string(opt.KV) + " KV " + opt.Batterie + " " + opt.Helice);
lab = reordercats(lab, string(lab));
coul = repmat(hex2rgb(C(1)), height(opt), 1);
coul(opt.Batterie == "4S1P", :) = repmat(hex2rgb(C(2)), nnz(opt.Batterie == "4S1P"), 1);
axa = nexttile(tl); hb = barh(axa, lab, opt.P_plein_W, 'FaceColor', 'flat'); hb.CData = coul;
xline(axa, p.prop.P_max_req, '--', {'150 W', '200 W'}, 'Color', GRIS);
xlim(axa, [0 1.15 * max(p.prop.P_max_req)]);
xlabel(axa, 'P_{élec} plein gaz, batterie pleine [W]'); title(axa, 'Puissance (V1-PROP-02)'); grid(axa, 'on');
axb = nexttile(tl); hb = barh(axb, lab, opt.T_sur_W, 'FaceColor', 'flat'); hb.CData = coul;
xline(axb, p.req.TsurW_stat, '--', 'T/W = 0,5', 'Color', GRIS);
xlabel(axb, 'Poussée statique / poids (tension nominale, ISA)');
title(axb, 'Lancer main (V1-PERF-08)'); grid(axb, 'on');
axc = nexttile(tl); hb = barh(axc, lab, opt.V_pas_sur_Vcr, 'FaceColor', 'flat'); hb.CData = coul;
xline(axc, p.req.k_pitch, '--', '1,5', 'Color', GRIS);
xlabel(axc, 'Vitesse de pas / 55 km/h'); title(axc, 'Vitesse de pas'); grid(axc, 'on');
title(tl, 'Options moteur 2212 + hélice repliable propulsive (bleu : 3S1P, orange : 4S1P) — modèle à valider au banc (phase 9)');
sauver_figure(fig, "fig06_options_motorisation", dFig, p.sortie.dpi);

%% §4 Autonomie et distance (bilan d'énergie, pas de Breguet)
V = p.bal.V_kmh / 3.6;
AU = cell(numel(p.batt.ns), nC, nA);
for b = 1:numel(p.batt.ns)
    for i = 1:nC
        for j = 1:nA
            AU{b, i, j} = autonomie_distance(V, m_ns(b), p.batt.ns(b), atm(j).rho, p, aeroC(i), p.prop.eta);
        end
    end
end

% Valeurs aux vitesses d'intérêt (ISA)
Vpts = [p.req.V_cr, p.req.V_end_plage];
nPts = numel(Vpts) + 2;
tab_aut = zeros(numel(p.batt.ns) * nC * nPts, 9);   % [ns, CD0, V_kmh, P, t_theo, t_r20, t_r30, R_theo, R_r30]
ligne = 0;
for b = 1:numel(p.batt.ns)
    for i = 1:nC
        a = AU{b, i, 1};
        for v = [Vpts, a.V_tmax, a.V_Rmax]
            k = find(abs(V - v) < 1e-6, 1);
            if isempty(k)
                k = interp1(V, 1:numel(V), v, 'nearest');
            end
            ligne = ligne + 1;
            tab_aut(ligne, :) = [p.batt.ns(b), aeroC(i).CD0, V(k) * 3.6, a.P_elec(k), ...
                a.t_min(k), a.t_reel(1, k), a.t_reel(2, k), a.R_km(k), a.R_reel(2, k)];
        end
    end
end

% Figures 3 (puissance), 4 (autonomie), 5 (distance)
grandeurs = {"P_elec", "fig03_puissance_requise", 'P_{élec} batterie [W]',   'north'; ...
             "t",      "fig04_autonomie",         'Autonomie [min]',         'northeast'; ...
             "R",      "fig05_distance",          'Distance sans vent [km]', 'southwest'};
for G = 1:size(grandeurs, 1)
    fig = figure('Visible', 'off', 'Position', [100 100 1150 480]);
    tl = tiledlayout(fig, 1, 2, 'TileSpacing', 'compact');
    for b = 1:numel(p.batt.ns)
        ax = nexttile(tl); hold(ax, 'on'); grid(ax, 'on'); box(ax, 'on');
        for i = 1:nC
            a = AU{b, i, 1};
            switch grandeurs{G, 1}
                case "P_elec"
                    y = a.P_elec;  yr = [];
                case "t"
                    y = a.t_min;   yr = a.t_reel;
                otherwise
                    y = a.R_km;    yr = a.R_reel;
            end
            if ~isempty(yr)
                ok = isfinite(yr(2, :));
                fill(ax, [V(ok) fliplr(V(ok))] * 3.6, [yr(1, ok) fliplr(yr(2, ok))], hex2rgb(C(i)), ...
                     'FaceAlpha', 0.18, 'EdgeColor', 'none', ...
                     'DisplayName', sprintf('Réel −20/−30 %%, C_{D0} = %.3f', aeroC(i).CD0));
                plot(ax, V * 3.6, y, '--', 'Color', C(i), 'LineWidth', 1.2, ...
                     'DisplayName', sprintf('Théorique, C_{D0} = %.3f', aeroC(i).CD0));
            else
                plot(ax, V * 3.6, y, '-', 'Color', C(i), 'LineWidth', 2, ...
                     'DisplayName', sprintf('C_{D0} = %.3f', aeroC(i).CD0));
            end
        end
        % Repères (CD0 nominal)
        a  = AU{b, iNom, 1};
        prb = points_remarquables(m_ns(b), S, p.aero, c);
        % Étiquettes réparties de part et d'autre des lignes (V(fmax) ≈ 1,2·Vs ici)
        xline(ax, prb.Pn_min.EV * 3.6, '-.', 'V(P_n min) > C_{L max}', 'Color', C(7), 'HandleVisibility', 'off', ...
              'LabelVerticalAlignment', 'bottom', 'LabelHorizontalAlignment', 'right');
        xline(ax, a.Vs * 3.6, '-', 'V_s', 'Color', C(8), 'HandleVisibility', 'off', ...
              'LabelVerticalAlignment', 'top', 'LabelHorizontalAlignment', 'left');
        xline(ax, a.V_min * 3.6, ':', '1,2 V_s', 'Color', C(8), 'HandleVisibility', 'off', ...
              'LabelVerticalAlignment', 'top', 'LabelHorizontalAlignment', 'left');
        xline(ax, prb.Tn_min.EV * 3.6, '-.', 'V(f_{max})', 'Color', C(6), 'HandleVisibility', 'off', ...
              'LabelVerticalAlignment', 'top', 'LabelHorizontalAlignment', 'right');
        xline(ax, p.req.V_cr * 3.6, '-', '55 km/h', 'Color', GRIS, 'LineWidth', 1.5, 'HandleVisibility', 'off', ...
              'LabelVerticalAlignment', 'middle', 'LabelHorizontalAlignment', 'right');
        if grandeurs{G, 1} == "t"
            if p.batt.ns(b) == 4
                yline(ax, p.req.t_4S_cr, '--', 'V1-PERF-03 : 45 min', 'Color', GRIS, 'HandleVisibility', 'off');
                yline(ax, p.req.t_4S_end, '--', 'V1-PERF-04 : 70 min', 'Color', GRIS, 'HandleVisibility', 'off');
                xline(ax, p.req.V_end_op * 3.6, '--', '40 km/h (endurance opérationnelle)', 'Color', GRIS, ...
                      'HandleVisibility', 'off', 'LabelVerticalAlignment', 'bottom', 'LabelHorizontalAlignment', 'right');
            else
                yline(ax, p.req.t_3S_cr, '--', 'V1-PERF-05 : 30 min', 'Color', GRIS, 'HandleVisibility', 'off');
            end
        end
        xlim(ax, [p.bal.V_kmh(1) p.bal.V_kmh(end)]);
        xlabel(ax, 'Vitesse vraie [km/h]'); ylabel(ax, grandeurs{G, 3});
        title(ax, sprintf('%dS1P — %.0f g, ISA', p.batt.ns(b), 1000 * m_ns(b)));
        legend(ax, 'Location', grandeurs{G, 4}, 'FontSize', 7);
    end
    sauver_figure(fig, grandeurs{G, 2}, dFig, p.sortie.dpi);
end

%% §4b Rendement en croisière calculé (hors skill) et classement des options moteur
% Le η = 0,5 du cahier est remplacé, option par option, par le η global au
% point de vol (palier : poussée = traînée), décomposé hélice × moteur × ESC ×
% batterie (point_propulsif.m). η = 0,5 reste le cas de comparaison.
aeroW = aeroC(nC);                                   % pire cas CD0 = 0,035
iE = find(p.batt.ns == 4);  i3 = find(p.batt.ns == 3);
iV40 = find(abs(p.req.V_eta - p.req.V_end_op) < 1e-9, 1);
iV55 = find(abs(p.req.V_eta - p.req.V_cr) < 1e-9, 1);

% Balayage E : moteur 2208 catalogue, hélice choisie sur le η à 55 km/h,
% bridée (THR_MAX) à 130 W si besoin ; il justifie E-1260 (défini dans
% params_v1). Variante E2 : 2208 à KV bas hors catalogue, sans bridage.
% Masse : groupe propulsif explicite (masse_option.m), cellules à 69 g.
mE = masse_option(constantes_moteur(p.motE.KV(1), "motE", p), m_ns, p);
[optE, tabE3, tabE4]    = variante_legere("motE",  "E",  true,  p, mE, rhoI, rhoH);
[optE2, tabE23, tabE24] = variante_legere("motEh", "E2", false, p, mE, rhoI, rhoH);
[~, toutE] = options_motorisation(p, rhoI, rhoH, mE, "motE");   % sans bridage
iE1260 = find([p.opt.nom] == "E-1260", 1);
fprintf('\nBalayage E : meilleur η en 4S pour KV %d, hélices %gx%g / %gx%g (option E-1260 de params_v1 : KV %d, %gx%g / %gx%g)\n', ...
        optE.KV, optE.hel3S, optE.hel4S, p.opt(iE1260).KV, p.opt(iE1260).hel3S, p.opt(iE1260).hel4S);
opts = [p.opt, optE2];
[RO, CLA] = classement_options(opts, p, rhoI, rhoH, m_ns, p.aero, aeroW, V);
fprintf('\nClassement des options sur le η de croisière (ISA, CD0 %.3f) :\n', p.aero.CD0);
disp(CLA);

% Groupe propulsif, masses et cas d'erreur des options comparées côte à côte
nomCote = ["F", "E-1260", "E-1100"];
[~, iCote] = ismember(nomCote, [RO.nom]);
fprintf('\nGroupe propulsif (moteur fiche + hélice %.1f g + adaptateur %.1f g) et masses :\n', 1000 * p.gp.m_pales, 1000 * p.gp.m_moyeu);
for o = 1:numel(RO)
    g_ = RO(o).gp;
    fprintf('  %-7s %5.0f g (budget %.0f g, écart %+.0f g) ; 4S1P %.0f g (marge %+.0f g ; cellules 70 g : %+.0f g) ; sans batterie %.0f g (marge %+.0f g)\n', ...
            RO(o).nom, g_.total, g_.budget, g_.ecart, g_.m_ns(iE), p.masse.MTOW - g_.m_ns(iE), ...
            p.masse.MTOW - g_.m_ns_fiche(iE), g_.sans_batt, p.masse.max_sans_batt - g_.sans_batt);
end
fprintf('\nCas d''erreur humaine (4S1P, batterie pleine, point fixe, ISA) :\n');
for o = iCote
    for k = 1:numel(RO(o).err)
        e_ = RO(o).err(k);
        fprintf('  %-7s %-40s P = %5.0f W, I bat = %5.1f A, I mot = %5.1f A (réf. %.1f A %s, %g s : %.0f A), %5.0f tr/min, survit %g s : %s\n', ...
                RO(o).nom, e_.nom, e_.P, e_.I_b, e_.I_m, e_.I_ref, e_.ref, RO(o).mot.t_I30, RO(o).mot.I30, e_.rpm, ...
                p.gp.t_lancer, ternaire(e_.survit_10s, "oui", "non"));
    end
end

% Cas de comparaison η = 0,5 (cahier), mêmes points de vol, masse du cahier
ref05 = struct('t', zeros(2, 2, 2), 't_W', zeros(2, 2, 2));
for b = 1:numel(p.batt.ns)
    for v = 1:numel(p.req.V_eta)
        aR = autonomie_distance(p.req.V_eta(v), m_ns(b), p.batt.ns(b), rhoI, p, p.aero, p.prop.eta);
        aW = autonomie_distance(p.req.V_eta(v), m_ns(b), p.batt.ns(b), rhoI, p, aeroW, p.prop.eta);
        ref05.t(b, v, :) = aR.t_reel;  ref05.t_W(b, v, :) = aW.t_reel;
    end
end

% Robustesse du classement à l'hypothèse d'hélice en vol (k_JT ±10 %)
kJT = p.hel.k_JT * [0.9 1.1];
rang_kJT = zeros(numel(RO), numel(kJT));
eta_kJT  = zeros(numel(RO), numel(kJT));
for k = 1:numel(kJT)
    q = p;  q.hel.k_JT = kJT(k);
    [~, Ck] = classement_options(opts, q, rhoI, rhoH, m_ns, q.aero, aeroW, V(1));
    [~, pos] = ismember(CLA.Option, Ck.Option);
    rang_kJT(:, k) = Ck.Rang(pos);
    eta_kJT(:, k)  = Ck.eta_4S_55(pos);
end

% Options tracées : toutes sauf F-8x5 (information, tableaux seulement) ;
% palette de 8 teintes en ordre fixe, une couleur par option tracée
oFig = find([RO.nom] ~= "F-8x5");
assert(numel(oFig) <= numel(C), 'plus d''options tracées que de teintes');
coulO = strings(1, numel(RO));
coulO(oFig) = C(1:numel(oFig));

% Figure 9 : η global en fonction de V
fig = figure('Visible', 'off', 'Position', [100 100 1150 480]);
tl = tiledlayout(fig, 1, 2, 'TileSpacing', 'compact');
for b = [iE i3]
    ax = nexttile(tl); hold(ax, 'on'); grid(ax, 'on'); box(ax, 'on');
    for o = oFig
        cr = RO(o).courbe(b);
        y = cr.eta;  y(~cr.faisable) = NaN;
        hc = RO(o).hel{b};
        plot(ax, V * 3.6, y, '-', 'Color', coulO(o), 'LineWidth', 2, ...
             'DisplayName', sprintf('%s : %s %d KV, %gx%g%s', RO(o).nom, RO(o).classe, RO(o).KV, hc(1), hc(2), ...
                                    ternaire(RO(o).thr(b) < 1, sprintf(', THR_{MAX} %.2f', RO(o).thr(b)), '')));
    end
    yline(ax, p.prop.eta, '--', 'η = 0,5 (cahier)', 'Color', GRIS, 'HandleVisibility', 'off');
    xline(ax, p.req.V_end_op * 3.6, ':', '40 km/h', 'Color', GRIS, 'HandleVisibility', 'off');
    xline(ax, p.req.V_cr * 3.6, '-', '55 km/h', 'Color', GRIS, 'HandleVisibility', 'off');
    xline(ax, AU{b, iNom, 1}.V_min * 3.6, ':', '1,2 V_s', 'Color', C(8), 'HandleVisibility', 'off', ...
          'LabelVerticalAlignment', 'bottom');
    xlim(ax, [p.bal.V_kmh(1) p.bal.V_kmh(end)]); ylim(ax, [0 0.8]);
    xlabel(ax, 'Vitesse vraie [km/h]'); ylabel(ax, 'η global = T·V / P_{batterie à vide} [-]');
    title(ax, sprintf('%dS1P, palier, ISA, C_{D0} = %.3f', p.batt.ns(b), p.aero.CD0));
    legend(ax, 'Location', 'south', 'FontSize', 7);
end
title(tl, 'Rendement global en croisière (modèle hélice/moteur/ESC/batterie, à recaler au banc en phase 9)');
sauver_figure(fig, "fig09_rendement_croisiere", dFig, p.sortie.dpi);

% Figure 10 : classement, autonomie réelle 4S1P à 55 km/h vs T/W statique
fig = figure('Visible', 'off', 'Position', [100 100 900 520]);
ax = nexttile(tiledlayout(fig, 1, 1)); hold(ax, 'on'); grid(ax, 'on'); box(ax, 'on');
haut = arrayfun(@(r) r.t(iE, iV55, 1), RO)';          % haut de chaque bande (−20 %)
for o = oFig
    tb = squeeze(RO(o).t(iE, iV55, :));
    plot(ax, [1 1] * CLA.TW_min(o), [tb(2) tb(1)], '-', 'Color', coulO(o), 'LineWidth', 3, 'HandleVisibility', 'off');
    plot(ax, CLA.TW_min(o), tb(2), 'o', 'MarkerSize', 9, 'Color', 'k', 'MarkerFaceColor', coulO(o), ...
         'DisplayName', sprintf('%s (rang %d)', RO(o).nom, CLA.Rang(o)));
    % Étiquette en haut de la bande, ou sous le point si une voisine monte plus haut
    voisine = abs(CLA.TW_min(oFig) - CLA.TW_min(o)) < 0.012 & haut(oFig) > haut(o);
    if any(voisine)
        text(ax, CLA.TW_min(o) + 0.005, tb(2) - 0.8, RO(o).nom, 'Color', GRIS, 'FontWeight', 'bold', 'VerticalAlignment', 'top');
    else
        text(ax, CLA.TW_min(o) + 0.005, tb(1), RO(o).nom, 'Color', GRIS, 'FontWeight', 'bold');
    end
end
tb = squeeze(ref05.t(iE, iV55, :));
yline(ax, tb(2), ':', 'η = 0,5, −30 %', 'Color', GRIS, 'HandleVisibility', 'off', ...
      'LabelHorizontalAlignment', 'left', 'LabelVerticalAlignment', 'bottom');
yline(ax, p.req.t_4S_cr, '--', 'V1-PERF-03 : 45 min', 'Color', C(8), 'HandleVisibility', 'off', ...
      'LabelHorizontalAlignment', 'left');
xline(ax, p.req.TsurW_stat, '--', 'V1-PERF-08 : T/W = 0,5', 'Color', C(8), 'HandleVisibility', 'off');
xlim(ax, [0.45 0.80]);
ylim(ax, [floor(min(CLA.t03_min) / 5) * 5 - 5, ceil(max(arrayfun(@(r) r.t(iE, iV55, 1), RO)) / 5) * 5 + 5]);
xlabel(ax, 'T/W statique minimal (3S/4S, ISA/jour chaud, tension nominale)');
ylabel(ax, 'Autonomie réelle 4S1P à 55 km/h [min] (−30 % à −20 %)');
title(ax, sprintf('Classement des options — ISA, C_{D0} = %.3f (F-8x5, rang %d : tableaux seulement)', ...
      p.aero.CD0, CLA.Rang([RO.nom] == "F-8x5")));
legend(ax, 'Location', 'southwest');
sauver_figure(fig, "fig10_classement_options", dFig, p.sortie.dpi);

%% §4c Configuration retenue (décision du 13/10/2026), groupe propulsif et plan d'allègement
iRef  = find([RO.nom] == p.choix.ref, 1);
iBanc = find([RO.nom] == p.choix.banc, 1);
rF = RO(iRef);
fprintf('\nConfiguration retenue : %s (%s %d KV, %gx%g / %gx%g, THR_MAX %.3f / %.3f) ; option banc : %s\n', ...
        rF.nom, rF.classe, rF.KV, rF.hel{i3}, rF.hel{iE}, rF.thr(i3), rF.thr(iE), RO(iBanc).nom);

% V1-PERF-07 avec le moteur retenu : montée plein gaz (THR_MAX) à 1,3·Vs,
% masse réelle, tension nominale. C1 p.79 : Vz = (T·V − Pn)/(m·g), Pn = D·V
% en palier (hypothèse de pente faible, signalée).
Vz_F = zeros(numel(p.batt.ns), nA);
Vm_F = zeros(numel(p.batt.ns), nA);
for b = 1:numel(p.batt.ns)
    m_b = rF.m_g(b) / 1000;                                         % kg
    for j = 1:nA
        Vm_F(b, j) = p.req.k_Vmontee * sqrt(2 * m_b * g / (atm(j).rho * S * p.aero.CLmax));   % 1,3·Vs
        rm = point_propulsif(rF.mot, rF.hel{b}, p.batt.ns(b), p.batt.V_nom, atm(j).rho, Vm_F(b, j), "gaz", rF.thr(b), p);
        [~, Pn_b] = puissance_requise(Vm_F(b, j), m_b, atm(j).rho, S, p.aero, 1, 0, c);
        Vz_F(b, j) = (rm.T * Vm_F(b, j) - Pn_b) / (m_b * g);       % m/s
    end
end
fprintf('V1-PERF-07 (%s) : Vz = %.2f / %.2f m/s en 3S, %.2f / %.2f m/s en 4S (ISA / jour chaud)\n', ...
        rF.nom, Vz_F(i3, 1), Vz_F(i3, 2), Vz_F(iE, 1), Vz_F(iE, 2));

% Option banc G (deux jeux de pales) : erreurs de fichier et de montage d'hélice
%  (a) 4S1P, fichier 3S : cas_erreur.m (hélice 4S montée)
%  (b) 4S1P, fichier 4S de G, mais hélice 3S restée montée (batterie pleine, point fixe, ISA)
%  (c) 3S1P, fichier 3S, mais hélice 4S restée montée : T/W au lancer le jour chaud
rGb = RO(iBanc);
eGb = point_propulsif(rGb.mot, rGb.hel{i3}, 4, p.batt.V_plein, rhoI, 0, "gaz", rGb.thr(iE), p);
eGc = point_propulsif(rGb.mot, rGb.hel{iE}, 3, p.batt.V_nom, rhoH, 0, "gaz", rGb.thr(i3), p);
TW_Gc = eGc.T / (rGb.m_g(i3) / 1000 * g);
fprintf('%s, 4S avec l''hélice %gx%g montée : P = %.0f W, I mot = %.1f A ; 3S avec l''hélice %gx%g montée : T/W jour chaud = %.2f\n', ...
        rGb.nom, rGb.hel{i3}, eGb.P_elec, eGb.I_mot, rGb.hel{iE}, TW_Gc);

% Groupe propulsif : référence et alternatives propulsives (masses publiées)
nAlt = numel(p.gp.alt);
gpAlt = zeros(nAlt, 3);                                % [pales, moyeu, moteur + pales + moyeu] en g
for k = 1:nAlt
    gpAlt(k, :) = 1000 * [p.gp.alt(k).m_pales, p.gp.alt(k).m_moyeu, ...
                          rF.mot.m + p.gp.alt(k).m_pales + p.gp.alt(k).m_moyeu];
end
gpAlt_min = 1000 * (rF.mot.m + [p.gp.alt.m_pales]');  % g, moteur + pales (borne basse si moyeu non publié)

% Plan d'allègement et budget réaffecté (option retenue, groupe propulsif réel)
B = budget_reaffecte(rF.gp, p);
fprintf('Plan d''allègement : gain %.1f g ; 4S1P %.1f g (cellules 69 g), %.1f g (cellules 70 g) ; sans batterie %.1f g ; structure max %.1f g -> cible %d g\n', ...
        B.gain, B.total_4S, B.total_4S_fiche, B.sans_batt, B.struct_max_4S, B.struct_cible);
% Cas pessimiste : masses hautes des pièces du plan (contrôleur de vol : 19 g
% de la page ArduPilot au lieu de la somme des composants de la fiche)
pH = p;  pH.allg.m = p.allg.m_haut;
B_h = budget_reaffecte(rF.gp, pH);
% Repli : WING MINI introuvable, contrôleur de vol du cahier (F405 WING APP, poste de 25 g)
pC = p;  pC.allg.m{1} = double(p.masse.postes(p.masse.postes(:, 1) == p.allg.postes(1, 1), 3));
B_c = budget_reaffecte(rF.gp, pC);
fprintf('Plan sans la WING MINI (FC du cahier) : 4S1P %.1f g (cellules 70 g) ; structure max %.1f g\n', B_c.total_4S_fiche, B_c.struct_max_4S);
fprintf('Plan, cas pessimiste : gain %.1f g ; 4S1P %.1f g (cellules 70 g) ; sans batterie %.1f g ; structure max %.1f g -> cible %d g\n', ...
        B_h.gain, B_h.total_4S_fiche, B_h.sans_batt, B_h.struct_max_4S, B_h.struct_cible);

% Hélice rigide et adaptateur (fiches APC et RC Dude) : montage, régime, garde au sol
D_hel   = [rF.hel{i3}(1), rGb.hel{iE}(1)];            % in, 8×6 (F) et 7×6 (G en 4S)
n_max_h = p.gp.k_rpm ./ D_hel;                        % tr/min, APC E : 150 000 / D
e_libre = p.gp.e_max - p.gp.e_moyeu;                  % m, réserve d'épaisseur de moyeu sous la limite de l'adaptateur
R_disq  = D_hel(1) * p.const.in / 2;                  % m, le disque balaie R sous l'axe (contrainte phase 5)
fprintf('Hélices %s / 7x6EP : régime max %.0f / %.0f tr/min ; réserve sur l''adaptateur %.1f / %.1f mm ; disque %.1f mm sous l''axe\n', ...
        p.gp.nom_hel, n_max_h, 1000 * e_libre, 1000 * R_disq);

% BEC 5 V du contrôleur de vol face au Pi Zero 2 W et à la caméra (HORS
% SKILL, courants typiques de la documentation Raspberry Pi)
I_pl   = p.av.I_pi + p.av.I_cam;                      % A, Pi + caméra, typique
P_pl   = p.av.V_bec * I_pl;                           % W, comparé à V1-PL-01 (≤ 2,5 W)
I_rest = (p.av.P_av_max - p.av.P_pl_max) / p.av.V_bec;% A, FC + GPS + récepteur dans le budget de V1-AV-05
I_typ  = I_rest + I_pl;                               % A, tout sur le BEC du FC, typique
I_reco = I_rest + p.av.I_pi_psu;                      % A, Pi alimenté au niveau recommandé par Raspberry Pi
fprintf('BEC FC %.1f A (crête %.1f A) : charge typique %.2f A ; avec l''alimentation recommandée du Pi %.2f A ; Pi + caméra %.2f W (V1-PL-01 : %.1f W)\n', ...
        p.av.I_bec_fc, p.av.I_bec_fc_pk, I_typ, I_reco, P_pl, p.av.P_pl_max);

% Budget hélices (lot consommable de MOD-03), prix catalogue en dollars US
bh = p.bud.hel;
cout_hel = [bh.qte] .* [bh.prix_usd];                 % $ par ligne
fprintf('Budget hélices : %.2f $ (prix catalogue, hors port) ; poste du cahier : %d €\n', sum(cout_hel), p.bud.hel_cahier_eur);

%% §5 Vent (V1-PERF-06)
aN = AU{2, iNom, 1};                                 % 4S1P, CD0 nominal, ISA
W  = vent(aN, p.req.V_vent);
k55 = find(abs(V - p.req.V_cr) < 1e-6, 1);
% Vitesse max en palier avec 150 W électriques (borne basse de V1-PROP-02)
Pn_dispo = p.prop.eta * min(p.prop.P_max_req);
fV = @(v) puissance_requise(v, m4S, rhoI, S, p.aero, 1, 0, c) - Pn_dispo;
V_max_palier = fzero(fV, [p.req.V_cr, 60]);
fprintf('\nVent 20 km/h : V_sol à 55 km/h = %.1f km/h ; V max palier (150 W) = %.1f km/h\n', ...
        W.V_sol(k55) * 3.6, V_max_palier * 3.6);

fig = figure('Visible', 'off', 'Position', [100 100 1100 440]);
tl = tiledlayout(fig, 1, 2, 'TileSpacing', 'compact');
ax = nexttile(tl); hold(ax, 'on'); grid(ax, 'on');
plot(ax, V * 3.6, V * 3.6, '-', 'Color', C(1), 'LineWidth', 2, 'DisplayName', 'Sans vent');
plot(ax, V * 3.6, W.V_sol * 3.6, '-', 'Color', C(2), 'LineWidth', 2, 'DisplayName', 'Face à 20 km/h');
xline(ax, p.req.V_cr * 3.6, '-', '55 km/h', 'Color', GRIS, 'HandleVisibility', 'off');
xline(ax, V_max_palier * 3.6, ':', 'V max palier 150 W', 'Color', C(8), 'HandleVisibility', 'off');
xlabel(ax, 'Vitesse air [km/h]'); ylabel(ax, 'Vitesse sol [km/h]'); title(ax, 'Vitesse sol (C1 p.40)');
legend(ax, 'Location', 'northwest');
ax = nexttile(tl); hold(ax, 'on'); grid(ax, 'on');
ok = isfinite(aN.R_reel(2, :));
fill(ax, [V(ok) fliplr(V(ok))] * 3.6, [aN.R_reel(1, ok) fliplr(aN.R_reel(2, ok))], hex2rgb(C(1)), ...
     'FaceAlpha', 0.2, 'EdgeColor', 'none', 'DisplayName', 'Sans vent, réel');
fill(ax, [V(ok) fliplr(V(ok))] * 3.6, [W.R_face_reel(1, ok) fliplr(W.R_face_reel(2, ok))], hex2rgb(C(2)), ...
     'FaceAlpha', 0.3, 'EdgeColor', 'none', 'DisplayName', 'Face au vent 20 km/h, réel');
xline(ax, p.req.V_cr * 3.6, '-', '55 km/h', 'Color', GRIS, 'HandleVisibility', 'off');
xline(ax, W.V_opt * 3.6, '-.', 'optimum face au vent', 'Color', C(2), 'HandleVisibility', 'off');
xlabel(ax, 'Vitesse air [km/h]'); ylabel(ax, 'Distance [km] (−20/−30 %)');
title(ax, '4S1P, C_{D0} nominal, ISA'); legend(ax, 'Location', 'southeast');
xlim(ax, [p.bal.V_kmh(1) p.bal.V_kmh(end)]);
sauver_figure(fig, "fig07_vent", dFig, p.sortie.dpi);

%% §6 Sensibilité
% Base de l'autonomie : 4S1P à 55 km/h, ISA, CD0 nominal, η = 0,5.
% Base du P/W : point de conception retenu (800 g, pire cas ISA / jour chaud).
SE = sensibilite(p, m4S, mTO, [rhoI rhoH]);
assert(abs(SE.base.PW - DP(iNom).PW_ret) < 1e-9, 'base de sensibilité ≠ point de conception');
fprintf('\nSensibilité (base : t = %.1f min théorique 4S ISA ; P/W = %.1f W/kg = point de conception, pire cas) :\n', ...
        SE.base.t, SE.base.PW);
disp(SE.table);

fig = figure('Visible', 'off', 'Position', [100 100 1100 420]);
tl = tiledlayout(fig, 1, 2, 'TileSpacing', 'compact');
cat_ = categorical(SE.table.Parametre); cat_ = reordercats(cat_, string(SE.table.Parametre));
ax = nexttile(tl); hold(ax, 'on'); grid(ax, 'on');
colororder(ax, [hex2rgb(C(1)); hex2rgb(C(2))]);
barh(ax, cat_, [SE.table.dt_bas_pct SE.table.dt_haut_pct], 'grouped');
xlabel(ax, 'Δ autonomie 4S1P à 55 km/h [%]'); title(ax, sprintf('Autonomie, base ISA, η = 0,5 : %.1f min théorique', SE.base.t));
legend(ax, {'valeur basse', 'valeur haute'}, 'Location', 'southeast');
ax = nexttile(tl); hold(ax, 'on'); grid(ax, 'on');
colororder(ax, [hex2rgb(C(1)); hex2rgb(C(2))]);
barh(ax, cat_, [SE.table.dPW_bas_pct SE.table.dPW_haut_pct], 'grouped');
xlabel(ax, 'Δ P/W de conception [%]'); title(ax, sprintf('Point de conception, pire cas ISA/jour chaud : %.1f W/kg', SE.base.PW));
legend(ax, {'valeur basse', 'valeur haute'}, 'Location', 'southeast');
sauver_figure(fig, "fig08_sensibilite", dFig, p.sortie.dpi);

%% §7 Vérification des exigences
% V1-PERF-01 : décrochage à 800 g (EAS = TAS au niveau de la mer ; TAS le jour chaud)
Vs800  = sqrt(2 * mTO * g / (rhoI * S * p.aero.CLmax));
Vs800H = sqrt(2 * mTO * g / (rhoH * S * p.aero.CLmax));
Vs_vir = Vs800 * sqrt(1 / cosd(p.req.phi_virage));          % décrochage en virage (C1 p.89-91)
% V1-PERF-02 : puissance à 45, 55, 60 km/h en 4S1P
P45 = puissance_requise(p.req.V_cr_plage(1), m4S, rhoI, S, p.aero, p.prop.eta, p.prop.P_av, c);
P55 = aN.P_elec(k55);
[P60, ~, CL60] = puissance_requise(p.req.V_cr_plage(2), m4S, rhoI, S, p.aero, p.prop.eta, p.prop.P_av, c);
% V1-PERF-07 : Vz disponible à 1,3·Vs avec 150 W (C1 p.79 : Vz = (Pu − Pn)/(m·g))
Vm800 = p.req.k_Vmontee * Vs800;
[~, Pn_m] = puissance_requise(Vm800, mTO, rhoI, S, p.aero, 1, 0, c);
Vz150  = (p.prop.eta_montee * min(p.prop.P_max_req) - Pn_m) / (mTO * g);
[~, Pn_mH] = puissance_requise(p.req.k_Vmontee * Vs800H, mTO, rhoH, S, p.aero, 1, 0, c);
Vz150H = (p.prop.eta_montee * min(p.prop.P_max_req) - Pn_mH) / (mTO * g);
% V1-PERF-08 : T/W statique avec 150 W, hélice 8" (Froude inversé), avant le choix du KV
A8 = pi * (p.prop.D_nominal * 0.0254)^2 / 4;
T150 = (min(p.prop.P_max_req) * p.prop.FM * p.prop.eta_mot * p.prop.eta_esc * sqrt(2 * rhoI * A8))^(2/3);
T150H = (min(p.prop.P_max_req) * p.prop.FM * p.prop.eta_mot * p.prop.eta_esc * sqrt(2 * rhoH * A8))^(2/3);
% V1-PERF-03/04/05 (ISA, CD0 nominal, et pire cas CD0 = 0,035)
a3 = AU{1, iNom, 1};  a4 = AU{2, iNom, 1};
a3w = AU{1, nC, 1};   a4w = AU{2, nC, 1};
t4_55 = a4.t_reel(:, k55);  t3_55 = a3.t_reel(:, k55);
% V1-PERF-04 : 40 km/h opérationnel (pas de pitot) ; 1,2·Vs = borne théorique
k40 = find(abs(V - p.req.V_end_op) < 1e-6, 1);
t4_end = a4.t_reel(:, k40);  t4_endW = a4w.t_reel(:, k40);
kVm = find(V >= a4.V_min, 1);
t4_borne = a4.t_reel(:, kVm);
% η calculé : plage des autonomies réelles (−30 %) sur les options classées
t03_mod = arrayfun(@(r) r.t(iE, iV55, 2), RO);
t04_mod = arrayfun(@(r) r.t(iE, iV40, 2), RO);
t05_mod = arrayfun(@(r) r.t(i3, iV55, 2), RO);
% Réserve et RTL : fraction de la capacité nominale restante en fin de mission
frac_fin = 1 - p.batt.f_utile * (1 - p.batt.reserve);
fprintf('\nFin de mission : %.0f %% de la capacité nominale restante (RTL du cahier à 30 %%)\n', 100 * frac_fin);
fprintf('V1-PERF-04 : 40 km/h = %.2f·Vs (4S1P, ISA)\n', p.req.V_end_op / a4.Vs);

DPn = DP(iNom);
ver = [ ...
  "V1-PERF-01", sprintf("Vs à 800 g = %s km/h (ISA) ; %s km/h TAS jour chaud", fr(Vs800*3.6, '%.1f'), fr(Vs800H*3.6, '%.1f')), ...
      "≤ 32 km/h (cible 29)", oui(Vs800H <= p.req.Vs_max), sprintf("%s km/h (pire cas)", fr((p.req.Vs_max - Vs800H)*3.6, '%.1f'));
  "V1-PERF-02", sprintf("P_élec 4S1P : %s W à 45, %s W à 55, %s W à 60 km/h (CL = %s)", fr(P45, '%.0f'), fr(P55, '%.0f'), fr(P60, '%.0f'), fr(CL60, '%.2f')), ...
      "45 à 60 km/h tenus", oui(P60 < min(p.prop.P_max_req)), sprintf("P(60 km/h) = %s %% de 150 W", fr(100*P60/min(p.prop.P_max_req), '%.0f'));
  "V1-PERF-03", sprintf("4S1P à 55 km/h, η = 0,5 : %s à %s min réel (−30/−20 %%), %s à %s min si CD0 = 0,035 ; η calculé : %s à %s min (−30 %%) selon l'option", ...
          fr(t4_55(2), '%.0f'), fr(t4_55(1), '%.0f'), fr(a4w.t_reel(2, k55), '%.0f'), fr(a4w.t_reel(1, k55), '%.0f'), fr(min(t03_mod), '%.0f'), fr(max(t03_mod), '%.0f')), ...
      "≥ 45 min", "sous réserve (" + oui3(t4_55(2) >= p.req.t_4S_cr, t4_55(1) >= p.req.t_4S_cr) + " à η = 0,5)", ...
      sprintf("%s à %s min (η = 0,5)", fr(t4_55(2) - p.req.t_4S_cr, '%+.0f'), fr(t4_55(1) - p.req.t_4S_cr, '%+.0f'));
  "V1-PERF-04", sprintf("4S1P à 40 km/h (%s·Vs, opérationnel), η = 0,5 : %s à %s min, %s à %s min si CD0 = 0,035 ; η calculé : %s à %s min (−30 %%) ; borne 1,2·Vs (%s km/h) : %s à %s min", ...
          fr(p.req.V_end_op / a4.Vs, '%.2f'), fr(t4_end(2), '%.0f'), fr(t4_end(1), '%.0f'), fr(t4_endW(2), '%.0f'), fr(t4_endW(1), '%.0f'), ...
          fr(min(t04_mod), '%.0f'), fr(max(t04_mod), '%.0f'), fr(V(kVm)*3.6, '%.1f'), fr(t4_borne(2), '%.0f'), fr(t4_borne(1), '%.0f')), ...
      "≥ 70 min (souhaitable)", oui3(t4_endW(2) >= p.req.t_4S_end, t4_end(1) >= p.req.t_4S_end), sprintf("%s min (CD0 0,035, −30 %%)", fr(t4_endW(2) - p.req.t_4S_end, '%+.1f'));
  "V1-PERF-05", sprintf("3S1P à 55 km/h, η = 0,5 : %s à %s min réel, %s à %s min si CD0 = 0,035 ; η calculé : %s à %s min (−30 %%)", fr(t3_55(2), '%.0f'), fr(t3_55(1), '%.0f'), ...
          fr(a3w.t_reel(2, k55), '%.0f'), fr(a3w.t_reel(1, k55), '%.0f'), fr(min(t05_mod), '%.0f'), fr(max(t05_mod), '%.0f')), ...
      "≥ 30 min", oui3(t3_55(2) >= p.req.t_3S_cr, t3_55(1) >= p.req.t_3S_cr), sprintf("%s min (pire)", fr(t3_55(2) - p.req.t_3S_cr, '%+.0f'));
  "V1-PERF-06", sprintf("V_cr/V_vent = %s ; V_sol face au vent = %s km/h ; V max palier (150 W) = %s km/h", fr(p.req.V_cr/p.req.V_vent, '%.2f'), fr(W.V_sol(k55)*3.6, '%.0f'), fr(V_max_palier*3.6, '%.0f')), ...
      "≥ 20 km/h (critère V_cr ≥ 2·V_vent)", oui(p.req.V_cr >= p.req.k_vent * p.req.V_vent), sprintf("V_cr/V_vent − 2 = %s", fr(p.req.V_cr/p.req.V_vent - p.req.k_vent, '%.2f'));
  "V1-PERF-07", sprintf("Vz à 1,3·Vs (%s km/h) avec 150 W : %s m/s ISA, %s m/s jour chaud", fr(Vm800*3.6, '%.0f'), fr(Vz150, '%.1f'), fr(Vz150H, '%.1f')), ...
      "≥ 3 m/s", oui(min(Vz150, Vz150H) >= p.req.Vz_min), sprintf("%s m/s (pire)", fr(min(Vz150, Vz150H) - p.req.Vz_min, '%+.1f'));
  "V1-PERF-08", sprintf("T/W statique, 150 W, hélice 8 pouces, Froude : %s ISA, %s jour chaud (avant choix du KV)", fr(T150/(mTO*g), '%.2f'), fr(T150H/(mTO*g), '%.2f')), ...
      "≥ 0,5", oui(min(T150, T150H)/(mTO*g) >= p.req.TsurW_stat), sprintf("%s (pire)", fr(min(T150, T150H)/(mTO*g) - p.req.TsurW_stat, '%+.2f'));
  "V1-PROP-02", sprintf("P requise au point retenu (CD0 %s, pire ISA/jour chaud) = %s W (%s)", fr(DPn.CD0, '%.3f'), fr(DPn.P_ret, '%.0f'), DPn.actif), ...
      "150 à 200 W", oui(DPn.P_ret <= min(p.prop.P_max_req)), sprintf("150 W = %s × le besoin", fr(min(p.prop.P_max_req)/DPn.P_ret, '%.2f'))];

fprintf('\n===== VÉRIFICATION DES EXIGENCES (hypothèses du cahier) =====\n');
for i = 1:size(ver, 1)
    fprintf('%-11s %-6s %s | %s | marge %s\n', ver(i, 1), ver(i, 4), ver(i, 2), ver(i, 3), ver(i, 5));
end

% Vérification à jour : configuration retenue (η calculé, masse réelle, plan d'allègement)
tolP = 0.5;   % W, tolérance numérique : un bridage à 200 W tombe à ±1e-6 W près
rG = RO(iBanc);
gF = rF.gp;
k45 = find(abs(V - p.req.V_cr_plage(1)) < 1e-6, 1);
k60 = find(abs(V - p.req.V_cr_plage(2)) < 1e-6, 1);
dcr = @(b, k) rF.courbe(b).d(k);                       % rapport cyclique en palier
cr60_ok = all(arrayfun(@(b) rF.courbe(b).faisable(k60), 1:numel(p.batt.ns)));
tF = @(b, v) fr(rF.t(b, v, 2), '%.0f') + " à " + fr(rF.t(b, v, 1), '%.0f');
P_MOD02 = [140 200];                                   % W, valeur proposée par MOD-02 (par batterie)
dP_MOD02 = [rF.P_max(i3) - P_MOD02(1), P_MOD02(2) - rF.P_max(iE)];   % W, marges aux bornes de MOD-02
dP_MOD02(abs(dP_MOD02) < tolP) = 0;                    % bridage exactement à 200 W : marge nulle, pas « −0 »
mod02_ok = all(rF.P_max >= P_MOD02(1) - tolP & rF.P_max <= P_MOD02(2) + tolP) && min(rF.TW_chaud) >= p.req.TsurW_stat;
verF = [ ...
  "V1-MAS-01", sprintf("4S1P : %s g (cellules 69 g), %s g (70 g) ; avec le plan d'allègement : %s g, %s g", ...
          fr(gF.m_ns(iE), '%.0f'), fr(gF.m_ns_fiche(iE), '%.0f'), fr(B.total_4S, '%.1f'), fr(B.total_4S_fiche, '%.1f')), ...
      "≤ 800 g", "à risque", sprintf("%s g sans plan ; %s g avec plan (cellules 70 g) ; %s g, plan pessimiste (FC 19 g)", fr(p.masse.MTOW - gF.m_ns_fiche(iE), '%+.0f'), fr(p.masse.MTOW - B.total_4S_fiche, '%+.1f'), fr(p.masse.MTOW - B_h.total_4S_fiche, '%+.1f'));
  "V1-MAS-02", sprintf("Sans batterie : %s g ; avec le plan : %s g", fr(gF.sans_batt, '%.0f'), fr(B.sans_batt, '%.1f')), ...
      "≤ 520 g", "à risque", sprintf("%s g sans plan ; %s g avec plan ; %s g, plan pessimiste", fr(p.masse.max_sans_batt - gF.sans_batt, '%+.0f'), fr(p.masse.max_sans_batt - B.sans_batt, '%+.1f'), fr(p.masse.max_sans_batt - B_h.sans_batt, '%+.1f'));
  "V1-MAS-03", sprintf("Structure du budget %s g ; maximum admissible avec le plan %s g (4S, cellules 70 g) ; cible %d g (plan pessimiste : %s g, cible %d g)", ...
          fr(B.structure, '%.0f'), fr(B.struct_max_4S, '%.1f'), B.struct_cible, fr(B_h.struct_max_4S, '%.1f'), B_h.struct_cible), ...
      "≤ 320 g (souhaitable)", ternaire(B.baisse_mas03, "baisse à décider (MOD)", "oui (budget)"), sprintf("%s g sous la cible", fr(B.struct_cible - B.structure, '%+.0f'));
  "V1-PERF-01", sprintf("Vs à 800 g = %s km/h (ISA) ; %s km/h TAS jour chaud (indépendant du moteur)", fr(Vs800*3.6, '%.1f'), fr(Vs800H*3.6, '%.1f')), ...
      "≤ 32 km/h (cible 29)", oui(Vs800H <= p.req.Vs_max), sprintf("%s km/h (pire cas)", fr((p.req.Vs_max - Vs800H)*3.6, '%.1f'));
  "V1-PERF-02", sprintf("%s : palier tenu de 45 à 60 km/h ; rapport cyclique à 45 / 60 km/h : %s / %s en 3S, %s / %s en 4S (THR_MAX %s / %s)", rF.nom, ...
          fr(dcr(i3, k45), '%.2f'), fr(dcr(i3, k60), '%.2f'), fr(dcr(iE, k45), '%.2f'), fr(dcr(iE, k60), '%.2f'), fr(rF.thr(i3), '%.2f'), fr(rF.thr(iE), '%.2f')), ...
      "45 à 60 km/h", oui(cr60_ok), sprintf("d(60 km/h, 4S) = %s × THR_MAX", fr(dcr(iE, k60) / rF.thr(iE), '%.2f'));
  "V1-PERF-03", sprintf("%s, 4S1P à 55 km/h, η calculé %s : %s min (−30 / −20 %%) ; CD0 0,035, −30 %% : %s min (G : %s min)", rF.nom, ...
          fr(rF.eta(iE, iV55), '%.3f'), tF(iE, iV55), fr(rF.t_W(iE, iV55, 2), '%.0f'), fr(rG.t_W(iE, iV55, 2), '%.0f')), ...
      "≥ 45 min", "sous réserve (MOD-01 validée)", sprintf("%s min (CD0 0,030, −30 %%) ; %s min (CD0 0,035)", fr(rF.t(iE, iV55, 2) - p.req.t_4S_cr, '%+.1f'), fr(rF.t_W(iE, iV55, 2) - p.req.t_4S_cr, '%+.1f'));
  "V1-PERF-04", sprintf("%s, 4S1P à 40 km/h, η calculé %s : %s min ; CD0 0,035, −30 %% : %s min", rF.nom, fr(rF.eta(iE, iV40), '%.3f'), tF(iE, iV40), fr(rF.t_W(iE, iV40, 2), '%.0f')), ...
      "≥ 70 min (souhaitable)", oui3(rF.t_W(iE, iV40, 2) >= p.req.t_4S_end, rF.t(iE, iV40, 2) >= p.req.t_4S_end), ...
      sprintf("%s min (CD0 0,035, −30 %%)", fr(rF.t_W(iE, iV40, 2) - p.req.t_4S_end, '%+.0f'));
  "V1-PERF-05", sprintf("%s, 3S1P à 55 km/h, η calculé %s : %s min ; CD0 0,035, −30 %% : %s min", rF.nom, fr(rF.eta(i3, iV55), '%.3f'), tF(i3, iV55), fr(rF.t_W(i3, iV55, 2), '%.0f')), ...
      "≥ 30 min", oui3(rF.t_W(i3, iV55, 2) >= p.req.t_3S_cr, rF.t(i3, iV55, 2) >= p.req.t_3S_cr), ...
      sprintf("%s min (CD0 0,035, −30 %%)", fr(rF.t_W(i3, iV55, 2) - p.req.t_3S_cr, '%+.0f'));
  "V1-PERF-06", sprintf("V_cr/V_vent = %s ; V_sol face au vent = %s km/h", fr(p.req.V_cr/p.req.V_vent, '%.2f'), fr(W.V_sol(k55)*3.6, '%.0f')), ...
      "≥ 20 km/h (critère V_cr ≥ 2·V_vent)", oui(p.req.V_cr >= p.req.k_vent * p.req.V_vent), sprintf("V_cr/V_vent − 2 = %s", fr(p.req.V_cr/p.req.V_vent - p.req.k_vent, '%.2f'));
  "V1-PERF-07", sprintf("%s plein gaz (THR_MAX) à 1,3·Vs, masse réelle : %s / %s m/s en 3S, %s / %s m/s en 4S (ISA / jour chaud)", rF.nom, ...
          fr(Vz_F(i3, 1), '%.1f'), fr(Vz_F(i3, 2), '%.1f'), fr(Vz_F(iE, 1), '%.1f'), fr(Vz_F(iE, 2), '%.1f')), ...
      "≥ 3 m/s", oui(min(Vz_F(:)) >= p.req.Vz_min), sprintf("%s m/s (pire)", fr(min(Vz_F(:)) - p.req.Vz_min, '%+.1f'));
  "V1-PERF-08", sprintf("%s, T/W statique : %s / %s en 3S, %s / %s en 4S (ISA / jour chaud)", rF.nom, ...
          fr(rF.TW(i3), '%.2f'), fr(rF.TW_chaud(i3), '%.2f'), fr(rF.TW(iE), '%.2f'), fr(rF.TW_chaud(iE), '%.2f')), ...
      "≥ 0,5", oui(min([rF.TW, rF.TW_chaud]) >= p.req.TsurW_stat), sprintf("%s (pire)", fr(min([rF.TW, rF.TW_chaud]) - p.req.TsurW_stat, '%+.2f'));
  "V1-PROP-02", sprintf("%s, P max batterie pleine : %s W en 3S, %s W en 4S (besoin au point de conception : %s W)", rF.nom, ...
          fr(rF.P_max(i3), '%.0f'), fr(rF.P_max(iE), '%.0f'), fr(DPn.P_ret, '%.0f')), ...
      "150 à 200 W ; MOD-02 : 140 à 200 W par batterie et T/W statique jour chaud ≥ 0,5", ternaire(mod02_ok, "oui (MOD-02 validée)", "NON"), ...
      sprintf("3S : %s W au-dessus de 140 W ; 4S : %s W sous 200 W (bridage) ; T/W jour chaud %s (pire)", fr(dP_MOD02(1), '%+.0f'), ...
              fr(dP_MOD02(2), '%.0f'), fr(min(rF.TW_chaud) - p.req.TsurW_stat, '%+.2f'));
  "V1-PROP-03", sprintf("%s + %s ; régime max %s tr/min (pire cas d'erreur : %s tr/min)", p.gp.nom_hel, p.gp.nom_moyeu, ...
          fr(n_max_h(1), '%.0f'), fr(max([rF.err.rpm]), '%.0f')), ...
      "Propulsive repliable (souhaitable) ; MOD-03 : propulsive, rigide acceptée, coupure moteur avant le toucher, lot de 10", ...
      "oui (MOD-03 validée)", sprintf("disque %s mm sous l'axe : garde au sol à vérifier en phase 5", fr(1000 * R_disq, '%.0f'));
  "V1-PL-01", sprintf("Pi Zero 2 W + caméra, courants typiques (documentation Raspberry Pi) : %s A, soit %s W sous %s V", ...
          fr(I_pl, '%.2f'), fr(P_pl, '%.2f'), fr(p.av.V_bec, '%.1f')), ...
      "≤ 2,5 W (et ≤ 30 g)", ternaire(P_pl > p.av.P_pl_max, "à risque (mesure phase 6)", "oui"), sprintf("%s W", fr(p.av.P_pl_max - P_pl, '%+.2f'))];
fprintf('\n===== VÉRIFICATION DES EXIGENCES (configuration retenue %s) =====\n', rF.nom);
for i = 1:size(verF, 1)
    fprintf('%-11s %-20s %s | %s | marge %s\n', verF(i, 1), verF(i, 4), verF(i, 2), verF(i, 3), verF(i, 5));
end

%% §7 Écriture des tableaux Markdown (recopiés dans phase3_resultats.md)
fid = fopen(fullfile(dRes, 'tableaux_auto.md'), 'w', 'n', 'UTF-8');
fprintf(fid, '# Tableaux générés par dimensionnement.m (%s)\n\n', string(datetime('now', 'Format', 'yyyy-MM-dd HH:mm')));
fprintf(fid, 'Ne pas éditer à la main : ce fichier est réécrit à chaque exécution.\n');

tableau_md(fid, "Vérification des exigences — configuration retenue " + rF.nom + " (η calculé, masse avec groupe propulsif réel, ISA, CD0 0,030 sauf mention)", ...
    ["Exigence", "Valeur calculée", "Exigence (cahier)", "Statut", "Marge"], verF);
tableau_md(fid, "Vérification des exigences — hypothèses du cahier (η = 0,5, budget du cahier), avant choix du moteur", ...
    ["Exigence", "Valeur calculée", "Exigence (cahier)", "Conforme", "Marge"], ver(:, [1 2 3 4 5]));

cel = strings(nA, 5);
for j = 1:nA
    cel(j, :) = [atm(j).nom, fr(atm(j).T - 273.15, '%.1f'), fr(atm(j).p, '%.0f'), fr(atm(j).rho, '%.4f'), fr(atm(j).sigma, '%.3f')];
end
tableau_md(fid, "Atmosphère (C1 p.36-39, ISA+ΔT)", ["Cas", "T [°C]", "p [Pa]", "ρ [kg/m³]", "σ"], cel);

tableau_md(fid, "Géométrie", ["λ", "S trapèze [m²]", "MAC C2 p.64 [m]", "MAC cahier [m]"], ...
    [fr(p.geo.lambda, '%.2f'), fr(S_trap, '%.4f'), fr(MAC, '%.4f'), fr(p.geo.MAC, '%.3f')]);

tableau_md(fid, "Estimation de CD0 (C3 p.85) et Reynolds", ...
    ["Swet/S", "Re croisière (MAC)", "Re à 29 km/h", "CD0 skill (Cfe 0,0055)", "Cfe corrigé Re", "CD0 corrigé", "Plage cahier"], ...
    [fr(est.Swet_sur_S, '%.2f'), fr(est.Re_cr, '%.3g'), fr(est.Re_Vs, '%.3g'), fr(est.CD0_skill, '%.4f'), ...
     fr(est.Cfe_corr, '%.4f'), fr(est.CD0_corrige, '%.4f'), "0,025 à 0,035"]);

cel = strings(nC, 9);
for i = 1:nC
    q = PR{i};
    cel(i, :) = [fr(aeroC(i).CD0, '%.3f'), fr(q.k, '%.4f'), fr(q.f_max, '%.2f'), ...
        fr(q.Pn_min.CL, '%.3f'), ternaire(q.Pn_min.faisable, "oui", "non (> CLmax)"), fr(q.Pn_min.EV*3.6, '%.1f'), ...
        fr(q.Tn_min.CL, '%.3f'), fr(q.Tn_min.EV*3.6, '%.1f'), fr(q.TnV_min.EV*3.6, '%.1f')];
end
tableau_md(fid, sprintf("Points remarquables, 4S1P %.0f g, ISA (C1 p.49-60)", bm.total_4S), ...
    ["CD0", "k", "f_max", "CL(Pn min)", "Pn min faisable", "V(Pn min) [km/h]", "CL(fmax)", "V(fmax) [km/h]", "V(Tn/V min) [km/h]"], cel);

cel = strings(nC, 10);
for i = 1:nC
    d = DP(i).detail;
    cel(i, :) = [fr(DP(i).CD0, '%.3f'), fr(d(1), '%.0f'), fr(d(2), '%.0f'), fr(d(3), '%.0f'), fr(d(4), '%.0f'), ...
        fr(DP(i).PW_ret, '%.0f'), DP(i).actif, fr(DP(i).P_ret, '%.0f'), fr(DP(i).WS_opt, '%.1f') + " (" + fr(DP(i).WS_opt/g, '%.2f') + " kg/m²)", fr(DP(i).PW_opt, '%.0f')];
end
tableau_md(fid, sprintf("Point de conception — W/S retenue %s N/m² (%s kg/m²), 800 g, pire cas ISA/jour chaud, P/W en W/kg", fr(WS_ret, '%.1f'), fr(WS_ret/g, '%.2f')), ...
    ["CD0", "Montée", "Virage", "Croisière", "Lancer 8 pouces", "P/W requis", "Contrainte active", "P_élec requise [W]", "Optimum skill W/S [N/m²]", "P/W à l'optimum"], cel);

cel = [string(opt.KV), string(opt.Batterie), string(opt.Helice), fr(opt.U_plein_V, '%.1f') + " / " + fr(opt.U_nom_V, '%.1f'), ...
       fr(opt.I_max_A, '%.1f') + " (lim. " + fr(opt.I_lim_A, '%.0f') + ")", fr(opt.P_plein_W, '%.0f') + " / " + fr(opt.P_nom_W, '%.0f'), ...
       fr(opt.rpm_nom, '%.0f'), fr(opt.V_pas_ms*3.6, '%.0f') + " (" + fr(opt.V_pas_sur_Vcr, '%.2f') + "×)", ...
       fr(opt.T_stat_N, '%.2f') + " (" + fr(opt.T_sur_W, '%.2f') + ")", fr(opt.T_sur_W_chaud, '%.2f'), ...
       fr(opt.eta_bat_arbre, '%.2f'), signalements(opt)];
tableau_md(fid, "Options moteur 2212 + hélice repliable propulsive (modèle, ISA sauf mention)", ...
    ["KV", "Batterie", "Hélice", "U sous charge plein / nominal [V]", "I max = I cellule [A]", "P_élec plein / nominal [W]", ...
     "tr/min (nominal)", "V pas [km/h] (/55 km/h)", "T statique [N] (T/W)", "T/W jour chaud", "η batterie→arbre", "Signalements"], cel);

% Toutes les combinaisons valides (pour choisir une variante) et blocage des KV élevés en 4S
tv = toutes(toutes.Valide, :);
tableau_md(fid, "Toutes les combinaisons qui passent les critères durs (ISA)", ...
    ["KV", "Batterie", "Hélice", "I max [A] (lim.)", "P plein / nominal [W]", "V pas / V_cr", "T/W ISA / chaud", "Signalements"], ...
    [string(tv.KV), tv.Batterie, tv.Helice, fr(tv.I_max_A, '%.1f') + " (" + fr(tv.I_lim_A, '%.1f') + ")", ...
     fr(tv.P_plein_W, '%.0f') + " / " + fr(tv.P_nom_W, '%.0f'), fr(tv.V_pas_sur_Vcr, '%.2f'), ...
     fr(tv.T_sur_W, '%.2f') + " / " + fr(tv.T_sur_W_chaud, '%.2f'), signalements(tv)]);
t4 = toutes(toutes.Batterie == "4S1P" & toutes.Helice == "7x4", :);
tableau_md(fid, "4S1P avec la plus petite hélice du balayage (7x4) : pourquoi les KV élevés échouent", ...
    ["KV", "I max [A]", "I limite [A]", "P batterie pleine [W]", "Valide"], ...
    [string(t4.KV), fr(t4.I_max_A, '%.1f'), fr(t4.I_lim_A, '%.1f'), fr(t4.P_plein_W, '%.0f'), ...
     arrayfun(@(v) ternaire(v, "oui", "non"), t4.Valide)]);

cel = strings(size(tab_aut, 1), 9);
for i = 1:size(tab_aut, 1)
    r = tab_aut(i, :);
    cel(i, :) = [sprintf("%dS1P", r(1)), fr(r(2), '%.3f'), fr(r(3), '%.1f'), fr(r(4), '%.1f'), fr(r(5), '%.0f'), ...
                 fr(r(6), '%.0f'), fr(r(7), '%.0f'), fr(r(8), '%.1f'), fr(r(9), '%.1f')];
end
tableau_md(fid, "Autonomie et distance, ISA (vitesses : 55, 35, 40 km/h, max autonomie, max distance)", ...
    ["Batterie", "CD0", "V [km/h]", "P_élec [W]", "t théorique [min]", "t réel −20 % [min]", "t réel −30 % [min]", "R théorique [km]", "R réel −30 % [km]"], cel);

cel = strings(numel(p.batt.ns) * nC, 5);
ligne = 0;
for b = 1:numel(p.batt.ns)
    for i = 1:nC
        a = AU{b, i, 1};  aH = AU{b, i, 2};
        ligne = ligne + 1;
        cel(ligne, :) = [sprintf("%dS1P", p.batt.ns(b)), fr(aeroC(i).CD0, '%.3f'), ...
            fr(a.V_tmax*3.6, '%.1f') + ternaire(a.tmax_en_butee, " (butée 1,2·Vs)", ""), ...
            fr(a.V_Rmax*3.6, '%.1f'), fr(aH.t_reel(2, k55), '%.0f') + " à " + fr(aH.t_reel(1, k55), '%.0f')];
    end
end
tableau_md(fid, "Optimums numériques (avec avionique) et autonomie réelle à 55 km/h le jour chaud", ...
    ["Batterie", "CD0", "V autonomie max [km/h]", "V distance max [km/h]", "t réel 55 km/h jour chaud [min]"], cel);

tableau_md(fid, "Vent de face 20 km/h (V1-PERF-06), 4S1P, CD0 nominal, ISA", ...
    ["V air [km/h]", "V sol [km/h]", "Distance face au vent réel [km]", "Distance sans vent réel [km]", "V optimale face au vent [km/h]", "Distance à l'optimum (théorique) [km]", "V max palier 150 W [km/h]"], ...
    [fr(p.req.V_cr*3.6, '%.0f'), fr(W.V_sol(k55)*3.6, '%.1f'), fr(W.R_face_reel(2, k55), '%.1f') + " à " + fr(W.R_face_reel(1, k55), '%.1f'), ...
     fr(aN.R_reel(2, k55), '%.1f') + " à " + fr(aN.R_reel(1, k55), '%.1f'), fr(W.V_opt*3.6, '%.1f'), fr(W.R_opt, '%.1f'), fr(V_max_palier*3.6, '%.0f')]);

cel = [bm.postes.Poste, bm.postes.Groupe, string(bm.postes.Masse_g)];
cel = [cel; "**Sous-total structure**", "", string(bm.structure); "**Sous-total systèmes**", "", string(bm.systemes); ...
       "**Masse sans batterie**", "", string(bm.sans_batt); "Batterie 4S1P", "", string(p.masse.batt_4S); ...
       "**Total 4S1P**", "", string(bm.total_4S); "Batterie 3S1P", "", string(p.masse.batt_3S); "**Total 3S1P**", "", string(bm.total_3S)];
tableau_md(fid, "Budget de masse (cahier)", ["Poste", "Groupe", "Masse [g]"], cel);
tableau_md(fid, "Marges de masse", ["Critère", "Valeur [g]", "Limite [g]", "Marge [g]"], [ ...
    "V1-MAS-01, 4S1P (cellules 69 g)", string(bm.total_4S), string(p.masse.MTOW), string(bm.marge_4S);
    "V1-MAS-01, 4S1P (cellules 70,0 g, fiche)", string(bm.total_4S_fiche), string(p.masse.MTOW), string(bm.marge_4S_fiche);
    "V1-MAS-01, 3S1P", string(bm.total_3S), string(p.masse.MTOW), string(bm.marge_3S);
    "V1-MAS-02, sans batterie", string(bm.sans_batt), string(p.masse.max_sans_batt), string(bm.marge_sans_batt);
    "V1-MAS-03, structure", string(bm.structure), string(p.masse.max_struct), string(bm.marge_struct);
    "Règle de décision structure", string(bm.structure), string(p.masse.seuil_struct), string(bm.marge_seuil330)]);

T = SE.table;
cel = [T.Parametre, fr(T.Bas, '%.3g') + " / " + fr(T.Haut, '%.3g'), fr(T.t_bas_min, '%.1f') + " / " + fr(T.t_haut_min, '%.1f'), ...
       fr(T.dt_bas_pct, '%+.1f') + " / " + fr(T.dt_haut_pct, '%+.1f'), fr(T.PW_bas, '%.1f') + " / " + fr(T.PW_haut, '%.1f'), ...
       fr(T.dPW_bas_pct, '%+.1f') + " / " + fr(T.dPW_haut_pct, '%+.1f')];
tableau_md(fid, sprintf("Sensibilité — base : 4S1P à 55 km/h, t théorique = %s min ; P/W de conception = %s W/kg", fr(SE.base.t, '%.1f'), fr(SE.base.PW, '%.1f')), ...
    ["Paramètre", "Bas / haut", "t théorique [min]", "Δt [%]", "P/W [W/kg]", "ΔP/W [%]"], cel);

% --- §4b : classement des options sur le η de croisière
nO = numel(RO);
cel = strings(nO + 1, 15);
for o = 1:nO
    r = RO(o);
    % Exigences non tenues dans le cas défavorable (CD0 nominal, −30 %)
    ech = ["V1-PERF-03", "V1-PERF-04", "V1-PERF-05", "V1-PERF-08", "croisière > THR_MAX"];
    ech = ech([r.t(iE, iV55, 2) < p.req.t_4S_cr, r.t(iE, iV40, 2) < p.req.t_4S_end, ...
               r.t(i3, iV55, 2) < p.req.t_3S_cr, min([r.TW, r.TW_chaud]) < p.req.TsurW_stat, ~all(r.cr_ok(:))]);
    ech = ternaire(isempty(ech), "aucune", strjoin(ech, ", "));
    hs = sprintf('%gx%g', r.hel{i3}) + " / " + sprintf('%gx%g', r.hel{iE});
    th = fr(r.thr(i3), '%.2f') + " / " + fr(r.thr(iE), '%.2f');
    tb = @(b, v) fr(r.t(b, v, 2), '%.0f') + " à " + fr(r.t(b, v, 1), '%.0f');
    cel(o, :) = [string(CLA.Rang(o)), r.nom, r.classe + " " + r.KV + " KV", hs, th, ...
        fr(r.eta(iE, iV40), '%.3f') + " / " + fr(r.eta(iE, iV55), '%.3f') + " / " + fr(r.eta(i3, iV55), '%.3f'), ...
        tb(iE, iV55), fr(r.t_W(iE, iV55, 2), '%.0f'), tb(iE, iV40), tb(i3, iV55), ...
        fr(min(r.TW), '%.2f') + " / " + fr(min(r.TW_chaud), '%.2f'), ...
        fr(r.P_max(i3), '%.0f') + " / " + fr(r.P_max(iE), '%.0f'), ...
        fr(r.I_max(i3), '%.1f') + " / " + fr(r.I_max(iE), '%.1f') + " (lim. " + fr(r.I_lim(iE), '%.0f') + ")", ...
        fr(r.m_g(iE), '%.0f') + " (" + fr(p.masse.MTOW - r.m_g(iE), '%+.0f') + " ; " + ...
        fr(p.masse.MTOW - r.gp.m_ns_fiche(iE), '%+.0f') + " cell. 70 g)", ech];
end
tb = @(b, v) fr(ref05.t(b, v, 2), '%.0f') + " à " + fr(ref05.t(b, v, 1), '%.0f');
cel(end, :) = ["—", "η = 0,5 (cahier)", "—", "—", "—", "0,5 / 0,5 / 0,5", tb(iE, iV55), fr(ref05.t_W(iE, iV55, 2), '%.0f'), ...
               tb(iE, iV40), tb(i3, iV55), "—", "—", "—", fr(bm.total_4S, '%.0f') + " (" + fr(bm.marge_4S, '%+.0f') + ")", ...
               ternaire(ref05.t(iE, iV55, 2) < p.req.t_4S_cr, "V1-PERF-03", "aucune")];
tableau_md(fid, sprintf("Classement des options moteur sur le η de croisière calculé (ISA, CD0 %s, tension nominale) — tri : autonomie réelle 4S1P à 55 km/h, −30 %%", fr(p.aero.CD0, '%.3f')), ...
    ["Rang", "Option", "Moteur", "Hélice 3S / 4S", "THR_MAX 3S / 4S", "η 4S 40 / 4S 55 / 3S 55 km/h", ...
     "V1-PERF-03 : 4S 55 km/h [min]", "idem CD0 0,035, −30 %", "V1-PERF-04 : 4S 40 km/h [min]", "V1-PERF-05 : 3S 55 km/h [min]", ...
     "T/W min ISA / jour chaud", "P max 3S / 4S [W]", "I max 3S / 4S [A]", "Masse 4S [g] (marge 800 g)", ...
     "Non tenu à −30 % (CD0 nominal)"], cel);

cel = strings(nO, 4);
for o = 1:nO
    cel(o, :) = [RO(o).nom, string(CLA.Rang(o)), string(rang_kJT(o, 1)) + " / " + string(rang_kJT(o, 2)), ...
                 fr(eta_kJT(o, 1), '%.3f') + " / " + fr(RO(o).eta(iE, iV55), '%.3f') + " / " + fr(eta_kJT(o, 2), '%.3f')];
end
tableau_md(fid, sprintf("Robustesse du classement à l'hypothèse d'hélice en vol (k_JT = %s / %s / %s)", ...
    fr(kJT(1), '%.2f'), fr(p.hel.k_JT, '%.2f'), fr(kJT(2), '%.2f')), ...
    ["Option", "Rang nominal", "Rang k_JT bas / haut", "η 4S 55 km/h bas / nominal / haut"], cel);

cel = strings(2 * nO, 9);
ligne = 0;
for o = 1:nO
    for b = [iE i3]
        ligne = ligne + 1;
        dt = squeeze(RO(o).det(b, iV55, :));
        cel(ligne, :) = [RO(o).nom, sprintf("%dS1P", p.batt.ns(b)), sprintf('%gx%g', RO(o).hel{b}), ...
            fr(dt(1), '%.3f'), fr(dt(2), '%.3f'), fr(dt(3), '%.3f'), fr(dt(4), '%.3f'), fr(RO(o).eta(b, iV55), '%.3f'), ...
            fr(RO(o).rpm(b, iV55), '%.0f') + " tr/min, d = " + fr(RO(o).d(b, iV55), '%.2f') + ", I = " + fr(RO(o).I_cr(b, iV55), '%.1f') + " A"];
    end
end
tableau_md(fid, "Décomposition du η global à 55 km/h (ISA, CD0 nominal, tension nominale)", ...
    ["Option", "Batterie", "Hélice", "η hélice", "η moteur", "η ESC", "η batterie", "η global", "Point de fonctionnement"], cel);

% Bridages (THR_MAX) calculés
cel = strings(nO * numel(p.batt.ns), 8);
ligne = 0;
for o = 1:nO
    for b = 1:numel(p.batt.ns)
        if isfield(RO(o), 'bridage') && numel(RO(o).bridage) >= b && ~isempty(RO(o).bridage(b).thr)
            L = RO(o).bridage(b);
            ligne = ligne + 1;
            cel(ligne, :) = [RO(o).nom, sprintf("%dS1P", p.batt.ns(b)), sprintf('%gx%g', RO(o).hel{b}), ...
                fr(L.d_P, '%.3f'), fr(L.d_I, '%.3f'), fr(L.thr, '%.3f') + " (" + L.actif + ")", ...
                fr(L.P, '%.0f'), fr(L.I, '%.1f') + " (lim. " + fr(L.I_lim, '%.0f') + ")"];
        end
    end
end
tableau_md(fid, "Bridage des gaz calculé (batterie pleine, point fixe, ISA)", ...
    ["Option", "Batterie", "Hélice", "d à P_lim", "d à I_lim", "THR_MAX retenu", "P au bridage [W]", "I au bridage [A]"], cel(1:ligne, :));

% Variante E : balayage sans bridage (catalogue) et choix sur le η
tv = toutE;
tableau_md(fid, sprintf("Variante E sans bridage : %s, hélices ≥ 8 pouces, fenêtre 100-130 W (toutes les combinaisons)", p.motE.nom), ...
    ["KV", "Batterie", "Hélice", "I max [A] (lim.)", "P plein [W]", "T/W ISA / chaud", "Valide"], ...
    [string(tv.KV), tv.Batterie, tv.Helice, fr(tv.I_max_A, '%.1f') + " (" + fr(tv.I_lim_A, '%.0f') + ")", ...
     fr(tv.P_plein_W, '%.0f'), fr(tv.T_sur_W, '%.2f') + " / " + fr(tv.T_sur_W_chaud, '%.2f'), ...
     arrayfun(@(v) ternaire(v, "oui", "non"), tv.Valide)]);
tE = {tabE3, tabE4, tabE23, tabE24};
nomE = ["E, 3S1P", "E, 4S1P", "E2, 3S1P", "E2, 4S1P"];
for k = 1:numel(tE)
    tk = sortrows(tE{k}(tE{k}.Valide, :), 'eta_55', 'descend');
    tk = tk(1:min(8, height(tk)), :);
    tableau_md(fid, "Choix de l'hélice sur le η à 55 km/h — " + nomE(k) + " (8 meilleures combinaisons valides)", ...
        ["KV", "Hélice", "THR_MAX (bridage)", "P max [W]", "I max [A]", "T/W ISA / chaud", "η 55 km/h", "d croisière"], ...
        [string(tk.KV), tk.Helice, fr(tk.THR_MAX, '%.2f') + " (" + tk.Bridage + ")", fr(tk.P_max_W, '%.0f'), fr(tk.I_max_A, '%.1f'), ...
         fr(tk.T_sur_W, '%.2f') + " / " + fr(tk.T_sur_W_chaud, '%.2f'), fr(tk.eta_55, '%.3f'), fr(tk.d_croisiere, '%.2f')]);
end

% Groupe propulsif explicite et masses (toutes les options)
cel = strings(nO, 9);
for o = 1:nO
    g_ = RO(o).gp;
    cel(o, :) = [RO(o).nom, RO(o).classe + " " + RO(o).KV + " KV", fr(g_.moteur, '%.0f'), ...
        fr(g_.pales, '%.0f') + " + " + fr(g_.moyeu, '%.0f'), fr(g_.total, '%.0f') + " (" + fr(g_.ecart, '%+.0f') + ")", ...
        fr(g_.m_ns(iE), '%.0f') + " (" + fr(p.masse.MTOW - g_.m_ns(iE), '%+.0f') + ")", ...
        fr(g_.m_ns_fiche(iE), '%.0f') + " (" + fr(p.masse.MTOW - g_.m_ns_fiche(iE), '%+.0f') + ")", ...
        fr(g_.sans_batt, '%.0f') + " (" + fr(p.masse.max_sans_batt - g_.sans_batt, '%+.0f') + ")", ...
        fr(g_.m_ns(i3), '%.0f') + " (" + fr(p.masse.MTOW - g_.m_ns(i3), '%+.0f') + ")"];
end
tableau_md(fid, sprintf("Groupe propulsif explicite (%s %s g + %s %s g) et masses — budget du cahier : %s g", ...
    p.gp.nom_hel, fr(1000 * p.gp.m_pales, '%.1f'), p.gp.nom_moyeu, fr(1000 * p.gp.m_moyeu, '%.1f'), fr(RO(1).gp.budget, '%.0f')), ...
    ["Option", "Moteur", "Moteur (fiche) [g]", "Hélice + adaptateur [g]", "Groupe propulsif [g] (écart au budget)", ...
     "4S1P, cellules 69 g [g] (marge 800 g)", "4S1P, cellules 70 g [g] (marge)", "Sans batterie [g] (marge 520 g, V1-MAS-02)", "3S1P [g] (marge)"], cel);

% Cas d'erreur humaine (options à hélice unique comparées)
cel = strings(2 * numel(iCote), 10);
ligne = 0;
for o = iCote
    mo = RO(o).mot;
    for k = 1:numel(RO(o).err)
        e_ = RO(o).err(k);
        ligne = ligne + 1;
        cel(ligne, :) = [RO(o).nom, e_.nom, fr(e_.P, '%.0f') + ternaire(isnan(mo.P_fiche), "", " (fiche " + fr(mo.P_fiche, '%.0f') + ")"), ...
            fr(e_.I_b, '%.1f'), fr(e_.I_m, '%.1f'), ...
            fr(e_.I_ref, '%.1f') + " A (" + e_.ref + ") / " + fr(mo.I30, '%.0f') + " A (" + fr(mo.t_I30, '%.0f') + " s)", ...
            fr(100 * e_.r_esc, '%.0f') + " % de " + fr(p.mot.I_esc, '%.0f') + " A ; " + fr(100 * e_.r_cell, '%.0f') + " % de " + fr(p.batt.I_max, '%.0f') + " A", ...
            fr(e_.rpm, '%.0f') + " (" + fr(100 * e_.r_rpm, '%.0f') + " % de " + fr(e_.n_max, '%.0f') + ")", ...
            ternaire(e_.r_mot_cont <= 1, "oui", "non (" + fr(e_.r_mot_cont, '%.2f') + "×)"), ...
            ternaire(e_.survit_10s, "oui", "non")];
    end
end
tableau_md(fid, "Erreur humaine : batterie 4S1P avec le fichier 3S ou sans bridage (batterie pleine 4,15 V/cellule, point fixe, ISA)", ...
    ["Option", "Cas", "P batterie [W]", "I batterie [A]", "I moteur = I ESC [A]", "Moteur : référence continue / courte durée", ...
     "ESC ; cellule P45B", "Régime [tr/min] (régime max APC E)", "Sous la référence continue", "Survit " + p.gp.t_lancer + " s plein gaz"], cel(1:ligne, :));

% Comparaison côte à côte : F, E-1260, E-1100
cri = ["Moteur, hélice 3S / 4S", "THR_MAX 3S / 4S (limite active)", "Groupe propulsif [g] (budget 62 g)", ...
       "Masse 4S1P, cellules 69 g (marge 800 g)", "Masse 4S1P, cellules 70 g (marge)", "Sans batterie (marge 520 g)", ...
       "η 4S 40 / 4S 55 / 3S 55 km/h", "V1-PERF-03 4S 55 km/h [min] (−30 % à −20 %)", "V1-PERF-03, CD0 0,035, −30 % [min]", ...
       "V1-PERF-04 4S 40 km/h [min]", "V1-PERF-05 3S 55 km/h [min]", "T/W ISA 3S / 4S", "T/W jour chaud 3S / 4S", ...
       "P max 3S / 4S [W] (V1-PROP-02 : 150-200 W)", "Erreur : 4S avec le fichier 3S", "Erreur : 4S sans bridage", "Exigences à MOD"]';
cel = strings(numel(cri), numel(iCote));
for j = 1:numel(iCote)
    r = RO(iCote(j));  g_ = r.gp;
    act = ["", ""];
    for b = 1:numel(p.batt.ns)
        if isfield(r, 'bridage') && numel(r.bridage) >= b && ~isempty(r.bridage(b).thr)
            act(b) = r.bridage(b).actif;
        end
    end
    tb = @(b, v) fr(r.t(b, v, 2), '%.0f') + " à " + fr(r.t(b, v, 1), '%.0f');
    er = @(k) fr(r.err(k).P, '%.0f') + " W, " + fr(r.err(k).I_m, '%.1f') + " A moteur (" + ...
        fr(r.err(k).r_mot_cont, '%.2f') + "× la référence continue, " + fr(r.err(k).r_mot_30s, '%.2f') + "× la limite " + ...
        fr(r.mot.t_I30, '%.0f') + " s ; survit " + p.gp.t_lancer + " s : " + ...
        ternaire(r.err(k).survit_10s, "oui", "non") + ")";
    % Exigences qui demanderaient une MOD (CD0 nominal, −30 %)
    % V1-PROP-02 porte sur la puissance max du moteur : jugée sur le max 3S/4S ;
    % un P max 3S sous 150 W seul est signalé à part (lecture à trancher)
    PROP_hors = max(r.P_max) < min(p.prop.P_max_req) - tolP || max(r.P_max) > max(p.prop.P_max_req) + tolP;
    mods = ["V1-MAS-01", "V1-MAS-01 (avec cellules à 70 g)", "V1-MAS-02", "V1-PROP-02", ...
            "V1-PROP-02 si lue batterie par batterie (P max 3S < 150 W)", "V1-PERF-03", ...
            "V1-PERF-04 (souhaitable)", "V1-PERF-05", "V1-PERF-08"];
    mods = mods([g_.m_ns(iE) > p.masse.MTOW, g_.m_ns(iE) <= p.masse.MTOW && g_.m_ns_fiche(iE) > p.masse.MTOW, ...
                 g_.sans_batt > p.masse.max_sans_batt, PROP_hors, ...
                 ~PROP_hors && r.P_max(i3) < min(p.prop.P_max_req) - tolP, ...
                 r.t(iE, iV55, 2) < p.req.t_4S_cr, r.t(iE, iV40, 2) < p.req.t_4S_end, r.t(i3, iV55, 2) < p.req.t_3S_cr, ...
                 min([r.TW, r.TW_chaud]) < p.req.TsurW_stat]);
    cel(:, j) = [r.classe + " " + r.KV + " KV, " + sprintf('%gx%g', r.hel{i3}) + " / " + sprintf('%gx%g', r.hel{iE}), ...
        fr(r.thr(i3), '%.2f') + " (" + act(i3) + ") / " + fr(r.thr(iE), '%.2f') + " (" + act(iE) + ")", ...
        fr(g_.total, '%.0f') + " (" + fr(g_.ecart, '%+.0f') + ")", ...
        fr(g_.m_ns(iE), '%.0f') + " (" + fr(p.masse.MTOW - g_.m_ns(iE), '%+.0f') + ")", ...
        fr(g_.m_ns_fiche(iE), '%.0f') + " (" + fr(p.masse.MTOW - g_.m_ns_fiche(iE), '%+.0f') + ")", ...
        fr(g_.sans_batt, '%.0f') + " (" + fr(p.masse.max_sans_batt - g_.sans_batt, '%+.0f') + ")", ...
        fr(r.eta(iE, iV40), '%.3f') + " / " + fr(r.eta(iE, iV55), '%.3f') + " / " + fr(r.eta(i3, iV55), '%.3f'), ...
        tb(iE, iV55), fr(r.t_W(iE, iV55, 2), '%.0f'), tb(iE, iV40), tb(i3, iV55), ...
        fr(r.TW(i3), '%.2f') + " / " + fr(r.TW(iE), '%.2f'), fr(r.TW_chaud(i3), '%.2f') + " / " + fr(r.TW_chaud(iE), '%.2f'), ...
        fr(r.P_max(i3), '%.0f') + " / " + fr(r.P_max(iE), '%.0f'), er(1), er(2), ...
        ternaire(isempty(mods), "aucune", strjoin(mods, ", "))]';
end
tableau_md(fid, "Comparaison côte à côte F / E-1260 / E-1100 (ISA, CD0 0,030, masse avec groupe propulsif réel, cellules 69 g)", ...
    ["Critère", [RO(iCote).nom]], [cri, cel]);

% Option retenue F, option banc G, F-8x5 (seule 8 pouces repliable propulsive trouvée) et C
[~, iG] = ismember([p.choix.ref, p.choix.banc, "F-8x5", "C"], [RO.nom]);
cel = strings(numel(iG), 11);
for j = 1:numel(iG)
    r = RO(iG(j));
    dt = squeeze(r.det(iE, iV55, :));
    cel(j, :) = [r.nom, r.classe + " " + r.KV + " KV, " + sprintf('%gx%g', r.hel{i3}) + " / " + sprintf('%gx%g', r.hel{iE}), ...
        fr(r.thr(i3), '%.2f') + " / " + fr(r.thr(iE), '%.2f'), ...
        fr(r.eta(iE, iV55), '%.3f') + " (hélice " + fr(dt(1), '%.3f') + ")", fr(r.d(iE, iV55), '%.2f') + " ; " + fr(r.rpm(iE, iV55), '%.0f') + " tr/min", ...
        fr(r.t(iE, iV55, 2), '%.1f') + " à " + fr(r.t(iE, iV55, 1), '%.1f'), fr(r.t_W(iE, iV55, 2), '%.1f'), ...
        fr(r.t(iE, iV40, 2), '%.0f') + " à " + fr(r.t(iE, iV40, 1), '%.0f'), fr(r.t(i3, iV55, 2), '%.0f') + " à " + fr(r.t(i3, iV55, 1), '%.0f'), ...
        fr(r.TW_chaud(i3), '%.2f') + " / " + fr(r.TW_chaud(iE), '%.2f'), fr(r.P_max(i3), '%.0f') + " / " + fr(r.P_max(iE), '%.0f')];
end
tableau_md(fid, "Option retenue, option banc et variantes (ISA, CD0 0,030, masse avec groupe propulsif réel)", ...
    ["Option", "Moteur, hélice 3S / 4S", "THR_MAX 3S / 4S", "η 4S 55 km/h", "d croisière 4S ; régime", "V1-PERF-03 [min]", ...
     "V1-PERF-03, CD0 0,035, −30 % [min]", "V1-PERF-04 [min]", "V1-PERF-05 [min]", "T/W jour chaud 3S / 4S", "P max 3S / 4S [W]"], cel);

% Option banc G : erreurs de fichier et de montage d'hélice
mG = rGb.mot;
eG1 = rGb.err(1);
cel = [ ...
    "4S1P avec le fichier 3S (THR_MAX " + fr(rGb.thr(i3), '%.2f') + "), " + sprintf('%gx%g', rGb.hel{iE}) + " montée", ...
        fr(eG1.P, '%.0f'), fr(eG1.I_m, '%.1f') + " (" + fr(eG1.r_mot_cont, '%.2f') + "× continu ; " + fr(eG1.r_mot_30s, '%.2f') + "× 30 s)", ...
        fr(eG1.rpm, '%.0f'), "—", ternaire(eG1.survit_10s, "oui", "non");
    "4S1P avec le fichier 4S (THR_MAX " + fr(rGb.thr(iE), '%.2f') + "), " + sprintf('%gx%g', rGb.hel{i3}) + " restée montée", ...
        fr(eGb.P_elec, '%.0f'), fr(eGb.I_mot, '%.1f') + " (" + fr(eGb.I_mot / mG.I_cont, '%.2f') + "× continu ; " + fr(eGb.I_mot / mG.I30, '%.2f') + "× 30 s)", ...
        fr(eGb.rpm, '%.0f'), "—", ternaire(eGb.I_mot <= mG.I30 && eGb.P_elec <= mG.P_fiche && mG.t_I30 >= p.gp.t_lancer, "oui", "non");
    "3S1P avec le fichier 3S, " + sprintf('%gx%g', rGb.hel{iE}) + " restée montée", "—", "—", "—", ...
        fr(TW_Gc, '%.2f') + ternaire(TW_Gc < p.req.TsurW_stat, " (< 0,5 : V1-PERF-08 non tenue)", ""), "—"];
tableau_md(fid, "Option banc " + rGb.nom + " : erreurs de fichier et de montage d'hélice (4S : batterie pleine, point fixe, ISA ; 3S : tension nominale, jour chaud)", ...
    ["Cas", "P batterie [W]", "I moteur [A]", "Régime [tr/min]", "T/W au lancer, jour chaud", "Survit " + p.gp.t_lancer + " s plein gaz"], cel);

% Groupe propulsif : référence vérifiée et alternatives propulsives
nd = @(x) ternaire(isfinite(x), fr(x, '%.1f'), "non publiée");
cel = strings(nAlt + 1, 6);
cel(1, :) = [p.gp.nom_hel + " + " + p.gp.nom_moyeu + " (retenu)", "rigide", "gauche (propulsive)", ...
             fr(1000 * p.gp.m_pales, '%.1f'), fr(1000 * p.gp.m_moyeu, '%.1f'), fr(gF.total, '%.1f') + " (" + fr(gF.ecart, '%+.1f') + " / budget)"];
for k = 1:nAlt
    a_ = p.gp.alt(k);
    tot = ternaire(isfinite(gpAlt(k, 3)), fr(gpAlt(k, 3), '%.1f'), ...
          ternaire(isfinite(gpAlt_min(k)), "≥ " + fr(gpAlt_min(k), '%.1f') + " (moteur + pales, sans " + ternaire(a_.repliable, "cône", "adaptateur") + ")", "non calculable"));
    cel(k + 1, :) = [a_.nom + " (" + sprintf('%gx%g', a_.hel) + ")", ternaire(a_.repliable, "repliable", "rigide"), a_.rotation, ...
                     nd(gpAlt(k, 1)), nd(gpAlt(k, 2)), tot];
end
tableau_md(fid, "Groupe propulsif : référence retenue et groupes examinés (masses de fiche ; moteur " + fr(1000 * rF.mot.m, '%.0f') + " g)", ...
    ["Hélice + moyeu", "Type", "Rotation", "Hélice / pales [g]", "Adaptateur / moyeu-cône [g]", "Moteur + hélice + moyeu [g]"], cel);
tableau_md(fid, "Hélices APC et " + p.gp.nom_moyeu + " : montage et régime", ...
    ["Hélice", "Épaisseur de moyeu [mm]", "Réserve sous les " + fr(1000 * p.gp.e_max, '%.1f') + " mm de l'adaptateur [mm]", "Régime max APC E [tr/min]", "Rayon du disque sous l'axe [mm]"], ...
    ["APC 8x6EP", fr(1000 * p.gp.e_moyeu(1), '%.1f'), fr(1000 * e_libre(1), '%.1f'), fr(n_max_h(1), '%.0f'), fr(1000 * R_disq, '%.1f');
     "APC 7x6EP", fr(1000 * p.gp.e_moyeu(2), '%.1f'), fr(1000 * e_libre(2), '%.1f'), fr(n_max_h(2), '%.0f'), fr(1000 * D_hel(2) * p.const.in / 2, '%.1f')]);
cel = [[bh.article]', string([bh.qte]'), fr([bh.prix_usd]', '%.2f'), fr(cout_hel', '%.2f')];
cel = [cel; "**Total**", "", "", fr(sum(cout_hel), '%.2f')];
tableau_md(fid, sprintf("Budget hélices (MOD-03 : lot de 10) — prix catalogue en dollars US, hors port et douane ; poste du cahier : %d €", p.bud.hel_cahier_eur), ...
    ["Article", "Quantité", "Prix unitaire [$]", "Total [$]"], cel);

% Plan d'allègement et budget réaffecté
T_ = B.postes;
cel = [T_.Poste, T_.Groupe, fr(T_.Cahier_g, '%.1f'), fr(T_.Reaffecte_g, '%.1f'), fr(T_.Ecart_g, '%+.1f'), T_.Piece];
cel = [cel; "**Structure (cahier)**", "", fr(sum(T_.Cahier_g(T_.Groupe == "structure")), '%.0f'), fr(B.structure, '%.0f'), "", "";
       "**Systèmes**", "", fr(sum(T_.Cahier_g(T_.Groupe ~= "structure")), '%.0f'), fr(B.systemes, '%.1f'), fr(B.systemes - sum(T_.Cahier_g(T_.Groupe ~= "structure")), '%+.1f'), "";
       "**Sans batterie**", "", fr(bm.sans_batt, '%.0f'), fr(B.sans_batt, '%.1f'), fr(B.sans_batt - bm.sans_batt, '%+.1f'), "V1-MAS-02 : ≤ 520 g";
       "**Total 4S1P, cellules 69 g**", "", fr(bm.total_4S, '%.0f'), fr(B.total_4S, '%.1f'), fr(B.total_4S - bm.total_4S, '%+.1f'), "V1-MAS-01 : ≤ 800 g";
       "**Total 4S1P, cellules 70 g**", "", fr(bm.total_4S_fiche, '%.0f'), fr(B.total_4S_fiche, '%.1f'), fr(B.total_4S_fiche - bm.total_4S_fiche, '%+.1f'), "V1-MAS-01 : ≤ 800 g";
       "**Total 3S1P, cellules 69 g**", "", fr(bm.total_3S, '%.0f'), fr(B.total_3S, '%.1f'), fr(B.total_3S - bm.total_3S, '%+.1f'), ""];
tableau_md(fid, sprintf("Budget de masse réaffecté — option %s, plan d'allègement (gain %s g sur les postes remplacés)", rF.nom, fr(B.gain, '%.1f')), ...
    ["Poste", "Groupe", "Cahier [g]", "Réaffecté [g]", "Écart [g]", "Pièce"], cel);
tableau_md(fid, "Structure cible qui découle du budget réaffecté", ...
    ["Cas", "Structure max (4S1P ≤ 800 g, cellules 70 g) [g]", "Structure max (V1-MAS-02) [g]", "V1-MAS-03 [g]", "Structure cible [g]", ...
     "4S1P cellules 70 g à la cible [g] (marge)", "Sans batterie à la cible [g] (marge)", "Cible sous les 320 g de V1-MAS-03"], ...
    [ligne_cible(B, "plan (FC " + fr(sum(p.allg.m{1}), '%.1f') + " g)", p); ligne_cible(B_h, "plan pessimiste (FC " + fr(sum(p.allg.m_haut{1}), '%.1f') + " g)", p);
     ligne_cible(B_c, "repli : FC du cahier (" + fr(sum(pC.allg.m{1}), '%.0f') + " g), ESC et GPS du plan", p)]);
cel = [p.av.uart(:, 1), p.av.uart(:, 2), p.av.uart(:, 3)];
tableau_md(fid, "Affectation des UART — SpeedyBee F405 WING MINI, cible ArduPilot SpeedyBeeF405WING", ["Port", "Usage", "Rôle"], cel);
tableau_md(fid, "BEC 5 V du contrôleur de vol face au Pi Zero 2 W et à la caméra (courants typiques)", ...
    ["Charge", "Courant [A]", "BEC FC " + fr(p.av.I_bec_fc, '%.1f') + " A continu / " + fr(p.av.I_bec_fc_pk, '%.1f') + " A crête"], ...
    ["FC + GPS + récepteur (budget V1-AV-05 − V1-PL-01)", fr(I_rest, '%.2f'), "";
     "Pi Zero 2 W + caméra, typique", fr(I_pl, '%.2f'), "";
     "**Tout sur le BEC FC, typique**", fr(I_typ, '%.2f'), fr(100 * I_typ / p.av.I_bec_fc, '%.0f') + " % du continu";
     "**Pi alimenté à 2 A (recommandation Raspberry Pi) + reste**", fr(I_reco, '%.2f'), fr(100 * I_reco / p.av.I_bec_fc, '%.0f') + " % du continu, " + fr(100 * I_reco / p.av.I_bec_fc_pk, '%.0f') + " % de la crête"]);

tableau_md(fid, "Réserve et RTL", ["Fraction utilisable", "Réserve", "Capacité nominale restante en fin de mission", "RTL du cahier"], ...
    [fr(p.batt.f_utile, '%.2f'), fr(p.batt.reserve, '%.2f'), fr(100 * frac_fin, '%.0f') + " %", "30 %"]);
fclose(fid);

save(fullfile(dRes, 'phase3.mat'), 'p', 'atm', 'bm', 'est', 'PR', 'CC', 'DP', 'opt', 'toutes', ...
     'AU', 'W', 'SE', 'ver', 'tab_aut', 'V_max_palier', 'RO', 'CLA', 'ref05', 'opts', 'toutE', ...
     'tabE3', 'tabE4', 'tabE23', 'tabE24', 'rang_kJT', 'eta_kJT', 'frac_fin', ...
     'verF', 'B', 'B_h', 'B_c', 'Vz_F', 'gpAlt', 'gpAlt_min', 'eGb', 'TW_Gc', 'n_max_h', 'e_libre', 'R_disq', ...
     'I_pl', 'P_pl', 'I_typ', 'I_reco', 'cout_hel');
fprintf('\nTerminé : figures dans %s, résultats dans %s\n', dFig, dRes);

%% Fonctions locales
function l = ligne_cible(B, cas, p)
% Ligne du tableau « structure cible » pour un budget réaffecté B
l = [cas, fr(B.struct_max_4S, '%.1f'), fr(B.struct_max_sb, '%.1f'), fr(p.masse.max_struct, '%.0f'), string(B.struct_cible), ...
     fr(B.cible_4S_fiche, '%.1f') + " (" + fr(p.masse.MTOW - B.cible_4S_fiche, '%+.1f') + ")", ...
     fr(B.cible_sans_batt, '%.1f') + " (" + fr(p.masse.max_sans_batt - B.cible_sans_batt, '%+.1f') + ")", ternaire(B.baisse_mas03, "oui", "non")];
end

function [op, T3, T4] = variante_legere(classe, nom, bridage_permis, p, m_ns, rhoI, rhoH)
% Variante moteur léger : pour chaque batterie, hélice de meilleur η à 55 km/h
% (meilleure_helice.m) ; même KV en 3S et en 4S, celui qui maximise le η en 4S
% (V1-PERF-03). Sans bridage permis : THR_MAX = 1 et P dans la fenêtre P_plage.
% Renvoie une structure vide (mêmes champs que p.opt) si aucun KV ne convient.
c = p.(classe);
P_lim = max(c.P_plage);
T3 = meilleure_helice(classe, 3, m_ns(1), P_lim, p, rhoI, rhoH, p.aero);
T4 = meilleure_helice(classe, 4, m_ns(2), P_lim, p, rhoI, rhoH, p.aero);
ok3 = T3.Valide;  ok4 = T4.Valide;
if ~bridage_permis
    ok3 = ok3 & T3.THR_MAX >= 1 & T3.P_max_W >= min(c.P_plage);
    ok4 = ok4 & T4.THR_MAX >= 1 & T4.P_max_W >= min(c.P_plage);
end
T3.Valide = ok3;  T4.Valide = ok4;
KVs = intersect(T3.KV(ok3), T4.KV(ok4));
op = p.opt([]);
if isempty(KVs)
    return
end
eta4 = arrayfun(@(k) max(T4.eta_55(ok4 & T4.KV == k)), KVs);
[~, iK] = max(eta4);
KV = KVs(iK);
i3 = find(ok3 & T3.KV == KV);  [~, j] = max(T3.eta_55(i3));  i3 = i3(j);
i4 = find(ok4 & T4.KV == KV);  [~, j] = max(T4.eta_55(i4));  i4 = i4(j);
thr = @(t) ternaire(t < 1, NaN, 1);                  % NaN : recalculé par limite_gaz.m
op = struct('nom', nom, 'classe', classe, 'KV', KV, 'hel3S', T3.hel(i3, :), 'hel4S', T4.hel(i4, :), ...
            'thr3S', thr(T3.THR_MAX(i3)), 'thr4S', thr(T4.THR_MAX(i4)), 'P_lim', P_lim);
end

function [PW, actif, detail] = pire_cas(WS, atm, p, aero)
% P/W requis à une W/S donnée : maximum des contraintes sur les cas atmosphériques
detail = zeros(1, 4);
for j = 1:numel(atm)
    cc = contraintes_PW(WS, atm(j).rho, p, aero);
    d = [cc.montee.PW, cc.virage.PW, cc.croisiere.PW, cc.statique.PW_nominal];
    detail = max(detail, d);
end
[PW, k] = max(detail);
actif = cc.noms(k);
end

function s = fr(x, fmt)
% Nombre(s) formaté(s) avec la virgule décimale française
s = strrep(compose(fmt, x), '.', ',');
s = string(s);
end

function s = signalements(opt)
% Critères souples non tenus par chaque option moteur
msg = ["P batterie pleine < 150 W", "vitesse de pas < 1,5·V_cr"];
s = strings(height(opt), 1);
for i = 1:height(opt)
    k = [~opt.P_dans_plage(i), ~opt.Pas_ok(i)];
    if any(k)
        s(i) = strjoin(msg(k), ", ");
    else
        s(i) = "—";
    end
end
end

function s = oui(cond)
s = ternaire(cond, "oui", "NON");
end

function s = oui3(cond_pire, cond_favorable)
% Conformité sur une bande −30 / −20 % : oui, limite (seulement à −20 %), non
if cond_pire
    s = "oui";
elseif cond_favorable
    s = "limite";
else
    s = "NON";
end
end

function s = ternaire(cond, a, b)
if cond
    s = a;
else
    s = b;
end
end
