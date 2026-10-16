%VERDICT_ELEVONS  Phase 4 — élevons retenus : autorité, vrillage et V1-PERF-03/04/05 (15/10/2026).
%
%   Script autonome, exécuté d'un bloc après stabilite.m (relit resultats/phase4.mat, et
%   03_predimensionnement/resultats/phase3.mat pour le modèle de performances de la phase 3).
%   2e décision de l'utilisateur du 15/10/2026 (critères hors cahier, donc sans MOD ;
%   V1-STAB-02 reste à 8–10 %) :
%     autorité  : vitesse minimale équilibrée, élevons à au plus 20° vers le haut, ≤ 30 km/h à
%                 MS 10 %, en 3S1P et en 4S1P ; V1-PERF-01 (≤ 32 km/h à 800 g) tenue ; le CL
%                 max équilibré remplace le CLmax de la phase 3 (hypothèse CL 0,8 à vérifier) ;
%     croisière : plus de fenêtre de braquage ; V1-PERF-03/04/05 recalculées avec la traînée
%                 équilibrée, élevons compris, à MS 9 %, avec le modèle de la phase 3 ;
%     variante  : élevons de 35 % de corde prolongés depuis y = 200 mm ; vrillage choisi par la
%                 règle de traînée équilibrée (E4) parmi ceux qui passent, MOD-04 comprise.
%   Estimations demandées : élevons prolongés jusqu'à y = 150 mm (et largeur maximale du
%   fuselage central) ; Cm0 visqueux du profil plus élevé de 0,01 et 0,02.
%   Polaires des élevons : celles des profils S5010 à charnière 65 % (p.elv.dossier_pol_c65)
%   dès que le jeu est complet ; sinon celles de la charnière 75 %, empruntées avec la même
%   efficacité visqueuse à braquage égal (variante_elevons).
%     §1 Données du §11, Weissinger recalé, polaires des élevons
%     §2 Variantes (200 et 150 mm), efficacité, largeur du fuselage central
%     §3 Autorité : vitesse minimale équilibrée, V1-PERF-01, CL max équilibré
%     §4 Choix du vrillage (règle annoncée en E4)
%     §5 Polaire équilibrée à MS 9 % et V1-PERF-03/04/05 (modèle de la phase 3) ; V1-PERF-07
%     §6 Estimation : Cm0 visqueux du profil plus élevé
%   HORS SKILL : VLM, bandes, profils minces, Weissinger (prolongement, traînée induite de
%   Trefftz), modèle propulsif de la phase 3.
%   Sorties : resultats/tableaux_verdict.md, figures/fig11_*, fig12_*, resultats/verdict.mat

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
fprintf('\n===== PHASE 4 — ÉLEVONS RETENUS : VERDICT (2e décision du 15/10/2026) =====\n');

%% §1 Données du §11, Weissinger recalé, polaires des élevons
S = load(fullfile(dRes, 'phase4.mat'), 'DE', 'atm', 'mTot', 'xref', 'cE', 'vrG', 'xNPv11', 'Cm0v11', 'ok04', 'vr04');
S3 = load(fullfile(rac3, 'resultats', 'phase3.mat'), 'RO', 'est', 'Vz_F');
DE = S.DE;
assert(isfield(DE, 'y') && isfield(DE.T.F, 'Clmax'), 'phase4.mat antérieur au 15/10/2026 : relancer stabilite.m');
rF = S3.RO([S3.RO.nom] == p.choix.ref);
gE = geometrie_aile(p, p.geo4.fleche_BA, S.cE);
rho = S.atm(1).rho;  rhoH = S.atm(2).rho;
[~, nuH] = reynolds(1, 1, rhoH, S.atm(2).T, c);
mg = S.mTot(:) * c.g;                                                   % N : 3S1P ; 4S1P (masses de la phase 4)
q1 = rho * p.geo.S / 2;                                                 % V = sqrt(m·g/(q1·CL)), ISA
vrG = S.vrG;  nVr = numel(vrG);
ok04 = S.ok04(:).';
pl = @(v) plage(v, p.stab.pas_vr);
bB = -p.geo.b/2 + [0; cumsum(DE.wy)];
Wg = weissinger(bB, gE.cf, gE.xBAf, S.xref, gE.S, gE.MAC);
xc4 = gE.xBAf(abs(DE.y)) + DE.c / 4;
CmL_T2 = -sum(DE.A(:, 4) .* DE.c .* DE.wy .* (xc4 - S.xref)) / (gE.S * gE.MAC);
[tau0, m0] = volet_mince(p.geo4.charniere);
assert(abs(tau0 - DE.tau) < 1e-12 && abs(m0 - DE.dCm_dd) < 1e-15, 'volet des T2 incohérent avec p.geo4.charniere');
E0 = Wg.a_CL(tau0 * DE.we * pi/180);
kappa = CmL_T2 / E0.Cm;
% Profils à charnière 65 % (manip du 15/10/2026) : polaires prises si le jeu est complet
Re_lot = round(exp(DE.T.lRe));
nomPr = p.xfl.nom_xflr5.(p.xfl.profil_retenu);
dV65 = sort(p.elv.d_volet_c65);
[pol65, manque] = polaires_dossier(fullfile(racine, p.elv.dossier_pol_c65), compose(p.elv.nom_c65, dV65), Re_lot, p.xfl.Ncrit);
propres = isempty(manque);
Tv = DE.T;
if propres
    [pol0, manque0] = polaires_dossier(fullfile(racine, p.xfl.dossier_pol2d), nomPr, Re_lot, p.xfl.Ncrit);
    assert(isempty(manque0), 'polaires du profil de base incomplètes');
    Tv = table_polaires_volet([pol65; pol0], [dV65 0], Re_lot, p.xfl.pas_Cl_volet);
end
% Contrôle des exports .dat des profils à volet (facultatif) : braquage mesuré sur la ligne moyenne
pf0 = lire_profil_dat(fullfile(racine, p.xfl.dossier_profils, p.xfl.profil_retenu + ".dat"));
d_mes = NaN(size(dV65));
for j = 1:numel(dV65)
    f = fullfile(racine, p.xfl.dossier_profils, sprintf(p.elv.dat_c65, dV65(j)));
    if isfile(f), d_mes(j) = braquage_mesure(lire_profil_dat(f), pf0, p.elv.charniere_c65); end
