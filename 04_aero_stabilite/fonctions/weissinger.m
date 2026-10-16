function W = weissinger(yb, cf, xBAf, xref, S, MAC)
%WEISSINGER  Ligne portante de Weissinger (méthode « L ») : réponses linéaires de l'aile plane.
%
%   W = weissinger(yb, cf, xBAf, xref, S, MAC)
%     yb   : bords des bandes sur toute l'envergure [m], croissants (n + 1 valeurs)
%     cf, xBAf : lois en plan c(|y|) et x du bord d'attaque x_BA(|y|) [m]
%     xref : point de référence des moments [m] ; S, MAC : surface et corde de référence
%   Un tourbillon en fer à cheval par bande : segment lié sur le quart avant (en flèche),
%   jambes libres parallèles à x ; condition de glissement au trois-quarts arrière du
%   milieu de la bande. Aile plane, sans dièdre ni winglets ; incidence locale petite.
%   Sortie (V = 1, incidences en rad) :
%     W.y, W.c, W.wy, W.xc4 : bandes (milieu, corde, largeur, quart avant)
%     W.K   : n × n, Cl local = K·α_local (α_local : incidence de chaque bande)
%     W.ClA : Cl local pour α uniforme = 1 rad ; W.CLa, W.Cma : CL et Cm (à xref) par rad
%     W.reponse(da) : [Cl, CL, Cm] pour une incidence locale da (n × 1, rad) ;
%     W.a_CL(da)    : idem à CL constant (incidence d'ensemble réajustée)
%     W.Ktr : n × n, incidence induite dans le plan de Trefftz (sillage plan, divisée par 2 :
%             ligne portante) au milieu de chaque bande, αi = Ktr·(c.*Cl) ;
%     W.CDi(Cl) : traînée induite d'une répartition de Cl locaux, Σ c·Cl·αi·wy / S
%   HORS SKILL (méthode tourbillonnaire) : ne sert qu'à des rapports entre deux répartitions
%   d'incidence (prolongement des élevons), recalés sur la VLM de xflr5, et à des écarts de
%   traînée induite entre deux répartitions de portance.

yb = yb(:);
n = numel(yb) - 1;
ya = yb(1:end-1);  yB = yb(2:end);
ym = (ya + yB) / 2;
xq = @(y) xBAf(abs(y)) + cf(abs(y)) / 4;
P1 = [xq(ya), ya];  P2 = [xq(yB), yB];                     % segment lié de chaque bande
Pc = [xBAf(abs(ym)) + 3 * cf(abs(ym)) / 4, ym];             % points de contrôle
L = 1e3 * (yb(end) - yb(1));                               % jambes libres « à l'infini »
Far1 = [P1(:, 1) + L, P1(:, 2)];  Far2 = [P2(:, 1) + L, P2(:, 2)];
A = seg(Pc, Far1, P1) + seg(Pc, P1, P2) + seg(Pc, P2, Far2);   % vitesse verticale par Γ unité
W.y = ym;  W.c = cf(abs(ym));  W.wy = yB - ya;  W.xc4 = xBAf(abs(ym)) + W.c / 4;
% Glissement : A·Γ + α = 0 (V = 1) ; Cl = 2Γ/c
W.K = -2 * (A \ eye(n)) ./ W.c;
W.ClA = W.K * ones(n, 1);
integre = @(Cl) deal(sum(Cl .* W.c .* W.wy) / S, -sum(Cl .* W.c .* W.wy .* (W.xc4 - xref)) / (S * MAC));
[W.CLa, W.Cma] = integre(W.ClA);
W.reponse = @(da) reponse(W.K * da, integre);
W.a_CL = @(da) reponse(W.K * da - W.ClA * (sum((W.K * da) .* W.c .* W.wy) / S) / W.CLa, integre);
% Trefftz : la bande j porte Γj = c·Cl/2 (V = 1) ; au bord e, tourbillon libre Γe − Γe−1
% (bande e à droite du bord e) ; αi(y) = Σ (Γe − Γe−1) / (4π (y − ye))
saut = eye(n + 1, n) - [zeros(1, n); eye(n)];
W.Ktr = (1 ./ (ym - yb.')) * saut / (8 * pi);
W.CDi = @(Cl) sum(W.c .* Cl .* (W.Ktr * (W.c .* Cl)) .* W.wy) / S;
end

function out = reponse(Cl, integre)
[CL, Cm] = integre(Cl);
out = struct('Cl', Cl, 'CL', CL, 'Cm', Cm);
end

function w = seg(P, Q1, Q2)
% Vitesse verticale en chaque point P (m × 2) due à chaque segment Q1→Q2 (n × 2), Γ = 1
% (Biot et Savart, segment rectiligne dans le plan z = 0)
r1x = P(:, 1) - Q1(:, 1).';  r1y = P(:, 2) - Q1(:, 2).';
r2x = P(:, 1) - Q2(:, 1).';  r2y = P(:, 2) - Q2(:, 2).';
r0x = Q2(:, 1).' - Q1(:, 1).';  r0y = Q2(:, 2).' - Q1(:, 2).';
cz = r1x .* r2y - r1y .* r2x;
n1 = hypot(r1x, r1y);  n2 = hypot(r2x, r2y);
w = (r0x .* (r1x ./ n1 - r2x ./ n2) + r0y .* (r1y ./ n1 - r2y ./ n2)) ./ (4 * pi * cz);
end
