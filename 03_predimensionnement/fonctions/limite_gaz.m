function L = limite_gaz(mot, hel, ns, rho, p, P_lim)
%LIMITE_GAZ  Rapport cyclique maximal (THR_MAX) qui respecte P_lim et la limite de courant.
%
%   L = limite_gaz(mot, hel, ns, rho, p, P_lim)
%     mot : constantes moteur ; hel : [D, pas] [pouces] ; ns : cellules
%     rho : masse volumique [kg/m³] ; p : paramètres
%     P_lim : puissance batterie maximale [W] (200 W = borne haute de V1-PROP-02)
%   Sortie : structure L
%     thr    : rapport cyclique maximal retenu (≤ 1)
%     d_P    : rapport cyclique où P_batt = P_lim
%     d_I    : rapport cyclique où I = min(I_max moteur, ESC, cellule)
%     actif  : "puissance", "courant" ou "aucune" (pas de bridage)
%     P, I   : puissance [W] et courant max [A] au bridage
%
%   HORS SKILL. Cas le plus défavorable : batterie pleine (V_plein), point
%   fixe (V = 0), où courant et puissance sont maximaux. Le rapport cyclique
%   est l'image de THR_MAX d'ArduPilot si la commande de l'ESC est linéaire :
%   correspondance à vérifier au banc (phase 9).

I_lim = min([mot.Imax, p.mot.I_esc, p.batt.I_max]);
etat  = @(d) point_propulsif(mot, hel, ns, p.batt.V_plein, rho, 0, "gaz", d, p);
fP = @(d) etat(d).P_elec - P_lim;
fI = @(d) courant(etat(d)) - I_lim;

L.d_P = 1;  L.d_I = 1;
if fP(1) > 0
    L.d_P = fzero(fP, [0.1 1]);
end
if fI(1) > 0
    L.d_I = fzero(fI, [0.1 1]);
end
[L.thr, k] = min([L.d_P, L.d_I]);
if L.thr >= 1
    L.actif = "aucune";
else
    L.actif = ternaire(k == 1, "puissance", "courant");
end
r = etat(L.thr);
L.P = r.P_elec;
L.I = courant(r);
L.I_lim = I_lim;
end

function I = courant(r)
% Courant le plus élevé du circuit (batterie ou moteur)
I = max(r.I, r.I_mot);
end

function s = ternaire(cond, a, b)
if cond
    s = a;
else
    s = b;
end
end
