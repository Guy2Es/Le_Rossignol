function pr = points_remarquables(m, S, aero, c)
%POINTS_REMARQUABLES  Points remarquables de la polaire parabolique.
%
%   pr = points_remarquables(m, S, aero, c)
%     m [kg], S [m²], aero (polaire parabolique), c = p.const
%   Sortie : structure avec, pour chaque régime, CL, CD, finesse f et
%   vitesse équivalente EV [m/s], plus un drapeau « faisable » (CL ≤ CLmax).
%
%   Source : skill, performance.md (C1 p.49-60) :
%     EV(Tn min)  = √(2mg/(ρ0 S))·(k/CD0)^(1/4)     CL = √(CD0/k),  CD = 2·CD0
%     EV(Tn/V min)= 3^(1/4)·EV(Tn min)               CL = √(CD0/(3k)), CD = 4/3·CD0
%     EV(Pn min)  = EV(Tn min)/3^(1/4)               CL = √(3·CD0/k), CD = 4·CD0
%   Hélice (C1 p.70) : endurance max à Pn min, distance max à Tn min = fmax.
%   ATTENTION : ces résultats ignorent la puissance de l'avionique, qui est
%   constante ; l'optimum réel de la batterie est cherché numériquement
%   dans autonomie_distance.m.

if aero.type ~= "parabolique"
    error('points_remarquables:type', ...
          'Formules analytiques valables pour la polaire parabolique seulement.');
end
k    = 1 / (pi * aero.lambda * aero.e);           % C1 p.47
base = sqrt(2 * m * c.g / (c.rho0 * S));          % √(2mg/(ρ0 S))
EVfm = base * (k / aero.CD0)^(1/4);               % C1 p.49-50
q4   = 3^(1/4);

pr.k     = k;
pr.f_max = 1 / (2 * sqrt(k * aero.CD0));          % C1 p.50
pr.Tn_min  = paquet(sqrt(aero.CD0 / k),       2 * aero.CD0,     EVfm);
pr.TnV_min = paquet(sqrt(aero.CD0 / (3 * k)), 4/3 * aero.CD0,   q4 * EVfm);
pr.Pn_min  = paquet(sqrt(3 * aero.CD0 / k),   4 * aero.CD0,     EVfm / q4);

    function s = paquet(CL, CD, EV)
        s.CL = CL;
        s.CD = CD;
        s.f  = CL / CD;
        s.EV = EV;
        s.faisable = CL <= aero.CLmax;   % sinon le point est au-delà du décrochage
    end
end
