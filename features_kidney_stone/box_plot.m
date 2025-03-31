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

%% Provera apsolutne razlike za 50%
obelezja = [3 7 8 10 11 13 22 23 24];
oznaka_nezdrav = zeros(broj_fajlova, 1); % Oznaka za bubrege koji su proglašeni nezdravima

for i = 1:broj_fajlova
    brojMaliRazlika = 0;
    for j = 1:length(obelezja)
        trenutno_obelezje = obelezja(j);
        apsolutna_razlika = abs(zdrav_bubreg_obelezja(i, trenutno_obelezje) - nezdrav_bubreg_obelezja(i, trenutno_obelezje));
        if apsolutna_razlika < 0.5 * nezdrav_bubreg_obelezja(i, trenutno_obelezje)
            brojMaliRazlika = brojMaliRazlika + 1;
        end
    end
    if brojMaliRazlika >= 5
        oznaka_nezdrav(i) = 1; % Označavamo da je ovaj pacijentov zdrav bubreg proglašen nezdravim
    end
end

%% Kreiranje box plot-a za svako obeležje
for j = 1:broj_obelezja
    figure;
    hold on;
    
    % Filtriramo podatke prema oznaci
    zdravi_bubrezi = zdrav_bubreg_obelezja(oznaka_nezdrav == 0, j);
    nezdravi_bubrezi = [nezdrav_bubreg_obelezja(:, j); zdrav_bubreg_obelezja(oznaka_nezdrav == 1, j)];
  
    % Kreiramo box plotove
    boxplot(nezdravi_bubrezi, 'Colors', 'r', 'Positions', 1, 'Widths', 0.4);
    boxplot(zdravi_bubrezi, 'Colors', 'b', 'Positions', 2.5, 'Widths', 0.4);
    
    xticks([1 2.5]);
    xticklabels({'Bolestan bubreg', 'Zdrav bubreg'});
    ylabel('Vrednosti');
    title(['GLCM obelezje ', num2str(j)]);
    
    hold off;
end