end
if propres
    srcPol = sprintf("profils à charnière %.0f %% (%d polaires, %+.0f à %+.0f°)", 100*p.elv.charniere_c65, numel(pol65), dV65(1), dV65(end));
else
    srcPol = sprintf("EMPRUNTÉES à la charnière %.0f %% (η identique à braquage égal) ; à %.0f %% : %s", ...
                     100*p.geo4.charniere, 100*p.elv.charniere_c65, ternaire(manque(1) == "dossier absent", "dossier absent", ...
                     numel(manque) + " polaire(s) manquante(s), ex. " + manque(1)));
end
fprintf('§1 Weissinger : κ = %.3f ; polaires des élevons : %s ; braquages mesurés : %s\n', kappa, srcPol, ...
        ternaire(all(isnan(d_mes)), "aucun export .dat", mat2str(round(d_mes, 2))));

%% §2 Variantes : élevons retenus (depuis 200 mm) et estimation jusqu'à 150 mm
iRet = find(p.elv.nom == p.elv.retenue);
assert(isscalar(iRet), 'variante retenue inconnue : %s', p.elv.retenue);
xhV = p.elv.charniere(iRet);
y0V = [p.elv.y0(iRet), p.elv.y0_estim];
nVa = numel(y0V);
nomVa = fr(100*(1 - xhV), '%.0f') + " % depuis y = " + fr(1000*y0V, '%.0f') + " mm";
DV = cell(1, nVa);
for k = 1:nVa
    var = variante_elevons(DE, xhV, p.geo4.charniere, y0V(k), p.geo4.y_elevon(1), bB, Wg, kappa, propres);
    DV{k} = DE;  DV{k}.T = Tv;  DV{k}.var = var;
end
modeV = p.stab.mode_verdict;
dxA = @(v, ms) (S.xNPv11(v) - ms * gE.MAC - S.xref) / gE.MAC;          % CG à x_NP visqueux − MS·MAC (§11)
% Cm_δ à l'équilibre : 45 km/h, 4S1P, MS nominale, vrillage des figures ; élevons des T2 en référence
v5 = find(abs(vrG - p.elv.vr_fig) < 1e-9);
assert(isscalar(v5), 'vrillage des figures hors de la grille');
Vr = p.stab.V_trim_ref;  CLr = mg(2) / (q1 * Vr^2);
Dref = [{DE}, DV];
effV = zeros(1, nVa + 1);  dgV = effV;
for k = 1:nVa + 1
    dgV(k) = delta_equilibre(CLr, Vr, vrG(v5), dxA(v5, p.stab.MS_nom), modeV, Dref{k}, 0, p.stab.d_lim);
    Rp = cm_elevons(dgV(k) + 0.5, CLr, Vr, vrG(v5), modeV, Dref{k});
    Rm = cm_elevons(dgV(k) - 0.5, CLr, Vr, vrG(v5), modeV, Dref{k});
    effV(k) = Rp.Cm - Rm.Cm;
end
% Fuselage central : élevons entièrement sur les demi-ailes si sa demi-largeur ≤ y0 (sans jeu)
R_hel = rF.hel{1}(1) * p.const.in / 2;
largeur = 2 * y0V;
garde_hel = y0V - R_hel;
fprintf('§2 Cm_δ (%s) à %.0f km/h, 4S1P, MS %.0f %%, vrillage %.0f° : T2 %+.5f /° ; ', modeV, 3.6*Vr, 100*p.stab.MS_nom, vrG(v5), effV(1));
for k = 1:nVa
    fprintf('%s %+.5f (%+.0f %%) ; ', nomVa(k), effV(k + 1), 100*(effV(k + 1)/effV(1) - 1));
end
fprintf('\n  fuselage central au plus %s mm de large (élevons entièrement sur les demi-ailes, sans jeu) ; bord des élevons à %s mm du disque de l''hélice\n', ...
        strjoin(fr(1000*largeur, '%.0f'), " / "), strjoin(fr(1000*garde_hel, '%.1f'), " / "));

%% §3 Autorité : vitesse minimale équilibrée (au plus |p.stab.d_autorite| vers le haut), MS 10 %
% Cas : 3S1P et 4S1P (masses de la phase 4), 800 g ISA et 800 g jour chaud (V1-PERF-01, TAS)
nomA = ["3S1P" "4S1P" "800 g ISA" "800 g jour chaud"];
nA = numel(nomA);
mgA = [mg; p.masse.MTOW / 1000 * c.g * [1; 1]];
q1A = [q1 q1 q1 rhoH * p.geo.S / 2];
nuA = [DE.nu DE.nu DE.nu nuH];
dLa = [p.stab.d_autorite, p.stab.d_lim(2)];
MSa = p.stab.MS_autorite;
CLa = NaN(nVa, nVr, nA);  VAa = CLa;  dAa = CLa;  causeA = strings(nVa, nVr, nA);  extA = false(nVa, nVr, nA);
for k = 1:nVa
    for v = 1:nVr
        for j = 1:nA
            Dk = DV{k};  Dk.nu = nuA(j);
            A = clmax_equilibre(mgA(j), q1A(j), vrG(v), dxA(v, MSa), modeV, Dk, p.stab.CL_autorite, dLa, p.stab.n_dicho);
            if A.cause == "polaires" && min(A.R.marge) < p.stab.tol_decrochage, A.cause = "bande"; end
            CLa(k, v, j) = A.CL;  VAa(k, v, j) = A.V;  dAa(k, v, j) = A.dg;  causeA(k, v, j) = A.cause;  extA(k, v, j) = A.R.ext;
        end
    end
end
okVit = all(VAa(:, :, 1:2) <= p.stab.V_aut_max + 1e-9, 3);            % critère de vitesse seul
okAut = ok04 & okVit;                                                   % avec la MOD-04
ok01  = all(VAa(:, :, 3:4) <= p.req.Vs_max + 1e-9, 3);
n35   = (p.stab.V_lancer ./ VAa(:, :, 1:2)).^2;                         % facteur de charge disponible au lancer
fprintf('§3 Autorité (%s, MS %.0f %%, au plus %.0f° vers le haut, V_min ≤ %.0f km/h en 3S1P et 4S1P) :\n', ...
        modeV, 100*MSa, -p.stab.d_autorite, 3.6*p.stab.V_aut_max);
