function rc = rendement_croisiere(mot, hel, ns, V_ocv, V, m, rho, aero, p)
%RENDEMENT_CROISIERE  Rendement global de propulsion en palier stabilisé, en fonction de V.
%
%   rc = rendement_croisiere(mot, hel, ns, V_ocv, V, m, rho, aero, p)
%     mot : constantes moteur ; hel : [D, pas] [pouces] ; ns : cellules
%     V_ocv : tension à vide par cellule [V] ; V : vitesses vraies [m/s]
%     m : masse [kg] ; rho [kg/m³] ; aero : modèle aéro ; p : paramètres
%   Sortie : structure de vecteurs (même taille que V) : η global et sa
%            décomposition, rapport cyclique d, courant, régime, faisabilité.
%
%   Palier stabilisé (C1 p.47) : portance = poids, poussée = traînée
%     CL = m·g/(q·S),  T = q·S·CD(CL)   (polaire.m)
%   puis point_propulsif.m en mode « poussée » (HORS SKILL).
%   NaN au-delà de CLmax (polaire.m) ou si le moteur ne suit pas (d > 1).

nV = numel(V);
champs = ["eta", "eta_h", "eta_mot", "eta_esc", "eta_bat", "d", "I", "rpm", "T", "J"];
for f = champs
    rc.(f) = NaN(size(V));
end
rc.faisable = false(size(V));
rc.V = V;
for k = 1:nV
    q  = 0.5 * rho * V(k)^2;                         % Pa, pression dynamique
    CL = m * p.const.g / (q * p.geo.S);              % palier : L = W
    CD = polaire(CL, aero);
    if ~isfinite(CD)
        continue                                     % au-delà de CLmax
    end
    T = q * p.geo.S * CD;                            % N, palier : T = D
    r = point_propulsif(mot, hel, ns, V_ocv, rho, V(k), "poussee", T, p);
    rc.eta(k) = r.eta_glob;   rc.eta_h(k) = r.eta_h;  rc.eta_mot(k) = r.eta_mot;
    rc.eta_esc(k) = r.eta_esc; rc.eta_bat(k) = r.eta_bat;
    rc.d(k) = r.d;  rc.I(k) = r.I;  rc.rpm(k) = r.rpm;  rc.T(k) = T;  rc.J(k) = r.J;
    rc.faisable(k) = r.faisable;
    if ~r.faisable
        rc.eta(k) = NaN;
    end
end
end
