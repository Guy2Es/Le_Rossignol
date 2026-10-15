# Phase 4 — tableaux générés par stabilite.m

Ne pas éditer : réécrit à chaque exécution.

### Géométrie de départ

| Grandeur | Valeur |
| --- | --- |
| Flèche du BA / vrillage au saumon | 27° / -3° |
| S (intégrale) | 0,2500 m² |
| MAC (intégrale) / formule skill C2 p.64 / cahier | 0,2565 / 0,2565 / 0,257 m |
| Y_mac / X_mac (BA de la MAC) | 226,7 / 115,5 mm |
| Foyer de l'aile seule, estimation skill (X_mac + 0,25·MAC) | 179,6 mm |


### Profils : géométrie (cordes en % ; longeron au saumon, hypothèse x/c = 0,25, besoin 9,6 mm)

| Profil | t max [%] | à x/c [%] | Cambrure max [%] | à x/c [%] | Réflexe | Épaisseur au longeron [mm] | Marge [mm] |
| --- | --- | --- | --- | --- | --- | --- | --- |
| MH 45 9.85% | 9,86 | 27,0 | 1,75 | 33,8 | oui | 17,7 | +8,1 |
| MH 60 10.08% | 10,09 | 27,0 | 1,83 | 34,2 | oui | 18,1 | +8,5 |
| MH 61 10.26% | 10,26 | 29,8 | 1,47 | 37,9 | oui | 18,2 | +8,6 |
| S5010 | 9,83 | 27,3 | 2,34 | 28,0 | oui | 17,6 | +8,0 |


### Reynolds de vol (Vs avec CLmax = 0,8, hypothèse de la phase 3)

| Atmosphère | Corde | Re à Vs min | Re à 38 km/h | Re à 55 km/h | Re à 70 km/h |
| --- | --- | --- | --- | --- | --- |
| ISA, niveau de la mer | emplanture (320 mm) | 167262 | 231241 | 334691 | 425970 |
| ISA, niveau de la mer | saumon (180 mm) | 94085 | 130073 | 188263 | 239608 |
| ISA, niveau de la mer | tête de winglet (90 mm) | 47043 | 65036 | 94132 | 119804 |
| Jour chaud, 200 m, 35 °C | emplanture (320 mm) | 151780 | 200516 | 290220 | 369371 |
| Jour chaud, 200 m, 35 °C | saumon (180 mm) | 85376 | 112790 | 163249 | 207771 |
| Jour chaud, 200 m, 35 °C | tête de winglet (90 mm) | 42688 | 56395 | 81624 | 103886 |


### Lots XFoil

| Grandeur | Valeur |
| --- | --- |
| Re min de vol : aile (saumon) / winglet (tête) | 85376 / 42688 |
| Re max de vol : aile (emplanture) / winglet (pied) | 425970 / 239608 |
| Lot des profils d'aile | 70000 ; 90000 ; 110000 ; 130000 ; 150000 ; 170000 ; 190000 ; 210000 ; 230000 ; 250000 ; 270000 ; 290000 ; 310000 ; 330000 ; 350000 ; 370000 ; 390000 ; 410000 ; 430000 |
| Lot du winglet (NACA 0008) | 30000 ; 50000 ; 70000 ; 90000 ; 110000 ; 130000 ; 150000 ; 170000 ; 190000 ; 210000 ; 230000 ; 250000 |
| Énoncé | 80000 à 400000, Ncrit = 9 |


### Masses ponctuelles sans batterie (positions HYPOTHÉTIQUES, arrêt A)

| Poste | m [g] | x [mm] | y [mm] | z [mm] |
| --- | --- | --- | --- | --- |
| Panneaux d'aile LW-PLA (2 demi-ailes) | 190,0 | 223,2 | 0 | 0 |
| Longeron carbone 8 mm + clé arrière 3 mm | 30,0 | 179,6 | 0 | 0 |
| Winglets + élevons (droite) | 15,0 | 365,1 | 450 | 0 |
| Winglets + élevons (gauche) | 15,0 | 365,1 | -450 | 0 |
| Fuselage central PLA/PETG + trappe | 70,0 | 130,0 | 0 | 0 |
| Câblage, connecteurs, velcro, PCB d'interconnexion | 35,0 | 130,0 | 0 | 0 |
| Contrôleur de vol | 14,3 | 120,0 | 0 | 10 |
| Raspberry Pi Zero 2 W + Camera Module 3 + microSD | 20,0 | -30,0 | 0 | 0 |
| 2 servos 9 g (droite) | 9,0 | 282,7 | 300 | 0 |
| 2 servos 9 g (gauche) | 9,0 | 282,7 | -300 | 0 |
| ESC 30 A | 9,0 | 130,0 | 0 | 0 |
| GPS M10 + compas | 9,0 | 200,0 | 0 | 20 |
| Récepteur ELRS + antennes | 3,0 | 220,0 | 0 | 0 |
| Moteur X2212 V3 | 57,0 | 335,0 | 0 | 20 |
| Hélice + adaptateur | 19,9 | 365,0 | 0 | 20 |
| **Total / CG** | 505,2 | 215,0 |  |  |


### Indicateur de centrage AVANT xflr5 (foyer de l'aile seule à X_mac + 0,25·MAC, skill ; ni winglets ni nacelle)

| MS | CG [mm] | Batterie 3S1P [mm] | Batterie 4S1P [mm] | Écart 3S/4S [mm] |
| --- | --- | --- | --- | --- |
| 8 % | 159,1 | 32,6 | 62,5 | 29,9 |
| 10 % | 154,0 | 15,8 | 48,5 | 32,6 |


