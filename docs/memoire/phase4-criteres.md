---
name: phase4-criteres
description: "Phase 4 (xflr5, stabilité aile volante V1) : outils, profils et critères go/no-go fixés par l'utilisateur le 13/10/2026"
metadata:
  node_type: memory
  type: project
  originSessionId: 2840dfa1-b0d3-4cbc-b05d-dee867db72d0
  modified: 2026-10-15T21:51:30.730Z
---

Décisions du 13/10/2026, phase 4 (branche `phase4-aero-stabilite`, dossier `04_aero_stabilite/`) :
- **Outils :** l'utilisateur pilote xflr5 v6.62 (`D:\IPSA_share\Aero_modelling\xflr5_v6.62_win64`, interface graphique seulement). Claude génère les .dat, les XML et la procédure ; MATLAB lit les exports et calcule tout.
- **Profils :** MH 45, MH 60, MH 61 et S5010.
- **Modes :** oscillation d'incidence ζ > 0,4 et roulis hollandais ζ > 0,1 (C1 p.180). Spirale : T2 > 12 s visé, no-go seulement si T2 < 4 s (Froude √(1/10), vols en FBWA). Écart à la skill, à signaler.
- **Élevons (critère remplacé à l'arrêt B) :** δ_trim(V) de 35 à 55 km/h, en 3S/4S, à MS 8 et 10 %, entre 0 et 6° vers le haut, avec au moins 10° de débattement à cabrer restant à 35 km/h. Seuils provisoires, à revoir avec le Cm_δ de l'étape 3. L'ancien critère (|δ| ≤ 1° à 45 km/h et ≤ 3° sur la plage) était hors cahier : pas de MOD. Ne jamais descendre la MS sous 8 % (V1-STAB-02 prime).
- **Arrêts :** A (profils et positions hypothétiques des composants), B (géométries), C (go/no-go).

Décisions de l'arrêt A (13/10/2026) :
- **V1-STAB-01 :** option C. Aucun des 4 profils n'a Cm0 ≥ 0 aux Re de vol. MOD-04 en brouillon (`04_aero_stabilite/resultats/MOD-04_brouillon.md`) : l'exigence porte sur le Cm(CL = 0) de l'aile complète, sans braquage d'élevons. Pas de profils plus réflexes, pas de volet fixe. À valider à l'arrêt B.
- **Profils 3D :** S5010 et MH 45 seulement. **Vrillage :** de −2 à −7° (Panknin, hors skill, à confirmer par VLM). Tracer CDi et le CL local au saumon en fonction du vrillage.
- **Positions :** ESC et câblage/PCB à 130 mm ; le reste inchangé, moteur à 335 mm. Si l'écart 3S/4S dépasse 30 mm avec le foyer xflr5 : s'arrêter et présenter les leviers, sans MOD automatique.

Étape 2, méthode xflr5 (13/10/2026) :
- Matrice réduite à 6 avions (S5010, MH 45 × −3, −5, −7°). Les T2 sont **non visqueux** : en visqueux, xflr5 rejetait 35 à 40 km/h (Re au-delà du lot, Clmax du winglet).
- **Les winglets doivent être inclinés** (`Tilt_angle`) du vrillage du saumon. xflr5 vrille autour du bord d'attaque ; un winglet à plat croise le treillis du saumon et rend la polaire fausse (CDi < 0, Cl du winglet jusqu'à 2,5). Exports valides : `xflr5/exports/T2/v1_winglet_tilt/`.
- Résultat à l'arrêt B : écart 3S/4S de 31 à 34 mm (> 30, arrêt). Équilibre sans braquage entre 58 et 135 km/h, aucune variante dans 35 à 55 km/h.

Décisions de l'arrêt B (13/10/2026) :
- **MOD-04 validée telle quelle** (`resultats/MOD-04.md`). **MOD-05 en brouillon** : V1-STAB-03 passe à ±18 mm puis ±20 mm, sans déplacement de masses. Une future MOD sur V1-MAS-03 prendra le numéro MOD-06.
- **Profil S5010.** Pas de T2 à −13°. Le vrillage se choisit sur la traînée équilibrée par les élevons à 40 et 55 km/h. Plan : 3 T2 à élevons (−3/−6, −7/−6, −5/−3), plus un T2 de contrôle facultatif (−5/0).
- **Contrôle visqueux avant l'étape 3** (Guilhem : le Cm XFoil s'écarte de celui de la ligne moyenne d'autant que le ΔCm d'équilibre). Le calcul en bandes donne ΔCm de −0,014 à −0,018 et avance le point neutre de 2,7 mm. C2 fait (13/10/2026) : xflr5 visqueux ne reprend PAS le Cm XFoil en VLM (ΔCm ≤ 3,7e-4, rapport 0,01). La correction en bandes s'applique et MOD-04 en visqueux élimine −3°.
- Suite le même jour : MOD-05 élargie à **±20 mm**. Polaires XFoil des profils à volet −3/−6/−9° (−9 sans T2). Le T2 de contrôle du maillage est décidé. MOD-04 : vérifiée avec le Cm visqueux, et la règle de choix élimine un vrillage qui échoue. **Ordre : C2 d'abord**, parce que si xflr5 reprend le Cm XFoil, la correction en bandes ne s'applique pas (`p.xfl.C2_seuils`). **Si aucun vrillage ne tient 0–6° dans les 4 configurations : arrêt**, montrer δ requis par configuration, sans changer ni les seuils ni la MS. Options de Guilhem dans ce cas : réflexe fixe au centre, fenêtre plus large, ou MS de premier vol à 8 %.
- Contraintes pour la phase 5 : `resultats/contraintes_phase5.md` (la batterie 3S est en conflit avec le Pi au nez).

