%T7_PHASE4  Phase 4 — T7 (V1-STAB-04) : avions et analyses de stabilité xflr5 (16/10/2026).
%
%   Script autonome, exécuté après cloture_phase4.m (relit resultats/phase4.mat, verdict.mat,
%   cloture.mat). Décision de l'utilisateur du 16/10/2026 (option 1) : 4 avions (3S1P/4S1P ×
%   MS 8/10 %), élevons portés par le profil p.clo.d_T7 (« S5010 c65 elv-3 »), aile et longeron
%   répartis en p.clo.n_bandes bandes par demi-aile pour les inerties Ixx et Izz.
%   Avec p.clo.d_T7 = p.clo.d_T7_filet, le même script génère le T7 de rattrapage (les noms
%   portent le braquage). CG à x_NP visqueux − MS·MAC (comme T2 et fiche de gel) ; la batterie
%   est placée par position_batterie.
%   xflr5 équilibre le T7 sur son Cm VLM, sans la correction visqueuse en bandes : on imprime
%   la vitesse d'équilibre et la marge attendues par xflr5 (modèle "vlm"), à comparer à ses sorties.
%   HORS SKILL : VLM (xflr5), modèle d'élevons.
%   Sorties : xflr5/genere/avion_*_T7_*.xml, analyse_T7_*.xml, resultats/t7_attendu.mat,
%             resultats/tableaux_T7_avions.md

clear; close all;
racine = fileparts(mfilename('fullpath'));
rac3   = fullfile(fileparts(racine), '03_predimensionnement');
addpath(fullfile(racine, 'fonctions'), rac3, fullfile(rac3, 'fonctions'));
dRes = fullfile(racine, 'resultats');

p = params_v1();
dGen = fullfile(racine, p.xfl.dossier_genere);
c = p.const;
fprintf('\n===== PHASE 4 — T7 (V1-STAB-04) : AVIONS ET ANALYSES, braquage %+d° =====\n', p.clo.d_T7);

%% §1 Géométrie retenue (identique à cloture_phase4.m)
S  = load(fullfile(dRes, 'phase4.mat'), 'atm', 'mTot', 'xref', 'vrG', 'xNPv11', 'B', 'gp', 'mb');
Vd = load(fullfile(dRes, 'verdict.mat'), 'DV', 'iOpt', 'y0V');
Cl = load(fullfile(dRes, 'cloture.mat'), 'vr', 'VE', 'dC', 'MS');
vO = Vd.iOpt(1);
vr = S.vrG(vO);
assert(abs(vr - Cl.vr) < 1e-12 && isequal(Cl.MS, p.stab.MS_vol1), 'cloture.mat ne correspond plus à params_v1');
pk = p;
pk.geo4.y_sec    = [0, p.elv.y0(end), p.geo.b/2];
pk.geo4.y_elevon = [p.elv.y0(end), p.geo.b/2];
gk = geometrie_aile(pk, p.geo4.fleche_BA, vr);
rho = S.atm(1).rho;
[~, nu1] = reynolds(1, 1, rho, S.atm(1).T, c);
pe = sprintf(p.elv.nom_c65, p.clo.d_T7);
jd = find(Cl.dC == p.clo.d_T7, 1);
assert(~isempty(jd), 'braquage %d° absent de cloture.mat (p.clo.d_T7_cand)', p.clo.d_T7);
Mk = masses_composants(p, gk, S.B, S.gp, p.clo.n_bandes);
nb = ["3S" "4S"];
MS = p.stab.MS_vol1;

%% §2 Marge d'xflr5 : son point neutre VLM (T2 de contrôle δ = 0, polaire exportée)
Cc = load(fullfile(dRes, 'cloture.mat'), 'nomT2', 'cgT');
P0 = lire_polaire_T2(fullfile(racine, p.clo.dossier_T2, "T2inv-VLM2_" + strrep(strrep(Cc.nomT2(1), 'V1_S5010_', ''), '_', '-') + ".txt"));
N0 = xnp_polaire(P0, Cc.cgT(1), gk.MAC);
fprintf('x_NP VLM (xflr5) %.1f mm contre x_NP visqueux %.1f mm\n', 1000*N0.x_NP_Cm, 1000*S.xNPv11(vO));