### Garde de l'hélice face au bord de fuite (flèche 27°, hypothèses de position ; élevons non braqués, moyeu non compté)

| Grandeur | Valeur |
| --- | --- |
| Bord de fuite à y = ±100 mm | 343,0 mm |
| Plan de l'hélice (CG hélice + adaptateur) : garde à cette station | 365,0 mm : 22,0 mm |
| Bord de fuite le plus en arrière sur le disque (R = 101,6 mm) : garde | 343,3 mm : 21,7 mm |
| Moteur (CG) : distance au bord de fuite de l'emplanture | 335,0 mm : 15,0 mm |


### Étape 2 : avions générés pour les T2 (xflr5/genere, méthode VLM2, masse 4S1P, batterie provisoire à MS 9 % sur le foyer skill)

| Avion | Profil (nom xflr5) | Vrillage au saumon [°] | Masse [g] | Batterie x [mm] | CG attendu x / z [mm] | Fichiers |
| --- | --- | --- | --- | --- | --- | --- |
| V1_MH45_vr3 | MH 45  9.85% | -3 | 797,2 | 55,5 | 156,5 / 2,3 | avion_V1_MH45_vr3.xml ; analyse_T2_V1_MH45_vr3.xml |
| V1_MH45_vr5 | MH 45  9.85% | -5 | 797,2 | 55,5 | 156,5 / 2,3 | avion_V1_MH45_vr5.xml ; analyse_T2_V1_MH45_vr5.xml |
| V1_MH45_vr7 | MH 45  9.85% | -7 | 797,2 | 55,5 | 156,5 / 2,3 | avion_V1_MH45_vr7.xml ; analyse_T2_V1_MH45_vr7.xml |
| V1_S5010_vr3 | S5010 | -3 | 797,2 | 55,5 | 156,5 / 2,3 | avion_V1_S5010_vr3.xml ; analyse_T2_V1_S5010_vr3.xml |
| V1_S5010_vr5 | S5010 | -5 | 797,2 | 55,5 | 156,5 / 2,3 | avion_V1_S5010_vr5.xml ; analyse_T2_V1_S5010_vr5.xml |
| V1_S5010_vr7 | S5010 | -7 | 797,2 | 55,5 | 156,5 / 2,3 | avion_V1_S5010_vr7.xml ; analyse_T2_V1_S5010_vr7.xml |


### Étape 2 : réglages des T2

| Grandeur | Valeur |
| --- | --- |
| ρ / ν (ISA, Sutherland) | 1,2250 kg/m³ / 1,4607e-05 m²/s |
| Plage d'alpha à saisir dans xflr5 | -2,0° à 12,0°, pas 0,5° |
| CL à couvrir (4S1P, ISA) | 0,135 (70 km/h) à 0,540 (35 km/h) |


### Polaires 2D : contrôle des exports

| Grandeur | Valeur |
| --- | --- |
| Fichiers lus / attendus | 76 / 76 |
| Ncrit / Mach / transition forcée | 9 / 0 / x/c = 1 (libre) : vérifiés dans chaque fichier |
| Points convergés par polaire (min / max / demandés) | 35 / 41 / 41 |
| Clmax au dernier alpha calculé (valeur = borne inférieure) | 1 polaires |
| Polaires à plusieurs passages de Cl par 0 | 0 |
| Plus grand écart d'alpha autour de Cl = 0 | 1,0° (pas demandé 0,5°) |


### V1-STAB-01 : Cm0 du profil (Cm au quart avant à Cl = 0, XFoil ; interpolé en log Re)

| Profil | Cm0 à Re 170000 | Cm0 à Re 260000 | Cm0 minimal sur le lot (70 000 à 430 000) | Contrôle : droite Cm(Cl) sur Cl 0,1–0,6 extrapolée à Cl = 0 (Re 170000 / Re 260000) | x_ac/c (Re 170000 / Re 260000) | Skill C2 p.69, sans réflexe | Volet fixe pour Cm0 = 0 (profil mince, charnière 75 %, HORS SKILL) | Cm au Cl de vol 4S1P (Re 170000 : Cl 0,545 / Re 260000 : Cl 0,233) | V1-STAB-01 du cahier (Cm0 du profil ≥ 0 aux Re de vol) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| MH 45 9.85% | -0,0165 | -0,0066 | -0,0373 (Re 90000) | -0,0251 / -0,0177 | 0,222 / 0,234 | -0,0359 | -1,5° | -0,0102 / -0,0138 | NON conforme (exigence de profil du cahier, remplacée par MOD-04 validée) |
| MH 60 10.08% | -0,0189 | -0,0085 | -0,0400 (Re 90000) | -0,0297 / -0,0206 | 0,220 / 0,235 | -0,0378 | -1,7° | -0,0137 / -0,0172 | NON conforme (exigence de profil du cahier, remplacée par MOD-04 validée) |
| MH 61 10.26% | -0,0150 | -0,0041 | -0,0393 (Re 90000) | -0,0271 / -0,0169 | 0,220 / 0,234 | -0,0327 | -1,3° | -0,0112 / -0,0131 | NON conforme (exigence de profil du cahier, remplacée par MOD-04 validée) |
| S5010 | -0,0096 | -0,0014 | -0,0474 (Re 70000) | -0,0179 / -0,0135 | 0,228 / 0,233 | -0,0426 | -0,8° | -0,0060 / -0,0095 | NON conforme (exigence de profil du cahier, remplacée par MOD-04 validée) |


### Performances du profil à Re 170000 (≈ 34,8 km/h sur la MAC, ISA ; Cl de vol 4S1P = 0,545)

