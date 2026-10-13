function est = estimation_cd0_e(p, rho, T)
%ESTIMATION_CD0_E  Estimation de CD0 par la méthode de la skill, comparée au cahier.
%
%   est = estimation_cd0_e(p, rho, T)
%     p : paramètres (params_v1) ; rho [kg/m³], T [K] : atmosphère du calcul
%
%   1) Méthode de la skill (C3 p.85, aerodynamic-model.md) :
%        CD0 = Cfe·Swet/S, Cfe ≈ 0,0055 pour un avion léger à hélice.
%   2) Correction de Reynolds (HORS SKILL, signalée dans le rapport) : Cfe est
%      calibré vers Re ≈ 10^7 ; à Re ≈ 3·10^5 le frottement est plus fort.
%      On multiplie Cfe par le rapport des Cf de plaque plane turbulente
%      (Prandtl : Cf = 0,074·Re^-0,2) entre le Re du modèle et Re_ref.
%   Surface mouillée de l'aile (HORS SKILL, approximation usuelle) :
%        Swet_aile ≈ 2·(1 + 0,2·t/c)·S
%   La skill ne donne pas d'estimateur de e : seulement la plage 0,7-0,85
%   (SKILL.md, « Orders of magnitude »), qu'on balaie en sensibilité.

S = p.geo.S;
Swet_aile = 2 * (1 + 0.2 * p.cd0est.t_sur_c) * S;
Swet      = Swet_aile + p.cd0est.Swet_fus + p.cd0est.Swet_wlet;

% Viscosité dynamique par la loi de Sutherland (hors skill), puis Reynolds sur la MAC
mu = 1.458e-6 * T^1.5 / (T + 110.4);       % Pa·s
nu = mu / rho;                             % m²/s
Re = p.req.V_cr * p.geo.MAC / nu;          % à la vitesse de croisière

cf  = @(R) 0.074 * R.^(-0.2);              % plaque plane turbulente (Prandtl)
Cfe_corr = p.cd0est.Cfe_ref * cf(Re) / cf(p.cd0est.Re_ref);

est.Swet        = Swet;
est.Swet_sur_S  = Swet / S;
est.Re_cr       = Re;
est.Re_Vs       = p.req.Vs_cible * p.geo.MAC / nu;   % Reynolds au décrochage visé
est.CD0_skill   = p.cd0est.Cfe_ref * Swet / S;       % C3 p.85, brut
est.Cfe_corr    = Cfe_corr;
est.CD0_corrige = Cfe_corr * Swet / S;               % avec correction de Reynolds
end
