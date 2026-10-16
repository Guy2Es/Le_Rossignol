%CLOTURE_PHASE4  Phase 4 — clôture : T2 de contrôle et préparation du T7 (15/10/2026).
%
%   Script autonome, exécuté après verdict_elevons.m (relit resultats/phase4.mat et
%   resultats/verdict.mat). Décision de l'utilisateur du 15/10/2026 :
%     T2 de contrôle : géométrie retenue (vrillage de la règle E4, élevons de 35 % depuis
%                      y = p.elv.y0(end)), δ = 0 et profil c65 braqué à −6°, VLM non visqueuse ;
%     T7 (V1-STAB-04), option T7-3 : 4 avions (3S1P/4S1P × MS 8/10 %), chacun avec le profil
%                      c65 braqué dont l'équilibre tombe dans p.clo.V_T7. Critères : ζ incidence
%                      > 0,4, ζ roulis hollandais > 0,1, T2 spirale ≥ 4 s (no-go en dessous).
%     §1 Géométrie retenue
%     §2 T2 de contrôle : avions et analyses (xflr5/genere/)
%     §3 Vitesse d'équilibre de chaque profil c65 candidat : xflr5 (VLM seule, sans la
%        correction visqueuse en bandes : contrôle C2) et avion réel (modèle "complet")
%   HORS SKILL : VLM, bandes, profils minces, Weissinger.
%   Sorties : xflr5/genere/*_c65_*.xml, resultats/tableaux_cloture.md

clear; close all;
racine = fileparts(mfilename('fullpath'));
rac3   = fullfile(fileparts(racine), '03_predimensionnement');
addpath(fullfile(racine, 'fonctions'), rac3, fullfile(rac3, 'fonctions'));
dRes = fullfile(racine, 'resultats');

p = params_v1();
dGen = fullfile(racine, p.xfl.dossier_genere);
c = p.const;
fprintf('\n===== PHASE 4 — CLÔTURE : T2 DE CONTRÔLE ET PRÉPARATION DU T7 (15/10/2026) =====\n');

%% §1 Géométrie retenue
S  = load(fullfile(dRes, 'phase4.mat'), 'atm', 'mTot', 'xref', 'cE', 'vrG', 'xNPv11', 'B', 'gp', 'mb');
Vd = load(fullfile(dRes, 'verdict.mat'), 'DV', 'iOpt', 'nomVa', 'y0V');
assert(abs(Vd.y0V(1) - p.elv.y0(end)) < 1e-12, 'verdict.mat : la 1re variante n''est pas la variante retenue');
vO = Vd.iOpt(1);
vr = S.vrG(vO);
D  = Vd.DV{1};
% Stations : emplanture, début des élevons retenus, saumon (aile trapézoïdale inchangée)
pk = p;
pk.geo4.y_sec    = [0, p.elv.y0(end), p.geo.b/2];
pk.geo4.y_elevon = [p.elv.y0(end), p.geo.b/2];
gk = geometrie_aile(pk, p.geo4.fleche_BA, vr);
g0 = geometrie_aile(p, p.geo4.fleche_BA, vr);
assert(abs(gk.S - g0.S) < 1e-12 && abs(gk.MAC - g0.MAC) < 1e-12, 'stations ajoutées : surface ou MAC modifiée');
rho = S.atm(1).rho;
[~, nu1] = reynolds(1, 1, rho, S.atm(1).T, c);
q1 = rho * p.geo.S / 2;
mg = S.mTot(:) * c.g;                                                   % N : 3S1P ; 4S1P
nomPr = p.xfl.nom_xflr5.(p.xfl.profil_retenu);
fprintf('§1 vrillage retenu %+.2f° (règle E4) ; élevons %s (charnière %.0f %%) ; S %.4f m², MAC %.1f mm\n', ...
        vr, Vd.nomVa(1), 100*p.elv.charniere_c65, gk.S, 1000*gk.MAC);

%% §2 T2 de contrôle : mêmes règles que les T2 à élevons de l'arrêt B (4S1P, batterie à MS p.stab.MS_T2
% avec le foyer de la skill, VLM non visqueuse)
Mk = masses_composants(p, gk, S.B, S.gp);
xb = position_batterie(Mk, S.mb(2), gk.xF_sk - p.stab.MS_T2 * gk.MAC);
MkB = [Mk; cell2table({"Batterie 4S1P (position provisoire)", S.mb(2), xb, 0, 0}, 'VariableNames', Mk.Properties.VariableNames)];
cgT = [sum(MkB.m .* MkB.x), 0, sum(MkB.m .* MkB.z)] / sum(MkB.m);
nT2 = numel(p.clo.d_T2);
nomT2 = strings(1, nT2);
for j = 1:nT2
    d = p.clo.d_T2(j);
    pe = ternaire(d == 0, nomPr, sprintf(p.elv.nom_c65, d));
    nomT2(j) = sprintf('V1_%s_vr%s_c65_e%d', upper(p.xfl.profil_retenu), strrep(sprintf('%g', abs(vr)), '.', ''), abs(d));
    ecrire_avion_xml(fullfile(dGen, "avion_" + nomT2(j) + ".xml"), nomT2(j), gk, p.xfl.profil_retenu, MkB, pk, pe);
    a = struct('methode', p.xfl.methode_T2, 'rho', rho, 'nu', nu1, 'S', gk.S, 'b', p.geo.b, ...
               'MAC', gk.MAC, 'm', sum(MkB.m), 'cg', cgT, 'visqueux', false);
    ecrire_analyse_xml(fullfile(dGen, "analyse_T2inv_" + nomT2(j) + ".xml"), "T2inv-" + p.xfl.methode_T2, nomT2(j), a);
end
fprintf('§2 T2 de contrôle : %s ; masse %.1f g, CG x = %.1f mm (batterie à %.1f mm)\n', ...
        strjoin(nomT2, ", "), 1000*sum(MkB.m), 1000*cgT(1), 1000*xb);

%% §3 Vitesse d'équilibre des profils c65 candidats (T7-3), 3S1P/4S1P × MS 8/10 %
Vk = p.clo.V_grille(1):p.clo.V_grille(3):p.clo.V_grille(2);
MS = p.stab.MS_vol1;
nb = ["3S1P" "4S1P"];
modes = ["vlm" "complet"];
dC = p.clo.d_T7_cand;
VE = NaN(2, numel(MS), numel(modes), numel(dC));                       % km/h
for b = 1:2
    for i = 1:numel(MS)
        dx = (S.xNPv11(vO) - MS(i) * gk.MAC - S.xref) / gk.MAC;          % CG à x_NP visqueux − MS·MAC
        for m = 1:numel(modes)
            dT = NaN(size(Vk));
            for k = 1:numel(Vk)
                dT(k) = delta_equilibre(mg(b) / (q1 * Vk(k)^2), Vk(k), vr, dx, modes(m), D, -5, p.stab.d_lim);
            end
            ok = ~isnan(dT);
            assert(all(diff(dT(ok)) > 0), 'δ_trim(V) non monotone : vitesse d''équilibre ambiguë');
            VE(b, i, m, :) = interp1(dT(ok), 3.6 * Vk(ok), dC);         % NaN : équilibre hors de la grille
        end
    end
end
dans = VE >= 3.6 * p.clo.V_T7(1) & VE <= 3.6 * p.clo.V_T7(2);
fprintf('§3 Vitesse d''équilibre [km/h] (grille %.0f à %.0f km/h ; « — » : hors grille), plage visée %.0f à %.0f km/h\n', ...
        3.6*Vk(1), 3.6*Vk(end), 3.6*p.clo.V_T7);
lig = strings(2 * numel(MS) * numel(modes), 2 + numel(dC));
r = 0;
for b = 1:2
    for i = 1:numel(MS)
        for m = 1:numel(modes)
            cel = arrayfun(@(j) vit(VE(b, i, m, j)) + ternaire(dans(b, i, m, j), " ✓", ""), 1:numel(dC));
            r = r + 1;
            lig(r, :) = [nb(b) + ", MS " + fr(100*MS(i), '%.0f') + " %", ...
                             ternaire(m == 1, "xflr5 (VLM seule)", "avion réel (complet)"), cel];
            fprintf('  %-16s %-22s %s\n', lig(r, 1), lig(r, 2), strjoin(compose('δ %+d° : %s', dC(:), cel(:)), ' | '));
        end
    end
end

%% Tableaux
fid = fopen(fullfile(dRes, 'tableaux_cloture.md'), 'w', 'n', 'UTF-8');
fprintf(fid, '# Phase 4 — clôture (généré par cloture_phase4.m)\n\n');
fprintf(fid, 'Géométrie retenue : vrillage %s° (règle E4), élevons %s, charnière à %s %% de corde.\n\n', ...
        fr(vr, '%+.2f'), Vd.nomVa(1), fr(100*p.elv.charniere_c65, '%.0f'));
fprintf(fid, '### T2 de contrôle (VLM non visqueuse, 4S1P, CG x = %s mm)\n\n', fr(1000*cgT(1), '%.1f'));
for j = 1:nT2
    fprintf(fid, '- `%s` : δ = %s°\n', nomT2(j), fr(p.clo.d_T2(j), '%+.0f'));
end
fprintf(fid, '\n');
tableau_md(fid, "Vitesse d'équilibre [km/h] par profil c65 braqué (✓ : dans " + fr(3.6*p.clo.V_T7(1), '%.0f') + " à " + ...
    fr(3.6*p.clo.V_T7(2), '%.0f') + " km/h ; CG à x_NP visqueux − MS·MAC)", ["Cas", "Modèle", "δ " + compose('%+d', dC) + "°"], lig);
fprintf(fid, ['\nxflr5 équilibre le T7 sur son Cm VLM, sans la correction visqueuse en bandes (contrôle C2) : ' ...
              'la ligne « xflr5 » est la vitesse à laquelle il calculera les modes ; la ligne « avion réel » est celle ' ...
              'de l''avion au même braquage.\n']);
fclose(fid);
save(fullfile(dRes, 'cloture.mat'), 'vr', 'nomT2', 'cgT', 'xb', 'VE', 'dans', 'dC', 'MS');
fprintf('Résultats : %s (tableaux_cloture.md, cloture.mat)\n', dRes);

%% Fonctions locales
function s = fr(x, fmt)
% Nombre(s) formaté(s) avec la virgule décimale française
s = string(strrep(compose(fmt, x), '.', ','));
end

function s = vit(V)
if isnan(V), s = "—"; else, s = fr(V, '%.1f'); end
end

function s = ternaire(cond, a, b)
if cond, s = a; else, s = b; end
end