for k = 1:nVa
    fprintf('  %s : vitesse tenue %s ; avec la MOD-04 %s ; V1-PERF-01 (≤ %.0f km/h à 800 g, ISA et jour chaud) : %s\n', ...
            nomVa(k), pl(vrG(okVit(k, :))), pl(vrG(okAut(k, :))), 3.6*p.req.Vs_max, pl(vrG(ok01(k, :))));
end

%% §4 Choix du vrillage : règle annoncée en E4 (moyenne des traînées équilibrées)
MSt = unique([p.stab.MS_regle_vr, p.stab.MS_perf]);  nMt = numel(MSt);
Vt = p.stab.V_choix_vr;  nVt = numel(Vt);
dT = NaN(nVa, nVr, 2, nMt, nVt);  Dt = dT;  extT = false(size(dT));
for k = 1:nVa
    for v = 1:nVr
        for b = 1:2
            for im = 1:nMt
                for iv = 1:nVt
                    CL = mg(b) / (q1 * Vt(iv)^2);
                    [dg, R] = delta_equilibre(CL, Vt(iv), vrG(v), dxA(v, MSt(im)), modeV, DV{k}, 0, p.stab.d_lim);
                    dT(k, v, b, im, iv) = dg;
                    if ~isnan(dg)
                        Dt(k, v, b, im, iv) = q1 * Vt(iv)^2 * (R.CDi + R.CDp);
                        extT(k, v, b, im, iv) = R.ext;
                    end
                end
            end
        end
    end
end
okTrim = all(~isnan(dT), [3 4 5]);
iRg = ismembertol(MSt, p.stab.MS_regle_vr, 1e-9);
Dmoy = mean(Dt(:, :, :, iRg, :), [3 4 5]);                              % nVa × nVr, N
okPass = ok04 & okAut & ok01 & okTrim;
iOpt = NaN(1, nVa);  iSel = NaN(1, nVa);  iLibre = zeros(1, nVa);  optCas = zeros(nVa, 2);
for k = 1:nVa
    Dok = Dmoy(k, :);  Dok(~okPass(k, :)) = Inf;
    [dmin, i] = min(Dok);
    if isfinite(dmin), iOpt(k) = i; end
    [~, iLibre(k)] = min(Dmoy(k, :));
    cas = reshape(Dt(k, :, :, iRg, :), nVr, []);
    [~, io] = min(cas, [], 1);
    optCas(k, :) = [min(vrG(io)), max(vrG(io))];
    % Sans vrillage qui passe : performances au vrillage le plus proche de l'autorité (information)
    iSel(k) = iOpt(k);
    if isnan(iSel(k))
        Vw = max(VAa(k, :, 1:2), [], 3);  Vw(~ok04) = Inf;
        [~, iSel(k)] = min(Vw);
    end
end
fprintf('§4 Règle E4 (moyenne des traînées de l''aile équilibrée à %s km/h, 3S1P/4S1P, MS %s %%) :\n', ...
        strjoin(fr(3.6*Vt, '%.0f'), " et "), strjoin(fr(100*p.stab.MS_regle_vr, '%.0f'), "/"));
for k = 1:nVa
    if isnan(iOpt(k))
        fprintf('  %s : AUCUN vrillage ne passe ; performances calculées au vrillage le plus proche de l''autorité, %+.2f°\n', nomVa(k), vrG(iSel(k)));
    else
        fprintf('  %s : vrillages qui passent %s ; retenu %+.2f° (%.3f N)%s ; sans contrainte %+.2f° ; optima des cas de %+.2f à %+.2f°\n', ...
                nomVa(k), pl(vrG(okPass(k, :))), vrG(iOpt(k)), Dmoy(k, iOpt(k)), ternaire(iOpt(k) == 1 || iOpt(k) == nVr, " — EN BORD DE PLAGE", ""), ...
                vrG(iLibre(k)), optCas(k, 1), optCas(k, 2));
    end
end

%% §5 Polaire équilibrée à MS 9 % et V1-PERF-03/04/05 avec le modèle de la phase 3
% Masses, groupe propulsif (option retenue) et η calculé au point de vol comme en phase 3
% (classement_options.m) ; seule la polaire change.
iE = find(p.batt.ns == 4);  i3 = find(p.batt.ns == 3);
m3 = rF.m_g / 1000;                                                     % kg, masses de la phase 3 (3S1P ; 4S1P)
nVp = round((p.elv.V_polaire(2) - p.elv.V_polaire(1)) / p.elv.V_polaire(3)) + 1;
Vp = linspace(p.elv.V_polaire(1), p.elv.V_polaire(2), nVp);
dCD_hors = S3.est.Cfe_corr * p.elv.Swet_hors_aile / p.geo.S;            % nacelle + winglets (frottement, phase 3)
aeroW = p.aero;  aeroW.CD0 = max(p.aero.CD0_bal);
nomP = ["Phase 3 : CD0 " + fr(p.aero.CD0, '%.3f') + ", e " + fr(p.aero.e, '%.2f'), "Phase 3 : CD0 " + fr(aeroW.CD0, '%.3f'), ...
        "Phase 4 complète : induite VLM + profil XFoil (bandes) + nacelle et winglets " + fr(dCD_hors, '%.4f'), ...
        "CD0 phase 3 " + fr(p.aero.CD0, '%.3f') + " + induite VLM + surcoût de profil des élevons", ...
        "Idem avec CD0 " + fr(aeroW.CD0, '%.3f')];
