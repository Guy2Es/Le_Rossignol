# MOD-05 — V1-STAB-03 (BROUILLON du 13/10/2026, non validée, non appliquée)

Le cahier des charges n'est pas modifié. Ce brouillon est rédigé à la demande de Guilhem (arrêt B, 13/10/2026). Il proposait d'abord ± 18 mm ; Guilhem l'a élargi le même jour à **± 20 mm**, parce qu'une marge de 0,2 mm (point neutre visqueux) ne survivrait pas aux pesées.

Numérotation : MOD-04 est validée (V1-STAB-01). Le dossier de la phase 3 (§8) cite une MOD éventuelle sur V1-MAS-03 sous le nom « MOD-04 », jamais rédigée. Si elle devient nécessaire, elle prendra le numéro **MOD-06**.

| Champ | Contenu |
| --- | --- |
| Date | 13/10/2026 (brouillon) |
| Exigence | V1-STAB-03 : plage de réglage du CG par la batterie ; obligatoire ; D4, deux batteries de masses différentes ; vérification : CAO en phase 5, centrage en phase 8 |
| Ancienne valeur | « ± 15 mm, en 3S1P et en 4S1P » |
| Nouvelle valeur | **± 20 mm, en 3S1P et en 4S1P** (soit un écart de 40 mm au plus entre les positions des deux batteries). Le reste de la ligne est inchangé |
| Justification | La valeur de ± 15 mm n'avait pas de base physique (Guilhem). ± 20 mm plutôt que ± 18 mm : garder quelques millimètres pour les pesées et le foyer réel, sans rouvrir la MOD à chaque correction (Guilhem). L'écart entre les deux positions est fixé par les masses : écart = k·(x0 − x_CG), avec x0 le CG sans batterie (215,0 mm) et k = 0,535. Avec le point neutre xflr5, cet écart vaut de 31,1 à 34,4 mm sur les 6 variantes de l'étape 2. **Aucun déplacement de masse** n'est retenu pour le réduire (décision de Guilhem) |
| Statut | **BROUILLON.** À valider ou rejeter par Guilhem |

## Vérification chiffrée (stabilite.m §7 et §8, tableaux dans `tableaux_auto.md`)

| Point neutre utilisé | Écart 3S/4S à MS 8 % | Écart à MS 10 % | Marge sous 40 mm |
| --- | --- | --- | --- |
| VLM non visqueuse, pente de Cm (6 variantes) | 31,1 à 31,7 mm | 33,8 à 34,4 mm | 5,6 mm au plus juste |
| VLM non visqueuse, pente de XCP·CL | — | — | 6,7 mm au plus juste |
| S5010 avec la correction visqueuse en bandes (section C) : point neutre avancé de 2,6 à 2,7 mm (174,8 / 174,1 / 173,8 mm pour −3 / −5 / −7°) | 32,5 à 33,0 mm | 35,2 à 35,8 mm | 4,2 à 4,8 mm |

- **Avec le point neutre non visqueux**, la nouvelle valeur est tenue par les 6 variantes.
- **Avec la correction visqueuse en bandes** (estimation hors skill, voir la MOD-04 et la section C), la nouvelle valeur reste tenue pour le S5010, avec 4,2 à 4,8 mm de marge à MS 10 %. Cette correction attend encore le verdict de la section C2 (double comptage possible avec xflr5).
- **Sensibilité :** chaque millimètre de recul de x0 (masses réelles en phase 5, pesées en phase 8) ajoute environ 0,54 mm à l'écart. Le CG sans batterie dépend de positions qui sont encore toutes des hypothèses.

## Conséquence à passer à la phase 5 (contrainte d'encombrement)

À MS 10 %, la batterie 3S1P se centre très en avant. La batterie est supposée longue de 70 mm selon x, cellules couchées dans l'axe (valeur de Guilhem) :

| Point neutre | Centre de la 3S1P (S5010, −3 à −7°) | Avant de la batterie | Raspberry Pi + caméra (hypothèse de position) |
| --- | --- | --- | --- |
| non visqueux | 8,8 à 5,2 mm du BA de l'emplanture | −26,2 à −29,8 mm | −30 mm |
| visqueux (bandes) | 0,1 à −3,3 mm | −34,9 à −38,3 mm | −30 mm |

La batterie et le Pi avec sa caméra se disputent donc le nez de la nacelle. **C'est la vraie contrainte pour la phase 5, plus que le chiffre de la plage** (Guilhem). Ce conflit est à lever en CAO, sans toucher aux masses (décision du 13/10/2026). La liste complète est dans `contraintes_phase5.md`.
