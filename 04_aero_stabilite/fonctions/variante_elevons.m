function [var, info] = variante_elevons(D, xh, xh0, y0, y_e, yb, Wg, kappa, propres)
%VARIANTE_ELEVONS  Élevons d'une autre corde ou d'une autre envergure que ceux des T2 (estimation).
%
%   [var, info] = variante_elevons(D, xh, xh0, y0, y_e, yb, Wg, kappa, propres)
%     D     : données de cm_elevons pour les élevons des T2 (charnière xh0, début à y_e)
%     xh    : charnière de la variante (x/c) ; y0 : début de la variante [m] (≤ y_e, même
%             fin au saumon)
%     yb    : bords des bandes de D [m] (toute l'envergure) ; Wg : weissinger sur ces bandes
%     kappa : recalage de Weissinger sur la VLM de xflr5 (moment de portance des élevons des
%             T2 à CL constant)
%     propres : (facultatif, false par défaut) true si D.T contient les polaires XFoil des
%             profils à volet de la variante elle-même (charnière xh) : kv = [1 1]
%   Sortie : var, à placer dans D.var pour cm_elevons :
%     rt, rm : rapports profils minces variante / T2 de τ et de dCm/dδ (quart avant) ; la
%              réponse VLM des élevons des T2 est prise au braquage rt·δ (portance, traînée
%              induite) et leur moment de section est ramené à rm·δ
%     tau, dCm_dd, we : volet de la variante et part braquée de chaque bande
%     Aext, Cmext : prolongement vers l'emplanture (y0 < y_e) : Cl des bandes et moment de
%              portance par degré, à CL constant (Weissinger × kappa)
%     Ksec_ext : moment de section du prolongement par degré (rapport VLM / profils minces
%              des élevons des T2 conservé)
%     Ktr    : incidence induite de Trefftz (Weissinger) si prolongement, sinon vide :
%              cm_elevons y ajoute la traînée induite due au Cl du prolongement
%     kv = [rt rm] : polaires XFoil empruntées à la charnière des T2, incréments dus au volet
%              (Δα, Clmax ; ΔCm) multipliés par kv : efficacité visqueuse η supposée la même
%              à braquage égal (HYPOTHÈSE) ; kv = [1 1] avec les polaires propres
%   info : rt, rm, dwe (prolongement), Ksec_mince des T2.
%   HORS SKILL : théorie des profils minces (volet), méthode de Weissinger.

if nargin < 9, propres = false; end
[tau0, m0] = volet_mince(xh0);
[tau, m] = volet_mince(xh);
yb = yb(:);
we = D.we;
if y0 < y_e
    lo = min(abs(yb(1:end-1)), abs(yb(2:end)));
    hi = max(abs(yb(1:end-1)), abs(yb(2:end)));
    we = max(0, hi - max(lo, y0)) ./ (hi - lo);       % part de chaque bande dans |y| ≥ y0 (bandes loin de y = 0)
end
dwe = we - D.we;
assert(all(dwe > -1e-12), 'variante_elevons:envergure', 'la variante doit couvrir les élevons des T2');
Ksec_mince0 = m0 * sum(D.we .* D.c.^2 .* D.wy) / (D.S * D.MAC);
Aext = zeros(size(D.c));  Cmext = 0;  Ktr = [];
if any(dwe > 0)
    E = Wg.a_CL(tau * dwe * pi/180);
    Aext = kappa * E.Cl;
    Cmext = kappa * E.Cm;
    Ktr = Wg.Ktr;
end
kv = [tau / tau0, m / m0];
if propres, kv = [1 1]; end
var = struct('rt', tau / tau0, 'rm', m / m0, 'tau', tau, 'dCm_dd', m, 'we', we, 'Aext', Aext, 'Cmext', Cmext, ...
             'Ksec_ext', D.Ksec / Ksec_mince0 * m * sum(dwe .* D.c.^2 .* D.wy) / (D.S * D.MAC), ...
             'Ktr', Ktr, 'kv', kv);
info = struct('rt', var.rt, 'rm', var.rm, 'dwe', dwe, 'Ksec_mince0', Ksec_mince0);
end
