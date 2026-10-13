# Phase 3 — Pré-dimensionnement de la V1 (aile volante 1 m)

13/10/2026, mise à jour après les décisions du jour · calculs MATLAB : `03_predimensionnement/dimensionnement.m` (paramètres : `params_v1.m`)

Tous les chiffres de ce rapport sortent de MATLAB. Les tableaux complets sont dans [tableaux_auto.md](tableaux_auto.md), réécrit à chaque exécution, et les figures dans [figures/](../figures/). Les valeurs relevées sur des fiches (masses, prix, courants) sont citées avec leur source. Le cahier des charges n'est pas modifié : les MOD sont rédigées ici, et c'est à Guilhem de les reporter dans le cahier.

## Décisions datées

| Date | Décision (Guilhem) | Où elle est inscrite |
| --- | --- | --- |
| 12/10/2026 | 40 km/h comme vitesse d'endurance opérationnelle (pas de pitot) | `p.req.V_end_op` |
| 13/10/2026 | Moteur SunnySky X2212 V3 980 KV. Configuration de référence F : 8×6 sur les deux batteries, THR_MAX 4S de 0,845 | `p.choix.ref = "F"` |
| 13/10/2026 | G (7×6 en 4S) devient une option à trancher au banc en phase 9 | `p.choix.banc = "G"` |
| 13/10/2026 | Hélice : option (a), **APC 8×6EP rigide propulsive** ; une APC 7×6EP est achetée pour trancher G au banc | `p.gp`, `p.gp.alt`, `p.bud.hel` |
| 13/10/2026 | **Plan d'allègement validé**, sous réserve des vérifications du §6 | `p.allg`, `p.av` |
| 13/10/2026 | **MOD-01 et MOD-02 validées** | `p.choix.mod`, §8 |
| 13/10/2026 | **MOD-03 sur V1-PROP-03** : « propulsive repliable » devient « propulsive, rigide acceptée ; coupure moteur avant le toucher ; hélices consommables (lot de 10) » | `p.choix.mod`, §8 |
| 13/10/2026 | Contrainte transmise à la phase 5 : garde au sol du disque de l'hélice | §10 |

## Synthèse

- **Configuration retenue (F) :** X2212 V3 980 KV, **APC 8×6EP rigide propulsive** sur les deux batteries, montée sur un adaptateur à pince 3,17 mm / M6 (RC Dude CPA-317-N, 6,0 g). THR_MAX vaut 1,00 en 3S1P et 0,845 en 4S1P (200 W).
- **Groupe propulsif :** 76,9 g, contre 80,0 g pour l'ancienne référence repliable (CAM + RFM, qui était tractrice) et 62 g au budget du cahier.
- **Masse, nouvelle marge :** avec le plan d'allègement, la 4S1P pèse **797,2 g avec des cellules de 70 g, soit +2,8 g sous 800 g**, la structure restant à 320 g.
  - Si le contrôleur de vol pèse 19 g (valeur de la page ArduPilot), la marge tombe à −1,9 g. La cible de structure devient alors 318 g.
  - Si la WING MINI est introuvable, il faut revenir au contrôleur de vol du cahier : la 4S1P monte à 807,9 g et la cible de structure tombe à 312 g.
- **Vérifications du plan :** aucun point n'est bloquant pour le calcul. Trois points doivent être réglés à l'achat :
  - la disponibilité de la WING MINI ;
  - la masse réelle de la WING MINI ;
  - le Pi, qui doit rester sur le régulateur 5 V dédié.

  Un risque est nouveau : V1-PL-01, la puissance du Pi et de la caméra (§6).
- **MOD :** MOD-01, MOD-02 et MOD-03 sont validées. V1-PERF-03 reste conforme sous réserve, et V1-PROP-02 et V1-PROP-03 sont conformes avec leur MOD.
- **Budget hélices :** 36,40 $ en prix catalogue (hors port et douane), pour un poste de 15 € au cahier.
- **Verdict : GO vers la phase 4**, avec des réserves suivies (§13).

## 1. Vérification des exigences (configuration retenue F)

Conditions : η calculé, masse avec le groupe propulsif réel (cellules de 69 g), ISA, CD0 = 0,030 sauf mention. Les autonomies réelles sont données de −30 % à −20 % sur l'autonomie théorique.

