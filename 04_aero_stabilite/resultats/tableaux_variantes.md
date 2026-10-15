# Phase 4 — élevons agrandis : estimation sans manip xflr5 (généré par elevons_variantes.m)

Critères du 15/10/2026 (utilisateur, hors cahier) : croisière de 40 à 55 km/h, δ_trim de -10 à +0° en 3S1P et 4S1P à MS 8, 9, 10 % ; autorité : équilibre au CLmax équilibré (bande critique) à MS 10 %, au plus 20° vers le haut. Modèle du verdict : « complet ». ESTIMATION, HORS SKILL : VLM des T2 mise à l'échelle (profils minces), prolongement par Weissinger recalé, polaires à volet de la charnière à 75 % empruntées (η identique à braquage égal).

### §1 : Weissinger recalé sur la VLM de xflr5

| Grandeur | Weissinger | xflr5 (§11) |
| --- | --- | --- |
| x_NP [mm] | 176,8 | 176,4 à 177,5 |
| Moment de portance des élevons des T2 à CL constant [/°] | -0,00198 | -0,00231 |
| Recalage κ (appliqué au prolongement) | 1,168 | — |
| Écart de forme des Cl recalés, hors bandes de transition (part du maximum) | 9 % | — |


### §2 : efficacité des variantes à 45 km/h, 4S1P, MS 9 %, vrillage -5°

| Variante | Corde des élevons | Envergure (demi-aile) [mm] | Profils minces / T2 : τ / moment de section | Cm_δ VLM linéaire : portance + section [/°] | Cm_δ à l'équilibre : VLM / bandes / complet [/°] | Gain sur les T2 | η_α / η_m (polaires empruntées) | δ_trim (complet) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| T2 (25 %) | 25 % (charnière 0,75) | 250 à 500 | 1,000 / 1,000 | -0,00231 + -0,00357 = -0,00588 | -0,00606 / -0,00522 / -0,00394 | +0 / +0 / +0 % | 0,68 / 0,66 | -10,2° |
| 30 % | 30 % (charnière 0,70) | 250 à 500 | 1,085 / 0,988 | -0,00251 + -0,00352 = -0,00603 | -0,00625 / -0,00552 / -0,00411 | +3 / +6 / +4 % | 0,68 / 0,66 | -9,8° |
| 35 % | 35 % (charnière 0,65) | 250 à 500 | 1,160 / 0,955 | -0,00268 + -0,00340 = -0,00609 | -0,00636 / -0,00575 / -0,00423 | +5 / +10 / +7 % | 0,68 / 0,66 | -9,6° |
| 35 % prolongés | 35 % (charnière 0,65) | 200 à 500 | 1,160 / 0,955 | -0,00265 + -0,00437 = -0,00702 | -0,00721 / -0,00614 / -0,00465 | +19 / +17 / +18 % | 0,69 / 0,66 | -8,5° |


### §3 : ordres de grandeur du raisonnement du 15/10/2026, recalculés

| Grandeur | Valeur MATLAB |
| --- | --- |
| Amplitude de δ_trim de 35 à 55 km/h (ancien critère ; 4S1P, MS 10 %, -5°, élevons des T2) | 8,6° |
| MS·ΔCL/|Cm_δ| (même cas, Cm_δ complet à 45 km/h) | 0,10 × 0,321 / 0,0040 = 8,0° |
| ΔCm cabreur requis à CL = 0,8 (4S1P, MS 10 %, 28,8 km/h) | 0,0886 |
| δ_trim à CL = 0,8 : VLM / bandes / complet (élevons des T2) | -11,2 / -17,9 / -24,9° |
| 1 % de MS | 2,57 mm |
| ±3 mm de centrage | ±1,17 % de MS |
| Élevons à 35 % contre 25 % (profils minces) : efficacité de portance τ | +16,0 % |
| Idem : moment de section au quart avant | -4,5 % (maximal à 25 % de corde) |
| CLmax de l'aile lisse (bande critique, δ = 0, vrillages −3 à −7°) | 1,159 à 1,167 |
| Vitesse de décrochage de l'aile lisse à ce CLmax (3S1P à 4S1P) | 22,8 à 23,9 km/h |


### §4 : croisière, δ_trim [°] de 40 à 55 km/h (3S1P / 4S1P ; critère : -10 à +0° à MS 8, 9 et 10 %)

