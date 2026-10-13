function r = motorisation(KV, hel, ns, V_ocv, rho, p, classe)
%MOTORISATION  Point de fonctionnement plein gaz au point fixe (V = 0, d = 1).
%
%   r = motorisation(KV, hel, ns, V_ocv, rho, p, classe)
%     KV     : constante de vitesse du moteur [tr/min/V]
%     hel    : [diamètre, pas] de l'hélice [pouces]
%     ns     : nombre de cellules en série (1P)
%     V_ocv  : tension à vide d'une cellule [V] (pleine charge ou nominale)
%     rho    : masse volumique [kg/m³] ; p : paramètres (params_v1)
%     classe : "mot" (2212, défaut) ou "motE" (2208)
%   Sortie : structure r (courant, tensions, puissances, régime, poussée,
%            vitesse de pas, figure of merit, limites).
%
%   HORS SKILL : cas particulier de point_propulsif.m (même modèle batterie,
%   ESC, moteur DC, hélice), à vitesse nulle et plein gaz.

if nargin < 7
    classe = "mot";
end
mot = constantes_moteur(KV, classe, p);
s = point_propulsif(mot, hel, ns, V_ocv, rho, 0, "gaz", 1, p);

PsurD = hel(2) / hel(1);
r.KV      = KV;
r.hel     = hel;
r.ns      = ns;
r.I       = s.I;                                     % A, courant batterie = cellule
r.I_mot   = s.I_mot;                                 % A, courant moteur
r.U_batt  = s.U_batt;                                % V, tension sous charge
r.U_cell  = s.U_batt / ns;                           % V
r.P_elec  = s.P_elec;                                % W, puissance tirée de la batterie
r.rpm     = s.rpm;
r.T       = s.T;                                     % N, poussée statique
r.P_arbre = s.P_arbre;                               % W
r.eta_me  = s.P_arbre / s.P_elec;                    % rendement batterie -> arbre
r.Ct0     = p.hel.a_t + p.hel.b_t * (PsurD - 0.5);
r.Cp0     = p.hel.a_p + p.hel.b_p * (PsurD - 0.5);
r.FM      = r.Ct0^1.5 / (r.Cp0 * sqrt(pi/2));        % figure of merit de l'hélice modèle
r.V_pas   = s.V_pas;                                 % m/s, vitesse de pas sous charge
r.Imax_mot = mot.Imax;
r.Rm = mot.Rm;  r.I0 = mot.I0;
end