| Profil | Clmax | (Cl/Cd)max | (Cl^1,5/Cd)max | Cd min [1e-4] | Largeur du creux ΔCl (Cd ≤ 1,10·Cd min) | Cd [1e-4] / Cm au Cl de vol |
| --- | --- | --- | --- | --- | --- | --- |
| MH 45 9.85% | 1,194 | 56,8 (Cl 0,78) | 52,1 (Cl 0,87) | 102,0 | 0,712 | 111,9 / -0,0102 |
| MH 60 10.08% | 1,159 | 57,4 (Cl 0,84) | 53,8 (Cl 0,93) | 104,5 | 0,754 | 111,2 / -0,0137 |
| MH 61 10.26% | 1,026 | 59,9 (Cl 0,81) | 53,8 (Cl 0,81) | 110,9 | 0,965 | 115,5 / -0,0112 |
| S5010 | 1,217 | 58,9 (Cl 0,89) | 56,8 (Cl 0,99) | 105,1 | 0,539 | 119,3 / -0,0060 |


### Performances du profil à Re 260000 (≈ 53,3 km/h sur la MAC, ISA ; Cl de vol 4S1P = 0,233)

| Profil | Clmax | (Cl/Cd)max | (Cl^1,5/Cd)max | Cd min [1e-4] | Largeur du creux ΔCl (Cd ≤ 1,10·Cd min) | Cd [1e-4] / Cm au Cl de vol |
| --- | --- | --- | --- | --- | --- | --- |
| MH 45 9.85% | 1,208 | 66,5 (Cl 0,78) | 60,7 (Cl 0,88) | 81,0 | 0,599 | 81,6 / -0,0138 |
| MH 60 10.08% | 1,177 | 67,5 (Cl 0,79) | 63,1 (Cl 0,94) | 82,3 | 0,637 | 82,4 / -0,0172 |
| MH 61 10.26% | 1,027 | 69,7 (Cl 0,76) | 61,4 (Cl 0,81) | 85,8 | 0,799 | 86,5 / -0,0131 |
| S5010 | 1,253 | 69,7 (Cl 0,87) | 67,0 (Cl 0,99) | 84,6 | 0,540 | 86,5 / -0,0095 |


### Étape 2 : T2 non visqueux (VLM2, winglets inclinés du vrillage du saumon) : contrôles et point neutre (estimation skill : 179,6 mm)

| Avion | x_NP pente de Cm [mm] | x_NP pente de XCP·CL [mm] | MS au CG de l'analyse (156,5 mm) | Cm(CL = 0) de l'aile | Écart max à la droite Cm(CL) | CL couvert | |Cl| max des winglets | CL intégré de l'aile − CL polaire (max) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| V1_MH45_vr3 | 177,4 | 179,8 | 8,1 % | +0,0037 | 1,1e-04 | 0,023 à 0,732 | 0,43 | 0,011 |
| V1_MH45_vr5 | 176,7 | 179,0 | 7,8 % | +0,0075 | 8,6e-05 | 0,005 à 0,676 | 0,40 | 0,010 |
| V1_MH45_vr7 | 176,3 | 178,6 | 7,7 % | +0,0115 | 6,1e-05 | 0,019 à 0,623 | 0,41 | 0,009 |
| V1_S5010_vr3 | 177,5 | 179,7 | 8,2 % | +0,0063 | 4,5e-05 | 0,029 à 0,737 | 0,43 | 0,012 |
| V1_S5010_vr5 | 176,8 | 178,9 | 7,9 % | +0,0102 | 2,4e-05 | 0,011 à 0,682 | 0,41 | 0,011 |
| V1_S5010_vr7 | 176,4 | 178,5 | 7,7 % | +0,0141 | 1,4e-05 | 0,024 à 0,628 | 0,41 | 0,010 |


### Étape 2 : équilibre sans braquage d'élevons (Cm0 − MS·CL = 0, ISA) et ΔCm cabreur à fournir par les élevons à 45 km/h

| Avion | CL_eq : V_eq 3S1P / 4S1P, MS 8 % | CL_eq : V_eq 3S1P / 4S1P, MS 10 % | ΔCm à 45 km/h 3S1P / 4S1P, MS 8 % | ΔCm à 45 km/h 3S1P / 4S1P, MS 10 % |
| --- | --- | --- | --- | --- |
| V1_MH45_vr3 | 0,046 : 115,0 / 120,3 km/h | 0,037 : 128,6 / 134,5 km/h | +0,0202 / +0,0225 | +0,0262 / +0,0290 |
| V1_MH45_vr5 | 0,094 : 80,1 / 83,8 km/h | 0,075 : 89,6 / 93,7 km/h | +0,0163 / +0,0186 | +0,0223 / +0,0251 |
| V1_MH45_vr7 | 0,144 : 64,8 / 67,8 km/h | 0,115 : 72,4 / 75,8 km/h | +0,0124 / +0,0146 | +0,0183 / +0,0211 |
| V1_S5010_vr3 | 0,079 : 87,5 / 91,6 km/h | 0,063 : 97,9 / 102,4 km/h | +0,0176 / +0,0198 | +0,0235 / +0,0264 |
| V1_S5010_vr5 | 0,127 : 69,0 / 72,2 km/h | 0,102 : 77,1 / 80,7 km/h | +0,0137 / +0,0160 | +0,0197 / +0,0225 |
| V1_S5010_vr7 | 0,177 : 58,5 / 61,2 km/h | 0,141 : 65,4 / 68,4 km/h | +0,0097 / +0,0120 | +0,0157 / +0,0185 |


