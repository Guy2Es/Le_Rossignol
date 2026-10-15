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

%% Plan d'allègement (demande du 13/10/2026, VALIDÉ le 13/10/2026 sous
%  réserve des vérifications ci-dessous) : remplacements de postes
% Chaque ligne remplace la masse d'un poste du budget par celle d'une pièce
% réelle (masses de fiche, consultées le 13/10/2026). Masses en grammes.
%   Contrôleur de vol : SpeedyBee F405 WING MINI = carte FC 5,6 g + PDB
%     5,5 g + carte sans fil 3,2 g (fiche reprise par hobbyrc.co.uk et
%     getfpv). La page ArduPilot de la carte donne « Muini:19G » : écart non
%     expliqué, retenu comme cas pessimiste (p.allg.m_haut).
%     Pour mémoire, le F405 WING APP du cahier : 24,5 g la carte, 35 g avec la
%     rallonge USB (fiche) ; le poste de 25 g suppose la rallonge retirée.
%   ESC : Favourite LittleBee-S 30 A (Hobbyking) : 30 A continu, 35 A crête,
%     sans BEC (opto), 9 g avec fils de puissance et de signal.
%   GPS : le Matek M10Q-5883 (8 g) est en fin de vie (« Discontinued »,
%     absent de la page GNSS de mateksys.com, qui ne propose plus que le
%     M9N-5883). Équivalents M10 + compas trouvés : MicoAir M10G-5883 (u-blox
%     M10050 + QMC5883L, 7 g, 30 mA, pyrodrone) ; FlyFishRC M10-IST8310 /
%     M10QMC-5883L (M10050, 9 g, fpvfaster). Les deux sont en rupture chez
%     ces revendeurs le 13/10/2026. Le budget retient le plus lourd (9 g).
p.allg.postes = [
    "Contrôleur de vol", "SpeedyBee F405 WING MINI (FC + PDB + carte sans fil)"
    "ESC 30 A",          "Favourite LittleBee-S 30 A, avec fils"
    "GPS M10 + compas",  "M10 + compas (MicoAir M10G-5883 7 g ou FlyFishRC M10 9 g)"
    ];
p.allg.m      = {[5.6 5.5 3.2], 9, 9};   % g, composants de chaque pièce (sommés par budget_reaffecte.m)
p.allg.m_haut = {19,            9, 9};   % g, cas pessimiste (FC : 19 g de la page ArduPilot)
% Leviers NON comptés (masses non publiées ou à peser) : câblage, servos
% plus légers. Le PCB d'interconnexion + régulateur 5 V du cahier est GARDÉ :
% il alimente le Pi Zero 2 W (voir p.av, BEC du contrôleur de vol).

%% Avionique : BEC 5 V, UART et firmware (vérifications du 13/10/2026)
% ArduPilot (ardupilot.org, « SpeedyBeeF405WING/ Wing Mini ») : une seule
% cible, SpeedyBeeF405WING, pour la WING et la WING MINI ; STM32F405, 1 Mo de
% flash (« this board does not include all ArduPilot features »).
% features.txt de la cible (firmware.ardupilot.org, Plane stable) :
% AP_FENCE_ENABLED, AP_GPS_UBLOX_ENABLED, AP_RCPROTOCOL_CRSF_ENABLED,
% AP_COMPASS_QMC5883L_ENABLED, AP_COMPASS_IST8310_ENABLED présents ;
% !AP_COMPASS_QMC5883P_ENABLED (compas QMC5883P NON pris en charge) ;
% !AP_SCRIPTING_ENABLED (pas de Lua).
% BEC du contrôleur de vol : MINI « 5.2V, continuous current 2 Amps, 3A
% Peak » pour FC, récepteur, GPS, airspeed, télémétrie (fiche, revendeurs
% fpvfaster et getfpv) ; la page ArduPilot donne 5 V 2,4 A (valeur de la WING).
% BEC servos : 5 V 4 A (fiche MINI).
% Raspberry Pi (raspberrypi.com, documentation, Power supply) : Zero 2 W :
% alimentation recommandée 2 A, consommation typique carte nue active 350 mA ;
% « Camera Module » : 250 mA typiques.
p.av.V_bec       = 5.0;    % V   tension du BEC
p.av.I_bec_fc    = 2.0;    % A   BEC du contrôleur de vol, continu (fiche MINI)
p.av.I_bec_fc_pk = 3.0;    % A   crête
p.av.I_pi        = 0.350;  % A   Pi Zero 2 W, typique actif
p.av.I_cam       = 0.250;  % A   Camera Module, typique
p.av.I_pi_psu    = 2.0;    % A   alimentation recommandée par Raspberry Pi pour le Zero 2 W
p.av.P_av_max    = 4.5;    % W   V1-AV-05 : avionique, caméra comprise (souhaitable)
p.av.P_pl_max    = 2.5;    % W   V1-PL-01 : Pi + caméra
% Affectation des UART (page ArduPilot, ordre par défaut) :
p.av.uart = [
    "SERIAL1 (USART1)", "ELRS (CRSF), RX1 + TX1", "besoin V1-AV-03"
    "SERIAL3 (UART3)",  "GPS M10 + compas (I2C pour le compas)", "besoin V1-AV-04"
    "SERIAL4 (UART4)",  "MAVLink2 vers le Pi Zero 2 W", "besoin charge utile (V1-PL-01)"
    "SERIAL5 (UART5)",  "libre (TX5 aussi sur le connecteur vidéo)", "réserve"
    "SERIAL2 (USART2)", "libre si BRD_ALT_CONFIG = 1 (RX2 relié à l'entrée SBUS inversée)", "réserve"
    "SERIAL6 (UART6)",  "carte sans fil interne (MAVLink2 Wi-Fi)", "occupé"
    ];

