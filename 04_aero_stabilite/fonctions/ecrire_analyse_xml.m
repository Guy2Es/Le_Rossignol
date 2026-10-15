function ecrire_analyse_xml(fichier, nom_polaire, nom_avion, a)
%ECRIRE_ANALYSE_XML  Analyse xflr5 v6.62 de type 2 (portance fixe), en XML.
%
%   ecrire_analyse_xml(fichier, nom_polaire, nom_avion, a)
%     a : structure des réglages :
%       methode ("VLM1" ou "VLM2"), rho [kg/m³], nu [m²/s],
%       S [m²], b [m], MAC [m] (dimensions de référence, projetées),
%       m [kg], cg [x y z] [m] (pour information : l'inertie du plan est utilisée),
%       visqueux (logique, facultatif, vrai par défaut : faux = VLM non visqueuse,
%       qui ne lit aucune polaire 2D et ne rejette donc aucun point)
%   Schéma relevé sur l'export réel de l'utilisateur (xflr5/gabarits/analyse_T2.xml) ;
%   seuls changent : noms, méthode, densité, viscosité, références et inertie.
%   La plage d'alpha ne fait pas partie de l'analyse : elle se saisit dans xflr5.

assert(ismember(a.methode, ["VLM1" "VLM2"]), 'ecrire_analyse_xml:methode', 'méthode inconnue : %s', a.methode);
visqueux = ~isfield(a, 'visqueux') || a.visqueux;
fid = fopen(fichier, 'w', 'n', 'UTF-8');
assert(fid > 0, 'ecrire_analyse_xml:ouverture', 'impossible d''écrire %s', fichier);
nettoie = onCleanup(@() fclose(fid));

fprintf(fid, '<?xml version="1.0" encoding="UTF-8"?>\n<!DOCTYPE Plane_Polar>\n<Plane_Polar version="1.0">\n');
fprintf(fid, ['    <Units>\n        <length_unit_to_meter>1</length_unit_to_meter>\n        <area_unit_to_m2>1</area_unit_to_m2>\n' ...
              '        <mass_unit_to_kg>1</mass_unit_to_kg>\n        <speed_unit_to_ms>1</speed_unit_to_ms>\n' ...
              '        <inertia_unit_to_kgm2>1</inertia_unit_to_kgm2>\n    </Units>\n']);
fprintf(fid, '    <Polar>\n        <Polar_Name>%s</Polar_Name>\n        <Plane_Name>%s</Plane_Name>\n', nom_polaire, nom_avion);
fprintf(fid, ['        <Type>FIXEDLIFTPOLAR</Type>\n        <Method>PANELMETHOD</Method>\n        <Ignore_Body_Panels>true</Ignore_Body_Panels>\n' ...
              '        <Use_VLM1>%s</Use_VLM1>\n        <Viscous_Analysis>%s</Viscous_Analysis>\n        <Thin_Surfaces>true</Thin_Surfaces>\n' ...
              '        <Tilted_Analysis>false</Tilted_Analysis>\n        <Ground_Effect>false</Ground_Effect>\n        <Ground_Height>0.00000</Ground_Height>\n'], ...
        ternaire(a.methode == "VLM1", 'true', 'false'), ternaire(visqueux, 'true', 'false'));
fprintf(fid, '        <Viscosity>%.5e</Viscosity>\n        <Density>%.5f</Density>\n', a.nu, a.rho);
fprintf(fid, ['        <Fixed_Velocity>10.00000</Fixed_Velocity>\n        <Fixed_AOA>0.00000</Fixed_AOA>\n' ...
              '        <Fixed_Bank_Angle>0.00000</Fixed_Bank_Angle>\n        <Fixed_SideSlip>0.00000</Fixed_SideSlip>\n']);
fprintf(fid, ['        <Reference_Dimensions>PROJECTEDREFDIM</Reference_Dimensions>\n        <Reference_Area>%.5f</Reference_Area>\n' ...
              '        <Reference_Span_Length>%.5f</Reference_Span_Length>\n        <Reference_Chord_Length>%.5f</Reference_Chord_Length>\n'], a.S, a.b, a.MAC);
fprintf(fid, '        <ExtraDrag>\n');
for k = 1:4
    fprintf(fid, '            <ExtraDragCoef_%d>0.00000</ExtraDragCoef_%d>\n            <ExtraDragArea_%d>0.00000</ExtraDragArea_%d>\n', k, k, k, k);
end
fprintf(fid, '        </ExtraDrag>\n        <Use_Plane_Inertia>true</Use_Plane_Inertia>\n');
fprintf(fid, ['        <Inertia_Value>\n            <Mass>%.5f</Mass>\n            <CoG>%.6f %.6f %.6f</CoG>\n' ...
              '            <CoG_Ixx>0.00000</CoG_Ixx>\n            <CoG_Iyy>0.00000</CoG_Iyy>\n            <CoG_Izz>0.00000</CoG_Izz>\n' ...
              '            <CoG_Ixz>0.00000</CoG_Ixz>\n        </Inertia_Value>\n'], a.m, a.cg);
fprintf(fid, ['        <Inertia_gains>\n            <Mass_gain>0.00000</Mass_gain>\n            <CoG_x_gain>0.00000</CoG_x_gain>\n' ...
              '            <CoG_z_gain>0.00000</CoG_z_gain>\n            <Ixx_gain>0.00000</Ixx_gain>\n            <Iyy_gain>0.00000</Iyy_gain>\n' ...
              '            <Izz_gain>0.00000</Izz_gain>\n            <Ixz_gain>0.00000</Ixz_gain>\n        </Inertia_gains>\n        <Angle_gains/>\n']);
fprintf(fid, '    </Polar>\n</Plane_Polar>\n');
end

function s = ternaire(c, a, b)
if c, s = a; else, s = b; end
end