### Étape 2 : centrage avec le foyer xflr5 (pente de Cm) ; V1-STAB-03 : écart 3S/4S ≤ 30 mm (cahier), ≤ 40 mm (MOD-05, brouillon) ; Pi + caméra à -30 mm

| Avion | MS | CG [mm] | Batterie 3S1P [mm] (avant, 70 mm de long) | Batterie 4S1P [mm] | Écart 3S/4S [mm] | V1-STAB-03 (cahier) | MOD-05 (brouillon) | Marge MOD-05 [mm] |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| V1_MH45_vr3 | 8 % | 156,8 | 25,2 (avant : -9,8) | 56,3 | 31,1 (XCP : 29,8) | **NON TENU** | tenu | 8,9 |
| V1_MH45_vr3 | 10 % | 151,7 | 8,4 (avant : -26,6) | 42,3 | 33,9 (XCP : 32,6) | **NON TENU** | tenu | 6,1 |
| V1_MH45_vr5 | 8 % | 156,1 | 22,9 (avant : -12,1) | 54,4 | 31,5 (XCP : 30,2) | **NON TENU** | tenu | 8,5 |
| V1_MH45_vr5 | 10 % | 151,0 | 6,2 (avant : -28,8) | 40,4 | 34,2 (XCP : 33,0) | **NON TENU** | tenu | 5,8 |
| V1_MH45_vr7 | 8 % | 155,8 | 21,7 (avant : -13,3) | 53,4 | 31,7 (XCP : 30,4) | **NON TENU** | tenu | 8,3 |
| V1_MH45_vr7 | 10 % | 150,6 | 4,9 (avant : -30,1) | 39,4 | 34,4 (XCP : 33,2) | **NON TENU** | tenu | 5,6 |
| V1_S5010_vr3 | 8 % | 156,9 | 25,5 (avant : -9,5) | 56,6 | 31,1 (XCP : 29,8) | **NON TENU** | tenu | 8,9 |
| V1_S5010_vr3 | 10 % | 151,8 | 8,8 (avant : -26,2) | 42,6 | 33,8 (XCP : 32,6) | **NON TENU** | tenu | 6,2 |
| V1_S5010_vr5 | 8 % | 156,2 | 23,2 (avant : -11,8) | 54,6 | 31,4 (XCP : 30,3) | **NON TENU** | tenu | 8,6 |
| V1_S5010_vr5 | 10 % | 151,1 | 6,4 (avant : -28,6) | 40,6 | 34,2 (XCP : 33,0) | **NON TENU** | tenu | 5,8 |
| V1_S5010_vr7 | 8 % | 155,8 | 21,9 (avant : -13,1) | 53,6 | 31,6 (XCP : 30,5) | **NON TENU** | tenu | 8,4 |
| V1_S5010_vr7 | 10 % | 150,7 | 5,2 (avant : -29,8) | 39,5 | 34,4 (XCP : 33,3) | **NON TENU** | tenu | 5,6 |


### Étape 2 : traînée induite et Cl local (reconstruit entre α = 4° et 12° ; indicateur, pas une prédiction de décrochage)

| Avion | CDi [1e-4] à 35 / 45 / 55 km/h (4S1P) | e = CL²/(π·λ·CDi), λ = 4 | Cl au saumon : 35 / 45 / 55 / 70 km/h 4S1P, 70 km/h 3S1P | max Cl/CL à 35 km/h (4S1P) | max Cl/CL à 70 km/h (3S1P) |
| --- | --- | --- | --- | --- | --- |
| V1_MH45_vr3 | 217,4 / 81,2 / 38,0 | 1,07 / 1,05 / 1,00 | +0,184 / +0,108 / +0,070 / +0,040 / +0,036 | 1,06 à |y| = 223 mm | 1,19 à |y| = 78 mm |
| V1_MH45_vr5 | 226,0 / 87,7 / 43,8 | 1,03 / 0,97 / 0,87 | +0,159 / +0,089 / +0,054 / +0,027 / +0,023 | 1,08 à |y| = 172 mm | 1,34 à |y| = 50 mm |
| V1_MH45_vr7 | 235,7 / 96,5 / 52,4 | 0,99 / 0,88 / 0,73 | +0,141 / +0,074 / +0,040 / +0,014 / +0,011 | 1,10 à |y| = 141 mm | 1,51 à |y| = 27 mm |
| V1_S5010_vr3 | 217,6 / 81,3 / 38,1 | 1,07 / 1,04 / 1,00 | +0,184 / +0,109 / +0,070 / +0,041 / +0,036 | 1,06 à |y| = 223 mm | 1,19 à |y| = 78 mm |
| V1_S5010_vr5 | 226,2 / 87,8 / 44,0 | 1,03 / 0,97 / 0,87 | +0,159 / +0,089 / +0,054 / +0,027 / +0,023 | 1,07 à |y| = 172 mm | 1,35 à |y| = 50 mm |
| V1_S5010_vr7 | 236,0 / 96,7 / 52,6 | 0,98 / 0,88 / 0,72 | +0,141 / +0,074 / +0,040 / +0,014 / +0,011 | 1,10 à |y| = 141 mm | 1,51 à |y| = 27 mm |


### Étape 2 : selon le vrillage (droite de Cm0 sur 3 points ; parabole de CDi par 3 points ; hors de -3° à -7° = extrapolation)

