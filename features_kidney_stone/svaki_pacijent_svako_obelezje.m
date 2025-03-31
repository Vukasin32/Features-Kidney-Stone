clear;
close all;
clc;

%% Indeksiranje i inicijalizacija
glcm_pocetak = 175; 
glcm_kraj = 198;
broj_fajlova = 5; % Broj fajlova - pacijenata
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

%% Kreiranje grafika, svaki pacijent - svako obeležje
% ukupno 24 obelezja, prikazujemo ih u grupama:
% 10+10+1+1+1+1 - ovaj izbor se pokazao kao najpregledniji, 
% zbog razmere...


% Prikaz prvih 20 obelezja
for i = 1:broj_fajlova
    for part = 1:2
        figure();
        hold on;
        
        if part == 1
            feature_range = 1:10;
        else
            feature_range = 11:20;
        end
        x = 1:10;
        
        scatter(x, nezdrav_bubreg_obelezja(i, feature_range), 'r', 'filled', 'DisplayName', 'Bolestan bubreg');
        scatter(x, zdrav_bubreg_obelezja(i, feature_range), 'b', 'filled', 'DisplayName', 'Zdrav bubreg');
        
        xticks(x);
        xticklabels(arrayfun(@(n) sprintf('glcm%d', n), feature_range, 'UniformOutput', false));
        xlabel('GLCM obelezja');
        ylabel('Vrednosti');
        title(['Pacijent ', num2str(i), ' - Deo ', num2str(part)]);
        legend('Location', 'Best');
        
        hold off;
    end
end

% Prikaz poslednja 4 obelezja
parametri = [21, 22, 23, 24];
for p = 1:length(parametri)
    parametar = parametri(p);
    
    for i = 1:broj_fajlova
        figure();
        hold on;
        
        scatter(1, nezdrav_bubreg_obelezja(i, parametar), 'r', 'filled', 'DisplayName', 'Bolestan bubreg');
        scatter(2, zdrav_bubreg_obelezja(i, parametar), 'b', 'filled', 'DisplayName', 'Zdrav bubreg');
        
        xticks([1 2]);
        xticklabels({'Bolestan bubreg', 'Zdrav bubreg'});
        xlabel(['glcm', num2str(parametar)]);
        ylabel('Vrednosti');
        title(['Pacijent ', num2str(i), ' - GLCM ', num2str(parametar)]);
        legend('Location', 'Best');
        
        hold off;
    end
end