%FICHE_GEL_PHASE4  Fiche de gel de la géométrie V1 à la clôture de la phase 4 (16/10/2026).
%
%   Script autonome, après verdict_elevons.m, cloture_phase4.m et controle_T2_cloture.m.
%   Rassemble ce que MATLAB a calculé : géométrie retenue, masses, CG et position des batteries
%   (3S1P/4S1P × MS 8/9/10 %), contrôle T2 de xflr5, état des exigences V1-STAB.
%   V1-STAB-04 (T7) reste ouverte tant que les exports xflr5 de type 7 manquent.
%   Sortie : resultats/fiche_gel_phase4.md
%   HORS SKILL : VLM, bandes, profils minces, Weissinger (voir les scripts d'origine).

clear; close all;
racine = fileparts(mfilename('fullpath'));
rac3   = fullfile(fileparts(racine), '03_predimensionnement');
addpath(fullfile(racine, 'fonctions'), rac3, fullfile(rac3, 'fonctions'));
dRes = fullfile(racine, 'resultats');
p = params_v1();

S  = load(fullfile(dRes, 'phase4.mat'), 'mTot', 'xref', 'xNPv11', 'B', 'gp', 'mb');
Vd = load(fullfile(dRes, 'verdict.mat'), 'iOpt', 'nomVa', 'y0V');
C  = load(fullfile(dRes, 'cloture.mat'), 'vr', 'cgT', 'VE', 'dans', 'dC', 'MS', 'nomT2');
vO = Vd.iOpt(1);
pk = p;
pk.geo4.y_sec    = [0, p.elv.y0(end), p.geo.b/2];
pk.geo4.y_elevon = [p.elv.y0(end), p.geo.b/2];
gk = geometrie_aile(pk, p.geo4.fleche_BA, C.vr);
Mk = masses_composants(p, gk, S.B, S.gp);
x0 = sum(Mk.m .* Mk.x) / sum(Mk.m);
xNP = S.xNPv11(vO);
nb = ["3S1P" "4S1P"];
MSt = unique([C.MS, p.stab.MS_nom]);                     % MS 8, 9, 10 %
n = numel(MSt);

lig = strings(2 * n, 6);
xbs = zeros(2, n);
r = 0;
for b = 1:2
    for i = 1:n
        xCG = xNP - MSt(i) * gk.MAC;
        xb = position_batterie(Mk, S.mb(b), xCG);
        xbs(b, i) = xb;
        r = r + 1;
        lig(r, :) = [nb(b), fr(100*MSt(i), '%.0f'), fr(1000*S.mTot(b), '%.1f'), fr(1000*xCG, '%.1f'), ...
                     fr(1000*xb, '%.1f'), fr(1000*(xNP - xCG), '%.1f')];
    end
end
ecart = abs(xbs(1, :) - xbs(2, :));                        % écart 3S/4S à chaque MS
fprintf('Géométrie : S %.4f m², MAC %.1f mm, vrillage %+.2f°, élevons %s ; x_NP visqueux %.1f mm\n', ...
        gk.S, 1000*gk.MAC, C.vr, Vd.nomVa(1), 1000*xNP);
fprintf('CG sans batterie %.1f mm ; écart des batteries 3S/4S : %.1f / %.1f / %.1f mm (MS 8 / 9 / 10 %%)\n', ...
        1000*x0, 1000*ecart);

fid = fopen(fullfile(dRes, 'fiche_gel_phase4.md'), 'w', 'n', 'UTF-8');
fprintf(fid, '# Fiche de gel V1 — clôture de la phase 4 (générée par fiche_gel_phase4.m, 16/10/2026)\n\n');
fprintf(fid, ['Écart à la skill : modèles hors skill (VLM xflr5, bandes, profils minces, Weissinger). ' ...
              'Le cahier des charges n''est pas modifié ; les MOD restent en brouillon sauf MOD-04.\n\n']);
fprintf(fid, '## 1. Géométrie gelée\n\n');
fprintf(fid, '| Paramètre | Valeur |\n| --- | --- |\n');
fprintf(fid, '| Envergure / surface / MAC | %s m / %s m² / %s mm |\n', fr(p.geo.b, '%.3f'), fr(gk.S, '%.4f'), fr(1000*gk.MAC, '%.1f'));
fprintf(fid, '| Flèche du bord d''attaque | %s° |\n', fr(p.geo4.fleche_BA, '%.0f'));
fprintf(fid, '| Profil | %s |\n', p.xfl.nom_xflr5.(p.xfl.profil_retenu));
fprintf(fid, '| Vrillage au saumon (règle E4, MOD-04) | %s° |\n', fr(C.vr, '%+.2f'));
fprintf(fid, '| Élevons | %s ; %s %% de corde depuis y = %s mm |\n', Vd.nomVa(1), fr(100*(1 - p.elv.charniere_c65), '%.0f'), fr(1000*p.elv.y0(end), '%.0f'));
fprintf(fid, '| x_NP visqueux (correction en bandes) | %s mm |\n', fr(1000*xNP, '%.1f'));
fprintf(fid, '| CG sans batterie | %s mm |\n\n', fr(1000*x0, '%.1f'));
fprintf(fid, '## 2. Masses, CG et position de la batterie (CG = x_NP visqueux − MS·MAC ; repère du BA de l''emplanture)\n\n');
tableau_md(fid, "Centrage", ["Batterie", "MS [%]", "Masse [g]", "x_CG [mm]", "x batterie [mm]", "x_NP − x_CG [mm]"], lig);
fprintf(fid, '\nÉcart des positions de batterie 3S/4S : %s / %s / %s mm à MS 8 / 9 / 10 %% (écart total admis : 30 mm pour V1-STAB-03 de ± 15 mm, 40 mm pour MOD-05 en brouillon de ± 20 mm).\n\n', ...
        fr(1000*ecart(1), '%.1f'), fr(1000*ecart(2), '%.1f'), fr(1000*ecart(3), '%.1f'));
fprintf(fid, '## 3. Contrôle T2 de clôture (xflr5 contre modèle « vlm »)\n\n');
fprintf(fid, 'Voir `tableaux_controle_T2.md` : l''incrément de Cm dû à 6° d''élevons concorde à 0,5–1,0 %% près ; le modèle « vlm » reproduit xflr5.\n\n');
fprintf(fid, '## 4. État des exigences\n\n');
fprintf(fid, '| Exigence | État | Remarque |\n| --- | --- | --- |\n');
fprintf(fid, '| V1-STAB-01 | MOD-04 validée | Cm(CL = 0) de l''aile complète |\n');
fprintf(fid, '| V1-STAB-02 | 8 à 10 %% | inchangée, aucune MOD |\n');
fprintf(fid, '| V1-STAB-03 | MOD-05 en brouillon | écart ci-dessus |\n');
fprintf(fid, '| V1-STAB-04 | **OUVERTE** | T7 non lancé : profil à braquer en attente de décision |\n\n');
fprintf(fid, ['Cm_δ incertain d''un facteur 2 (polaires XFoil à charnière 65 %% et 75 %%, bulle de décollement) : ' ...
              'à ne pas utiliser pour régler les gains sans essai en vol.\n']);
fclose(fid);
fprintf('Résultats : %s\n', fullfile(dRes, 'fiche_gel_phase4.md'));

function s = fr(x, fmt)
% Nombre(s) formaté(s) avec la virgule décimale française
s = string(strrep(compose(fmt, x), '.', ','));
end
