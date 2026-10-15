function [xb, x0] = position_batterie(M, mb, xCG)
%POSITION_BATTERIE  Position de la batterie qui place le CG à la cible.
%
%   [xb, x0] = position_batterie(M, mb, xCG)
%     M   : masses sans batterie (table masses_composants : m [kg], x [m])
%     mb  : masse de la batterie [kg] (scalaire ou tableau)
%     xCG : position visée du CG [m] (scalaire ou tableau compatible avec mb)
%   Sorties :
%     xb : position du CG de la batterie [m]
%     x0 : CG de l'avion sans batterie [m]
%
%   Équilibre des moments autour du BA de l'emplanture :
%     (m0 + mb)·xCG = m0·x0 + mb·xb  ⇒  xb = xCG + m0·(xCG − x0)/mb
%   Conséquence (V1-STAB-03) : les positions 3S1P et 4S1P coïncident si x0 =
%   xCG ; leur écart vaut m0·(xCG − x0)·(1/mb3 − 1/mb4).

m0 = sum(M.m);
x0 = sum(M.m .* M.x) / m0;
xb = xCG + m0 .* (xCG - x0) ./ mb;
end
