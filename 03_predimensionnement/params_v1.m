function p = params_v1()
%PARAMS_V1  Tous les paramètres du pré-dimensionnement V1 (phase 3), en SI.
%
%   p = params_v1() renvoie une structure unique. Aucun autre fichier ne
%   contient de valeur numérique de projet : pour une étude de sensibilité
%   ou une mise à jour (phase 4 : polaire xflr5 ; phase 9 : banc moteur),
%   on modifie ICI ou on surcharge un champ de p dans le script appelant.
%
%   Référence : « Cahier des charges V1 — aile volante 1 m » (gelé le
%   12/10/2026). Les identifiants d'exigences (V1-xxx-nn) sont rappelés en
%   commentaire à côté de chaque valeur qui en découle.
%   Physique : skill /aircraft-design (C1 = Flight Mechanics,
%   C3 = Aircraft Design, numéro de diapositive « p. »).

%% Constantes physiques (skill, SKILL.md « ISA constants » ; C1 p.36-40)
p.const.g    = 9.80665;     % m/s²     pesanteur standard g0
p.const.R    = 287.053;     % J/kg/K   constante de l'air sec
p.const.gam  = 1.4;         % -        rapport des chaleurs massiques
p.const.T0   = 288.15;      % K        température ISA au niveau de la mer
p.const.p0   = 101325;      % Pa       pression ISA au niveau de la mer
p.const.rho0 = 1.225;       % kg/m³    masse volumique ISA au niveau de la mer
p.const.TH   = -0.0065;     % K/m      gradient de la troposphère (C1 p.37)

%% Cas atmosphériques
% Cas 1 : ISA, niveau de la mer.
% Cas 2 : « jour chaud », terrain près de Toulouse, 200 m, 35 °C.
%         Modèle ISA+ΔT (atmosphere-airspeeds.md, « Validity ») : pression
%         ISA à l'altitude, température décalée de ΔT.
p.atm(1).nom = "ISA, niveau de la mer";
p.atm(1).H   = 0;                                   % m
p.atm(1).dT  = 0;                                   % K
p.atm(2).nom = "Jour chaud, 200 m, 35 °C";
p.atm(2).H   = 200;                                 % m
p.atm(2).dT  = (35 + 273.15) - (p.const.T0 + p.const.TH*200);  % K, ΔT par rapport à T_ISA(200 m)

%% Géométrie de l'aile (cahier, « Hypothèses de calcul » ; V1-DIM-01)
p.geo.b      = 1.00;        % m   envergure (V1-DIM-01 : ≤ 1,00 m)
p.geo.S      = 0.25;        % m²  surface de référence
p.geo.c_emp  = 0.32;        % m   corde à l'emplanture c_i
p.geo.c_ext  = 0.18;        % m   corde au saumon c_e
p.geo.lambda = p.geo.b^2 / p.geo.S;   % -  allongement λ = b²/S (= 4)
p.geo.MAC    = 0.257;       % m   corde aérodynamique moyenne (recalculée et vérifiée dans le script, C2 p.64)

%% Modèle aérodynamique (C1 p.18 et p.47) — passe UNIQUEMENT par polaire.m
% type = "parabolique" : CD = CD0 + k·CL², k = 1/(π·λ·e)
% type = "xflr5"       : table importée par import_polaire_xflr5.m (phase 4)
p.aero.type    = "parabolique";
p.aero.CD0     = 0.030;               % -  valeur nominale (milieu de la plage du cahier)
p.aero.CD0_bal = [0.025 0.030 0.035]; % -  balayage demandé
p.aero.e       = 0.78;                % -  coefficient d'Oswald (skill : 0,7-0,85)
p.aero.lambda  = p.geo.lambda;        % -  recopié pour que polaire() soit autonome
p.aero.CLmax   = 0.8;                 % -  aile volante à profil autostable (réflexe)