nPo = numel(nomP);
PO = struct('dg', NaN(2, nVp), 'CL', NaN(2, nVp), 'CDi', NaN(2, nVp), 'CDp', NaN(2, nVp), 'CDp0', NaN(2, nVp), 'ext', false(2, nVp));
PO = repmat(PO, 1, nVa);
nVe = numel(p.req.V_eta);
tP = NaN(nVa, nPo, 2, nVe, 2);  etaP = NaN(nVa, nPo, 2, nVe);  dP = etaP;  okP = false(nVa, nPo, 2, nVe);  CDP = etaP;
for k = 1:nVa
    v = iSel(k);
    for b = 1:2
        d0 = 0;
        for iv = 1:nVp
            CL = m3(b) * c.g / (q1 * Vp(iv)^2);
            [dg, R] = delta_equilibre(CL, Vp(iv), vrG(v), dxA(v, p.stab.MS_perf), modeV, DV{k}, d0, p.stab.d_lim);
            assert(~isnan(dg), 'polaire équilibrée : pas d''équilibre à %.0f km/h', 3.6*Vp(iv));
            R0 = cm_elevons(0, CL, Vp(iv), vrG(v), modeV, DV{k});
            PO(k).dg(b, iv) = dg;  PO(k).CL(b, iv) = CL;  PO(k).CDi(b, iv) = R.CDi;  PO(k).CDp(b, iv) = R.CDp;
            PO(k).CDp0(b, iv) = R0.CDp;  PO(k).ext(b, iv) = R.ext;
            d0 = round(dg);
        end
        CDs = [PO(k).CDi(b, :) + PO(k).CDp(b, :) + dCD_hors;
               p.aero.CD0 + PO(k).CDi(b, :) + PO(k).CDp(b, :) - PO(k).CDp0(b, :);
               aeroW.CD0 + PO(k).CDi(b, :) + PO(k).CDp(b, :) - PO(k).CDp0(b, :)];
        aeros = [{p.aero, aeroW}, arrayfun(@(i) aero_table(p.aero, PO(k).CL(b, :), CDs(i, :)), 1:3, 'UniformOutput', false)];
        for ip = 1:nPo
            for ie = 1:nVe
                Ve = p.req.V_eta(ie);
                cN = rendement_croisiere(rF.mot, rF.hel{b}, p.batt.ns(b), p.batt.V_nom, Ve, m3(b), rho, aeros{ip}, p);
                aN = autonomie_distance(Ve, m3(b), p.batt.ns(b), rho, p, aeros{ip}, cN.eta);
                tP(k, ip, b, ie, :) = aN.t_reel;  etaP(k, ip, b, ie) = cN.eta;  dP(k, ip, b, ie) = cN.d;
                okP(k, ip, b, ie) = cN.faisable && cN.d <= rF.thr(b);
                CDP(k, ip, b, ie) = polaire(m3(b) * c.g / (q1 * Ve^2), aeros{ip});
            end
        end
    end
end
% Contrôle : la polaire de la phase 3 redonne ses autonomies (même modèle, mêmes masses)
eRef = max(abs([reshape(squeeze(tP(1, 1, :, :, :)) - rF.t, [], 1); reshape(squeeze(tP(1, 2, :, :, :)) - rF.t_W, [], 1)]));
assert(eRef < 1e-9, 'la polaire de la phase 3 ne redonne pas ses autonomies (écart %.1e min)', eRef);
i40 = find(abs(p.req.V_eta - p.req.V_end_op) < 1e-9);  i55 = find(abs(p.req.V_eta - p.req.V_cr) < 1e-9);
perf = {iE, i55, p.req.t_4S_cr, "V1-PERF-03 : 4S1P à 55 km/h"; iE, i40, p.req.t_4S_end, "V1-PERF-04 : 4S1P à 40 km/h (souhaitable)"; ...
        i3, i55, p.req.t_3S_cr, "V1-PERF-05 : 3S1P à 55 km/h"};
fprintf('§5 V1-PERF-03/04/05 (réel −30 / −20 %%, η calculé, masses de la phase 3 %s g ; vrillage %s, MS %.0f %%) :\n', ...
        strjoin(fr(1000*m3, '%.1f'), " / "), strjoin(fr(vrG(iSel), '%+.2f') + "°", " / "), 100*p.stab.MS_perf);
for r = 1:size(perf, 1)
    [b, ie, seuil, lib] = perf{r, :};
    fprintf('  %s (≥ %.0f min) :', lib, seuil);
    for ip = 1:nPo
        fprintf(' [%d] %.1f / %.1f', ip, tP(1, ip, b, ie, 2), tP(1, ip, b, ie, 1));
    end
    fprintf('\n');
end
% V1-PERF-07 avec le CL max équilibré (MS 10 %) à la place de p.aero.CLmax : montée plein gaz à
% 1,3·Vs, polaire de la phase 3 (C1 p.79, comme dimensionnement.m §4c)
atmJ = [rho rhoH];
Vz = NaN(nVa, 2, 2);  VzRef = NaN(2, 2);  Vm = NaN(nVa, 2, 2);
for b = 1:2
    for j = 1:2
        [VzRef(b, j), ~] = montee(rF, b, m3(b), atmJ(j), p.aero, p);
        for k = 1:nVa
            aK = p.aero;  aK.CLmax = CLa(k, iSel(k), b);
            [Vz(k, b, j), Vm(k, b, j)] = montee(rF, b, m3(b), atmJ(j), aK, p);
        end
    end
end
assert(max(abs(VzRef(:) - S3.Vz_F(:))) < 1e-9, 'V1-PERF-07 : la phase 3 n''est pas retrouvée');

%% §6 Estimation : Cm0 visqueux du profil plus élevé (couple pur, le même sur toutes les bandes)
dC0 = [0 p.elv.dCm0];  nC0 = numel(dC0);
facC0 = sum(DE.c.^2 .* DE.wy) / (DE.S * DE.MAC);                       % ΔCm de l'aile par unité de ΔCm0 du profil
vC = iSel(1);
dTC = NaN(nC0, 2, nMt, nVt);  VC0 = NaN(nC0, 2);  dVC0 = VC0;
for i = 1:nC0
    D2 = DV{1};  D2.dCm0 = dC0(i);
    for b = 1:2
        for im = 1:nMt
            for iv = 1:nVt
                CL = mg(b) / (q1 * Vt(iv)^2);
                dTC(i, b, im, iv) = delta_equilibre(CL, Vt(iv), vrG(vC), dxA(vC, MSt(im)), modeV, D2, 0, p.stab.d_lim);
            end
        end
        A = clmax_equilibre(mg(b), q1, vrG(vC), dxA(vC, MSa), modeV, D2, p.stab.CL_autorite, dLa, p.stab.n_dicho);
        VC0(i, b) = A.V;  dVC0(i, b) = A.dg;
    end
