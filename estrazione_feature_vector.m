% Script che elabora i segnali EEG da cui parte il lvaoro di tesi, e da
% essi estrae le features usate nelle fasi successive di classificazione.
% In questo script si elaborano i segnali della fase di calibrazione.
% 
% NB: i files con i segnali EEG inseriti in files .mat non sono inclusi
% nella repository git, sono comunque scaricabili liberamente da:
% http://bnci-horizon-2020.eu/database/data-sets num. 17.
clc
clear
close all

%i files .mat dei ricercatori vanno inseriti in una sottocartella chiamata
%"dati"
d = dir("dati\*.mat");
mainFolder = pwd; %salvo il percorso della cartella principale (servirà dopo)

%ciclo sui vari files .mat (cioè sui vari soggetti)
for i=1:size(d,1)

    %ottengo variabili presenti nel file .mat
    clear data;

    load(fullfile(d(i).folder,d(i).name));

    % Per ogni evento (cioè stimolo target o
    % non target) si prende il segnale nell' intervallo [-200 ms,
    % +800 ms] (t= 0 ms corrisponde allo stimulus onset) e si calcola la 
    % media degli intervalli associati alle componenti ERP per ogni canale
    % EEG, tenendo separati gli stimoli target da quelli non target.


    %Trovo l' info sullo stimolo target o non target nella variabile data.y
    %e l' istante dell' onset (in campioni) lo trovo in data.trial (lo
    %converto in ms con data.trial/data.fs*1000).

    %% ------------segmentazione segnali-----------------
    %[-200ms,+800ms] => durata = 1000ms = 1s

    durata_erp = 1000; %duarata dell' erp in ms.


    for stim_type = 1:length(data{1, 1}.classes)

        %inizializzo la matrice che conterrà gli ERP dei vari canali. I singoli
        %canali sono le colonne della matrice, le righe corrispondono ai
        %diversi campioni dell' ERP.
        tipo = replace(data{1, 1}.classes{1, stim_type},"-","_");
        erp_matrix.(tipo) = zeros([durata_erp*data{1,1}.fs/1000,63,1]); %num di campioni di un epoca deve essere 250 poichè fs = 250 Hz.
        %NB: l' ultima dimensione qui è 1 poichè lavoro con un unico soggetto
        %(altrimenti sarebbe length(d)).

        %ciclo sui singoli canali
        for ch = 1:length(data{1, 1}.channels)

            %qui vado a mettere i vari ERP di cui vado ad estrarre le
            %features temporali 
            erp_tmp = zeros([durata_erp*data{1,1}.fs/1000,1]);   %num di campioni di un epoca deve essere 250 poichè fs = 250 Hz.

            switch stim_type
                case 1
                    idx = find(data{1,1}.y == 1);
                case 2
                    idx = find(data{1,1}.y == 2);
                otherwise
                    error("Errore nello switch");
            end

            trial_onset = data{1,1}.trial(idx); %in questo vettore sono presenti i campioni corrispondenti agli onset degli stimoli

            %scansiono i vari eventi di stimolazione
            for stim_idx = 1:length(trial_onset)
            
                %inizio e fine dell' erp IN CAMPIONI.
                start_erp = trial_onset(stim_idx) - 200*data{1,1}.fs/1000+1; %start a -200ms dall' onset NB: il +1 è fatto per fare combaciare le dimensioni con erp_tmp
                fine_erp = trial_onset(stim_idx) + 800*data{1,1}.fs/1000; %fine a +800ms dall' onset
                
                %% baseline correction 

                %erp_tmp = data{1,1}.X(start_erp:fine_erp,ch); %SENZA BASELINE CORRECTION
                erp_tmp = data{1,1}.X(start_erp:fine_erp,ch) - mean(data{1,1}.X(start_erp:trial_onset(stim_idx),ch)); %CON BASELINE CORRECTION
                %% estrazione features 

                %calcolo medie nei vari intervalli di tempo, associati alle
                %varie componenti dell' ERP

                componenti_erp = [115,135;135,155;155,195;205,235;285,325;335,395;495,535]+200;
                %ci vuole +200 per tenere conto che l' erp inizia a -200ms e
                %non a 0 ms rispetto l' onset dello stimolo.

                for t = 1:size(componenti_erp,1)

                    idx_start_interval = round(componenti_erp(t,1)*data{1,1}.fs/1000);
                    idx_end_interval = round(componenti_erp(t,2)*data{1,1}.fs/1000);

                    feature_vector.(strcat("soggetto_",num2str(i))).(tipo).(strcat("stim_",num2str(stim_idx)))(ch,t) = mean(erp_tmp(idx_start_interval: idx_end_interval));

                end
            end
        end

    end

end

save("feature vector.mat","feature_vector");
