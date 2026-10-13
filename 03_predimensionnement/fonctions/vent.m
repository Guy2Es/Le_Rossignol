function w = vent(a, Vw)
%VENT  Vitesse sol et distance face au vent (V1-PERF-06).
%
%   w = vent(a, Vw)
%     a  : sortie de autonomie_distance (V, t_min, t_reel)
%     Vw : vent moyen de face [m/s]
%   Composition des vitesses (atmosphere-airspeeds.md, C1 p.40) :
%     V_sol = V_air + V_vent ; vent de face => V_sol = V − Vw.
%   Distance parcourue face au vent pendant l'autonomie t(V) :
%     R_face = (V − Vw)·t(V) ; l'optimum se déplace vers les vitesses plus
%   élevées que sans vent (on « paie » le temps passé contre le vent).

w.V_sol    = a.V - Vw;                                     % m/s
w.R_face   = max(w.V_sol, 0) .* a.t_min * 60 / 1000;       % km, théorique
w.R_face_reel = max(w.V_sol, 0) .* a.t_reel * 60 / 1000;   % km, [2 × N]
ok = a.V >= a.V_min & isfinite(a.t_min);
[~, i] = max(w.R_face .* ok);
w.V_opt  = a.V(i);
w.R_opt  = w.R_face(i);
end
