function G = garde_helice(p, g)
%GARDE_HELICE  Garde entre l'hélice propulsive et le bord de fuite de l'aile en flèche.
%
%   G = garde_helice(p, g)
%     p : paramètres (p.stab, p.prop, p.const)
%     g : géométrie de l'aile (geometrie_aile), repère du BA de l'emplanture
%   Sortie (m) :
%     R           rayon du disque (p.prop.D_nominal)
%     y_ctrl      station de contrôle p.stab.garde_helice_y
%     xBF_ctrl    abscisse du bord de fuite à y_ctrl
%     garde_ctrl  x_helice − xBF_ctrl
%     xBF_max     bord de fuite le plus en arrière sur le disque (|y| ≤ R)
%     garde_min   x_helice − xBF_max (garde la plus faible face au disque)
%     xBF_0, gap_moteur_0 : bord de fuite à l'emplanture, x_moteur − xBF_0
%   Limites : le plan de l'hélice est réduit au CG de l'hélice + adaptateur
%   (p.stab.x_helice) ; le braquage des élevons et l'épaisseur du moyeu ne sont
%   pas comptés (signalé dans le rapport).

G.R = p.prop.D_nominal * p.const.in / 2;
xBF = @(y) g.xBAf(abs(y)) + g.cf(abs(y));
G.y_ctrl     = p.stab.garde_helice_y;
G.xBF_ctrl   = xBF(G.y_ctrl);
G.garde_ctrl = p.stab.x_helice - G.xBF_ctrl;
yd = linspace(-G.R, G.R, 401);
G.xBF_max    = max(xBF(yd));
G.garde_min  = p.stab.x_helice - G.xBF_max;
G.xBF_0      = xBF(0);
G.gap_moteur_0 = p.stab.x_moteur - G.xBF_0;
end