**Why:** l'utilisateur fixe lui-même les seuils et les choix.

**How to apply:** voir le plan `~/.claude/plans/on-passe-a-la-glimmering-deer.md`, ainsi que [[phase3-regles-utilisateur]] et [[phase3-choix-moteur]].

**15/10/2026, 1er arrêt :** règle de l'arrêt B. Les 4 T2 à élevons sont dépouillés (§11 de `stabilite.m`, gardé pour la trace). Aucun vrillage ne tient 0 à −6°. L'amplitude de δ_trim de 35 à 55 km/h (6,5 à 8,7°, ≈ MS·ΔCL/Cm_δ) dépasse la fenêtre.

**15/10/2026, décision de Guilhem (texte collé d'un conseiller) :** critère remplacé, hors cahier, donc pas de MOD (`p.stab.d_crois` etc.) :
- croisière de 40 à 55 km/h, δ_trim entre −10 et 0°, 3S/4S, MS 8/9/10 % ;
- autorité : équilibre au CLmax de l'aile, MS 10 %, |δ| ≤ 20° vers le haut ;
- MS nominale 9 %.

Il a demandé une estimation SANS manip xflr5 d'élevons à 30 %, 35 % et 35 % prolongés de 10 % de demi-envergure : `elevons_variantes.m` → `resultats/tableaux_variantes.md`, fig09/fig10. Méthode : VLM des T2 × profils minces, Weissinger recalé (κ 1,17) pour le prolongement, polaires à 75 % empruntées avec le même η (pas de XFoil autonome sur la machine, seulement la DLL d'xflr5).

**Résultat : 2e ARRÊT** (consigne 4 : aucune variante ne passe, même à MS 7–9 %).
- En profils minces, le moment de section est maximal à 25 % de corde : la corde rapporte +4 à +7 % de Cm_δ seulement. Le prolongement rapporte +18 %, par le moment de section et non par le bras de levier.
- L'autorité bloque tout : avec 20°, CL max équilibré 0,65 à 0,79 à MS 10 %, alors que le CLmax lisse (bande critique) vaut 1,16.
- Pas de MOD sur V1-STAB-02 sans accord de Guilhem. En attente de sa décision.

**15/10/2026, 2e décision de Guilhem (texte collé) :** critères hors cahier, sans MOD ; V1-STAB-02 reste à 8–10 %.
- **Autorité :** vitesse minimale équilibrée ≤ 30 km/h à MS 10 %, 3S1P et 4S1P, au plus 20° vers le haut (`p.stab.V_aut_max`). V1-PERF-01 doit être tenue. Le CL max équilibré remplace le CLmax de 0,8.
- **Croisière :** plus de fenêtre de braquage. V1-PERF-03/04/05 avec la traînée équilibrée à MS 9 % (modèle de la phase 3) ; signaler tout écart sur V1-PERF-03.
- **Variante retenue :** 35 % de corde depuis y = 200 mm. Vrillage choisi par la règle E4, parmi ceux qui passent.

Commit `70eee52` (« Phase 4 en cours (arrêts A à C) ») fait AVANT ce travail, qui n'est pas commité.

Script `verdict_elevons.m` → `resultats/tableaux_verdict.md`, fig11/fig12. Il prend les polaires à charnière 65 % dès que `xflr5/exports/polaires_volet_c65/` est complet (manip F de `procedure_etapes_2_3.md`, en attente de Guilhem). Sinon, polaires à 75 % empruntées.