| Profil | Cm0(vrillage) | Vrillage pour δ = 0 à 45 km/h, MS 8 % (3S1P / 4S1P) | Idem, MS 10 % | Sommet de la parabole CDi(vrillage) à 45 km/h |
| --- | --- | --- | --- | --- |
| mh45 | -0,00227 -0,00197·vr (écart 4,0e-05) | -13,3° / -14,4° | -16,3° / -17,8° | 1,4° |
| s5010 | +0,00041 -0,00196·vr (écart 4,4e-05) | -12,0° / -13,1° | -15,0° / -16,5° | 1,5° |


### Section C2 : xflr5 visqueux − non visqueux (V1_S5010_vr5, mêmes alpha) contre la correction en bandes ; rapport médian 0,01 → bandes

| alpha [°] | V [km/h] | CL | ΔCm xflr5 | ΔCm en bandes | ΔCL xflr5 |
| --- | --- | --- | --- | --- | --- |
| 3,5 | 68,6 | 0,140 | +0,0000 | -0,0176 | +0,0000 |
| 4,0 | 61,9 | 0,173 | -0,0000 | -0,0180 | +0,0000 |
| 4,5 | 56,8 | 0,205 | -0,0000 | -0,0178 | +0,0000 |
| 5,0 | 52,8 | 0,238 | -0,0000 | -0,0175 | +0,0000 |
| 5,5 | 49,5 | 0,270 | -0,0000 | -0,0172 | +0,0000 |
| 6,0 | 46,8 | 0,302 | -0,0001 | -0,0169 | +0,0000 |
| 6,5 | 44,5 | 0,334 | -0,0001 | -0,0166 | +0,0000 |
| 7,0 | 42,5 | 0,366 | -0,0001 | -0,0163 | +0,0000 |
| 7,5 | 40,8 | 0,398 | -0,0001 | -0,0160 | +0,0000 |
| 8,0 | 39,2 | 0,430 | -0,0002 | -0,0156 | +0,0000 |
| 8,5 | 37,8 | 0,462 | -0,0002 | -0,0153 | +0,0000 |
| 9,0 | 36,6 | 0,494 | -0,0002 | -0,0149 | +0,0000 |
| 9,5 | 35,5 | 0,525 | -0,0002 | -0,0145 | +0,0000 |
| 10,0 | 34,5 | 0,557 | -0,0003 | -0,0141 | +0,0000 |
| 10,5 | 33,5 | 0,588 | -0,0003 | -0,0137 | +0,0000 |
| 11,0 | 32,7 | 0,620 | -0,0003 | -0,0133 | +0,0000 |
| 11,5 | 31,9 | 0,651 | -0,0003 | -0,0129 | +0,0000 |
| 12,0 | 31,2 | 0,682 | -0,0004 | -0,0125 | +0,0000 |


### Section C : contrôle visqueux du Cm (en bandes, C2 : bandes) (s5010, XFoil Ncrit 9 contre ligne moyenne en profils minces : Cm +0,0081 ; HORS SKILL, redistribution de portance négligée)

| Avion | Cm(CL = 0) non visqueux → visqueux (MOD-04), Re à 70 km/h | ΔCm visqueux 3S1P à 35 / 40 / 45 / 55 / 70 km/h | Idem 4S1P | ΔCm à fournir par les élevons à 45 km/h, 4S1P : MS 8 % ; MS 10 % (non visqueux → visqueux) | Idem visqueux à 35 km/h, 4S1P : MS 8 % / MS 10 % | Pente de ΔCm(CL) (35 à 55 km/h) : x_NP [mm] non visqueux → visqueux | Écart 3S/4S avec x_NP visqueux, MS 8 % / 10 % [mm] (marge MOD-05) |
| --- | --- | --- | --- | --- | --- | --- | --- |
| V1_S5010_vr3 | +0,0063 → -0,0004 (**non tenue**) | -0,0152 / -0,0165 / -0,0172 / -0,0181 / -0,0169 | -0,0143 / -0,0158 / -0,0167 / -0,0177 / -0,0177 | +0,0198 → +0,0365 ; +0,0264 → +0,0430 | +0,0512 / +0,0620 | +0,0104 : 177,5 → 174,8 | 32,5 / 35,2 (marge 4,8) |
| V1_S5010_vr5 | +0,0102 → +0,0032 (tenue) | -0,0152 / -0,0165 / -0,0172 / -0,0181 / -0,0169 | -0,0143 / -0,0158 / -0,0167 / -0,0177 / -0,0173 | +0,0160 → +0,0327 ; +0,0225 → +0,0392 | +0,0474 / +0,0582 | +0,0103 : 176,8 → 174,1 | 32,8 / 35,6 (marge 4,4) |
| V1_S5010_vr7 | +0,0141 → +0,0066 (tenue) | -0,0152 / -0,0165 / -0,0172 / -0,0180 / -0,0164 | -0,0143 / -0,0159 / -0,0167 / -0,0177 / -0,0167 | +0,0120 → +0,0287 ; +0,0185 → +0,0352 | +0,0434 / +0,0542 | +0,0101 : 176,4 → 173,8 | 33,0 / 35,8 (marge 4,2) |


### §9 : T2 à élevons braqués à générer (s5010, δ convention xflr5 : < 0 = vers le haut ; élevons de y = 250 à 500 mm, charnière à 75 % ; conditionnement du plan 28,6)

