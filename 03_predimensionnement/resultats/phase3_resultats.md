# Phase 3 — Pré-dimensionnement de la V1 (aile volante 1 m)

13/10/2026 · calculs MATLAB : `03_predimensionnement/dimensionnement.m` (paramètres : `params_v1.m`)

Tous les chiffres de ce rapport sortent de MATLAB. Les tableaux complets sont dans [tableaux_auto.md](tableaux_auto.md), réécrit à chaque exécution, et les figures dans [figures/](../figures/). Les valeurs relevées sur des fiches (masses, prix, courants) sont citées avec leur source. Le cahier des charges n'est pas modifié : les changements d'exigences sont rédigés ci-dessous sous forme de brouillons de MOD, à valider par Guilhem.

## Synthèse

- **Configuration retenue (F) :** moteur SunnySky X2212 V3 980 KV, hélice 8×6 sur les deux batteries. THR_MAX vaut 1,00 en 3S1P ; en 4S1P, il est limité à 0,845 pour plafonner la puissance à 200 W.
- **Option à trancher au banc en phase 9 (G) :** même moteur, avec une 7×6 en 4S1P.
- **Autonomie (V1-PERF-03) :** F donne 46 à 53 min en 4S1P à 55 km/h. L'exigence est conforme sous réserve (MOD-01). Avec un CD0 de 0,035, F tombe à 43 min, alors que G tient encore 48 min.
- **Masse :**
  - avec le groupe propulsif réel, la 4S1P pèse 814 g (818 g avec des cellules de 70 g) : V1-MAS-01 et V1-MAS-02 sont **à risque** ;
  - le plan d'allègement proposé ramène la 4S1P à **799,3 g avec des cellules de 70 g**, soit une marge de +0,7 g, sans toucher à la structure : la cible de structure reste 320 g et MOD-03 est inutile.
- **Risque nouveau, à trancher avant l'achat (V1-PROP-03) :**
  - les pales CAM Carbon 8×6 et 7×6 et le moyeu RFM sont tous en **rotation droite (montage tracteur)**, et je n'en ai trouvé aucune version propulsive ;
  - la seule pale repliable propulsive de 8 pouces trouvée est une 8×5 aero-naut, et avec elle V1-PERF-03 et V1-PERF-05 échouent (§5).
- **Verdict : GO conditionnel vers la phase 4** (§12).

## 1. Vérification des exigences (configuration retenue F)

Conditions : η calculé, masse avec le groupe propulsif réel (cellules de 69 g), ISA, CD0 = 0,030 sauf mention. Les autonomies réelles sont données de −30 % à −20 % sur l'autonomie théorique.

| Exigence | Valeur calculée | Exigence (cahier) | Statut | Marge |
| --- | --- | --- | --- | --- |
| V1-MAS-01 | 4S1P : 814 g (cellules 69 g), 818 g (70 g) ; avec le plan d'allègement : 795,3 g, 799,3 g | ≤ 800 g | **à risque** | −18 g sans plan ; +0,7 g avec plan (cellules 70 g) |
| V1-MAS-02 | Sans batterie : 526 g ; avec le plan : 507,3 g | ≤ 520 g | **à risque** | −6 g sans plan ; +12,7 g avec plan |
| V1-MAS-03 | Structure du budget 320 g ; maximum admissible avec le plan 320,7 g (4S, cellules 70 g) ; cible 320 g | ≤ 320 g (souhaitable) | oui (budget) | 0 g sous la cible |
| V1-PERF-01 | Vs à 800 g = 28,8 km/h (ISA) ; 30,1 km/h TAS le jour chaud | ≤ 32 km/h (cible 29) | oui | 1,9 km/h (pire cas) |
| V1-PERF-02 | Palier tenu de 45 à 60 km/h ; rapport cyclique à 45 / 60 km/h : 0,59 / 0,78 en 3S, 0,45 / 0,58 en 4S (THR_MAX 1,00 / 0,84) | 45 à 60 km/h | oui | d(60 km/h, 4S) = 0,69 × THR_MAX |
| V1-PERF-03 | 4S1P à 55 km/h, η calculé 0,538 : 46 à 53 min ; CD0 0,035, −30 % : 43 min (G : 48 min) | ≥ 45 min | **sous réserve (MOD-01)** | +1,1 min (CD0 0,030, −30 %) ; −2,5 min (CD0 0,035) |
| V1-PERF-04 | 4S1P à 40 km/h, η calculé 0,537 : 79 à 91 min ; CD0 0,035, −30 % : 75 min | ≥ 70 min (souhaitable) | oui | +5 min (CD0 0,035, −30 %) |
| V1-PERF-05 | 3S1P à 55 km/h, η calculé 0,531 : 35 à 40 min ; CD0 0,035, −30 % : 32 min | ≥ 30 min | oui | +2 min (CD0 0,035, −30 %) |
| V1-PERF-06 | V_cr/V_vent = 2,75 ; vitesse sol face au vent = 35 km/h | ≥ 20 km/h (critère V_cr ≥ 2·V_vent) | oui | V_cr/V_vent − 2 = 0,75 |
| V1-PERF-07 | Plein gaz (THR_MAX) à 1,3·Vs, masse réelle : 5,4 / 5,1 m/s en 3S, 6,7 / 6,4 m/s en 4S (ISA / jour chaud) | ≥ 3 m/s | oui | +2,1 m/s (pire) |
| V1-PERF-08 | T/W statique : 0,76 / 0,70 en 3S, 0,86 / 0,80 en 4S (ISA / jour chaud) | ≥ 0,5 | oui | +0,20 (pire) |
| V1-PROP-02 | P max batterie pleine : 145 W en 3S, 200 W en 4S (besoin au point de conception : 69 W) | 150 à 200 W | **NON en 3S (MOD-02)** | 3S : −5 W sous 150 W ; avec MOD-02 : conforme |
| V1-PROP-03 | Pales CAM Carbon 8×6 / 7×6 et moyeu RFM en rotation droite (tracteur) ; aucune version propulsive trouvée | Propulsive repliable (souhaitable) | **à risque** | voir §5 |

