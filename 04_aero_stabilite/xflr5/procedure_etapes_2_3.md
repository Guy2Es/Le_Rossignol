# Procédure xflr5, étapes 2 et 3 (en construction ; mise à jour à l'arrêt B le 13/10/2026)

Projet : `xflr5/V1_phase4.xfl`. Profils 3D : **MH 45** et **S5010** seulement (décision du 13/10/2026).

Je n'écris pas les XML des avions avant d'avoir un gabarit réel avec les winglets : le schéma d'une dérive ou d'un winglet dans xflr5 v6.62 n'est pas dans les gabarits de l'étape 0 (l'avion par défaut a une dérive en haut de fuselage, pas des winglets de bout d'aile). Je ne le devine pas.

## 2.0 Gabarit d'un avion avec winglets (environ 10 minutes)

1. Ouvre `V1_phase4.xfl`. Menu **Plane > Define a New Plane** (Ctrl+F3).
2. **Aile principale** : 3 sections, des valeurs quelconques conviennent (je les remplace par celles de MATLAB) :
   - y = 0 ; 0,25 ; 0,5 m ;
   - cordes 0,32 ; 0,25 ; 0,18 m ;
   - décalage de bord d'attaque (xOffset) 0 ; 0,13 ; 0,25 m ;
   - dièdre 0 ; vrillage 0 ;
   - profil **MH 45** aux trois sections.
   Ne coche pas de volet : il n'est pas utile en T2.
