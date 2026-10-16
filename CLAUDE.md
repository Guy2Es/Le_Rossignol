# Projet drone — aile volante V1 de 1 m (Le Rossignol)

Reprise du travail en session cloud. Lire d'abord `docs/memoire/` (copie de la mémoire locale de Claude : décisions, critères, état) et `Cahier des charges V1 — aile volante 1 m.md`.

## Règles permanentes
- Aucun chiffre que MATLAB n'a pas calculé.
- Ne jamais modifier le cahier des charges de sa propre initiative ; les MOD restent en brouillon.
- Zéro avertissement du Code Analyzer ; tous les paramètres dans `03_predimensionnement/params_v1.m`.
- Suivre la skill /aircraft-design et signaler les écarts (VLM, bandes, profils minces, Weissinger sont hors skill).
- S'arrêter avant les choix structurants et présenter un classement SANS recommander.
- Répondre en français. Pronoms they/them si non précisés.
- Commit seulement sur demande. Pas de MOD sur V1-STAB-02 sans l'accord de l'utilisateur.

## Limites de l'environnement cloud
- MATLAB n'est pas disponible dans le cloud : les calculs et tests (`test_predim`, `test_stab`) se lancent sur le PC de l'utilisateur. Dans le cloud : rédaction, relecture, procédures, documents. Ne pas inventer de résultat.
- xflr5 est piloté à la main par l'utilisateur ; les exports vont dans `04_aero_stabilite/xflr5/exports/`.

## État (16/10/2026)
Phase 4 : T7 option 1 généré (`04_aero_stabilite/t7_phase4.m`, procédure H de `xflr5/procedure_etapes_2_3.md`). En attente des exports T7 (`xflr5/exports/T7/`, message « T7 faits »). Ensuite : lecteur T7, critères V1-STAB-04 (ζ incidence > 0,4 ; ζ roulis hollandais > 0,1 ; spirale T2 ≥ 4 s), filet elv-6 si marge < 0,05, fiche de gel, fusion dans main avec report de MOD-04 et MOD-05 dans le cahier. test_predim 16/16 et test_stab 25/25 au 16/10.