Les exigences hors du champ de la phase 3 (stabilité, structure, avionique, opérations, réglementation) sont vérifiées dans les phases suivantes. Le tableau avec les hypothèses du cahier (η = 0,5, budget du cahier), qui sert de référence avant le choix du moteur, est dans [tableaux_auto.md](tableaux_auto.md).

V1-PERF-07 est maintenant calculée avec le moteur retenu : poussée du modèle à THR_MAX, puis Vz = (T·V − Pn)/(m·g) (C1 p.79). Le calcul précédent supposait 150 W et η = 0,5. La formule néglige la pente de montée, qui n'est pas faible ici ; c'est signalé au §11.

## 2. Point de conception

Le point est figé par la géométrie du cahier (S = 0,25 m², λ = 4) à la masse maximale de 800 g, dans le pire cas entre ISA et le jour chaud (200 m, 35 °C).

| Grandeur | Valeur |
| --- | --- |
| Charge alaire retenue | 31,4 N/m² (3,20 kg/m²) |
| P/W requis | 86 W/kg, soit 69 W électriques |
| Contrainte active | Lancer main, T/W ≥ 0,5 (identique pour CD0 = 0,025, 0,030 et 0,035) |
| Optimum au sens de la skill (C3 p.73) | W/S = 35,4 N/m² (3,61 kg/m²), P/W = 92 W/kg ; non retenu, car S est figée par le cahier |
| Décrochage à 800 g | 28,8 km/h ISA ; 30,1 km/h TAS le jour chaud |

Le besoin de 69 W est bien en dessous des 145 W (3S) et 200 W (4S) disponibles. La puissance installée est fixée par l'autonomie et la marge au lancer, pas par une contrainte de vol. Voir [fig02](../figures/) (diagrammes de contraintes) et le tableau « Point de conception » de [tableaux_auto.md](tableaux_auto.md).

## 3. Choix du moteur et de l'hélice

Le choix de Guilhem (13/10/2026) est F : X2212 V3 980 KV, 8×6 en 3S1P et en 4S1P, THR_MAX 4S de 0,845 (limité par la puissance de 200 W). Il est inscrit dans `params_v1.m` (`p.choix.ref = "F"`). Trois éléments du calcul le justifient.

**Classement.** Le classement trie les options sur l'autonomie réelle en 4S1P à 55 km/h, à −30 %.
- F est 6e sur 9, avec 46,1 min.
- Les trois options à hélice unique sont dans la résolution du modèle : E-1260 fait 46,5 min, E-1100 46,2 min, F 46,1 min.
- Si l'hypothèse d'hélice en vol varie de ±10 % (k_JT), F passe au 4e ou au 6e rang. Le modèle ne peut donc pas départager F et E sur l'autonomie.
- Les options devant F (C, G, A) utilisent une hélice différente en 4S. C fait échouer V1-PERF-05 (27 min en 3S).