% Estimation de CD0 par la méthode de la skill (C3 p.85) : CD0 = Cfe·Swet/S
p.cd0est.Cfe_ref    = 0.0055;  % -   avion léger à hélice (C3 p.85)
p.cd0est.Re_ref     = 1e7;     % -   Reynolds typique d'un avion léger (hypothèse, hors skill)
p.cd0est.t_sur_c    = 0.10;    % -   épaisseur relative du profil (hypothèse, à fixer en phase 4)
p.cd0est.Swet_fus   = 0.040;   % m²  surface mouillée de la nacelle centrale (hypothèse)
p.cd0est.Swet_wlet  = 0.048;   % m²  2 winglets × 2 faces × ≈ 0,012 m² (hypothèse)

%% Propulsion
p.prop.eta       = 0.50;    % -  rendement global hélice × moteur × ESC en croisière (cahier)
p.prop.eta_montee= 0.50;    % -  idem en montée et en virage (même hypothèse, faute de mieux)
p.prop.P_av      = 4.5;     % W  avionique + caméra (V1-AV-05)
p.prop.P_max_req = [150 200]; % W  puissance électrique max du moteur (V1-PROP-02)
% Conversion poussée statique -> puissance électrique (théorie de Froude) :
p.prop.FM        = 0.55;    % -  figure of merit d'une hélice repliable au point fixe (hypothèse)
p.prop.eta_mot   = 0.80;    % -  rendement moteur au point fixe plein gaz (hypothèse)
p.prop.eta_esc   = 0.95;    % -  rendement ESC (hypothèse)
p.prop.D_pouces  = [7 8 9]; % in diamètres d'hélice balayés
p.prop.D_nominal = 8;       % in diamètre utilisé pour l'enveloppe du diagramme

%% Batterie : Molicel INR-21700-P45B
% Fiche Molicel INR21700P45B-01 v0.2 (contrôlée le 12/10/2026) :
% 4,5 Ah typ. / 4,35 Ah min. ; 3,6 V nominal (décharge 0,9 A) ; 4,20 V fin
% de charge ; 2,5 V fin de décharge ; 45 A continu ; masse 70,0 g MAX ;
% résistance interne AC 1 kHz ≤ 8 mΩ (pas de valeur DC publiée).
p.batt.Q_Ah     = 4.5;      % Ah  capacité typique
p.batt.Q_Ah_min = 4.35;     % Ah  capacité minimale garantie
p.batt.V_nom    = 3.6;      % V   tension nominale par cellule
p.batt.V_plein  = 4.15;     % V   tension à vide juste après charge (≈ 4,20 V moins relaxation)
p.batt.m_cell   = 0.069;    % kg  valeur du cahier (fiche : 70,0 g max)
p.batt.m_cell_fiche = 0.070;% kg  masse maximale de la fiche
p.batt.I_max    = 45;       % A   courant continu max par cellule
p.batt.R_ac     = 0.008;    % Ω   résistance AC 1 kHz (fiche)
p.batt.R_dc     = 0.015;    % Ω   résistance DC sous charge (HYPOTHÈSE ≈ 2 × R_ac, à mesurer au banc phase 9)
p.batt.f_utile  = 0.85;     % -   fraction utilisable de l'énergie
p.batt.reserve  = 0.20;     % -   réserve à l'atterrissage (V1-PERF-03, V1-PERF-05)
p.batt.pertes   = [0.20 0.30]; % - abattement théorique -> réel
p.batt.ns       = [3 4];    % -   3S1P et 4S1P (V1-PROP-01)

%% Budget de masse (cahier, section « Budget de masse »), en grammes
p.masse.postes = [
    "Panneaux d'aile LW-PLA (2 demi-ailes)",             "structure", 190
    "Fuselage central PLA/PETG + trappe",                "structure",  70
    "Longeron carbone 8 mm + clé arrière 3 mm",          "structure",  30
    "Winglets + élevons",                                "structure",  30
    "Moteur 2212 + hélice repliable + cône",             "systèmes",   62
    "Câblage, connecteurs, velcro, PCB d'interconnexion","systèmes",   35
    "Contrôleur de vol",                                 "systèmes",   25
    "Raspberry Pi Zero 2 W + Camera Module 3 + microSD", "systèmes",   20
    "2 servos 9 g",                                      "systèmes",   18
    "ESC 30 A",                                          "systèmes",   15
    "GPS M10 + compas",                                  "systèmes",   10
    "Récepteur ELRS + antennes",                         "systèmes",    3
    ];
