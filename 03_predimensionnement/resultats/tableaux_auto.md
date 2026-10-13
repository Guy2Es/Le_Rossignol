# Tableaux générés par dimensionnement.m (2026-10-13 10:49)

Ne pas éditer à la main : ce fichier est réécrit à chaque exécution.

### Vérification des exigences — configuration retenue F (η calculé, masse avec groupe propulsif réel, ISA, CD0 0,030 sauf mention)

| Exigence | Valeur calculée | Exigence (cahier) | Statut | Marge |
| --- | --- | --- | --- | --- |
| V1-MAS-01 | 4S1P : 814 g (cellules 69 g), 818 g (70 g) ; avec le plan d'allègement : 795,3 g, 799,3 g | ≤ 800 g | à risque | -18 g sans plan ; +0,7 g avec plan (cellules 70 g) |
| V1-MAS-02 | Sans batterie : 526 g ; avec le plan : 507,3 g | ≤ 520 g | à risque | -6 g sans plan ; +12,7 g avec plan |
| V1-MAS-03 | Structure du budget 320 g ; maximum admissible avec le plan 320,7 g (4S, cellules 70 g) ; cible 320 g | ≤ 320 g (souhaitable) | oui (budget) | +0 g sous la cible |
| V1-PERF-01 | Vs à 800 g = 28,8 km/h (ISA) ; 30,1 km/h TAS jour chaud (indépendant du moteur) | ≤ 32 km/h (cible 29) | oui | 1,9 km/h (pire cas) |
| V1-PERF-02 | F : palier tenu de 45 à 60 km/h ; rapport cyclique à 45 / 60 km/h : 0,59 / 0,78 en 3S, 0,45 / 0,58 en 4S (THR_MAX 1,00 / 0,84) | 45 à 60 km/h | oui | d(60 km/h, 4S) = 0,69 × THR_MAX |
| V1-PERF-03 | F, 4S1P à 55 km/h, η calculé 0,538 : 46 à 53 min (−30 / −20 %) ; CD0 0,035, −30 % : 43 min (G : 48 min) | ≥ 45 min | sous réserve (MOD-01) | +1,1 min (CD0 0,030, −30 %) ; -2,5 min (CD0 0,035) |
| V1-PERF-04 | F, 4S1P à 40 km/h, η calculé 0,537 : 79 à 91 min ; CD0 0,035, −30 % : 75 min | ≥ 70 min (souhaitable) | oui | +5 min (CD0 0,035, −30 %) |
| V1-PERF-05 | F, 3S1P à 55 km/h, η calculé 0,531 : 35 à 40 min ; CD0 0,035, −30 % : 32 min | ≥ 30 min | oui | +2 min (CD0 0,035, −30 %) |
| V1-PERF-06 | V_cr/V_vent = 2,75 ; V_sol face au vent = 35 km/h | ≥ 20 km/h (critère V_cr ≥ 2·V_vent) | oui | V_cr/V_vent − 2 = 0,75 |
| V1-PERF-07 | F plein gaz (THR_MAX) à 1,3·Vs, masse réelle : 5,4 / 5,1 m/s en 3S, 6,7 / 6,4 m/s en 4S (ISA / jour chaud) | ≥ 3 m/s | oui | +2,1 m/s (pire) |
| V1-PERF-08 | F, T/W statique : 0,76 / 0,70 en 3S, 0,86 / 0,80 en 4S (ISA / jour chaud) | ≥ 0,5 | oui | +0,20 (pire) |
| V1-PROP-02 | F, P max batterie pleine : 145 W en 3S, 200 W en 4S (besoin au point de conception : 69 W) | 150 à 200 W | NON en 3S (MOD-02) | 3S : -5 W sous 150 W ; avec MOD-02 (140-200 W, T/W jour chaud ≥ 0,5) : conforme |
| V1-PROP-03 | Pales CAM Carbon 8×6 / 7×6 et moyeu RFM : rotation droite (tractrice) ; pas de version propulsive trouvée | Propulsive repliable (souhaitable) | à risque | alternatives : aero-naut 8×5 propulsive (repliable) ou APC EP (rigide) |


### Vérification des exigences — hypothèses du cahier (η = 0,5, budget du cahier), avant choix du moteur

| Exigence | Valeur calculée | Exigence (cahier) | Conforme | Marge |
| --- | --- | --- | --- | --- |
| V1-PERF-01 | Vs à 800 g = 28,8 km/h (ISA) ; 30,1 km/h TAS jour chaud | ≤ 32 km/h (cible 29) | oui | 1,9 km/h (pire cas) |
| V1-PERF-02 | P_élec 4S1P : 29 W à 45, 43 W à 55, 52 W à 60 km/h (CL = 0,18) | 45 à 60 km/h tenus | oui | P(60 km/h) = 35 % de 150 W |
| V1-PERF-03 | 4S1P à 55 km/h, η = 0,5 : 43 à 50 min réel (−30/−20 %), 39 à 44 min si CD0 = 0,035 ; η calculé : 35 à 54 min (−30 %) selon l'option | ≥ 45 min | sous réserve (limite à η = 0,5) | -2 à +5 min (η = 0,5) |
| V1-PERF-04 | 4S1P à 40 km/h (1,39·Vs, opérationnel), η = 0,5 : 76 à 87 min, 70 à 80 min si CD0 = 0,035 ; η calculé : 68 à 87 min (−30 %) ; borne 1,2·Vs (34,5 km/h) : 88 à 100 min | ≥ 70 min (souhaitable) | limite | -0,2 min (CD0 0,035, −30 %) |
| V1-PERF-05 | 3S1P à 55 km/h, η = 0,5 : 33 à 38 min réel, 29 à 34 min si CD0 = 0,035 ; η calculé : 27 à 36 min (−30 %) | ≥ 30 min | oui | +3 min (pire) |
| V1-PERF-06 | V_cr/V_vent = 2,75 ; V_sol face au vent = 35 km/h ; V max palier (150 W) = 91 km/h | ≥ 20 km/h (critère V_cr ≥ 2·V_vent) | oui | V_cr/V_vent − 2 = 0,75 |
| V1-PERF-07 | Vz à 1,3·Vs (37 km/h) avec 150 W : 8,4 m/s ISA, 8,3 m/s jour chaud | ≥ 3 m/s | oui | +5,3 m/s (pire) |
| V1-PERF-08 | T/W statique, 150 W, hélice 8 pouces, Froude : 0,86 ISA, 0,84 jour chaud (avant choix du KV) | ≥ 0,5 | oui | +0,34 (pire) |
| V1-PROP-02 | P requise au point retenu (CD0 0,030, pire ISA/jour chaud) = 69 W (Lancer main T/W ≥ 0,5) | 150 à 200 W | oui | 150 W = 2,17 × le besoin |


### Atmosphère (C1 p.36-39, ISA+ΔT)

| Cas | T [°C] | p [Pa] | ρ [kg/m³] | σ |
| --- | --- | --- | --- | --- |
| ISA, niveau de la mer | 15,0 | 101325 | 1,2250 | 1,000 |
| Jour chaud, 200 m, 35 °C | 35,0 | 98945 | 1,1186 | 0,913 |


### Géométrie

| λ | S trapèze [m²] | MAC C2 p.64 [m] | MAC cahier [m] |
| --- | --- | --- | --- |
| 4,00 | 0,2500 | 0,2565 | 0,257 |


### Estimation de CD0 (C3 p.85) et Reynolds

| Swet/S | Re croisière (MAC) | Re à 29 km/h | CD0 skill (Cfe 0,0055) | Cfe corrigé Re | CD0 corrigé | Plage cahier |
| --- | --- | --- | --- | --- | --- | --- |
| 2,39 | 2,69e+05 | 1,42e+05 | 0,0132 | 0,0113 | 0,0271 | 0,025 à 0,035 |


### Points remarquables, 4S1P 796 g, ISA (C1 p.49-60)

