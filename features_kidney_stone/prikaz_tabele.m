clear;
close all;
clc;

%% Indeksiranje i inicijalizacija
glcm_pocetak = 175; 
glcm_kraj = 198;
broj_fajlova = 10; % Broj fajlova - pacijenata
broj_obelezja = glcm_kraj - glcm_pocetak + 1;

%% Učitavanje podataka
zdrav_bubreg_obelezja = zeros(broj_fajlova, broj_obelezja);
nezdrav_bubreg_obelezja = zeros(broj_fajlova, broj_obelezja);

for i = 1:broj_fajlova
    ime_fajla = sprintf('data/kalk_%d.csv', i);
    
    data_matrix = readmatrix(ime_fajla, 'NumHeaderLines', 1);

    nezdrav_bubreg = data_matrix(1, glcm_pocetak:glcm_kraj);
    zdrav_bubreg = data_matrix(2, glcm_pocetak:glcm_kraj);
    
    nezdrav_bubreg_obelezja(i, :) = nezdrav_bubreg;
    zdrav_bubreg_obelezja(i, :) = zdrav_bubreg;
end

%% Provera da li pacijent ima oba nezdrava bubrega
obelezja = [3 7 8 10 11 13 22 23 24];
oznaka_nezdrav = zeros(broj_fajlova, 1); % Oznaka za bubrege koji su proglašeni nezdravima

for i = 1:broj_fajlova
    broj_slicnosti = 0;
    for j = 1:length(obelezja)
        trenutno_obelezje = obelezja(j);
        apsolutna_razlika = abs(zdrav_bubreg_obelezja(i, trenutno_obelezje)...
        - nezdrav_bubreg_obelezja(i, trenutno_obelezje));
        if apsolutna_razlika < 0.5 * nezdrav_bubreg_obelezja(i, trenutno_obelezje)
            broj_slicnosti = broj_slicnosti + 1;
        end
    end
    if broj_slicnosti >= 5
        oznaka_nezdrav(i) = 1; % Označavamo da je ovaj pacijentov zdrav bubreg proglašen nezdravim
    end
end

%% Mediana, min, max i Mann-Whitney U test
statisticki_param = zeros(length(obelezja), 6);
p_values = zeros(length(obelezja), 1);

for i = 1:length(obelezja)
    trenutno_obelezje = obelezja(i);
    
    % Ekstrahujemo kolone odgovarajućeg obeležja za zdrav i nezdrav bubreg
    zdrav_podaci = zdrav_bubreg_obelezja(:, trenutno_obelezje);
    nezdrav_podaci = nezdrav_bubreg_obelezja(:, trenutno_obelezje);
    
    % Filtriramo podatke prema oznaci
    zdravi_bubrezi = zdrav_podaci(oznaka_nezdrav == 0);
    nezdravi_bubrezi = [nezdrav_podaci; zdrav_podaci(oznaka_nezdrav == 1)];
    
    % Izračunavamo median, min i max za zdrav bubreg
    mediana_zdrav = median(zdravi_bubrezi);
    min_zdrav = min(zdravi_bubrezi);
    max_zdrav = max(zdravi_bubrezi);
    
    % Izračunavamo median, min i max za nezdrav bubreg
    mediana_nezdrav = median(nezdravi_bubrezi);
    min_nezdrav = min(nezdravi_bubrezi);
    max_nezdrav = max(nezdravi_bubrezi);
    
    % Popunjavamo matricu X
    statisticki_param(i, :) = [min_zdrav, mediana_zdrav, max_zdrav, min_nezdrav, mediana_nezdrav, max_nezdrav];
    
    % Mann-Whitney U test
    p_values(i) = ranksum(zdravi_bubrezi, nezdravi_bubrezi);
end

% Prikaz p-vrednosti
disp('p-vrednosti za svakо obeležjе (Mann-Whitney U test):');
disp(p_values);

% Ispis pacijenata čiji su bubrezi proglašeni nezdravima
disp('Pacijenti čiji su bubrezi proglašeni nezdravima:');
for i = 1:broj_fajlova
    if oznaka_nezdrav(i) == 1
        fprintf('Pacijent %d\n', i);
    end
end
