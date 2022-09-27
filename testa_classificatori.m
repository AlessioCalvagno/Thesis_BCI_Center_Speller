function [predizioni_finali,Xnew,Y] = testa_classificatori(MdlLinear,feature_vector_test,k,alpha,sogg)
%[predizioni_finali,Xnew,Y] = testa_classificatori(MdlLinear,feature_vector_test,k,alpha,sogg)
%
% Funzione che fornisce la classificazione un determinato data set,
% implementando l' ottimizzazione della soglia di classificazione tramite
% curva ROC e majority voting.
% 
% Input:
% - MdlLinear: oggetto restituito dalla funzione fitcdiscr, contenente i k
% classsificatori ottenuti e altre informazioni (v.
% ClassificationPartitionedModel e allena_classificatori.m).
% 
% - feature_vector_test: struttura contentente i feature vectors del set da
% classificare (v. estrazione_feature_vector.m ed
% estrazione_feature_vector_test_set.m per più info sull' organizzazione di
% tale struttura).
% 
% - k: valore usato nel k-fold.
% 
% - alpha: valore da usare per regolare la zona grigia dei non classificati
% (compreso tra 0.5 e 1).
% 
% - sogg: stringa che indica il soggetto da cui provengono le features.
% 
% Output:
% - predizioni_finali: vettore delle predizioni dopo majority voting.
% 
% - Xnew: matrice delle features del set da classificare (organizza in modo
% diverso le informazioni passate con feature_vector_test).
% 
% - Y: vettore delle classi reali degli elementi del set da valutare

%%
        Xnew=[]; %matrice che conterrà le osservazioni e le variabili di predizione
        % (cioè i vari feature vector, disposti nelle righe della matrice)
        Y = [""]; %vettore delle classi

        N_non_target = size(fieldnames(feature_vector_test.(sogg).Non_target),1); %numero di stimoli non target
        N_target = size(fieldnames(feature_vector_test.(sogg).Target),1); %numero di stimoli target

        contatore = 1;

        for t = ["Target","Non_target"]

            campi = fieldnames(feature_vector_test.(sogg).(t));

            for stim_num = 1:size(campi,1)

                if isequal(contatore,1)
                    Xnew = feature_vector_test.(sogg).(t).(campi{stim_num,1})(:)';
                else

                    Xnew = [Xnew; feature_vector_test.(sogg).(t).(campi{stim_num,1})(:)'];
                end
                Y(contatore,1) = t;
                contatore = contatore + 1;
            end

        end

%%

% con i non classificati
predizioni = string(); %inizializzo la variabile delle classi predette come
% matrice di stringhe.
%predizioni sarà una matrice di stringhe di dimensioni NxK con N = numero
%di elementi da valutare e K = k (valore usato nel k fold): in questo
%modo l' elemento (i,j) della matrice indica la classificazione dell'
%elemento i-esimo da parte del classificatore j-esimo.

for idx_classificatore = 1:k %ciclo sui vari classificatori presenti

    [label,scores,cost] = predict(MdlLinear.Trained{idx_classificatore,1},Xnew);

    [X1,Y1,T,AUC] = perfcurve(Y,scores(:,2),"Target");

    %punto operativo ottimale = punto a distanza MAGGIORE dal punto (1,0)
    %per ogni punto della ROC devo calcolare la distanza da tale punto.
    clear distanza

    for idx = 1:length(X1)

        distanza(idx) = norm([X1(idx);Y1(idx)]-[1;0],2); %distanza euclidea = norma 2

    end

    idx_new = find(distanza == max(distanza),1);

    thresh = T(idx_new);

   

    for elem=1:size(scores,1)

        if scores(elem,2)>thresh %classe positiva (Target)

            predizioni(elem,idx_classificatore) = "Target";

        else
            if scores(elem,2)<=alpha*thresh
                predizioni(elem,idx_classificatore)="Non_target";
            else
                predizioni(elem,idx_classificatore)="NON_CLASSIFICATO";
            end
        end
    end

end

%% implementazione majority voting

predizioni_finali = string(); %vettore di stringhe che conterrà il risultato del majority voting per ogni elemento

keySet = {'Target','Non_target','NON_CLASSIFICATO'};
valueSet = [0 0 0];

for elem=1:size(predizioni,1) %ciclo sulle righe di predizioni

        conteggio_voti = containers.Map(keySet,valueSet); %inizializzazione mappa per conteggio dei voti

    for idx_classificatore = 1:size(predizioni,2) %ciclo sulle colonne di predizioni
        
        conteggio_voti(predizioni(elem,idx_classificatore)) = conteggio_voti(predizioni(elem,idx_classificatore))+1;

    end

    voto_max = max(cell2mat(values(conteggio_voti))); %prendo il conteggio più alto
    
    %devo trovare la chiave corrispondente al valore voto_max
    chiave = '';


    for key = keys(conteggio_voti)

        if (isequal(conteggio_voti(cell2mat(key)),voto_max))
            chiave = cell2mat(key);
            break %effettuo l' assegnazione una volta sola anche in caso di pareggio nel majority voting
        end

    end

    if isempty(chiave) %se fin qui chiave non ha avuto nesssun assegnazione, qualcosa è andato storto
        error("unable to perform majority voting correctly");
    end
    
    predizioni_finali(elem) = string(chiave);

end

end