# Fiche de gel V1 — clôture de la phase 4 (générée par fiche_gel_phase4.m, 16/10/2026)

Écart à la skill : modèles hors skill (VLM xflr5, bandes, profils minces, Weissinger). Le cahier des charges n'est pas modifié ; les MOD restent en brouillon sauf MOD-04.

## 1. Géométrie gelée

| Paramètre | Valeur |
| --- | --- |
| Envergure / surface / MAC | 1,000 m / 0,2500 m² / 256,5 mm |
| Flèche du bord d'attaque | 27° |
| Profil | S5010 |
| Vrillage au saumon (règle E4, MOD-04) | -3,50° |
| Élevons | 35 % depuis y = 200 mm ; 35 % de corde depuis y = 200 mm |
| x_NP visqueux (correction en bandes) | 174,7 mm |
| CG sans batterie | 215,0 mm |

## 2. Masses, CG et position de la batterie (CG = x_NP visqueux − MS·MAC ; repère du BA de l'emplanture)


### Centrage

| Batterie | MS [%] | Masse [g] | x_CG [mm] | x batterie [mm] | x_NP − x_CG [mm] |
| --- | --- | --- | --- | --- | --- |
| 3S1P | 8 | 728,2 | 154,2 | 16,5 | 20,5 |
| 3S1P | 9 | 728,2 | 151,6 | 8,2 | 23,1 |
| 3S1P | 10 | 728,2 | 149,1 | -0,2 | 25,7 |
| 4S1P | 8 | 797,2 | 154,2 | 49,1 | 20,5 |
| 4S1P | 9 | 797,2 | 151,6 | 42,1 | 23,1 |
| 4S1P | 10 | 797,2 | 149,1 | 35,1 | 25,7 |


Écart des positions de batterie 3S/4S : 32,5 / 33,9 / 35,3 mm à MS 8 / 9 / 10 % (écart total admis : 30 mm pour V1-STAB-03 de ± 15 mm, 40 mm pour MOD-05 en brouillon de ± 20 mm).

## 3. Contrôle T2 de clôture (xflr5 contre modèle « vlm »)

Voir `tableaux_controle_T2.md` : l'incrément de Cm dû à 6° d'élevons concorde à 0,5–1,0 % près ; le modèle « vlm » reproduit xflr5.

## 4. État des exigences

| Exigence | État | Remarque |
| --- | --- | --- |
| V1-STAB-01 | MOD-04 validée | Cm(CL = 0) de l'aile complète |
| V1-STAB-02 | 8 à 10 % | inchangée, aucune MOD |
| V1-STAB-03 | MOD-05 en brouillon | écart ci-dessus |
| V1-STAB-04 | **OUVERTE** | T7 non lancé : profil à braquer en attente de décision |

Cm_δ incertain d'un facteur 2 (polaires XFoil à charnière 65 % et 75 %, bulle de décollement) : à ne pas utiliser pour régler les gains sans essai en vol.