%% §3 Avions et analyses T7
nom = strings(2, 2);  xCG = zeros(2, 2);  xb = xCG;  mT = xCG;  MSx = xCG;  VX = xCG;
Ixx = xCG;  Iyy = xCG;  Izz = xCG;
for b = 1:2
    for i = 1:2
        xCG(b, i) = S.xNPv11(vO) - MS(i) * gk.MAC;
        xb(b, i) = position_batterie(Mk, S.mb(b), xCG(b, i));
        MkB = [Mk; cell2table({"Batterie " + nb(b) + "1P", S.mb(b), xb(b, i), 0, 0}, 'VariableNames', Mk.Properties.VariableNames)];
        cg = [sum(MkB.m .* MkB.x), 0, sum(MkB.m .* MkB.z)] / sum(MkB.m);
        assert(abs(cg(1) - xCG(b, i)) < 1e-9, 'CG ≠ cible');
        mT(b, i) = sum(MkB.m);
        assert(abs(mT(b, i) - S.mTot(b)) < 1e-9, 'masse ≠ phase4.mat');
        nom(b, i) = sprintf('V1_%s_vr%s_T7_%s_MS%d_d%d', upper(p.xfl.profil_retenu), strrep(sprintf('%g', abs(vr)), '.', ''), nb(b), round(100*MS(i)), abs(p.clo.d_T7));
        ecrire_avion_xml(fullfile(dGen, "avion_" + nom(b, i) + ".xml"), nom(b, i), gk, p.xfl.profil_retenu, MkB, pk, pe);
        a = struct('methode', p.xfl.methode_T2, 'rho', rho, 'nu', nu1, 'S', gk.S, 'b', p.geo.b, 'MAC', gk.MAC, ...
                   'm', mT(b, i), 'cg', cg, 'visqueux', false, 'stabilite', true);
        ecrire_analyse_xml(fullfile(dGen, "analyse_T7_" + nom(b, i) + ".xml"), "T7-" + p.xfl.methode_T2, nom(b, i), a);
        MSx(b, i) = (N0.x_NP_Cm - xCG(b, i)) / gk.MAC;
        VX(b, i) = Cl.VE(b, i, 1, jd);
        % Inerties de la table de masses (axes par rapport au CG), pour comparer à celles d'xflr5
        dxm = MkB.x - cg(1);  dym = MkB.y - cg(2);  dzm = MkB.z - cg(3);
        Ixx(b, i) = sum(MkB.m .* (dym.^2 + dzm.^2));
        Iyy(b, i) = sum(MkB.m .* (dxm.^2 + dzm.^2));
        Izz(b, i) = sum(MkB.m .* (dxm.^2 + dym.^2));
        fprintf('  %-34s m %.1f g | CG %.1f mm | batterie %.1f mm | MS (xflr5) %.1f %% | V équilibre xflr5 attendue %.1f km/h\n', ...
                nom(b, i), 1000*mT(b, i), 1000*xCG(b, i), 1000*xb(b, i), 100*MSx(b, i), VX(b, i));
    end
end
dansPlage = VX >= 3.6*p.clo.V_T7(1) & VX <= 3.6*p.clo.V_T7(2);
fprintf('Vitesse d''équilibre attendue dans xflr5 : %d avion(s) sur 4 dans %.0f–%.0f km/h (braquage %+d°)\n', ...
        sum(dansPlage(:)), 3.6*p.clo.V_T7, p.clo.d_T7);

%% Tableau
fid = fopen(fullfile(dRes, 'tableaux_T7_avions.md'), 'w', 'n', 'UTF-8');
fprintf(fid, '# T7 de V1-STAB-04 : avions générés (généré par t7_phase4.m)\n\n');
fprintf(fid, 'Profil des élevons : `%s`. Analyse `T7-%s` (Stability polar, **Viscous décochée**, gains de commande nuls). ', pe, p.xfl.methode_T2);
fprintf(fid, 'Aile et longeron en %d bandes par demi-aile.\n\n', p.clo.n_bandes);
lig = strings(4, 10);  r = 0;
for b = 1:2
    for i = 1:2
        r = r + 1;
        lig(r, :) = [nom(b, i), fr(1000*mT(b, i), '%.1f'), fr(1000*xCG(b, i), '%.1f'), fr(1000*xb(b, i), '%.1f'), fr(100*MSx(b, i), '%.1f'), ...
                     fr(VX(b, i), '%.1f'), fr(1e3*Ixx(b, i), '%.2f'), fr(1e3*Iyy(b, i), '%.2f'), fr(1e3*Izz(b, i), '%.2f'), fr(100*MS(i), '%.0f')];
    end
end
tableau_md(fid, "Avions du T7 (repère du BA de l'emplanture)", ["Avion", "Masse [g]", "x_CG [mm]", "x batterie [mm]", ...
    "MS vue par xflr5 [%]", "V équilibre attendue (xflr5) [km/h]", "Ixx [g·m²]", "Iyy [g·m²]", "Izz [g·m²]", "MS visée [%]"], lig);
fprintf(fid, ['\nLa MS « vue par xflr5 » est celle de son point neutre VLM (%s mm), plus avancé que le point neutre ' ...
              'visqueux (%s mm). La vitesse attendue est celle du modèle « vlm » (équilibre sur le Cm VLM seul).\n'], ...
        fr(1000*N0.x_NP_Cm, '%.1f'), fr(1000*S.xNPv11(vO), '%.1f'));
fclose(fid);
save(fullfile(dRes, 't7_attendu.mat'), 'nom', 'xCG', 'xb', 'mT', 'MSx', 'VX', 'Ixx', 'Iyy', 'Izz', 'vr');
fprintf('Résultats : %s (tableaux_T7_avions.md, t7_attendu.mat)\n', dRes);

%% Fonctions locales
function s = fr(x, fmt)
% Nombre(s) formaté(s) avec la virgule décimale française
s = string(strrep(compose(fmt, x), '.', ','));
end
