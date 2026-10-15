function [tau, dCm_dd] = volet_mince(xh)
%VOLET_MINCE  Volet de bord de fuite en théorie des profils minces.
%
%   [tau, dCm_dd] = volet_mince(xh)
%     xh : position de la charnière (x/c), cos θh = 1 − 2·xh
%   Sorties :
%     tau    : efficacité de portance, Δα0 = −τ·δ ; τ = 1 − θh/π + sin θh/π
%     dCm_dd : dérivée du Cm au quart avant par degré de braquage,
%              −½·sin θh·(1 − cos θh)·π/180 (maximale en valeur absolue à xh = 0,75)
%   HORS SKILL (la skill ne traite pas les volets) : même théorie qu'aux §5 et §10 de
%   stabilite.m.

th = acos(1 - 2*xh);
tau = 1 - th/pi + sin(th)/pi;
dCm_dd = -0.5 * sin(th) .* (1 - cos(th)) * pi/180;
end