| Exigence | Valeur calculée | Exigence (cahier, et MOD validée) | Statut | Marge |
| --- | --- | --- | --- | --- |
| V1-MAS-01 | 4S1P : 811 g (cellules 69 g), 815 g (70 g) ; avec le plan d'allègement : 793,2 g, 797,2 g | ≤ 800 g | **à risque** | −15 g sans plan ; +2,8 g avec plan (cellules 70 g) ; −1,9 g, plan pessimiste (FC 19 g) |
| V1-MAS-02 | Sans batterie : 523 g ; avec le plan : 505,2 g | ≤ 520 g | **à risque** | −3 g sans plan ; +14,8 g avec plan ; +10,1 g, plan pessimiste |
| V1-MAS-03 | Structure du budget 320 g ; maximum admissible avec le plan 322,8 g (4S, cellules 70 g) ; cible 320 g (plan pessimiste : 318,1 g, cible 318 g) | ≤ 320 g (souhaitable) | oui (budget) | 0 g sous la cible |
| V1-PERF-01 | Vs à 800 g = 28,8 km/h (ISA) ; 30,1 km/h TAS le jour chaud | ≤ 32 km/h (cible 29) | oui | 1,9 km/h (pire cas) |
| V1-PERF-02 | Palier tenu de 45 à 60 km/h ; rapport cyclique à 45 / 60 km/h : 0,59 / 0,78 en 3S, 0,45 / 0,58 en 4S (THR_MAX 1,00 / 0,84) | 45 à 60 km/h | oui | d(60 km/h, 4S) = 0,69 × THR_MAX |
| V1-PERF-03 | 4S1P à 55 km/h, η calculé 0,537 : 46 à 53 min ; CD0 0,035, −30 % : 43 min (G : 48 min) | ≥ 45 min | **sous réserve (MOD-01 validée)** | +1,1 min (CD0 0,030, −30 %) ; −2,4 min (CD0 0,035) |
| V1-PERF-04 | 4S1P à 40 km/h, η calculé 0,537 : 79 à 91 min ; CD0 0,035, −30 % : 75 min | ≥ 70 min (souhaitable) | oui | +5 min (CD0 0,035, −30 %) |
| V1-PERF-05 | 3S1P à 55 km/h, η calculé 0,531 : 35 à 40 min ; CD0 0,035, −30 % : 32 min | ≥ 30 min | oui | +2 min (CD0 0,035, −30 %) |
| V1-PERF-06 | V_cr/V_vent = 2,75 ; vitesse sol face au vent = 35 km/h | ≥ 20 km/h (critère V_cr ≥ 2·V_vent) | oui | V_cr/V_vent − 2 = 0,75 |
| V1-PERF-07 | Plein gaz (THR_MAX) à 1,3·Vs, masse réelle : 5,4 / 5,1 m/s en 3S, 6,8 / 6,4 m/s en 4S (ISA / jour chaud) | ≥ 3 m/s | oui | +2,1 m/s (pire) |
| V1-PERF-08 | T/W statique : 0,76 / 0,71 en 3S, 0,86 / 0,80 en 4S (ISA / jour chaud) | ≥ 0,5 | oui | +0,21 (pire) |
| V1-PROP-02 | P max batterie pleine : 145 W en 3S, 200 W en 4S (besoin au point de conception : 69 W) | MOD-02 : 140 à 200 W par batterie, et T/W statique ≥ 0,5 le jour chaud | **oui (MOD-02 validée)** | 3S : +5 W au-dessus de 140 W ; 4S : 0 W sous 200 W (bridage) ; T/W jour chaud +0,21 |
| V1-PROP-03 | APC 8×6EP + adaptateur RC Dude CPA-317-N ; régime max 18 750 tr/min (pire cas d'erreur : 13 229 tr/min) | MOD-03 : propulsive, rigide acceptée ; coupure moteur avant le toucher ; lot de 10 | **oui (MOD-03 validée)** | disque à 102 mm sous l'axe : garde au sol à vérifier en phase 5 |
| V1-PL-01 | Pi Zero 2 W + caméra, courants typiques de la documentation Raspberry Pi : 0,60 A, soit 3,00 W sous 5,0 V | ≤ 2,5 W (et ≤ 30 g) | **à risque (mesure en phase 6)** | −0,50 W |

Les exigences hors du champ de la phase 3 (stabilité, structure, opérations, réglementation) sont vérifiées dans les phases suivantes. V1-PL-01 est ajoutée ici parce que la vérification du BEC (§6) a demandé les courants du Pi. Le tableau avec les hypothèses du cahier (η = 0,5, budget du cahier) est dans [tableaux_auto.md](tableaux_auto.md).

V1-PERF-07 est calculée avec le moteur retenu : poussée du modèle à THR_MAX, puis Vz = (T·V − Pn)/(m·g) (C1 p.79). L'approximation de pente faible est signalée au §12.

## 2. Point de conception

Le point est figé par la géométrie du cahier (S = 0,25 m², λ = 4) à la masse maximale de 800 g, dans le pire cas entre ISA et le jour chaud (200 m, 35 °C).

| Grandeur | Valeur |
| --- | --- |
| Charge alaire retenue | 31,4 N/m² (3,20 kg/m²) |
| P/W requis | 86 W/kg, soit 69 W électriques |
| Contrainte active | Lancer main, T/W ≥ 0,5 (identique pour CD0 = 0,025, 0,030 et 0,035) |
| Optimum au sens de la skill (C3 p.73) | W/S = 35,4 N/m², P/W = 92 W/kg ; non retenu, car S est figée par le cahier |
| Décrochage à 800 g | 28,8 km/h ISA ; 30,1 km/h TAS le jour chaud |

Le besoin de 69 W est bien en dessous des 145 W (3S) et 200 W (4S) disponibles. La puissance installée est fixée par l'autonomie et la marge au lancer. Voir [fig02](../figures/) et le tableau « Point de conception » de [tableaux_auto.md](tableaux_auto.md).

## 3. Choix du moteur et de l'hélice

Le choix de Guilhem (13/10/2026) est F : X2212 V3 980 KV, 8×6 en 3S1P et en 4S1P, THR_MAX 4S de 0,845 (limité par la puissance de 200 W). La géométrie 8×6 est désormais celle d'une APC 8×6EP rigide (§5). Le modèle d'hélice ne dépend que du diamètre et du pas : les performances de F sont donc inchangées par le passage de la CAM à l'APC, et seule la masse change. Trois éléments du calcul justifient le choix.

**Classement.** Le classement trie les options sur l'autonomie réelle en 4S1P à 55 km/h, à −30 %.
- F est 6e sur 9, avec 46,1 min.
- Les trois options à hélice unique sont dans la résolution du modèle : E-1260 fait 46,5 min, E-1100 46,2 min, F 46,1 min.
- Si l'hypothèse d'hélice en vol varie de ±10 % (k_JT), F passe au 5e ou au 6e rang. Le modèle ne peut donc pas départager F et E sur l'autonomie.
- Les options devant F (C, G, A) utilisent une hélice différente en 4S. C fait échouer V1-PERF-05 (27 min en 3S).

**Marge de poussée.**
- Le jour chaud, F donne un T/W de 0,71 en 3S et 0,80 en 4S. Les options X2208 donnent 0,65 / 0,59 (E-1260) et 0,64 / 0,59 (E-1100).
- C'est la marge la plus large des options à hélice unique pour le lancer main (V1-PERF-08, V1-OPS-02).
- Montée plein gaz : 5,1 m/s au pire (3S, jour chaud), pour 3 m/s exigés.

**Tolérance à une erreur de fichier.** Le cas étudié est une 4S1P branchée avec le fichier 3S, batterie pleine, au point fixe, en ISA.
- F est inchangé, puisque THR_MAX vaut déjà 1,00 en 3S : 296 W et 19,1 A au moteur, soit 1,04 fois la limite continue (18,4 A). **Le moteur survit 10 s plein gaz** (limite de 26 A sur 30 s).
- Avec le X2208, le moteur dépasse sa limite de courte durée : 20,9 A pour E-1260 (limite de 15 A sur 30 s) et 17,8 A pour E-1100 (limite de 14 A sur 15 s).
- Ni l'ESC 30 A, ni les cellules, ni l'hélice ne sont dépassés : 64 % de 30 A, 43 % de 45 A, et 13 229 tr/min, soit 71 % du régime max de l'APC 8×6E (18 750 tr/min).

**Ce que F coûte.**
- Son groupe propulsif pèse 77 g contre 66 g pour les options X2208, pour 62 g au budget. En 4S1P, sans le plan d'allègement, cela donne 811 g contre 800 g.
- Sa puissance max en 3S est de 145 W, sous l'ancienne borne de 150 W de V1-PROP-02 (couvert par MOD-02).

| Option | Hélice 3S / 4S | THR_MAX 3S / 4S | η 4S 55 km/h | V1-PERF-03 [min] | Idem, CD0 0,035, −30 % | V1-PERF-04 [min] | V1-PERF-05 [min] | T/W jour chaud 3S / 4S | P max 3S / 4S [W] |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| **F (retenue)** | 8×6 / 8×6 | 1,00 / 0,84 | 0,537 | 46,1 à 52,7 | 42,6 | 79 à 91 | 35 à 40 | 0,71 / 0,80 | 145 / 200 |
| G (banc) | 8×6 / 7×6 | 1,00 / 0,99 | 0,621 | 52,4 à 59,9 | 47,6 | 84 à 96 | 35 à 40 | 0,71 / 0,72 | 145 / 200 |
| F-8x5 (information) | 8×5 / 8×5 | 1,00 / 0,88 | 0,446 | 39,0 à 44,6 | 36,4 | 70 à 80 | 30 à 34 | 0,69 / 0,84 | 131 / 200 |
| C (pour mémoire) | 8,5×5 / 7×6 | 1,00 / 1,00 | 0,641 | 53,8 à 61,5 | 48,9 | 87 à 100 | 27 à 31 | 0,74 / 0,66 | 133 / 174 |

Le classement complet, sa robustesse, la décomposition du η et les bridages sont dans [tableaux_auto.md](tableaux_auto.md). Voir aussi [fig09](../figures/fig09_rendement_croisiere.png) et [fig10](../figures/fig10_classement_options.png).

## 4. Option G, à trancher au banc en phase 9

G garde le moteur et la 8×6 de F en 3S1P, mais monte une APC 7×6EP rigide en 4S1P, bridée à 0,99 par la puissance. Dans le modèle :
- le η de l'hélice à 55 km/h passe de 0,676 à 0,799 ;
- le η global passe de 0,537 à 0,621 ;
- V1-PERF-03 passe de 46 à 53 min (F) à 52 à 60 min (G) ;
- **G tient 45 min même dans le cas pessimiste** (CD0 0,035, −30 %) : 47,6 min.

Le gain repose entièrement sur le modèle d'hélice en vol, qui n'est pas recalé : c'est pourquoi la décision se prend au banc. La masse de G est calculée avec l'hélice 8×6, ce qui la majore : la 7×6EP pèse 7,9 g contre 13,9 g.

**Ce que G introduit.** Il y a deux hélices, donc deux erreurs de montage possibles :

| Cas | P batterie [W] | I moteur [A] | Régime [tr/min] | T/W au lancer, jour chaud | Survit 10 s |
| --- | --- | --- | --- | --- | --- |
| 4S1P, fichier 3S, 7×6 montée | 204 | 12,9 (0,70× continu ; 0,50× 30 s) | 14 223 | — | oui |
| 4S1P, fichier 4S, 8×6 restée montée | 290 | 18,9 (1,03× continu ; 0,73× 30 s) | 13 146 | — | oui |
| 3S1P, fichier 3S, **7×6 restée montée** | — | — | — | **0,48 (< 0,5 : V1-PERF-08 non tenue)** | — |

Le moteur survit à toutes les erreurs, et les régimes restent sous les limites APC : 21 429 tr/min pour la 7×6 et 18 750 tr/min pour la 8×6. En revanche, **une 3S lancée avec la 7×6 est sous le seuil de poussée**. Si G est retenue, la liste de vérification avant vol devra lier la batterie à l'hélice.

**Ce qu'il faut mesurer pour trancher entre F et G** (même moteur, 4S1P) :
1. **Au banc, en phase 9 (point fixe) :**
   - pour chaque hélice : poussée, puissance batterie, courant et régime en fonction du gaz ;
   - vérifier qu'au THR_MAX calculé (0,845 avec la 8×6, 0,99 avec la 7×6), la puissance reste sous 200 W, le courant sous 18,4 A et le régime sous la limite APC ;
   - mesurer le T/W statique de la 7×6 en 4S1P (0,72 le jour chaud au modèle) ;
   - recaler Ct0 et Cp0 du modèle.
2. **En vol (CRUISE), phases 9 et 10 :** puissance batterie en palier à 55 km/h, en 4S1P, avec chaque hélice. La mesure vient du capteur de courant de la PDB, relevé dans le journal ArduPilot, à la même masse et par vent faible. C'est cette mesure qui tranche : le banc statique ne mesure pas le η en vol, et c'est lui qui porte l'écart entre F et G.
3. **Critère de décision :** G est retenue si sa puissance en croisière est inférieure à celle de F de plus que la dispersion entre vols répétés. Sinon, on garde F, qui n'a qu'une hélice et donc aucune erreur de montage possible.

## 5. Groupe propulsif retenu : APC 8×6EP et adaptateur

**Pourquoi l'hélice rigide (rappel).** Les pales CAM Carbon 8×6 et 7×6 et le moyeu RFM n'existent qu'en rotation droite, c'est-à-dire tractrice. La seule repliable propulsive de 8 pouces trouvée, l'aero-naut 8×5 « linkslaufend », fait échouer V1-PERF-03 (39,0 min) et V1-PERF-05 (29,5 min à −30 % ; voir F-8x5 au §3). La décision (a) est donc prise, avec MOD-03.

**Adaptateur retenu : RC Dude Hobbies CPA-317-N.** C'est une pince 3,17 mm à écrou hexagonal, avec un axe fileté M6 × 1,0 de 6 mm. Fiche : « Prop Adapter Weight – 6.0 grams », longueur utile de 17 mm, épaisseur de moyeu max de 10,5 mm avec rondelle et écrou, en stock, 4,49 $ ([rcdude.com](https://rcdude.com/collet-style-prop-adapter-with-hex-nut-for-3-17mm-motor-shafts.html)). Une pince ne demande pas de méplat sur l'axe, contrairement au moyeu RFM.

| Point vérifié | Résultat | Source |
| --- | --- | --- |
| Axe du X2212 V3 | 3,17 mm : la pince de 3,17 mm convient | [SunnySky](https://sunnyskyusa.com/products/replacement-shaft-for-sunnysky-x2212-motors-3-175mm) |
| Alésage APC | 1/4" (6,35 mm) sur la 8×6EP comme sur la 7×6EP. L'axe de 6 mm de l'adaptateur se centre avec une **bague de 6 mm** : elle fait partie du jeu LPAR06E (1/8", 4, 5, 6 mm, 5/16"), fourni avec la 8×6EP. La 7×6EP est livrée avec les jeux LPAR18SF et LPARM12SF ; un revendeur annonce une bague de 6 mm dans le jeu métrique. **À confirmer à réception** | [APC 8x6EP](https://www.apcprop.com/product/8x6ep/), [APC 7x6EP](https://www.apcprop.com/product/7x6ep/), [AMain (LPAR06E)](https://www.amainhobbies.com/apc-electric-propeller-adapter-rings-6-sets-1-8-4mm-5mm-6mm-5-16-apclpar06e/p261605), [ReadyMadeRC (bagues SF métriques)](https://www.readymaderc.com/products/details/apc-adapter-rings-metric-sf) |
| Épaisseur de moyeu | 8×6EP : 9,4 mm, soit 1,1 mm de réserve sous les 10,5 mm de l'adaptateur ; 7×6EP : 8,4 mm, soit 2,1 mm de réserve | fiches APC et RC Dude |
| Régime max | APC « Thin Electric » : 150 000 / D, soit 18 750 tr/min en 8 pouces et 21 429 tr/min en 7 pouces. Pire cas d'erreur de F : 13 229 tr/min (71 %) | [APC, RPM Limits](https://www.apcprop.com/technical-information/rpm-limits/) |
| Sens | « Thin Electric Pusher, Reverse Rotation » : propulsive | fiches APC |

**Adaptateurs écartés :**
- HobbyKing 3,17 mm à pince (4,2 g, axe de 5 mm) : les deux références sont « Discontinued Product » ;
- E-flite EFLM1923 (6 g, en stock) : « Final Hub Diameter 6.5mm », plus gros que l'alésage APC de 6,35 mm, il faudrait aléser l'hélice ;
- adaptateurs dont la masse n'est publiée que par des revendeurs non identifiés (3 à 5 g, caractéristiques contradictoires).

Le paquet du X2212 V3 contient aussi « 1 x Propeller Adapter » ([ReadyMadeRC](https://www.ReadyMadeRC.com/products/details/sunny-sky-x-series-v3-x2212-980kv)), de type et de masse non publiés. **À peser à réception** : s'il accepte l'APC, il peut remplacer l'adaptateur.

**Groupes examinés (masses de fiche) :**

| Hélice + moyeu | Type | Rotation | Hélice / pales [g] | Adaptateur / moyeu [g] | Moteur + hélice + moyeu [g] |
| --- | --- | --- | --- | --- | --- |
| **APC 8×6EP + CPA-317-N (retenu)** | rigide | propulsive | 13,9 | 6,0 | **76,9** (+14,9 sur le budget de 62 g) |
| APC 7×6EP + CPA-317-N (banc G) | rigide | propulsive | 7,9 | 6,0 | 70,9 |
| aero-naut 8×5 linkslaufend + cône CN 30/3,17 | repliable | propulsive | non publiée | non publiée | non calculable |
| CAM Carbon 8×6 + moyeu-cône RFM 30 mm (ancienne référence) | repliable | **tractrice** | 9,0 | 14,0 | 80,0 |

**Budget hélices (MOD-03 : lot de 10).** Prix catalogue en dollars US, hors port et douane : la conversion et le port sont à établir à l'achat.

| Article | Quantité | Prix unitaire [$] | Total [$] |
| --- | --- | --- | --- |
| APC 8×6EP (LP08060EP), lot consommable | 10 | 2,92 | 29,20 |
| APC 7×6EP (LP07060EP), banc G | 1 | 2,71 | 2,71 |
| Adaptateur RC Dude CPA-317-N | 1 | 4,49 | 4,49 |
| **Total** | | | **36,40** |

Le cahier prévoit 15 € pour le lot « hélices propulsives repliables + cône » (V1-BUD-01). L'écart est à suivre en phase 6. Le moyeu RFM (45,54 €) n'est plus acheté. Pour voler G en routine, il faudrait aussi un lot de 7×6EP, non compté ici.

## 6. Plan d'allègement validé : vérifications et budget réaffecté

### Vérifications demandées

| Point | Résultat | Statut | Source |
| --- | --- | --- | --- |
| Support ArduPilot du F405 WING MINI | **Pris en charge.** Une seule cible, `SpeedyBeeF405WING`, pour la WING et la WING MINI (page « SpeedyBeeF405WING/ Wing Mini »). La carte a 1 Mo de flash, donc un firmware réduit. Le `features.txt` de la cible (Plane stable) contient la clôture (`AP_FENCE_ENABLED`), le u-blox, le CRSF et les compas QMC5883L et IST8310. Il ne contient **ni le Lua** (`!AP_SCRIPTING_ENABLED`) **ni le compas QMC5883P** (`!AP_COMPASS_QMC5883P_ENABLED`). Les modes de V1-AV-01 sont des modes de base d'ArduPlane | conforme ; **acheter un GPS dont le compas est un QMC5883L ou un IST8310, pas un QMC5883P** | [ArduPilot](https://ardupilot.org/plane/docs/common-speedybeef405wing.html), [features.txt](https://firmware.ardupilot.org/Plane/stable/SpeedyBeeF405WING/features.txt) |
| UART libres | **5 UART utilisateur + 1 interne.** Besoin : 3 (ELRS, GPS, MAVLink vers le Pi). Affectation : SERIAL1 pour l'ELRS (CRSF, RX1 + TX1), SERIAL3 pour le GPS (compas en I2C), SERIAL4 pour le MAVLink2 vers le Pi. SERIAL5 reste libre (TX5 est aussi sur le connecteur vidéo), SERIAL2 aussi avec BRD_ALT_CONFIG = 1. SERIAL6 est pris par la carte sans fil (MAVLink Wi-Fi) | conforme, 2 UART de réserve | [ArduPilot](https://ardupilot.org/plane/docs/common-speedybeef405wing.html) ; pastilles UART1 à 6 listées par la fiche MINI ([FPVFaster](https://fpvfaster.com.au/products/speedybee-f405-wing-mini-fixed-wing-flight-controller)) |
| BEC 5 V face au Pi Zero 2 W et à la Camera Module 3 | BEC du FC de la MINI : 5,2 V, 2 A continu et 3 A en crête (fiche ; la page ArduPilot donne 2,4 A, valeur de la WING). Courants typiques : Pi Zero 2 W 350 mA, caméra 250 mA ; Raspberry Pi recommande une alimentation de 2 A pour le Zero 2 W. **Tout sur le BEC du FC, en typique : 1,00 A, soit 50 % du continu.** Avec un Pi alimenté au niveau recommandé (2 A) plus le reste de l'avionique : **2,40 A, soit 120 % du continu** (80 % de la crête) | **non bloquant si le Pi garde le régulateur 5 V dédié** du PCB d'interconnexion, déjà prévu au cahier et gardé dans le budget. Le levier « supprimer le PCB » est abandonné | [Raspberry Pi, Power supply](https://www.raspberrypi.com/documentation/computers/raspberry-pi.html) ; fiche MINI |
| Disponibilité du F405 WING MINI | **Incertaine.** Rupture chez fpv24 (« no longer available »), 6sfull.cz et Flying Tech. La page produit SpeedyBee renvoie « Not Found ». Encore annoncée en stock chez des revendeurs US (SoarSky, MEPSKING), sans vérification de livraison en France | **à risque** (voir le repli ci-dessous) | [fpv24](https://www.fpv24.com/en/speedy-bee/speedybee-f405-wing-mini-fixed-wing-fpv-flight-controller), [Flying Tech](https://www.flyingtech.co.uk/product/speedybee-f405-wing-mini-fixed-wing-flight-controller/) |
| Masse du F405 WING MINI | Fiche : FC 5,6 g + PDB 5,5 g + carte sans fil 3,2 g = 14,3 g. **La page ArduPilot donne 19 g** (« Muini:19G »). L'écart n'est pas expliqué ; 19 g est gardé comme cas pessimiste | **à peser** | [HobbyRC UK](https://www.hobbyrc.co.uk/speedybee-f405-wing-mini-flight-controller), page ArduPilot |
| Disponibilité du LittleBee-S 30 A | Les originaux sont rares (rupture annoncée chez Robu, avec un délai de réapprovisionnement), et Robu signale de nombreuses **contrefaçons** vendues sous ce nom | **à risque** : acheter chez un revendeur identifié, sinon un autre ESC 30 A sans BEC de masse comparable (à peser) | [Robu](https://robu.in/?p=57493) |
| Équivalent M10 + compas au Matek M10Q-5883 | Le M10Q-5883 est en fin de vie : la page GNSS de Matek ne propose plus que le M9N-5883. Équivalents trouvés : MicoAir M10G-5883 (u-blox M10050 + QMC5883L, 7 g, 30 mA) et FlyFishRC M10-IST8310 / M10QMC-5883L (M10050, 9 g). Les deux sont **en rupture** chez les revendeurs consultés. Le budget retient 9 g | **équivalent identifié, approvisionnement à surveiller** | [Matek GNSS](https://www.mateksys.com/?page_id=2849), [Pyrodrone (MicoAir)](https://pyrodrone.com/products/micoair-m10g-5883-gnss-gps-compass-module), [FPVFaster (FlyFishRC)](https://www.fpvfaster.com/products/flyfishrc-m10qmc-5883l-gps-module-compass) |

**Points bloquants : aucun** pour le pré-dimensionnement ni pour la phase 4. Quatre points sont à régler avant ou à l'achat (phase 6) :
1. **La WING MINI** (disponibilité et masse). Si elle est introuvable et qu'on revient au contrôleur du cahier (poste de 25 g), la 4S1P monte à **807,9 g** avec la structure à 320 g. La structure maximale admissible devient alors **312,1 g** (cible 312 g, tableau ci-dessous).
2. **Le compas du GPS :** QMC5883L ou IST8310, pas QMC5883P (absent du firmware de la cible).
3. **Le Pi reste sur le régulateur 5 V dédié** (PCB d'interconnexion), pas sur le BEC du FC.
4. **V1-PL-01 à risque :** avec les courants typiques de Raspberry Pi, le Pi et la caméra consomment 3,00 W, pour ≤ 2,5 W exigés. À mesurer en phase 6. Ce n'est pas une MOD : la valeur réelle dépend de la charge (encodage vidéo) et sera pesée au banc.

### Budget de masse réaffecté

| Poste | Cahier [g] | Pièce | Réaffecté [g] | Écart [g] |
| --- | --- | --- | --- | --- |
| Structure (panneaux, fuselage, longeron, winglets) | 320 | cahier | 320 | 0 |
| Moteur 2212 + hélice + cône | 62,0 | X2212 V3 (57 g) + APC 8×6EP + adaptateur CPA-317-N | 76,9 | +14,9 |
| Câblage, connecteurs, velcro, PCB d'interconnexion | 35,0 | cahier (PCB et régulateur 5 V gardés) | 35,0 | 0 |
| Contrôleur de vol | 25,0 | SpeedyBee F405 WING MINI (FC + PDB + carte sans fil) | 14,3 | −10,7 |
| Raspberry Pi Zero 2 W + Camera Module 3 + microSD | 20,0 | cahier | 20,0 | 0 |
| 2 servos 9 g | 18,0 | cahier | 18,0 | 0 |
| ESC 30 A | 15,0 | Favourite LittleBee-S 30 A, avec fils | 9,0 | −6,0 |
| GPS M10 + compas | 10,0 | M10 + compas (MicoAir 7 g ou FlyFishRC 9 g) | 9,0 | −1,0 |
| Récepteur ELRS + antennes | 3,0 | cahier | 3,0 | 0 |
| **Systèmes** | 188 | | **185,2** | −2,8 |
| **Sans batterie (V1-MAS-02 : ≤ 520 g)** | 508 | | **505,2** | −2,8 |
| **4S1P, cellules 69 g** | 796 | | 793,2 | −2,8 |
| **4S1P, cellules 70 g (V1-MAS-01 : ≤ 800 g)** | 800 | | **797,2** | −2,8 |
| 3S1P, cellules 69 g | 728 | | 725,2 | −2,8 |

Le plan économise 17,7 g sur ses trois postes. Le groupe propulsif réel en reprend 14,9 g.

### Nouvelle marge de masse et structure cible

| Cas | Structure max (4S1P ≤ 800 g, cellules 70 g) [g] | Structure max (V1-MAS-02) [g] | Structure cible [g] | 4S1P cellules 70 g à la cible [g] (marge) | Sans batterie à la cible [g] (marge) |
| --- | --- | --- | --- | --- | --- |
| **Plan (FC 14,3 g)** | 322,8 | 334,8 | **320** | 797,2 (+2,8) | 505,2 (+14,8) |
| Plan pessimiste (FC 19,0 g) | 318,1 | 330,1 | 318 | 799,9 (+0,1) | 507,9 (+12,1) |
| Repli : FC du cahier (25 g), ESC et GPS du plan | 312,1 | 324,1 | 312 | 799,9 (+0,1) | 507,9 (+12,1) |

- **Avec le plan, la cible de structure reste 320 g** (V1-MAS-03) et la 4S1P a **+2,8 g** de marge avec des cellules de 70 g. La marge précédente était de +0,7 g. Le groupe APC + adaptateur (76,9 g) est plus léger que le groupe CAM + RFM (80,0 g), mais le GPS équivalent retenu (9 g) est plus lourd que le Matek (8 g).
- Dans les deux autres cas, la cible passe sous les 320 g. V1-MAS-03 (≤ 320 g) reste alors tenue, mais c'est la structure qui absorbe l'écart. La pesée du contrôleur de vol, à réception, décide quelle ligne s'applique.

**Leviers non comptés, à peser :** servos plus légers (18 g au budget, plus chers : V1-BUD-01) ; câblage. Le levier « supprimer le PCB d'interconnexion » est abandonné (BEC, ci-dessus).

**Points relevés pendant la vérification :** le F405 WING APP du cahier pèse 24,5 g en carte seule, mais **35 g avec la rallonge USB** (fiche). Le poste de 25 g suppose donc la rallonge retirée.

## 7. Masse : V1-MAS-01 et V1-MAS-02 à risque, sans MOD

- **V1-MAS-01 :** la 3S1P reste conforme : 743 g avec le groupe réel et 725,2 g avec le plan. La 4S1P dépend du plan d'allègement : 815 g sans le plan et 797,2 g avec, pour des cellules de 70 g.
- **V1-MAS-02 :** 523 g sans le plan, 505,2 g avec.
- Aucune MOD n'est proposée pour ces deux exigences.

**Nouvelle règle de décision** (elle complète celle du cahier sur la structure à 330 g) : si la masse 4S1P **pesée en phase 8** dépasse 800 g, on vole en **3S1P seule**, ou bien une MOD relève V1-MAS-01, en acceptant l'enregistrement du drone et le signalement électronique.

## 8. MOD : statut

Le cahier des charges n'est pas modifié par ce dossier. Les trois MOD ci-dessous sont validées par Guilhem et sont à reporter dans le cahier.

| MOD | Exigence | Statut |
| --- | --- | --- |
| MOD-01 | V1-PERF-03 | **Validée le 13/10/2026** |
| MOD-02 | V1-PROP-02 | **Validée le 13/10/2026** |
| MOD-03 | V1-PROP-03 | **Validée le 13/10/2026** (texte fixé par Guilhem) |

### MOD-01 — V1-PERF-03 (rédigée le 12/10/2026, mise à jour et validée le 13/10/2026)

| Champ | Contenu |
| --- | --- |
| Exigence | V1-PERF-03 : autonomie réelle en 4S1P à 55 km/h, 20 % de réserve |
| Ancienne valeur | ≥ 45 min ; vérification : essai CRUISE, phase 10 |
| Nouvelle valeur | ≥ 45 min (inchangé). Statut après la phase 3 : **conforme sous réserve** avec F (46 à 53 min) ; **conforme même dans le cas pessimiste** avec G (47,6 min avec CD0 0,035 et −30 %). Vérification : analyse en phase 3, recalage en phase 4 (CD0 par xflr5) et en phase 9 (η au banc), essai CRUISE en phase 10 |
| Justification | Avec F, la marge est de +1,1 min à CD0 0,030 et −30 %, et devient négative (−2,4 min) si CD0 vaut 0,035. Le η calculé est le paramètre le plus influent (±18 % d'autonomie pour ±20 % de η) et n'est pas encore mesuré. G tient l'exigence même dans le cas pessimiste ; elle se tranche au banc (§4) |

### MOD-02 — V1-PROP-02 (validée le 13/10/2026)

| Champ | Contenu |
| --- | --- |
| Exigence | V1-PROP-02 : puissance électrique maximale du moteur |
| Ancienne valeur | 150 à 200 W |
| Nouvelle valeur | **140 à 200 W par batterie, et T/W statique ≥ 0,5 le jour chaud** |
| Justification | Le besoin calculé au point de conception est de 69 W (contrainte active : lancer main, T/W ≥ 0,5), contre « ≈ 90 W » dans le cahier. Le moteur retenu donne 145 W en 3S1P (THR_MAX 1,00, sans bridage) et 200 W en 4S1P (bridé à 0,845). La borne de 150 W n'apporte rien en 3S : le T/W le jour chaud vaut 0,71 et la montée 5,1 m/s au pire, pour 3 m/s exigés. Le critère de T/W ajouté porte la vraie contrainte, le lancer (V1-PERF-08, V1-OPS-02). Avec cette MOD, F est conforme |

### MOD-03 — V1-PROP-03 (validée le 13/10/2026)

| Champ | Contenu |
| --- | --- |
| Date | 13/10/2026 |
| Exigence | V1-PROP-03 : hélice (souhaitable) ; vérification : inspection, phase 8 |
| Ancienne valeur | Propulsive repliable |
| Nouvelle valeur | **Propulsive, rigide acceptée ; coupure moteur avant le toucher ; hélices consommables (lot de 10)** |
| Justification | Aucune hélice repliable propulsive de 8×6 n'est disponible : les CAM Carbon 8×6 et 7×6 et le moyeu RFM n'existent qu'en rotation droite (tractrice). La seule repliable propulsive de 8 pouces trouvée, l'aero-naut 8×5, fait échouer V1-PERF-03 (39,0 min) et V1-PERF-05 au modèle. L'APC 8×6EP garde la géométrie de F, donc ses performances ; elle est exposée à l'atterrissage sur le ventre, d'où la coupure moteur avant le toucher et le lot de rechange (pièce remplaçable au sens de V1-STR-02) |

Conséquences à suivre, sans MOD supplémentaire :
- la coupure moteur avant le toucher est à configurer et à tester en SITL (phase 7) ;
- la garde au sol du disque de l'hélice passe en contrainte de la phase 5 (§10).

**V1-MAS-03 :** aucune MOD aujourd'hui. Si la pesée du contrôleur de vol donne 19 g, ou si la WING MINI est remplacée, la cible de structure tombe à 318 g ou 312 g (§6). Une MOD sur V1-MAS-03, qui serait la MOD-04, serait alors à rédiger.

## 9. Réserve et RTL (sans MOD)

En fin de mission, il reste **32 %** de la capacité nominale : 1 − 0,85 × (1 − 0,20), avec 85 % d'énergie utilisable et 20 % de réserve à l'atterrissage. Cela correspond au RTL à 30 % de la mission type : le retour est déclenché juste avant d'entamer la réserve. Les deux hypothèses du cahier sont cohérentes et aucune MOD n'est nécessaire.

## 10. Contraintes transmises à la phase 5 (CAO)

1. **Garde au sol de l'hélice.** Le disque de l'APC 8×6EP balaie **101,6 mm** sous l'axe moteur (88,9 mm pour la 7×6EP). Il faut placer l'axe moteur le plus haut possible et vérifier la garde au sol à l'atterrissage sur le ventre (V1-STR-02), aile posée et fuselage écrasé dans l'herbe.
2. **Montage de l'hélice.** L'adaptateur accepte un moyeu de 10,5 mm au plus : il reste 1,1 mm de réserve avec la 8×6EP. Il faut aussi prévoir l'accès à l'écrou de 10 mm pour changer l'hélice au terrain (lot consommable).
3. **Contrôleur de vol.** Prévoir le logement pour la masse pessimiste (19 g) et le repli possible vers le contrôleur du cahier (§6). Le Pi reste alimenté par le régulateur 5 V du PCB d'interconnexion.

## 11. Ce qu'il faut mesurer, par ordre de priorité

1. **Le η de propulsion (phase 9, puis en vol en phase 10)** : c'est le paramètre le plus influent (±18 % d'autonomie pour ±20 % de η). Il faut mesurer Ct0 et Cp0 au banc pour recaler le modèle, puis la puissance en croisière à 55 km/h en 4S1P, avec la 8×6EP puis la 7×6EP (§4). Cette mesure décide de G et lève la réserve de MOD-01.
2. **Le CD0 (phase 4 avec xflr5, phase 10 en vol)** : de 0,025 à 0,035, l'autonomie varie de +15 % à −11 %. À 0,035, F ne tient plus 45 min.
3. **La FM au point fixe (phase 9)** : elle fixe le point de conception (P/W de +25 % à −5 % pour FM ±20 %), donc le T/W au lancer.
4. **La résistance interne de la P45B (phase 9)** : R_dc est pris à 15 mΩ, environ deux fois la valeur AC de la fiche. Elle conditionne la tension sous charge, le bridage THR_MAX et les cas d'erreur.
5. **Les masses réelles (phases 5 à 8)** : à peser au fil des achats et des impressions (colonne « pesé » du budget).
   - Dès réception, en priorité : le **contrôleur de vol** (14,3 ou 19 g), puis l'adaptateur et l'hélice. La pesée du contrôleur décide de la structure cible.
   - Ensuite : la structure (aucune marge), les cellules et le câblage.
6. **La puissance du Pi Zero 2 W et de la caméra (phase 6)**, en enregistrement 1080p : V1-PL-01 est à risque avec les valeurs typiques.

## 12. Écarts par rapport à la skill /aircraft-design

| Écart | Raison | Recalage |
| --- | --- | --- |
| Modèle propulsif hors skill : hélice Ct(J) et Cp(J) (k_JT = 1,10, k_JP = 1,6), moteur à courant continu (Kv, Rm, I0), ESC (R_esc et pertes fixes de 0,5 W), batterie (R_dc). Point de fonctionnement résolu par fzero | La skill ne traite pas la propulsion électrique en détail | Phase 9 (banc). Robustesse du classement testée à k_JT ±10 % |
| Le modèle d'hélice ne dépend que de D et du pas : APC 8×6EP et CAM 8×6 ont les mêmes performances au modèle | Pas de données UIUC propres à chaque hélice dans le modèle | Phase 9 (banc) |
| Autonomie par bilan d'énergie, et non par Breguet | Breguet suppose un η constant et une masse variable. En électrique, la masse est constante et le η varie avec V | — |
| Jour chaud modélisé en ISA + ΔT | Cas du terrain près de Toulouse (200 m, 35 °C) | — |
| Contrainte de lancer main par le T/W statique, avec la théorie de Froude et une FM | Absente de la skill (avions à piste) | Phase 9 (FM) |
| CD0 corrigé du Reynolds sur la méthode Cfe·Swet/S (C3 p.85) | Le Cfe de la skill vaut pour Re ≈ 10⁷ ; ici Re ≈ 2,7·10⁵ | Phase 4 (xflr5) |
| Critères pratiques : V_cr ≥ 2·V_vent ; vitesse de pas ≥ 1,5·V_cr | Absents de la skill | Phase 10 |
| V1-PERF-07 : Vz = (T·V − Pn)/(m·g) avec Pn calculé en palier | Approximation de pente faible (C1 p.79), alors que la pente est forte ici. En montée, la portance est inférieure au poids : la traînée induite et Pn sont légèrement surestimés, ce qui va dans le sens de la sécurité | Phase 10 |
| Bilan du BEC 5 V et puissance du Pi par courants typiques | Hors skill (avionique) ; valeurs de la documentation Raspberry Pi | Phase 6 (mesure) |
| Masses et caractéristiques des pièces relevées sur fiches et chez des revendeurs | Données d'entrée, citées dans `params_v1.m` | Pesée en phases 5 à 8 |

## 13. Verdict de la phase 3

**GO vers la phase 4.**

- **Ce qui est acquis :**
  - le point de conception (31,4 N/m², 69 W requis) ;
  - le moteur (X2212 V3 980 KV) et le groupe propulsif (APC 8×6EP + adaptateur CPA-317-N) ;
  - V1-PERF-01, 02, 04, 05, 06, 07 et 08 conformes au modèle ;
  - V1-PROP-02 et V1-PROP-03 conformes avec MOD-02 et MOD-03 ;
  - V1-PERF-03 conforme sous réserve (MOD-01) ;
  - V1-MAS-01 tenue avec le plan validé : +2,8 g en 4S1P avec des cellules de 70 g.
- **Réserves suivies (aucune ne bloque la phase 4) :**
  1. V1-PERF-03 : CD0 en phase 4, η en phase 9 ;
  2. V1-MAS-01 et 02 à risque : la marge de 2,8 g dépend de la pesée du contrôleur de vol et de la disponibilité de la WING MINI (§6) ; règle du §7 en phase 8 ;
  3. V1-PL-01 à risque (3,00 W typiques pour 2,5 W) : mesure en phase 6 ;
  4. achats de la phase 6 : compas QMC5883L ou IST8310, LittleBee-S d'origine, bague de 6 mm de la 7×6EP, adaptateur livré avec le moteur à peser ;
  5. G à trancher au banc en phase 9.
- **La phase 4 peut démarrer** (xflr5 : polaire, CD0, Cm0, marge statique). Le CD0 qu'elle fournira est la deuxième inconnue de V1-PERF-03.

## Sources consultées le 13/10/2026

- SunnySky X2212 V3 : [fiche](https://sunnyskyusa.com/products/sunnsky-x2212) ; [axe de rechange de 3,17 mm](https://sunnyskyusa.com/products/replacement-shaft-for-sunnysky-x2212-motors-3-175mm) ; [contenu du paquet (ReadyMadeRC)](https://www.ReadyMadeRC.com/products/details/sunny-sky-x-series-v3-x2212-980kv)
- Hélices APC : [8x6EP](https://www.apcprop.com/product/8x6ep/) ; [7x6EP](https://www.apcprop.com/product/7x6ep/) ; [limites de régime](https://www.apcprop.com/technical-information/rpm-limits/) ; [bagues LPAR06E (AMain)](https://www.amainhobbies.com/apc-electric-propeller-adapter-rings-6-sets-1-8-4mm-5mm-6mm-5-16-apclpar06e/p261605) ; [bagues SF métriques (ReadyMadeRC)](https://www.readymaderc.com/products/details/apc-adapter-rings-metric-sf)
- Adaptateur RC Dude CPA-317-N : [rcdude.com](https://rcdude.com/collet-style-prop-adapter-with-hex-nut-for-3-17mm-motor-shafts.html) ; écartés : [HobbyKing 3,17 mm](https://hobbyking.com/en_us/aluminum-propeller-adapter-collet-type-3-17mm.html), [HobbyKing noir 3,17 mm](https://hobbyking.com/en_us/propeller-adapter-collet-type-black-3-17mm.html), [E-flite EFLM1923 (Stevens Aero)](https://www.stevensaero.com/product/eflm1923/), [Horizon Hobby](https://www.horizonhobby.com/product/prop-adapter-w-collet-3.17mm/EFLM1923.html)
- Pales aero-naut CAM Carbon 8×6 : [Zeller](https://zeller-modellbau.com/antrieb/luftschrauben/cam-carbon-klappluftschr-blaetter-8x6/) ; [Reisenauer](https://www.reisenauer.de/aid-578-Aeronaut-Cam-Carbon-8x6.html) ; 7×6 : [hacker-motor-shop](https://www.hacker-motor-shop.com/aero-naut-camcarbon-7x6-klappluftschraube.htm?a=article&ProdNr=10618500&p=1960)
- Cône RFM de 30 mm, alésage 3,17 mm : [f3x.de](https://www.f3x.de/30mm-3,17mm-rfm-cfk-spinner-weiss-versetzt-0-grad-verdreht-kuehlloch)
- Pales propulsives aero-naut : [Lindinger, 8×5 linkslaufend](https://www.lindinger.at/de/RC-Flugzeuge/RC-Flugzeug-Elektro-Antriebe/Luftschrauben/Klappluftschrauben/AERONAUT-KLAPPLUFTSCHRAUBE-8x5-linkslaufend-Klappluftschraube/76283)
- SpeedyBee F405 WING MINI : [ArduPilot](https://ardupilot.org/plane/docs/common-speedybeef405wing.html) ; [features.txt de la cible](https://firmware.ardupilot.org/Plane/stable/SpeedyBeeF405WING/features.txt) ; [HobbyRC UK](https://www.hobbyrc.co.uk/speedybee-f405-wing-mini-flight-controller) ; [FPVFaster](https://fpvfaster.com.au/products/speedybee-f405-wing-mini-fixed-wing-flight-controller) ; disponibilité : [fpv24](https://www.fpv24.com/en/speedy-bee/speedybee-f405-wing-mini-fixed-wing-fpv-flight-controller), [Flying Tech](https://www.flyingtech.co.uk/product/speedybee-f405-wing-mini-fixed-wing-flight-controller/), [6sfull](https://www.6sfull.cz/en/speedybee-f405-wing-mini-app/)
- F405 WING APP (35 g avec la rallonge USB) : [manuel](https://www.manualslib.com/manual/3340724/Speedybee-F405-Wing-App.html)
- Raspberry Pi Zero 2 W et Camera Module, courants : [documentation Raspberry Pi](https://www.raspberrypi.com/documentation/computers/raspberry-pi.html)
- ESC Favourite LittleBee-S 30 A : [Hobbyking](https://hobbyking.com/en_us/favourite-littlebee-s-30a-2-6s-opto-esc.html) ; [Robu (contrefaçons, stock)](https://robu.in/?p=57493)
- GPS : [Matek, page GNSS](https://www.mateksys.com/?page_id=2849) ; [MicoAir M10G-5883 (Pyrodrone)](https://pyrodrone.com/products/micoair-m10g-5883-gnss-gps-compass-module) ; [FlyFishRC M10 (FPVFaster)](https://www.fpvfaster.com/products/flyfishrc-m10qmc-5883l-gps-module-compass)
