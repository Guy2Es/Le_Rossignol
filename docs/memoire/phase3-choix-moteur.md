---
name: phase3-choix-moteur
description: "État de la phase 3 (pré-dimensionnement V1, MATLAB) : moteur X2212 980 KV + APC 8x6EP rigide retenus, plan d'allègement validé sous réserve, MOD-01/02/03 validées"
metadata:
  node_type: memory
  type: project
  originSessionId: cca9d503-6024-4563-8b98-5645c2e36348
  modified: 2026-10-13T11:30:25.391Z
---

Décisions de l'utilisateur au 2026-10-13 :
- **Moteur et configuration :** X2212 V3 980 KV, configuration F (8×6, THR_MAX 4S 0,845). G (7×6 en 4S) est à trancher au banc en phase 9.
- **Hélice :** APC 8x6EP rigide propulsive, plus une 7x6EP pour le banc. Adaptateur RC Dude CPA-317-N : pince 3,17 mm, M6, 6,0 g. Le tout est dans `p.gp`.
- **Plan d'allègement :** validé sous réserve. Pièces : F405 WING MINI, LittleBee-S, GPS M10 à 9 g.
- **MOD :** MOD-01 (PERF-03), MOD-02 (PROP-02) et MOD-03 (PROP-03, rigide acceptée) sont validées.
- **Phase 5 :** contrainte de garde au sol (disque à 101,6 mm sous l'axe).

Rapport : `03_predimensionnement/resultats/phase3_resultats.md`, verdict GO phase 4. Phase 3 close et commitée (4441587). La 4S1P pèse 797,2 g (+2,8 g de marge), la 3S1P 725,2 g. Suite : [[phase4-criteres]].

Réserves ouvertes :
- **Masse 4S :** marge de +2,8 g. Elle dépend de la pesée du FC (14,3 g selon la fiche, 19 g selon ArduPilot) et de la disponibilité de la WING MINI. Si on revient au FC du cahier, la 4S fait 807,9 g et la structure tombe à 312 g ; il faudrait alors une MOD-04 sur V1-MAS-03.
- **V1-PL-01 :** 3,0 W typiques pour un maximum de 2,5 W.
- **Achats :** compas QMC5883P exclu du firmware, LittleBee-S contrefaits, Pi sur un régulateur 5 V dédié.

**Why:** l'utilisateur décide lui-même. Il ne faut jamais choisir à sa place ni modifier le cahier des charges.

**How to apply:** relancer `dimensionnement.m`, les tests (16) et checkcode après tout changement de `params_v1.m`.

Voir [[phase3-regles-utilisateur]].
