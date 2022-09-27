%Script che esegue l' allenamento del classificatore LDA tramite k-fold
%e classificazione del train set e test set.
%In questo caso si usa il train set sbilanciato 
%(coincidente con data set di calibrazione).
%Vedi commenti nel codice per altri dettagli.
clc
clear
close all

load("feature vector.mat");

feature_vector_train = feature_vector; %per il train set (si riferisce alla fase di calibrazione)

load("feature vector test set.mat");

feature_vector_test = feature_vector; %per il test set (si riferisce alla fase di free speech)
clear feature_vector

%le strutture feature_vector_train e feature_vector_test contiengono i dati
%relativi ai 13 soggetti, con distinzione tra target e non taget.

%per ogni soggetto, si allena il classificatore lda usando il train set,
% usando le funzioni fitcdiscr(impostando la cross validazione con il k
% fold) e poi testare tale classificatore con il test set (e train set).
% Per la classificazione si procede come segue:
% per ogni elemento del set da valutare si fa una classificazione per ognuno dei
% k classificatori ottenuti e poi decido la classe finale con mayority
% voting (assegno la classe che ha ricevuto più voti).


for i = 1:13

    soggetti(i) = "soggetto_" + num2str(i);

end

tipo = ["Target","Non_target"];


for sogg = soggetti

    for alpha = [0.5:0.05:1] %fattore usato nella classificazione per determinare zona grigia dei non classificati
     
        k = 15; %valore da usare nel k fold

        rip=1; %in questa prova si effettua un' unica iterazione di alleamento e classificazione

        %% fase di training dei classificatori

        clear X Y MdlLinear classi_predette;

        [MdlLinear,X,Y] = allena_classificatori_no_bil(feature_vector_train,k,sogg);

        %% fase di testing dei classificatori

        %Poichè ognuno dei k classificatori ottenuti è indipendente
        %dagli altri, per ogni elemento del test set avrò k punteggi
        %LDA: si calcola la
        %curva ROC per ognuno dei k classificatori ottenuti ->
        %si ottimizza il punto operativo con la tecnica della distanza
        %-> si ottenere la soglia ottimale -> si usa il parametro alpha per
        %gestire i non classificati -> si classifica tramite
        %confronto del punteggio LDA con la soglia ottenuta.
        %Per ogni elemento del test set ottengo k voti e la classe finale è
        %determinata con majority voting.

        %%%%%%%%%%%%%%%%%%%%%%%%%%
        [predizioni_test,X_test,Y_test] = testa_classificatori(MdlLinear,feature_vector_test,k,alpha,sogg);

        [predizioni_train,X_train,Y_train] = testa_classificatori(MdlLinear,feature_vector_train,k,alpha,sogg);

        %% matrice di confusione Target = Positivo, Non-Target = Negativo

        %costruzione matrice di confusione per le 3 classi con funzione custom
        CM_completa_test = confusion_matrix_3_classes(Y_test,predizioni_test);
        CM_completa_train = confusion_matrix_3_classes(Y_train,predizioni_train);


        CM_per_struttura_test(:,:,rip) = CM_completa_test;
        CM_per_struttura_train(:,:,rip) = CM_completa_train;


        proporzione_NC_test(rip,1) = sum(CM_completa_test(:,3))/sum(CM_completa_test,"all");
        proporzione_NC_train(rip,1) = sum(CM_completa_train(:,3))/sum(CM_completa_train,"all");


        CM_test = CM_completa_test(:,1:2); %matrice di confusione ridotta, cioè eliminando la colonna dei non classificati
        CM_train = CM_completa_train(:,1:2);

        %spec = VN/(VN+FP)
        specificita_test(rip,1) = CM_test(2,2)/(CM_test(2,2)+CM_test(2,1));
        specificita_train(rip,1) = CM_train(2,2)/(CM_train(2,2)+CM_train(2,1));


        %sens = VP/(VP+FN)
        sensibilita_test(rip,1) = CM_test(1,1)/(CM_test(1,1)+CM_test(1,2));
        sensibilita_train(rip,1) = CM_train(1,1)/(CM_train(1,1)+CM_train(1,2));


        %acc = (VP+VN)/(VP+VN+FP+FN)
        accuratezza_test(rip,1) = (CM_test(1,1)+CM_test(2,2))/sum(CM_test,"all");
        accuratezza_train(rip,1) = (CM_train(1,1)+CM_train(2,2))/sum(CM_train,"all");


        %indice F1 = VP/(VP+1/2*(FP+FN))
        F1_test(rip,1) = CM_test(1,1)/(CM_test(1,1)+1/2*(CM_test(2,1)+CM_test(1,2)));
        F1_train(rip,1) = CM_train(1,1)/(CM_train(1,1)+1/2*(CM_train(2,1)+CM_train(1,2)));

        risultati.("k_fold_"+k).("alpha_"+replace(string(alpha),".","_")).(sogg).test.CM=CM_per_struttura_test;
        risultati.("k_fold_"+k).("alpha_"+replace(string(alpha),".","_")).(sogg).test.proporzione_NC = proporzione_NC_test;
        risultati.("k_fold_"+k).("alpha_"+replace(string(alpha),".","_")).(sogg).test.specificita = specificita_test;
        risultati.("k_fold_"+k).("alpha_"+replace(string(alpha),".","_")).(sogg).test.sensibilita = sensibilita_test;
        risultati.("k_fold_"+k).("alpha_"+replace(string(alpha),".","_")).(sogg).test.accuratezza=accuratezza_test;
        risultati.("k_fold_"+k).("alpha_"+replace(string(alpha),".","_")).(sogg).test.F1 = F1_test;

        risultati.("k_fold_"+k).("alpha_"+replace(string(alpha),".","_")).(sogg).train.CM=CM_per_struttura_train;
        risultati.("k_fold_"+k).("alpha_"+replace(string(alpha),".","_")).(sogg).train.proporzione_NC = proporzione_NC_train;
        risultati.("k_fold_"+k).("alpha_"+replace(string(alpha),".","_")).(sogg).train.specificita = specificita_train;
        risultati.("k_fold_"+k).("alpha_"+replace(string(alpha),".","_")).(sogg).train.sensibilita = sensibilita_train;
        risultati.("k_fold_"+k).("alpha_"+replace(string(alpha),".","_")).(sogg).train.accuratezza=accuratezza_train;
        risultati.("k_fold_"+k).("alpha_"+replace(string(alpha),".","_")).(sogg).train.F1 = F1_train;

    end
end


save("risultati_con_test_set_sbilanciato_vari_alpha.mat","risultati");



