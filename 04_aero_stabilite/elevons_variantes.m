%ELEVONS_VARIANTES  Phase 4 — élevons agrandis : estimation sans manip xflr5 (15/10/2026).
%
%   Script autonome, exécuté d'un bloc après stabilite.m (relit resultats/phase4.mat).
%   Décision de l'utilisateur du 15/10/2026 : le critère « 0 à 6° vers le haut de 35 à
%   55 km/h + 10° de réserve » (infaisable par construction) est remplacé par deux critères,
%   hors cahier (pas de MOD) :
%     croisière : δ_trim de 40 à 55 km/h entre −10 et 0°, 3S1P et 4S1P, MS 8, 9 et 10 % ;
%     autorité  : équilibre au CLmax de l'aile, MS 10 %, 3S1P et 4S1P, au plus 20° vers le haut.
%   Variantes (p.elv) : élevons des T2 (25 % de corde), 30 et 35 % de corde sur la même
%   envergure, 35 % prolongés vers l'emplanture de 10 % de la demi-envergure.
%     §1 Données du §11 ; Weissinger recalé sur la VLM de xflr5
%     §2 Variantes : efficacité Cm_δ (VLM, bandes, complet)
%     §3 Ordres de grandeur du raisonnement de l'utilisateur, recalculés
%     §4 Croisière (et MS 7 % pour le cas « aucune variante ne passe »)
%     §5 Autorité : CLmax équilibré par la méthode de la bande critique
%     §6 Synthèse, figures, tableaux
%   ESTIMATION, HORS SKILL : réponse VLM des élevons des T2 mise à l'échelle par la théorie
%   des profils minces (volet_mince) ; prolongement par Weissinger recalé ; polaires XFoil de
%   la charnière des T2 empruntées, efficacité visqueuse η supposée la même à braquage égal
%   (variante_elevons). Le modèle du verdict reste p.stab.mode_verdict.
%   Sorties : resultats/tableaux_variantes.md, figures/fig09_*, fig10_*, resultats/variantes.mat

clear; close all;
racine = fileparts(mfilename('fullpath'));
rac3   = fullfile(fileparts(racine), '03_predimensionnement');
addpath(fullfile(racine, 'fonctions'), rac3, fullfile(rac3, 'fonctions'));
dFig = fullfile(racine, 'figures');
dRes = fullfile(racine, 'resultats');

p = params_v1();
c = p.const;
C = ["#2a78d6" "#eb6834" "#1baf7a" "#eda100" "#e87ba4" "#008300" "#6250d6" "#e34948"];
GRIS = "#52514e";
fprintf('\n===== PHASE 4 — ÉLEVONS AGRANDIS (estimation, critères du 15/10/2026) =====\n');

%% §1 Données du §11 et Weissinger recalé sur la VLM de xflr5
S = load(fullfile(dRes, 'phase4.mat'), 'DE', 'atm', 'mTot', 'xref', 'cE', 'vrG', 'xNPv11', 'xNPl11', ...
         'Cm0v11', 'ok04', 'vr04', 'dT11', 'Vg', 'CLg', 'cfg', 'modes');
DE = S.DE;
assert(isfield(DE, 'y') && isfield(DE.T.F, 'Clmax'), 'phase4.mat antérieur au 15/10/2026 : relancer stabilite.m');
gE = geometrie_aile(p, p.geo4.fleche_BA, S.cE);
rho = S.atm(1).rho;
mg = S.mTot(:) * c.g;                                                   % N : 3S1P ; 4S1P
q1 = rho * p.geo.S / 2;                                                 % V = sqrt(mg/(q1·CL)), comme au §11 (ISA)
vrG = S.vrG;  nVr = numel(vrG);
pl = @(v) plage(v, p.stab.pas_vr);                                     % vrillages en plages continues
ok04 = S.ok04(:).';
bB = -p.geo.b/2 + [0; cumsum(DE.wy)];                                   % bords des bandes du §11
Wg = weissinger(bB, gE.cf, gE.xBAf, S.xref, gE.S, gE.MAC);
xNP_W = S.xref - gE.MAC * Wg.Cma / Wg.CLa;
xc4 = gE.xBAf(abs(DE.y)) + DE.c / 4;
CmL_T2 = -sum(DE.A(:, 4) .* DE.c .* DE.wy .* (xc4 - S.xref)) / (gE.S * gE.MAC);   % moment de portance des élevons des T2 [/°], CL constant
[tau0, m0] = volet_mince(p.geo4.charniere);
assert(abs(tau0 - DE.tau) < 1e-12 && abs(m0 - DE.dCm_dd) < 1e-15, 'volet des T2 incohérent avec p.geo4.charniere');
E0 = Wg.a_CL(tau0 * DE.we * pi/180);
kappa = CmL_T2 / E0.Cm;
iTr = DE.we > 0 & DE.we < 1;                                           % bandes de transition (panneau de 4 mm de xflr5)
eForme = max(abs(DE.A(~iTr, 4) - kappa * E0.Cl(~iTr))) / max(abs(DE.A(:, 4)));
fprintf(['§1 Weissinger (%d bandes, aile plane sans winglets) : CLα %.3f /rad ; x_NP %.1f mm (VLM xflr5 %.1f à %.1f mm)\n' ...
         '  élevons des T2 à CL constant : moment de portance %.5f /° (xflr5, bandes) contre %.5f (Weissinger) : κ = %.3f ; ' ...
         'écart de forme des Cl recalés hors transition : %.0f %% du maximum\n'], numel(Wg.y), Wg.CLa, 1000*xNP_W, 1000*min(S.xNPl11), ...
        1000*max(S.xNPl11), CmL_T2, E0.Cm, kappa, 100*eForme);