| Variante | Vrillage | MS 8 % | MS 9 % | MS 10 % | Critère | VLM seule (MS 10 % 4S1P à MS 8 % 3S1P) | MS 7 % (premier vol 7–9 %) | Points au-delà de -9° (MS 8–10 %) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| T2 (25 %) | -3° (MOD-04 non tenue) | -11,5 à -7,6 / -12,2 à -8,0 | -12,4 à -8,1 / -13,2 à -8,5 | -13,4 à -8,6 / -14,2 à -9,1 | **non tenu** | -5,8 à -1,7 | -10,6 à -7,1 / -11,2 à -7,4 (7–9 % non tenu) | 72 |
| T2 (25 %) | -4° | -11,1 à -7,1 / -11,8 à -7,5 | -12,0 à -7,7 / -12,8 à -8,1 | -12,9 à -8,2 / -13,8 à -8,6 | **non tenu** | -5,5 à -1,4 | -10,1 à -6,6 / -10,7 à -6,9 (7–9 % non tenu) | 61 |
| T2 (25 %) | -5° | -10,6 à -6,7 / -11,3 à -7,0 | -11,5 à -7,2 / -12,3 à -7,6 | -12,5 à -7,7 / -13,4 à -8,2 | **non tenu** | -5,3 à -1,0 | -9,6 à -6,1 / -10,2 à -6,4 (7–9 % non tenu) | 50 |
| T2 (25 %) | -6° | -10,1 à -6,2 / -10,8 à -6,5 | -11,1 à -6,7 / -11,9 à -7,1 | -12,0 à -7,2 / -12,9 à -7,7 | **non tenu** | -5,0 à -0,7 | -9,1 à -5,6 / -9,7 à -5,9 (7–9 % non tenu) | 40 |
| T2 (25 %) | -7° | -9,6 à -5,7 / -10,3 à -6,0 | -10,6 à -6,2 / -11,4 à -6,6 | -11,5 à -6,7 / -12,4 à -7,2 | **non tenu** | -4,6 à -0,3 | -8,6 à -5,1 / -9,2 à -5,4 (7–9 % non tenu) | 32 |
| 30 % | -3° (MOD-04 non tenue) | -11,1 à -7,3 / -11,7 à -7,7 | -12,0 à -7,8 / -12,7 à -8,2 | -12,9 à -8,3 / -13,7 à -8,8 | **non tenu** | -5,6 à -1,6 | -10,2 à -6,8 / -10,7 à -7,1 (7–9 % non tenu) | 64 |
| 30 % | -4° | -10,6 à -6,9 / -11,3 à -7,2 | -11,5 à -7,4 / -12,3 à -7,8 | -12,4 à -7,9 / -13,3 à -8,3 | **non tenu** | -5,4 à -1,3 | -9,7 à -6,4 / -10,3 à -6,7 (7–9 % non tenu) | 52 |
| 30 % | -5° | -10,2 à -6,5 / -10,9 à -6,8 | -11,1 à -7,0 / -11,9 à -7,3 | -12,0 à -7,5 / -12,8 à -7,9 | **non tenu** | -5,1 à -1,0 | -9,3 à -5,9 / -9,9 à -6,2 (7–9 % non tenu) | 44 |
| 30 % | -6° | -9,7 à -6,0 / -10,4 à -6,3 | -10,7 à -6,5 / -11,4 à -6,9 | -11,6 à -7,0 / -12,4 à -7,4 | **non tenu** | -4,8 à -0,7 | -8,8 à -5,5 / -9,4 à -5,8 (7–9 % non tenu) | 34 |
| 30 % | -7° | -9,3 à -5,5 / -9,9 à -5,8 | -10,2 à -6,0 / -11,0 à -6,4 | -11,1 à -6,5 / -12,0 à -7,0 | **non tenu** | -4,5 à -0,3 | -8,3 à -5,0 / -8,9 à -5,3 (7–9 % non tenu) | 26 |
| 35 % | -3° (MOD-04 non tenue) | -10,8 à -7,2 / -11,5 à -7,5 | -11,7 à -7,7 / -12,4 à -8,1 | -12,6 à -8,2 / -13,4 à -8,6 | **non tenu** | -5,6 à -1,6 | -9,9 à -6,7 / -10,5 à -7,0 (7–9 % non tenu) | 58 |
| 35 % | -4° | -10,4 à -6,8 / -11,1 à -7,1 | -11,3 à -7,3 / -12,0 à -7,6 | -12,2 à -7,8 / -13,0 à -8,2 | **non tenu** | -5,3 à -1,3 | -9,5 à -6,3 / -10,1 à -6,6 (7–9 % non tenu) | 50 |
| 35 % | -5° | -10,0 à -6,3 / -10,6 à -6,7 | -10,9 à -6,8 / -11,6 à -7,2 | -11,7 à -7,3 / -12,6 à -7,8 | **non tenu** | -5,0 à -1,0 | -9,1 à -5,8 / -9,6 à -6,1 (7–9 % non tenu) | 40 |
| 35 % | -6° | -9,5 à -5,9 / -10,2 à -6,2 | -10,4 à -6,4 / -11,2 à -6,8 | -11,3 à -6,9 / -12,1 à -7,3 | **non tenu** | -4,7 à -0,7 | -8,6 à -5,4 / -9,2 à -5,7 (7–9 % non tenu) | 31 |
| 35 % | -7° | -9,1 à -5,4 / -9,7 à -5,7 | -10,0 à -5,9 / -10,7 à -6,3 | -10,9 à -6,4 / -11,7 à -6,8 | **non tenu** | -4,5 à -0,3 | -8,1 à -4,9 / -8,7 à -5,2 (7–9 % non tenu) | 23 |
| 35 % prolongés | -3° (MOD-04 non tenue) | -9,6 à -6,3 / -10,1 à -6,6 | -10,4 à -6,7 / -11,0 à -7,1 | -11,1 à -7,1 / -11,9 à -7,5 | **non tenu** | -4,9 à -1,4 | -8,7 à -5,9 / -9,3 à -6,1 (7–9 % non tenu) | 33 |
| 35 % prolongés | -4° | -9,2 à -5,9 / -9,8 à -6,2 | -10,0 à -6,3 / -10,6 à -6,7 | -10,8 à -6,8 / -11,5 à -7,1 | **non tenu** | -4,6 à -1,1 | -8,3 à -5,5 / -8,9 à -5,7 (7–9 % non tenu) | 24 |
| 35 % prolongés | -5° | -8,8 à -5,5 / -9,4 à -5,8 | -9,6 à -5,9 / -10,3 à -6,3 | -10,4 à -6,4 / -11,1 à -6,7 | **non tenu** | -4,4 à -0,9 | -7,9 à -5,1 / -8,5 à -5,3 (7–9 % non tenu) | 17 |
| 35 % prolongés | -6° | -8,4 à -5,1 / -9,0 à -5,4 | -9,2 à -5,5 / -9,9 à -5,9 | -10,0 à -6,0 / -10,7 à -6,3 | **non tenu** | -4,2 à -0,6 | -7,5 à -4,7 / -8,0 à -4,9 (7–9 % tenu) | 12 |
| 35 % prolongés | -7° | -7,9 à -4,7 / -8,5 à -5,0 | -8,8 à -5,1 / -9,4 à -5,5 | -9,6 à -5,6 / -10,3 à -5,9 | **non tenu** | -3,9 à -0,3 | -7,1 à -4,3 / -7,6 à -4,5 (7–9 % tenu) | 8 |


