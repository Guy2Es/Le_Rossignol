# MOD-04 — V1-STAB-01 (rédigée le 13/10/2026, VALIDÉE le 13/10/2026 telle quelle)

Le fichier du cahier des charges n'est pas modifié : la MOD s'applique par ce document, comme les MOD-01 à 03 de la phase 3. Guilhem l'a validée à l'arrêt B, au vu des résultats de l'étape 2 ci-dessous.

Numérotation : MOD-01 à MOD-03 sont validées (phase 3). MOD-05 (V1-STAB-03) est en brouillon. Le dossier de la phase 3 (§8) cite « MOD-04 » seulement comme une MOD éventuelle sur V1-MAS-03, jamais rédigée. Si cette dernière devient nécessaire, elle prendra le numéro **MOD-06**.

| Champ | Contenu |
| --- | --- |
| Date | 13/10/2026 (rédaction et validation) |
| Exigence | V1-STAB-01 : moment à portance nulle (Cm0) ; obligatoire ; aile sans empennage ; vérification : analyse xflr5, phase 4 |
| Ancienne valeur | « Moment à portance nulle du **profil** (Cm0) ≥ 0 » |
| Nouvelle valeur | **Cm(CL = 0) de l'aile complète ≥ 0, sans braquage d'élevons**, ce qui revient à un équilibre à CL > 0 avec la marge statique de V1-STAB-02 (8 à 10 % de la MAC). Vérification : xflr5 T2 sur l'aile complète à l'étape 2 de la phase 4 ; T7 à l'étape 3 pour l'équilibre en vol |
| Justification | Les 4 profils réflexes testés (MH 45, MH 60, MH 61, S5010 ; XFoil, Ncrit 9) ont tous un Cm0 négatif aux Reynolds de vol : de −0,0165 à −0,0096 à Re 170 000 et de −0,0066 à −0,0014 à Re 260 000, au quart avant (tableau V1-STAB-01 de `tableaux_auto.md`). Le critère sur le profil seul ne se tient donc pas. Argument de Guilhem : sur une aile en flèche vrillée, l'équilibre est dominé par CL·MS plutôt que par le Cm0 du profil, et c'est donc l'aile complète qui doit porter l'exigence |
| Critères chiffrés à renseigner à l'étape 2 | Cm(CL = 0) de l'aile, pour chaque variante (profil × vrillage) ; CL d'équilibre sans braquage et vitesse équivalente correspondante, pour 3S1P et 4S1P, à MS 8 % et 10 % ; la valeur CL·MS « ≈ 0,03 » de Guilhem est à confirmer par ce calcul |
| Statut | **VALIDÉE le 13/10/2026, telle quelle** (Guilhem, arrêt B) |

## Résultats de l'étape 2 (13/10/2026, T2 non visqueux VLM2, winglets inclinés du vrillage du saumon)

Valeurs calculées par `stabilite.m` §7 (tableaux dans `tableaux_auto.md`). Contrôle visqueux : voir la section suivante (fait après la validation).

| Avion | Cm(CL = 0) de l'aile | CL_eq MS 8 % : V_eq 3S1P / 4S1P | CL_eq MS 10 % : V_eq 3S1P / 4S1P |
| --- | --- | --- | --- |
| V1_MH45_vr3 | +0,0037 | 0,046 : 115,0 / 120,3 km/h | 0,037 : 128,6 / 134,5 km/h |
| V1_MH45_vr5 | +0,0075 | 0,094 : 80,1 / 83,8 km/h | 0,075 : 89,6 / 93,7 km/h |
| V1_MH45_vr7 | +0,0115 | 0,144 : 64,8 / 67,8 km/h | 0,115 : 72,4 / 75,8 km/h |
| V1_S5010_vr3 | +0,0063 | 0,079 : 87,5 / 91,6 km/h | 0,063 : 97,9 / 102,4 km/h |
| V1_S5010_vr5 | +0,0102 | 0,127 : 69,0 / 72,2 km/h | 0,102 : 77,1 / 80,7 km/h |
| V1_S5010_vr7 | +0,0141 | 0,177 : 58,5 / 61,2 km/h | 0,141 : 65,4 / 68,4 km/h |

- **Nouvelle valeur (Cm(CL = 0) ≥ 0)** : tenue par les 6 variantes.
- **Équilibre sans braquage dans 35 à 55 km/h** : tenu par **aucune** variante (58,5 à 134,5 km/h).
- **CL·MS « ≈ 0,03 » de Guilhem** : confirmé à 45 km/h, de 0,0239 (3S1P, MS 8 %) à 0,0327 (4S1P, MS 10 %). C'est le Cm0 qu'il faudrait pour δ = 0 à 45 km/h ; les variantes en donnent 0,0037 à 0,0141.