%% §2 Variantes : efficacité des élevons
nVa = numel(p.elv.nom);
DV = cell(nVa, 1);
linV = zeros(nVa, 7);                                                   % rt, rm, portance, section, total [/°], demi-envergure ajoutée [m]
for k = 1:nVa
    [var, info] = variante_elevons(DE, p.elv.charniere(k), p.geo4.charniere, p.elv.y0(k), p.geo4.y_elevon(1), bB, Wg, kappa);
    DV{k} = DE;  DV{k}.var = var;
    CmL = var.rt * CmL_T2 + var.Cmext;
    CmS = var.rm * DE.Ksec + var.Ksec_ext;
    linV(k, :) = [var.rt, var.rm, CmL, CmS, CmL + CmS, sum(info.dwe .* DE.wy) / 2, var.Ksec_ext];
end
MSc = unique([p.stab.MS_bas, p.stab.MS_crois]);  nMS = numel(MSc);    % MS 7 % : cas « aucune variante ne passe »
cfg = [repmat((1:2).', nMS, 1), repelem((1:nMS).', 2)];                % [batterie, indice de MS]
nC = height(cfg);
labC = compose("%dS1P, MS %.0f %%", 2 + cfg(:, 1), 100 * MSc(cfg(:, 2)).');
modes = ["vlm" "bandes" "complet"];  nMo = numel(modes);
iCo = find(modes == p.stab.mode_verdict);  iVl = find(modes == "vlm");
xNPm = @(v, mo) ternaire(mo == iVl, S.xNPl11(v), S.xNPv11(v));       % foyer du même modèle à δ = 0
dxM = @(v, ms, mo) (xNPm(v, mo) - ms * gE.MAC - S.xref) / gE.MAC;
% Point de référence : 45 km/h, 4S1P, MS nominale, vrillage des figures
v5 = find(abs(vrG - p.elv.vr_fig) < 1e-9);
assert(isscalar(v5), 'vrillage des figures hors de la grille');
Vr = p.stab.V_trim_ref;  CLr = mg(2) / (q1 * Vr^2);
effV = NaN(nVa, nMo + 3);                                              % Cm_δ par modèle, δ_trim, η_α, η_m (modèle du verdict)
for k = 1:nVa
    for mo = 1:nMo
        dx = dxM(v5, p.stab.MS_nom, mo);
        dg = delta_equilibre(CLr, Vr, vrG(v5), dx, modes(mo), DV{k}, 0, p.stab.d_lim);
        Rp = cm_elevons(dg + 0.5, CLr, Vr, vrG(v5), modes(mo), DV{k});
        Rm = cm_elevons(dg - 0.5, CLr, Vr, vrG(v5), modes(mo), DV{k});
        effV(k, mo) = Rp.Cm - Rm.Cm;
        if mo == iCo
            R = cm_elevons(dg, CLr, Vr, vrG(v5), modes(mo), DV{k});
            effV(k, nMo + (1:3)) = [dg, R.eta_a, R.eta_m];
        end
    end
end
gainV = effV(:, 1:nMo) ./ effV(1, 1:nMo) - 1;
fprintf('§2 Cm_δ à %.0f km/h, 4S1P, MS %.0f %%, vrillage %.0f° [/°] (VLM / bandes / complet ; gain sur les élevons des T2) :\n', ...
        3.6*Vr, 100*p.stab.MS_nom, vrG(v5));
for k = 1:nVa
    fprintf('  %-16s charnière %.2f, dès y = %.3f m : τ ×%.3f, moment de section ×%.3f ; %+.5f / %+.5f / %+.5f (%+.0f / %+.0f / %+.0f %%) ; δ_trim %+.1f°\n', ...
            p.elv.nom(k), p.elv.charniere(k), p.elv.y0(k), linV(k, 1), linV(k, 2), effV(k, 1:nMo), 100*gainV(k, :), effV(k, nMo + 1));
end

%% §3 Ordres de grandeur du raisonnement de l'utilisateur, recalculés
% a) Ancien critère : amplitude de δ_trim de 35 à 55 km/h ≈ MS·ΔCL/|Cm_δ| (4S1P, MS 10 %, vrillage des figures)
S11 = struct('cfg', S.cfg, 'MS', p.stab.MS_vol1);
ic11 = find(S11.cfg(:, 1) == 2 & S11.MS(S11.cfg(:, 2)).' == max(S11.MS));
amp11 = range(squeeze(S.dT11(v5, ic11, :, iCo)));
dx10 = dxM(v5, max(S11.MS), iCo);
iv45 = find(abs(S.Vg - Vr) < 1e-9);
dg45 = S.dT11(v5, ic11, iv45, iCo);
Rp = cm_elevons(dg45 + 0.5, S.CLg(2, iv45), Vr, vrG(v5), modes(iCo), DE);
Rm = cm_elevons(dg45 - 0.5, S.CLg(2, iv45), Vr, vrG(v5), modes(iCo), DE);
Cmd10 = Rp.Cm - Rm.Cm;
ampEst = max(S11.MS) * (S.CLg(2, 1) - S.CLg(2, end)) / abs(Cmd10);
% b) Équilibre à CL = p.aero.CLmax (hypothèse de la phase 3), 4S1P, MS 10 %, élevons des T2
V08 = sqrt(mg(2) / (q1 * p.aero.CLmax));
R0 = cm_elevons(0, p.aero.CLmax, V08, vrG(v5), modes(iCo), DE);
dCm08 = -(R0.Cm + p.aero.CLmax * dx10);
d08m = zeros(1, nMo);
for mo = 1:nMo
    d08m(mo) = delta_equilibre(p.aero.CLmax, V08, vrG(v5), dxM(v5, max(S11.MS), mo), modes(mo), DE, 0, p.stab.d_lim);
