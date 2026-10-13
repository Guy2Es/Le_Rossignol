function tab = meilleure_helice(classe, ns, m, P_lim, p, rhoI, rhoH, aero)
%MEILLEURE_HELICE  Pour une classe de moteur, évalue chaque couple KV / hélice sur le η de croisière.
%
%   tab = meilleure_helice(classe, ns, m, P_lim, p, rhoI, rhoH, aero)
%     classe : "motE" ou "motEh" (KV et D_min lus dans p.(classe))
%     ns : cellules ; m : masse [kg] ; P_lim : puissance batterie max [W]
%     p : paramètres ; rhoI, rhoH : ρ ISA et jour chaud ; aero : modèle aéro
%   Sortie : table, une ligne par couple (KV, hélice) :
%     thr (THR_MAX nécessaire pour P_lim et la limite de courant), contrainte
%     de bridage, P et I au bridage, T/W statique ISA et jour chaud au
%     bridage, η global à 55 km/h, rapport cyclique de croisière, validité
%     (T/W ≥ 0,5 et croisière possible sous le bridage).
%
%   Critère de choix de la variante E (demande : moteur léger, rendement) :
%   le η de croisière à 55 km/h (V1-PERF-03), et non la puissance installée.
%   HORS SKILL (modèles de point_propulsif.m), à recaler en phase 9.

c = p.(classe);
H = p.hel.liste(p.hel.liste(:, 1) >= c.D_min, :);
N = numel(c.KV) * size(H, 1);
KV = zeros(N, 1);  Hel = strings(N, 1);  D = zeros(N, 2);
thr = KV;  actif = Hel;  P = KV;  I = KV;  TW = KV;  TWc = KV;  eta = KV;  dcr = KV;  val = false(N, 1);
i = 0;
for a = 1:numel(c.KV)
    mot = constantes_moteur(c.KV(a), classe, p);
    for h = 1:size(H, 1)
        i = i + 1;
        L  = limite_gaz(mot, H(h, :), ns, rhoI, p, P_lim);
        rn = point_propulsif(mot, H(h, :), ns, p.batt.V_nom, rhoI, 0, "gaz", L.thr, p);
        rh = point_propulsif(mot, H(h, :), ns, p.batt.V_nom, rhoH, 0, "gaz", L.thr, p);
        cr = rendement_croisiere(mot, H(h, :), ns, p.batt.V_nom, p.req.V_cr, m, rhoI, aero, p);
        KV(i) = c.KV(a);  Hel(i) = sprintf('%gx%g', H(h, 1), H(h, 2));  D(i, :) = H(h, :);
        thr(i) = L.thr;  actif(i) = L.actif;  P(i) = L.P;  I(i) = L.I;
        TW(i)  = rn.T / (m * p.const.g);
        TWc(i) = rh.T / (m * p.const.g);
        eta(i) = cr.eta;  dcr(i) = cr.d;
        val(i) = min(TW(i), TWc(i)) >= p.req.TsurW_stat && cr.faisable && cr.d <= L.thr;
    end
end
tab = table(KV, Hel, D, thr, actif, P, I, TW, TWc, eta, dcr, val, ...
    'VariableNames', {'KV', 'Helice', 'hel', 'THR_MAX', 'Bridage', 'P_max_W', 'I_max_A', ...
    'T_sur_W', 'T_sur_W_chaud', 'eta_55', 'd_croisiere', 'Valide'});
end