**Marge de poussée.**
- Le jour chaud, F donne un T/W de 0,70 en 3S et 0,80 en 4S. Les deux options X2208 donnent 0,65 / 0,59 et 0,64 / 0,59.
- C'est la marge la plus large des options à hélice unique pour le lancer main (V1-PERF-08, V1-OPS-02).
- Montée plein gaz : 5,1 m/s au pire (3S, jour chaud), pour 3 m/s exigés.

**Tolérance à une erreur de fichier.** Le cas étudié est une 4S1P branchée avec le fichier de paramètres 3S, batterie pleine, au point fixe, en ISA.
- F est inchangé, puisque THR_MAX vaut déjà 1,00 en 3S : 296 W et 19,1 A au moteur, soit 1,04 fois la limite continue (18,4 A) et 0,74 fois la limite de 30 s (26 A). **Le moteur survit 10 s plein gaz.**
- Avec le X2208, le moteur dépasse sa limite de courte durée :
  - E-1260 : 20,9 A, soit 1,39 fois la limite de 30 s ;
  - E-1100 : 17,8 A, soit 1,27 fois la limite de 15 s.
- Ni l'ESC 30 A, ni les cellules, ni les pales ne sont dépassés : 64 % de 30 A, 43 % de 45 A et 13 229 tr/min pour une limite de 16 000 tr/min.

**Ce que F coûte.**
- Son groupe propulsif pèse plus lourd que celui des options X2208 : 80 g contre 69 g, pour 62 g au budget. En 4S1P, cela donne 814 g contre 803 g.
- Sa puissance max en 3S est de 145 W, sous la borne de 150 W de V1-PROP-02 (MOD-02).

| Option | Hélice 3S / 4S | THR_MAX 3S / 4S | η 4S 55 km/h | V1-PERF-03 [min] | Idem, CD0 0,035, −30 % | V1-PERF-04 [min] | V1-PERF-05 [min] | T/W jour chaud 3S / 4S | P max 3S / 4S [W] |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| **F (retenue)** | 8×6 / 8×6 | 1,00 / 0,84 | 0,538 | 46,1 à 52,7 | 42,5 | 79 à 91 | 35 à 40 | 0,70 / 0,80 | 145 / 200 |
| G (banc) | 8×6 / 7×6 | 1,00 / 0,99 | 0,621 | 52,3 à 59,8 | 47,6 | 84 à 96 | 35 à 40 | 0,70 / 0,72 | 145 / 200 |
| F-8x5 (information) | 8×5 / 8×5 | 1,00 / 0,88 | 0,446 | 39,0 à 44,6 | 36,4 | 70 à 80 | 29 à 34 | 0,68 / 0,84 | 131 / 200 |
| C (pour mémoire) | 8,5×5 / 7×6 | 1,00 / 1,00 | 0,641 | 53,8 à 61,5 | 48,8 | 87 à 100 | 27 à 31 | 0,73 / 0,66 | 133 / 174 |

Le classement complet, sa robustesse, la décomposition du η et les bridages sont dans [tableaux_auto.md](tableaux_auto.md). Voir aussi [fig09](../figures/fig09_rendement_croisiere.png) et [fig10](../figures/fig10_classement_options.png).

## 4. Option G, à trancher au banc en phase 9

G garde le moteur et la 8×6 de F en 3S1P, mais monte une 7×6 en 4S1P, bridée à 0,99 par la puissance. Dans le modèle :
- le η de l'hélice à 55 km/h passe de 0,676 à 0,799 ;
- le η global passe de 0,538 à 0,621 ;
- V1-PERF-03 passe de 46 à 53 min (F) à 52 à 60 min (G) ;
- **G tient 45 min même dans le cas pessimiste** (CD0 0,035, −30 %) : 47,6 min.

Le gain repose entièrement sur le modèle d'hélice en vol, qui n'est pas recalé : c'est pourquoi la décision se prend au banc.

**Ce que G introduit.** Il y a deux jeux de pales, donc deux erreurs de montage possibles :

| Cas | P batterie [W] | I moteur [A] | Régime [tr/min] | T/W au lancer, jour chaud | Survit 10 s |
| --- | --- | --- | --- | --- | --- |
| 4S1P, fichier 3S, 7×6 montée | 204 | 12,9 (0,70× continu) | 14 223 | — | oui |
| 4S1P, fichier 4S, 8×6 restée montée | 290 | 18,9 (1,03× continu ; 0,73× 30 s) | 13 146 | — | oui |
| 3S1P, fichier 3S, **7×6 restée montée** | — | — | — | **0,47 (< 0,5 : V1-PERF-08 non tenue)** | — |

