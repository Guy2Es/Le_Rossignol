function E = cas_erreur(mot, hel4S, thr3S, rho, p)
%CAS_ERREUR  Erreur humaine : batterie 4S1P avec un mauvais réglage de THR_MAX.
%
%   E = cas_erreur(mot, hel4S, thr3S, rho, p)
%     mot   : constantes moteur (constantes_moteur.m)
%     hel4S : hélice montée [D, pas] en pouces (hélice unique : même en 3S)
%     thr3S : THR_MAX du fichier de paramètres 3S
%     rho   : masse volumique [kg/m³] (ISA : cas le plus chargé)
%     p     : paramètres
%   Sortie : structure E, une case par cas :
%     (1) 4S1P branchée avec le fichier 3S (d = thr3S)
%     (2) 4S1P sans aucun bridage (d = 1)
%   Champs : nom, d, P [W], I_b (batterie) [A], I_m (moteur = ESC) [A], rpm,
%     I_ref [A] et ref : référence continue (limite publiée, sinon plus fort
%     courant d'essai de la fiche, signalé), ratios aux limites (référence
%     continue, moteur courte durée, ESC, cellule, puissance de fiche, régime
%     max de l'hélice n_max = p.gp.k_rpm / D) et verdicts.
%
%   HORS SKILL. Point fixe (V = 0), batterie pleine (V_plein) : courant et
%   puissance maximaux, donc cas enveloppe du lancer et du début de montée.
%   « Survit 10 s » : le courant moteur reste sous la limite de courte durée
%   de la fiche (I30, tenue t_I30 ≥ 10 s) et la puissance sous P_fiche.

d   = [thr3S, 1];
nom = ["4S1P avec le fichier 3S (THR_MAX " + strrep(sprintf('%.2f', thr3S), '.', ',') + ")", ...
       "4S1P sans bridage (THR_MAX 1)"];
% Référence « continue » : limite publiée, sinon plus fort courant d'essai de la fiche
if isfinite(mot.I_cont)
    I_ref = mot.I_cont;   ref = "continu";
else
    I_ref = mot.I_essai;  ref = "essai de fiche, durée non publiée";
end
E = struct('nom', cell(1, 2));
for k = 1:2
    r = point_propulsif(mot, hel4S, 4, p.batt.V_plein, rho, 0, "gaz", d(k), p);
    E(k).nom = nom(k);
    E(k).d   = d(k);
    E(k).P   = r.P_elec;                         % W, puissance batterie
    E(k).I_b = r.I;                              % A, courant batterie (= cellule en 1P)
    E(k).I_m = r.I_mot;                          % A, courant moteur = courant ESC
    E(k).rpm = r.rpm;
    % Ratios aux limites (> 1 : limite dépassée)
    E(k).I_ref = I_ref;  E(k).ref = ref;
    E(k).r_mot_cont = E(k).I_m / I_ref;
    E(k).r_mot_30s  = E(k).I_m / mot.I30;
    E(k).r_esc      = max(E(k).I_b, E(k).I_m) / p.mot.I_esc;
    E(k).r_cell     = E(k).I_b / p.batt.I_max;
    E(k).r_P        = E(k).P / mot.P_fiche;      % NaN si pas de puissance de fiche
    E(k).n_max      = p.gp.k_rpm / hel4S(1);         % tr/min, régime max de l'hélice (APC E : 150 000 / D)
    E(k).r_rpm      = E(k).rpm / E(k).n_max;
    % Verdicts
    E(k).survit_10s = E(k).r_mot_30s <= 1 && ~(E(k).r_P > 1) && mot.t_I30 >= p.gp.t_lancer;
    E(k).esc_ok  = E(k).r_esc  <= 1;
    E(k).cell_ok = E(k).r_cell <= 1;
    E(k).rpm_ok  = E(k).r_rpm  <= 1;
end
end
