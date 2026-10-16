# Phase 4 — clôture (généré par cloture_phase4.m)

Géométrie retenue : vrillage -3,50° (règle E4), élevons 35 % depuis y = 200 mm, charnière à 65 % de corde.

### T2 de contrôle (VLM non visqueuse, 4S1P, CG x = 156,5 mm)

- `V1_S5010_vr35_c65_e0` : δ = +0°
- `V1_S5010_vr35_c65_e6` : δ = -6°


### Vitesse d'équilibre [km/h] par profil c65 braqué (✓ : dans 40 à 55 km/h ; CG à x_NP visqueux − MS·MAC)

| Cas | Modèle | δ -3° | δ -6° | δ -9° | δ -12° |
| --- | --- | --- | --- | --- | --- |
| 3S1P, MS 8 % | xflr5 (VLM seule) | 43,9 ✓ | 32,8 | — | — |
| 3S1P, MS 8 % | avion réel (complet) | 68,6 | 43,1 ✓ | 31,9 | — |
| 3S1P, MS 10 % | xflr5 (VLM seule) | 48,5 ✓ | 36,2 | — | — |
| 3S1P, MS 10 % | avion réel (complet) | — | 45,6 ✓ | 34,2 | — |
| 4S1P, MS 8 % | xflr5 (VLM seule) | 45,9 ✓ | 34,3 | — | — |
| 4S1P, MS 8 % | avion réel (complet) | — | 44,2 ✓ | 32,8 | — |
| 4S1P, MS 10 % | xflr5 (VLM seule) | 50,7 ✓ | 37,8 | 31,2 | — |
| 4S1P, MS 10 % | avion réel (complet) | — | 46,9 ✓ | 35,2 | — |


xflr5 équilibre le T7 sur son Cm VLM, sans la correction visqueuse en bandes (contrôle C2) : la ligne « xflr5 » est la vitesse à laquelle il calculera les modes ; la ligne « avion réel » est celle de l'avion au même braquage.
