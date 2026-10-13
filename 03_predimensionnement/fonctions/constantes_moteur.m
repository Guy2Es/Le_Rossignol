function mot = constantes_moteur(KV, classe, p)
%CONSTANTES_MOTEUR  Constantes du modèle DC (Kv, Rm, I0, Imax) d'un moteur candidat.
%
%   mot = constantes_moteur(KV, classe, p)
%     KV     : constante de vitesse [tr/min/V]
%     classe : "mot" (2212, lois d'échelle), "motX" (X2212 V3, fiche),
%              "motE" (X2208, fiche) ou "motEh" (2208 hors catalogue)
%     p      : paramètres (params_v1)
%   Sortie : structure mot
%     KV, Kv [rad/s/V], Rm [Ω], I0 [A], m [kg]
%     Imax    [A] : limite retenue pour le bridage (continue si publiée)
%     I_cont  [A] : limite continue publiée (NaN si la fiche n'en donne pas)
%     I30     [A] : limite de courte durée de la fiche, tenue t_I30 [s]
%     I_essai [A] : plus fort courant plein gaz des essais de la fiche (NaN si absent)
%     P_fiche [W] : puissance max de la fiche (NaN si absente)
%
%   HORS SKILL. Deux cas :
%   - classe sans table par KV (2212 générique, 2208 hors catalogue) : lois
%     d'échelle à volume de bobinage constant, Rm ∝ 1/KV², I0 ∝ KV, Imax ∝ KV ;
%     I30 = Imax (seule valeur disponible) ;
%   - classe avec table par KV (fiche constructeur) : valeurs lues
%     directement ; un KV absent de la table est une erreur.

c = p.(classe);
mot.KV = KV;
mot.Kv = KV * 2*pi/60;                               % rad/s/V
if isfield(c, 'Rm')
    i = find(c.KV == KV, 1);
    assert(~isempty(i), 'KV %g absent de la fiche de la classe %s', KV, classe);
    mot.Rm = c.Rm(i);  mot.I0 = c.I0(i);  mot.Imax = c.Imax(i);
else
    i = 1;
    mot.Rm   = c.Rm_ref   * (c.KV_ref / KV)^2;      % Rm ∝ 1/KV²
    mot.I0   = c.I0_ref   * KV / c.KV_ref;          % I0 ∝ KV
    mot.Imax = c.Imax_ref * KV / c.KV_ref;          % Imax ∝ KV
end
mot.I_cont  = champ(c, 'I_cont', i, NaN);
mot.I30     = champ(c, 'I30', i, mot.Imax);
mot.t_I30   = champ(c, 't_I30', i, NaN);
mot.I_essai = champ(c, 'I_essai', i, NaN);
mot.P_fiche = champ(c, 'P_fiche', i, NaN);
mot.m = c.m;
end

function v = champ(c, nom, i, defaut)
% Valeur i du champ nom s'il existe (un scalaire vaut pour tous les KV), sinon défaut
if ~isfield(c, nom)
    v = defaut;
elseif isscalar(c.(nom))
    v = c.(nom);
else
    v = c.(nom)(i);
end
end