Le moteur survit à toutes les erreurs. **Le lancer d'une 3S avec la 7×6 est sous le seuil de poussée** : si G est retenue, la liste de vérification avant vol devra lier la batterie à l'hélice.

**Ce qu'il faut mesurer pour trancher entre F et G** (même moteur, 4S1P) :
1. **Au banc, en phase 9 (point fixe) :**
   - pour chaque hélice : poussée, puissance batterie, courant et régime en fonction du gaz ;
   - vérifier qu'au THR_MAX calculé (0,845 avec la 8×6, 0,99 avec la 7×6), la puissance reste sous 200 W, le courant sous 18,4 A et le régime sous 16 000 tr/min ;
   - mesurer le T/W statique de la 7×6 en 4S1P (0,77 ISA / 0,72 jour chaud au modèle) ;
   - recaler Ct0 et Cp0 du modèle.
2. **En vol (CRUISE), phases 9 et 10 :** puissance batterie en palier à 55 km/h, en 4S1P, avec chaque hélice. Mesure par le capteur de courant de la PDB, sur le journal ArduPilot, à la même masse et par vent faible. C'est cette mesure qui tranche : le banc statique ne mesure pas le η en vol, et c'est lui qui porte l'écart entre F et G.
3. **Critère de décision :** G est retenue si sa puissance en croisière est inférieure à celle de F de plus que la dispersion entre vols répétés. Sinon, on garde F, qui n'a qu'une hélice et donc aucune erreur de montage possible.

Point lié au §5 : la 7×6 repliable n'existe pas non plus en version propulsive. En vol, G devrait se faire avec une APC 7×6EP rigide.

## 5. Groupe propulsif : vérification du moyeu (à trancher avant l'achat)

Vérifications faites le 13/10/2026 :