| CD0 | k | f_max | CL(Pn min) | Pn min faisable | V(Pn min) [km/h] | CL(fmax) | V(fmax) [km/h] | V(Tn/V min) [km/h] |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 0,025 | 0,1020 | 9,90 | 0,857 | non (> CLmax) | 27,8 | 0,495 | 36,5 | 48,1 |
| 0,030 | 0,1020 | 9,04 | 0,939 | non (> CLmax) | 26,5 | 0,542 | 34,9 | 45,9 |
| 0,035 | 0,1020 | 8,37 | 1,014 | non (> CLmax) | 25,5 | 0,586 | 33,6 | 44,2 |


### Point de conception — W/S retenue 31,4 N/m² (3,20 kg/m²), 800 g, pire cas ISA/jour chaud, P/W en W/kg

| CD0 | Montée | Virage | Croisière | Lancer 8 pouces | P/W requis | Contrainte active | P_élec requise [W] | Optimum skill W/S [N/m²] | P/W à l'optimum |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 0,025 | 80 | 35 | 41 | 86 | 86 | Lancer main T/W ≥ 0,5 | 69 | 35,4 (3,61 kg/m²) | 92 |
| 0,030 | 82 | 39 | 48 | 86 | 86 | Lancer main T/W ≥ 0,5 | 69 | 35,4 (3,61 kg/m²) | 92 |
| 0,035 | 84 | 43 | 54 | 86 | 86 | Lancer main T/W ≥ 0,5 | 69 | 35,4 (3,61 kg/m²) | 92 |


### Options moteur 2212 + hélice repliable propulsive (modèle, ISA sauf mention)

| KV | Batterie | Hélice | U sous charge plein / nominal [V] | I max = I cellule [A] | P_élec plein / nominal [W] | tr/min (nominal) | V pas [km/h] (/55 km/h) | T statique [N] (T/W) | T/W jour chaud | η batterie→arbre | Signalements |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 920 | 3S1P | 8.5x5 | 11,9 / 10,4 | 11,2 (lim. 12) | 133 / 91 | 8638 | 66 (1,20×) | 5,76 (0,81) | 0,75 | 0,85 | P batterie pleine < 150 W, vitesse de pas < 1,5·V_cr |
| 920 | 4S1P | 7x6 | 15,9 / 13,9 | 10,9 (lim. 12) | 174 / 118 | 11870 | 109 (1,97×) | 5,65 (0,72) | 0,67 | 0,87 | — |
| 1000 | 3S1P | 8x6 | 11,9 / 10,3 | 12,7 (lim. 13) | 151 / 104 | 9354 | 86 (1,56×) | 5,71 (0,80) | 0,75 | 0,85 | — |
| 1000 | 4S1P | 7x4 | 16,0 / 13,9 | 10,5 (lim. 13) | 167 / 114 | 13094 | 80 (1,45×) | 6,04 (0,77) | 0,72 | 0,88 | vitesse de pas < 1,5·V_cr |


### Toutes les combinaisons qui passent les critères durs (ISA)

| KV | Batterie | Hélice | I max [A] (lim.) | P plein / nominal [W] | V pas / V_cr | T/W ISA / chaud | Signalements |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 920 | 3S1P | 7.5x5 | 7,5 (12,0) | 91 / 62 | 1,26 | 0,56 / 0,52 | P batterie pleine < 150 W, vitesse de pas < 1,5·V_cr |
| 920 | 3S1P | 7.5x6 | 8,4 (12,0) | 102 / 69 | 1,49 | 0,58 / 0,54 | P batterie pleine < 150 W, vitesse de pas < 1,5·V_cr |
| 920 | 3S1P | 8x4 | 8,1 (12,0) | 98 / 67 | 1,00 | 0,66 / 0,61 | P batterie pleine < 150 W, vitesse de pas < 1,5·V_cr |
| 920 | 3S1P | 8x4.5 | 8,7 (12,0) | 105 / 71 | 1,11 | 0,67 / 0,62 | P batterie pleine < 150 W, vitesse de pas < 1,5·V_cr |
| 920 | 3S1P | 8x5 | 9,2 (12,0) | 111 / 76 | 1,23 | 0,68 / 0,63 | P batterie pleine < 150 W, vitesse de pas < 1,5·V_cr |
| 920 | 3S1P | 8x5.5 | 9,8 (12,0) | 117 / 80 | 1,34 | 0,69 / 0,64 | P batterie pleine < 150 W, vitesse de pas < 1,5·V_cr |
| 920 | 3S1P | 8x6 | 10,3 (12,0) | 123 / 85 | 1,45 | 0,70 / 0,65 | P batterie pleine < 150 W, vitesse de pas < 1,5·V_cr |
| 920 | 3S1P | 8.5x5 | 11,2 (12,0) | 133 / 91 | 1,20 | 0,81 / 0,75 | P batterie pleine < 150 W, vitesse de pas < 1,5·V_cr |
| 920 | 4S1P | 7x4 | 8,4 (12,0) | 136 / 92 | 1,35 | 0,67 / 0,62 | P batterie pleine < 150 W, vitesse de pas < 1,5·V_cr |
| 920 | 4S1P | 7x5 | 9,7 (12,0) | 155 / 106 | 1,67 | 0,70 / 0,65 | — |
| 920 | 4S1P | 7x6 | 10,9 (12,0) | 174 / 118 | 1,97 | 0,72 / 0,67 | — |
| 920 | 4S1P | 7.5x4 | 10,6 (12,0) | 169 / 115 | 1,32 | 0,83 / 0,77 | vitesse de pas < 1,5·V_cr |
| 1000 | 3S1P | 7x6 | 8,4 (13,0) | 101 / 69 | 1,64 | 0,55 / 0,50 | P batterie pleine < 150 W |
| 1000 | 3S1P | 7.5x4 | 8,1 (13,0) | 98 / 67 | 1,10 | 0,62 / 0,58 | P batterie pleine < 150 W, vitesse de pas < 1,5·V_cr |
| 1000 | 3S1P | 7.5x5 | 9,3 (13,0) | 112 / 76 | 1,35 | 0,65 / 0,60 | P batterie pleine < 150 W, vitesse de pas < 1,5·V_cr |
| 1000 | 3S1P | 7.5x6 | 10,4 (13,0) | 125 / 85 | 1,60 | 0,67 / 0,62 | P batterie pleine < 150 W |
| 1000 | 3S1P | 8x4 | 10,0 (13,0) | 121 / 82 | 1,07 | 0,76 / 0,70 | P batterie pleine < 150 W, vitesse de pas < 1,5·V_cr |
| 1000 | 3S1P | 8x4.5 | 10,7 (13,0) | 129 / 88 | 1,19 | 0,77 / 0,71 | P batterie pleine < 150 W, vitesse de pas < 1,5·V_cr |
| 1000 | 3S1P | 8x5 | 11,4 (13,0) | 136 / 93 | 1,32 | 0,78 / 0,72 | P batterie pleine < 150 W, vitesse de pas < 1,5·V_cr |
| 1000 | 3S1P | 8x5.5 | 12,1 (13,0) | 144 / 99 | 1,44 | 0,79 / 0,74 | P batterie pleine < 150 W, vitesse de pas < 1,5·V_cr |
| 1000 | 3S1P | 8x6 | 12,7 (13,0) | 151 / 104 | 1,56 | 0,80 / 0,75 | — |
| 1000 | 4S1P | 7x4 | 10,5 (13,0) | 167 / 114 | 1,45 | 0,77 / 0,72 | vitesse de pas < 1,5·V_cr |
| 1000 | 4S1P | 7x5 | 12,0 (13,0) | 191 / 130 | 1,79 | 0,80 / 0,74 | — |
| 1100 | 3S1P | 7x4 | 8,3 (14,3) | 100 / 68 | 1,21 | 0,59 / 0,55 | P batterie pleine < 150 W, vitesse de pas < 1,5·V_cr |
| 1100 | 3S1P | 7x5 | 9,5 (14,3) | 114 / 78 | 1,50 | 0,62 / 0,57 | P batterie pleine < 150 W, vitesse de pas < 1,5·V_cr |
| 1100 | 3S1P | 7x6 | 10,7 (14,3) | 128 / 87 | 1,78 | 0,64 / 0,59 | P batterie pleine < 150 W |
| 1100 | 3S1P | 7.5x4 | 10,4 (14,3) | 125 / 85 | 1,19 | 0,73 / 0,68 | P batterie pleine < 150 W, vitesse de pas < 1,5·V_cr |
| 1100 | 3S1P | 7.5x5 | 11,9 (14,3) | 142 / 97 | 1,46 | 0,76 / 0,70 | P batterie pleine < 150 W, vitesse de pas < 1,5·V_cr |
| 1100 | 3S1P | 7.5x6 | 13,3 (14,3) | 157 / 108 | 1,73 | 0,78 / 0,73 | — |
| 1100 | 3S1P | 8x4 | 12,8 (14,3) | 152 / 104 | 1,16 | 0,89 / 0,83 | vitesse de pas < 1,5·V_cr |
| 1100 | 3S1P | 8x4.5 | 13,7 (14,3) | 162 / 111 | 1,29 | 0,90 / 0,84 | vitesse de pas < 1,5·V_cr |
| 1250 | 3S1P | 7x4 | 11,5 (16,2) | 137 / 94 | 1,36 | 0,74 / 0,68 | P batterie pleine < 150 W, vitesse de pas < 1,5·V_cr |
| 1250 | 3S1P | 7x5 | 13,2 (16,2) | 156 / 107 | 1,67 | 0,77 / 0,71 | — |
| 1250 | 3S1P | 7x6 | 14,7 (16,2) | 174 / 119 | 1,97 | 0,79 / 0,74 | — |
| 1250 | 3S1P | 7.5x4 | 14,4 (16,2) | 170 / 116 | 1,32 | 0,91 / 0,84 | vitesse de pas < 1,5·V_cr |
| 1400 | 3S1P | 7x4 | 15,3 (18,2) | 180 / 123 | 1,49 | 0,89 / 0,83 | vitesse de pas < 1,5·V_cr |


