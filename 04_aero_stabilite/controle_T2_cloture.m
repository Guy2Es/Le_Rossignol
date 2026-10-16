%CONTROLE_T2_CLOTURE  Compare les T2 de contrôle (xflr5) au modèle "vlm" de cm_elevons (15/10/2026).
%
%   Script autonome, après cloture_phase4.m. Lit les deux polaires exportées de
%   xflr5/exports/T2/Cloture/ (profil S5010 puis profil c65 braqué à −6°), calcule le Cm0,
%   la pente dCm/dCL, x_NP et l'incrément de Cm dû au braquage, et les compare au modèle
%   cm_elevons en mode "vlm" (VLM seule : c'est ce que xflr5 calcule) sur la géométrie retenue.
%   Sortie : resultats/tableaux_controle_T2.md
%   HORS SKILL : VLM (xflr5), modèle d'élevons de cm_elevons.

clear; close all;
racine = fileparts(mfilename('fullpath'));
rac3   = fullfile(fileparts(racine), '03_predimensionnement');
addpath(fullfile(racine, 'fonctions'), rac3, fullfile(rac3, 'fonctions'));
dRes = fullfile(racine, 'resultats');
p = params_v1();

S = load(fullfile(dRes, 'phase4.mat'), 'xref');
Vd = load(fullfile(dRes, 'verdict.mat'), 'DV');
C = load(fullfile(dRes, 'cloture.mat'), 'vr', 'nomT2', 'cgT');
D = Vd.DV{1};
nT2 = numel(C.nomT2);
assert(nT2 == 2 && isequal(p.clo.d_T2, [0 -6]), 'contrôle prévu pour δ = 0 et −6°');
dossier = fullfile(racine, p.clo.dossier_T2);
MAC = D.MAC;
dx = (C.cgT(1) - S.xref) / MAC;                       % Cm_G = Cm_ref + CL·dx
fprintf('\n===== CONTRÔLE T2 DE CLÔTURE : xflr5 contre modèle "vlm" =====\n');

P = cell(1, nT2);
pol = strings(nT2, 5);
for j = 1:nT2
    P{j} = lire_polaire_T2(fullfile(dossier, "T2inv-VLM2_" + strrep(strrep(C.nomT2(j), 'V1_S5010_', ''), '_', '-') + ".txt"));
    assert(P{j}.avion == C.nomT2(j), 'avion lu « %s » ≠ « %s »', P{j}.avion, C.nomT2(j));
    N = xnp_polaire(P{j}, C.cgT(1), MAC);
    c = polyfit(P{j}.CL, P{j}.Cm, 1);
    pol(j, :) = [C.nomT2(j), fr(c(2), '%.5f'), fr(c(1), '%.4f'), fr(1000*N.x_NP_Cm, '%.1f'), fr(1000*N.x_NP_xcp, '%.1f')];
    fprintf('  %-24s Cm0 %+.5f | dCm/dCL %.4f | x_NP (Cm) %.1f mm, (XCP) %.1f mm\n', ...
            C.nomT2(j), c(2), c(1), 1000*N.x_NP_Cm, 1000*N.x_NP_xcp);
end

CLs = p.clo.CL_ctrl(:);
n = numel(CLs);
cx = zeros(n, nT2);  cm = cx;
for j = 1:nT2
    cx(:, j) = interp1(P{j}.CL, P{j}.Cm, CLs);
    for k = 1:n
        R = cm_elevons(p.clo.d_T2(j), CLs(k), 10, C.vr, "vlm", D);
        cm(k, j) = R.Cm + CLs(k) * dx;
    end
end
assert(~any(isnan(cx), 'all'), 'CL de comparaison hors des polaires');
dX = cx(:, 2) - cx(:, 1);  dM = cm(:, 2) - cm(:, 1);
ecart = 100 * (dM ./ dX - 1);
lig = strings(n, 6);
for k = 1:n
    lig(k, :) = [fr(CLs(k), '%.1f'), fr(cx(k, 1), '%+.5f'), fr(cm(k, 1), '%+.5f'), fr(dX(k), '%.5f'), fr(dM(k), '%.5f'), fr(ecart(k), '%+.1f')];
end
fprintf('  Incrément de Cm dû au braquage (−6°) : xflr5 %.5f à %.5f ; modèle %.5f à %.5f ; écart du modèle %+.1f à %+.1f %%\n', ...
        min(dX), max(dX), min(dM), max(dM), min(ecart), max(ecart));
fprintf('  Cm à δ = 0 : écart modèle − xflr5 de %+.5f à %+.5f\n', min(cm(:,1) - cx(:,1)), max(cm(:,1) - cx(:,1)));

fid = fopen(fullfile(dRes, 'tableaux_controle_T2.md'), 'w', 'n', 'UTF-8');
fprintf(fid, '# Contrôle T2 de clôture (généré par controle_T2_cloture.m)\n\n');
tableau_md(fid, "Polaires xflr5 (VLM non visqueuse, CG x = " + fr(1000*C.cgT(1), '%.1f') + " mm)", ...
           ["Avion", "Cm0", "dCm/dCL", "x_NP par Cm [mm]", "x_NP par XCP [mm]"], pol);
fprintf(fid, '\n');
tableau_md(fid, "xflr5 contre modèle « vlm » (Cm au CG ; ΔCm = Cm(−6°) − Cm(0))", ...
           ["CL", "Cm xflr5 (δ=0)", "Cm modèle (δ=0)", "ΔCm xflr5", "ΔCm modèle", "écart ΔCm [%]"], lig);
fclose(fid);
fprintf('Résultats : %s\n', fullfile(dRes, 'tableaux_controle_T2.md'));

function s = fr(x, fmt)
% Nombre(s) formaté(s) avec la virgule décimale française
s = string(strrep(compose(fmt, x), '.', ','));
end