%% Contrainte pour la phase 5 (décision du 13/10/2026) : garde au sol
% Hélice rigide propulsive : le disque balaie D/2 sous l'axe moteur. Placer
% l'axe le plus haut possible et vérifier la garde au sol à l'atterrissage
% sur le ventre (V1-STR-02).

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
% Groupe propulsif « moteur + hélice + moyeu » (poste « Moteur 2212 + hélice
% repliable + cône » de 62 g du budget du cahier).
% DÉCISION DE L'UTILISATEUR (13/10/2026, après vérification du moyeu) :
% hélice APC 8x6EP RIGIDE propulsive (MOD-03 sur V1-PROP-03) ; une APC
% 7x6EP est achetée pour trancher G au banc (phase 9).
% Références RÉELLES (consultées le 13/10/2026, navigateur Obscura) :
%   hélice : APC 8x6EP (LP08060EP, apcprop.com) : « Thin Electric Pusher,
%            Reverse Rotation », 0,49 oz, alésage 1/4", épaisseur de moyeu
%            0,37 in, bagues LPAR06E fournies (un jeu) ; 2,92 $ ;
%            APC 7x6EP (LP07060EP) : 0,28 oz, alésage 1/4", moyeu 0,33 in,
%            bagues LPAR18SF et LPARM12SF fournies ; 2,71 $.
%            Bagues : LPAR06E = 1/8", 4, 5, 6 mm, 5/16" (revendeurs AMain,
%            HobbyTown) ; LPARM12SF : bague de 6 mm annoncée par un revendeur
%            (readymaderc), à confirmer à réception.
%   régime max APC « Thin Electric (E) » : 150 000 / D[in] tr/min
%            (apcprop.com, RPM Limits), soit 18 750 tr/min en 8 pouces.
%   adaptateur : pince 3,17 mm à écrou hexagonal, RC Dude Hobbies CPA-317-N
%            (rcdude.com) : axe fileté M6 × 1,0 de 6 mm, « Prop Adapter
%            Weight – 6.0 grams », longueur utile 17 mm, épaisseur de moyeu
%            max 10,5 mm avec rondelle et écrou, en stock, 4,49 $.
%            Écartés : HobbyKing 017000383 / 017000384 (4,2 g, axe 5 mm) :
%            « Discontinued Product » ; E-flite EFLM1923 (6 g, en stock chez
%            Horizon, « Final Hub Diameter 6.5mm » : plus gros que l'alésage
%            APC de 1/4", alésage à reprendre) ; adaptateurs à masse publiée
%            seulement par des revendeurs non identifiés (robu.in 3 g, specs
%            contradictoires).
%   Le paquet du X2212 V3 contient « 1 x Propeller Adapter » (readymaderc,
%   type et masse non publiés) : à peser, il peut remplacer l'adaptateur.
% Hypothèse signalée : la masse de l'hélice 8×6 est gardée pour l'option G
% (7×6 en 4S) : majorant (fiches : 0,49 oz contre 0,28 oz).
% Vérification antérieure (13/10/2026) : pales CAM Carbon 8×6 / 7×6 et moyeu
% RFM en rotation DROITE (tractrice) seulement ; X2212 V3 : axe 3,17 mm.
p.const.oz = 0.028349523125;   % kg  once avoirdupois (conversion des fiches APC)
p.const.in = 0.0254;           % m   pouce
p.gp.poste      = "Moteur 2212 + hélice repliable + cône";  % ligne du budget (libellé du cahier)
p.gp.nom_hel    = "APC 8x6EP (rigide, propulsive)";
p.gp.nom_moyeu  = "adaptateur à pince 3,17 mm / M6 RC Dude CPA-317-N";
p.gp.m_pales    = 0.49 * p.const.oz;   % kg  hélice APC 8x6EP (fiche : 0,49 oz)
p.gp.m_moyeu    = 0.0060;              % kg  adaptateur (fiche : 6,0 g ; écrou et rondelle inclus ou non : non précisé, à peser)
p.gp.k_rpm      = 150000;              % tr/min·in, régime max APC E = k_rpm / D
p.gp.e_moyeu    = [0.37 0.33] * p.const.in;  % m  épaisseur de moyeu APC 8x6EP, 7x6EP
p.gp.e_max      = 0.0105;              % m   épaisseur de moyeu max de l'adaptateur (avec rondelle et écrou)
p.gp.t_lancer   = 10;      % s   plein gaz au lancer + montée (cas d'erreur)
% Autres groupes propulsifs examinés (masses publiées seulement ; NaN = non
% publiée), pour la traçabilité de la décision :
%   alt 1 : APC 7x6EP + même adaptateur : option banc G (rigide, propulsive) ;
%   alt 2 : aero-naut « Klappluftschraube 8x5" linkslaufend Carbon » (722415,
%           seule 8 pouces repliable propulsive trouvée ; PAS de 8×6 ni 7×6)
%           + cône aero-naut CN 30/3,17 mm (725903) ; masses non publiées ;
%           F-8x5 fait échouer V1-PERF-03 et 05 ;
%   alt 3 : pales CAM Carbon 8×6 (9 g, Zeller Modellbau) + moyeu-cône RFM
%           Ø 30 mm / 3,17 mm (14 g, f3x.de) : repliable mais TRACTRICE.
p.gp.alt = struct( ...
    'nom',     {"APC 7x6EP + adaptateur CPA-317-N (banc G)", "aero-naut 8×5 linkslaufend + cône CN 30/3,17", "CAM Carbon 8×6 + moyeu-cône RFM 30 mm"}, ...
    'hel',     {[7 6], [8 5], [8 6]}, ...
    'repliable', {false, true, true}, ...
    'rotation', {"gauche (propulsive)", "gauche (propulsive)", "droite (tractrice)"}, ...
    'm_pales', {0.28 * p.const.oz, NaN, 0.009}, ...   % kg
    'm_moyeu', {p.gp.m_moyeu, NaN, 0.014});           % kg (adaptateur / cône)

%% Budget hélices (MOD-03 : hélices consommables, lot de 10)
% Prix catalogue en dollars US (fiches citées ci-dessus), hors port, douane
% et conversion : à établir à l'achat. Poste du cahier : « Hélices,
% propulsives repliables + cône, lot » 15 €.
p.bud.hel = struct( ...
    'article', {"APC 8x6EP (LP08060EP), lot consommable", "APC 7x6EP (LP07060EP), banc G", "Adaptateur RC Dude CPA-317-N"}, ...
    'qte',     {10, 1, 1}, ...
    'prix_usd', {2.92, 2.71, 4.49});
p.bud.hel_cahier_eur = 15;     % € poste « Hélices » du budget du cahier

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
% Décisions suivantes (13/10/2026) : hélice APC 8x6EP rigide propulsive
% (p.gp), APC 7x6EP achetée pour le banc ; plan d'allègement validé sous
% réserve (p.allg, p.av) ; MOD-01 et MOD-02 validées ; MOD-03 sur V1-PROP-03.
p.choix.ref  = "F";        % option de référence (nom dans p.opt)
p.choix.banc = "G";        % option à trancher au banc (phase 9)
p.choix.mod  = ["MOD-01", "V1-PERF-03", "validée le 13/10/2026"
                "MOD-02", "V1-PROP-02", "validée le 13/10/2026"
                "MOD-03", "V1-PROP-03", "validée le 13/10/2026 (texte fixé par l'utilisateur)"];

%% Sensibilité (§6)
p.sens.eta  = p.prop.eta * [0.8 1.2];   % ±20 %
p.sens.e    = [0.70 0.85];
p.sens.CD0  = [0.025 0.035];
p.sens.FM   = p.prop.FM * [0.8 1.2];    % ajout hors demande : pèse sur le point de conception

%% Sorties
p.sortie.dpi = 200;           % résolution des PNG

%% ===================== PHASE 4 — aérodynamique et stabilité (xflr5) =====================
% Décisions de l'utilisateur (13/10/2026) : xflr5 v6.62 piloté par l'utilisateur,
% MATLAB lit les exports et fait tous les calculs (04_aero_stabilite/stabilite.m).
% La géométrie de la phase 3 (b, S, cordes, MAC) est GARDÉE : la phase 4 n'itère
% que sur la flèche, le vrillage et le profil.

% Viscosité : loi de Sutherland (hors skill, déjà utilisée en phase 3 dans
% estimation_cd0_e.m ; constantes de l'air standard)
p.const.mu_S  = 1.458e-6;      % kg/(m·s·K^0,5)  constante de Sutherland
p.const.T_S   = 110.4;         % K               température de Sutherland

%% Géométrie de l'aile (phase 4) : valeurs de départ de l'énoncé de la phase 4
p.geo4.fleche_BA   = 27;          % deg  flèche du bord d'attaque (départ)
p.geo4.vrillage    = -3;          % deg  vrillage au saumon (négatif = piqueur), départ au milieu de 2-4°
p.geo4.vrillage_plage = [-2 -7];  % deg  plage d'itération du vrillage au saumon (décision du 13/10/2026 : ouverte jusqu'à −7°)
p.geo4.vrillage_matrice = [-3 -5 -7]; % deg  vrillages des T2 (décision du 13/10/2026 : VLM linéaire, Cm0 linéaire et CDi quadratique en vrillage ; 3 points suffisent, un T2 de contrôle si l'optimum tombe entre deux valeurs)
p.geo4.loi_vrillage = "lineaire"; % vrillage proportionnel à y/(b/2) (HYPOTHÈSE)
p.geo4.y_sec       = [0 0.25 0.50]; % m  stations : emplanture, début des élevons, saumon
p.geo4.dihedre     = 0;           % deg
p.geo4.charniere   = 0.75;        % x/c  charnière des élevons (élevons à 25 % de corde)
p.geo4.y_elevon    = [0.25 0.50]; % m    élevons sur la moitié extérieure de chaque demi-aile
% Winglets (dérives de bout d'aile) : seule la hauteur est donnée par l'énoncé
p.geo4.wl_h        = 0.10;        % m    hauteur
p.geo4.wl_c_pied   = p.geo.c_ext; % m    corde au pied = corde du saumon (HYPOTHÈSE)
p.geo4.wl_c_tete   = 0.09;        % m    corde en tête (HYPOTHÈSE, effilement 0,5)
p.geo4.wl_fleche   = 30;          % deg  flèche du bord d'attaque du winglet (HYPOTHÈSE)
p.geo4.wl_profil   = "NACA 0008"; % profil symétrique (HYPOTHÈSE), généré par xflr5
% Longeron : contrôle de place dans le profil (le tracé exact est fait en phase 5)
p.geo4.d_longeron  = 0.008;       % m    longeron carbone 8 mm (cahier, budget de masse)
p.geo4.x_longeron  = 0.25;        % x/c  position relative du longeron (HYPOTHÈSE)
p.geo4.e_peau      = 0.0008;      % m    épaisseur de paroi LW-PLA autour du longeron (HYPOTHÈSE)

%% Analyses xflr5 (énoncé de la phase 4)
p.xfl.dossier_profils = "profils";              % sous-dossier de 04_aero_stabilite
p.xfl.profils  = ["mh45" "mh60" "mh61" "s5010"]; % choix de l'utilisateur (13/10/2026), base UIUC
p.xfl.profils_3d = ["mh45" "s5010"];            % profils de l'aile 3D (décision du 13/10/2026)
p.xfl.Re_min   = 80000;     % -    bas de la plage du lot XFoil (énoncé)
p.xfl.Re_max   = 400000;     % -    haut de la plage (énoncé)
p.xfl.Re_pas   = 20000;      % -    pas du lot (choix de calcul)
p.xfl.Ncrit    = 9;          % -    énoncé
p.xfl.alpha    = [-6 14 0.5];% deg  [début fin pas] des polaires 2D (choix de calcul)
p.xfl.Re_vol   = [170000 260000]; % - Reynolds de l'énoncé (38 et 55 km/h), comparaison des profils
p.xfl.V_max    = 70/3.6;     % m/s  vitesse max examinée (haut de p.bal.V_kmh)
p.xfl.Re_marge = 0.9;        % -    Re_min du lot ≤ 0,9 × plus petit Re de vol (marge d'extrapolation)
p.xfl.dossier_pol2d = "xflr5/exports/polaires_2d"; % exports .txt de l'étape 1 (sous-dossier de 04_aero_stabilite)
p.xfl.Cl_fit_Cm0 = [0.1 0.6]; % -  plage de Cl de la droite Cm(Cl) extrapolée à Cl = 0 (contrôle de Cm0, hors bulle)
p.xfl.creux_tol = 0.10;      % -    creux de traînée : plage de Cl où Cd ≤ (1 + 0,10)·Cd_min (définition de calcul)
% Noms des profils DANS xflr5 (première ligne du .dat, espaces compris : lus sur
% les exports de l'étape 1 et le gabarit avion_winglet.xml)
p.xfl.nom_xflr5 = struct('mh45', "MH 45  9.85%", 'mh60', "MH 60  10.08%", 'mh61', "MH 61  10.26%", ...
                         's5010', "S5010", 'naca0008', "NACA 0008");
p.xfl.profil_wl = "naca0008";  % profil du winglet (lot XFoil de 30 000 à 250 000, 13/10/2026)
% Avions générés pour le T2 (étape 2) : choix de calcul
p.xfl.dossier_genere = "xflr5/genere";        % sous-dossier de 04_aero_stabilite
p.xfl.nx       = 13;          % -    panneaux en corde (aile et winglets), comme le gabarit
p.xfl.ny_aile  = [12 12];     % -    panneaux en envergure de chaque panneau d'aile (emplanture→élevons, élevons→saumon)
p.xfl.ny_wl    = 7;           % -    panneaux en hauteur du winglet, comme le gabarit
p.xfl.methode_T2 = "VLM2";    % -    anneaux tourbillonnaires (plan approuvé) ; le gabarit de l'étape 0 était en VLM1
p.xfl.T2_alpha = [-2 12 0.5]; % deg  plage d'alpha à saisir dans xflr5 ; xflr5 rejette seul les points
                              %      à portance négative ou hors des polaires ; MATLAB vérifie que les CL
                              %      de 35 à 70 km/h sont couverts
p.xfl.dossier_T2 = "xflr5/exports/T2/v1_winglet_tilt"; % exports T2 non visqueux, winglets inclinés du
                              %      vrillage du saumon (la série à winglets à plat est écartée : treillis croisés)
p.xfl.alpha_Cl = [4 12];      % deg  alpha des deux exports de Cl local (reconstruction linéaire entre les deux)
p.geo4.vrillage_panknin = [-5 -7]; % deg  indication de l'utilisateur (Panknin, HORS SKILL) pour δ ≈ 0 à
                              %      45 km/h avec MS 9 % : repère sur les figures, pas un résultat
p.xfl.profil_retenu = "s5010"; % profil de l'aile (décision du 13/10/2026, arrêt B)
% T2 à élevons braqués (arrêt B) : avec les 3 T2 à δ = 0 (vrillages -3/-5/-7°), 3 points de plus
% déterminent exactement les modèles quadratiques en (vrillage, δ) : [vrillage δ] en deg, δ xflr5
p.xfl.elevon_T2 = [-3 -6; -7 -6; -5 -3];
p.xfl.elevon_T2_controle = [-5 0];  % T2 de contrôle (décidé le 13/10/2026) : maillage à élevons, δ = 0 (effet du maillage seul)
p.xfl.dy_elevon = 0.004;       % m    panneau de transition centré sur le début des élevons (xflr5 interpole
                               %      le profil entre deux sections : envergure efficace des élevons conservée)
p.xfl.T2_alpha_elv = [-2 14 0.5]; % deg plage d'alpha des T2 à élevons relevés (CL de 35 km/h à couvrir)
p.xfl.alpha_Cl_elv = [6 14];   % deg  alpha des exports de Cl local des T2 à élevons (portance > 0 sûre)
p.xfl.pas_Cl_volet = 0.005;    % -    pas de Cl de la table (δ, Cl, Re) des polaires à volet (stabilite.m §11, choix de calcul)
% Contrôle visqueux en bandes (section C) : Cm XFoil du profil − Cm de sa ligne moyenne (profils minces),
% intégré sur l'envergure avec le Cl local du T2 (HORS SKILL, signalé)
p.xfl.V_visc = [35 40 45 55 70]/3.6; % m/s vitesses du contrôle
% Section C2 : T2 visqueux xflr5 contre T2 non visqueux, même avion, mêmes alpha. Tranche si xflr5
% reprend déjà le Cm des polaires XFoil (la correction en bandes le compterait alors deux fois).
p.xfl.avion_C2   = "V1_S5010_vr5";
p.xfl.C2_seuils  = [0.25 0.75]; % -  rapport ΔCm xflr5 / ΔCm en bandes (médiane) : < 0,25 → xflr5 ne reprend
                                %    pas le Cm XFoil, correction en bandes appliquée ; > 0,75 → il le
                                %    reprend, correction en bandes NON appliquée ; entre les deux → arrêt
                                %    (choix de calcul)
% Profils à volet : braquages des polaires XFoil (même lot qu'à l'étape 1). −9° sans T2 : le cas
% 35 km/h, MS 10 % reste une interpolation (décision du 13/10/2026)
p.xfl.d_volet = [-3 -6 -9];     % deg  convention xflr5 (< 0 = bord de fuite vers le haut)
p.xfl.dossier_pol_volet = "xflr5/exports/polaires_volet"; % exports .txt des polaires des profils à volet
p.xfl.Re_volet_tab = [130000 190000 250000]; % -  Re du tableau d'efficacité des élevons (cordes des
                                %    élevons de 35 à 55 km/h, voir stabilite.m §10) : choix d'affichage
p.xfl.Cl_volet_tab = [0.2 0.4 0.6];          % -  Cl locaux du tableau (Cl des bandes d'élevon en vol)
p.stab.MS_T2   = 0.09;        % -    MS provisoire de la batterie dans les T2 (milieu de V1-STAB-02) :
                              %      sans effet sur X_NP ni sur Cm(CL = 0), seul le transfert du Cm en dépend

%% Stabilité et centrage (cahier V1-STAB-01 à 04 ; critères fixés par l'utilisateur le 13/10/2026)
p.stab.Cm0_min    = 0;             % -   V1-STAB-01 : Cm0 du profil ≥ 0
p.stab.MS_vol1    = [0.08 0.10];   % -   V1-STAB-02 : marge statique au premier vol (fraction de MAC)
p.stab.MS_regle   = [0.05 0.07];   % -   aile réglée (énoncé), pour information
p.stab.plage_batt = 0.015;         % m   V1-STAB-03 : ± 15 mm de réglage par la batterie (cahier)
p.stab.plage_batt_MOD05 = 0.020;   % m   MOD-05 (BROUILLON du 13/10/2026) : ± 20 mm (± 18 mm d'abord, élargi le
                                   %     même jour : 0,2 mm de marge avec le foyer visqueux) ; sans déplacement de masses
p.stab.zeta_spo   = 0.4;           % -   V1-STAB-04 : oscillation d'incidence (C1 p.180)
p.stab.zeta_dr    = 0.1;           % -   V1-STAB-04 : roulis hollandais (C1 p.180)
p.stab.T2_spi_vise = 12;           % s   spirale : objectif (C1 p.180)
p.stab.T2_spi_nogo = 4;            % s   spirale : no-go si T2 < 4 s (12 s × √(1/10), Froude,
                                   %     1 m contre ≈ 10 m d'envergure ; ÉCART à la skill)
p.stab.V_trim     = [35 55]/3.6;   % m/s plage d'équilibre
p.stab.V_trim_ref = 45/3.6;        % m/s vitesse de référence des élevons
% Critère d'élevons du go/no-go (utilisateur, 13/10/2026, arrêt B ; remplace « |δ| ≤ 1° à 45 km/h
% et ≤ 3° sur la plage » de l'arrêt A, critère hors cahier donc sans MOD). SEUILS PROVISOIRES, à
% revoir avec le Cm_δ de l'étape 3. Convention xflr5 : δ > 0 = bord de fuite vers le bas.
% REMPLACÉ le 15/10/2026 (voir p.stab.d_crois) : infaisable par construction, l'écart de braquage
% de 35 à 55 km/h (≈ MS·ΔCL/Cm_δ) dépasse la fenêtre. Gardé pour la trace de l'arrêt (stabilite.m §11).
p.stab.d_trim     = [-6 0];        % deg braquage d'équilibre de 35 à 55 km/h, 3S1P et 4S1P, MS 8 et 10 % :
                                   %     entre 0 et 6° vers le haut
p.stab.d_reserve  = 10;            % deg débattement à cabrer (vers le haut) restant à 35 km/h, au minimum
p.stab.V_choix_vr = [40 55]/3.6;   % m/s vrillage choisi sur la traînée équilibrée par les élevons à ces vitesses
% Calcul de δ_trim (stabilite.m §11) : choix de calcul
p.stab.pas_V_trim = 1/3.6;         % m/s pas de vitesse de δ_trim(V) sur p.stab.V_trim
p.stab.pas_vr     = 0.25;          % deg pas de vrillage (équilibre, critère, traînée) entre les vrillages des T2
p.stab.vr_tableau = [-3 -4 -5 -6 -7]; % deg vrillages détaillés dans les tableaux (choix d'affichage)
p.stab.d_lim      = [-30 15];      % deg plage de recherche de δ_trim ; hors de −9 à 0° (polaires à volet),
                                   %     prolongement linéaire en δ, signalé
p.stab.mode_verdict = "complet";   % modèle d'élevons du verdict (cm_elevons) : "complet" ajoute à la méthode
                                   %     annoncée en E4 ("bandes", montrée à côté) la perte de portance du
                                   %     volet mesurée par XFoil (η_α du §10). ÉCART à la procédure, signalé
% Critères des élevons du 15/10/2026 (utilisateur ; remplacent p.stab.d_trim et p.stab.d_reserve ;
% hors cahier, donc sans MOD ; V1-STAB-02 inchangée) : deux questions séparées
p.stab.V_crois    = [40 55]/3.6;   % m/s croisière (40 km/h = p.req.V_end_op, endurance opérationnelle)
p.stab.d_crois    = [-10 0];       % deg δ_trim en croisière, 3S1P et 4S1P, à chaque MS de p.stab.MS_crois
p.stab.MS_crois   = [0.08 0.09 0.10]; % -  MS nominale 9 % ; 8 et 10 % : tolérance de centrage
p.stab.MS_nom     = 0.09;          % -   MS nominale du premier vol
p.stab.MS_autorite = 0.10;         % -   autorité : CG le plus avant (MS 10 %), 3S1P et 4S1P
p.stab.d_autorite = -20;           % deg autorité : équilibre au CLmax de l'aile avec au plus 20° vers le haut
p.stab.MS_bas     = [0.07 0.08 0.09]; % - si aucune variante ne passe : MS de premier vol 7–9 % à chiffrer
                                   %     (pas de MOD sur V1-STAB-02 sans accord de l'utilisateur)
p.stab.CL_autorite = [0.4 1.4];    % -   bornes de la recherche du CLmax équilibré (dichotomie, choix de calcul)
p.stab.n_dicho    = 14;            % -   pas de dichotomie du CLmax équilibré (précision 6e-5, choix de calcul)
p.stab.tol_decrochage = 0.02;      % -   une bande à moins de 0,02 de son Clmax au dernier CL faisable : la limite
                                   %     est son décrochage (grille des polaires : Cl par 0,005, Re par 20 000)
% Variantes d'élevons (estimation du 15/10/2026, sans manip xflr5 ; elevons_variantes.m) : la 1re
% est celle des T2. Même fin au saumon. Prolongement : 10 % de la demi-envergure vers l'emplanture.
p.elv.nom       = ["T2 (25 %)" "30 %" "35 %" "35 % prolongés"];
p.elv.charniere = [0.75 0.70 0.65 0.65];   % x/c
p.elv.y0        = [0.25 0.25 0.25 0.25 - 0.10*p.geo.b/2];  % m  début des élevons
p.elv.vr_fig    = -5;              % deg vrillage des figures (milieu de la matrice, choix d'affichage)
p.elv.CL_fig    = [0.3 1.3 0.02];  % -   [début fin pas] de CL de la figure d'autorité (choix d'affichage)

% Positions des composants, AVANT la CAO de la phase 5 : TOUTES HYPOTHÈSES,
% à valider par l'utilisateur (arrêt A). Repère : origine au bord d'attaque de
% l'emplanture, x vers l'arrière, y vers la droite, z vers le haut (repère xflr5).
% Deux façons de placer un poste du budget (libellé exact de p.masse.postes) :
%   "nacelle" : x absolu [m] dans la nacelle centrale (y = 0)
%   "aile"    : réparti sur l'aile proportionnellement à la surface, au point
%               x_BA(y) + k·c(y) (k = colonne x) ; ou ponctuel à ±y si y > 0
% Le groupe propulsif est séparé en moteur et hélice + adaptateur (masses de p.gp).
p.stab.pos = struct( ...
    'poste', {"Panneaux d'aile LW-PLA (2 demi-ailes)", "Longeron carbone 8 mm + clé arrière 3 mm", ...
              "Winglets + élevons", "Fuselage central PLA/PETG + trappe", ...
              "Câblage, connecteurs, velcro, PCB d'interconnexion", "Contrôleur de vol", ...
              "Raspberry Pi Zero 2 W + Camera Module 3 + microSD", "2 servos 9 g", "ESC 30 A", ...
              "GPS M10 + compas", "Récepteur ELRS + antennes"}, ...
    'mode',  {"aile", "aile", "aile", "nacelle", "nacelle", "nacelle", "nacelle", "aile", "nacelle", "nacelle", "nacelle"}, ...
    'x',     {0.42,   0.25,   0.70,   0.13,      0.13,      0.12,      -0.03,     0.55,   0.13,      0.20,      0.22}, ...
    'y',     {0,      0,      0.45,   0,         0,         0,         0,         0.30,   0,         0,         0}, ...
    'z',     {0,      0,      0,      0,         0,         0.01,      0,         0,      0,         0.02,      0});
% Décision du 13/10/2026 (arrêt A) : câblage + PCB et ESC avancés de 160 et 270 mm à 130 mm
% (levier de V1-STAB-03) ; tout le reste inchangé. HYPOTHÈSES : l'ESC à 130 mm tombe au
% même endroit que le fuselage (130) et près du contrôleur de vol (120) : place à vérifier
% en CAO (phase 5) ; les fils de phase du moteur s'allongent d'autant.
%   x : en m pour "nacelle" ; en fraction de corde locale (k) pour "aile"
%   y = 0 et mode "aile" : masse répartie sur toute l'aile ; y > 0 : deux masses à ±y
p.stab.x_moteur = 0.335;   % m  CG du moteur propulsif, monté au bord de fuite de l'emplanture (HYPOTHÈSE)
p.stab.x_helice = 0.365;   % m  CG de l'hélice + adaptateur (HYPOTHÈSE)
p.stab.z_moteur = 0.02;    % m  axe moteur au-dessus du plan de corde (HYPOTHÈSE ; garde au sol, phase 5)
p.stab.garde_helice_y = 0.10;  % m  station de contrôle de la garde hélice / bord de fuite (décision du 13/10/2026)
p.stab.Cm0_aile_min = 0;       % -  MOD-04 (validée le 13/10/2026) : Cm(CL = 0) de l'aile complète ≥ 0, sans braquage d'élevons
p.stab.mod = ["MOD-04", "V1-STAB-01", "validée le 13/10/2026 (telle quelle)"
              "MOD-05", "V1-STAB-03", "BROUILLON du 13/10/2026"];
% Encombrement (contrainte pour la phase 5) : longueur de la batterie selon x, cellules 21700
% couchées dans l'axe (utilisateur, 13/10/2026)
p.batt.L_x = 0.070;            % m
end
