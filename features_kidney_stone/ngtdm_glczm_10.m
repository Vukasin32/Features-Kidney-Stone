clear;
close all;
clc;

%% Indeksiranje i inicijalizacija
glcm_pocetak = 175; 
glcm_kraj = 198;
broj_fajlova = 10; % Broj fajlova - pacijenata
broj_obelezja = glcm_kraj - glcm_pocetak + 1;
ngtdm_complexity = [];
glszm_graylvl_var = [];

%% Učitavanje podataka
zdrav_bubreg_obelezja = zeros(broj_fajlova, broj_obelezja);
nezdrav_bubreg_obelezja = zeros(broj_fajlova, broj_obelezja);

for i = 1:broj_fajlova
    ime_fajla = sprintf('data/kalk_%d.csv', i);
    data_matrix = readmatrix(ime_fajla, 'NumHeaderLines', 1);

    % Provera da li data_matrix ima dovoljno kolona
    if size(data_matrix, 2) < max([glcm_kraj, 213, 228])
        error('Fajl %s nema dovoljno kolona.', ime_fajla);
    end

    ngtdm_complexity = [ngtdm_complexity; data_matrix(1,213) data_matrix(2,213)];
    glszm_graylvl_var = [glszm_graylvl_var; data_matrix(1,228) data_matrix(2,228)];

    nezdrav_bubreg_obelezja(i, :) = data_matrix(1, glcm_pocetak:glcm_kraj);
    zdrav_bubreg_obelezja(i, :) = data_matrix(2, glcm_pocetak:glcm_kraj);
end

%% Provera apsolutne razlike za 50%
obelezja = [3 7 8 10 11 13 22 23 24];
oznaka_nezdrav = zeros(broj_fajlova, 1); % Oznaka za bubrege koji su proglašeni nezdravima

for i = 1:broj_fajlova
    broj_malih_razlika = 0;
    for j = 1:length(obelezja)
        trenutno_obelezje = obelezja(j);
        apsolutna_razlika = abs(zdrav_bubreg_obelezja(i, trenutno_obelezje) - nezdrav_bubreg_obelezja(i, trenutno_obelezje));
        if apsolutna_razlika < 0.5 * nezdrav_bubreg_obelezja(i, trenutno_obelezje)
            broj_malih_razlika = broj_malih_razlika + 1;
        end
    end
    if broj_malih_razlika >= 5
        oznaka_nezdrav(i) = 1; % Označavamo da je ovaj pacijentov zdrav bubreg proglašen nezdravim
    end
end

%% Mann-Whitney Test (ranksum test) za NGTDM Complexity i GLSZM Gray Level Variance
% Pravi zdrav i nezdrav bubreg (bez oznaka za potencijalno pogrešno klasifikovane)
pravi_zdrav_ngtdm = ngtdm_complexity(oznaka_nezdrav == 0, 2);
pravi_nezdrav_ngtdm = ngtdm_complexity(:, 1);

pravi_zdrav_glszm = glszm_graylvl_var(oznaka_nezdrav == 0, 2);
pravi_nezdrav_glszm = glszm_graylvl_var(:, 1);

[p_ngtdm, ~] = ranksum(pravi_zdrav_ngtdm, pravi_nezdrav_ngtdm);
[p_glszm, ~] = ranksum(pravi_zdrav_glszm, pravi_nezdrav_glszm);

%% Kreiranje scatter plot-a
figure;
hold on;

% Prikaz bolesnih bubrega
scatter(ngtdm_complexity(:,1), glszm_graylvl_var(:,1), 'r', 'filled');
for i = 1:broj_fajlova
    text(ngtdm_complexity(i,1), glszm_graylvl_var(i,1), num2str(i), 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right');
end

% Prikaz zdravih bubrega, uzimajući u obzir oznaku za nezdrave bubrege
for i = 1:broj_fajlova
    if oznaka_nezdrav(i) == 0
        scatter(ngtdm_complexity(i,2), glszm_graylvl_var(i,2), 'b', 'filled');
        text(ngtdm_complexity(i,2), glszm_graylvl_var(i,2), num2str(i), 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right');
    else
        scatter(ngtdm_complexity(i,2), glszm_graylvl_var(i,2), 'r', 'filled');
        text(ngtdm_complexity(i,2), glszm_graylvl_var(i,2), num2str(i), 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right');
    end
end
xlabel('NGTDM Complexity');
ylabel('GLSZM Gray Level Variance');
title('NGTDM Complexity vs. GLSZM Gray Level Variance');
xlim([0 20000])

% Dodavanje legende
legend({'Bolestan bubreg', 'Zdrav bubreg'}, 'Location', 'best');

hold off;

% Ispis p-vrednosti
fprintf('P-vrednost za NGTDM Complexity: %.4f\n', p_ngtdm);
fprintf('P-vrednost za GLSZM Gray Level Variance: %.4f\n', p_glszm);