### 4S1P avec la plus petite hélice du balayage (7x4) : pourquoi les KV élevés échouent

| KV | I max [A] | I limite [A] | P batterie pleine [W] | Valide |
| --- | --- | --- | --- | --- |
| 920 | 8,4 | 12,0 | 136 | oui |
| 1000 | 10,5 | 13,0 | 167 | oui |
| 1100 | 13,4 | 14,3 | 211 | non |
| 1250 | 18,4 | 16,2 | 285 | non |
| 1400 | 24,1 | 18,2 | 365 | non |


### Autonomie et distance, ISA (vitesses : 55, 35, 40 km/h, max autonomie, max distance)

| Batterie | CD0 | V [km/h] | P_élec [W] | t théorique [min] | t réel −20 % [min] | t réel −30 % [min] | R théorique [km] | R réel −30 % [km] |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 3S1P | 0,025 | 55,0 | 36,2 | 55 | 44 | 38 | 50,1 | 35,1 |
| 3S1P | 0,025 | 35,0 | 18,5 | 107 | 86 | 75 | 62,5 | 43,7 |
| 3S1P | 0,025 | 40,0 | 21,1 | 94 | 75 | 66 | 62,6 | 43,8 |
| 3S1P | 0,025 | 33,0 | 17,8 | 111 | 89 | 78 | 61,2 | 42,9 |
| 3S1P | 0,025 | 37,8 | 19,8 | 100 | 80 | 70 | 63,0 | 44,1 |
| 3S1P | 0,030 | 55,0 | 41,7 | 48 | 38 | 33 | 43,6 | 30,5 |
| 3S1P | 0,030 | 35,0 | 19,9 | 99 | 80 | 70 | 58,0 | 40,6 |
| 3S1P | 0,030 | 40,0 | 23,2 | 85 | 68 | 60 | 56,9 | 39,9 |
| 3S1P | 0,030 | 33,0 | 19,0 | 104 | 84 | 73 | 57,4 | 40,2 |
| 3S1P | 0,030 | 35,8 | 20,3 | 98 | 78 | 68 | 58,1 | 40,7 |
| 3S1P | 0,035 | 55,0 | 47,2 | 42 | 34 | 29 | 38,5 | 27,0 |
| 3S1P | 0,035 | 35,0 | 21,3 | 93 | 74 | 65 | 54,2 | 37,9 |
| 3S1P | 0,035 | 40,0 | 25,3 | 78 | 63 | 55 | 52,2 | 36,6 |
| 3S1P | 0,035 | 33,0 | 20,2 | 98 | 79 | 69 | 54,1 | 37,9 |
| 3S1P | 0,035 | 34,5 | 21,0 | 94 | 75 | 66 | 54,2 | 38,0 |
| 4S1P | 0,025 | 55,0 | 37,1 | 71 | 57 | 50 | 65,3 | 45,7 |
| 4S1P | 0,025 | 35,0 | 19,9 | 133 | 106 | 93 | 77,5 | 54,3 |
| 4S1P | 0,025 | 40,0 | 22,3 | 119 | 95 | 83 | 79,0 | 55,3 |
| 4S1P | 0,025 | 34,5 | 19,7 | 134 | 107 | 94 | 77,1 | 54,0 |
| 4S1P | 0,025 | 39,0 | 21,7 | 122 | 97 | 85 | 79,1 | 55,4 |
| 4S1P | 0,030 | 55,0 | 42,6 | 62 | 50 | 43 | 56,9 | 39,8 |
| 4S1P | 0,030 | 35,0 | 21,3 | 124 | 99 | 87 | 72,4 | 50,7 |
| 4S1P | 0,030 | 40,0 | 24,4 | 108 | 87 | 76 | 72,2 | 50,5 |
| 4S1P | 0,030 | 34,5 | 21,1 | 126 | 100 | 88 | 72,2 | 50,5 |
| 4S1P | 0,030 | 37,2 | 22,5 | 117 | 94 | 82 | 72,9 | 51,0 |
| 4S1P | 0,035 | 55,0 | 48,0 | 55 | 44 | 39 | 50,5 | 35,3 |
| 4S1P | 0,035 | 35,0 | 22,7 | 116 | 93 | 82 | 67,9 | 47,6 |
| 4S1P | 0,035 | 40,0 | 26,5 | 100 | 80 | 70 | 66,5 | 46,5 |
| 4S1P | 0,035 | 34,5 | 22,4 | 118 | 94 | 83 | 67,8 | 47,5 |
| 4S1P | 0,035 | 35,8 | 23,2 | 114 | 91 | 80 | 68,0 | 47,6 |


### Optimums numériques (avec avionique) et autonomie réelle à 55 km/h le jour chaud

| Batterie | CD0 | V autonomie max [km/h] | V distance max [km/h] | t réel 55 km/h jour chaud [min] |
| --- | --- | --- | --- | --- |
| 3S1P | 0,025 | 33,0 (butée 1,2·Vs) | 37,8 | 40 à 46 |
| 3S1P | 0,030 | 33,0 (butée 1,2·Vs) | 35,8 | 35 à 40 |
| 3S1P | 0,035 | 33,0 (butée 1,2·Vs) | 34,5 | 31 à 36 |
| 4S1P | 0,025 | 34,5 (butée 1,2·Vs) | 39,0 | 53 à 60 |
| 4S1P | 0,030 | 34,5 (butée 1,2·Vs) | 37,2 | 46 à 53 |
| 4S1P | 0,035 | 34,5 (butée 1,2·Vs) | 35,8 | 41 à 47 |


### Vent de face 20 km/h (V1-PERF-06), 4S1P, CD0 nominal, ISA

| V air [km/h] | V sol [km/h] | Distance face au vent réel [km] | Distance sans vent réel [km] | V optimale face au vent [km/h] | Distance à l'optimum (théorique) [km] | V max palier 150 W [km/h] |
| --- | --- | --- | --- | --- | --- | --- |
| 55 | 35,0 | 25,4 à 29,0 | 39,8 à 45,5 | 46,8 | 38,2 | 91 |


### Budget de masse (cahier)

