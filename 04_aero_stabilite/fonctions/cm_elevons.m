function R = cm_elevons(dg, CL, V, vr, mode, D)
%CM_ELEVONS  Cm et traînée de l'aile à élevons braqués : VLM, puis corrections visqueuses.
%
%   R = cm_elevons(dg, CL, V, vr, mode, D)
%     dg   : braquage géométrique des élevons [deg] (convention xflr5 : < 0 = vers le haut)
%     CL, V, vr : CL de l'avion, vitesse [m/s], vrillage au saumon [deg]
%     mode : "vlm"     T2 non visqueux seul (modèle quadratique en vrillage et braquage)
%            "bandes"  + correction en bandes : Cm XFoil du profil (à volet sur les
%                      élevons) − Cm de sa ligne moyenne en profils minces (méthode
%                      annoncée à l'arrêt B, procédure E4)
%            "complet" + perte de portance du volet : la VLM est prise au braquage
%                      efficace δe tel que −τ·δe = Δα XFoil moyen des élevons (moyenne
%                      pondérée par la corde), le moment de section restant au braquage
%                      géométrique
%     D    : données (voir stabilite.m §11) :
%            beta (6 × 5 : Cm0, pente dCm/dCL au point de référence, CDi = a0 + a1·CL + a2·CL²),
%            centre, echelle (base_vr_d) ; A (n × 4) : Cl local = A·[1 CL vr δ] ;
%            c, wy, we (n × 1) : corde, largeur et part braquée de chaque bande ;
%            Ksec : dérivée du moment de section de la VLM par degré de braquage ;
%            T (table_polaires_volet), Cm_mince, dCm_dd (/deg), tau ; S, MAC, nu
%            D.var (facultatif, variante_elevons) : élevons autres que ceux des T2 ; sans
%            ce champ, les élevons sont ceux des T2.
%   Sortie : R.Cm (au point de référence des T2), R.de (braquage efficace des élevons des
%   T2), R.CDi, R.CDp (traînée de profil de l'aile, intégrée en bandes ; NaN en "vlm"),
%   R.Cl (bandes), R.dCm (correction visqueuse en bandes), R.eta_a (Δα XFoil / profils
%   minces sur les élevons), R.eta_m (ΔCm de section XFoil / profils minces), R.ext
%   (braquage hors des polaires à volet), R.marge (Clmax − Cl de chaque bande, hors "vlm").
%   HORS SKILL : VLM, théorie des bandes, théorie des profils minces (volet).

if isfield(D, 'var')
    W = D.var;
else
    W = struct('rt', 1, 'rm', 1, 'tau', D.tau, 'dCm_dd', D.dCm_dd, 'we', D.we, ...
               'Aext', zeros(size(D.c)), 'Cmext', 0, 'Ksec_ext', 0, 'kv', [1 1]);
end
R = struct('dg', dg, 'de', W.rt * dg, 'Cm', NaN, 'CDi', NaN, 'CDp', NaN, 'Cl', [], 'dCm', 0, ...
           'eta_a', NaN, 'eta_m', NaN, 'ext', false, 'marge', []);
eta = 1;                                               % Δα XFoil / profils minces (1 hors "complet")
if mode ~= "vlm"
    Re = V * D.c / D.nu;
    dl = dg * W.we;                                    % braquage local de chaque bande
    pv = @(champ, d, Cl) interp_polaires_volet(D.T, champ, d, Cl, Re);
    if mode == "complet" && dg ~= 0
        ok = false;
        for it = 1:20                                  % point fixe : le Cl local dépend de δe
            Cl = D.A * [1; CL; vr; R.de] + W.Aext * (eta * dg);
            da = W.kv(1) * (pv("alpha", dl, Cl) - pv("alpha", 0, Cl));
            eta = -sum(da .* D.c .* D.wy) / (W.tau * dg * sum(W.we .* D.c .* D.wy));
            de = eta * W.rt * dg;
            ok = abs(de - R.de) < 1e-6;
            R.de = de;
            if ok, break; end
        end
        assert(ok, 'cm_elevons:convergence', 'braquage efficace non convergé (δ = %.2f°)', dg);
    end
    R.Cl = D.A * [1; CL; vr; R.de] + W.Aext * (eta * dg);
    [Cm_xf, ext] = pv("Cm", dl, R.Cl);
    Cx = pv("Clmax", dl, R.Cl);
    if dg ~= 0                                         % kv : polaires empruntées à une autre charnière
        Cm_0 = pv("Cm", 0, R.Cl);
        Cm_xf = Cm_0 + W.kv(2) * (Cm_xf - Cm_0);
        Cx0 = pv("Clmax", 0, R.Cl);
        Cx = Cx0 + W.kv(1) * (Cx - Cx0);
        R.eta_a = eta;
        R.eta_m = sum((Cm_xf - Cm_0) .* D.c.^2 .* D.wy) / (W.dCm_dd * sum(dl .* D.c.^2 .* D.wy));
    end
    R.ext = any(ext);
    R.dCm = sum((Cm_xf - D.Cm_mince - W.dCm_dd * dl) .* D.c.^2 .* D.wy) / (D.S * D.MAC);
    R.CDp = sum(pv("CD", dl, R.Cl) .* D.c .* D.wy) / D.S;
    R.marge = Cx - R.Cl;
end
k = base_vr_d(vr, R.de, D.centre, D.echelle) * D.beta;
R.Cm = k(1) + k(2) * CL + R.dCm + D.Ksec * (W.rm * dg - R.de) + (W.Cmext * eta + W.Ksec_ext) * dg;
R.CDi = k(3) + k(4) * CL + k(5) * CL^2;
end
