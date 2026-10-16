function [pols, manque] = polaires_dossier(dossier, noms, Re_lot, Ncrit)
%POLAIRES_DOSSIER  Polaires XFoil exportées par xflr5 dans un dossier, rangées par profil et par Re.
%
%   [pols, manque] = polaires_dossier(dossier, noms, Re_lot, Ncrit)
%     dossier : dossier des exports .txt (lire_polaire_2d) ; noms : nP noms de profils (ligne
%               « Calculated polar for: ») ; Re_lot : nR Re attendus ; Ncrit : Ncrit du lot
%   Sortie : pols, cellule nP × nR (vide là où la polaire manque) ; manque, liste des polaires
%   absentes (« <nom>, Re <Re> »), ou « dossier absent » ; vide si le jeu est complet. Les
%   autres profils du dossier sont ignorés.
%   Erreur si une polaire attendue est en double, ou si Ncrit, Mach ou la transition d'une
%   polaire attendue diffèrent du lot (Mach 0, transition libre).

noms = string(noms(:));
nP = numel(noms);  nR = numel(Re_lot);
pols = cell(nP, nR);
if ~isfolder(dossier)
    manque = "dossier absent";
    return
end
fic = dir(fullfile(dossier, '*.txt'));
lues = cell(numel(fic), 1);
for i = 1:numel(fic)
    lues{i} = lire_polaire_2d(fullfile(fic(i).folder, fic(i).name));
end
nomL = string(cellfun(@(q) char(q.profil), lues, 'UniformOutput', false));
ReL  = cellfun(@(q) q.Re, lues);
manque = strings(0, 1);
for i = 1:nP
    for r = 1:nR
        k = find(nomL == noms(i) & ReL == Re_lot(r));
        assert(numel(k) <= 1, 'polaires_dossier:double', 'polaire en double : %s, Re = %.0f', noms(i), Re_lot(r));
        if isempty(k)
            manque(end+1, 1) = sprintf('%s, Re %.0f', noms(i), Re_lot(r)); %#ok<AGROW>
            continue
        end
        q = lues{k};
        assert(q.Ncrit == Ncrit && q.Mach == 0 && all(q.xtr == 1), 'polaires_dossier:lot', ...
               '%s, Re = %.0f : Ncrit, Mach ou transition différents du lot', noms(i), Re_lot(r));
        pols{i, r} = q;
    end
end
end