end
% c) Tolérance de centrage : 1 % de MS en mm, et ±3 mm en % de MAC
mm1pc = 10 * gE.MAC;  pc3mm = 0.3 / gE.MAC;
fprintf(['§3 Ancien critère (4S1P, MS 10 %%, %.0f°) : amplitude de 35 à 55 km/h %.1f° ; MS·ΔCL/|Cm_δ| = %.2f × %.3f / %.4f = %.1f°\n' ...
         '  CL = %.2f (hypothèse phase 3, %.1f km/h) : ΔCm cabreur requis %.4f ; δ_trim VLM / bandes / complet %+.1f / %+.1f / %+.1f°\n' ...
         '  1 %% de MS = %.2f mm ; ±3 mm = ±%.2f %% ; profils minces, élevons à 35 %% : τ %+.1f %%, moment de section %+.1f %%\n'], ...
        vrG(v5), amp11, max(S11.MS), S.CLg(2, 1) - S.CLg(2, end), abs(Cmd10), ampEst, p.aero.CLmax, 3.6*V08, dCm08, d08m, ...
        mm1pc, pc3mm, 100*(linV(end, 1) - 1), 100*(linV(end, 2) - 1));

%% §4 Croisière : δ_trim de 40 à 55 km/h dans p.stab.d_crois
nV = round(diff(p.stab.V_crois) / p.stab.pas_V_trim) + 1;
Vc = linspace(p.stab.V_crois(1), p.stab.V_crois(2), nV);
CLc = mg ./ (q1 * Vc.^2);                                               % 2 × nV
[okT, iTab] = ismembertol(p.stab.vr_tableau, vrG, 1e-9);
assert(all(okT), 'vrillages des tableaux hors de la grille');
calc = false(nVr, nMo);  calc(:, iCo) = true;  calc(iTab, :) = true;   % VLM et bandes aux vrillages des tableaux seulement
dC = NaN(nVa, nVr, nC, nV, nMo);  horsC = false(nVa, nVr, nC, nV, nMo);  extC = false(nVa, nVr, nC, nV);
for k = 1:nVa
    for v = 1:nVr
        for ic = 1:nC
            m = cfg(ic, 1);
            for mo = find(calc(v, :))
                d0 = 0;
                for iv = 1:nV
                    [dg, R] = delta_equilibre(CLc(m, iv), Vc(iv), vrG(v), dxM(v, MSc(cfg(ic, 2)), mo), modes(mo), DV{k}, d0, p.stab.d_lim);
                    dC(k, v, ic, iv, mo) = dg;  horsC(k, v, ic, iv, mo) = R.hors;
                    if ~isnan(dg)
                        d0 = round(dg);
                        if mo == iCo, extC(k, v, ic, iv) = R.ext; end
                    end
                end
            end
        end
    end
end
dW = p.stab.d_crois;
dMinC = reshape(min(dC, [], 4, 'includenan'), nVa, nVr, nC, nMo);
dMaxC = reshape(max(dC, [], 4, 'includenan'), nVa, nVr, nC, nMo);
okCC = dMinC >= dW(1) & dMaxC <= dW(2);                                % NaN : non tenu
dansMS = @(liste) ismembertol(MSc(cfg(:, 2)), liste, 1e-9);
iCr = dansMS(p.stab.MS_crois);  iBas = dansMS(p.stab.MS_bas);
okCr    = ok04 & all(okCC(:, :, iCr, iCo), 3);                         % nVa × nVr
okCrBas = ok04 & all(okCC(:, :, iBas, iCo), 3);
fenC = cat(3, min(dMinC(:, :, iCr, iCo), [], 3), max(dMaxC(:, :, iCr, iCo), [], 3));   % fenêtre requise, MS 8–10 %
fenB = cat(3, min(dMinC(:, :, iBas, iCo), [], 3), max(dMaxC(:, :, iBas, iCo), [], 3)); % idem, MS 7–9 %
nExtC = reshape(sum(extC(:, :, iCr, :), [3 4]), nVa, nVr);
fprintf('§4 Croisière (%.0f à %.0f km/h, δ_trim de %+.0f à %+.0f°, %s) : vrillages tenant les %d configurations à MS %s %% (MOD-04 comprise)\n', ...
        3.6*Vc(1), 3.6*Vc(end), dW, p.stab.mode_verdict, nnz(iCr), strjoin(compose('%.0f', 100*p.stab.MS_crois), '/'));
