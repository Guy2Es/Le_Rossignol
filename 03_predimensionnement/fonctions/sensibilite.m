function s = sensibilite(p, m4S, mDP, rhos)
%SENSIBILITE  Effet des paramètres incertains sur l'autonomie et le point de conception.
%
%   s = sensibilite(p, m4S, mDP, rhos)
%     p    : paramètres nominaux
%     m4S  : masse 4S1P [kg] (autonomie)
%     mDP  : masse du point de conception [kg] (800 g, V1-MAS-01)
%     rhos : [ρ ISA, ρ jour chaud] [kg/m³]
%   Sortie : table, une ligne par variation, avec
%     - l'autonomie théorique 4S1P à 55 km/h (V1-PERF-03), base ISA,
%       CD0 nominal, η = p.prop.eta ;
%     - le P/W de conception : enveloppe des contraintes à la W/S de mDP,
%       PIRE CAS ISA / jour chaud (même définition que le point retenu).
%   Variations (demande de la phase 3) : η ±20 %, e 0,70/0,85,
%   CD0 0,025/0,035, masse +50 g (sur m4S et sur mDP) ; FM ±20 % ajouté
%   (pèse sur le lancer main). Les Δ en % se lisent sur la base nominale.

base = evaluer(p, m4S, mDP, rhos);

var = { ...
    "η (rendement global)",     "prop", "eta", p.sens.eta;
    "e (Oswald)",               "aero", "e",   p.sens.e;
    "CD0",                      "aero", "CD0", p.sens.CD0;
    "Masse +50 g",              "",     "",    [0 p.masse.ajout_sens];
    "FM hélice (point fixe)",   "prop", "FM",  p.sens.FM};

nV = size(var, 1);
nom = strings(nV, 1); bas = zeros(nV, 1); haut = bas;
t_bas = bas; t_haut = bas; pw_bas = bas; pw_haut = bas;
for i = 1:nV
    vals = var{i, 4};
    res = zeros(2, 2);
    for j = 1:2
        q = p;  dm = 0;
        if var{i, 2} == ""
            dm = vals(j) / 1000;                     % surcharge de masse [g -> kg]
        else
            q.(var{i, 2}).(var{i, 3}) = vals(j);
            if var{i, 3} == "eta"
                q.prop.eta_montee = vals(j);         % η s'applique aussi à la montée et au virage
            end
        end
        r = evaluer(q, m4S + dm, mDP + dm, rhos);
        res(j, :) = [r.t, r.PW];
    end
    nom(i) = var{i, 1};
    bas(i) = vals(1);  haut(i) = vals(2);
    t_bas(i) = res(1, 1);  t_haut(i) = res(2, 1);
    pw_bas(i) = res(1, 2); pw_haut(i) = res(2, 2);
end
s.base = base;
s.table = table(nom, bas, haut, t_bas, t_haut, ...
    100 * (t_bas / base.t - 1), 100 * (t_haut / base.t - 1), ...
    pw_bas, pw_haut, 100 * (pw_bas / base.PW - 1), 100 * (pw_haut / base.PW - 1), ...
    'VariableNames', {'Parametre', 'Bas', 'Haut', 't_bas_min', 't_haut_min', ...
    'dt_bas_pct', 'dt_haut_pct', 'PW_bas', 'PW_haut', 'dPW_bas_pct', 'dPW_haut_pct'});
end

function r = evaluer(p, m4S, mDP, rhos)
% Autonomie théorique 4S1P à 55 km/h (ISA) et P/W de conception (pire cas)
a = autonomie_distance(p.req.V_cr, m4S, 4, rhos(1), p, p.aero, p.prop.eta);
r.t = a.t_min;
WS = mDP * p.const.g / p.geo.S;
r.PW = 0;
for k = 1:numel(rhos)
    cc = contraintes_PW(WS, rhos(k), p, p.aero);
    r.PW = max(r.PW, cc.enveloppe);
end
end