| Avion | Vrillage [°] | δ [°] | Profil des élevons (nom xflr5) | Fichiers | Statut |
| --- | --- | --- | --- | --- | --- |
| V1_S5010_vr3_e6 | -3 | -6 | S5010 elv-6 | avion_V1_S5010_vr3_e6.xml ; analyse_T2inv_V1_S5010_vr3_e6.xml | obligatoire |
| V1_S5010_vr7_e6 | -7 | -6 | S5010 elv-6 | avion_V1_S5010_vr7_e6.xml ; analyse_T2inv_V1_S5010_vr7_e6.xml | obligatoire |
| V1_S5010_vr5_e3 | -5 | -3 | S5010 elv-3 | avion_V1_S5010_vr5_e3.xml ; analyse_T2inv_V1_S5010_vr5_e3.xml | obligatoire |
| V1_S5010_vr5_e0 | -5 | +0 | S5010 | avion_V1_S5010_vr5_e0.xml ; analyse_T2inv_V1_S5010_vr5_e0.xml | contrôle du maillage (décidé) |


### §10 : efficacité visqueuse des élevons (S5010 à volet, charnière 75 %, XFoil Ncrit 9, contre profils minces HORS SKILL ; Re des élevons de 35 à 55 km/h : 119804 à 261477)

| Re | δ (xflr5, < 0 = haut) | ΔCm,c/4 à Cl 0,2 / 0,4 / 0,6 | Δα [°] à Cl égal | ΔCd [1e-4] à Cl égal |
| --- | --- | --- | --- | --- |
| 130000 | -3° | +0,0235 / +0,0242 / +0,0253 (mince +0,0340) : η 0,69 / 0,71 / 0,74 | +1,34 / +1,39 / +1,47 (mince +1,83) : η 0,73 / 0,76 / 0,80 | 15,1 / 8,3 / 5,1 |
| 130000 | -6° | +0,0456 / +0,0453 / +0,0453 (mince +0,0680) : η 0,67 / 0,67 / 0,67 | +2,56 / +2,58 / +2,64 (mince +3,65) : η 0,70 / 0,70 / 0,72 | 32,7 / 20,9 / 14,4 |
| 130000 | -9° | +0,0664 / +0,0657 / +0,0637 (mince +0,1020) : η 0,65 / 0,64 / 0,62 | +3,70 / +3,70 / +3,70 (mince +5,48) : η 0,68 / 0,68 / 0,68 | 53,5 / 38,7 / 32,2 |
| 190000 | -3° | +0,0240 / +0,0244 / +0,0250 (mince +0,0340) : η 0,71 / 0,72 / 0,74 | +1,35 / +1,39 / +1,46 (mince +1,83) : η 0,74 / 0,76 / 0,80 | 10,5 / 5,9 / 4,8 |
| 190000 | -6° | +0,0463 / +0,0457 / +0,0446 (mince +0,0680) : η 0,68 / 0,67 / 0,66 | +2,57 / +2,59 / +2,62 (mince +3,65) : η 0,70 / 0,71 / 0,72 | 25,7 / 18,6 / 15,4 |
| 190000 | -9° | +0,0676 / +0,0661 / +0,0632 (mince +0,1020) : η 0,66 / 0,65 / 0,62 | +3,73 / +3,72 / +3,69 (mince +5,48) : η 0,68 / 0,68 / 0,67 | 45,5 / 36,7 / 33,8 |
| 250000 | -3° | +0,0240 / +0,0242 / +0,0248 (mince +0,0340) : η 0,71 / 0,71 / 0,73 | +1,34 / +1,39 / +1,46 (mince +1,83) : η 0,73 / 0,76 / 0,80 | 9,5 / 5,6 / 4,8 |
| 250000 | -6° | +0,0462 / +0,0454 / +0,0443 (mince +0,0680) : η 0,68 / 0,67 / 0,65 | +2,55 / +2,57 / +2,60 (mince +3,65) : η 0,70 / 0,70 / 0,71 | 24,4 / 18,7 / 16,2 |
| 250000 | -9° | +0,0676 / +0,0717 / +0,0773 (mince +0,1020) : η 0,66 / 0,70 / 0,76 | +3,72 / +3,97 / +4,36 (mince +5,48) : η 0,68 / 0,72 / 0,80 | 44,2 / 40,6 / 43,0 |


### §11 : T2 à élevons, contrôles (exports reconnus par leur en-tête ; plage de CL d'équilibre 0,200 à 0,540, 35 à 55 km/h, 3S1P et 4S1P, ISA)

| Contrôle | Valeur |
| --- | --- |
| Polaires / points de fonctionnement lus | 7 / 8 (α = 6 et 14°) |
| Ajustement par avion sur la plage de CL : résidu max Cm (droite) / CDi (parabole) | 5,3e-05 / 1,6e-06 |
| Pente dCm/dCL des 7 avions (point neutre VLM correspondant) | -0,0828 à -0,0773 (1,41 mm) |
| Maillage à élevons (V1_S5010_vr5_e0 − V1_S5010_vr5) : ΔCm aux deux bouts de la plage | +1,9e-05 / +3,9e-05 (δ équivalent -0,003 / -0,007°) |
| Maillage à élevons : Δx_NP / ΔCDi | -0,014 mm / +6,8e-07 / +5,8e-06 |
| Bandes de l'aile ; cordes exportées contre loi en plan | 50 ; écart 6,0e-05 m |
| Cl local = A·[1 CL vr δ] (8 points) : résidu max, bande de transition (4 mm) / ailleurs | 0,0181 / 0,0081 |
| Recomposition du Cm par les bandes (CmAirf, Cl) / CL des bandes contre CL | 7,1e-04 / 2,2 % |
| Moment de section de la VLM, dérivée en δ (par degré) : VLM / profils minces sur les élevons | -0,00357 / -0,00412 |
| Moment de section de la VLM à δ = 0 (vrillage -5°, CL 0,327) / ligne moyenne 2D | +0,0028 / +0,0081 (effet 3D de la flèche ; la correction en bandes n'ajoute que l'écart visqueux 2D) |
| Recoupement §8 à δ = 0 : ΔCm visqueux / x_NP visqueux / Cm(CL = 0) visqueux | 2,6e-04 / 0,12 mm / 4,2e-04 |


