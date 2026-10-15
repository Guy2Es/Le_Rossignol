# Contraintes passées par la phase 4 à la phase 5 (CAO)

Liste tenue à jour pendant la phase 4. Les chiffres viennent de `stabilite.m` (voir `tableaux_auto.md`).

| N° | Date | Contrainte | Origine |
| --- | --- | --- | --- |
| P5-01 | 13/10/2026 | **Nez de la nacelle :** à MS 10 %, la batterie 3S1P (70 mm selon x) se centre entre +8,8 et +5,2 mm du BA de l'emplanture. Son avant arrive entre −26,2 et −29,8 mm, au même endroit que le Raspberry Pi + caméra (−30 mm). Avec le point neutre corrigé de la viscosité, l'avant recule jusqu'à −34,9 à −38,3 mm. Conflit à lever sans déplacer de masse | MOD-05 (brouillon), décision de Guilhem |
| P5-02 | 13/10/2026 | **ESC et câblage + PCB à 130 mm,** au même endroit que le fuselage (130 mm) et près du contrôleur de vol (120 mm). Les fils de phase du moteur s'allongent d'autant | Arrêt A |
| P5-03 | 13/10/2026 | **Garde de l'hélice :** 22,0 mm à y = ±100 mm et 21,7 mm sur le disque, avec les élevons au neutre et sans compter le moyeu. Les élevons relevés et le moyeu sont à vérifier | Arrêt A, `garde_helice.m` |
| P5-04 | 13/10/2026 | **Débattement des élevons à cabrer :** au moins le braquage d'équilibre à 35 km/h plus 10° (critère provisoire de Guilhem). Le braquage d'équilibre sort de l'étape 3 | Arrêt B |
| P5-05 | 13/10/2026 | **Masses réelles :** chaque millimètre de recul du CG sans batterie ajoute environ 0,54 mm à l'écart 3S/4S. La MOD-05 (± 20 mm, brouillon) garde 4,2 à 4,8 mm de marge avec le point neutre corrigé de la viscosité (5,6 mm au moins sans correction) | MOD-05 (brouillon) |
