function CM = confusion_matrix_3_classes(true_classes,predicted)
% CM = confusion_matrix_3_classes(true_classes,predicted)
%
% Funzione che calcola la matrice di confusione nel caso di 3 classi
% predette e 2 classi vere, cioè quando il classificatore restituisce pure
% i non classificati.
% 
% Input:
% - true_classes = vettore che contiene le classi vere degli elementi
% 
% - predicted = vettore che contiene le classi predette degli elementi
% 
% Output:
% - CM = matrice di confusione di dimensioni 2x3 (le classi predette sono
% sulle colonne, le classi vere sono sulle righe).

if ~(isequal(size(true_classes),size(predicted))||isequal(size(true_classes),size(predicted')))
    %L' OR messo nell' if gestisce il caso in cui ho un vettore riga e un
    %vettore colonna (situazione comunque ammessa in questo contesto)
    error("I due vettori di input devono avere stesse dimensioni, pari al numero di elementi considerati")
end

CM = zeros([2,3]);

for elem=1:length(predicted)

    switch predicted(elem)
        case "Target" %mi muovo su colonna 1
            switch true_classes(elem)
                case "Target" %TRUE POSITIVE
                    CM(1,1) = CM(1,1)+1;
                case "Non_target" %FALSE POSITIVE
                    CM(2,1) = CM(2,1)+1;
            end
        case "Non_target" %mi muovo su colonna 2
            switch true_classes(elem)
                case "Target" %FALSE NEGATIVE
                    CM(1,2) = CM(1,2)+1;
                case "Non_target" %TRUE NEGATIVE
                    CM(2,2) = CM(2,2)+1;
            end

        otherwise %caso non classificato - mi muovo su colonna 3
            switch true_classes(elem)
                case "Target"
                    CM(1,3) = CM(1,3)+1;
                case "Non_target"
                    CM(2,3) = CM(2,3)+1;
            end
    end
end


end