### §5 : autorité, MS 10 % (3S1P / 4S1P) : plus grand CL équilibré avec au plus 20° vers le haut ; limite « bande » = décrochage d'une bande atteint (critère tenu), « braquage » = butée atteinte avant (non tenu), « polaires » = hors des polaires

| Variante | Vrillage | CL atteint (limite) ; V ; δ | Critère | δ_trim à CL = 0,8 (hypothèse phase 3) | Bande de marge minimale |y| [mm] | MS 9 % (premier vol 7–9 %) |
| --- | --- | --- | --- | --- | --- | --- |
| T2 (25 %) | -3° (MOD-04 non tenue) | 0,622 / 0,625 (braquage / braquage) ; 31,2 / 32,5 km/h ; δ -20,0 / -20,0° | **non tenu** | -25,9 / -25,8° | 140 / 140 ; au-delà des polaires à volet | 0,675 / 0,679 (braquage / braquage) ; 29,9 / 31,2 km/h ; δ -20,0 / -20,0° (non tenu) |
| T2 (25 %) | -4° | 0,636 / 0,639 (braquage / braquage) ; 30,8 / 32,2 km/h ; δ -20,0 / -20,0° | **non tenu** | -25,5 / -25,3° | 140 / 140 ; au-delà des polaires à volet | 0,690 / 0,694 (braquage / braquage) ; 29,6 / 30,9 km/h ; δ -20,0 / -20,0° (non tenu) |
| T2 (25 %) | -5° | 0,650 / 0,654 (braquage / braquage) ; 30,5 / 31,8 km/h ; δ -20,0 / -20,0° | **non tenu** | -25,0 / -24,9° | 140 / 140 ; au-delà des polaires à volet | 0,705 / 0,709 (braquage / braquage) ; 29,3 / 30,6 km/h ; δ -20,0 / -20,0° (non tenu) |
| T2 (25 %) | -6° | 0,664 / 0,668 (braquage / braquage) ; 30,2 / 31,5 km/h ; δ -20,0 / -20,0° | **non tenu** | -24,6 / -24,4° | 140 / 140 ; au-delà des polaires à volet | 0,720 / 0,724 (braquage / braquage) ; 29,0 / 30,2 km/h ; δ -20,0 / -20,0° (non tenu) |
| T2 (25 %) | -7° | 0,678 / 0,683 (braquage / braquage) ; 29,8 / 31,1 km/h ; δ -20,0 / -20,0° | **non tenu** | -24,1 / -23,9° | 108 / 108 ; au-delà des polaires à volet | 0,735 / 0,740 (braquage / braquage) ; 28,7 / 29,9 km/h ; δ -20,0 / -20,0° (non tenu) |
| 30 % | -3° (MOD-04 non tenue) | 0,653 / 0,656 (braquage / braquage) ; 30,4 / 31,7 km/h ; δ -20,0 / -20,0° | **non tenu** | -24,7 / -24,5° | 254 / 140 ; au-delà des polaires à volet | 0,707 / 0,711 (braquage / braquage) ; 29,2 / 30,5 km/h ; δ -20,0 / -20,0° (non tenu) |
| 30 % | -4° | 0,666 / 0,670 (braquage / braquage) ; 30,1 / 31,4 km/h ; δ -20,0 / -20,0° | **non tenu** | -24,2 / -24,1° | 140 / 140 ; au-delà des polaires à volet | 0,721 / 0,725 (braquage / braquage) ; 29,0 / 30,2 km/h ; δ -20,0 / -20,0° (non tenu) |
| 30 % | -5° | 0,680 / 0,684 (braquage / braquage) ; 29,8 / 31,1 km/h ; δ -20,0 / -20,0° | **non tenu** | -23,8 / -23,7° | 140 / 140 ; au-delà des polaires à volet | 0,735 / 0,740 (braquage / braquage) ; 28,7 / 29,9 km/h ; δ -20,0 / -20,0° (non tenu) |
| 30 % | -6° | 0,694 / 0,698 (braquage / braquage) ; 29,5 / 30,8 km/h ; δ -20,0 / -20,0° | **non tenu** | -23,4 / -23,2° | 140 / 140 ; au-delà des polaires à volet | 0,750 / 0,754 (braquage / braquage) ; 28,4 / 29,6 km/h ; δ -20,0 / -20,0° (non tenu) |
| 30 % | -7° | 0,708 / 0,712 (braquage / braquage) ; 29,2 / 30,5 km/h ; δ -20,0 / -20,0° | **non tenu** | -23,0 / -22,8° | 108 / 108 ; au-delà des polaires à volet | 0,765 / 0,769 (braquage / braquage) ; 28,1 / 29,3 km/h ; δ -20,0 / -20,0° (non tenu) |
| 35 % | -3° (MOD-04 non tenue) | 0,674 / 0,678 (braquage / braquage) ; 30,0 / 31,3 km/h ; δ -20,0 / -20,0° | **non tenu** | -23,8 / -23,7° | 254 / 140 ; au-delà des polaires à volet | 0,729 / 0,733 (braquage / braquage) ; 28,8 / 30,0 km/h ; δ -20,0 / -20,0° (non tenu) |
| 35 % | -4° | 0,687 / 0,691 (braquage / braquage) ; 29,7 / 30,9 km/h ; δ -20,0 / -20,0° | **non tenu** | -23,4 / -23,3° | 254 / 140 ; au-delà des polaires à volet | 0,743 / 0,747 (braquage / braquage) ; 28,5 / 29,8 km/h ; δ -20,0 / -20,0° (non tenu) |
| 35 % | -5° | 0,700 / 0,704 (braquage / braquage) ; 29,4 / 30,6 km/h ; δ -20,0 / -20,0° | **non tenu** | -23,0 / -22,9° | 254 / 140 ; au-delà des polaires à volet | 0,757 / 0,761 (braquage / braquage) ; 28,3 / 29,5 km/h ; δ -20,0 / -20,0° (non tenu) |
| 35 % | -6° | 0,714 / 0,718 (braquage / braquage) ; 29,1 / 30,4 km/h ; δ -20,0 / -20,0° | **non tenu** | -22,6 / -22,5° | 140 / 140 ; au-delà des polaires à volet | 0,771 / 0,775 (braquage / braquage) ; 28,0 / 29,2 km/h ; δ -20,0 / -20,0° (non tenu) |
| 35 % | -7° | 0,728 / 0,732 (braquage / braquage) ; 28,8 / 30,1 km/h ; δ -20,0 / -20,0° | **non tenu** | -22,2 / -22,1° | 108 / 108 ; au-delà des polaires à volet | 0,785 / 0,790 (braquage / braquage) ; 27,7 / 28,9 km/h ; δ -20,0 / -20,0° (non tenu) |
| 35 % prolongés | -3° (MOD-04 non tenue) | 0,735 / 0,738 (braquage / braquage) ; 28,7 / 29,9 km/h ; δ -20,0 / -20,0° | **non tenu** | -22,2 / -22,1° | 199 / 199 ; au-delà des polaires à volet | 0,785 / 0,788 (braquage / braquage) ; 27,7 / 29,0 km/h ; δ -20,0 / -20,0° (non tenu) |
| 35 % prolongés | -4° | 0,746 / 0,750 (braquage / braquage) ; 28,5 / 29,7 km/h ; δ -20,0 / -20,0° | **non tenu** | -21,8 / -21,7° | 199 / 199 ; au-delà des polaires à volet | 0,797 / 0,800 (braquage / braquage) ; 27,5 / 28,8 km/h ; δ -20,0 / -20,0° (non tenu) |
| 35 % prolongés | -5° | 0,758 / 0,761 (braquage / braquage) ; 28,2 / 29,5 km/h ; δ -20,0 / -20,0° | **non tenu** | -21,5 / -21,3° | 199 / 199 ; au-delà des polaires à volet | 0,809 / 0,812 (braquage / braquage) ; 27,3 / 28,5 km/h ; δ -20,0 / -20,0° (non tenu) |
| 35 % prolongés | -6° | 0,770 / 0,773 (braquage / braquage) ; 28,0 / 29,3 km/h ; δ -20,0 / -20,0° | **non tenu** | -21,1 / -20,9° | 199 / 199 ; au-delà des polaires à volet | 0,822 / 0,824 (braquage / braquage) ; 27,1 / 28,3 km/h ; δ -20,0 / -20,0° (non tenu) |
| 35 % prolongés | -7° | 0,782 / 0,785 (braquage / braquage) ; 27,8 / 29,0 km/h ; δ -20,0 / -20,0° | **non tenu** | -20,6 / -20,5° | 199 / 199 ; au-delà des polaires à volet | 0,834 / 0,837 (braquage / braquage) ; 26,9 / 28,1 km/h ; δ -20,0 / -20,0° (non tenu) |


