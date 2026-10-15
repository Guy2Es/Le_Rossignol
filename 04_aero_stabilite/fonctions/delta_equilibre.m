function [dg, R] = delta_equilibre(CL, V, vr, dx, mode, D, d0, d_lim)
%DELTA_EQUILIBRE  Braquage des élevons qui annule le Cm au CG (cm_elevons).
%
%   [dg, R] = delta_equilibre(CL, V, vr, dx, mode, D, d0, d_lim)
%     CL, V, vr, mode, D : comme cm_elevons
%     dx    : (x_G − x_ref)/MAC, position du CG par rapport au point de référence des T2
%             (Cm_G = Cm_ref + CL·dx : la portance passe au point de référence)
%     d0    : braquage de départ [deg] ; d_lim : [δ min, δ max] de la recherche [deg]
%   Le Cm au CG décroît quand δ croît (élevon vers le haut = cabreur). Recherche d'un
%   encadrement par pas de 1° depuis d0, puis fzero.
%   Sortie : dg [deg] et R (cm_elevons à dg). dg = NaN si aucun équilibre dans d_lim ou
%   si un Cl local sort des polaires XFoil (R.hors = true).

f = @(d) cm_G(d, CL, V, vr, dx, mode, D);
dg = NaN;
R = struct('hors', false);
try
    a = d0;  ga = f(a);
    if ga == 0
        dg = a;
    else
        pas = sign(ga);                                % Cm_G > 0 : équilibre à δ plus grand
        trouve = false;
        while ~trouve
            b = a + pas;
            if b < d_lim(1) || b > d_lim(2), return; end
            gb = f(b);
            trouve = sign(gb) ~= sign(ga);
            if ~trouve, a = b;  ga = gb; end
        end
        dg = fzero(f, sort([a b]), optimset('TolX', 1e-6));
    end
    R = cm_elevons(dg, CL, V, vr, mode, D);
    R.hors = false;
catch err
    if ~strcmp(err.identifier, 'interp_polaires_volet:hors'), rethrow(err); end
    dg = NaN;
    R = struct('hors', true);
end
end

function g = cm_G(d, CL, V, vr, dx, mode, D)
R = cm_elevons(d, CL, V, vr, mode, D);
g = R.Cm + CL * dx;
end