for k = 1:nVa
    fprintf('  %-16s %s ; fenêtre requise au vrillage %.0f° : %+.1f à %+.1f° ; MS 7–9 %% : %s\n', p.elv.nom(k), pl(vrG(okCr(k, :))), ...
            vrG(v5), fenC(k, v5, 1), fenC(k, v5, 2), pl(vrG(okCrBas(k, :))));
end

%% §5 Autorité : CLmax équilibré (bande critique), au plus p.stab.d_autorite vers le haut
MSa = unique([p.stab.MS_bas(end), p.stab.MS_autorite]);  nMa = numel(MSa);
iA10 = find(abs(MSa - p.stab.MS_autorite) < 1e-9);  iA9 = find(abs(MSa - p.stab.MS_bas(end)) < 1e-9);
dLa = [p.stab.d_autorite, p.stab.d_lim(2)];
CLa = NaN(nVa, nVr, 2, nMa);  dAa = CLa;  VAa = CLa;  yAa = CLa;  mAa = CLa;  d08 = CLa;  m08 = CLa;
causeA = strings(nVa, nVr, 2, nMa);  borneA = false(nVa, nVr, 2, nMa);  extA = borneA;  ext08 = borneA;
V08m = sqrt(mg / (q1 * p.aero.CLmax));
for k = 1:nVa
    for v = 1:nVr
        for m = 1:2
            for ia = 1:nMa
                dx = dxM(v, MSa(ia), iCo);
                A = clmax_equilibre(mg(m), q1, vrG(v), dx, modes(iCo), DV{k}, p.stab.CL_autorite, dLa, p.stab.n_dicho);
                if A.cause == "polaires" && min(A.R.marge) < p.stab.tol_decrochage, A.cause = "bande"; end
                CLa(k, v, m, ia) = A.CL;  dAa(k, v, m, ia) = A.dg;  VAa(k, v, m, ia) = A.V;
                yAa(k, v, m, ia) = abs(DE.y(A.iB));  mAa(k, v, m, ia) = min(A.R.marge);
                causeA(k, v, m, ia) = A.cause;  borneA(k, v, m, ia) = A.borne;  extA(k, v, m, ia) = A.R.ext;
                [dg, R] = delta_equilibre(p.aero.CLmax, V08m(m), vrG(v), dx, modes(iCo), DV{k}, round(A.dg), p.stab.d_lim);
                d08(k, v, m, ia) = dg;
                if ~isnan(dg), m08(k, v, m, ia) = min(R.marge);  ext08(k, v, m, ia) = R.ext; end
            end
        end
    end
end
okA = causeA == "bande" | borneA;                                      % décrochage atteint avant la butée de braquage
okAut    = ok04 & reshape(all(okA(:, :, :, iA10), 3), nVa, nVr);
okAutBas = ok04 & reshape(all(okA(:, :, :, iA9), 3), nVa, nVr);
% CLmax de l'aile lisse (δ = 0) par la même méthode, pour situer l'hypothèse de la phase 3
CLmax0 = NaN(nVr, 2);
for v = 1:nVr
    for m = 1:2
        CLmax0(v, m) = fzero(@(CL) marge_lisse(CL, mg(m), q1, vrG(v), DE), p.stab.CL_autorite);
    end