p.masse.batt_3S   = 220;    % g  batterie 3S1P (cahier)
p.masse.batt_4S   = 288;    % g  batterie 4S1P (cahier : 4 × 69 g + nickel, fils, XT30)
p.masse.MTOW      = 800;    % g  V1-MAS-01
p.masse.max_sans_batt = 520;% g  V1-MAS-02
p.masse.max_struct    = 320;% g  V1-MAS-03 (souhaitable)
p.masse.seuil_struct  = 330;% g  règle de décision du cahier
p.masse.ajout_sens    = 50; % g  surcharge testée en sensibilité

%% Plan d'allègement (demande du 13/10/2026) : remplacements de postes
% Chaque ligne remplace la masse d'un poste du budget par celle d'une pièce
% réelle (masses de fiche, consultées le 13/10/2026). Masses en grammes.
%   Contrôleur de vol : SpeedyBee F405 WING MINI (ArduPilot :
%     SpeedyBeeF405WING) = carte FC 5,6 g + PDB 5,5 g + carte sans fil 3,2 g
%     (fiche reprise par hobbyrc.co.uk). PDB : capteur de courant 80 A,
%     BEC FC 5,2 V 2 A, BEC servos 5 V 4 A.
%     Pour mémoire, le F405 WING APP du cahier : 24,5 g la carte, 35 g avec la
%     rallonge USB (fiche) ; le poste de 25 g suppose la rallonge retirée.
%   ESC : Favourite LittleBee-S 30 A (Hobbyking) : 30 A continu, 35 A crête,
%     sans BEC (opto), 9 g avec fils de puissance et de signal.
%   GPS : Matek M10Q-5883 (GNSS M10 + compas QMC5883L) : 8 g (fiche ; produit
%     en fin de vie, un équivalent M10 + compas est à retrouver à l'achat).
p.allg.postes = [
    "Contrôleur de vol", "SpeedyBee F405 WING MINI (FC + PDB + carte sans fil)"
    "ESC 30 A",          "Favourite LittleBee-S 30 A, avec fils"
    "GPS M10 + compas",  "Matek M10Q-5883"
    ];
p.allg.m = {[5.6 5.5 3.2], 9, 8};   % g, composants de chaque pièce (sommés par budget_reaffecte.m)
% Leviers NON comptés (masses non publiées ou à peser) : câblage (la PDB du
% MINI fournit le 5 V : le PCB d'interconnexion + régulateur pourrait
% disparaître, si le BEC FC de 2 A suffit aussi au Pi Zero 2 W), servos
% plus légers, hélice rigide APC au lieu du moyeu repliable.

%% Exigences de mission (cahier, tableau des exigences)
p.req.Vs_max      = 32/3.6;   % m/s  V1-PERF-01 : décrochage ≤ 32 km/h à 800 g
p.req.Vs_cible    = 29/3.6;   % m/s  V1-PERF-01 : cible 29 km/h
p.req.V_cr        = 55/3.6;   % m/s  V1-PERF-02 : croisière (plage 45-60 km/h)
p.req.V_cr_plage  = [45 60]/3.6; % m/s V1-PERF-02
p.req.Vz_min      = 3.0;      % m/s  V1-PERF-07 : montée plein gaz après le lancer
p.req.k_Vmontee   = 1.3;      % -    vitesse de montée = 1,3·Vs (justifié dans le rapport)
p.req.phi_virage  = 45;       % deg  virage à 45° (n = 1/cos φ = 1,41)
p.req.V_virage    = 45/3.6;   % m/s  vitesse du virage
p.req.TsurW_stat  = 0.5;      % -    V1-PERF-08 : poussée statique / poids ≥ 0,5
p.req.t_4S_cr     = 45;       % min  V1-PERF-03
p.req.t_4S_end    = 70;       % min  V1-PERF-04 (souhaitable)
p.req.V_end_plage = [35 40]/3.6; % m/s V1-PERF-04 : « vitesse d'endurance ≈ 35 à 40 km/h »
p.req.V_end_op    = 40/3.6;   % m/s  V1-PERF-04 vérifiée à 40 km/h : pas de pitot sur la V1,
                              %      marge au décrochage (1,2·Vs reste la borne théorique)
p.req.V_eta       = [40 55]/3.6; % m/s vitesses où le η en croisière est détaillé
p.req.t_3S_cr     = 30;       % min  V1-PERF-05
p.req.V_vent      = 20/3.6;   % m/s  V1-PERF-06 : vent moyen admissible
p.req.k_vent      = 2.0;      % -    critère pratique V_croisière ≥ 2·V_vent (hors skill)
p.req.k_Vmin_op   = 1.2;      % -    vitesse minimale d'utilisation = 1,2·Vs
p.req.k_pitch     = 1.5;      % -    critère pratique vitesse de pas ≥ 1,5·V_croisière (hors skill)

%% Balayages
p.bal.V_kmh  = 25:0.25:70;    % km/h  plage des courbes d'autonomie (demandée : 25 à 70)
p.bal.WS     = 10:0.1:60;     % N/m²  axe du diagramme de contraintes

%% Motorisation : moteurs 2212 candidats et hélices repliables propulsives
% Modèle moteur à courant continu (KV, Rm, I0). Valeurs GÉNÉRIQUES 2212
% (catalogue type A2212) avec lois d'échelle à volume de bobinage constant :
% Rm ∝ 1/KV², I0 ∝ KV, Imax ∝ KV (pertes cuivre max constantes).
% À REMPLACER par les mesures au banc (phase 9).
p.mot.KV      = [920 1000 1100 1250 1400];      % tr/min/V, KV courants des 2212 du commerce
p.mot.KV_ref  = 1000;      % tr/min/V
p.mot.Rm_ref  = 0.090;     % Ω   résistance de phase à KV_ref (catalogue A2212/13T)
p.mot.I0_ref  = 0.5;       % A   courant à vide à KV_ref, 10 V
p.mot.Imax_ref= 13;        % A   courant max (60 s) à KV_ref
p.mot.t_I30   = 60;        % s   durée associée (pas de valeur 30 s publiée)
p.mot.R_esc   = 0.010;     % Ω   résistance ESC + câblage (hypothèse)
p.mot.P_esc0  = 0.5;       % W   pertes fixes de l'ESC (commutation, repos), hypothèse : pèse à charge partielle
p.mot.I_esc   = 30;        % A   ESC 30 A (budget)
p.mot.m       = 0.057;     % kg  masse d'un 2212 (SunnySky X2212 V3 KV980, fiche constructeur)
p.mot.nom     = "2212 (générique, lois d'échelle)";
p.mot.court   = "2212";
p.mot.P_plage = p.prop.P_max_req; % W  fenêtre de puissance visée (V1-PROP-02)
p.mot.D_min   = 0;         % in  toutes les hélices de p.hel.liste

% Moteur de F et G : SunnySky X2212 V3 KV980, valeurs RELEVÉES sur la fiche
% (sunnyskyusa.com, consultée le 13/10/2026) : 57 g, 92 mΩ, 0,6 A à 10 V,
% axe 3,175 mm (cf. X2208, même gamme), ESC conseillé 20-30 A, 3-4S.
%   I30     : « Max Continuous Current 26 A/30 s » (limite de courte durée)
%   Imax    : limite CONTINUE retenue = plus fort courant plein gaz de la fiche
%             tenu 10 min en 4S (APC 9047 : 18,4 A, 70 °C après 10 min).
%             En 3S, la fiche donne 20,2 A (APC 1038, 76 °C, 10 min).
%   P_fiche : « Max Continuous Power » 385 W (même durée que I30)
p.motX.nom     = "2212 (SunnySky X2212 V3, fiche)";
p.motX.court   = "X2212";
p.motX.KV      = 980;          % tr/min/V
p.motX.Rm      = 0.092;        % Ω
p.motX.I0      = 0.6;          % A à 10 V
p.motX.Imax    = 18.4;         % A  continu (10 min, 70 °C), utilisé pour le bridage
p.motX.I_cont  = p.motX.Imax;  % A  limite continue publiée (référence des cas d'erreur)
p.motX.I30     = 26;           % A  30 s
p.motX.t_I30   = 30;           % s  durée associée à I30
p.motX.P_fiche = 385;          % W
p.motX.m       = 0.057;        % kg
p.motX.P_plage = p.prop.P_max_req;
p.motX.D_min   = 0;

% Variante E : moteur plus léger, classe 2208, 100 à 130 W, hélice 8 à 9 pouces.
% Valeurs RELEVÉES par KV sur la fiche SunnySky X2208 (sunnyskyusa.com,
% consultée le 12/10/2026 et revue le 13/10/2026), sans loi d'échelle : la
% fiche ne suit pas Rm ∝ 1/KV². Axe 3,175 mm, ESC conseillé 18 A (20 A en KV1500).
%   Imax = I30 : « Max Continuous Current » de la fiche, 14 A/15 s (KV1100),
%          15 A/30 s (KV1260), 16 A/30 s (KV1500) : limite de COURTE durée,
%          aucune limite continue publiée (hypothèse optimiste, signalée).
%   I_essai : plus fort courant plein gaz du tableau d'essais de la fiche
%          (durée non indiquée) : KV1100 13,0 A (4S, APC 9047, 56 °C),
%          KV1260 13,9 A (3S, APC 9047, 52 °C), KV1500 17,5 A (3S, APC 8038, 52 °C).
%   P_fiche : « Max Continuous Power » 205 / 168 / 240 W.
p.motE.nom    = "2208 (SunnySky X2208)";
p.motE.court  = "X2208";
p.motE.KV     = [1100 1260 1500];      % tr/min/V
p.motE.Rm     = [0.191 0.122 0.095];   % Ω
p.motE.I0     = [0.3 0.4 0.7];         % A à 10 V
p.motE.Imax   = [14 15 16];            % A
p.motE.I30    = [14 15 16];            % A
p.motE.t_I30  = [15 30 30];            % s
p.motE.I_essai = [13.0 13.9 17.5];     % A
p.motE.P_fiche = [205 168 240];        % W
p.motE.m      = 0.046;     % kg  masse (fiche)
p.motE.P_plage = [100 130];% W  fenêtre demandée pour la variante E
p.motE.D_min  = 8;         % in  hélices de 8 à 9 pouces seulement
% Variante E2 : même carcasse 2208, KV BAS non catalogué chez SunnySky
% (HYPOTHÈSE) : lois d'échelle du 2212 appliquées à partir du X2208 KV1100,
% pour savoir quel KV ferait tenir 100-130 W en 3S ET en 4S sans bridage.
p.motEh.nom      = "2208 KV bas (extrapolé du X2208 KV1100, hors catalogue)";
p.motEh.court    = "2208 hors cat.";
p.motEh.KV       = 650:50:1000;    % tr/min/V
p.motEh.KV_ref   = 1100;
p.motEh.Rm_ref   = 0.191;          % Ω
p.motEh.I0_ref   = 0.3;            % A
p.motEh.Imax_ref = 14;             % A
p.motEh.m        = p.motE.m;       % kg
p.motEh.P_plage  = p.motE.P_plage;
p.motEh.D_min    = p.motE.D_min;
% Groupe propulsif « moteur + pales repliables + moyeu + cône » (poste de
% 62 g du budget du cahier). Références RÉELLES pour axe 3,175 mm, pied de
% pale 8 mm (consultées le 13/10/2026) :
%   pales : aero-naut CAM Carbon 8×6 (réf. fabricant 723417), paire,
%           « Nettogewicht 9 g » (Zeller Modellbau, art. 132733 ; masse
%           revendeur, pas fabricant) ; régime max admis 16 000 tr/min
%           (Reisenauer, fiche CAM Carbon 8×6) ;
%   moyeu + cône : RFM Freudenthaler, cône CFK Ø 30 mm, alésage 3,17 mm,
%           pied de pale 8 mm, CFK + alu, vis fournies : 14 g (f3x.de).
% Hypothèse signalée : même masse de pales pour les hélices de 7 pouces
% (majorant ; masse de la CAM Carbon 7×6 non publiée).
% Vérification du 13/10/2026 (navigateur Obscura) :
%   - moyeu RFM (f3x.de, art. RFM9106-317mk) : « Drehrichtung rechts
%     (Standard) », largeur de pied de pale 8 mm, trou de pale 3 mm, fixation
%     par vis pointeau (méplat de 0,5 mm à meuler sur l'axe), 45,54 € ;
%     « autres types sur demande » (page RFM de f3x.de), version gauche non
%     confirmée ;
%   - CAM Carbon 7×6 (hacker-motor-shop.com ; Reisenauer) : pied 8 mm, trou
%     3 mm, 16 000 tr/min max, « rechtslaufend » : même moyeu que la 8×6 ;
%   - X2212 V3 : axe 3,17 mm (sunnyskyusa.com, « Replacement Shaft for
%     SunnySky X2212 Motors 3.17mm » ; X2212 d'avant 2013 : 3 mm) ; version
%     à axe long livrée avec pince alu ; l'axe long permet d'inverser le
%     montage du moteur ;
%   - les CAM Carbon 8×6 et 7×6 et le moyeu RFM sont en rotation DROITE
%     (tractrice) : aucune version propulsive trouvée (voir p.gp.alt).
p.gp.poste      = "Moteur 2212 + hélice repliable + cône";  % ligne du budget
p.gp.m_pales    = 0.009;   % kg  paire de pales CAM Carbon 8×6
p.gp.m_moyeu    = 0.014;   % kg  moyeu + cône RFM Ø 30 mm, 3,17 mm
p.gp.n_max_rpm  = 16000;   % tr/min, limite des pales CAM Carbon 8×6
p.gp.t_lancer   = 10;      % s   plein gaz au lancer + montée (cas d'erreur)
% Alternatives PROPULSIVES trouvées (masses publiées seulement ; NaN = non
% publiée). Les masses APC sont données en onces sur la fiche.
%   alt 1 : aero-naut « Klappluftschraube 8x5" linkslaufend Carbon » (722415,
%           « als Druckpropeller (linkslaufend) entwickelt », plastique chargé
%           carbone ; existe aussi en 9,5×5 et 10×7, PAS en 8×6 ni 7×6) +
%           cône aero-naut CN 30/3,17 mm (725903 : pince conique M8, pied 8 mm,
%           Mittelstück alu) ; masses non publiées ;
%   alt 2 : APC 8x6EP (LP08060EP, « Thin Electric Pusher, Reverse Rotation »,
%           0,49 oz, alésage 1/4" avec bagues) : RIGIDE, adaptateur à prévoir ;
%   alt 3 : APC 7x6EP (0,28 oz) : rigide, pour G.
p.const.oz = 0.028349523125;   % kg  once avoirdupois (conversion des fiches APC)
p.gp.alt = struct( ...
    'nom',     {"aero-naut 8×5 linkslaufend + cône CN 30/3,17", "APC 8x6EP (rigide)", "APC 7x6EP (rigide)"}, ...
    'hel',     {[8 5], [8 6], [7 6]}, ...
    'repliable', {true, false, false}, ...
    'm_pales', {NaN, 0.49 * p.const.oz, 0.28 * p.const.oz}, ...   % kg
    'm_moyeu', {NaN, NaN, NaN});                                   % kg (cône / adaptateur)

% Hélices repliables propulsives : [diamètre pouces, pas pouces]
% (tailles courantes des pales repliables ; disponibilité en version
%  PROPULSIVE, avec moyeu adapté, à vérifier à l'achat)
p.hel.liste = [7 4; 7 5; 7 6; 7.5 4; 7.5 5; 7.5 6; 8 4; 8 4.5; 8 5; 8 5.5; 8 6; ...
               8.5 5; 8.5 6; 9 5; 9 6; 9 7];
% Coefficients au point fixe en fonction de P/D (ordre de grandeur UIUC pour
% petites hélices, hypothèse) : Ct0 = a_t + b_t·(P/D − 0,5) ; Cp0 = a_p + b_p·(P/D − 0,5)
p.hel.a_t = 0.100;  p.hel.b_t = 0.050;
p.hel.a_p = 0.040;  p.hel.b_p = 0.060;
% Hélice en vol, J = V/(n·D) (hypothèse, ordre de grandeur des hélices
% fines UIUC, à recaler) :
%   Ct(J) = Ct0·(1 − (J/J_T)²),  J_T = k_JT·(P/D)  (poussée nulle vers J ≈ P/D)
%   Cp(J) = Cp0·(1 − (J/J_P)²),  J_P = k_JP·J_T   (la puissance s'annule plus tard)
% Avec ces valeurs, η hélice max ≈ 0,75 pour une 8×6 (vérifié dans les tests).
p.hel.k_JT = 1.10;
p.hel.k_JP = 1.6;

%% Options moteur comparées (demande du 12/10/2026, avant choix du KV)
% classe : "mot" (2212) ou "motE" (2208) ; hel3S / hel4S : [D, pas] en pouces ;
% thr3S / thr4S : rapport cyclique maximal (1 = pas de bridage ; NaN =
% calculé par limite_gaz.m pour tenir P_lim et la limite de courant).
% Demande du 13/10/2026 :
%   F      : SunnySky X2212 V3 KV980 (fiche), 8×6 unique, THR_MAX 4S calculé ;
%   G      : moteur de F, 7×6 en 4S bridée (pour information, piste « C ») ;
%   E-1260 : X2208 KV1260, 8×6 unique, THR_MAX calculé pour 130 W ;
%   E-1100 : X2208 KV1100, 8×6 unique, THR_MAX calculé pour 130 W.
% La variante E2 (2208 KV bas hors catalogue, sans bridage) est ajoutée par
% le script ; le balayage E (meilleure_helice.m) reste pour justifier le KV.
% Ajout du 13/10/2026 (vérification du moyeu) :
%   F-8x5 : moteur de F avec 8×5 sur les deux batteries, pour information :
%           seule taille de 8 pouces trouvée en pales repliables PROPULSIVES
%           (aero-naut « linkslaufend », voir p.gp.alt).
p.opt = struct( ...
    'nom',    {"A",   "B",     "C",     "F",     "G",     "E-1260", "E-1100", "F-8x5"}, ...
    'classe', {"mot", "mot",   "mot",   "motX",  "motX",  "motE",   "motE",   "motX"}, ...
    'KV',     {1000,  1000,    920,     980,     980,     1260,     1100,     980}, ...
    'hel3S',  {[8 6], [8 5.5], [8.5 5], [8 6],   [8 6],   [8 6],    [8 6],    [8 5]}, ...
    'hel4S',  {[7 5], [7 4],   [7 6],   [8 6],   [7 6],   [8 6],    [8 6],    [8 5]}, ...
    'thr3S',  {1,     1,       1,       NaN,     NaN,     NaN,      NaN,      NaN}, ...
    'thr4S',  {1,     1,       1,       NaN,     NaN,     NaN,      NaN,      NaN}, ...
    'P_lim',  {200,   200,     200,     200,     200,     130,      130,      200});   % W, borne de puissance de l'option

%% Décision de l'utilisateur (13/10/2026)
% Moteur SunnySky X2212 V3 980 KV. Configuration de référence F : 8×6 sur les
% deux batteries, THR_MAX 4S calculé par limite_gaz.m (200 W). G (7×6 en 4S)
% reste une option à trancher au banc en phase 9 ; les deux jeux de pales
% sont achetés.
p.choix.ref  = "F";        % option de référence (nom dans p.opt)
p.choix.banc = "G";        % option à trancher au banc (phase 9)

%% Sensibilité (§6)
p.sens.eta  = p.prop.eta * [0.8 1.2];   % ±20 %
p.sens.e    = [0.70 0.85];
p.sens.CD0  = [0.025 0.035];
p.sens.FM   = p.prop.FM * [0.8 1.2];    % ajout hors demande : pèse sur le point de conception

%% Sorties
p.sortie.dpi = 200;           % résolution des PNG
end