### §11 : efficacité des élevons à l'équilibre, 4S1P, MS 8 %, 45 km/h (Cm_δ à CL fixé, par degré ; HORS SKILL)

| Vrillage | VLM : δ_trim : Cm_δ | Bandes (méthode E4) : δ_trim : Cm_δ | Complet (verdict) : δ_trim : Cm_δ | η_α (portance du volet, XFoil / profils minces) | η_m (moment de section) | Cm_δ complet / VLM |
| --- | --- | --- | --- | --- | --- | --- |
| -3° | -3,38° : -0,00610 | -8,26° : -0,00527 | -10,31° : -0,00397 | 0,67 | 0,66 | 0,65 |
| -4° | -3,08° : -0,00604 | -7,92° : -0,00520 | -9,85° : -0,00393 | 0,68 | 0,66 | 0,65 |
| -5° | -2,76° : -0,00598 | -7,57° : -0,00513 | -9,37° : -0,00389 | 0,68 | 0,66 | 0,65 |
| -6° | -2,44° : -0,00591 | -7,20° : -0,00506 | -8,88° : -0,00385 | 0,68 | 0,66 | 0,65 |
| -7° | -2,11° : -0,00584 | -6,82° : -0,00498 | -8,38° : -0,00380 | 0,68 | 0,66 | 0,65 |


### §11 : braquage d'équilibre δ_trim [°] de 35 à 55 km/h (ISA ; < 0 = vers le haut) ; critère : de -6 à +0° sur toute la plage (seuils provisoires du 13/10/2026) ; verdict sur le modèle « complet »

| Vrillage | Configuration | δ_trim à 35 / 40 / 45 / 55 km/h | Plage de 35 à 55 km/h | Critère | Bandes (méthode E4) | VLM seule | Débattement à cabrer requis (δ_trim à 35 km/h + 10°, P5-04) | Braquage hors des polaires à volet (−9 à 0°) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| -3° | 3S1P, MS 8 % | -14,1 / -11,5 / -9,8 / -7,6 | -14,1 à -7,6 (amplitude 6,5°) | **non tenu** | -11,0 à -6,2 (non tenu) | -5,5 à -1,7 | 24,1° | oui |
| -3° | 4S1P, MS 8 % | -15,0 / -12,2 / -10,3 / -8,0 | -15,0 à -8,0 (amplitude 7,1°) | **non tenu** | -11,6 à -6,5 (non tenu) | -6,1 à -1,9 | 25,0° | oui |
| -3° | 3S1P, MS 10 % | -16,5 / -13,4 / -11,2 / -8,6 | -16,5 à -8,6 (amplitude 7,9°) | **non tenu** | -12,7 à -7,0 (non tenu) | -7,1 à -2,4 | 26,5° | oui |
| -3° | 4S1P, MS 10 % | -17,6 / -14,2 / -11,9 / -9,1 | -17,6 à -9,1 (amplitude 8,6°) | **non tenu** | -13,5 à -7,3 (non tenu) | -7,8 à -2,7 | 27,6° | oui |
| -4° | 3S1P, MS 8 % | -13,6 / -11,1 / -9,3 / -7,1 | -13,6 à -7,1 (amplitude 6,5°) | **non tenu** | -10,7 à -5,8 (non tenu) | -5,3 à -1,4 | 23,6° | oui |
| -4° | 4S1P, MS 8 % | -14,6 / -11,8 / -9,8 / -7,5 | -14,6 à -7,5 (amplitude 7,1°) | **non tenu** | -11,3 à -6,1 (non tenu) | -5,9 à -1,6 | 24,6° | oui |
| -4° | 3S1P, MS 10 % | -16,1 / -12,9 / -10,8 / -8,2 | -16,1 à -8,2 (amplitude 7,9°) | **non tenu** | -12,4 à -6,6 (non tenu) | -6,8 à -2,0 | 26,1° | oui |
| -4° | 4S1P, MS 10 % | -17,2 / -13,8 / -11,5 / -8,6 | -17,2 à -8,6 (amplitude 8,6°) | **non tenu** | -13,2 à -7,0 (non tenu) | -7,5 à -2,4 | 27,2° | oui |
| -5° | 3S1P, MS 8 % | -13,2 / -10,6 / -8,8 / -6,7 | -13,2 à -6,7 (amplitude 6,5°) | **non tenu** | -10,3 à -5,5 (non tenu) | -5,0 à -1,0 | 23,2° | oui |
| -5° | 4S1P, MS 8 % | -14,1 / -11,3 / -9,4 / -7,0 | -14,1 à -7,0 (amplitude 7,1°) | **non tenu** | -11,0 à -5,8 (non tenu) | -5,6 à -1,3 | 24,1° | oui |
| -5° | 3S1P, MS 10 % | -15,6 / -12,5 / -10,3 / -7,7 | -15,6 à -7,7 (amplitude 7,9°) | **non tenu** | -12,1 à -6,2 (non tenu) | -6,5 à -1,7 | 25,6° | oui |
| -5° | 4S1P, MS 10 % | -16,8 / -13,4 / -11,0 / -8,2 | -16,8 à -8,2 (amplitude 8,6°) | **non tenu** | -12,9 à -6,6 (non tenu) | -7,2 à -2,0 | 26,8° | oui |
| -6° | 3S1P, MS 8 % | -12,7 / -10,1 / -8,3 / -6,2 | -12,7 à -6,2 (amplitude 6,5°) | **non tenu** | -10,0 à -5,1 (non tenu) | -4,7 à -0,7 | 22,7° | oui |
| -6° | 4S1P, MS 8 % | -13,7 / -10,8 / -8,9 / -6,5 | -13,7 à -6,5 (amplitude 7,1°) | **non tenu** | -10,7 à -5,4 (non tenu) | -5,3 à -0,9 | 23,7° | oui |
| -6° | 3S1P, MS 10 % | -15,2 / -12,0 / -9,9 / -7,2 | -15,2 à -7,2 (amplitude 7,9°) | **non tenu** | -11,8 à -5,9 (non tenu) | -6,2 à -1,4 | 25,2° | oui |
| -6° | 4S1P, MS 10 % | -16,4 / -12,9 / -10,6 / -7,7 | -16,4 à -7,7 (amplitude 8,7°) | **non tenu** | -12,6 à -6,2 (non tenu) | -7,0 à -1,7 | 26,4° | oui |
| -7° | 3S1P, MS 8 % | -12,2 / -9,6 / -7,8 / -5,7 | -12,2 à -5,7 (amplitude 6,6°) | **non tenu** | -9,7 à -4,7 (non tenu) | -4,4 à -0,3 | 22,2° | oui |
| -7° | 4S1P, MS 8 % | -13,2 / -10,3 / -8,4 / -6,0 | -13,2 à -6,0 (amplitude 7,2°) | **non tenu** | -10,3 à -5,0 (non tenu) | -5,0 à -0,6 | 23,2° | oui |
| -7° | 3S1P, MS 10 % | -14,7 / -11,5 / -9,4 / -6,7 | -14,7 à -6,7 (amplitude 8,0°) | **non tenu** | -11,5 à -5,5 (non tenu) | -5,9 à -1,0 | 24,7° | oui |
| -7° | 4S1P, MS 10 % | -15,9 / -12,4 / -10,1 / -7,2 | -15,9 à -7,2 (amplitude 8,7°) | **non tenu** | -12,3 à -5,8 (non tenu) | -6,7 à -1,4 | 25,9° | oui |


