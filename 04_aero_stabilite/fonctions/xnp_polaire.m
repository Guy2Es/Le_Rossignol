function N = xnp_polaire(P, xcg, MAC, plage_CL)
%XNP_POLAIRE  Point neutre d'une polaire T2 xflr5, de deux façons indépendantes.
%
%   N = xnp_polaire(P, xcg, MAC, plage_CL)
%     P        : polaire (lire_polaire_T2)
%     xcg      : abscisse du point de référence des moments de la polaire [m]
%     MAC      : corde de référence de xflr5 (Cm = M / (q·S·MAC)) [m]
%     plage_CL : [CL_bas CL_haut] des points retenus (optionnel, tous par défaut)
%   Méthode 1 (pente du moment, skill C2 p.21-22) :
%       Cm = Cm0 − CL·(x_NP − x_cg)/MAC   (Cm positif cabreur, x vers l'arrière)
%       d'où dCm/dCL = −(x_NP − x_cg)/MAC = −MS_statique (marge, CG devant le NP : pente < 0)
%       x_NP = x_cg − MAC·dCm/dCL
%   Méthode 2 (définition affichée par xflr5 dans le panneau de résultats,
%   « XNP = d(XCp·CL)/dCL ») : pente de XCP·CL contre CL.
%   Sortie : x_NP_Cm, x_NP_xcp [m] ; pente_Cm, pente_xcp ; ecart_Cm, ecart_xcp
%   (plus grand écart des points à leur droite : contrôle de linéarité) ;
%   n (nombre de points) ; stable (pente de Cm négative).

if nargin < 4 || isempty(plage_CL), plage_CL = [-Inf Inf]; end
u = P.CL >= plage_CL(1) & P.CL <= plage_CL(2);
assert(nnz(u) >= 2, 'xnp_polaire:points', 'moins de 2 points dans la plage de CL');
cl = P.CL(u);

c1 = polyfit(cl, P.Cm(u), 1);
c2 = polyfit(cl, P.XCP(u) .* cl, 1);
N.pente_Cm  = c1(1);
N.pente_xcp = c2(1);
N.x_NP_Cm   = xcg - MAC * c1(1);
N.x_NP_xcp  = c2(1);
N.ecart_Cm  = max(abs(P.Cm(u) - polyval(c1, cl)));
N.ecart_xcp = max(abs(P.XCP(u) .* cl - polyval(c2, cl)));
N.n = nnz(u);
N.stable = c1(1) < 0;
end
