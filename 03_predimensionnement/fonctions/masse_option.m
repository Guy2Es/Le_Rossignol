function [m, gp] = masse_option(mot, m_ns, p)
%MASSE_OPTION  Masses d'une option moteur avec le groupe propulsif explicite.
%
%   [m, gp] = masse_option(mot, m_ns, p)
%     mot  : constantes moteur (constantes_moteur.m), dont la masse de fiche mot.m [kg]
%     m_ns : masses 3S1P et 4S1P du budget du cahier [kg]
%     p    : paramètres
%   Sorties :
%     m  : masses 3S1P et 4S1P de l'option [kg]
%     gp : structure en grammes : moteur, pales, moyeu (moyeu + cône), total,
%          budget (poste du cahier), ecart (total − budget), sans_batt,
%          m_ns (= 1000·m), m_ns_fiche (cellules à 70,0 g au lieu de 69 g)
%
%   Bilan : le poste « moteur + hélice repliable + cône » du budget (62 g)
%   est remplacé par moteur (fiche) + pales + moyeu-cône (références réelles,
%   params_v1, p.gp). Les autres postes du cahier sont inchangés.

P = p.masse.postes;
i = find(P(:, 1) == p.gp.poste, 1);
assert(~isempty(i), 'poste « %s » absent du budget', p.gp.poste);
gp.budget = double(P(i, 3));                                   % g
gp.moteur = 1000 * mot.m;                                      % g, fiche
gp.pales  = 1000 * p.gp.m_pales;                               % g
gp.moyeu  = 1000 * p.gp.m_moyeu;                               % g
gp.total  = gp.moteur + gp.pales + gp.moyeu;                   % g
gp.ecart  = gp.total - gp.budget;                              % g, > 0 : dépassement du poste
m = m_ns + gp.ecart / 1000;                                    % kg
gp.m_ns = 1000 * m;                                            % g
gp.sans_batt = gp.m_ns(end) - p.masse.batt_4S;                 % g, V1-MAS-02
dm_cell = 1000 * (p.batt.m_cell_fiche - p.batt.m_cell);        % g par cellule
gp.m_ns_fiche = gp.m_ns + p.batt.ns * dm_cell;                 % g
end