| Poste | Groupe | Masse [g] |
| --- | --- | --- |
| Panneaux d'aile LW-PLA (2 demi-ailes) | structure | 190 |
| Fuselage central PLA/PETG + trappe | structure | 70 |
| Longeron carbone 8 mm + clé arrière 3 mm | structure | 30 |
| Winglets + élevons | structure | 30 |
| Moteur 2212 + hélice repliable + cône | systèmes | 62 |
| Câblage, connecteurs, velcro, PCB d'interconnexion | systèmes | 35 |
| Contrôleur de vol | systèmes | 25 |
| Raspberry Pi Zero 2 W + Camera Module 3 + microSD | systèmes | 20 |
| 2 servos 9 g | systèmes | 18 |
| ESC 30 A | systèmes | 15 |
| GPS M10 + compas | systèmes | 10 |
| Récepteur ELRS + antennes | systèmes | 3 |
| **Sous-total structure** |  | 320 |
| **Sous-total systèmes** |  | 188 |
| **Masse sans batterie** |  | 508 |
| Batterie 4S1P |  | 288 |
| **Total 4S1P** |  | 796 |
| Batterie 3S1P |  | 220 |
| **Total 3S1P** |  | 728 |


### Marges de masse

| Critère | Valeur [g] | Limite [g] | Marge [g] |
| --- | --- | --- | --- |
| V1-MAS-01, 4S1P (cellules 69 g) | 796 | 800 | 4 |
| V1-MAS-01, 4S1P (cellules 70,0 g, fiche) | 800 | 800 | 0 |
| V1-MAS-01, 3S1P | 728 | 800 | 72 |
| V1-MAS-02, sans batterie | 508 | 520 | 12 |
| V1-MAS-03, structure | 320 | 320 | 0 |
| Règle de décision structure | 320 | 330 | 10 |


### Sensibilité — base : 4S1P à 55 km/h, t théorique = 62,1 min ; P/W de conception = 86,3 W/kg

| Paramètre | Bas / haut | t théorique [min] | Δt [%] | P/W [W/kg] | ΔP/W [%] |
| --- | --- | --- | --- | --- | --- |
| η (rendement global) | 0,4 / 0,6 | 50,7 / 73,0 | -18,3 / +17,5 | 102,4 / 86,3 | +18,7 / +0,0 |
| e (Oswald) | 0,7 / 0,85 | 61,2 / 62,7 | -1,4 / +1,0 | 86,3 / 86,3 | +0,0 / +0,0 |
| CD0 | 0,025 / 0,035 | 71,2 / 55,0 | +14,7 / -11,4 | 86,3 / 86,3 | +0,0 / +0,0 |
| Masse +50 g | 0 / 50 | 62,1 / 61,1 | +0,0 / -1,6 | 86,3 / 88,9 | +0,0 / +3,1 |
| FM hélice (point fixe) | 0,44 / 0,66 | 62,1 / 62,1 | +0,0 / +0,0 | 107,8 / 81,9 | +25,0 / -5,0 |


### Classement des options moteur sur le η de croisière calculé (ISA, CD0 0,030, tension nominale) — tri : autonomie réelle 4S1P à 55 km/h, −30 %

| Rang | Option | Moteur | Hélice 3S / 4S | THR_MAX 3S / 4S | η 4S 40 / 4S 55 / 3S 55 km/h | V1-PERF-03 : 4S 55 km/h [min] | idem CD0 0,035, −30 % | V1-PERF-04 : 4S 40 km/h [min] | V1-PERF-05 : 3S 55 km/h [min] | T/W min ISA / jour chaud | P max 3S / 4S [W] | I max 3S / 4S [A] | Masse 4S [g] (marge 800 g) | Non tenu à −30 % (CD0 nominal) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | C | 2212 920 KV | 8.5x5 / 7x6 | 1,00 / 1,00 | 0,605 / 0,641 / 0,396 | 54 à 61 | 49 | 87 à 100 | 27 à 31 | 0,71 / 0,66 | 133 / 174 | 11,2 / 10,9 (lim. 12) | 814 (-14 ; -18 cell. 70 g) | V1-PERF-05 |
| 2 | G | X2212 980 KV | 8x6 / 7x6 | 1,00 / 0,99 | 0,578 / 0,621 / 0,531 | 52 à 60 | 48 | 84 à 96 | 35 à 40 | 0,76 / 0,70 | 145 / 200 | 12,2 / 12,7 (lim. 18) | 814 (-14 ; -18 cell. 70 g) | aucune |
| 3 | A | 2212 1000 KV | 8x6 / 7x5 | 1,00 / 1,00 | 0,545 / 0,559 / 0,545 | 48 à 55 | 44 | 80 à 92 | 36 à 41 | 0,78 / 0,73 | 151 / 191 | 12,7 / 12,0 (lim. 13) | 814 (-14 ; -18 cell. 70 g) | aucune |
| 4 | E-1260 | X2208 1260 KV | 8x6 / 8x6 | 0,80 / 0,59 | 0,562 / 0,540 / 0,535 | 46 à 53 | 43 | 83 à 95 | 35 à 40 | 0,63 / 0,59 | 130 / 130 | 13,5 / 13,5 (lim. 15) | 803 (-3 ; -7 cell. 70 g) | aucune |
| 5 | E-1100 | X2208 1100 KV | 8x6 / 8x6 | 0,93 / 0,69 | 0,563 / 0,537 / 0,531 | 46 à 53 | 42 | 83 à 95 | 35 à 40 | 0,62 / 0,59 | 130 / 130 | 11,6 / 11,6 (lim. 14) | 803 (-3 ; -7 cell. 70 g) | aucune |
| 6 | F | X2212 980 KV | 8x6 / 8x6 | 1,00 / 0,84 | 0,537 / 0,538 / 0,531 | 46 à 53 | 43 | 79 à 91 | 35 à 40 | 0,76 / 0,70 | 145 / 200 | 12,2 / 14,9 (lim. 18) | 814 (-14 ; -18 cell. 70 g) | aucune |
| 7 | B | 2212 1000 KV | 8x5.5 / 7x4 | 1,00 / 1,00 | 0,463 / 0,453 / 0,500 | 40 à 45 | 37 | 70 à 80 | 33 à 38 | 0,76 / 0,70 | 144 / 167 | 12,1 / 10,5 (lim. 13) | 814 (-14 ; -18 cell. 70 g) | V1-PERF-03 |
| 8 | F-8x5 | X2212 980 KV | 8x5 / 8x5 | 1,00 / 0,88 | 0,464 / 0,446 / 0,440 | 39 à 45 | 36 | 70 à 80 | 29 à 34 | 0,74 / 0,68 | 131 / 200 | 11,0 / 14,3 (lim. 18) | 814 (-14 ; -18 cell. 70 g) | V1-PERF-03, V1-PERF-05 |
| 9 | E2 | 2208 hors cat. 800 KV | 9x7 / 8x4.5 | 1,00 / 1,00 | 0,439 / 0,393 / 0,488 | 35 à 40 | 33 | 68 à 77 | 33 à 37 | 0,60 / 0,57 | 102 / 128 | 8,5 / 7,9 (lim. 10) | 803 (-3 ; -7 cell. 70 g) | V1-PERF-03, V1-PERF-04 |
| — | η = 0,5 (cahier) | — | — | — | 0,5 / 0,5 / 0,5 | 43 à 50 | 39 | 76 à 87 | 33 à 38 | — | — | — | 796 (+4) | V1-PERF-03 |


### Robustesse du classement à l'hypothèse d'hélice en vol (k_JT = 0,99 / 1,10 / 1,21)

| Option | Rang nominal | Rang k_JT bas / haut | η 4S 55 km/h bas / nominal / haut |
| --- | --- | --- | --- |
| C | 1 | 1 / 1 | 0,565 / 0,641 / 0,709 |
| G | 2 | 2 / 2 | 0,549 / 0,621 / 0,685 |
| A | 3 | 3 / 3 | 0,482 / 0,559 / 0,630 |
| E-1260 | 4 | 5 / 4 | 0,455 / 0,540 / 0,621 |
| E-1100 | 5 | 6 / 5 | 0,451 / 0,537 / 0,618 |
| F | 6 | 4 / 6 | 0,457 / 0,538 / 0,614 |
| B | 7 | 7 / 7 | 0,379 / 0,453 / 0,524 |
| F-8x5 | 8 | 8 / 8 | 0,370 / 0,446 / 0,520 |
| E2 | 9 | 9 / 9 | 0,318 / 0,393 / 0,469 |


