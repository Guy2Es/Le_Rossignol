# Cahier des charges V1 — aile volante 1 m

Oct 12, 2026 · @guilhem

La V1 est un démonstrateur de 800 g maximum, en Li-ion 21700, qui vise environ 45 min de vol réel à 55 km/h et plus d'une heure en flânant. Elle décroche vers 29 km/h, se lance à la main et vole à vue sur un terrain privé. Ce document fige ses exigences avant la phase 3 ; toute modification passe par une MOD écrite (dernière section).

## Objet et périmètre

La V1 sert à apprendre, à valider la géométrie et la chaîne ArduPilot, et à mesurer les polaires réelles qui dimensionneront la V2. Ce n'est pas la cellule de la V2 : celle-ci sera réimprimée avec les corrections issues des essais.

Dans le périmètre :

- Aile volante de 1,00 m imprimée en 3D (LW-PLA + longeron carbone), démontable.
- Propulsion électrique, batterie Li-ion 21700 en 3S1P puis 4S1P.
- ArduPlane avec modes stabilisés, retour automatique et missions à vue.
- Liaison ELRS 2,4 GHz (commandes + télémétrie MAVLink).
- Enregistrement vidéo HD embarqué (Raspberry Pi Zero 2 W + Camera Module 3).

Hors périmètre (reporté en V2) : liaison 4G et pilotage depuis le PC, caméra thermique et projecteur IR, capteur de vitesse (pitot), décollage sur chariot, atterrissage automatique, vol de nuit.

## Décisions de cadrage (12/10/2026)

Sept décisions remplacent les TLAR V1 de la notice ; elles déplacent le point de conception vers une charge alaire d'environ 31 N/m² au lieu de 50 à 70 N/m².

| N° | Décision | Remplace | Justification |
| --- | --- | --- | --- |
| D1 | V1 = démonstrateur, pas cellule de la V2 | « Même aile » V1 → V2 | Évite de payer 0,7 kg de structure V2 pendant l'apprentissage ; réimprimer coûte ≈ 40 € |
| D2 | Masse au décollage ≤ 800 g | 1,4 kg max | Pas d'enregistrement du drone ni de signalement électronique ; décrochage plus lent, plus facile pour un débutant |
| D3 | Autonomie maximale, en Li-ion 21700 | LiPo 4S 3000 mAh, 35 min | À masse égale, ≈ 60 % d'énergie en plus ; « autonomie max » demandée pour le plaisir |
| D4 | Berceau et structure prévus pour 4S1P ; premiers vols en 3S1P | — | 3S1P laisse ≈ 50 g de marge pour les premiers vols ; 4S1P pour l'endurance |
| D5 | Lancer main par un aide, atterrissage sur le ventre dans l'herbe | Chariot sur piste | Proto simple ; le chariot passe en V2 |
| D6 | Terrain privé, sans trafic aérien, hors club | Terrain de club FFAM | Terrain disponible ; règles de la catégorie ouverte A3 à respecter |
| D7 | Raspberry Pi Zero 2 W en vol ; Pi 3 réservé au banc et au développement | Pi Zero 2 W | Le Pi 3 coûte ≈ 45 g et 2 W, soit 5 à 10 min de vol |

## Mission type

Un vol d'endurance de la V1 dure 45 min à 1 h 20 et reste à vue au-dessus du terrain privé.

1. Lancer main par un aide, moteur plein gaz, mode FBWA.
2. Montée à 80 m à 3 m/s minimum.
3. Croisière ou attente (LOITER) entre 35 et 55 km/h, à moins de 300 m du pilote, vidéo HD enregistrée.
4. Retour automatique (RTL) à 30 % de batterie, ou sur failsafe.
5. Approche manuelle et atterrissage sur le ventre dans l'herbe.
6. Téléchargement du journal de vol et de la vidéo, carnet rempli.

## Exigences

La V1 compte 39 exigences, dont 31 obligatoires ; chacune renvoie à la phase de la notice qui la vérifie. Les identifiants sont figés : une exigence modifiée garde son numéro et reçoit une MOD.