3. **Supprime** l'empennage horizontal et la dérive centrale de l'avion par défaut (pas d'*Elevator*, pas de *Fin* au centre).
4. **Winglet** : ajoute-le comme tu le ferais en xflr5. Deux façons possibles, choisis celle que l'interface te propose et dis-moi laquelle :
   - **a.** une dérive (*Fin*) à l'extrémité de l'aile, avec les options dérive double / symétrique si elles existent, hauteur 0,10 m, corde 0,18 m au pied et 0,09 m en tête, profil NACA 0008 ;
   - **b.** une section supplémentaire à l'extrémité de l'aile principale, avec un dièdre proche de 90°.
   Position : y = 0,5 m, x = bord de fuite du saumon moins la corde du winglet (valeur quelconque, je la remplace).
5. Donne une **masse** : **Plane > Current Plane > Define Inertia**, une masse ponctuelle de 0,8 kg à x = 0,1 m, comme à l'étape 0.
6. Exporte l'avion en XML, par la même entrée du menu `Plane` qu'à l'étape 0.5. Nom : `xflr5/gabarits/avion_winglets.xml`.
7. Lance un **T2** (type 2, mêmes réglages que le gabarit `analyse_T2.xml`) sur cet avion, de α = −4° à 12° par pas de 1°, avec la vitesse que tu veux. Exporte :
   - la polaire du plan en .txt (clic droit sur la polaire dans l'*Object explorer*) : `xflr5/exports/gabarits_T2/T2_polaire.txt` ;
   - **un point de fonctionnement** (un seul α, par exemple 4°) : l'aile vue en 3D avec le graphique du Cl local selon l'envergure ; exporte ce graphique (clic droit sur le graphique, *Export to file* ou équivalent) : `xflr5/exports/gabarits_T2/T2_Cl_local.txt`.
   Je lis ces deux fichiers pour écrire les lecteurs ; si l'export du Cl local n'existe pas dans ton interface, dis-le-moi, il me faut alors une autre source.

## 2.0 bis Profil et polaires du winglet (NACA 0008)

Le T2 du gabarit montre que les stations du winglet sortent de la plage des polaires (Re de 47 000 à 69 000, sous le premier Re du lot des profils d'aile, 70 000). En VLM visqueux, xflr5 lit les polaires 2D du profil de chaque station : il faut donc un lot propre au winglet.

Journal du T2 du gabarit (13/10/2026) : xflr5 **rejette tout point de fonctionnement** dont une seule station sort de la plage des polaires. α ≤ −1° : portance négative (normal en T2). α = 0° et 1° : Re de l'aile au-dessus de 430 000 (vitesses de 37 et 22 m/s, hors du domaine de vol). α ≥ 6° : Re du winglet sous 70 000. Seuls α = 2° à 5° ont été gardés.

1. Importe `profils/naca0008.dat` comme les autres profils à l'étape 1.1 (`File > Open`). Ce fichier vient d'airfoiltools.com (NACA 0008, 35 points) ; MATLAB l'a contrôlé : épaisseur 8,00 %, cambrure nulle, écart à la formule analytique des NACA à 4 chiffres inférieur à 1e-5 corde. Son nom dans xflr5 sera celui de la première ligne : **NACA 0008**.
2. Raffine-le comme les autres (`Design > Refine Globally`) : avec 35 points seulement, c'est indispensable avant XFoil.
3. Dans **XFoil Direct Analysis**, lance un lot (*Multi-threaded batch analysis*) sur ce seul profil, avec les mêmes réglages qu'à l'étape 1.2 (T1, Ncrit 9, transition libre, α de −6° à 14° par pas de 0,5°, « From Zero » coché) et la liste de **12 Re** : 30 000 ; 50 000 ; 70 000 ; 90 000 ; 110 000 ; 130 000 ; 150 000 ; 170 000 ; 190 000 ; 210 000 ; 230 000 ; 250 000.
4. Pas d'export nécessaire : ces polaires servent à xflr5 lui-même pendant le T2. Enregistre le projet (Ctrl+S).

## 2.1 Où on en est, et ce qu'il reste à faire (mis à jour le 13/10/2026)

**Fait** : gabarits (étape 0), 76 polaires 2D (étape 1), lot NACA 0008 du winglet, projet contenant **les 6 avions** importés (V1_MH45_vr3, vr5, vr7, V1_S5010_vr3, vr5, vr7), un premier T2 visqueux sur V1_S5010_vr7.

**Constat du premier T2 (V1_S5010_vr7, visqueux)** : xflr5 n'a gardé que α = 4,5° à 8,0°, soit de 65 à 40 km/h. Il manque 35 à 40 km/h, alors que le critère d'élevons s'y joue (CL = 0,540). Raisons des rejets :

- α ≤ 2,0° : portance négative (normal en T2 : la portance doit égaler le poids) ;
- α = 2,5° à 4,0° : Re de l'emplanture au-dessus du lot de polaires (430 000), à plus de 75 km/h ;
- α ≥ 8,5° : le Cl local du winglet (NACA 0008) dépasse son Clmax dans le modèle (0,81 à 1,45 pour 0,73 à 0,76). Que ce soit physique ou un artefact de la VLM, xflr5 rejette alors **tout** le point.

**Décision de méthode (outil, pas conception)** : pour que le point neutre, le Cm(CL = 0), la traînée induite et le Cl local sortent sur toute la plage de vitesse, on lance pour chaque avion une analyse **non visqueuse** (même VLM2, même masse, même CG). Elle ne lit aucune polaire 2D et ne rejette aucun point. L'analyse visqueuse reste utile pour la traînée de profil : on la garde pour l'avion retenu (étape 4) et pour un contrôle sur V1_S5010_vr7 (section C).

MATLAB a généré dans `xflr5/genere/` **les 6 analyses non visqueuses** : `analyse_T2inv_V1_<PROFIL>_vr<n>.xml`, polaire nommée `T2inv-VLM2`. Elles sont identiques aux T2 visqueux (ρ = 1,225, ν = 1,4607e-5, dimensions projetées, inertie du plan) sauf la case « Viscous ».

Limite à retenir : la VLM non visqueuse ne dit rien du décrochage ni de la traînée de profil. Le Cl local au saumon est un indicateur de risque, pas une prédiction.

## 2.2 Procédure détaillée : une analyse non visqueuse par avion (6 fois)

### A. Préparer (une seule fois)

1. Ouvre `V1_phase4.xfl`. Module **Wing and Plane Design** (Ctrl+6).
2. Enregistre (Ctrl+S) avant de commencer : un plantage de xflr5 pendant une analyse ne doit pas faire perdre l'import.
3. Crée le dossier `xflr5/exports/T2/` s'il n'existe pas.

### B. Pour chaque avion

Ordre conseillé : V1_S5010_vr7, V1_S5010_vr5, V1_S5010_vr3, V1_MH45_vr7, V1_MH45_vr5, V1_MH45_vr3. Après le premier avion, envoie-moi les 3 fichiers (polaire et 2 Cl local) : je les lis avant que tu fasses les 5 autres.

1. **Sélectionne l'avion** : clic sur son nom dans l'*Object explorer* (à gauche). Le panneau de résultats en bas à droite affiche ses dimensions.
2. **Contrôle** (3 secondes) :
   - Wing Span = 1,000 m, Wing Area = 0,250 m², Plane Mass = 0,797 kg ;
   - **TipTwist = −3,000°, −5,000° ou −7,000°** selon le nom de l'avion. S'il affiche +3, +5 ou +7 : arrête-toi et dis-le-moi (signe inversé) ;
   - deux winglets visibles dans la vue 3D.
3. **Import de l'analyse** : menu `Plane` ou `Polars` (là où tu as importé l'analyse visqueuse), entrée d'import XML d'une analyse, fichier `xflr5/genere/analyse_T2inv_<avion>.xml`. Si l'entrée n'existe pas : `Analysis > Define an Analysis`, mêmes réglages que le T2 visqueux **sauf** « Viscous » décochée.
4. **Vérifie la polaire créée** : dans l'*Object explorer*, déplie l'avion : une polaire `T2inv-VLM2` apparaît. Ouvre ses réglages (double-clic, ou clic droit > Edit) : type 2 (*Fixed Lift*), VLM2 (case VLM1 décochée), **Viscous décochée**, densité 1,225, viscosité 1,4607e-5. Si Viscous est cochée, décoche-la et dis-le-moi : l'import ne l'aurait pas lue.
5. **Sélectionne la polaire `T2inv-VLM2`** (clic sur son nom). Dans le panneau *Plane analysis* à droite :
   - mode **séquence** coché ;
   - α de départ **−2**, fin **12**, pas **0,5** (comme sur ta capture) ;
   - **Store OpPoint** coché ;
   - **Init LLT** : ne touche pas (il ne sert qu'à la LLT).
6. Clic **Analyze**. Quelques secondes. Les α à portance négative sont rejetés : normal. **Il ne doit plus y avoir de message « outside the flight envelope of polars » ni « could not be interpolated »**, puisqu'aucune polaire 2D n'est lue. Si ce message apparaît, la case Viscous est restée cochée : reviens à l'étape 4.
7. **Contrôle du CG** : touche L (*View Log File*) : `CoG_x= 0.1565 m` et `CoG_z= 0.0023 m`. Sinon, ne continue pas et dis-le-moi.
8. **Export de la polaire** : clic droit sur `T2inv-VLM2` dans l'*Object explorer*, export de la polaire en .txt (comme au gabarit, 2.0.7). Nom : `xflr5/exports/T2/T2inv_<avion>.txt`, par exemple `T2inv_V1_S5010_vr7.txt`.
9. **Export du Cl local à deux α** : α = **4,0°** et α = **12,0°** (les mêmes pour les 6 avions : 4,0° est à portance positive même pour −7° de vrillage, puisque le point à 2,5° l'était déjà). Pour chacun :
   - dans l'*Object explorer*, déplie `T2inv-VLM2` : une ligne par α stocké. Double-clic sur la ligne α = 4,0 : la vue 3D affiche ce point de fonctionnement ;
   - affiche le graphique du **Cl local** (le même qu'au gabarit : menu `Graphs` ou clic droit sur le graphique, variable Cl). Une seule courbe doit rester, celle du point courant : si plusieurs points sont affichés, décoche les autres ;
   - clic droit sur le graphique, **Export to file** (ou équivalent) : `xflr5/exports/T2/Cl_<avion>_a4.0.txt`. Même chose à α = 12,0 : `Cl_<avion>_a12.0.txt`.
   - Le titre du graphique dans le fichier doit contenir l'avion, la méthode, α et la vitesse (comme au gabarit) : MATLAB s'en sert.
10. **Enregistre** (Ctrl+S) et passe à l'avion suivant.

### C. Contrôle visqueux (révisé le 13/10/2026, arrêt B)

**C1. Fait par MATLAB, sans clic (stabilite.m §8).** La VLM non visqueuse porte la ligne moyenne du profil. MATLAB compare, bande par bande, le Cm XFoil de l'étape 1 au Cm de cette ligne moyenne (profils minces), puis intègre l'écart sur l'envergure. Résultat pour le S5010 : −0,014 à −0,018 sur le Cm de l'aile en vol. C'est du même ordre que le ΔCm d'équilibre, comme Guilhem le prévoyait. Le détail est dans le tableau « Section C » de `tableaux_auto.md` et dans `MOD-04.md`.

**C2. Dans xflr5 (1 analyse, 1 export) : est-ce que xflr5 visqueux corrige le Cm ?** Je ne sais pas si la VLM visqueuse de xflr5 reprend le Cm des polaires XFoil, ou seulement leur traînée. Je ne l'ai pas trouvé dans une source, donc on le mesure :

1. Sélectionne **V1_S5010_vr5** (l'avion à winglets inclinés déjà dans le projet). L'ancienne polaire visqueuse de V1_S5010_vr7 a pu être calculée avant l'inclinaison des winglets : ne la réutilise pas.
2. Importe l'analyse visqueuse `xflr5/genere/analyse_T2_V1_S5010_vr5.xml` (polaire `T2-VLM2`, case **Viscous cochée**).
3. α de −2 à 12, pas de 0,5, Store OpPoint coché, puis **Analyze**. Des points seront rejetés (Re hors du lot, Clmax du winglet) : c'est normal, il suffit de quelques α communs avec le T2 non visqueux.
4. Exporte la polaire : `xflr5/exports/T2/v1_winglet_tilt/T2vis_V1_S5010_vr5.txt`. Le Cl local n'est pas nécessaire.

MATLAB compare le Cm des deux polaires aux mêmes α. Deux cas :
- **ΔCm proche de zéro :** xflr5 ne reprend pas le Cm des polaires, et la correction en bandes (C1) reste notre seule estimation visqueuse.
- **ΔCm proche de C1 :** xflr5 la fait déjà, et les deux méthodes se recoupent.

Seuils (`p.xfl.C2_seuils`, choix de calcul) : rapport médian ΔCm xflr5 / ΔCm en bandes sous 0,25, on garde les bandes ; au-dessus de 0,75, on prend xflr5 et on n'applique pas les bandes ; entre les deux, j'arrête et je te montre les deux séries. Quand c'est fait, dis « C2 fait » : je traite C2 avant que tu passes à E1.

### D. Fichiers attendus dans `xflr5/exports/T2/` (21)

| Avion | Polaire | Cl local |
| --- | --- | --- |
| V1_MH45_vr3 | `T2inv_V1_MH45_vr3.txt` | `Cl_V1_MH45_vr3_a4.0.txt`, `Cl_V1_MH45_vr3_a12.0.txt` |
| V1_MH45_vr5 | `T2inv_V1_MH45_vr5.txt` | `Cl_V1_MH45_vr5_a4.0.txt`, `Cl_V1_MH45_vr5_a12.0.txt` |
| V1_MH45_vr7 | `T2inv_V1_MH45_vr7.txt` | `Cl_V1_MH45_vr7_a4.0.txt`, `Cl_V1_MH45_vr7_a12.0.txt` |
| V1_S5010_vr3 | `T2inv_V1_S5010_vr3.txt` | `Cl_V1_S5010_vr3_a4.0.txt`, `Cl_V1_S5010_vr3_a12.0.txt` |
| V1_S5010_vr5 | `T2inv_V1_S5010_vr5.txt` | `Cl_V1_S5010_vr5_a4.0.txt`, `Cl_V1_S5010_vr5_a12.0.txt` |
| V1_S5010_vr7 | `T2inv_V1_S5010_vr7.txt` | `Cl_V1_S5010_vr7_a4.0.txt`, `Cl_V1_S5010_vr7_a12.0.txt` |
| V1_S5010_vr5 (visqueux, section C2 révisée) | `T2vis_V1_S5010_vr5.txt` | aucun |

Les 18 fichiers non visqueux sont faits (13/10/2026). Reste la polaire visqueuse de C2.

**Ce que MATLAB en tire** : X_NP par la pente de Cm et par la pente de XCP·CL ; Cm(CL = 0) de l'aile (critère de la MOD-04, brouillon) ; CL d'équilibre sans braquage = Cm0 / MS pour MS 8 % et 10 %, et vitesse équivalente ; couverture des CL de 0,135 (70 km/h) à 0,540 (35 km/h) ; écart de batterie 3S/4S avec le foyer xflr5 (arrêt si > 30 mm) ; traînée induite et Cl local au saumon selon le vrillage (Cl local reconstruit linéairement à partir de tes deux α).

## E. T2 à élevons braqués (arrêt B, 13/10/2026) : choix du vrillage

**Ordre décidé par Guilhem :**
1. **C2 d'abord**, le T2 visqueux ci-dessus. Tout le reste en dépend : si xflr5 reprend déjà le Cm XFoil, la correction en bandes n'est pas appliquée (double comptage), et MATLAB refait les chiffres de la section C.
2. **Ensuite, les profils et les polaires à volet** (E1).
3. **Enfin, les 3 T2 à élevons et le T2 de contrôle** (E2, E3).

**Pourquoi 3 avions, plus 1.** En VLM non visqueuse, le Cm est linéaire et la traînée induite quadratique en vrillage et en braquage δ. Pour chaque coefficient, un polynôme de degré 2 en (vrillage, δ) a 6 inconnues. Les 3 T2 à δ = 0 (−3, −5, −7°) et 3 T2 à élevons relevés les déterminent exactement : (−3°, 6° vers le haut), (−7°, 6° vers le haut), (−5°, 3° vers le haut). Le conditionnement vaut 28,6 en variables réduites.

Le **4e T2**, `V1_S5010_vr5_e0` (décidé), isole l'effet du maillage : les avions à élevons ont deux sections de plus, avec un panneau de transition de 4 mm. MATLAB le compare au V1_S5010_vr5 déjà exporté.

Convention xflr5 : un braquage positif abaisse le bord de fuite. « 6° vers le haut » s'écrit donc **−6°**.

### E1. Les trois profils à volet et leurs polaires XFoil (après C2)

1. Module **Foil Direct Design** (ou XFoil Direct Analysis), sélectionne le **S5010** déjà raffiné à l'étape 1 (200 panneaux). Ne le raffine pas une seconde fois.
2. Ouvre la commande **Set Flap** (menu `Foil` ou `Design`, ou clic droit sur le profil selon la version) :
   - case **T.E. Flap** cochée ;
   - charnière à **75 %** de la corde en x, et à **50 %** de l'épaisseur en y ;
   - angle **−3°** (bord de fuite vers le haut).
3. Nomme le nouveau profil **exactement** `S5010 elv-3`, avec une espace et un tiret : les XML le citent sous ce nom.
4. Recommence avec **−6°** (`S5010 elv-6`) et **−9°** (`S5010 elv-9`). Le profil à −9° ne sert qu'aux polaires XFoil, sans T2 : il garde le cas 35 km/h, MS 10 % dans le domaine interpolé.
5. **Contrôle :** exporte chaque profil en .dat (`Foil > Export`) vers `04_aero_stabilite/profils/s5010_elv-3.dat`, `s5010_elv-6.dat` et `s5010_elv-9.dat`. MATLAB mesure le braquage sur la ligne moyenne et le compare à −3, −6 et −9°.
6. **Polaires XFoil**, avec le **même lot qu'à l'étape 1** (`procedure_etapes_0_1.md`, 1.2) sur ces 3 profils seulement :
   - les 19 Re de 70 000 à 430 000 ;
   - T1, Ncrit 9, transitions libres ;
   - α de −6 à 14 par pas de 0,5, « From Zero » coché, « Initialize BLs between polars » coché.
7. **Export** au format texte (.txt) dans un nouveau dossier, `xflr5/exports/polaires_volet/`. Si tu passes par « Export All Polars », les polaires des autres profils partiront avec : ce n'est pas grave, MATLAB ne garde que les profils `S5010 elv-…`.

### E2. Les avions et les analyses

Fichiers dans `xflr5/genere/` :

| Avion | Vrillage | δ | Statut |
| --- | --- | --- | --- |
| `avion_V1_S5010_vr3_e6.xml` + `analyse_T2inv_V1_S5010_vr3_e6.xml` | −3° | −6° | obligatoire |
| `avion_V1_S5010_vr7_e6.xml` + `analyse_T2inv_V1_S5010_vr7_e6.xml` | −7° | −6° | obligatoire |
| `avion_V1_S5010_vr5_e3.xml` + `analyse_T2inv_V1_S5010_vr5_e3.xml` | −5° | −3° | obligatoire |
| `avion_V1_S5010_vr5_e0.xml` + `analyse_T2inv_V1_S5010_vr5_e0.xml` | −5° | 0° | contrôle du maillage (décidé) |

Pour chaque avion, même déroulé qu'en B, avec trois différences :

1. **Import de l'avion :** dans la vue 3D, la moitié extérieure de chaque demi-aile doit avoir le bord de fuite relevé. Si xflr5 signale un profil introuvable, le nom de E1 ne correspond pas : arrête-toi et dis-le-moi.
2. **Contrôle :** TipTwist de −3, −5 ou −7° comme pour les autres. Wing Span 1,000 m et Wing Area 0,250 m² (le panneau de transition ne change pas la surface).
3. **Analyse :** `T2inv-VLM2`, **Viscous décochée**, α de **−2 à 14**, pas de 0,5. La plage va à 14 parce que les élevons relevés retirent de la portance et que 35 km/h demande CL = 0,540. Contrôle du CG : `CoG_x= 0.1565 m`.

### E3. Exports (dans `xflr5/exports/T2/v1_winglet_tilt/`)

Pour chaque avion :
- la polaire `T2inv_<avion>.txt` ;
- le Cl local à **α = 6,0°** et **α = 14,0°** : `Cl_<avion>_a6.0.txt` et `Cl_<avion>_a14.0.txt`. On prend 6° plutôt que 4° parce que, élevons relevés, la portance à 4° peut être trop faible ou rejetée.

Soit 4 polaires et 8 Cl local. Quand c'est fait, dis « exports élevons faits ».

**Reçu le 15/10/2026.** Les Cl local sont venus sous forme d'export complet du point de fonctionnement (50 bandes avec corde, Cl, CmAirf, etc.), plus riche que l'export du graphe. MATLAB (§11) reconnaît chaque fichier par son en-tête (avion, analyse, α) : les noms de fichiers sont libres.

### E4. Ce que MATLAB en tire

1. **Les 6 avions sont recombinés** dans le modèle quadratique en (vrillage, δ).
2. **Pour chaque vrillage de −3 à −7°,** braquage d'équilibre δ_trim(V) de 35 à 55 km/h : 3S1P et 4S1P, MS 8 et 10 %, Cm corrigé de la viscosité en bandes (C1).
3. **Critère de go/no-go provisoire :** δ_trim entre 0 et 6° vers le haut sur toute la plage, et au moins 10° de débattement à cabrer restant à 35 km/h.
4. **Règle de choix du vrillage, annoncée avant le calcul :** parmi les vrillages qui tiennent le critère dans les 4 configurations, celui qui minimise la moyenne des 8 traînées équilibrées (40 et 55 km/h × 3S1P/4S1P × MS 8/10 %). Les optima de chaque configuration sont montrés à côté, pour voir la sensibilité. Si l'optimum tombe à −3° ou à −7°, c'est-à-dire en bord de plage, je le signale.
5. **Traînée et efficacité :** les polaires des profils à volet (−3, −6, −9°) corrigent en bandes le Cm et la traînée de profil des élevons. C'est le même principe que la section C1, sauf si C2 montre que xflr5 le fait déjà.
6. **Si aucun vrillage ne tient la fenêtre dans les 4 configurations : arrêt.** Je montre le braquage requis par configuration, sans toucher ni aux seuils ni à la marge statique. Guilhem choisit alors entre un réflexe fixe sur la partie centrale, une fenêtre plus large, ou une marge statique de premier vol à 8 % seulement.

## 3 À préciser après l'arrêt B

- T7 sur 4 avions (3S/4S × MS 8/10 %) au vrillage choisi : gabarit T7 avec élevons. Il faudra un profil à volet au neutre (Set Flap à 0°), pour que xflr5 reconnaisse le volet comme une commande et balaye le braquage symétrique.
