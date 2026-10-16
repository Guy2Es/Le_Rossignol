function M = masses_composants(p, g, B, gp, nB)
%MASSES_COMPOSANTS  Masses ponctuelles de l'avion sans batterie (phase 4).
%
%   M = masses_composants(p, g, B, gp)
%   M = masses_composants(p, g, B, gp, nB)
%     p  : paramètres (p.stab.pos, p.stab.x_moteur, p.stab.x_helice, p.gp)
%     g  : géométrie (geometrie_aile.m)
%     B  : budget réaffecté (budget_reaffecte.m), masses en grammes
%     gp : groupe propulsif (masse_option.m), en grammes
%     nB : (facultatif, 0 par défaut) nombre de bandes par demi-aile : les postes « aile » à
%          y = 0 sont alors répartis en 2·nB masses (une par bande et par côté), avec la même
%          loi proportionnelle à la surface locale ; même CG, mais les inerties Ixx et Izz
%          de l'aile sont représentées (T7 : xflr5 ne voit que les masses ponctuelles)
%   Sortie : table M, une ligne par masse ponctuelle :
%     Nom, m [kg], x, y, z [m] (repère xflr5, origine au BA de l'emplanture)
%   Les postes « aile » à y = 0 sont ramenés à leur centre de gravité,
%   calculé avec une répartition proportionnelle à la surface locale :
%     x̄ = (2/S)·∫ c(y)·(x_BA(y) + k·c(y)) dy,  ȳ = 0 (symétrie)
%   (pour le centrage longitudinal, seul x̄ compte ; les inerties sont
%   calculées par xflr5 à partir de sa propre répartition de la masse d'aile).
%   Les postes « aile » à y > 0 donnent deux masses à ±y.
%   Le poste « moteur + hélice + cône » est remplacé par le moteur et
%   l'hélice + adaptateur, séparés (masses de gp).

if nargin < 5, nB = 0; end
pos = p.stab.pos;
double_ = [pos.y] > 0 & [pos.mode] == "aile";      % postes dédoublés à ±y
reparti = [pos.y] == 0 & [pos.mode] == "aile" & nB > 0;   % postes répartis en bandes
n = numel(pos) + sum(double_) + sum(reparti) * (2*nB - 1) + 2;
nom = strings(n, 1);  m = zeros(n, 1);  x = m;  y = m;  z = m;

b2 = p.geo.b / 2;
yy = linspace(0, b2, 2001);
cc = g.cf(yy);

j = 0;
for k = 1:numel(pos)
    q = pos(k);
    i = find(B.postes.Poste == q.poste, 1);
    assert(~isempty(i), 'poste « %s » absent du budget', q.poste);
    mk = B.postes.Reaffecte_g(i) / 1000;            % kg
    switch q.mode
        case "nacelle"
            j = j + 1;
            nom(j) = q.poste; m(j) = mk; x(j) = q.x; y(j) = 0; z(j) = q.z;
        case "aile"
            if q.y == 0 && nB > 0
                % Bandes égales en envergure : masse ∝ ∫c dy, CG de la bande ∫c·(x_BA + k·c) dy / ∫c dy
                yb = linspace(0, b2, nB + 1);
                [mB, xB, yB] = deal(zeros(nB, 1));
                for s = 1:nB
                    u = yy >= yb(s) & yy <= yb(s + 1);
                    A = trapz(yy(u), cc(u));
                    mB(s) = A;
                    xB(s) = trapz(yy(u), cc(u) .* (g.xBAf(yy(u)) + q.x .* cc(u))) / A;
                    yB(s) = trapz(yy(u), cc(u) .* yy(u)) / A;
                end
                mB = mk / 2 * mB / sum(mB);
                r = j + (1:2*nB);  j = j + 2*nB;
                nom(r) = q.poste + " (bande " + string([1:nB, 1:nB]') + [repmat(" droite)", nB, 1); repmat(" gauche)", nB, 1)];
                m(r) = [mB; mB];  x(r) = [xB; xB];  y(r) = [yB; -yB];  z(r) = q.z;
            elseif q.y == 0
                j = j + 1;
                nom(j) = q.poste; m(j) = mk; y(j) = 0; z(j) = q.z;
                x(j) = 2 / g.S * trapz(yy, cc .* (g.xBAf(yy) + q.x .* cc));
            else
                r = j + (1:2);  j = j + 2;
                nom(r) = q.poste + [" (droite)"; " (gauche)"];
                m(r) = mk / 2;
                x(r) = g.xBAf(q.y) + q.x * g.cf(q.y);
                y(r) = [q.y; -q.y];
                z(r) = q.z;
            end
        otherwise
            error('masses_composants:mode', 'mode inconnu : %s', q.mode);
    end
end

% Groupe propulsif, séparé en moteur et hélice + adaptateur
r = j + (1:2);
nom(r) = ["Moteur X2212 V3"; "Hélice + adaptateur"];
m(r)   = [gp.moteur; gp.pales + gp.moyeu] / 1000;
x(r)   = [p.stab.x_moteur; p.stab.x_helice];
y(r)   = 0;
z(r)   = p.stab.z_moteur;

M = table(nom, m, x, y, z, 'VariableNames', {'Nom', 'm', 'x', 'y', 'z'});
% Contrôle : la somme retombe sur le budget sans batterie
assert(abs(sum(M.m) * 1000 - B.sans_batt) < 1e-9, 'masses ponctuelles ≠ budget sans batterie');
end
