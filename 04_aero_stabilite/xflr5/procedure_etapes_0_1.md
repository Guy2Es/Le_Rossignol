# Procédure xflr5 v6.62 — étapes 0 et 1

Durée : environ 15 min de manipulation, plus le calcul du lot XFoil. Les plages de Reynolds ci-dessous sortent de `stabilite.m` (§3, `resultats/tableaux_auto.md`). Si un intitulé de menu diffère dans ta version, prends l'entrée la plus proche et note-le : j'adapterai la procédure suivante.

Dossiers (depuis `04_aero_stabilite/`) :
- `xflr5/gabarits/` : XML de l'étape 0 ;
- `xflr5/exports/polaires_2d/` : polaires de l'étape 1 (à créer s'il n'existe pas).

## Étape 0 — Formats réels (gabarits XML)

Je ne veux pas deviner le schéma XML de la v6.62 : je génère les avions et les analyses à partir de tes exports.

1. Lance xflr5, puis `File > New Project`. Enregistre-le tout de suite sous `04_aero_stabilite/xflr5/V1_phase4.xfl`.
2. `File > Open` : sélectionne les 4 fichiers `04_aero_stabilite/profils/mh45.dat`, `mh60.dat`, `mh61.dat` et `s5010.dat`.
3. Passe dans le module **Wing and Plane Design**.
4. `Plane > Define a New Plane` : garde l'avion par défaut, puis OK.
   - Donne-lui une masse, sinon xflr5 refuse les analyses T2 et T7 (« Mass must be non-zero for type 2 polars ») : `Plane > Current Plane > Define Inertia` (ou bouton d'inertie dans la fenêtre d'édition de l'avion). Ajoute **une masse ponctuelle** : 0,8 kg, x = 0,1 m, y = 0, z = 0, description « test ». Valide.
   - Cette masse sert aussi de gabarit : elle me montre comment la v6.62 écrit les masses ponctuelles dans le XML.
5. Exporte sa définition en XML (menu `Plane`, entrée « Export … to xml » ou « Export definition to XML ») vers `xflr5/gabarits/avion_defaut.xml`.
6. `Analysis > Define an Analysis` (fenêtre à quatre types : 1, 2, 4, 5) : choisis **Type 2 (fixed lift)**, avec les réglages par défaut, puis OK. Exporte la définition en XML (entrée « Export analysis … xml » du menu `Analysis` ou `Polars`) vers `xflr5/gabarits/analyse_T2.xml`.
   - Si l'entrée d'export n'est pas dans les menus : clic droit sur l'analyse dans l'*Object explorer*.
7. Même chose pour une analyse de stabilité (**Type 7, stability**) : elle n'est pas dans la fenêtre des types 1 à 5. Elle a son propre menu, `Analysis > Define a Stability Analysis` (Maj+F6). Réglages par défaut, puis export vers `xflr5/gabarits/analyse_T7.xml`.
   - Si xflr5 refuse de la créer sans réglage de contrôle, laisse-la vide et dis-le-moi.
8. Ne lance aucune analyse sur cet avion par défaut.

## Étape 1 — Polaires 2D des 4 profils

### 1.1 Raffiner les profils

Les .dat de l'UIUC n'ont que 62 à 69 points, trop peu pour XFoil.

Pour chaque profil, dans le module **Direct Foil Design** (ou **XFoil Direct Analysis**) :
- `Design > Refine Globally` (raffinement global) : **200 panneaux**, répartition par défaut ;
- garde **le même nom** (MH 45 …, S5010) et accepte l'écrasement.

### 1.2 Lot XFoil

Module **XFoil Direct Analysis**, menu `Analysis > Multi-threaded Batch Analysis` (ou `Batch Analysis`).

| Réglage | Valeur |
| --- | --- |
| Profils | les 4 (MH 45, MH 60, MH 61, S5010) |
| Type de polaire | Type 1 (vitesse fixe) |
| Reynolds | de **70 000** à **430 000**, pas de **20 000** (19 polaires par profil) |
| Mach | 0 |
| NCrit | **9** |
| Transition forcée | extrados 1, intrados 1 (transition libre) |
| Incidence | de **−6°** à **14°**, pas de **0,5°** |
| Initialiser les couches limites entre polaires | oui |

La plage dépasse celle de l'énoncé (80 000 à 400 000) :
- en bas, le saumon descend vers 85 000 au décrochage le jour chaud ;
- en haut, l'emplanture monte vers 426 000 à 70 km/h.

Dans la v6.62, la fenêtre « Multi-threaded batch analysis » n'a pas de champs min/max/pas pour Re : c'est une **liste éditable** (12 lignes par défaut, de 30 000 à 3e+06).
- Double-clic sur une cellule Re pour la modifier ; colonne `Actions` (`...`) pour insérer ou supprimer une ligne.
- La liste doit contenir exactement les 19 valeurs : 70000, 90000, 110000, 130000, 150000, 170000, 190000, 210000, 230000, 250000, 270000, 290000, 310000, 330000, 350000, 370000, 390000, 410000, 430000 (Mach 0, NCrit 9 sur chaque ligne, toutes cochées dans la colonne ×).
- Polar type T1 ; transitions 1 et 1 ; Specify α ; Min −6, Max 14, Increment 0,5 ; « From Zero » coché (calcul de 0 vers 14 puis de 0 vers −6, meilleure convergence) ; « Initialize BLs between polars » coché ; threads au maximum.

Lance le calcul. Les points qui ne convergent pas à bas Reynolds sont normaux.

### 1.3 Export

`Polars > Export All Polars` (ou, à défaut, `Polars > Current Polar > Export` polaire par polaire) :
- **format texte (.txt)**, celui de XFoil, pas le CSV ;
- dossier `xflr5/exports/polaires_2d/`.

Enregistre le projet (`File > Save`).

## Ce qu'il me faut ensuite

Dis-moi quand c'est fait, et signale tout menu qui ne correspondait pas. Je lis alors :
- les 3 XML de `gabarits/` ;
- les polaires de `exports/polaires_2d/`.

MATLAB calcule ensuite Cm0, CLmax, (Cl/Cd)max, Cl^1,5/Cd et le creux de traînée à Re = 170 000 et 260 000, puis j'écris le classement de l'**arrêt A**.

Plus tard, à l'étape 2 et seulement pour les profils retenus :
- les copies avec volet (charnière à 75 %, 0°) ;
- le NACA 0008 des winglets (Re de 30 000 à 250 000, pas de 20 000).
