# Thesis_BCI_Center_Speller
Repository con i codici Matlab usati nella tesi di laurea magistrale in ingegneria biomedica "Implementazione e valutazione di un nuovo algoritmo di processing e classificazione per la BCI Center Speller" di Alessio Calvagno.

I codici da eseguire (in qualsiasi ordine) per la parte di elaborazione dei segnali e feature extraction sono:
- estrazione_feature_vector.m
- estrazione_feature_vector_test_set.m 

I codici da eseguire per la parte di allenamento e classificazione sono:
- classNoBilKfoldConTest.m
- classBilKfoldConTest_parallel_v2.m

Anche questi ultimi due codici possono essere eseguiti in qualsiasi ordine.

Tutti gli altri codici e files inseriti sono funzioni utilizzate nei codici sopra menzionati, o files .mat contenenti particolari variabili ottenute durante l'esecuzione dei codici. Per più informazioni v. doc-string contenuta all'inizio di ogni codice, consultabile anche nella command window di Matlab con "help nome_file".

Per il corretto funzionamento degli script di elaborazione e feature extraction è necessario inserire i files .mat contenenti i segnali EEG, in una sottocartella chiamata "dati". I files .mat contenenti i segnali EEG e altre info, da cui parte l' elaborazione, NON sono inclusi in tale repository, ma sono liberamente scaricabili da: http://bnci-horizon-2020.eu/database/data-sets (numero 17). 

Per più informazioni sui files .mat con i segnali EEG fare riferimento all'articolo da cui parte il lavoro di tesi: 
M. Treder, N. Schmidt e B. Blankertz, «Gaze-independent brain–computer interfaces based on covert
attention and feature attention» Journal of Neural Engineering, vol. 8, 2011.
