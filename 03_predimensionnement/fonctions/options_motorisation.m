function [opt, tout] = options_motorisation(p, rho, rhoChaud, m_ns, classe)
%OPTIONS_MOTORISATION  Balaye KV × hélices en 3S et 4S, retient une hélice par batterie.
%
%   [opt, tout] = options_motorisation(p, rho, rhoChaud, m_ns, classe)
%     p        : paramètres ; rho : masse volumique ISA [kg/m³]
%     rhoChaud : masse volumique du jour chaud [kg/m³]
%     m_ns     : masses au décollage [kg] associées à p.batt.ns (3S1P, 4S1P)
%     classe   : "mot" (2212, défaut) ou "motE" (variante légère 2208) ;
%                fixe les KV, la fenêtre de puissance P_plage et D_min
%   Sorties :
%     tout : table de toutes les combinaisons (KV, batterie, hélice)
%     opt  : table des couples retenus, une ligne par KV et par batterie,
%            pour les seuls KV qui fonctionnent en 3S ET en 4S
%
%   Critères (HORS SKILL, tous à valider au banc moteur en phase 9) :
%   - durs :
%       I plein gaz, batterie pleine ≤ min(I_max moteur, 30 A ESC, 45 A cellule)
%       P_elec plein gaz, batterie pleine ≤ max(P_plage)
%       T_statique/poids ≥ 0,5 à tension nominale, ISA ET jour chaud (V1-PERF-08)
%   - signalés seulement (règles pratiques) :
%       P_elec batterie pleine ≥ min(P_plage)
%       vitesse de pas ≥ 1,5 × V_croisière
%   - choix : parmi les hélices valides, P_elec batterie pleine la plus proche
%             du milieu de P_plage.

if nargin < 5
    classe = "mot";
end
c   = p.(classe);
H   = p.hel.liste(p.hel.liste(:, 1) >= c.D_min, :);
nKV = numel(c.KV);
nB  = numel(p.batt.ns);
nH  = size(H, 1);
N   = nKV * nB * nH;

% Colonnes préallouées
KVc = zeros(N, 1);  Bat = strings(N, 1);  Hel = strings(N, 1);
Up = zeros(N, 1);  Un = Up;  Ip = Up;  Il = Up;  Pp = Up;  Pnom = Up;
rpm = Up;  Vp = Up;  Vr = Up;  Ts = Up;  TW = Up;  TWc = Up;  eta = Up;  FM = Up;
val = false(N, 1);  P_ok = val;  pas_ok = val;

i = 0;
for a = 1:nKV
    KV = c.KV(a);
    for j = 1:nB
        ns = p.batt.ns(j);
        for h = 1:nH
            i  = i + 1;
            rp = motorisation(KV, H(h, :), ns, p.batt.V_plein, rho, p, classe);       % courant max
            rn = motorisation(KV, H(h, :), ns, p.batt.V_nom,   rho, p, classe);       % mi-décharge
            rc = motorisation(KV, H(h, :), ns, p.batt.V_nom,   rhoChaud, p, classe);  % jour chaud
            KVc(i) = KV;
            Bat(i) = sprintf('%dS1P', ns);
            Hel(i) = sprintf('%gx%g', H(h, 1), H(h, 2));
            Up(i) = rp.U_batt;   Un(i) = rn.U_batt;
            Ip(i) = max(rp.I, rp.I_mot);
            Il(i) = min([rp.Imax_mot, p.mot.I_esc, p.batt.I_max]);
            Pp(i) = rp.P_elec;   Pnom(i) = rn.P_elec;
            rpm(i) = rn.rpm;     Vp(i) = rn.V_pas;   Vr(i) = rn.V_pas / p.req.V_cr;
            Ts(i) = rn.T;
            TW(i)  = rn.T / (m_ns(j) * p.const.g);
            TWc(i) = rc.T / (m_ns(j) * p.const.g);
            eta(i) = rn.eta_me;  FM(i) = rn.FM;
            val(i) = Ip(i) <= Il(i) && Pp(i) <= max(c.P_plage) && ...
                     min(TW(i), TWc(i)) >= p.req.TsurW_stat;
            P_ok(i)   = Pp(i) >= min(c.P_plage);
            pas_ok(i) = Vr(i) >= p.req.k_pitch;
        end
    end
end
tout = table(KVc, Bat, Hel, Up, Un, Ip, Il, Pp, Pnom, rpm, Vp, Vr, Ts, TW, TWc, eta, FM, val, P_ok, pas_ok, ...
    'VariableNames', {'KV', 'Batterie', 'Helice', 'U_plein_V', 'U_nom_V', 'I_max_A', ...
    'I_lim_A', 'P_plein_W', 'P_nom_W', 'rpm_nom', 'V_pas_ms', 'V_pas_sur_Vcr', ...
    'T_stat_N', 'T_sur_W', 'T_sur_W_chaud', 'eta_bat_arbre', 'FM', 'Valide', 'P_dans_plage', 'Pas_ok'});

% Une hélice par (KV, batterie) : P batterie pleine la plus proche du milieu de P_plage
cible = mean(c.P_plage);
garde = false(N, 1);
for a = 1:nKV
    for j = 1:nB
        idx = find(tout.KV == c.KV(a) & tout.Batterie == sprintf('%dS1P', p.batt.ns(j)) & tout.Valide);
        if ~isempty(idx)
            [~, k] = min(abs(tout.P_plein_W(idx) - cible));
            garde(idx(k)) = true;
        end
    end
end
opt = tout(garde, :);

% On ne garde que les KV qui fonctionnent en 3S ET en 4S
[nb, KVu] = groupcounts(opt.KV);
opt = opt(ismember(opt.KV, KVu(nb == nB)), :);
end