end
decal = dTC(2:end, :, :, :) - dTC(1, :, :, :);                          % décalage de δ_trim [°]
ok04C = S.Cm0v11(:).' + facC0 * dC0(:) >= p.stab.Cm0_aile_min;         % MOD-04 avec ΔCm0 (nC0 × nVr)
fprintf('§6 Cm0 du profil + %s (ΔCm de l''aile = %.3f × ΔCm0), vrillage %+.2f° : décalage de δ_trim %s° ; V_min (MS 10 %%, 3S1P / 4S1P) %s km/h\n', ...
        strjoin(fr(p.elv.dCm0, '%.2f'), " / "), facC0, vrG(vC), ...
        strjoin(fr(min(decal, [], [2 3 4]), '%+.2f') + " à " + fr(max(decal, [], [2 3 4]), '%+.2f'), " / "), ...
        strjoin(fr(3.6*VC0(:, 1), '%.1f') + " / " + fr(3.6*VC0(:, 2), '%.1f'), " → "));

%% Figures
fig = figure('Visible', 'off', 'Position', [100 100 1400 560]);
tl = tiledlayout(fig, 1, 2, 'TileSpacing', 'compact');
ax = nexttile(tl); hold(ax, 'on'); grid(ax, 'on');
if any(~ok04)
    xregion(ax, min(vrG(~ok04)), max(vrG(~ok04)), 'FaceColor', [0.98 0.86 0.86], 'DisplayName', 'MOD-04 non tenue (visqueux)');
end
yline(ax, 3.6*p.stab.V_aut_max, '-', sprintf('autorité : %.0f km/h', 3.6*p.stab.V_aut_max), 'Color', GRIS, 'HandleVisibility', 'off');
yline(ax, 3.6*p.req.Vs_max, '--', sprintf('V1-PERF-01 : %.0f km/h à 800 g', 3.6*p.req.Vs_max), 'Color', C(8), 'HandleVisibility', 'off');
yline(ax, 3.6*p.req.Vs_cible, ':', sprintf('cible %.0f km/h', 3.6*p.req.Vs_cible), 'Color', C(8), 'HandleVisibility', 'off');
styA = ["-" "--" "-." ":"];
for k = 1:nVa
    for j = 1:nA
        plot(ax, vrG, 3.6*VAa(k, :, j), styA(j), 'Color', C(k), 'LineWidth', 1.4, 'DisplayName', nomVa(k) + ", " + nomA(j));
    end
    if ~isnan(iOpt(k))
        plot(ax, vrG(iOpt(k)), 3.6*max(VAa(k, iOpt(k), 1:2)), 'o', 'Color', C(k), 'MarkerFaceColor', C(k), 'MarkerSize', 8, ...
             'DisplayName', nomVa(k) + " : vrillage retenu (règle E4)");
    end
end
ylim(ax, [floor(3.6*min(VAa(:))) - 0.5, 3.6*p.req.Vs_max + 0.75]);
xlabel(ax, 'vrillage au saumon [°]'); ylabel(ax, 'vitesse minimale équilibrée [km/h]');
title(ax, sprintf('Autorité : MS %.0f %%, au plus %.0f° vers le haut (%s)', 100*MSa, -p.stab.d_autorite, ternaire(propres, "polaires à 65 %", "polaires empruntées")));
legend(ax, 'Location', 'southoutside', 'NumColumns', 2);
ax = nexttile(tl); hold(ax, 'on'); grid(ax, 'on');
for k = 1:nVa
    plot(ax, vrG, Dmoy(k, :), '-', 'Color', C(k), 'LineWidth', 1.4, 'DisplayName', nomVa(k) + " : moyenne de la règle E4");
    if any(okPass(k, :))
        plot(ax, vrG(okPass(k, :)), Dmoy(k, okPass(k, :)), 'o', 'Color', C(k), 'DisplayName', nomVa(k) + " : vrillages qui passent");
    end
end
xlabel(ax, 'vrillage au saumon [°]'); ylabel(ax, 'traînée de l''aile équilibrée [N]');
title(ax, sprintf('Règle E4 : %s km/h, 3S1P/4S1P, MS %s %%', strjoin(compose('%.0f', 3.6*Vt), ' et '), strjoin(compose('%.0f', 100*p.stab.MS_regle_vr), '/')));
legend(ax, 'Location', 'southoutside');
sauver_figure(fig, "fig11_verdict_autorite", dFig, p.sortie.dpi);

fig = figure('Visible', 'off', 'Position', [100 100 1400 520]);
tl = tiledlayout(fig, 1, 2, 'TileSpacing', 'compact');
ax = nexttile(tl); hold(ax, 'on'); grid(ax, 'on');
CLf = PO(1).CL(iE, :);
plot(ax, polaire(CLf, p.aero), CLf, '-', 'Color', GRIS, 'LineWidth', 1.4, 'DisplayName', nomP(1));
CDf = [PO(1).CDi(iE, :) + PO(1).CDp(iE, :) + dCD_hors; p.aero.CD0 + PO(1).CDi(iE, :) + PO(1).CDp(iE, :) - PO(1).CDp0(iE, :)];
for i = 1:2
    plot(ax, CDf(i, :), CLf, '-', 'Color', C(i), 'LineWidth', 1.4, 'DisplayName', nomP(2 + i));
end
for ie = 1:nVe
    yline(ax, m3(iE) * c.g / (q1 * p.req.V_eta(ie)^2), ':', sprintf('%.0f km/h', 3.6*p.req.V_eta(ie)), 'Color', GRIS, 'HandleVisibility', 'off');
