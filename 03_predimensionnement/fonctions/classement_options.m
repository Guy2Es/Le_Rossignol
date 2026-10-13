function [R, tab] = classement_options(opts, p, rhoI, rhoH, m_ns, aeroN, aeroW, V)
%CLASSEMENT_OPTIONS  Évalue et classe les options moteur sur le rendement en croisière.
%
%   [R, tab] = classement_options(opts, p, rhoI, rhoH, m_ns, aeroN, aeroW, V)
%     opts  : options (p.opt complété des variantes E, E2) : nom, classe, KV,
%             hel3S, hel4S, thr3S, thr4S (1 = libre, NaN = calculé par
%             limite_gaz.m pour tenir P_lim et la limite de courant), P_lim
%     p     : paramètres ; rhoI, rhoH : ρ ISA et jour chaud [kg/m³]
%     m_ns  : masses 3S1P et 4S1P du budget du cahier (moteur 2212) [kg]
%     aeroN : modèle aéro nominal ; aeroW : pire cas (CD0 = 0,035)
%     V     : vitesses du balayage [m/s] (courbes η(V))
%   Sorties :
%     R   : structure par option (statique, croisière, autonomies, courbes)
%     tab : table triée par autonomie réelle 4S1P à 55 km/h (V1-PERF-03, −30 %)
%
%   Masse : le poste « moteur + hélice repliable + cône » du budget (62 g)
%   est remplacé par la masse explicite du groupe propulsif (masse_option.m :
%   moteur de fiche + pales + moyeu-cône réels). Les performances sont
%   calculées à cette masse (cellules à 69 g).
%   Autonomies : autonomie_distance.m avec le η global calculé au point de
%   vol (rendement_croisiere.m), à tension nominale, ISA.
%   Cas d'erreur (cas_erreur.m) : 4S1P avec le THR_MAX du fichier 3S, puis
%   sans bridage, hélice 4S montée.
%   HORS SKILL pour toute la partie propulsive (à recaler en phase 9).

nO = numel(opts);
ns = p.batt.ns;
R = struct('nom', cell(1, nO));
for o = 1:nO
    op  = opts(o);
    mot = constantes_moteur(op.KV, op.classe, p);
    [m, gp] = masse_option(mot, m_ns, p);
    R(o).nom = op.nom;  R(o).classe = p.(op.classe).court;  R(o).KV = op.KV;
    R(o).mot = mot;  R(o).gp = gp;  R(o).m_g = gp.m_ns;
    hel = {op.hel3S, op.hel4S};
    thr = [op.thr3S, op.thr4S];
    for b = 1:numel(ns)
        % Bridage des gaz (THR_MAX) si demandé
        if isnan(thr(b))
            L = limite_gaz(mot, hel{b}, ns(b), rhoI, p, op.P_lim);
            thr(b) = L.thr;
            R(o).bridage(b) = L;
        end
        % Point fixe : batterie pleine (P et I max) et nominale (T/W ISA, jour chaud)
        rp = point_propulsif(mot, hel{b}, ns(b), p.batt.V_plein, rhoI, 0, "gaz", thr(b), p);
        rn = point_propulsif(mot, hel{b}, ns(b), p.batt.V_nom,   rhoI, 0, "gaz", thr(b), p);
        rh = point_propulsif(mot, hel{b}, ns(b), p.batt.V_nom,   rhoH, 0, "gaz", thr(b), p);
        R(o).P_max(b)  = rp.P_elec;
        R(o).I_max(b)  = max(rp.I, rp.I_mot);
        R(o).I_lim(b)  = min([mot.Imax, p.mot.I_esc, p.batt.I_max]);
        R(o).TW(b)     = rn.T / (m(b) * p.const.g);
        R(o).TW_chaud(b) = rh.T / (m(b) * p.const.g);
        % Croisière : η(V) à tension nominale, ISA, CD0 nominal
        cr = rendement_croisiere(mot, hel{b}, ns(b), p.batt.V_nom, V, m(b), rhoI, aeroN, p);
        cr.faisable = cr.faisable & cr.d <= thr(b);   % le bridage s'applique aussi en vol
        R(o).courbe(b) = cr;
        % η aux vitesses de V1-PERF-03/04/05 (CD0 nominal et pire cas)
        for v = 1:numel(p.req.V_eta)
            cN = rendement_croisiere(mot, hel{b}, ns(b), p.batt.V_nom, p.req.V_eta(v), m(b), rhoI, aeroN, p);
            cW = rendement_croisiere(mot, hel{b}, ns(b), p.batt.V_nom, p.req.V_eta(v), m(b), rhoI, aeroW, p);
            R(o).eta(b, v)   = cN.eta;   R(o).eta_W(b, v) = cW.eta;
            R(o).d(b, v)     = cN.d;     R(o).det(b, v, :) = [cN.eta_h, cN.eta_mot, cN.eta_esc, cN.eta_bat];
            R(o).rpm(b, v)   = cN.rpm;   R(o).I_cr(b, v) = cN.I;
            R(o).cr_ok(b, v) = cN.faisable && cN.d <= thr(b);
            % Autonomie réelle (2 lignes : −20 %, −30 %) avec ce η
            aN = autonomie_distance(p.req.V_eta(v), m(b), ns(b), rhoI, p, aeroN, cN.eta);
            aW = autonomie_distance(p.req.V_eta(v), m(b), ns(b), rhoI, p, aeroW, cW.eta);
            R(o).t(b, v, :)   = aN.t_reel;
            R(o).t_W(b, v, :) = aW.t_reel;
            R(o).t_theo(b, v) = aN.t_min;
        end
    end
    R(o).thr = thr;
    R(o).hel = hel;
    R(o).err = cas_erreur(mot, hel{ns == 4}, thr(ns == 3), rhoI, p);
end

% Table de classement (V_eta = [40 55] km/h : indice 2 = 55 km/h, 1 = 40 km/h)
nom = string({R.nom})';
t03 = arrayfun(@(r) r.t(2, 2, 2), R)';               % 4S, 55 km/h, −30 %
tab = table(nom, ...
    arrayfun(@(r) r.eta(2, 2), R)', arrayfun(@(r) r.eta(2, 1), R)', arrayfun(@(r) r.eta(1, 2), R)', ...
    t03, arrayfun(@(r) r.t_W(2, 2, 2), R)', arrayfun(@(r) r.t(2, 1, 2), R)', arrayfun(@(r) r.t(1, 2, 2), R)', ...
    arrayfun(@(r) min([r.TW, r.TW_chaud]), R)', arrayfun(@(r) max(r.P_max), R)', ...
    arrayfun(@(r) r.m_g(2), R)', ...
    'VariableNames', {'Option', 'eta_4S_55', 'eta_4S_40', 'eta_3S_55', 't03_min', 't03_CD035_min', ...
    't04_min', 't05_min', 'TW_min', 'P_max_W', 'm_4S_g'});
[tab, ordre] = sortrows(tab, 't03_min', 'descend');
tab.Rang = (1:height(tab))';
R = R(ordre);
end