### §11 : choix du vrillage (règle de l'arrêt B : critère tenu dans les 4 configurations et MOD-04 tenue en visqueux, puis traînée équilibrée moyenne minimale ; grille de 0,25°)

| Vrillage | Cm(CL = 0) visqueux (MOD-04) | Critère tenu : complet / bandes / MS 8 % seule | Fenêtre requise (4 configurations) | Réflexe fixe : couple ΔCm constant qui met tous les cas dans la fenêtre (≥ : cas le plus cabré à -6° ; ≤ : cas le moins cabré à +0°) | x_NP visqueux [mm] | Traînée équilibrée moyenne [N] | Traînée [N] : 3S1P, MS 8 %  / 4S1P, MS 8 %  / 3S1P, MS 10 %  / 4S1P, MS 10 %  à 40 km/h, puis à 55 km/h |
| --- | --- | --- | --- | --- | --- | --- | --- |
| -3° | -0,0006 (**non tenue**) | non / non / non | -17,6 à -7,6° | ≥ +0,0445 et ≤ +0,0297 : **impossible** | 174,9 (VLM 177,5) | 0,538 | 0,492 / 0,539 / 0,515 / 0,565 / 0,524 / 0,551 / 0,545 / 0,575 |
| -4° | +0,0012 (tenue) | non / non / non | -17,2 à -7,1° | ≥ +0,0426 et ≤ +0,0278 : **impossible** | 174,5 (VLM 177,1) | 0,546 | 0,498 / 0,546 / 0,522 / 0,572 / 0,532 / 0,559 / 0,553 / 0,583 |
| -5° | +0,0029 (tenue) | non / non / non | -16,8 à -6,7° | ≥ +0,0408 et ≤ +0,0258 : **impossible** | 174,2 (VLM 176,8) | 0,554 | 0,505 / 0,553 / 0,530 / 0,580 / 0,540 / 0,569 / 0,563 / 0,593 |
| -6° | +0,0046 (tenue) | non / non / non | -16,4 à -6,2° | ≥ +0,0389 et ≤ +0,0238 : **impossible** | 174,0 (VLM 176,5) | 0,564 | 0,513 / 0,561 / 0,538 / 0,589 / 0,550 / 0,579 / 0,573 / 0,604 |
| -7° | +0,0062 (tenue) | non / non / non | -15,9 à -5,7° | ≥ +0,0370 et ≤ +0,0218 : **impossible** | 173,9 (VLM 176,4) | 0,574 | 0,521 / 0,569 / 0,547 / 0,598 / 0,563 / 0,591 / 0,585 / 0,617 |


### §11 : minimum de traînée équilibrée par cas (grille de 0,25°, de -3 à -7°)

| Cas | Vrillage du minimum |
| --- | --- |
| 3S1P, MS 8 %, 40 km/h | -3,00° |
| 4S1P, MS 8 %, 40 km/h | -3,00° |
| 3S1P, MS 10 %, 40 km/h | -3,00° |
| 4S1P, MS 10 %, 40 km/h | -3,00° |
| 3S1P, MS 8 %, 55 km/h | -3,00° |
| 4S1P, MS 8 %, 55 km/h | -3,00° |
| 3S1P, MS 10 %, 55 km/h | -3,00° |
| 4S1P, MS 10 %, 55 km/h | -3,00° |
| Moyenne des 8 cas, sans contrainte | -3,00° |
| **Règle de l'arrêt B** | **ARRÊT : aucun vrillage ne tient le critère dans les 4 configurations** |

