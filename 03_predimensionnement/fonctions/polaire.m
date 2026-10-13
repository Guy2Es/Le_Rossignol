function [CD, CL] = polaire(CL, aero)
%POLAIRE  Point d'entrée UNIQUE du modèle aérodynamique : CD = f(CL).
%
%   [CD, CL] = polaire(CL, aero)
%     CL   : coefficient de portance demandé (scalaire ou tableau)
%     aero : structure du modèle (p.aero de params_v1, ou sortie de
%            import_polaire_xflr5)
%   Sorties :
%     CD : coefficient de traînée ; NaN si CL > CLmax (aile décrochée :
%          hors du domaine de validité du modèle, C1 p.18 « Validity »)
%     CL : renvoyé tel quel (même taille que CD), pour chaîner les appels
%
%   aero.type = "parabolique" :
%     CD = CD0 + k·CL²,  k = 1/(π·λ·e)         (C1 p.18 et p.47)
%     Hypothèses (aerodynamic-model.md) : incompressible, polaire symétrique
%     (traînée mini à CL = 0), domaine linéaire, CL ≤ CLmax.
%   aero.type = "xflr5" :
%     interpolation pchip de CD(CL) dans la table importée (phase 4) ; aucune
%     autre fonction du projet n'a besoin d'être modifiée.

switch aero.type
    case "parabolique"
        k  = 1 / (pi * aero.lambda * aero.e);     % facteur de traînée induite (C1 p.47)
        CD = aero.CD0 + k .* CL.^2;               % polaire parabolique (C1 p.18)
    case "xflr5"
        % Branche montante de la polaire, triée par CL croissant
        CD = interp1(aero.table.CL, aero.table.CD, CL, 'pchip', NaN);
    otherwise
        error('polaire:type', 'Type de polaire inconnu : %s', aero.type);
end

% Au-delà de CLmax, le vol stabilisé est impossible : on renvoie NaN
CD(CL > aero.CLmax) = NaN;
end