end
Vs0 = sqrt(mg.' ./ (q1 * CLmax0));                                      % m/s, décrochage de l'aile lisse (nVr × 2)
fprintf('§5 Autorité (%s, MS %.0f %%, au plus %.0f° vers le haut) : vrillages où l''équilibre atteint le décrochage d''une bande (3S1P et 4S1P)\n', ...
        p.stab.mode_verdict, 100*p.stab.MS_autorite, -p.stab.d_autorite);
for k = 1:nVa
    fprintf('  %-16s %s ; au vrillage %.0f° : CL atteint %.3f / %.3f (%s / %s) ; δ à CL %.2f : %+.1f / %+.1f° ; MS 9 %% : %s\n', ...
            p.elv.nom(k), pl(vrG(okAut(k, :))), vrG(v5), CLa(k, v5, 1, iA10), CLa(k, v5, 2, iA10), causeA(k, v5, 1, iA10), ...
            causeA(k, v5, 2, iA10), p.aero.CLmax, d08(k, v5, 1, iA10), d08(k, v5, 2, iA10), pl(vrG(okAutBas(k, :))));
end
fprintf('  CLmax de l''aile lisse (bande critique, δ = 0) : %.3f à %.3f (hypothèse de la phase 3 : %.2f)\n', ...
        min(CLmax0(:)), max(CLmax0(:)), p.aero.CLmax);

%% §6 Synthèse
okTout = okCr & okAut;
okToutBas = okCrBas & okAutBas;
arret = ~any(okTout(:));
fprintf('§6 Synthèse : vrillages tenant croisière (MS 8–10 %%) et autorité (MS 10 %%), MOD-04 comprise :\n');
for k = 1:nVa
    fprintf('  %-16s %s ; avec MS de premier vol 7–9 %% (autorité à 9 %%) : %s\n', p.elv.nom(k), pl(vrG(okTout(k, :))), pl(vrG(okToutBas(k, :))));
end
if arret
    fprintf('  ARRÊT (consigne du 15/10/2026) : aucune variante ne passe à MS 8–10 %% ; effet d''une MS de premier vol de 7–9 %% chiffré ci-dessus\n');
end
fprintf('  δ_trim hors des polaires à volet (prolongement linéaire au-delà de %+.0f°) : croisière %d points sur %d ; autorité %d cas sur %d\n', ...
        min(DE.T.d), nnz(extC(:, :, iCr, :)), numel(extC(:, :, iCr, :)), nnz(extA(:, :, :, iA10)), numel(extA(:, :, :, iA10)));

%% Figures
vrM = [max(p.geo4.vrillage_matrice) min(p.geo4.vrillage_matrice)];
fig = figure('Visible', 'off', 'Position', [100 100 1400 520]);
tl = tiledlayout(fig, 1, 2, 'TileSpacing', 'compact');
ax = nexttile(tl); hold(ax, 'on'); grid(ax, 'on');
yregion(ax, dW(1), dW(2), 'FaceColor', [0.92 0.92 0.92], 'DisplayName', 'fenêtre de croisière');
icF = [find(cfg(:, 1) == 2 & abs(MSc(cfg(:, 2)).' - max(p.stab.MS_crois)) < 1e-9), find(cfg(:, 1) == 1 & abs(MSc(cfg(:, 2)).' - min(p.stab.MS_crois)) < 1e-9)];
styF = ["-" "--"];
for k = 1:nVa
    for t = 1:2
        plot(ax, 3.6*Vc, squeeze(dC(k, v5, icF(t), :, iCo)), styF(t), 'Color', C(k), 'LineWidth', 1.4, ...
             'DisplayName', p.elv.nom(k) + ", " + labC(icF(t)));
    end
end
xlabel(ax, 'V [km/h] (ISA)'); ylabel(ax, 'δ_{trim} [°] (< 0 : bord de fuite vers le haut)');
title(ax, sprintf('Croisière, vrillage %.0f°, modèle « %s » (estimation)', vrG(v5), p.stab.mode_verdict));
legend(ax, 'Location', 'southoutside', 'NumColumns', 2);
ax = nexttile(tl); hold(ax, 'on'); grid(ax, 'on');
yregion(ax, dW(1), dW(2), 'FaceColor', [0.92 0.92 0.92], 'DisplayName', 'fenêtre de croisière');
if any(~ok04)
    xregion(ax, min(vrG(~ok04)), max(vrG(~ok04)), 'FaceColor', [0.98 0.86 0.86], 'DisplayName', 'MOD-04 non tenue (visqueux)');
end
for k = 1:nVa
    plot(ax, vrG, fenC(k, :, 1), '-', 'Color', C(k), 'LineWidth', 1.4, 'DisplayName', p.elv.nom(k) + sprintf(' : δ le plus haut (%.0f km/h)', 3.6*Vc(1)));
    plot(ax, vrG, fenC(k, :, 2), '--', 'Color', C(k), 'LineWidth', 1.4, 'DisplayName', p.elv.nom(k) + sprintf(' : δ le plus bas (%.0f km/h)', 3.6*Vc(end)));
end
xlim(ax, sort(vrM));
xlabel(ax, 'vrillage au saumon [°]'); ylabel(ax, 'δ_{trim} [°]');
title(ax, sprintf('Fenêtre requise (3S1P et 4S1P, MS %s %%)', strjoin(compose('%.0f', 100*p.stab.MS_crois), ', ')));
legend(ax, 'Location', 'southoutside', 'NumColumns', 2);
sauver_figure(fig, "fig09_variantes_croisiere", dFig, p.sortie.dpi);

CLf = p.elv.CL_fig(1):p.elv.CL_fig(3):p.elv.CL_fig(2);
dF = NaN(nVa, numel(CLf));
dxF = dxM(v5, p.stab.MS_autorite, iCo);
for k = 1:nVa
    d0 = 0;
    for j = 1:numel(CLf)
        [dg, R] = delta_equilibre(CLf(j), sqrt(mg(2) / (q1 * CLf(j))), vrG(v5), dxF, modes(iCo), DV{k}, d0, p.stab.d_lim);
        if isnan(dg) || min(R.marge) < 0, break; end
        dF(k, j) = dg;  d0 = round(dg);
    end
end
fig = figure('Visible', 'off', 'Position', [100 100 900 560]);
ax = axes(fig); hold(ax, 'on'); grid(ax, 'on');
yline(ax, p.stab.d_autorite, '-', sprintf('butée du critère (%.0f°)', p.stab.d_autorite), 'Color', GRIS, 'HandleVisibility', 'off');
xline(ax, p.aero.CLmax, ':', sprintf('CLmax hypothèse phase 3 (%.1f)', p.aero.CLmax), 'Color', GRIS, 'HandleVisibility', 'off');
for k = 1:nVa
    plot(ax, CLf, dF(k, :), '-', 'Color', C(k), 'LineWidth', 1.6, 'DisplayName', p.elv.nom(k));
    plot(ax, CLa(k, v5, 2, iA10), dAa(k, v5, 2, iA10), 'o', 'Color', C(k), 'MarkerFaceColor', C(k), ...
         'DisplayName', p.elv.nom(k) + " : limite (" + causeA(k, v5, 2, iA10) + ")");
end
xlabel(ax, 'CL de l''aile'); ylabel(ax, 'δ_{trim} [°]');
title(ax, sprintf('Autorité : 4S1P, MS %.0f %%, vrillage %.0f°, modèle « %s » (estimation)', 100*p.stab.MS_autorite, vrG(v5), p.stab.mode_verdict));
legend(ax, 'Location', 'southwest');
sauver_figure(fig, "fig10_variantes_autorite", dFig, p.sortie.dpi);

%% Tableaux
fid = fopen(fullfile(dRes, 'tableaux_variantes.md'), 'w', 'n', 'UTF-8');
fprintf(fid, '# Phase 4 — élevons agrandis : estimation sans manip xflr5 (généré par elevons_variantes.m)\n\n');
fprintf(fid, ['Critères du 15/10/2026 (utilisateur, hors cahier) : croisière de %s à %s km/h, δ_trim de %s à %s° en 3S1P et 4S1P à MS %s %% ; ' ...
              'autorité : équilibre au CLmax équilibré (bande critique) à MS %s %%, au plus %s° vers le haut. Modèle du verdict : « %s ». ' ...
              'ESTIMATION, HORS SKILL : VLM des T2 mise à l''échelle (profils minces), prolongement par Weissinger recalé, polaires à volet ' ...
              'de la charnière à %s %% empruntées (η identique à braquage égal).\n'], fr(3.6*Vc(1), '%.0f'), fr(3.6*Vc(end), '%.0f'), ...
        fr(dW(1), '%+.0f'), fr(dW(2), '%+.0f'), strjoin(fr(100*p.stab.MS_crois, '%.0f'), ", "), fr(100*p.stab.MS_autorite, '%.0f'), ...
        fr(-p.stab.d_autorite, '%.0f'), p.stab.mode_verdict, fr(100*p.geo4.charniere, '%.0f'));
tableau_md(fid, "§1 : Weissinger recalé sur la VLM de xflr5", ["Grandeur", "Weissinger", "xflr5 (§11)"], ...
    ["x_NP [mm]", fr(1000*xNP_W, '%.1f'), fr(1000*min(S.xNPl11), '%.1f') + " à " + fr(1000*max(S.xNPl11), '%.1f');
     "Moment de portance des élevons des T2 à CL constant [/°]", fr(E0.Cm, '%+.5f'), fr(CmL_T2, '%+.5f');
     "Recalage κ (appliqué au prolongement)", fr(kappa, '%.3f'), "—";
     "Écart de forme des Cl recalés, hors bandes de transition (part du maximum)", fr(100*eForme, '%.0f') + " %", "—"]);
lig = strings(nVa, 9);
for k = 1:nVa
    lig(k, :) = [p.elv.nom(k), fr(100*(1 - p.elv.charniere(k)), '%.0f') + " % (charnière " + fr(p.elv.charniere(k), '%.2f') + ")", ...
        fr(1000*p.elv.y0(k), '%.0f') + " à " + fr(1000*p.geo.b/2, '%.0f'), fr(linV(k, 1), '%.3f') + " / " + fr(linV(k, 2), '%.3f'), ...
        fr(linV(k, 3), '%+.5f') + " + " + fr(linV(k, 4), '%+.5f') + " = " + fr(linV(k, 5), '%+.5f'), ...
        strjoin(fr(effV(k, 1:nMo), '%+.5f'), " / "), strjoin(fr(100*gainV(k, :), '%+.0f'), " / ") + " %", ...
        fr(effV(k, nMo + 2), '%.2f') + " / " + fr(effV(k, nMo + 3), '%.2f'), fr(effV(k, nMo + 1), '%+.1f') + "°"];
end
tableau_md(fid, "§2 : efficacité des variantes à " + fr(3.6*Vr, '%.0f') + " km/h, 4S1P, MS " + fr(100*p.stab.MS_nom, '%.0f') + " %, vrillage " + fr(vrG(v5), '%.0f') + "°", ...
    ["Variante", "Corde des élevons", "Envergure (demi-aile) [mm]", "Profils minces / T2 : τ / moment de section", ...
     "Cm_δ VLM linéaire : portance + section [/°]", "Cm_δ à l'équilibre : VLM / bandes / complet [/°]", "Gain sur les T2", ...
     "η_α / η_m (polaires empruntées)", "δ_trim (complet)"], lig);
tableau_md(fid, "§3 : ordres de grandeur du raisonnement du 15/10/2026, recalculés", ["Grandeur", "Valeur MATLAB"], ...
    ["Amplitude de δ_trim de 35 à 55 km/h (ancien critère ; 4S1P, MS 10 %, " + fr(vrG(v5), '%.0f') + "°, élevons des T2)", fr(amp11, '%.1f') + "°";
     "MS·ΔCL/|Cm_δ| (même cas, Cm_δ complet à 45 km/h)", fr(max(S11.MS), '%.2f') + " × " + fr(S.CLg(2, 1) - S.CLg(2, end), '%.3f') + " / " + fr(abs(Cmd10), '%.4f') + " = " + fr(ampEst, '%.1f') + "°";
     "ΔCm cabreur requis à CL = " + fr(p.aero.CLmax, '%.1f') + " (4S1P, MS 10 %, " + fr(3.6*V08, '%.1f') + " km/h)", fr(dCm08, '%.4f');
     "δ_trim à CL = " + fr(p.aero.CLmax, '%.1f') + " : VLM / bandes / complet (élevons des T2)", strjoin(fr(d08m, '%+.1f'), " / ") + "°";
     "1 % de MS", fr(mm1pc, '%.2f') + " mm";
     "±3 mm de centrage", "±" + fr(pc3mm, '%.2f') + " % de MS";
     "Élevons à 35 % contre 25 % (profils minces) : efficacité de portance τ", fr(100*(linV(end, 1) - 1), '%+.1f') + " %";
     "Idem : moment de section au quart avant", fr(100*(linV(end, 2) - 1), '%+.1f') + " % (maximal à 25 % de corde)";
     "CLmax de l'aile lisse (bande critique, δ = 0, vrillages −3 à −7°)", fr(min(CLmax0(:)), '%.3f') + " à " + fr(max(CLmax0(:)), '%.3f');
     "Vitesse de décrochage de l'aile lisse à ce CLmax (3S1P à 4S1P)", fr(3.6*min(Vs0(:)), '%.1f') + " à " + fr(3.6*max(Vs0(:)), '%.1f') + " km/h"]);
lig = strings(0, 9);
iM = @(ms) find(abs(MSc - ms) < 1e-9);
cell2 = @(k, v, ms) fr(dMinC(k, v, cfg(:, 1) == 1 & cfg(:, 2) == iM(ms), iCo), '%+.1f') + " à " + fr(dMaxC(k, v, cfg(:, 1) == 1 & cfg(:, 2) == iM(ms), iCo), '%+.1f') + ...
                    " / " + fr(dMinC(k, v, cfg(:, 1) == 2 & cfg(:, 2) == iM(ms), iCo), '%+.1f') + " à " + fr(dMaxC(k, v, cfg(:, 1) == 2 & cfg(:, 2) == iM(ms), iCo), '%+.1f');
for k = 1:nVa
    for t = iTab(:).'
        lig(end+1, :) = [p.elv.nom(k), fr(vrG(t), '%+.0f') + "°" + ternaire(ok04(t), "", " (MOD-04 non tenue)"), ...
            cell2(k, t, 0.08), cell2(k, t, 0.09), cell2(k, t, 0.10), ternaire(okCr(k, t), "tenu", "**non tenu**"), ...
            fr(dMinC(k, t, cfg(:, 1) == 2 & cfg(:, 2) == iM(0.10), iVl), '%+.1f') + " à " + fr(dMaxC(k, t, cfg(:, 1) == 1 & cfg(:, 2) == iM(0.08), iVl), '%+.1f'), ...
            cell2(k, t, 0.07) + " (" + ternaire(okCrBas(k, t), "7–9 % tenu", "7–9 % non tenu") + ")", fr(nExtC(k, t), '%d')]; %#ok<SAGROW>
    end
end
tableau_md(fid, "§4 : croisière, δ_trim [°] de " + fr(3.6*Vc(1), '%.0f') + " à " + fr(3.6*Vc(end), '%.0f') + " km/h (3S1P / 4S1P ; critère : " + ...
    fr(dW(1), '%+.0f') + " à " + fr(dW(2), '%+.0f') + "° à MS 8, 9 et 10 %)", ...
    ["Variante", "Vrillage", "MS 8 %", "MS 9 %", "MS 10 %", "Critère", "VLM seule (MS 10 % 4S1P à MS 8 % 3S1P)", "MS 7 % (premier vol 7–9 %)", ...
     "Points au-delà de " + fr(min(DE.T.d), '%+.0f') + "° (MS 8–10 %)"], lig);
lig = strings(0, 7);
celA = @(k, v, ia) fr(CLa(k, v, 1, ia), '%.3f') + " / " + fr(CLa(k, v, 2, ia), '%.3f') + " (" + causeA(k, v, 1, ia) + " / " + causeA(k, v, 2, ia) + ...
                   ") ; " + fr(3.6*VAa(k, v, 1, ia), '%.1f') + " / " + fr(3.6*VAa(k, v, 2, ia), '%.1f') + " km/h ; δ " + ...
                   fr(dAa(k, v, 1, ia), '%+.1f') + " / " + fr(dAa(k, v, 2, ia), '%+.1f') + "°" + ...
                   ternaire(any(borneA(k, v, :, ia)), " ; CL de recherche atteint", "");
for k = 1:nVa
    for t = iTab(:).'
        lig(end+1, :) = [p.elv.nom(k), fr(vrG(t), '%+.0f') + "°" + ternaire(ok04(t), "", " (MOD-04 non tenue)"), celA(k, t, iA10), ...
            ternaire(all(okA(k, t, :, iA10)), "tenu", "**non tenu**"), ...
            fr(d08(k, t, 1, iA10), '%+.1f') + " / " + fr(d08(k, t, 2, iA10), '%+.1f') + "°", ...
            fr(1000*yAa(k, t, 1, iA10), '%.0f') + " / " + fr(1000*yAa(k, t, 2, iA10), '%.0f') + ternaire(any(extA(k, t, :, iA10)), " ; au-delà des polaires à volet", ""), ...
            celA(k, t, iA9) + " (" + ternaire(all(okA(k, t, :, iA9)), "tenu", "non tenu") + ")"]; %#ok<SAGROW>
    end
end
tableau_md(fid, "§5 : autorité, MS " + fr(100*p.stab.MS_autorite, '%.0f') + " % (3S1P / 4S1P) : plus grand CL équilibré avec au plus " + fr(-p.stab.d_autorite, '%.0f') + ...
    "° vers le haut ; limite « bande » = décrochage d'une bande atteint (critère tenu), « braquage » = butée atteinte avant (non tenu), « polaires » = hors des polaires", ...
    ["Variante", "Vrillage", "CL atteint (limite) ; V ; δ", "Critère", "δ_trim à CL = " + fr(p.aero.CLmax, '%.1f') + " (hypothèse phase 3)", ...
     "Bande de marge minimale |y| [mm]", "MS 9 % (premier vol 7–9 %)"], lig);
lig = strings(nVa, 5);
for k = 1:nVa
    lig(k, :) = [p.elv.nom(k), pl(vrG(okCr(k, :))), pl(vrG(okAut(k, :))), "**" + pl(vrG(okTout(k, :))) + "**", pl(vrG(okToutBas(k, :)))];
end
tableau_md(fid, "§6 : synthèse, vrillages qui passent (grille de " + fr(p.stab.pas_vr, '%.2f') + "° ; MOD-04 en visqueux comprise, limite " + fr(S.vr04, '%.2f') + "°)", ...
    ["Variante", "Croisière (MS 8–10 %)", "Autorité (MS 10 %)", "Les deux", "Les deux avec MS de premier vol 7–9 % (autorité à 9 %)"], lig);
lig = strings(0, 6);
for k = 1:nVa
    for t = iTab(:).'
        lig(end+1, :) = [p.elv.nom(k), fr(vrG(t), '%+.0f') + "°" + ternaire(ok04(t), "", " (MOD-04 non tenue)"), ...
            fr(fenC(k, t, 1), '%+.1f') + " à " + fr(fenC(k, t, 2), '%+.1f') + "° → " + fr(fenB(k, t, 1), '%+.1f') + " à " + fr(fenB(k, t, 2), '%+.1f') + "°", ...
            ternaire(okCr(k, t), "tenu", "non tenu") + " → " + ternaire(okCrBas(k, t), "**tenu**", "non tenu"), ...
            fr(CLa(k, t, 2, iA10), '%.3f') + " (" + fr(3.6*VAa(k, t, 2, iA10), '%.1f') + " km/h) → " + fr(CLa(k, t, 2, iA9), '%.3f') + " (" + fr(3.6*VAa(k, t, 2, iA9), '%.1f') + " km/h)", ...
            fr(d08(k, t, 2, iA10), '%+.1f') + " → " + fr(d08(k, t, 2, iA9), '%+.1f') + "°"]; %#ok<SAGROW>
    end
end
tableau_md(fid, "§7 : effet d'une MS de premier vol de 7–9 % au lieu de 8–10 % (pas de MOD sur V1-STAB-02 sans accord ; autorité à MS 9 % au lieu de 10 %)", ...
    ["Variante", "Vrillage", "Fenêtre de croisière requise : MS 8–10 % → 7–9 %", "Croisière", ...
     "CL équilibré avec " + fr(-p.stab.d_autorite, '%.0f') + "° (4S1P) : MS 10 % → 9 %", "δ_trim à CL = " + fr(p.aero.CLmax, '%.1f') + " (4S1P) : MS 10 % → 9 %"], lig);
fclose(fid);

save(fullfile(dRes, 'variantes.mat'), 'p', 'Wg', 'kappa', 'CmL_T2', 'xNP_W', 'eForme', 'linV', 'DV', 'MSc', 'cfg', 'labC', 'modes', ...
     'effV', 'gainV', 'amp11', 'ampEst', 'Cmd10', 'dCm08', 'd08m', 'Vc', 'CLc', 'dC', 'horsC', 'extC', 'dMinC', 'dMaxC', 'okCC', ...
     'okCr', 'okCrBas', 'fenC', 'fenB', 'Vs0', 'MSa', 'CLa', 'dAa', 'VAa', 'yAa', 'mAa', 'causeA', 'borneA', 'extA', 'd08', 'm08', 'ext08', ...
     'okA', 'okAut', 'okAutBas', 'CLmax0', 'okTout', 'okToutBas', 'arret', 'dF', 'CLf');
fprintf('Résultats : %s (tableaux_variantes.md, variantes.mat)\n', dRes);

%% Fonctions locales
function s = fr(x, fmt)
% Nombre(s) formaté(s) avec la virgule décimale française
s = string(strrep(compose(fmt, x), '.', ','));
end

function s = ternaire(cond, a, b)
if cond, s = a; else, s = b; end
end

function s = plage(v, pas)
% Vrillages d'une grille de pas donné, en plage(s) continues
if isempty(v), s = "aucun"; return; end
v = sort(v, 'descend');
coupe = [0, find(abs(diff(v)) > pas + 1e-9), numel(v)];
s = strings(1, numel(coupe) - 1);
for i = 1:numel(coupe) - 1
    a = v(coupe(i) + 1);  b = v(coupe(i + 1));
    s(i) = fr(a, '%+.2f') + "°" + ternaire(a == b, "", " à " + fr(b, '%+.2f') + "°");
end
s = strjoin(s, " ; ");
end

function g = marge_lisse(CL, mg, q1, vr, D)
% Plus petite marge Clmax − Cl des bandes de l'aile lisse (δ = 0) à CL donné
V = sqrt(mg / (q1 * CL));
Cl = D.A * [1; CL; vr; 0];
g = min(interp_polaires_volet(D.T, "Clmax", 0, Cl, V * D.c / D.nu) - Cl);
end