### Décomposition du η global à 55 km/h (ISA, CD0 nominal, tension nominale)

| Option | Batterie | Hélice | η hélice | η moteur | η ESC | η batterie | η global | Point de fonctionnement |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| C | 4S1P | 7x6 | 0,799 | 0,826 | 0,980 | 0,991 | 0,641 | 7822 tr/min, d = 0,62, I = 2,1 A |
| C | 3S1P | 8.5x5 | 0,481 | 0,854 | 0,984 | 0,982 | 0,396 | 7676 tr/min, d = 0,84, I = 4,4 A |
| G | 4S1P | 7x6 | 0,799 | 0,800 | 0,979 | 0,991 | 0,621 | 7822 tr/min, d = 0,59, I = 2,1 A |
| G | 3S1P | 8x6 | 0,671 | 0,819 | 0,980 | 0,986 | 0,531 | 6976 tr/min, d = 0,71, I = 3,3 A |
| A | 4S1P | 7x5 | 0,691 | 0,832 | 0,981 | 0,990 | 0,559 | 8739 tr/min, d = 0,64, I = 2,4 A |
| A | 3S1P | 8x6 | 0,671 | 0,840 | 0,979 | 0,987 | 0,545 | 6976 tr/min, d = 0,70, I = 3,2 A |
| E-1260 | 4S1P | 8x6 | 0,675 | 0,827 | 0,977 | 0,990 | 0,540 | 7003 tr/min, d = 0,44, I = 2,5 A |
| E-1260 | 3S1P | 8x6 | 0,670 | 0,827 | 0,977 | 0,987 | 0,535 | 6971 tr/min, d = 0,59, I = 3,2 A |
| E-1100 | 4S1P | 8x6 | 0,675 | 0,820 | 0,979 | 0,990 | 0,537 | 7003 tr/min, d = 0,51, I = 2,5 A |
| E-1100 | 3S1P | 8x6 | 0,670 | 0,820 | 0,979 | 0,986 | 0,531 | 6971 tr/min, d = 0,68, I = 3,3 A |
| F | 4S1P | 8x6 | 0,676 | 0,820 | 0,980 | 0,990 | 0,538 | 7008 tr/min, d = 0,53, I = 2,5 A |
| F | 3S1P | 8x6 | 0,671 | 0,819 | 0,980 | 0,986 | 0,531 | 6976 tr/min, d = 0,71, I = 3,3 A |
| B | 4S1P | 7x4 | 0,553 | 0,843 | 0,984 | 0,988 | 0,453 | 10143 tr/min, d = 0,74, I = 2,9 A |
| B | 3S1P | 8x5.5 | 0,612 | 0,844 | 0,981 | 0,986 | 0,500 | 7409 tr/min, d = 0,74, I = 3,5 A |
| F-8x5 | 4S1P | 8x5 | 0,554 | 0,831 | 0,983 | 0,988 | 0,446 | 7963 tr/min, d = 0,61, I = 3,0 A |
| F-8x5 | 3S1P | 8x5 | 0,548 | 0,830 | 0,983 | 0,984 | 0,440 | 7933 tr/min, d = 0,81, I = 3,9 A |
| E2 | 4S1P | 8x4.5 | 0,484 | 0,835 | 0,986 | 0,986 | 0,393 | 8604 tr/min, d = 0,86, I = 3,4 A |
| E2 | 3S1P | 9x7 | 0,644 | 0,783 | 0,982 | 0,985 | 0,488 | 5788 tr/min, d = 0,83, I = 3,5 A |


### Bridage des gaz calculé (batterie pleine, point fixe, ISA)

| Option | Batterie | Hélice | d à P_lim | d à I_lim | THR_MAX retenu | P au bridage [W] | I au bridage [A] |
| --- | --- | --- | --- | --- | --- | --- | --- |
| G | 3S1P | 8x6 | 1,000 | 1,000 | 1,000 (aucune) | 145 | 12,2 (lim. 18) |
| G | 4S1P | 7x6 | 0,991 | 1,000 | 0,991 (puissance) | 200 | 12,7 (lim. 18) |
| E-1260 | 3S1P | 8x6 | 0,801 | 0,859 | 0,801 (puissance) | 130 | 13,5 (lim. 15) |
| E-1260 | 4S1P | 8x6 | 0,594 | 0,636 | 0,594 (puissance) | 130 | 13,5 (lim. 15) |
| E-1100 | 3S1P | 8x6 | 0,935 | 1,000 | 0,935 (puissance) | 130 | 11,6 (lim. 14) |
| E-1100 | 4S1P | 8x6 | 0,694 | 0,789 | 0,694 (puissance) | 130 | 11,6 (lim. 14) |
| F | 3S1P | 8x6 | 1,000 | 1,000 | 1,000 (aucune) | 145 | 12,2 (lim. 18) |
| F | 4S1P | 8x6 | 0,845 | 0,973 | 0,845 (puissance) | 200 | 14,9 (lim. 18) |
| F-8x5 | 3S1P | 8x5 | 1,000 | 1,000 | 1,000 (aucune) | 131 | 11,0 (lim. 18) |
| F-8x5 | 4S1P | 8x5 | 0,880 | 1,000 | 0,880 (puissance) | 200 | 14,3 (lim. 18) |


### Variante E sans bridage : 2208 (SunnySky X2208), hélices ≥ 8 pouces, fenêtre 100-130 W (toutes les combinaisons)