| ID | Exigence | Valeur | Priorité | Justification | Vérification |
| --- | --- | --- | --- | --- | --- |
| V1-MAS-01 | Masse au décollage avec batterie 4S1P | ≤ 800 g | Obligatoire | D2, seuil réglementaire | Pesée — phase 8 |
| V1-MAS-02 | Masse sans batterie | ≤ 520 g | Obligatoire | Laisse ≈ 280 g pour la 4S1P | Pesée — phase 8 |
| V1-MAS-03 | Masse de la structure (centre, panneaux, longeron, winglets) | ≤ 320 g | Souhaitable | Budget de masse | Pesée des tranches et pièces — phases 5 et 8 |
| V1-DIM-01 | Envergure hors tout | ≤ 1,00 m | Obligatoire | Transport en voiture | Inspection — phase 8 |
| V1-DIM-02 | Démontage | 3 parties, montage ≤ 5 min sans outil | Souhaitable | Transport et réparation | Essai chronométré — phase 9 |
| V1-DIM-03 | Longueur d'un tronçon imprimé | ≤ 200 mm | Obligatoire | Imprimante du fablab encore inconnue ; plateaux courants ≥ 220 mm | Inspection CAO — phase 5 |
| V1-PERF-01 | Vitesse de décrochage à 800 g | ≤ 32 km/h (cible 29) | Obligatoire | Lancer main, pilote débutant | Analyse — phases 3 et 4 ; essai — phase 10 |
| V1-PERF-02 | Vitesse de croisière | 45 à 60 km/h | Obligatoire | Tenir 20 km/h de vent avec marge | Essai — phase 10 |
| V1-PERF-03 | Autonomie réelle en 4S1P à 55 km/h, 20 % de réserve | ≥ 45 min | Obligatoire | D3 | Essai CRUISE — phase 10 |
| V1-PERF-04 | Autonomie réelle en 4S1P à la vitesse d'endurance (≈ 35 à 40 km/h) | ≥ 70 min | Souhaitable | D3 | Essai LOITER — phase 10 |
| V1-PERF-05 | Autonomie réelle en 3S1P à 55 km/h, 20 % de réserve | ≥ 30 min | Obligatoire | Vols d'apprentissage | Essai — phase 10 |
| V1-PERF-06 | Vent moyen admissible | ≥ 20 km/h | Obligatoire | Vent d'autan fréquent ; charge alaire faible | Essai — phase 10 |
| V1-PERF-07 | Taux de montée plein gaz après le lancer | ≥ 3 m/s | Obligatoire | Quitter le sol après un lancer main | Analyse — phase 3 ; essai — phase 10 |
| V1-PERF-08 | Rapport poussée statique / poids | ≥ 0,5 | Obligatoire | Lancer main sûr | Banc moteur — phase 9 |
| V1-STAB-01 | Moment à portance nulle du profil (Cm0) | ≥ 0 | Obligatoire | Aile sans empennage | Analyse xflr5 — phase 4 |
| V1-STAB-02 | Marge statique au premier vol | 8 à 10 % de la MAC | Obligatoire | Sécurité du premier vol | Analyse — phase 4 ; centrage — phase 8 |
| V1-STAB-03 | Plage de réglage du CG par la batterie | ± 15 mm, en 3S1P et en 4S1P | Obligatoire | D4, deux batteries de masses différentes | CAO — phase 5 ; centrage — phase 8 |
| V1-STAB-04 | Modes dynamiques | Incidence et roulis hollandais amortis ; spirale lente tolérée | Obligatoire | Stabilité naturelle | Analyse xflr5 (type 7) — phase 4 |
| V1-STR-01 | Facteur de charge limite à 800 g | n = 5, coefficient de sécurité 1,5 | Obligatoire | Virages serrés, rafales, ressources | Calcul du longeron — phase 5 |
| V1-STR-02 | Atterrissage sur le ventre dans l'herbe à 35 km/h | Aucune pièce non remplaçable endommagée | Obligatoire | Crash probable en apprentissage | Essai — phase 10 |
| V1-STR-03 | Fusibles mécaniques | Demi-ailes et trappe se déboîtent sous choc | Souhaitable | Limiter la casse | Essai au sol — phase 9 |
| V1-STR-04 | Réparabilité | Toute pièce réimprimable en une nuit | Souhaitable | Prototype | Inspection — phase 5 |
| V1-PROP-01 | Batterie | Li-ion 21700 haute capacité (type Molicel P45B), 3S1P et 4S1P | Obligatoire | D3, D4 | Inspection — phase 6 |
| V1-PROP-02 | Puissance électrique maximale du moteur | 150 à 200 W | Obligatoire | Montée à 3 m/s avec marge (≈ 90 W requis) | Banc moteur — phase 9 |
| V1-PROP-03 | Hélice | Propulsive repliable | Souhaitable | Protège l'hélice à l'atterrissage sur le ventre | Inspection — phase 8 |
| V1-AV-01 | Pilote automatique | ArduPlane : MANUAL, FBWA, RTL, puis CRUISE, LOITER, AUTO, AUTOTUNE | Obligatoire | Apprentissage et missions | Simulation SITL — phase 7 |
| V1-AV-02 | Failsafes | Perte radio → RTL ; batterie faible → RTL ; clôture virtuelle, plafond 120 m | Obligatoire | Sécurité | SITL — phase 7 ; sol — phase 9 ; vol — phase 10 |
| V1-AV-03 | Liaison radio | ELRS 2,4 GHz, ≤ 100 mW PIRE, portée ≥ 1 km, télémétrie MAVLink | Obligatoire | Réglementation, télémétrie vers le PC | Essai de portée — phase 9 |
| V1-AV-04 | GPS | ≥ 10 satellites avant le lancer | Obligatoire | RTL et missions | Inspection — phase 9 |
| V1-AV-05 | Consommation de l'avionique, caméra comprise | ≤ 4,5 W | Souhaitable | Autonomie | Mesure au banc — phase 9 |
| V1-PL-01 | Caméra et ordinateur de bord | Pi Zero 2 W + Camera Module 3, ≤ 30 g, ≤ 2,5 W | Obligatoire | D7 | Pesée et mesure — phase 6 |
| V1-PL-02 | Vidéo | 1080p enregistrée dès l'armement, sur toute la durée du vol | Obligatoire | Démonstrateur de surveillance | Essai — phase 10 |
| V1-OPS-01 | Zone de vol | À vue, hauteur ≤ 120 m, à ≥ 150 m des zones habitées, commerciales, industrielles ou de loisirs | Obligatoire | Catégorie ouverte A3 | Inspection du terrain et de la clôture — phase 0 |
| V1-OPS-02 | Lancement | Lancer main par un aide, main jamais dans le disque de l'hélice | Obligatoire | D5, sécurité | Essai — phase 10 |
| V1-OPS-03 | Mise en œuvre au terrain | ≤ 10 min de la voiture au lancer | Souhaitable | Pratique | Essai — phase 9 |
| V1-REG-01 | Exploitant | Inscrit sur AlphaTango, numéro collé sur le drone | Obligatoire | Caméra embarquée | Inspection — phase 0 |
| V1-REG-02 | Formation du télépilote | Formation en ligne A1/A3 réussie (à confirmer pour un drone construit soi-même) | Obligatoire | Catégorie ouverte | Inspection — phase 0 |
| V1-REG-03 | Terrain et assurance | Accord écrit du propriétaire, zone vérifiée sur Géoportail, assurance responsabilité civile drone | Obligatoire | Hors club : pas d'assurance FFAM | Inspection — phase 0 |
| V1-BUD-01 | Coût de conception et fabrication | ≤ 500 € | Obligatoire | Budget fixé | Suivi des achats — phases 5 à 8 |

