function ecrire_avion_xml(fichier, nom, g, profil, M, p, profil_elevon)
%ECRIRE_AVION_XML  Avion xflr5 v6.62 (XML) : aile en flèche vrillée + winglets + masses ponctuelles.
%
%   ecrire_avion_xml(fichier, nom, g, profil, M, p)
%   ecrire_avion_xml(..., profil_elevon)
%     profil_elevon : nom xflr5 du profil à volet braqué (facultatif). Les élevons
%       (p.geo4.y_elevon) portent ce profil ; xflr5 interpolant le profil entre deux
%       sections, la station de début des élevons est remplacée par deux sections
%       à ± p.xfl.dy_elevon/2, reliées par un panneau de transition d'un seul
%       panneau en envergure (envergure efficace des élevons conservée).
%     fichier : chemin du .xml écrit
%     nom     : nom de l'avion dans xflr5
%     g       : géométrie (geometrie_aile) : stations g.y, cordes g.c, BA g.xBA, vrillage g.vr
%     profil  : clé du profil d'aile (champ de p.xfl.nom_xflr5, ex. "mh45")
%     M       : table des masses ponctuelles (Nom, m [kg], x, y, z [m]), batterie comprise
%     p       : paramètres (p.xfl, p.geo4)
%   Schéma relevé sur les exports réels de l'utilisateur (xflr5/gabarits/avion_defaut.xml
%   et avion_winglet.xml) :
%     - aile principale MAINWING symétrique, une <Section> par station (xOffset = BA,
%       Twist = vrillage local, Dihedral = dièdre du panneau suivant) ;
%     - winglets = dérive FIN avec isDoubleFin = true, Position = pied du winglet à
%       (x, ±y, z) ; ses sections sont données en hauteur (y_position = hauteur) ;
%       Tilt_angle = vrillage du saumon : xflr5 vrille les sections autour du bord
%       d'attaque (vue 3D de l'utilisateur, 13/10/2026) et incline la dérive autour de
%       sa Position, qui est le BA du saumon ; le pied du winglet se pose donc sur la
%       section vrillée (à plat, les deux treillis se croisaient : Cl du winglet
%       jusqu'à 2,5 et CDi < 0 sur les premiers T2) ;
%     - masses : <Point_Mass> sous <Plane><Inertia> ; Volume_Mass des ailes à 0 (toute
%       la masse est ponctuelle : le CG de xflr5 est alors exactement celui de MATLAB).

nf = p.xfl.nom_xflr5;
pa = nf.(profil);
pw = nf.(p.xfl.profil_wl);
w  = g.wl;

fid = fopen(fichier, 'w', 'n', 'UTF-8');
assert(fid > 0, 'ecrire_avion_xml:ouverture', 'impossible d''écrire %s', fichier);
nettoie = onCleanup(@() fclose(fid));

fprintf(fid, '<?xml version="1.0" encoding="UTF-8"?>\n<!DOCTYPE explane>\n<explane version="1.0">\n');
fprintf(fid, '    <Units>\n        <length_unit_to_meter>1</length_unit_to_meter>\n        <mass_unit_to_kg>1</mass_unit_to_kg>\n    </Units>\n');
fprintf(fid, '    <Plane>\n        <Name>%s</Name>\n        <Description>%s</Description>\n', echappe(nom), ...
        echappe(sprintf('Généré par MATLAB (stabilite.m) : flèche %.1f°, vrillage %.1f°, profil %s', g.fleche, g.vrillage, pa)));
fprintf(fid, '        <Inertia>\n');
for k = 1:height(M)
    fprintf(fid, ['            <Point_Mass>\n                <Tag>%s</Tag>\n                <Mass>%.6f</Mass>\n' ...
                  '                <coordinates>%.6f, %.6f, %.6f</coordinates>\n            </Point_Mass>\n'], ...
            echappe(M.Nom(k)), M.m(k), M.x(k), M.y(k), M.z(k));
end
fprintf(fid, '        </Inertia>\n        <has_body>false</has_body>\n');

% Aile principale : une section par station de p.geo4.y_sec
ny = [p.xfl.ny_aile(:); 1];                 % le dernier nombre (saumon) n'est pas utilisé par xflr5
ys = g.y;  pfs = repmat(string(pa), numel(ys), 1);
if nargin > 6 && strlength(profil_elevon) > 0
    ie = find(abs(g.y - p.geo4.y_elevon(1)) < 1e-9);
    assert(isscalar(ie) && abs(g.y(end) - p.geo4.y_elevon(2)) < 1e-9, 'ecrire_avion_xml:elevon', ...
           'les élevons doivent commencer à une station et finir au saumon');
    d  = p.xfl.dy_elevon / 2;
    ys = [g.y(1:ie-1); g.y(ie) - d; g.y(ie) + d; g.y(ie+1:end)];
    ny = [ny(1:ie-1); 1; ny(ie:end)];
    pfs = [pfs(1:ie); repmat(string(profil_elevon), numel(g.y) - ie + 1, 1)];
end
% Lois linéaires entre stations : interpolation exacte de la corde, du BA et du vrillage
sec = struct('y', num2cell(ys), 'c', num2cell(interp1(g.y, g.c, ys)), 'x', num2cell(interp1(g.y, g.xBA, ys)), ...
             'tw', num2cell(interp1(g.y, g.vr, ys)), 'ny', num2cell(ny), 'pf', cellstr(pfs));
ecrire_aile(fid, "Main Wing", "MAINWING", [0 0 0], 0, false, sec, p.xfl.nx, [153 111 165]);

% Winglets : dérive double au saumon (hauteur, cordes et flèche de p.geo4)
secw = struct('y', {0, w.h}, 'c', {w.c_pied, w.c_tete}, 'x', {0, w.x_tete - w.x_pied}, ...
              'tw', {0, 0}, 'ny', {p.xfl.ny_wl, 1}, 'pf', pw);
ecrire_aile(fid, "Fin", "FIN", [w.x_pied w.y 0], g.vr(end), true, secw, p.xfl.nx, [171 137 118]);

fprintf(fid, '    </Plane>\n</explane>\n');
end

function ecrire_aile(fid, nom, type, pos, tilt, est_derive, sec, nx, rgb)
fprintf(fid, '        <wing>\n            <Name>%s</Name>\n            <Type>%s</Type>\n', nom, type);
fprintf(fid, '            <Color>\n                <red>%d</red>\n                <green>%d</green>\n                <blue>%d</blue>\n                <alpha>255</alpha>\n            </Color>\n', rgb);
fprintf(fid, '            <Description></Description>\n            <Position>%.6f, %.6f, %.6f</Position>\n            <Tilt_angle>%.3f</Tilt_angle>\n', pos, tilt);
fprintf(fid, '            <Symetric>true</Symetric>\n            <isFin>%s</isFin>\n            <isDoubleFin>%s</isDoubleFin>\n            <isSymFin>false</isSymFin>\n', ...
        vf(est_derive), vf(est_derive));
fprintf(fid, '            <Inertia>\n                <Volume_Mass>0.000</Volume_Mass>\n            </Inertia>\n            <Sections>\n');
for k = 1:numel(sec)
    s = sec(k);
    fprintf(fid, ['                <Section>\n                    <y_position>%.6f</y_position>\n' ...
        '                    <Chord>%.6f</Chord>\n                    <xOffset>%.6f</xOffset>\n' ...
        '                    <Dihedral>0.000</Dihedral>\n                    <Twist>%.4f</Twist>\n' ...
        '                    <x_number_of_panels>%d</x_number_of_panels>\n                    <x_panel_distribution>COSINE</x_panel_distribution>\n' ...
        '                    <y_number_of_panels>%d</y_number_of_panels>\n                    <y_panel_distribution>COSINE</y_panel_distribution>\n' ...
        '                    <Left_Side_FoilName>%s</Left_Side_FoilName>\n                    <Right_Side_FoilName>%s</Right_Side_FoilName>\n' ...
        '                </Section>\n'], s.y, s.c, s.x, s.tw, nx, s.ny, echappe(s.pf), echappe(s.pf));
end
fprintf(fid, '            </Sections>\n        </wing>\n');
end

function s = vf(b)
if b, s = 'true'; else, s = 'false'; end
end

function s = echappe(s)
% Caractères réservés du XML
s = replace(string(s), ["&" "<" ">"], ["&amp;" "&lt;" "&gt;"]);
end