end
xlabel(ax, 'C_D'); ylabel(ax, 'C_L');
title(ax, sprintf('Polaire équilibrée, %s, 4S1P, MS %.0f %%, vrillage %+.2f°', nomVa(1), 100*p.stab.MS_perf, vrG(iSel(1))));
legend(ax, 'Location', 'southoutside');
ax = nexttile(tl); hold(ax, 'on'); grid(ax, 'on');
for b = 1:2
    plot(ax, 3.6*Vp, PO(1).dg(b, :), '-', 'Color', C(b), 'LineWidth', 1.4, 'DisplayName', sprintf('%dS1P (%.0f g)', p.batt.ns(b), 1000*m3(b)));
end
xlabel(ax, 'V [km/h] (ISA)'); ylabel(ax, 'δ_{trim} [°] (< 0 : vers le haut)');
title(ax, sprintf('Braquage d''équilibre, MS %.0f %%', 100*p.stab.MS_perf));
legend(ax, 'Location', 'southeast');
sauver_figure(fig, "fig12_polaire_equilibree", dFig, p.sortie.dpi);

%% Tableaux
fid = fopen(fullfile(dRes, 'tableaux_verdict.md'), 'w', 'n', 'UTF-8');
fprintf(fid, '# Phase 4 — élevons retenus : verdict (généré par verdict_elevons.m)\n\n');
fprintf(fid, ['2e décision du 15/10/2026 (utilisateur, critères hors cahier, sans MOD ; V1-STAB-02 à 8–10 %%) : autorité = vitesse minimale ' ...
              'équilibrée ≤ %s km/h à MS %s %%, 3S1P et 4S1P, au plus %s° vers le haut ; V1-PERF-01 tenue ; plus de fenêtre de croisière ; ' ...
              'V1-PERF-03/04/05 avec la traînée équilibrée à MS %s %%. Modèle : « %s ». Polaires des élevons : %s.\n'], ...
        fr(3.6*p.stab.V_aut_max, '%.0f'), fr(100*MSa, '%.0f'), fr(-p.stab.d_autorite, '%.0f'), fr(100*p.stab.MS_perf, '%.0f'), modeV, srcPol);
lig = strings(nVa + 1, 6);
lig(1, :) = ["Élevons des T2 (25 %, depuis 250 mm)", "—", "—", fr(effV(1), '%+.5f'), "—", fr(dgV(1), '%+.1f') + "°"];
for k = 1:nVa
    lig(k + 1, :) = [nomVa(k), fr(1000*largeur(k), '%.0f') + " mm", fr(1000*garde_hel(k), '%.1f') + " mm", fr(effV(k + 1), '%+.5f'), ...
                     fr(100*(effV(k + 1)/effV(1) - 1), '%+.0f') + " %", fr(dgV(k + 1), '%+.1f') + "°"];
end
tableau_md(fid, "§2 : variantes (Cm_δ à " + fr(3.6*Vr, '%.0f') + " km/h, 4S1P, MS " + fr(100*p.stab.MS_nom, '%.0f') + " %, vrillage " + fr(vrG(v5), '%.0f') + "°)", ...
    ["Élevons", "Fuselage central au plus (élevons entièrement sur les demi-ailes, sans jeu)", "Bord des élevons au disque de l'hélice (R = " + fr(1000*R_hel, '%.1f') + " mm)", ...
     "Cm_δ à l'équilibre [/°]", "Gain sur les T2", "δ_trim"], lig);
fprintf(fid, ['\n**Cm_δ incertain d''un facteur 2** (décision du 15/10/2026) : les polaires XFoil à charnière 65 %% et 75 %% ' ...
              's''écartent du rapport des profils minces, de façon localisée selon α, Re et δ (bulle de décollement probable). ' ...
              'À ne pas utiliser pour régler les gains sans essai en vol (AUTOTUNE).\n']);