| KV | Batterie | Hélice | I max [A] (lim.) | P plein [W] | T/W ISA / chaud | Valide |
| --- | --- | --- | --- | --- | --- | --- |
| 1100 | 3S1P | 8x4 | 10,5 (14) | 126 | 0,75 / 0,70 | oui |
| 1100 | 3S1P | 8x4.5 | 11,1 (14) | 133 | 0,75 / 0,70 | non |
| 1100 | 3S1P | 8x5 | 11,7 (14) | 140 | 0,75 / 0,71 | non |
| 1100 | 3S1P | 8x5.5 | 12,3 (14) | 146 | 0,75 / 0,71 | non |
| 1100 | 3S1P | 8x6 | 12,8 (14) | 152 | 0,75 / 0,71 | non |
| 1100 | 3S1P | 8.5x5 | 13,6 (14) | 161 | 0,85 / 0,81 | non |
| 1100 | 3S1P | 8.5x6 | 14,8 (14) | 174 | 0,85 / 0,81 | non |
| 1100 | 3S1P | 9x5 | 15,6 (14) | 183 | 0,96 / 0,91 | non |
| 1100 | 3S1P | 9x6 | 16,7 (14) | 196 | 0,95 / 0,90 | non |
| 1100 | 3S1P | 9x7 | 17,8 (14) | 207 | 0,94 / 0,89 | non |
| 1100 | 4S1P | 8x4 | 16,3 (14) | 255 | 1,08 / 1,02 | non |
| 1100 | 4S1P | 8x4.5 | 17,2 (14) | 267 | 1,08 / 1,02 | non |
| 1100 | 4S1P | 8x5 | 18,0 (14) | 279 | 1,07 / 1,02 | non |
| 1100 | 4S1P | 8x5.5 | 18,7 (14) | 290 | 1,07 / 1,02 | non |
| 1100 | 4S1P | 8x6 | 19,5 (14) | 300 | 1,07 / 1,01 | non |
| 1100 | 4S1P | 8.5x5 | 20,6 (14) | 316 | 1,20 / 1,14 | non |
| 1100 | 4S1P | 8.5x6 | 22,1 (14) | 338 | 1,19 / 1,13 | non |
| 1100 | 4S1P | 9x5 | 23,1 (14) | 352 | 1,33 / 1,27 | non |
| 1100 | 4S1P | 9x6 | 24,7 (14) | 373 | 1,30 / 1,24 | non |
| 1100 | 4S1P | 9x7 | 26,0 (14) | 392 | 1,28 / 1,22 | non |
| 1260 | 3S1P | 8x4 | 15,4 (15) | 181 | 0,96 / 0,90 | non |
| 1260 | 3S1P | 8x4.5 | 16,2 (15) | 190 | 0,96 / 0,90 | non |
| 1260 | 3S1P | 8x5 | 17,1 (15) | 199 | 0,96 / 0,90 | non |
| 1260 | 3S1P | 8x5.5 | 17,8 (15) | 208 | 0,96 / 0,90 | non |
| 1260 | 3S1P | 8x6 | 18,6 (15) | 216 | 0,96 / 0,91 | non |
| 1260 | 3S1P | 8.5x5 | 19,8 (15) | 229 | 1,09 / 1,03 | non |
| 1260 | 3S1P | 8.5x6 | 21,4 (15) | 246 | 1,08 / 1,03 | non |
| 1260 | 3S1P | 9x5 | 22,5 (15) | 257 | 1,21 / 1,15 | non |
| 1260 | 3S1P | 9x6 | 24,1 (15) | 274 | 1,20 / 1,14 | non |
| 1260 | 3S1P | 9x7 | 25,6 (15) | 289 | 1,18 / 1,13 | non |
| 1260 | 4S1P | 8x4 | 23,5 (15) | 356 | 1,36 / 1,29 | non |
| 1260 | 4S1P | 8x4.5 | 24,7 (15) | 373 | 1,36 / 1,29 | non |
| 1260 | 4S1P | 8x5 | 25,8 (15) | 388 | 1,35 / 1,28 | non |
| 1260 | 4S1P | 8x5.5 | 26,8 (15) | 402 | 1,35 / 1,28 | non |
| 1260 | 4S1P | 8x6 | 27,8 (15) | 416 | 1,34 / 1,27 | non |
| 1260 | 4S1P | 8.5x5 | 29,4 (15) | 436 | 1,51 / 1,44 | non |
| 1260 | 4S1P | 8.5x6 | 31,5 (15) | 463 | 1,48 / 1,42 | non |
| 1260 | 4S1P | 9x5 | 32,9 (15) | 481 | 1,65 / 1,58 | non |
| 1260 | 4S1P | 9x6 | 35,0 (15) | 508 | 1,61 / 1,55 | non |
| 1260 | 4S1P | 9x7 | 36,9 (15) | 530 | 1,58 / 1,52 | non |
| 1500 | 3S1P | 8x4 | 22,6 (16) | 258 | 1,19 / 1,12 | non |
| 1500 | 3S1P | 8x4.5 | 23,7 (16) | 270 | 1,18 / 1,12 | non |
| 1500 | 3S1P | 8x5 | 24,8 (16) | 281 | 1,17 / 1,11 | non |
| 1500 | 3S1P | 8x5.5 | 25,8 (16) | 291 | 1,17 / 1,11 | non |
| 1500 | 3S1P | 8x6 | 26,7 (16) | 301 | 1,17 / 1,11 | non |
| 1500 | 3S1P | 8.5x5 | 28,2 (16) | 316 | 1,31 / 1,25 | non |
| 1500 | 3S1P | 8.5x6 | 30,2 (16) | 335 | 1,29 / 1,23 | non |
| 1500 | 3S1P | 9x5 | 31,6 (16) | 348 | 1,44 / 1,38 | non |
| 1500 | 3S1P | 9x6 | 33,6 (16) | 367 | 1,40 / 1,35 | non |
| 1500 | 3S1P | 9x7 | 35,4 (16) | 384 | 1,38 / 1,32 | non |
| 1500 | 4S1P | 8x4 | 33,4 (16) | 487 | 1,64 / 1,56 | non |
| 1500 | 4S1P | 8x4.5 | 34,9 (16) | 506 | 1,62 / 1,55 | non |
| 1500 | 4S1P | 8x5 | 36,3 (16) | 523 | 1,60 / 1,53 | non |
| 1500 | 4S1P | 8x5.5 | 37,5 (16) | 539 | 1,59 / 1,52 | non |
| 1500 | 4S1P | 8x6 | 38,8 (16) | 553 | 1,58 / 1,51 | non |
| 1500 | 4S1P | 8.5x5 | 40,6 (16) | 575 | 1,76 / 1,69 | non |
| 1500 | 4S1P | 8.5x6 | 43,1 (16) | 604 | 1,71 / 1,65 | non |
| 1500 | 4S1P | 9x5 | 44,8 (16) | 623 | 1,90 / 1,83 | non |
| 1500 | 4S1P | 9x6 | 47,2 (16) | 650 | 1,84 / 1,77 | non |
| 1500 | 4S1P | 9x7 | 49,3 (16) | 673 | 1,79 / 1,73 | non |


### Choix de l'hélice sur le η à 55 km/h — E, 3S1P (8 meilleures combinaisons valides)

| KV | Hélice | THR_MAX (bridage) | P max [W] | I max [A] | T/W ISA / chaud | η 55 km/h | d croisière |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1260 | 8x6 | 0,80 (puissance) | 130 | 13,5 | 0,69 / 0,65 | 0,535 | 0,59 |
| 1100 | 8x6 | 0,93 (puissance) | 130 | 11,6 | 0,68 / 0,64 | 0,531 | 0,68 |
| 1500 | 8x6 | 0,68 (puissance) | 130 | 15,9 | 0,67 / 0,63 | 0,507 | 0,50 |
| 1260 | 9x7 | 0,67 (courant) | 121 | 15,0 | 0,68 / 0,64 | 0,494 | 0,51 |
| 1260 | 8x5.5 | 0,82 (puissance) | 130 | 13,3 | 0,70 / 0,66 | 0,490 | 0,62 |
| 1100 | 8x5.5 | 0,95 (puissance) | 130 | 11,4 | 0,70 / 0,66 | 0,487 | 0,72 |
| 1100 | 9x7 | 0,81 (puissance) | 130 | 13,4 | 0,70 / 0,66 | 0,486 | 0,60 |
| 1260 | 8.5x6 | 0,75 (puissance) | 130 | 14,4 | 0,71 / 0,67 | 0,475 | 0,58 |


### Choix de l'hélice sur le η à 55 km/h — E, 4S1P (8 meilleures combinaisons valides)

| KV | Hélice | THR_MAX (bridage) | P max [W] | I max [A] | T/W ISA / chaud | η 55 km/h | d croisière |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1260 | 8x6 | 0,59 (puissance) | 130 | 13,5 | 0,63 / 0,59 | 0,540 | 0,44 |
| 1100 | 8x6 | 0,69 (puissance) | 130 | 11,6 | 0,62 / 0,59 | 0,537 | 0,51 |
| 1500 | 8x6 | 0,50 (puissance) | 130 | 15,9 | 0,61 / 0,58 | 0,513 | 0,38 |
| 1260 | 9x7 | 0,50 (courant) | 121 | 15,0 | 0,62 / 0,58 | 0,500 | 0,39 |
| 1260 | 8x5.5 | 0,61 (puissance) | 130 | 13,3 | 0,64 / 0,60 | 0,496 | 0,47 |
| 1100 | 8x5.5 | 0,71 (puissance) | 130 | 11,4 | 0,64 / 0,60 | 0,493 | 0,54 |
| 1100 | 9x7 | 0,60 (puissance) | 130 | 13,4 | 0,64 / 0,60 | 0,492 | 0,45 |
| 1260 | 8.5x6 | 0,56 (puissance) | 130 | 14,4 | 0,65 / 0,62 | 0,481 | 0,43 |


### Choix de l'hélice sur le η à 55 km/h — E2, 3S1P (8 meilleures combinaisons valides)

| KV | Hélice | THR_MAX (bridage) | P max [W] | I max [A] | T/W ISA / chaud | η 55 km/h | d croisière |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 950 | 8x6 | 1,00 (aucune) | 108 | 9,0 | 0,60 / 0,57 | 0,532 | 0,79 |
| 1000 | 8x6 | 1,00 (aucune) | 122 | 10,2 | 0,65 / 0,61 | 0,532 | 0,75 |
| 800 | 9x7 | 1,00 (aucune) | 102 | 8,5 | 0,60 / 0,57 | 0,488 | 0,83 |
| 850 | 9x7 | 1,00 (aucune) | 118 | 9,8 | 0,66 / 0,62 | 0,488 | 0,78 |
| 950 | 8x5.5 | 1,00 (aucune) | 103 | 8,6 | 0,60 / 0,56 | 0,488 | 0,84 |
| 1000 | 8x5.5 | 1,00 (aucune) | 117 | 9,7 | 0,65 / 0,61 | 0,488 | 0,80 |
| 900 | 8.5x6 | 1,00 (aucune) | 110 | 9,2 | 0,63 / 0,60 | 0,471 | 0,82 |
| 950 | 8.5x6 | 1,00 (aucune) | 125 | 10,4 | 0,69 / 0,65 | 0,470 | 0,78 |


