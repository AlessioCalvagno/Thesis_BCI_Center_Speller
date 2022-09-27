function [predizioni_finali,Xnew,Y] = testa_classificatori_train_bilanciato(MdlLinear,Xnew,Y,k,alpha)
% [predizioni_finali,Xnew,Y] = testa_classificatori_train_bilanciato(MdlLinear,Xnew,Y,k,alpha)
% 
% Variante della funzione testa_classificatori.m adattata al caso di train
% set bilanciato (cambiano solo gli input della funzione, le operazioni
% eseguite sono le stesse).
% 
% Input: 
% - MdlLinear: oggetto restituito dalla funzione fitcdiscr, contenente i k
% classsificatori ottenuti e altre informazioni (v.
% ClassificationPartitionedModel e allena_classificatori.m).
% 
% - Xnew: matrice contenente i feature vectors del data set bilanciato 
% (sulle righe vi sono gli elementi, sulle colonne le
% relative features, v. allena_classificatori.m).
% 
% - Y: vettore contenente le classi reali degli elementi del train set
% (vettore colonna di lunghezza uguale al numero di righe di X, 
% v. allena_classificatori.m).
% 
% - k: valore usato nel k-fold.
% 
% - alpha: valore da usare per regolare la zona grigia dei non
% classificati (compreso tra 0.5 e 1).
% 
% Output:
% 
% - predizioni_finali: vettore delle predizioni dopo majority voting.
% - Xnew: la stessa passata in input.
% - Y: la stessa passata in input.


%%

% con i non classificati
predizioni = string(); %inizializzo la variabile delle classi predette come
% matrice di stringhe.
%preidzioni sarà una matrice di stringhe di dimensioni NxK con N = numero
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