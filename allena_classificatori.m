function [MdlLinear,X,Y] = allena_classificatori(feature_vector_train,k,sogg)
% [MdlLinear,X,Y] = allena_classificatori(feature_vector_train,k)
% 
% Funzione che allena i classificari LDA usando il k fold come tecnica di
% cross-validazione. Si effettua il bilanciamento del train set a monte
% dell' allenamento.
% 
% Input:
% - feature_vector_train: struttura contenente le feature vector estratte
% dal training set, con distinzione tra stimolo target e stimolo non target
% (v. codice "estrazione_feature_vector.m" per più info sull'
% organizzazione di tale struttura).
% 
% - k: valore di k da usare per il k fold.
% 
% -sogg: stringa del tipo "soggetto_n" con n= intero tra 1 e 13, utile per
% accedere dentro la struttura feature_vector_train.
% 
% Output:
% - MdlLinear: oggetto restituito dalla funzione fitcdiscr, contenente i k
% classsificatori ottenuti e altre informazioni (v.
% ClassificationPartitionedModel).
% 
% - X: matrice che contiene il training set bilanciato effettivamente usato
% nell' allenamento (sulle righe vi sono gli elementi, sulle colonne le
% relative features).
% 
% - Y: vettore contenente le classi reali degli elementi del train set
% (vettore colonna di lunghezza uguale al numero di righe di X).

%% creazione train set bilanciato

            X=[]; %matrice che conterrà le osservazioni e le variabili di predizione
            % (cioè i vari feature vector, disposti nelle righe della matrice)
            Y = [""]; %vettore delle classi

            N_non_target = size(fieldnames(feature_vector_train.(sogg).Non_target),1); %numero di stimoli non target
            N_target = size(fieldnames(feature_vector_train.(sogg).Target),1); %numero di stimoli target

            % N_non_target = 1700 e N_target = 340;

            contatore = 1;

            for t = ["Target","Non_target"]

                campi = fieldnames(feature_vector_train.(sogg).(t));

                switch t

                    case "Target" %per lo stimolo target non faccio niente in particolare, poichè è la classe meno numerosa

                        for stim_num = 1:size(campi,1)

                            if isequal(contatore,1)
                                X = feature_vector_train.(sogg).(t).(campi{stim_num,1})(:)';
                            else

                                X = [X; feature_vector_train.(sogg).(t).(campi{stim_num,1})(:)'];
                            end
                            Y(contatore,1) = t;
                            contatore = contatore + 1;
                        end

                    case "Non_target" %per lo stimolo Non_target devo fare l' estrazione casuale degli elementi per bilanciare il training set

                        %creo vettore colonna di lunghezza = num stimoli target
                        %(classe meno numerosa) che contiene gli indici degli
                        %stimoli non target da estrarre
                       
                        stimoli_selezionati = randperm(N_non_target,N_target); %così ottengo valori interi unici dall' intervallo [1, N_non_target]
                        for stim_num = 1:length(stimoli_selezionati)

                            %per lo stimolo non target non dovrei mai entrare in
                            %questo if poichè qui contatore è sicuramente > 1.
                            if isequal(contatore,1)
                                X = feature_vector_train.(sogg).(t).(campi{stimoli_selezionati(stim_num),1})(:)';
                            else
                                X = [X; feature_vector_train.(sogg).(t).(campi{stimoli_selezionati(stim_num),1})(:)'];
                            end
                            Y(contatore,1) = t;
                            contatore = contatore + 1;
                        end
                end

            end

            %creo classificatore LDA - con K-Fold come metodo di cross
            %validazione
            MdlLinear = fitcdiscr(X,Y,'KFold',k); %NOTA: il k deve essere un parametro.
            %facendo il k-fold Matlab garantisce la proporzione originale
            %del data set nelle ripartizioni in k gruppi (verificato in passato).

end