### Choix de l'hélice sur le η à 55 km/h — E2, 4S1P (8 meilleures combinaisons valides)

| KV | Hélice | THR_MAX (bridage) | P max [W] | I max [A] | T/W ISA / chaud | η 55 km/h | d croisière |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 700 | 8x6 | 1,00 (aucune) | 106 | 6,6 | 0,55 / 0,51 | 0,539 | 0,80 |
| 750 | 8x6 | 1,00 (aucune) | 126 | 7,8 | 0,61 / 0,57 | 0,538 | 0,75 |
| 650 | 9x7 | 1,00 (aucune) | 127 | 7,8 | 0,63 / 0,60 | 0,495 | 0,76 |
| 700 | 8x5.5 | 1,00 (aucune) | 102 | 6,3 | 0,54 / 0,51 | 0,495 | 0,85 |
| 750 | 8x5.5 | 1,00 (aucune) | 120 | 7,4 | 0,61 / 0,57 | 0,495 | 0,79 |
| 650 | 8.5x6 | 1,00 (aucune) | 103 | 6,4 | 0,56 / 0,52 | 0,478 | 0,85 |
| 700 | 8.5x6 | 1,00 (aucune) | 123 | 7,7 | 0,63 / 0,59 | 0,477 | 0,79 |
| 750 | 8x5 | 1,00 (aucune) | 115 | 7,1 | 0,60 / 0,57 | 0,446 | 0,85 |


### Groupe propulsif explicite (pales CAM Carbon 8×6 9 g + moyeu-cône RFM Ø 30 mm 14 g) et masses — budget du cahier : 62 g

| Option | Moteur | Moteur (fiche) [g] | Pales + moyeu-cône [g] | Groupe propulsif [g] (écart au budget) | 4S1P, cellules 69 g [g] (marge 800 g) | 4S1P, cellules 70 g [g] (marge) | Sans batterie [g] (marge 520 g, V1-MAS-02) | 3S1P [g] (marge) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| C | 2212 920 KV | 57 | 9 + 14 | 80 (+18) | 814 (-14) | 818 (-18) | 526 (-6) | 746 (+54) |
| G | X2212 980 KV | 57 | 9 + 14 | 80 (+18) | 814 (-14) | 818 (-18) | 526 (-6) | 746 (+54) |
| A | 2212 1000 KV | 57 | 9 + 14 | 80 (+18) | 814 (-14) | 818 (-18) | 526 (-6) | 746 (+54) |
| E-1260 | X2208 1260 KV | 46 | 9 + 14 | 69 (+7) | 803 (-3) | 807 (-7) | 515 (+5) | 735 (+65) |
| E-1100 | X2208 1100 KV | 46 | 9 + 14 | 69 (+7) | 803 (-3) | 807 (-7) | 515 (+5) | 735 (+65) |
| F | X2212 980 KV | 57 | 9 + 14 | 80 (+18) | 814 (-14) | 818 (-18) | 526 (-6) | 746 (+54) |
| B | 2212 1000 KV | 57 | 9 + 14 | 80 (+18) | 814 (-14) | 818 (-18) | 526 (-6) | 746 (+54) |
| F-8x5 | X2212 980 KV | 57 | 9 + 14 | 80 (+18) | 814 (-14) | 818 (-18) | 526 (-6) | 746 (+54) |
| E2 | 2208 hors cat. 800 KV | 46 | 9 + 14 | 69 (+7) | 803 (-3) | 807 (-7) | 515 (+5) | 735 (+65) |


### Erreur humaine : batterie 4S1P avec le fichier 3S ou sans bridage (batterie pleine 4,15 V/cellule, point fixe, ISA)

| Option | Cas | P batterie [W] | I batterie [A] | I moteur = I ESC [A] | Moteur : référence continue / courte durée | ESC ; cellule P45B | Régime [tr/min] (pales) | Sous la référence continue | Survit 10 s plein gaz |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| F | 4S1P avec le fichier 3S (THR_MAX 1,00) | 296 (fiche 385) | 19,2 | 19,1 | 18,4 A (continu) / 26 A (30 s) | 64 % de 30 A ; 43 % de 45 A | 13229 (83 % de 16000) | non (1,04×) | oui |
| F | 4S1P sans bridage (THR_MAX 1) | 296 (fiche 385) | 19,2 | 19,1 | 18,4 A (continu) / 26 A (30 s) | 64 % de 30 A ; 43 % de 45 A | 13229 (83 % de 16000) | non (1,04×) | oui |
| E-1260 | 4S1P avec le fichier 3S (THR_MAX 0,80) | 261 (fiche 168) | 16,7 | 20,9 | 13,9 A (essai de fiche, durée non publiée) / 15 A (30 s) | 70 % de 30 A ; 37 % de 45 A | 12262 (77 % de 16000) | non (1,50×) | non |
| E-1260 | 4S1P sans bridage (THR_MAX 1) | 416 (fiche 168) | 27,8 | 27,8 | 13,9 A (essai de fiche, durée non publiée) / 15 A (30 s) | 93 % de 30 A ; 62 % de 45 A | 14187 (89 % de 16000) | non (2,00×) | non |
| E-1100 | 4S1P avec le fichier 3S (THR_MAX 0,93) | 260 (fiche 205) | 16,6 | 17,8 | 13,0 A (essai de fiche, durée non publiée) / 14 A (15 s) | 59 % de 30 A ; 37 % de 45 A | 12120 (76 % de 16000) | non (1,37×) | non |
| E-1100 | 4S1P sans bridage (THR_MAX 1) | 300 (fiche 205) | 19,5 | 19,4 | 13,0 A (essai de fiche, durée non publiée) / 14 A (15 s) | 65 % de 30 A ; 43 % de 45 A | 12683 (79 % de 16000) | non (1,49×) | non |


### Comparaison côte à côte F / E-1260 / E-1100 (ISA, CD0 0,030, masse avec groupe propulsif réel, cellules 69 g)

| Critère | F | E-1260 | E-1100 |
| --- | --- | --- | --- |
| Moteur, hélice 3S / 4S | X2212 980 KV, 8x6 / 8x6 | X2208 1260 KV, 8x6 / 8x6 | X2208 1100 KV, 8x6 / 8x6 |
| THR_MAX 3S / 4S (limite active) | 1,00 (aucune) / 0,84 (puissance) | 0,80 (puissance) / 0,59 (puissance) | 0,93 (puissance) / 0,69 (puissance) |
| Groupe propulsif [g] (budget 62 g) | 80 (+18) | 69 (+7) | 69 (+7) |
| Masse 4S1P, cellules 69 g (marge 800 g) | 814 (-14) | 803 (-3) | 803 (-3) |
| Masse 4S1P, cellules 70 g (marge) | 818 (-18) | 807 (-7) | 807 (-7) |
| Sans batterie (marge 520 g) | 526 (-6) | 515 (+5) | 515 (+5) |
| η 4S 40 / 4S 55 / 3S 55 km/h | 0,537 / 0,538 / 0,531 | 0,562 / 0,540 / 0,535 | 0,563 / 0,537 / 0,531 |
| V1-PERF-03 4S 55 km/h [min] (−30 % à −20 %) | 46 à 53 | 46 à 53 | 46 à 53 |
| V1-PERF-03, CD0 0,035, −30 % [min] | 43 | 43 | 42 |
| V1-PERF-04 4S 40 km/h [min] | 79 à 91 | 83 à 95 | 83 à 95 |
| V1-PERF-05 3S 55 km/h [min] | 35 à 40 | 35 à 40 | 35 à 40 |
| T/W ISA 3S / 4S | 0,76 / 0,86 | 0,69 / 0,63 | 0,68 / 0,62 |
| T/W jour chaud 3S / 4S | 0,70 / 0,80 | 0,65 / 0,59 | 0,64 / 0,59 |
| P max 3S / 4S [W] (V1-PROP-02 : 150-200 W) | 145 / 200 | 130 / 130 | 130 / 130 |
| Erreur : 4S avec le fichier 3S | 296 W, 19,1 A moteur (1,04× la référence continue, 0,74× la limite 30 s ; survit 10 s : oui) | 261 W, 20,9 A moteur (1,50× la référence continue, 1,39× la limite 30 s ; survit 10 s : non) | 260 W, 17,8 A moteur (1,37× la référence continue, 1,27× la limite 15 s ; survit 10 s : non) |
| Erreur : 4S sans bridage | 296 W, 19,1 A moteur (1,04× la référence continue, 0,74× la limite 30 s ; survit 10 s : oui) | 416 W, 27,8 A moteur (2,00× la référence continue, 1,85× la limite 30 s ; survit 10 s : non) | 300 W, 19,4 A moteur (1,49× la référence continue, 1,39× la limite 15 s ; survit 10 s : non) |
| Exigences à MOD | V1-MAS-01, V1-MAS-02, V1-PROP-02 si lue batterie par batterie (P max 3S < 150 W) | V1-MAS-01, V1-PROP-02 | V1-MAS-01, V1-PROP-02 |