Résultats avec les polaires empruntées :
- **Autorité :** tenue partout. Avec la MOD-04, de −3,5 à −7°. Marge mince : 29,8 km/h en 4S à −3,5°. Butée de 20° partout, au-delà des polaires.
- **Vrillage retenu −3,5°,** fixé par la MOD-04 (limite −3,32°) ; l'optimum libre est au bord de la matrice (−3°).
- **CL max équilibré 0,744.** V1-PERF-01 à 29,9 / 31,4 km/h.
- **V1-PERF-03 :** 44,6 min à −30 % (écart signalé) avec CD0 0,030 + induite VLM + surcoût des élevons, contre 60,7 min avec la polaire complète de la phase 4.
- **Prolongement à 150 mm :** Cm_δ +27 %, fuselage central ≤ 300 mm.
- **Cm0 +0,01 :** δ_trim +2,1°.

**15/10/2026, polaires c65 reçues (114/114) :** le verdict tourne, mais le Cm_δ passe de +18 % à +145 % par rapport au T2. Δα0/δ XFoil c65 = 0,61 à 0,75 /° à Re 0,25 (τ mince 65 % = 0,707, donc η ≥ 1, et η croît avec δ), contre η ≈ 0,68 à 75 %. Résultat suspect, non validé. On attend les .dat de contrôle F1.5 (`profils/s5010_c65_elv-*.dat`) pour mesurer le braquage et la charnière réels.

**15/10/2026, fin de journée :**
- Contrôle gratuit fait : l'écart est localisé (bulle). Pas de B ; Cm_δ signalé « incertain d'un facteur 2 » dans tableaux_verdict.
- `cloture_phase4.m` a généré le T2 de contrôle (`V1_S5010_vr35_c65_e0/e6`, procédure G, exports attendus dans `xflr5/exports/T2/cloture/`).
- **Option T7-3 bloquée :** à −9° et à −12°, aucun équilibre ne tombe entre 40 et 55 km/h. xflr5 s'équilibre en VLM sans la correction visqueuse : −3° y donne 44 à 51 km/h. L'avion réel, lui, s'y équilibre avec −6° (43 à 47 km/h). On attend le choix de Guilhem.
- Inertie corrigée pour le T7 : `masses_composants(..., nB)` répartit l'aile en bandes, `p.clo.n_bandes` = 10.
- Ensuite : fiche de gel et contraintes_phase5.md.

**État au 13/10/2026 au soir (reprise le 14/10) :**
- C2 tranché, profils à volet −3/−6/−9° mesurés, 76 polaires XFoil dépouillées (§10 : η_m 0,62–0,76, η_α 0,67–0,80).
- Les 4 avions à élevons (`vr3_e6`, `vr7_e6`, `vr5_e3`, `vr5_e0`) sont **importés dans xflr5**, mais **aucun T2 n'est encore lancé**. Reste : analyse `T2inv-VLM2` (Viscous décochée, α −2 à 14 pas 0,5), puis export polaire + Cl local à α = 6,0 et 14,0 dans `xflr5/exports/T2/v1_winglet_tilt/` (procédure E2–E3).
- Ensuite : lecteur de ces T2 (modèle quadratique vrillage × δ), règle de choix du vrillage, arrêt si aucun vrillage ne tient 0–6° dans les 4 configurations.

**16/10/2026 :** T2 de clôture lu : l'incrément de Cm dû à −6° concorde à 0,5–1,0 % (modèle "vlm" validé, part visqueuse de Cm_δ toujours incertaine ×2) ; x_NP VLM 177,5 mm contre 174,7 mm visqueux. Fiche de gel générée (`fiche_gel_phase4.m`), contraintes P5-06 à P5-10 ajoutées.
- **Décision T7 : option 1** : `S5010 c65 elv-3` pour les 4 avions (3S/4S × MS 8/10 %). Avions et analyses T7 générés par `t7_phase4.m` (procédure H de `procedure_etapes_2_3.md`, exports attendus dans `xflr5/exports/T7/`). xflr5 voit une MS de 9,1 / 11,1 % (son NP VLM).
- **Filet :** si un avion sort à moins de 0,05 de marge sur un critère (ζ incidence > 0,4, ζ roulis hollandais > 0,1, spirale T2 ≥ 4 s no-go), proposer un T7 de plus pour lui avec `S5010 c65 elv-6` (`p.clo.d_T7_filet`).
- **Quand V1-STAB-04 est tranchée :** relancer test_predim (16 tests) avant tout commit ; mettre à jour la fiche de gel ; commiter sur la branche `phase4-aero-stabilite` (elle n'existe pas en local au 16/10 : on est sur `main`, à créer) ; préparer la fusion dans main avec le report de MOD-04 et MOD-05 dans le cahier des charges (demandé par Guilhem).
- Tests : test_stab 25/25 (lancer avec `feature('DefaultCharacterSet','UTF-8')` dans la session MATLAB), test_predim 16/16.