[okT, iTab] = ismembertol(p.stab.vr_tableau, vrG, 1e-9);
assert(all(okT), 'vrillages des tableaux hors de la grille');
lig = strings(0, 7);
for k = 1:nVa
    for t = unique([iTab(:).', iSel(k)])
        cel = @(j) fr(3.6*VAa(k, t, j), '%.1f') + " (CL " + fr(CLa(k, t, j), '%.3f') + ", δ " + fr(dAa(k, t, j), '%+.1f') + "°, " + causeA(k, t, j) + ")";
        lig(end+1, :) = [nomVa(k), fr(vrG(t), '%+.2f') + "°" + ternaire(ok04(t), "", " (MOD-04 non tenue)") + ternaire(t == iOpt(k), " **retenu**", ""), ...
            cel(1), cel(2), ternaire(okVit(k, t), "tenu", "**non tenu**") + " ; n au lancer " + fr(n35(k, t, 1), '%.2f') + " / " + fr(n35(k, t, 2), '%.2f'), ...
            fr(3.6*VAa(k, t, 3), '%.1f') + " / " + fr(3.6*VAa(k, t, 4), '%.1f') + " km/h (" + ternaire(ok01(k, t), "tenue", "non tenue") + ")", ...
            ternaire(any(extA(k, t, :)), "oui", "non")]; %#ok<SAGROW>
    end
end
tableau_md(fid, "§3 : autorité, vitesse minimale équilibrée [km/h] à MS " + fr(100*MSa, '%.0f') + " % (limite « braquage » : butée de " + fr(-p.stab.d_autorite, '%.0f') + ...
    "° atteinte ; « bande » : décrochage d'une bande ; « polaires » : hors des polaires, V_min majorée)", ...
    ["Élevons", "Vrillage", "3S1P", "4S1P", "Critère ≤ " + fr(3.6*p.stab.V_aut_max, '%.0f') + " km/h ; n disponible à " + fr(3.6*p.stab.V_lancer, '%.0f') + " km/h (3S / 4S)", ...
     "V1-PERF-01 : 800 g ISA / jour chaud (≤ " + fr(3.6*p.req.Vs_max, '%.0f') + " km/h)", "Braquage au-delà des polaires"], lig);
lig = strings(nVa, 7);
for k = 1:nVa
    act = "—";                                                          % contrainte qui sépare le retenu de l'optimum libre
    if ~isnan(iOpt(k)) && iOpt(k) ~= iLibre(k)
        j = iOpt(k) + sign(iLibre(k) - iOpt(k));
        noms = ["MOD-04" "autorité" "V1-PERF-01" "équilibre en croisière"];
        act = strjoin(noms(~[ok04(j), okVit(k, j), ok01(k, j), okTrim(k, j)]), ", ") + " (non tenue à " + fr(vrG(j), '%+.2f') + "°)";
    end
    lig(k, :) = [nomVa(k), pl(vrG(okAut(k, :))), pl(vrG(ok01(k, :))), "**" + pl(vrG(okPass(k, :))) + "**", ...
        ternaire(isnan(iOpt(k)), "aucun (performances au " + fr(vrG(iSel(k)), '%+.2f') + "°, le plus proche)", fr(vrG(iSel(k)), '%+.2f') + "° (" + fr(Dmoy(k, iSel(k)), '%.3f') + " N)" + ...
                 ternaire(iOpt(k) == 1 || iOpt(k) == nVr, " — en bord de plage", "")), ...
        fr(vrG(iLibre(k)), '%+.2f') + "° (" + fr(Dmoy(k, iLibre(k)), '%.3f') + " N)" + ternaire(iLibre(k) == 1 || iLibre(k) == nVr, ", bord de la matrice des T2", "") + ...
        " ; optima des " + fr(nnz(iRg) * 2 * nVt, '%d') + " cas : " + fr(optCas(k, 1), '%+.2f') + " à " + fr(optCas(k, 2), '%+.2f') + "°", act];
end
tableau_md(fid, "§4 : choix du vrillage (règle E4 : moyenne des traînées de l'aile équilibrée à " + strjoin(fr(3.6*Vt, '%.0f'), " et ") + " km/h, 3S1P/4S1P, MS " + ...
    strjoin(fr(100*p.stab.MS_regle_vr, '%.0f'), "/") + " % ; MOD-04 limite " + fr(S.vr04, '%.2f') + "° ; grille de " + fr(p.stab.pas_vr, '%.2f') + "°)", ...
    ["Élevons", "Autorité (≤ " + fr(3.6*p.stab.V_aut_max, '%.0f') + " km/h) et MOD-04", "V1-PERF-01", "Passent (avec équilibre en croisière)", "Vrillage retenu", ...
     "Sans contrainte ; optima par cas", "Contrainte qui fixe le choix"], lig);
lig = strings(0, 5);
for k = 1:nVa
    t = iSel(k);
    Vop = p.req.k_Vmin_op * max(VAa(k, t, 1:2));                       % 1,2·V_min (phase 3 : 1,2·Vs), pire batterie
    lig(end+1, :) = [nomVa(k) + ", " + fr(vrG(t), '%+.2f') + "°", ...
        "3S1P / 4S1P : " + fr(CLa(k, t, 1), '%.3f') + " / " + fr(CLa(k, t, 2), '%.3f') + " ; 800 g : " + fr(CLa(k, t, 3), '%.3f'), ...
        fr(3.6*VAa(k, t, 3), '%.1f') + " km/h ISA, " + fr(3.6*VAa(k, t, 4), '%.1f') + " km/h jour chaud (phase 3, CL " + fr(p.aero.CLmax, '%.1f') + " : " + ...
        fr(3.6*sqrt(2 * p.masse.MTOW/1000 * c.g / (rho * p.geo.S * p.aero.CLmax)), '%.1f') + " / " + fr(3.6*sqrt(2 * p.masse.MTOW/1000 * c.g / (rhoH * p.geo.S * p.aero.CLmax)), '%.1f') + ")", ...
        "3S : " + fr(Vz(k, i3, 1), '%.2f') + " / " + fr(Vz(k, i3, 2), '%.2f') + " ; 4S : " + fr(Vz(k, iE, 1), '%.2f') + " / " + fr(Vz(k, iE, 2), '%.2f') + ...
        " m/s (phase 3 : " + fr(VzRef(i3, 1), '%.2f') + " / " + fr(VzRef(i3, 2), '%.2f') + " ; " + fr(VzRef(iE, 1), '%.2f') + " / " + fr(VzRef(iE, 2), '%.2f') + ")", ...
        fr(3.6*Vop, '%.1f') + " km/h ; " + fr(3.6*p.req.V_end_op, '%.0f') + " km/h = " + fr(p.req.V_end_op / max(VAa(k, t, 1:2)), '%.2f') + "·V_min"]; %#ok<SAGROW>
end
tableau_md(fid, "§3 bis : CL max équilibré (MS " + fr(100*MSa, '%.0f') + " %) à la place de l'hypothèse CL " + fr(p.aero.CLmax, '%.1f') + " de la phase 3", ...
    ["Élevons, vrillage", "CL max équilibré", "Vitesse minimale à 800 g (V1-PERF-01)", "V1-PERF-07 : montée plein gaz à 1,3·V_min, ISA / jour chaud (≥ 3 m/s)", ...
     "1,2·V_min (vitesse minimale d'utilisation de la phase 3), pire batterie, MS " + fr(100*MSa, '%.0f') + " %"], lig);
lig = strings(0, 9);
for k = 1:nVa
    for b = [iE i3]
        for ie = 1:nVe
            iv = find(abs(Vp - p.req.V_eta(ie)) < 1e-9);
            lig(end+1, :) = [nomVa(k), sprintf('%dS1P, %.0f km/h', p.batt.ns(b), 3.6*p.req.V_eta(ie)), fr(PO(k).CL(b, iv), '%.3f'), ...
                fr(PO(k).dg(b, iv), '%+.1f') + "°" + ternaire(PO(k).ext(b, iv), " (au-delà des polaires)", ""), fr(1e4*PO(k).CDi(b, iv), '%.1f'), ...
                fr(1e4*PO(k).CDp(b, iv), '%.1f'), fr(1e4*(PO(k).CDp(b, iv) - PO(k).CDp0(b, iv)), '%+.1f'), ...
                strjoin(fr(1e4*squeeze(CDP(k, :, b, ie)), '%.1f'), " / "), strjoin(fr(squeeze(etaP(k, :, b, ie)), '%.3f'), " / ")]; %#ok<SAGROW>
        end
    end
end
tableau_md(fid, "§5 : polaire équilibrée à MS " + fr(100*p.stab.MS_perf, '%.0f') + " % (masses de la phase 3 ; nacelle et winglets : " + fr(1e4*dCD_hors, '%.1f') + ...
    "e-4 = Cfe corrigé " + fr(S3.est.Cfe_corr, '%.4f') + " × " + fr(p.elv.Swet_hors_aile, '%.3f') + " m² / S)", ...
    ["Élevons", "Cas", "CL", "δ_trim", "CDi VLM [1e-4]", "CDp de l'aile [1e-4]", "dont surcoût des élevons [1e-4]", ...
     "CD total des polaires [1] à [5] [1e-4]", "η calculé, polaires [1] à [5]"], lig);
fprintf(fid, '\nPolaires : %s.\n', strjoin("[" + string(1:nPo) + "] " + nomP, " ; "));
lig = strings(0, nPo + 1);
for k = 1:nVa
    for r = 1:size(perf, 1)
        [b, ie, seuil, lib] = perf{r, :};
        cel = strings(1, nPo);
        for ip = 1:nPo
            t30 = tP(k, ip, b, ie, 2);  t20 = tP(k, ip, b, ie, 1);
            cel(ip) = fr(t30, '%.1f') + " à " + fr(t20, '%.1f') + " (" + fr(t30 - seuil, '%+.1f') + ")" + ...
                      ternaire(t30 >= seuil, "", ternaire(t20 >= seuil, " **à −20 % seulement**", " **non tenue**")) + ternaire(okP(k, ip, b, ie), "", " ; HORS THR_MAX");
        end
        lig(end+1, :) = [nomVa(k) + " — " + lib + " (≥ " + fr(seuil, '%.0f') + " min)", cel]; %#ok<SAGROW>
    end
end
tableau_md(fid, "§5 bis : autonomies réelles [min], −30 % à −20 % (écart au seuil à −30 %), modèle de la phase 3 (η calculé au point de vol, option " + rF.nom + ")", ...
    ["Exigence", "[" + string(1:nPo) + "] " + nomP], lig);
lig = strings(0, 5);
for i = 2:nC0
    for b = 1:2
        lig(end+1, :) = ["+" + fr(dC0(i), '%.2f'), sprintf('%dS1P', p.batt.ns(b)), ...
            strjoin(fr(squeeze(decal(i - 1, b, :, 1)).', '%+.2f'), " / ") + "° à " + fr(3.6*Vt(1), '%.0f') + " km/h ; " + ...
            strjoin(fr(squeeze(decal(i - 1, b, :, nVt)).', '%+.2f'), " / ") + "° à " + fr(3.6*Vt(nVt), '%.0f') + " km/h", ...
            fr(3.6*VC0(1, b), '%.1f') + " → " + fr(3.6*VC0(i, b), '%.1f') + " km/h (δ " + fr(dVC0(i, b), '%+.1f') + "°)", ...
            pl(vrG(ok04C(i, :)))]; %#ok<SAGROW>
    end
end
tableau_md(fid, "§6 : Cm0 visqueux du profil plus élevé (couple pur sur toutes les bandes ; ΔCm de l'aile = " + fr(facC0, '%.3f') + " × ΔCm0), " + nomVa(1) + ", vrillage " + fr(vrG(vC), '%+.2f') + "°", ...
    ["ΔCm0", "Batterie", "Décalage de δ_trim, MS " + strjoin(fr(100*MSt, '%.0f'), " / ") + " % (> 0 : moins vers le haut)", "V_min équilibrée à MS " + fr(100*MSa, '%.0f') + " %", ...
     "MOD-04 tenue (vrillages ; sans ΔCm0 : " + pl(vrG(ok04)) + ")"], lig);
fclose(fid);

save(fullfile(dRes, 'verdict.mat'), 'p', 'propres', 'manque', 'd_mes', 'kappa', 'nomVa', 'y0V', 'DV', 'effV', 'dgV', 'largeur', 'garde_hel', ...
     'nomA', 'CLa', 'VAa', 'dAa', 'causeA', 'extA', 'okVit', 'okAut', 'ok01', 'n35', 'MSt', 'Vt', 'dT', 'Dt', 'extT', 'okTrim', 'Dmoy', 'okPass', ...
     'iOpt', 'iSel', 'iLibre', 'optCas', 'Vp', 'PO', 'dCD_hors', 'nomP', 'tP', 'etaP', 'dP', 'okP', 'CDP', 'Vz', 'Vm', 'VzRef', ...
     'dC0', 'facC0', 'dTC', 'decal', 'VC0', 'dVC0', 'ok04C');
fprintf('Résultats : %s (tableaux_verdict.md, verdict.mat)\n', dRes);

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

function d = braquage_mesure(q, pf, xh)
% Braquage du volet [deg] mesuré sur la ligne moyenne derrière la charnière, contre le profil de base
dz = (q.yu + q.yl) / 2 - (pf.yu + pf.yl) / 2;
arr = q.xs > xh + 0.05 & q.xs < 0.98;
cP = polyfit(q.xs(arr) - xh, dz(arr), 1);
d = -atand(cP(1));
end

function aero = aero_table(base, CL, CD)
% Polaire tabulée CD(CL) au format de la phase 3 (polaire.m, type "xflr5")
[CL, o] = sort(CL(:));
CD = CD(:);
CD = CD(o);
aero = base;
aero.type = "xflr5";
aero.table = table(CL, CD, 'VariableNames', {'CL', 'CD'});
aero.CLmax = CL(end);
aero.CD0 = min(CD);
end

function [Vz, Vm] = montee(rF, b, m, rho, aero, p)
% V1-PERF-07 comme dimensionnement.m §4c : plein gaz (THR_MAX) à 1,3·Vs, tension nominale (C1 p.79)
Vm = p.req.k_Vmontee * sqrt(2 * m * p.const.g / (rho * p.geo.S * aero.CLmax));
r = point_propulsif(rF.mot, rF.hel{b}, p.batt.ns(b), p.batt.V_nom, rho, Vm, "gaz", rF.thr(b), p);
[~, Pn] = puissance_requise(Vm, m, rho, p.geo.S, aero, 1, 0, p.const);
Vz = (r.T * Vm - Pn) / (m * p.const.g);
end