### Option retenue, option banc et variantes (ISA, CD0 0,030, masse avec groupe propulsif réel)

| Option | Moteur, hélice 3S / 4S | THR_MAX 3S / 4S | η 4S 55 km/h | d croisière 4S ; régime | V1-PERF-03 [min] | V1-PERF-03, CD0 0,035, −30 % [min] | V1-PERF-04 [min] | V1-PERF-05 [min] | T/W jour chaud 3S / 4S | P max 3S / 4S [W] |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| F | X2212 980 KV, 8x6 / 8x6 | 1,00 / 0,84 | 0,538 (hélice 0,676) | 0,53 ; 7008 tr/min | 46,1 à 52,7 | 42,5 | 79 à 91 | 35 à 40 | 0,70 / 0,80 | 145 / 200 |
| G | X2212 980 KV, 8x6 / 7x6 | 1,00 / 0,99 | 0,621 (hélice 0,799) | 0,59 ; 7822 tr/min | 52,3 à 59,8 | 47,6 | 84 à 96 | 35 à 40 | 0,70 / 0,72 | 145 / 200 |
| F-8x5 | X2212 980 KV, 8x5 / 8x5 | 1,00 / 0,88 | 0,446 (hélice 0,554) | 0,61 ; 7963 tr/min | 39,0 à 44,6 | 36,4 | 70 à 80 | 29 à 34 | 0,68 / 0,84 | 131 / 200 |
| C | 2212 920 KV, 8.5x5 / 7x6 | 1,00 / 1,00 | 0,641 (hélice 0,799) | 0,62 ; 7822 tr/min | 53,8 à 61,5 | 48,8 | 87 à 100 | 27 à 31 | 0,73 / 0,66 | 133 / 174 |


### Option banc G : erreurs de fichier et de montage d'hélice (4S : batterie pleine, point fixe, ISA ; 3S : tension nominale, jour chaud)

| Cas | P batterie [W] | I moteur [A] | Régime [tr/min] | T/W au lancer, jour chaud | Survit 10 s plein gaz |
| --- | --- | --- | --- | --- | --- |
| 4S1P avec le fichier 3S (THR_MAX 1,00), 7x6 montée | 204 | 12,9 (0,70× continu ; 0,50× 30 s) | 14223 | — | oui |
| 4S1P avec le fichier 4S (THR_MAX 0,99), 8x6 restée montée | 290 | 18,9 (1,03× continu ; 0,73× 30 s) | 13146 | — | oui |
| 3S1P avec le fichier 3S, 7x6 restée montée | — | — | — | 0,47 (< 0,5 : V1-PERF-08 non tenue) | — |


### Groupe propulsif : référence vérifiée et alternatives propulsives (masses de fiche ; moteur 57 g)

| Hélice + moyeu | Type | Rotation | Pales [g] | Moyeu-cône / adaptateur [g] | Moteur + pales + moyeu [g] |
| --- | --- | --- | --- | --- | --- |
| CAM Carbon 8×6 (et 7×6) + moyeu-cône RFM 30 mm / 3,17 mm (référence) | repliable | droite (tractrice) | 9,0 | 14,0 | 80,0 (+18,0 / budget) |
| aero-naut 8×5 linkslaufend + cône CN 30/3,17 (8x5) | repliable | gauche (propulsive) | non publiée | non publiée | non calculable |
| APC 8x6EP (rigide) (8x6) | rigide | gauche (propulsive) | 13,9 | non publiée | ≥ 70,9 (moteur + pales, sans adaptateur) |
| APC 7x6EP (rigide) (7x6) | rigide | gauche (propulsive) | 7,9 | non publiée | ≥ 64,9 (moteur + pales, sans adaptateur) |


### Budget de masse réaffecté — option F, plan d'allègement (gain 18,7 g sur les postes remplacés)

| Poste | Groupe | Cahier [g] | Réaffecté [g] | Écart [g] | Pièce |
| --- | --- | --- | --- | --- | --- |
| Panneaux d'aile LW-PLA (2 demi-ailes) | structure | 190,0 | 190,0 | +0,0 | cahier |
| Fuselage central PLA/PETG + trappe | structure | 70,0 | 70,0 | +0,0 | cahier |
| Longeron carbone 8 mm + clé arrière 3 mm | structure | 30,0 | 30,0 | +0,0 | cahier |
| Winglets + élevons | structure | 30,0 | 30,0 | +0,0 | cahier |
| Moteur 2212 + hélice repliable + cône | systèmes | 62,0 | 80,0 | +18,0 | groupe propulsif réel (moteur de fiche + pales + moyeu-cône) |
| Câblage, connecteurs, velcro, PCB d'interconnexion | systèmes | 35,0 | 35,0 | +0,0 | cahier |
| Contrôleur de vol | systèmes | 25,0 | 14,3 | -10,7 | SpeedyBee F405 WING MINI (FC + PDB + carte sans fil) |
| Raspberry Pi Zero 2 W + Camera Module 3 + microSD | systèmes | 20,0 | 20,0 | +0,0 | cahier |
| 2 servos 9 g | systèmes | 18,0 | 18,0 | +0,0 | cahier |
| ESC 30 A | systèmes | 15,0 | 9,0 | -6,0 | Favourite LittleBee-S 30 A, avec fils |
| GPS M10 + compas | systèmes | 10,0 | 8,0 | -2,0 | Matek M10Q-5883 |
| Récepteur ELRS + antennes | systèmes | 3,0 | 3,0 | +0,0 | cahier |
| **Structure (cahier)** |  | 320 | 320 |  |  |
| **Systèmes** |  | 188 | 187,3 | -0,7 |  |
| **Sans batterie** |  | 508 | 507,3 | -0,7 | V1-MAS-02 : ≤ 520 g |
| **Total 4S1P, cellules 69 g** |  | 796 | 795,3 | -0,7 | V1-MAS-01 : ≤ 800 g |
| **Total 4S1P, cellules 70 g** |  | 800 | 799,3 | -0,7 | V1-MAS-01 : ≤ 800 g |
| **Total 3S1P, cellules 69 g** |  | 728 | 727,3 | -0,7 |  |


### Structure cible qui découle du budget réaffecté

| Structure max (4S1P ≤ 800 g, cellules 70 g) [g] | Structure max (V1-MAS-02) [g] | V1-MAS-03 [g] | Structure cible [g] | 4S1P cellules 70 g à la cible [g] (marge) | Sans batterie à la cible [g] (marge) | MOD-03 nécessaire |
| --- | --- | --- | --- | --- | --- | --- |
| 320,7 | 332,7 | 320 | 320 | 799,3 (+0,7) | 507,3 (+12,7) | non |


### Réserve et RTL

| Fraction utilisable | Réserve | Capacité nominale restante en fin de mission | RTL du cahier |
| --- | --- | --- | --- |
| 0,85 | 0,20 | 32 % | 30 % |