## Budget de masse

En 4S1P, l'estimation tombe à 796 g : il reste 4 g de marge sous 800 g, donc la structure est le poste à surveiller. En 3S1P, on vole à 728 g.

| Élément | Masse estimée (g) |
| --- | --- |
| Panneaux d'aile LW-PLA (2 demi-ailes) | 190 |
| Fuselage central PLA/PETG + trappe | 70 |
| Longeron carbone 8 mm + clé arrière 3 mm | 30 |
| Winglets + élevons | 30 |
| **Sous-total structure** | **320** |
| Moteur 2212 + hélice repliable + cône | 62 |
| Câblage, connecteurs, velcro, PCB d'interconnexion | 35 |
| Contrôleur de vol | 25 |
| Raspberry Pi Zero 2 W + Camera Module 3 + microSD | 20 |
| 2 servos 9 g | 18 |
| ESC 30 A | 15 |
| GPS M10 + compas | 10 |
| Récepteur ELRS + antennes | 3 |
| **Sous-total systèmes** | **188** |
| **Masse sans batterie** | **508** |
| Batterie 4S1P (4 × P45B ≈ 69 g + nickel, fils, XT30) | 288 |
| **Total en 4S1P** | **796** |
| Batterie 3S1P | 220 |
| **Total en 3S1P** | **728** |