| Point vérifié | Résultat | Source |
| --- | --- | --- |
| Le moyeu RFM accepte-t-il la CAM 7×6 ? | **Oui.** Le moyeu reçoit des pieds de pale de 8 mm avec un trou de 3 mm ; la CAM 7×6 a un pied de 8 mm et un trou de 3 mm (16 000 tr/min max) | [f3x.de](https://www.f3x.de/30mm-3,17mm-rfm-cfk-spinner-weiss-versetzt-0-grad-verdreht-kuehlloch), [hacker-motor-shop](https://www.hacker-motor-shop.com/aero-naut-camcarbon-7x6-klappluftschraube.htm?a=article&ProdNr=10618500&p=1960), [Reisenauer](https://www.reisenauer.de/aid-575-Aeronaut-Cam-Carbon-7x6.html) |
| Le moyeu RFM accepte-t-il l'axe du X2212 V3 ? | **Oui.** Alésage de 3,17 mm ; l'axe du X2212 V3 fait 3,17 mm (les X2212 d'avant 2013 ont un axe de 3 mm). Le cône se bloque par vis pointeau : il faut meuler un méplat de 0,5 mm sur l'axe | [f3x.de](https://www.f3x.de/30mm-3,17mm-rfm-cfk-spinner-weiss-versetzt-0-grad-verdreht-kuehlloch), [SunnySky (axe de rechange)](https://sunnyskyusa.com/products/replacement-shaft-for-sunnysky-x2212-motors-3-175mm) |
| Existe-t-il une version propulsive ? | **Non trouvée.** Le moyeu RFM est « Drehrichtung rechts (Standard) », les CAM Carbon 8×6 et 7×6 sont « rechtslaufend ». RFM indique « autres types sur demande » sans confirmer de version gauche, et une version gauche du moyeu seule ne suffirait pas : il faut aussi des pales gauches | mêmes sources ; [page RFM de f3x.de](https://www.f3x.de/rfm-freudenthaler/) |

**Alternatives propulsives trouvées.** Les masses sont celles des fiches ; « non publiée » signifie que je n'ai trouvé aucune masse.

| Hélice + moyeu | Type | Pales [g] | Moyeu ou adaptateur [g] | Moteur + pales + moyeu [g] | Performances |
| --- | --- | --- | --- | --- | --- |
| CAM Carbon 8×6 + RFM 30 mm (référence, **tracteur**) | repliable | 9,0 | 14,0 | 80,0 | F |
| aero-naut 8×5 « linkslaufend » Carbon (722415) + cône aero-naut CN 30/3,17 (725903, pince conique, pied de 8 mm) | repliable, **propulsive** | non publiée | non publiée | non calculable | F-8x5 : V1-PERF-03 à 39,0 min et V1-PERF-05 à 29 min, **non tenues** |
| APC 8x6EP (LP08060EP, « Thin Electric Pusher ») + adaptateur | **rigide**, propulsive | 13,9 | non publiée | ≥ 70,9 (sans adaptateur) | celles de F au modèle (même diamètre et même pas) |
| APC 7x6EP + adaptateur | rigide, propulsive | 7,9 | non publiée | ≥ 64,9 (sans adaptateur) | celles de G au modèle |

En pales repliables propulsives, aero-naut ne propose que les tailles 8×5, 9,5×5 et 10×7. La 9,5×5 n'a pas été calculée. Une pale générique « 8×6 CCW » à pied de 8 mm existe chez un revendeur néo-zélandais (Pilot Petes), mais « CCW » ne suffit pas à dire qu'elle est propulsive : je ne la retiens pas.

**Décision à prendre (je ne choisis pas) :**
- **(a)** Hélice rigide APC 8×6EP : géométrie de F conservée, moins lourde que la référence, mais V1-PROP-03 (souhaitable) n'est pas tenue et l'hélice est exposée à l'atterrissage sur le ventre (pièce remplaçable, V1-STR-02).
- **(b)** Pales repliables aero-naut 8×5 propulsives : V1-PROP-03 tenue, mais V1-PERF-03 et V1-PERF-05 échouent au modèle.
- **(c)** Demander à RFM un moyeu à rotation gauche et chercher des pales gauches de 8×6 et 7×6 : disponibilité non confirmée.
- **(d)** Calculer d'abord la 9,5×5 propulsive avec le même moteur.

**À ne pas acheter avant cette décision :** les deux jeux de pales CAM et le moyeu RFM. Ce sont des pièces tractrices.

**Budget financier.** Le moyeu RFM coûte à lui seul 45,54 € (f3x.de), alors que le cahier prévoit un lot « Hélices propulsives repliables + cône » à 15 € (V1-BUD-01). À suivre en phase 6.

Les paramètres de l'option de référence (`p.gp`) ne sont pas modifiés tant que la décision n'est pas prise. Les alternatives sont dans `p.gp.alt`.

## 6. Plan d'allègement et budget de masse réaffecté

**Objectif :** une 4S1P sous 800 g avec des cellules de 70 g (la masse maximale de la fiche Molicel), soit 18 g à trouver avec le groupe propulsif réel de F.

**Économies concrètes retenues** (masses des fiches, consultées le 13/10/2026) :

| Poste | Cahier [g] | Pièce proposée | Réaffecté [g] | Écart [g] | Source |
| --- | --- | --- | --- | --- | --- |
| Contrôleur de vol | 25,0 | SpeedyBee F405 WING MINI : FC 5,6 g + PDB 5,5 g + carte sans fil 3,2 g. Cible ArduPilot SpeedyBeeF405WING ; PDB avec capteur de courant 80 A, BEC FC 5,2 V / 2 A et BEC servos 5 V / 4 A | 14,3 | −10,7 | [fiche reprise par HobbyRC UK](https://www.hobbyrc.co.uk/speedybee-f405-wing-mini-flight-controller) |
| ESC 30 A | 15,0 | Favourite LittleBee-S 30 A : 30 A continu, 35 A en crête, sans BEC, avec fils | 9,0 | −6,0 | [Hobbyking](https://hobbyking.com/en_us/favourite-littlebee-s-30a-2-6s-opto-esc.html) |
| GPS M10 + compas | 10,0 | Matek M10Q-5883 (produit en fin de vie : un équivalent M10 + compas est à retrouver à l'achat) | 8,0 | −2,0 | [Matek](https://www.mateksys.com/?portfolio=m10q-5883) |
| **Gain du plan** | | | | **−18,7** | |

**Budget réaffecté.**

| Poste | Cahier [g] | Réaffecté [g] |
| --- | --- | --- |
| Structure (panneaux, fuselage, longeron, winglets) | 320 | 320 |
| Moteur + hélice repliable + cône (groupe réel de F) | 62,0 | 80,0 |
| Câblage, connecteurs, velcro, PCB d'interconnexion | 35,0 | 35,0 |
| Contrôleur de vol | 25,0 | 14,3 |
| Raspberry Pi Zero 2 W + Camera Module 3 + microSD | 20,0 | 20,0 |
| 2 servos 9 g | 18,0 | 18,0 |
| ESC 30 A | 15,0 | 9,0 |
| GPS M10 + compas | 10,0 | 8,0 |
| Récepteur ELRS + antennes | 3,0 | 3,0 |
| **Systèmes** | 188 | 187,3 |
| **Sans batterie (V1-MAS-02 : ≤ 520 g)** | 508 | **507,3** |
| **4S1P, cellules 69 g** | 796 | 795,3 |
| **4S1P, cellules 70 g (V1-MAS-01 : ≤ 800 g)** | 800 | **799,3** |
| 3S1P, cellules 69 g | 728 | 727,3 |

**Structure cible qui en découle.**
- Avec les systèmes réaffectés et une 4S1P à cellules de 70 g, la structure peut atteindre 320,7 g sans dépasser 800 g. V1-MAS-02 la limiterait à 332,7 g.
- **La cible de structure reste donc 320 g**, la valeur de V1-MAS-03, et **MOD-03 n'est pas nécessaire**.
- Le budget boucle avec seulement +0,7 g de marge : la structure n'a aucun gramme de tolérance.

**Leviers non comptés, à peser ou à préciser** (aucune masse publiée trouvée, ou décision encore ouverte) :
- **Câblage (35 g) :** la PDB du MINI fournit le 5 V. Le PCB d'interconnexion et son régulateur pourraient disparaître, si le BEC FC de 2 A alimente aussi le Pi Zero 2 W (à mesurer au banc, V1-AV-05).
- **Hélice :** l'APC 8×6EP rigide (§5) donne un groupe d'au moins 70,9 g, adaptateur non compris, contre 80,0 g pour la référence.
- **Servos (18 g) :** des servos plus légers existent, mais plus chers (V1-BUD-01).

**Points relevés pendant la vérification :**
- Le SpeedyBee F405 WING APP prévu au cahier pèse 24,5 g en carte seule, mais **35 g avec la rallonge USB** (fiche). Le poste de 25 g du cahier suppose donc la rallonge retirée.
- Les cas d'erreur de F restent valables avec le LittleBee-S, qui a le même calibre de 30 A : 19,1 A au pire, soit 64 % du calibre.

## 7. Masse : V1-MAS-01 et V1-MAS-02 à risque, sans MOD

- **V1-MAS-01 :** la 3S1P reste conforme, à 746 g avec le groupe réel et 727,3 g avec le plan. La 4S1P dépend du plan d'allègement : 818 g sans le plan et 799,3 g avec, pour des cellules de 70 g.
- **V1-MAS-02 :** 526 g sans le plan, 507,3 g avec.
- Aucune MOD n'est proposée pour ces deux exigences.

**Nouvelle règle de décision** (complète celle du cahier sur la structure à 330 g) : si la masse 4S1P **pesée en phase 8** dépasse 800 g, on vole en **3S1P seule**, ou bien une MOD relève V1-MAS-01, en acceptant l'enregistrement du drone et le signalement électronique.

## 8. Brouillons de MOD (à valider ; le cahier n'est pas modifié)

### MOD-01 — V1-PERF-03 (rédigée le 12/10/2026, mise à jour le 13/10/2026)

| Champ | Contenu |
| --- | --- |
| Exigence | V1-PERF-03 : autonomie réelle en 4S1P à 55 km/h, 20 % de réserve |
| Ancienne valeur | ≥ 45 min ; vérification : essai CRUISE, phase 10 |
| Nouvelle valeur | ≥ 45 min (inchangé). Statut après la phase 3 : **conforme sous réserve** avec F (46 à 53 min) ; **conforme même dans le cas pessimiste** avec G (47,6 min avec CD0 0,035 et −30 %). Vérification : analyse en phase 3, recalage en phase 4 (CD0 par xflr5) et en phase 9 (η au banc), essai CRUISE en phase 10 |
| Justification | Avec F, la marge est de +1,1 min à CD0 0,030 et −30 %, et devient négative (−2,5 min) si CD0 vaut 0,035. Le η calculé est le paramètre le plus influent (±18 % d'autonomie pour ±20 % de η) et n'est pas encore mesuré. G garde l'exigence même dans le cas pessimiste ; elle se tranche au banc (§4) |

### MOD-02 — V1-PROP-02 (13/10/2026)

| Champ | Contenu |
| --- | --- |
| Exigence | V1-PROP-02 : puissance électrique maximale du moteur |
| Ancienne valeur | 150 à 200 W |
| Nouvelle valeur | **140 à 200 W par batterie, et T/W statique ≥ 0,5 le jour chaud** |
| Justification | Le besoin calculé au point de conception est de 69 W (contrainte active : lancer main, T/W ≥ 0,5), contre « ≈ 90 W » dans le cahier. Le moteur retenu donne 145 W en 3S1P (THR_MAX 1,00, sans bridage) et 200 W en 4S1P (bridé à 0,845). La borne de 150 W n'apporte rien en 3S : le T/W le jour chaud vaut 0,70 et la montée 5,1 m/s au pire, pour 3 m/s exigés. Le critère de T/W ajouté porte la vraie contrainte, le lancer (V1-PERF-08, V1-OPS-02). Avec cette MOD, F est conforme |

### MOD-03 — V1-MAS-03

**Non nécessaire.** Le budget réaffecté (§6) n'abaisse pas la cible de structure, qui reste à 320 g (maximum admissible : 320,7 g). Si le plan d'allègement n'était pas appliqué, il faudrait revoir ce point.

## 9. Réserve et RTL (sans MOD)

En fin de mission, il reste **32 %** de la capacité nominale : 1 − 0,85 × (1 − 0,20), avec 85 % d'énergie utilisable et 20 % de réserve à l'atterrissage. Cela correspond au RTL à 30 % de la mission type : le retour est déclenché juste avant d'entamer la réserve. Les deux hypothèses du cahier sont cohérentes et aucune MOD n'est nécessaire.

## 10. Ce qu'il faut mesurer, par ordre de priorité

1. **Le η de propulsion (phase 9, puis en vol en phase 10)** : c'est le paramètre le plus influent (±18 % d'autonomie pour ±20 % de η). Il faut mesurer Ct0 et Cp0 au banc pour recaler le modèle, puis la puissance en croisière à 55 km/h en 4S1P, avec la 8×6 puis la 7×6 (§4). C'est cette mesure qui décide de G et qui lève la réserve de MOD-01.
2. **Le CD0 (phase 4 avec xflr5, phase 10 en vol)** : de 0,025 à 0,035, l'autonomie varie de +15 % à −11 %. À 0,035, F ne tient plus 45 min.
3. **La FM au point fixe (phase 9)** : elle fixe le point de conception (P/W de +25 % à −5 % pour FM ±20 %), donc le T/W au lancer.
4. **La résistance interne de la P45B (phase 9)** : R_dc est pris à 15 mΩ, environ 2 fois la valeur AC de la fiche. Elle conditionne la tension sous charge, le bridage THR_MAX et les cas d'erreur.
5. **Les masses réelles (phases 5 à 8)** : à peser au fil des impressions et des achats (colonne « pesé » du budget). Les priorités sont la structure, qui n'a aucun gramme de marge, le groupe propulsif retenu au §5, les cellules et le câblage.

## 11. Écarts par rapport à la skill /aircraft-design

| Écart | Raison | Recalage |
| --- | --- | --- |
| Modèle propulsif hors skill : hélice Ct(J) et Cp(J) (k_JT = 1,10, k_JP = 1,6), moteur à courant continu (Kv, Rm, I0), ESC (R_esc et pertes fixes de 0,5 W), batterie (R_dc). Point de fonctionnement résolu par fzero | La skill ne traite pas la propulsion électrique en détail | Phase 9 (banc). Robustesse du classement testée à k_JT ±10 % |
| Autonomie par bilan d'énergie, et non par Breguet | Breguet suppose un η constant et une masse variable. En électrique, la masse est constante et le η varie avec V | — |
| Jour chaud modélisé en ISA + ΔT | Cas du terrain près de Toulouse (200 m, 35 °C) | — |
| Contrainte de lancer main par le T/W statique, avec la théorie de Froude et une FM | Absente de la skill (avions à piste) | Phase 9 (FM) |
| CD0 corrigé du Reynolds sur la méthode Cfe·Swet/S (C3 p.85) | Le Cfe de la skill vaut pour Re ≈ 10⁷ ; ici Re ≈ 2,7·10⁵ | Phase 4 (xflr5) |
| Critères pratiques : V_cr ≥ 2·V_vent ; vitesse de pas ≥ 1,5·V_cr | Absents de la skill | Phase 10 |
| V1-PERF-07 : Vz = (T·V − Pn)/(m·g) avec Pn calculé en palier | Approximation de pente faible (C1 p.79), alors que la pente est forte ici. En montée, la portance est inférieure au poids, donc la traînée induite et Pn sont légèrement surestimés : l'approximation va dans le sens de la sécurité | Phase 10 |
| Masses et caractéristiques des pièces relevées sur fiches et chez des revendeurs | Données d'entrée, citées dans `params_v1.m` | Pesée en phases 5 à 8 |

## 12. Verdict de la phase 3

**GO conditionnel vers la phase 4.**

- **Ce qui est acquis :**
  - le point de conception (31,4 N/m², 69 W requis) ;
  - le moteur (X2212 V3 980 KV) ;
  - V1-PERF-01, 02, 04, 05, 06, 07 et 08 conformes au modèle ;
  - V1-PERF-03 conforme sous réserve.
- **Conditions à lever :**
  1. **Choisir le groupe propulsif propulsif** (§5) **avant tout achat d'hélice ou de moyeu**. La configuration de référence n'existe qu'en version tractrice.
  2. **Valider ou refuser le plan d'allègement** (§6). Sans lui, la 4S1P dépasse 800 g (818 g avec des cellules de 70 g) ; la règle du §7 s'applique alors en phase 8.
  3. **Valider ou refuser MOD-01 et MOD-02** (§8). MOD-03 n'est pas nécessaire.
- **La phase 4 peut démarrer sans attendre ces décisions** (xflr5 : polaire, CD0, Cm0, marge statique). Elle ne dépend pas du groupe propulsif, à part la masse et la position du moteur, qui varient de quelques grammes selon l'option du §5. Le CD0 qu'elle fournira est la deuxième inconnue de V1-PERF-03.

## Sources consultées le 13/10/2026

- SunnySky X2212 V3 : [fiche](https://sunnyskyusa.com/products/sunnsky-x2212) ; [axe de rechange de 3,17 mm](https://sunnyskyusa.com/products/replacement-shaft-for-sunnysky-x2212-motors-3-175mm)
- Pales aero-naut CAM Carbon 8×6 : [Zeller](https://zeller-modellbau.com/antrieb/luftschrauben/cam-carbon-klappluftschr-blaetter-8x6/) (9 g) ; [Reisenauer](https://www.reisenauer.de/aid-578-Aeronaut-Cam-Carbon-8x6.html) (16 000 tr/min)
- Pales aero-naut CAM Carbon 7×6 : [hacker-motor-shop](https://www.hacker-motor-shop.com/aero-naut-camcarbon-7x6-klappluftschraube.htm?a=article&ProdNr=10618500&p=1960) ; [Reisenauer](https://www.reisenauer.de/aid-575-Aeronaut-Cam-Carbon-7x6.html)
- Cône RFM de 30 mm, alésage 3,17 mm : [f3x.de](https://www.f3x.de/30mm-3,17mm-rfm-cfk-spinner-weiss-versetzt-0-grad-verdreht-kuehlloch)
- Pales propulsives aero-naut : [Lindinger, 8×5 linkslaufend](https://www.lindinger.at/de/RC-Flugzeuge/RC-Flugzeug-Elektro-Antriebe/Luftschrauben/Klappluftschrauben/AERONAUT-KLAPPLUFTSCHRAUBE-8x5-linkslaufend-Klappluftschraube/76283) ; [Modellbau-Planet, gamme linkslaufend](https://modellbau-planet.de/flugmodelle-_-zubehoer/flugzubehoer/luftschrauben/aeronaut-luftschrauben/elektro-luftschrauben/klapp-luftschrauben/linkslauf/)
- Cône aero-naut CN 30/3,17 (725903) : [Natterer Modellbau](https://natterer-modellbau.de/CN-Spinner-30-317mm)
- Hélices APC : [8x6EP](https://www.apcprop.com/product/8x6ep/) ; [7x6EP](https://www.apcprop.com/product/7x6ep/)
- SpeedyBee F405 WING MINI : [HobbyRC UK](https://www.hobbyrc.co.uk/speedybee-f405-wing-mini-flight-controller) ; F405 WING APP (35 g avec la rallonge USB) : [manuel](https://www.manualslib.com/manual/3340724/Speedybee-F405-Wing-App.html)
- ESC Favourite LittleBee-S 30 A : [Hobbyking](https://hobbyking.com/en_us/favourite-littlebee-s-30a-2-6s-opto-esc.html)
- GPS Matek M10Q-5883 : [Matek](https://www.mateksys.com/?portfolio=m10q-5883)