### §6 : synthèse, vrillages qui passent (grille de 0,25° ; MOD-04 en visqueux comprise, limite -3,32°)

| Variante | Croisière (MS 8–10 %) | Autorité (MS 10 %) | Les deux | Les deux avec MS de premier vol 7–9 % (autorité à 9 %) |
| --- | --- | --- | --- | --- |
| T2 (25 %) | aucun | aucun | **aucun** | aucun |
| 30 % | aucun | aucun | **aucun** | aucun |
| 35 % | aucun | aucun | **aucun** | aucun |
| 35 % prolongés | aucun | aucun | **aucun** | aucun |


### §7 : effet d'une MS de premier vol de 7–9 % au lieu de 8–10 % (pas de MOD sur V1-STAB-02 sans accord ; autorité à MS 9 % au lieu de 10 %)

| Variante | Vrillage | Fenêtre de croisière requise : MS 8–10 % → 7–9 % | Croisière | CL équilibré avec 20° (4S1P) : MS 10 % → 9 % | δ_trim à CL = 0,8 (4S1P) : MS 10 % → 9 % |
| --- | --- | --- | --- | --- | --- |
| T2 (25 %) | -3° (MOD-04 non tenue) | -14,2 à -7,6° → -13,2 à -7,1° | non tenu → non tenu | 0,625 (32,5 km/h) → 0,679 (31,2 km/h) | -25,8 → -23,9° |
| T2 (25 %) | -4° | -13,8 à -7,1° → -12,8 à -6,6° | non tenu → non tenu | 0,639 (32,2 km/h) → 0,694 (30,9 km/h) | -25,3 → -23,4° |
| T2 (25 %) | -5° | -13,4 à -6,7° → -12,3 à -6,1° | non tenu → non tenu | 0,654 (31,8 km/h) → 0,709 (30,6 km/h) | -24,9 → -22,9° |
| T2 (25 %) | -6° | -12,9 à -6,2° → -11,9 à -5,6° | non tenu → non tenu | 0,668 (31,5 km/h) → 0,724 (30,2 km/h) | -24,4 → -22,5° |
| T2 (25 %) | -7° | -12,4 à -5,7° → -11,4 à -5,1° | non tenu → non tenu | 0,683 (31,1 km/h) → 0,740 (29,9 km/h) | -23,9 → -22,0° |
| 30 % | -3° (MOD-04 non tenue) | -13,7 à -7,3° → -12,7 à -6,8° | non tenu → non tenu | 0,656 (31,7 km/h) → 0,711 (30,5 km/h) | -24,5 → -22,7° |
| 30 % | -4° | -13,3 à -6,9° → -12,3 à -6,4° | non tenu → non tenu | 0,670 (31,4 km/h) → 0,725 (30,2 km/h) | -24,1 → -22,3° |
| 30 % | -5° | -12,8 à -6,5° → -11,9 à -5,9° | non tenu → non tenu | 0,684 (31,1 km/h) → 0,740 (29,9 km/h) | -23,7 → -21,9° |
| 30 % | -6° | -12,4 à -6,0° → -11,4 à -5,5° | non tenu → non tenu | 0,698 (30,8 km/h) → 0,754 (29,6 km/h) | -23,2 → -21,4° |
| 30 % | -7° | -12,0 à -5,5° → -11,0 à -5,0° | non tenu → non tenu | 0,712 (30,5 km/h) → 0,769 (29,3 km/h) | -22,8 → -20,9° |
| 35 % | -3° (MOD-04 non tenue) | -13,4 à -7,2° → -12,4 à -6,7° | non tenu → non tenu | 0,678 (31,3 km/h) → 0,733 (30,0 km/h) | -23,7 → -22,0° |
| 35 % | -4° | -13,0 à -6,8° → -12,0 à -6,3° | non tenu → non tenu | 0,691 (30,9 km/h) → 0,747 (29,8 km/h) | -23,3 → -21,6° |
| 35 % | -5° | -12,6 à -6,3° → -11,6 à -5,8° | non tenu → non tenu | 0,704 (30,6 km/h) → 0,761 (29,5 km/h) | -22,9 → -21,2° |
| 35 % | -6° | -12,1 à -5,9° → -11,2 à -5,4° | non tenu → non tenu | 0,718 (30,4 km/h) → 0,775 (29,2 km/h) | -22,5 → -20,7° |
| 35 % | -7° | -11,7 à -5,4° → -10,7 à -4,9° | non tenu → non tenu | 0,732 (30,1 km/h) → 0,790 (28,9 km/h) | -22,1 → -20,3° |
| 35 % prolongés | -3° (MOD-04 non tenue) | -11,9 à -6,3° → -11,0 à -5,9° | non tenu → non tenu | 0,738 (29,9 km/h) → 0,788 (29,0 km/h) | -22,1 → -20,4° |
| 35 % prolongés | -4° | -11,5 à -5,9° → -10,6 à -5,5° | non tenu → non tenu | 0,750 (29,7 km/h) → 0,800 (28,8 km/h) | -21,7 → -20,0° |
| 35 % prolongés | -5° | -11,1 à -5,5° → -10,3 à -5,1° | non tenu → non tenu | 0,761 (29,5 km/h) → 0,812 (28,5 km/h) | -21,3 → -19,6° |
| 35 % prolongés | -6° | -10,7 à -5,1° → -9,9 à -4,7° | non tenu → **tenu** | 0,773 (29,3 km/h) → 0,824 (28,3 km/h) | -20,9 → -19,2° |
| 35 % prolongés | -7° | -10,3 à -4,7° → -9,4 à -4,3° | non tenu → **tenu** | 0,785 (29,0 km/h) → 0,837 (28,1 km/h) | -20,5 → -18,7° |