Règle de décision : si la structure imprimée dépasse 330 g en phase 8, la V1 vole en 3S1P seulement, ou une MOD relève V1-MAS-01 en acceptant de passer au-dessus de 800 g. Ajoute une colonne « pesé » au fil des impressions.

## Budget financier

La V1 revient à environ 430 €, ou 480 € avec l'aile mousse d'entraînement : il reste 20 à 70 € de marge sur les 500 €. Les prix sont des ordres de grandeur à vérifier à l'achat ; radio, licence, assurance et outillage sont hors budget.

| Achat | Choix | Phase | Prix indicatif (€) |
| --- | --- | --- | --- |
| Cellules Li-ion + connectique | 7 × Molicel P45B (une 3S1P + une 4S1P), nickel, XT30 | 6 | 66 |
| Raspberry Pi Zero 2 W + Camera Module 3 + microSD | Le Pi 3 reste au banc | 6 | 54 |
| Contrôleur de vol | SpeedyBee F405 WING | 6 | 50 |
| Chargeur équilibreur compatible Li-ion | À retirer si l'atelier en a un | 6 | 45 |
| Filament LW-PLA | 1 bobine (PLA/PETG déjà disponibles) | 5 | 40 |
| GPS + compas | u-blox M10 | 6 | 30 |
| Moteur | 2212, KV à choisir pour 3S/4S en phase 3 | 6 | 22 |
| Structure | Tubes carbone, aimants, vis, charnières | 8 | 20 |
| Câblage | XT30, fil silicone, gaine, velcro | 8 | 20 |
| PCB d'interconnexion | Fabrication 2 couches + régulateur 5 V | 6 | 20 |
| Servos | 2 × 9 g pignons métal | 6 | 18 |
| Récepteur | ELRS 2,4 GHz | 6 | 15 |
| ESC | 30 A | 6 | 15 |
| Hélices | Propulsives repliables + cône, lot | 6 | 15 |
| **Total V1** |  |  | **430** |
| Aile mousse EPP ≈ 900 mm (optionnelle) | Entraînement, reçoit l'électronique V1 | 1 | 50 |

Les cellules se soudent par points (fablab) ; jamais au fer. Des packs déjà assemblés coûtent environ 30 € de plus.

## Hypothèses, points ouverts et modifications

Les chiffres de performance viennent d'un pré-dimensionnement en Python, à refaire proprement dans MATLAB en phase 3 autour du nouveau point de conception.

Hypothèses de calcul : S = 0,25 m², allongement 4, e = 0,78, CD0 de 0,025 à 0,035, CLmax = 0,8, rendement de propulsion η = 0,5, avionique 4,5 W, 85 % de la batterie utilisable, 20 % de réserve, puis 20 à 30 % retirés pour passer du théorique au réel. Charge alaire ≈ 31 N/m² et P/W ≈ 190 à 250 W/kg.

Points ouverts :

- [ ] Imprimante du fablab : modèle, plateau, réglages LW-PLA (confirme V1-DIM-03).
- [ ] KV du moteur et hélice repliable, à choisir pour fonctionner en 3S et en 4S (phase 3).
- [ ] Comportement des cellules P45B au lancer plein gaz (chute de tension, courant crête) : mesure au banc en phase 9.
- [ ] Formation A1/A3 et inscription exploitant : confirmer les obligations pour un drone construit soi-même de moins de 800 g avec caméra.
- [ ] Terrain privé : accord écrit, distances aux habitations, obstacles, zone sur Géoportail, assurance RC.
- [ ] Écolage : le terrain privé n'a pas de moniteur ; prévoir quand même un club ou un pilote confirmé pour les premiers vols.

Gestion des modifications : toute exigence changée après ce gel reçoit une MOD numérotée (MOD-01, MOD-02…) avec la date, l'exigence touchée, l'ancienne et la nouvelle valeur, et la justification. Le prochain jalon est la phase 3 : refaire le diagramme de contraintes P/W en fonction de W/S autour de 31 N/m² et vérifier V1-PERF-01 à 08.