## Note de lecture (à discuter à l'arrêt B)

Avec un CG devant le point neutre, Cm(CL) = Cm0 − MS·CL autour du CG (Cm positif cabreur ; sens à vérifier sur la pente dCm/dCL de xflr5, comme l'exige la skill). L'équilibre sans braquage est à CL = Cm0 / MS : il exige un Cm0 de l'aile **strictement positif** pour voler à CL > 0. La MOD ne dit donc pas « l'aile se contente d'un Cm0 de profil négatif » : elle déplace l'exigence sur l'aile complète, où c'est le vrillage qui doit apporter un Cm0 positif. Ce Cm0 est fixé par la géométrie, donc l'équilibre sans braquage n'existe qu'à une seule vitesse par masse et par MS. Les autres vitesses de la plage de 35 à 55 km/h passent par un braquage, soumis au critère |δ| de l'étape 3.

Valeurs de contexte déjà calculées (profil seul, quart avant, Cm au Cl de vol 4S1P) : de −0,0137 à −0,0060 à Re 170 000 (Cl 0,545) et de −0,0172 à −0,0095 à Re 260 000 (Cl 0,233).

## Contrôle visqueux après la validation (section C, 13/10/2026, profil retenu S5010)

Valeurs de `stabilite.m` §8 (tableau « Section C » de `tableaux_auto.md`). **Méthode HORS SKILL, signalée.** La VLM non visqueuse porte la ligne moyenne du profil : en théorie des profils minces, le Cm au quart avant de cette ligne vaut **+0,0081** pour le S5010. XFoil (Ncrit 9, étape 1) donne le Cm visqueux à chaque Re et Cl local. L'écart, intégré sur l'envergure avec le Cl local du T2, corrige le Cm de l'aile. La redistribution de portance due à la viscosité est négligée.

| Avion | Cm(CL = 0) non visqueux → avec correction (Re de 70 km/h) | ΔCm visqueux en vol (4S1P, 35 → 55 km/h) |
| --- | --- | --- |
| V1_S5010_vr3 | +0,0063 → **−0,0004** (nouvelle valeur non tenue) | −0,0143 → −0,0177 |
| V1_S5010_vr5 | +0,0102 → +0,0032 (tenue) | −0,0143 → −0,0177 |
| V1_S5010_vr7 | +0,0141 → +0,0066 (tenue) | −0,0143 → −0,0177 |

- La correction au point CL = 0 (−0,0067 à −0,0075) est plus faible qu'en vol (−0,014 à −0,018) : le Cm XFoil du S5010 n'est pas linéaire en Cl près de Cl = 0 (Cm0 −0,0014 à Re 260 000, mais −0,0095 au Cl de vol).
- **En vol, la correction double à peu près le ΔCm cabreur que les élevons doivent fournir.** Exemple à 45 km/h, 4S1P, MS 8 % : de +0,0198 à +0,0365 (vr3) et de +0,0120 à +0,0287 (vr7).
- **La correction varie avec CL,** donc elle avance aussi le point neutre de 2,6 à 2,7 mm, et la marge statique réelle baisse d'autant à CG fixe. Les conséquences sur V1-STAB-03 sont dans `MOD-05_brouillon.md`.
- **Le texte reste inchangé, mais la vérification se fait avec le Cm visqueux** (Guilhem, 13/10/2026), puisque c'est lui qui représente le vol.
- **Verdict de C2 (13/10/2026) : pas de double comptage.** Le T2 visqueux de xflr5 sur V1_S5010_vr5 (18 α communs, de 31 à 69 km/h) ne change pas le CL, et ne change le Cm que de 3,7e-4 au plus. La correction en bandes, elle, vaut −0,0125 à −0,0180 aux mêmes points, soit un rapport médian de 0,01. xflr5 ne reprend donc pas le Cm des polaires XFoil en VLM : la correction en bandes s'applique et les chiffres ci-dessus restent valables. Le petit écart qui reste grandit avec la traînée de profil (CDv) ; c'est probablement le moment de cette traînée (interprétation).
- **Vérification de la MOD-04 avec le Cm visqueux :** tenue à −5° (+0,0032) et à −7° (+0,0066), **non tenue à −3° (−0,0004)**. Selon la décision de Guilhem, la règle de choix du vrillage élimine donc −3°, sans autre décision à prendre.
