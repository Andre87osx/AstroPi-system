> Ekos è uno strumento avanzato di controllo e automazione dell'osservatorio con particolare attenzione all'astrofiografia. Si basa su una struttura modulare estensibile per eseguire attività di astrofifotografia comuni. Ciò include GOTO altamente accurati che utilizzano il risolutore Stellar Solver, la capacità di misurare e correggere gli errori di allineamento polare, la messa a fuoco automatica e le funzionalità di guida automatica, l'acquisizione di immagini singole o stack di immagini con supporto della ruota filtro. Ekos è parte integrante di Kstars KStars come tutti i sui moduli (non servono altre applicazioni esterne).

# Installazione di Ekos
Ekos Astrophotography Tool è organizzato in diversi moduli. Un modulo è un insieme di funzioni e attività per un particolare passaggio nell'astrofotografia e/o nell'acquisizione dei dati. Attualmente, i seguenti moduli sono inclusi in Ekos, ogni modulo ha la sua scheda e icona nell'interfaccia utente grafica come illustrato nello screenshot qui sotto:

### Modulo riepilogativo e installazione
Come suggerisce il nome, è qui che creerai e gestirai il tuo profilo dell'apparecchiatura e ti connetterai ai tuoi dispositivi. Fornisce anche una visualizzazione riepilogativo in cui lo stato di avanzamento dell'acquisizione insieme alle operazioni di messa a fuoco e guida viene visualizzato in un formato compatto per trasmettere le informazioni più importanti rilevanti per l'utente.

### Modulo Scheduler
Dopo aver padroneggiato Ekos, gli utenti sono incoraggiati a imparare come utilizzare il modulo Scheduler poiché facilita notevolmente l'intero processo di osservazione. Consente di selezionare più destinazioni, specificare quali condizioni e requisiti devono essere soddisfatti e quali fotogrammi sono necessari per l'acquisizione. Successivamente l'utilità di pianificazione calcola in modo intelligente il miglior tempo di osservazione per ogni oggetto e quindi procede al controllo dell'osservatorio completo dall'avvio allo spegnimento.

### Modulo di acquisizione
Questo è il modulo principale per il controllo della ruota della fotocamera e del filtro. Crea sequenze di imaging, acquisisci anteprime e guarda i flussi video. Supporta il controllo dei rotatori e può acquisire automaticamente fotogrammi piatti in una serie di scenari.

### Modulo Messa a fuoco
Misura la nitidezza delle tue immagini nel modulo di messa a fuoco calcolando Mezzo flusso-raggio. Più basso è l'HFR, più nitida diventa l'immagine. È possibile eseguire il modulo di messa a fuoco con o senza uno stato attivo. Con un focuser elettronico, è possibile eseguire un'operazione di messa a fuoco automatica in cui Ekos itera e calcola la posizione di messa a fuoco ottica.

### Modulo guida
Per ottenere un'astrofiografia a lunga esposizione, è necessaria una guida per garantire che l'immagine sia bloccata e stabilizzata per tutta la durata dell'esposizione. Le deviazioni dal fotogramma con il tempo possono portare a immagini sfocate e percorsi stellari. Nel modulo guida, può selezionare automaticamente una stella guida adatta e quindi bloccare il supporto per mantenere sempre quella stella nella sua posizione. Se il modulo guida rileva una deviazione da questa posizione bloccata, invia impulsi di correzione al supporto per riportarlo nella posizione originale.

### Modulo montaggio
Il controllo del montaggio può essere effettuato tramite Sky Map in modo interattivo o tramite il Pannello di controllo del montaggio nel modulo di montaggio. Configura le proprietà del telescopio (lunghezza focale e apertura) sia per il telescopio di imaging primario che per l'ambito guida. Tuttavia, si consiglia di selezionare i telescopi nel profilo dell'apparecchiatura e di non modificare i valori direttamente nel modulo di montaggio.

# Creazione guidata profilo
La Creazione guidata profilo è uno strumento pratico per configurare l'apparecchiatura per la prima volta. Dovrebbe essere popup automaticamente la prima volta che si esegue KStars. Seguire le istruzioni guidate per configurare il primo profilo dell'apparecchiatura.

- Pagina di saluto
Profile Wizard Welcome
La prima schermata di saluto contiene alcuni collegamenti per saperne di più su Ekos e INDI. Fare clic su Avanti per continuare.

- Pagina Posizione attrezzatura
Successivamente, ti verrà presentata la pagina della posizione dell'attrezzatura. La selezione dipende da dove l'apparecchiatura è collegata a:

- L'apparecchiatura è collegata al PC:selezionare questa opzione se Ekos è in esecuzione su StellarMate (tramite HDMI o VNC), PC(Windows®/Linux®) o Mac® OS.

- L'apparecchiatura è collegata a un computer remoto:selezionare questa opzione se Ekos è in esecuzione sul PC(Windows®/Linux®) o Mac® OSe l'apparecchiatura è connessa a un computer remoto.

- L'apparecchiatura è collegata a StellarMate: selezionare questa opzione se Ekos è in esecuzione sul PC(Windows®/Linux®) o Mac® OSe l'apparecchiatura è collegata a StellarMate.

Equipment location page
Fare clic su Avanti per continuare.

Pagina connessione remota
Nel caso in cui sia stata selezionata la seconda opzione nell'ultimo passaggio, ti verrà presentata la Pagina Di connessione remota, qui inserirai il nome host o l'indirizzo IP dell'unità StellarMate. In alternativa, è possibile creare il nome host dall'app mobile StellarMate. In alternativa, è possibile costruire il nome host da StellarMate HotSpot SSID. Dovresti vedere l'SSID quando cerchi reti WiFi nelle vicinanze. Si supponga, ad esempio, che l'SSID sia stellarmate. Il nome host deve essere stellarmate.local. In altre condizioni, se si rimuove il carattere di sottolineatura e si aggiunge .local, si oserà il nome host dell'unità. Puoi sempre utilizzare l'app StellarMate per modificare il nome host predefinito dell'unità in base al nome desiderato.



Pagina creazione profilo
Ora puoi nominare il tuo profilo dell'attrezzatura. Successivamente selezionare l'applicazione guida da utilizzare. L'Internal Guider è l'unica selezione ufficialmente supportata in StellarMate. È possibile scegliere di selezionare PHD2/LinGuider, ma i dettagli non sono nell'ambito di questa documentazione. Se si desidera servizi aggiuntivi, controllare quelli che si desidera eseguire.

The final page of Profile Wizard
Nell'esempio precedente, selezioniamo driver Remote Astrometry, WatchDog e SkySafari. Le spiegazioni dettagliate per ciascuno di essi sono fornite nella descrizione comando quando le si sovrapporne. Al termine, fare clic sul pulsante Crea profilo. Ora dovresti essere presentato con l'Editor profili.

Editor profili
Profile Editor
Profili
È possibile definire i profili per l'apparecchiatura e la modalità di connessione utilizzando l'Editor profili. Ekos viene preinstallato con il profilo Simulatori che può essere utilizzato per avviare dispositivi simulatore a scopo dimostrativo:

Modalità di connessione:Ekos può essere avviato localmente o in remoto. La modalità locale è quando Ekos è in esecuzione nella stessa macchina del server INDI, cioè tutti i dispositivi sono collegati direttamente alla macchina. Se si esegue il server INDI in un computer remoto, ad esempio su un server Raspberry PI, è necessario impostare l'host e la porta del server INDI.

Connessione automatica:selezionare questa opzione per abilitare la connessione automatica a tutti i dispositivi dopo l'avvio del server INDI. Se deselezionata, i dispositivi INDI vengono creati ma non connessi automaticamente. Ciò è utile quando si desidera apportare modifiche al driver(ad esempio, modificare la velocità in baud o l'indirizzo IP o qualsiasi altra impostazioni) prima di connettersi ad esso.

Informazioni sito:facoltativamente, è possibile selezionare la casella di controllo Informazioni sito e Ekos caricherà la città e il fuso orario correnti ogni volta che Ekos viene avviato con questo profilo. Questo può essere utile quando ci si connette al sito geografico remoto in modo che Ekos sia in posizione di sincronizzazione e per quanto riguarda il tempo.

Guida:selezionare l'applicazione Guida che si desidera utilizzare per la guida. Per impostazione predefinita, viene utilizzato il modulo guida interno Ekos. Gli guide esterni includono PHD2 e LinGuider.

INDI Web Manager: StellarMate Web Manager è uno strumento basato sul Web per avviare e arrestare i driver INDI. Dovresti sempre controllare questa opzione quando ti connetto da remoto a un'unità StellarMate.

Selezione dispositivo:selezionare i dispositivi da ogni categoria. Si prega di notare che se si dispone di un CCD con una testa guida, è possibile lasciare vuoto il menu a discesa del guider poiché Ekos rileverà automaticamente la testa della guida dalla fotocamera CCD. Allo stesso modo, se il CCD include il supporto incorporato della ruota del filtro, non è necessario specificare il dispositivo della ruota filtro nel menu a discesa del filtro.

Avviare e arrestare INDI
Avviare e arrestare i servizi INDI. Una volta stabilito il server INDI, verrà visualizzato il Pannello di controllo INDI. Qui è possibile modificare alcune opzioni del driver come la porta a cui è collegato il dispositivo, ecc.

Connettere e disconnettere dispositivi
Connettersi al server INDI. In base ai dispositivi collegati, saranno stabiliti e disponibili per l'uso i moduli Ekos (CCD, Focus, Guide, ecc.).

Una volta pronto, fare clic su Avvia INDI per stabilire il server INDI e la connessione all'apparecchiatura. Ekos deve creare le varie icone del modulo (Montaggio, Acquisizione, Messa a fuoco, ecc.)man mano che viene stabilita la connessione con il dispositivo.

Registri
La registrazione è uno strumento molto importante per diagnosticare eventuali problemi con i driver INDI o Ekos. Prima di inviare qualsiasi richiesta di supporto, il registro deve essere allegato per aiutare a diagnosticare il problema esatto. A seconda del problema esatto, potrebbe essere necessario abilitare la registrazione per la funzionalità o i driver che presentano problemi. L'abilitazione della registrazione per tutto non è consigliata in quanto produrrà troppi dati che sarebbero utili per diagnosticare il problema e potrebbero comportare la mancanza della causa principale per tutti gli altri. Quindi abilita solo i registri necessari.

Nel breve video seguente viene illustrato come utilizzare la funzionalità Registrazione per inviare i log.


Funzione di registrazione

cattura
Ekos Capture
Il modulo CCD è il modulo principale di acquisizione di immagini e video in Ekos. Consente di acquisire singole (anteprima), più immagini (coda di sequenza) o registrare video SER insieme a una selezione di ruote filtro e rotatore, se disponibili.

Gruppo ruote CCD e filtro
Selezionare il CCD/DSLR desiderato e la ruota filtro (se disponibile) per l'acquisizione. Impostare la temperatura ccd e le impostazioni del filtro.

CCD:selezionare la telecamera CCD attiva. Se la fotocamera ha una testa di guida, puoi selezionarla anche da qui.

FW: selezionare il dispositivo ruota filtro attivo. Se la fotocamera ha una ruota filtro integrata, il dispositivo sarebbe lo stesso della fotocamera.

Dispositivo di raffreddamento:attivare/disattivare il dispositivo di raffreddamento. Impostare la temperatura desiderata, se la fotocamera è dotata di un dispositivo di raffreddamento. Controllare l'opzione per forzare l'impostazione della temperatura prima di qualsiasi acquisizione. Il processo di cattura viene avviato solo dopo che la temperatura misurata è entro la tolleranza di temperatura richiesta. La tolleranza di default è di 0,1 gradi Celsius, ma può essere regolata nelle opzioni di acquisizione in configurazione Ekos.

Impostazioni di acquisizione
Capture Settings
Impostare tutti i parametri di acquisizione come descritto di seguito. Una volta impostato, è possibile acquisire un'anteprima facendo clic su Anteprima o aggiungere un processo alla coda di sequenza.

Esposizione:specificare la durata dell'esposizione in secondi.

Filtro:specificare il filtro desiderato.

Conteggio:numero di immagini da acquisire

Ritardo:ritardo in secondi tra le acquisizioni di immagini.

Tipo:specificare il tipo di frame CCD desiderato. Le opzioni sono Fotogrammi Chiaro, Scuro, Distorsione e Piatto.

ISO: per le fotocamere DSLR, specificare il valore ISO.

Formato:specificare il formato di salvataggio dell'acquisizione. Per tutti i CCD è disponibile solo l'opzione FITS. Per le fotocamere DSLR, è possibile utilizzare un'opzione aggiuntiva per risparmiare in formato nativo(ad esempio RAW o JPEG).

Proprietà personalizzate:impostare le proprietà estese disponibili nella fotocamera sulle impostazioni del processo.

Calibrazione: per &scuri; Fotogrammi piatti, potete impostare opzioni aggiuntive spiegate nella sezione Fotogrammi di calibrazione riportata di seguito.

Fotogramma:specificare la sinistra (X), la parte superiore (Y), la larghezza (W) e l'altezza (H) del fotogramma CCD desiderato. Se avete modificato le quote del fotogramma, potete reimpostarla sui valori predefiniti facendo clic sul pulsante di ripristino.

Binning: specificare l'binning orizzontale (X) e verticale (Y).

Proprietà personalizzate
Molte fotocamere offrono proprietà aggiuntive che non possono essere impostate direttamente nelle impostazioni di acquisizione utilizzando il controllo comune. I controlli di acquisizione sopra descritti rappresentano le impostazioni più comuni condivise tra diverse fotocamere, ma ogni fotocamera è unica e può offrire le proprie proprietà estese. Sebbene sia possibile utilizzare il Pannello di controllo INDI per impostare qualsiasi proprietà nel driver; è importante essere in grado di impostare tale proprietà per ogni processo nella sequenza. Quando si fa clic su Proprietà personalizzate, viene visualizzata una finestra di dialogo suddivisa in Proprietà disponibili e Proprietà processo. Quando si sposta una proprietà disponibile nell'elenco Proprietà processo, il relativo valore corrente può essere registrato una volta fatto clic su Applica. Quando si aggiunge un processo alla coda di sequenza, i valori delle proprietà selezionati nell'elenco Proprietà processo devono essere registrati e salvati.

Il seguente video spiega questo concetto è più dettagliato con un esempio dal vivo:


Caratteristica Proprietà personalizzate

Impostazioni file
File Settings
Impostazioni per specificare dove vengono salvate le immagini acquisite e come generare nomi di file univoci oltre alle impostazioni della modalità di caricamento.

Prefisso :specificare il prefisso da aggiungere al nome file generato. È inoltre possibile aggiungere il tipo di frame, il filtro, la durata dell'esposizione e il timestamp ISO 8601. Ad esempio, se si specifica Prefisso come M45 e si selezionano le caselle di controllo Tipo e Filtro e si supposto che il filtro sia stato impostato su Rosso e che il tipo di frame sia Light, i nomi di file generati saranno i seguenti:

M45_Light_Red_001.fits

M45_Light_Red_002.fits

Se TS è stato selezionato, verrà aggiunto un timestamp al nome del file, ad esempio

M45_Light_Red_001_2016-11-09T23-47-46.fits

M45_Light_Red_002_2016-11-09T23-48-34.fits

Script:specificare uno script facoltativo da eseguire al termine di ogni acquisizione. È necessario specificare il percorso completo dello script e eseguibile. Per indicare il successo, lo script deve restituire zero in quanto ciò consentirebbe alla sequenza di continuare. Se lo script restituisce un valore non zero, la sequenza viene interrotta.

Directory: directory locale in cui salvare le immagini della sequenza.

Carica:selezionare la modalità di caricamento delle immagini acquisite:

Client:le immagini acquisite vengono caricate solo in Ekos e salvate nella directory locale specificata in precedenza.

Locale:le immagini acquisite vengono salvate solo localmente nel computer remoto.

Entrambi:le immagini acquisite vengono salvate sul dispositivo remoto e caricate su Ekos.

Quando si seleziona Locale o Entrambi, è necessario specificare la directory remota in cui vengono salvate le immagini remote. Per impostazione predefinita, tutte le immagini acquisite vengono caricate su Ekos.

Remoto:quando si selezionano le modalità Locale o Entrambe le modalità precedenti, è necessario specificare la directory remota in cui vengono salvate le immagini remote.

Limita impostazioni
Limit Settings
Le impostazioni limite sono applicabili a tutte le immagini nella coda di sequenza. In caso di superamento di un limite, Ekos comanda l'azione appropriata per porre rimedio alla situazione, come spiegato di seguito.

Deviazione guida: Se selezionata, applica un limite di deviazione guida massima consentita per l'esposizione, se si utilizza l'autoguida. Se la deviazione guida supera questo limite in secondi d'arco, interrompe la sequenza di esposizione. Riprenderà automaticamente la sequenza di esposizione una volta che la deviazione guida scende al di sotto di questo limite.

Messa a fuoco automatica se HFR >: Se l'autofocus è abilitato nel modulo di messa a fuoco e almeno un'operazione di messa a fuoco automatica è stata completata correttamente, è possibile impostare il valore HFR massimo accettabile. Se questa opzione è abilitata tra esposizioni consecutive, il valore HFR viene ricalcolato e, se viene rilevato che supera il valore HFR massimo accettabile, viene attivata automaticamente un'operazione di messa a fuoco automatica. Se l'operazione di messa a fuoco automatica viene completata correttamente, la coda di sequenza riprenderà, altrimenti il processo viene interrotto.

Capovolgimento meridiano: se supportato dal supporto, impostare il limite dell'angolo delle ore (in ore) prima che sia comandato un capovolgimento meridiano. Ad esempio, se si imposta la durata di capovolgimento del meridiano su 0,1 ore, Ekos attenderà fino a quando il supporto non supera il meridiano di 0,1 ore (6 minuti), quindi comanda al supporto di eseguire un capovolgimento meridiano. Al termine del capovolgimento del meridiano, Ekos si rilinea utilizzando astrometry.net (se l'allineamento è stato utilizzato) e riprende la guida (se è stato avviato prima) e quindi riprende automaticamente il processo di acquisizione.

Coda sequenza
Coda sequenza è l'hub principale del modulo di acquisizione Ekos. È qui che è possibile pianificare ed eseguire processi utilizzando l'editor potente incorporato nella coda di sequenza. Per aggiungere un processo, è sufficiente selezionare tutti i parametri dalle impostazioni di acquisizione e file come indicato sopra. Dopo aver selezionato i parametri desiderati,  fare clic sul pulsante Aggiungi nella coda di sequenza per aggiungerlo alla coda.

Sequence Queue
È possibile aggiungere tutti i processi desiderati. Anche se non è strettamente necessario, è preferibile aggiungere i lavori scuri e piatti dopo i telai di luce. Al termine dell'aggiunta dei processi, è sufficiente fare clic su Avvia sequenza  per iniziare l'esecuzione dei processi. Uno stato del processo passa da Inattivo a In corso e infine a Completo una volta completato. La coda sequenza avvia automaticamente il processo successivo. Se un processo viene interrotto, potrebbe essere ripreso di nuovo. Per sospendere una sequenza,  fare clic sul pulsante di pausa e la sequenza verrà interrotta al termine dell'acquisizione corrente. Per reimpostare lo stato di tutti i  processi, è sufficiente fare clic sul pulsante di ripristino . Fai attenzione che anche tutti i conteggi dei progressi dell'immagine vengono ripristinati. Per visualizzare in anteprima un'immagine in KStars FITS Viewer, fate clic sul pulsante Anteprima.

Le code di sequenza possono essere salvate come file XML con estensione (Coda sequenza Ekos). Per caricare una coda di sequenza, fare clic sul pulsante apri documento  . Si prega di notare che sostituirà tutte le code di sequenza correnti in Ekos. .esq

importante
Avanzamento processo:Ekos è progettato per eseguire e riprendere la sequenza su più notti, se necessario. Pertanto, se l'opzione Ricorda avanzamento processo è abilitata in Opzioni Ekos, Ekos eseguirà la scansione del file system per contare quante immagini sono già state completate e riprenderà la sequenza da dove è stata lasciata. Se questo comportamento predefinito non è desiderato, è sufficiente disattivare Ricorda avanzamento processo in opzioni.

Per modificare un processo, fare doppio clic su di esso. Si noterà che  il pulsante aggiungi  ora viene modificato per controllare il pulsante . Apportare le modifiche sul lato sinistro del modulo CCD e, una volta fatto, fare clic sul pulsante del segno di spunta. Per annullare una modifica del processo, fare clic in un punto qualsiasi dello spazio vuoto all'interno della tabella della coda di sequenza.

Se la videocamera supporta il feed video in diretta, puoi fare clic sul pulsante Video in diretta per avviare lo streaming. La finestra del flusso video consente la registrazione e la sottoframing del flusso video. Per ulteriori informazioni, consultare il video seguente:


Funzione di registrazione

Impostazioni filtro
Filter Queue
Fare clic  sull'icona del filtro accanto alla casella di selezione della rotellina del filtro per aprire la finestra di dialogo impostazioni filtro. Se si utilizzano filtri non parafocali tra loro e che richiedono una quantità specifica di offset dello stato attivo per renderli appropriati, impostare tutti gli offset relativi dello stato attivo nella finestra di dialogo.

Configurare le impostazioni per ogni filtro singolarmente:

Filtro:Nome filtro

Esposizione:impostare il tempo di esposizione utilizzato quando si esegue lo stato attivo sotto questo filtro. Per impostazione predefinita, è impostato su 1 secondo.

Offset: imposta offset relativi. Ekos comanderà una modifica dell'offset dello stato attivo se c'è una differenza tra gli offset del filtro corrente e quello di destinazione. Ad esempio, dati i valori nell'immagine di esempio, se il filtro corrente è impostato su Rosso e il filtro successivo è Verde, Ekos comanderà al focuser di mettere a fuoco per +300 segni di graduazione. Gli offset di messa a fuoco positivi relativi denotano lo stato attivo mentre i valori negativi denotano lo stato attivo in.

Messa a fuocoautomatica: selezionare questa opzione per il processo di messa a fuoco automatica iniziale ogni volta che il filtro viene modificato in questo filtro.

Filtro di blocco:impostare il filtro da impostare e bloccare durante l'esecuzione della messa a fuoco automatica per questo filtro.

Facciamo un esempio. Si supponga che la sequenza di acquisizione sia in esecuzione e che il filtro corrente sia Verde, pertanto l'offset relativo è già impostato su +300. L'immagine successiva nella sequenza utilizza Hydrogen Alpha (H_Alpha) quindi prima che Ekos catturi il fotogramma successivo, si svolgono le seguenti azioni:

Poiché la luminosità viene specificata come filtro bloccato e lo stato attivo automatico è selezionato, il filtro viene modificato in Luminosità

Un offset dello stato attivo è -300 applicato poiché il filtro precedente Green è stato spostato +300 in precedenza.

Viene avviato il processo di messa a fuoco automatica.

Una volta completata la messa a fuoco automatica, il filtro viene modificato in H_Alpha.

Viene applicato un offset dello stato attivo di -1200.

La sequenza di acquisizione viene ripresa.

Visualizzatore FITS
Le immagini acquisite vengono visualizzate nello strumento KStars FITS Viewer e anche nella schermata di riepilogo. Impostare le opzioni relative alla modalità di visualizzazione delle immagini nel visualizzatore.

Scuro automatico:è possibile acquisire un'immagine e sottrarla automaticamente scura selezionando questa opzione. Si noti che questa opzione è applicabile solo quando si utilizza Anteprima, non è possibile utilizzarla nella coda di sequenza in modalità batch.

Effects: Image enhancement filter to be applied to the image after capture.

Rotator Settings
Rotator Settings
Field Rotators are supported in INDI & Ekos. The rotator angle is the raw angle reported by the rotator and is not necessary the Position Angle. A Position Angle of zero indicates that the frame top (indicated by small arrow) is pointing directly at the pole. The position angle is expressed as E of N (East of North), so 90 degrees PA indicates the frame top points 90 degrees away (counter-clockwise) from the pole. Check examples for various PAs.

To calibrate the Position Angle (PA), capture and solve an image in the Ekos Align module. An offset and a multiplier are applied to the raw angle to produce the position angle. The Ekos Rotator dialog permits direct control of the raw angle and also the PA. The offset and multiplier can be changed manually to synchronize the rotator's raw angle with the actual PA. Check Sync FOV to PA to rotate the current Field of View (FOV) indicator on the Sky Map with the PA value as you change it in the dialog.


Rotator settings

Each capture job may be assigned different rotator angles, but be aware that this would cause guiding to abort as it would lose track of the guide star when rotating. Therefore, for most sequences, the rotator angle is kept the same for all capture jobs.

Calibration Frames
Calibration settings
For Flat Field frames, you can set calibration options in order to automate the process. The calibration options are designed to facilitate automatic unattended flat field frame capture. It can also be used for dark and bias frames if desired. If your camera is equipped with a mechanical shutter, then it is not necessary to set calibration settings unless you want to close the dust cover to ensure no light at all passes through the optical tube. For flat fields, you must specify the flat field light source, and then specify the duration of the flat field frame. The duration can be either manual or based on ADU calculations.

Flat Field Source

Manual: The flat light source is manual.

Dust Cover with Built-In Flat Light: If using a dust cover with builtin light source (e.g. FlipFlat). For dark and bias frames, close the dust cap before proceeding. For flat frames, close the dust cap and turn on the light source.

Dust Cover with External Flat Light: If using a dust cover with an external flat light source. For dark and bias frames, close the dust cap before proceeding. For flat frames, open the dust cap and turn on the light source. The external flat light source location is presumed to be the parking location.

Wall: Light source is a panel on the observatory wall. Specify the Azimuth and Altitude coordinates of the panel and the mount shall slew there before capturing the flat field frames. If the light panel is controllable from INDI, Ekos shall turn it on/off as required.

Dawn/Dusk: Currently unsupported.

Flat Field Duration

Manual: Duration is as specified in the Sequence Queue.

ADU: Duration is variable until specified ADU is met.

Before the calibration capture process is started, you can request Ekos to park the mount and/or dome. Depending on your flat source selection above, Ekos will use the appropriate flat light source before starting flat frames capture. If ADU is specified, Ekos begins by capturing a couple of preview images to establish the curve required to achieve the desired ADU count. Once an appropriate value is calculated, another capture is taken and ADU is recounted until a satisfactory value is achieved.

Video Tutorials

Capture


Filter Wheels

Focus
Theory Of Operation
Ekos Focus
In order to focus an image, Ekos needs to establish a numerical method for gauging how good your focus is. It's easy when you look at an image and can see it as unfocused, as the human is very good at detecting that, but how can Ekos possibly know that?

There are multiple methods. One is to calculate the Full Width at Half Maximum (FHWM) of a star profile within an image, and then adjust the focus until an optimal (narrower) FWHM is reached. The problem with FWHM is that it assumes the initial focus position to be close to the critical focus. Additionally, FWHM does not perform very well under low-intensity fluxes. An Alternative method is Half-Flux-Radius (HFR), which is a measure of the width in pixels counting from the center of the stars until the accumulated intensity is half of the total flux of the star. HFR proved to be much more stable in conditions where you might have unfavorable sky conditions, when the brightness profile of the stars is low, and when the starting position of the focus is far from the optimal focus.

After Ekos processes an image, it selects the brightest star and starts measuring its HFR. It can automatically select the star, or you can select the star manually. It is usually recommended to select stars that are not too bright as they might get saturated during the focusing process. A magnitude 3 or 4 star is often sufficient.

Ekos then begins the focusing process by commanding the focuser to focus inwards or outwards, and re-measures the HFR. This establishes a V-shaped curve in which the sweet spot of optimal focus is at the center of the V-curve, and the slope of which depends on the properties of the telescope and camera in use. In Ekos, a full V-curve is never constructed as the focusing process works iteratively, so under most circumstances, a half V-curve shape as illustrated in the Focus Module image is measured.

Because the HFR varies linearly with focus distance, it is possible to calculate the optimal focus point. In practice, Ekos operates iteratively by moving in discrete steps, decided initially by the user-configurable step size and later by the slope of the V-curve, to get closer to the optimal focus position where it then changes gears and performs smaller, finer moves to reach the optimal focus. In the default Iterative algorithm, the focus process stops when the measured HFR is within the configurable tolerance of the minimum recorded HFR in the process. In other words, whenever the process starts searching for a solution within a narrowly limited range, it checks if the current HFR is within % difference compared to the minimum HFR recorded, and if this condition is met then the autofocus process is considered successful. The default value is set to 1% and is sufficient for most situations. The Step options specify the number of initial ticks the focuser has to move. If the image is severely out of focus, we set the step size high (i.e. > 250). On the other hand, if the focus is close to optimal focus, we set the step size to a more reasonable range (< 50). It takes trial and error to find the best starting tick, but Ekos only uses that for the first focus motion, as all subsequent motions depend on the V-Curve slope calculations.

When using the Polynomial algorithm, the process starts in the Iterative mode, but once we cross to the other side of the V-curve (i.e. once HFR values start increasing again after decreasing for a while), the Ekos performs polynomial fitting to find a solution that predicts the minimum possible HFR position. If a valid solution is found, the autofocus process is considered successful.

While Ekos Focus Module supports relative focusers, it is highly recommended to use absolute focusers.

Focuser Group
Focuser Settings
Any INDI-compatible focuser is supported. It is recommended to use absolute focusers since their absolute position is known on power up. In INDI, the focuser zero position is when the drawtube is fully retracted. When focusing outwards, the focuser position increases, while it decreases when focusing inwards. The following focuser types are supported:

Absolute: Absolute Position Focusers such as RoboFocus, MoonLite, etc.

Relative: Relative Position Focusers.

Simple Focusers: DC/PWM focusers with no position feedback.

For absolute focusers, you can set the ticks count. To view a continuous feed of the camera, click the Framing button. An image shall be captured repeatedly according to the CCD settings in the CCD and Filter Wheel group. You can focus in and out by pressing the respective buttons, and each shall move by the step size indicated in the focus settings. For absolute and relative focusers, the step size is in units of ticks and for simple DC focusers, the step size is in milliseconds

To begin the autofocus process, simply click the Auto Focus button.

CCD & Filter Wheel Group
Focus CCD & Filter Wheel Group
You must specify the CCD and Filter Wheel (if any) to be used during the focusing process. You can lock a specific filter within the filter wheel to be utilized whenever the autofocus process is invoked. Usually, the user should select the Clear/Luminescence filter for this purpose so that Ekos always uses the same filter to perform the autofocus process. This locked filter is also used in the Alignment Module whenever it performs any astrometry capture.

You may also select an Effect filter to enhance the image for preview purposes. It is highly advisable to turn off any effects during the focusing process as it may interfere with HFR calculations. For DSLRs cameras, you can change the ISO settings. You may reset the focusing subframe to full frame capture if you click the Reset button.

Settings
Focus Settings
You may need to adjust focus settings in order to achieve a successful and reliable autofocus process. The settings are retained between sessions.

Auto Star Select: Automatically select the best focus star from the image.

Subframe: Subframe around the focus star during the autofocus procedure. Enabling subframing can significantly speed up the focus process.

Dark Frame: Check this option to capture a dark frame if necessary and perform dark-frame subtraction. This option can be useful in noisy images.

Suspend Guiding: Suspend Guiding while autofocus in progress. If the focus process can disrupt the guide star (e.g. when using Integrated Guide Port IGP whereas the guider is physically attached to the primary CCD), then it is recommended to enable this option. When using Off-Axis guider, then this option is not necessary.

Box size: Sets the box size used to enclose the focus star. Increase if you have very large stars. For Bahtinov focus the box size can be increased even more to better enclose the Bahtinov diffraction pattern.

Max Travel: Maximum travel in ticks before the autofocus process aborts.

Step: Initial step size in ticks to cause a noticeable change in HFR value. For timer-based focuser, it is the initial time in milliseconds to move the focuser inward or outward.

Tolerance: The tolerance percentage values decides when the autofocus process stops in the Iterative algorithm. During the autofocus process, HFR values are recorded, and once the focuser is close to an optimal position, it starts measuring HFRs against the minimum recorded HFR in the sessions and stops whenever a measured HFR value is within % difference of the minimum recorded HFR. Decrease value to narrow optimal focus point solution radius. Increase to expand solution radius.

Warning
Setting the value too low might result in a repetitive loop and would most likely result in a failed autofocus process.

Threshold: Threshold percentage value is used for star detection using the Threshold detection algorithm. Increase to restrict the centroid to bright cores. Decrease to enclose fuzzy stars.

Algorithm: Select the autofocus process algorithm:

Iterative: Moves focuser by discreet steps initially decided by the step size. Once a curve slope is calculated, further step sizes are calculated to reach an optimal solution. The algorithm stops when the measured HFR is within percentage tolerance of the minimum HFR recorded in the procedure.

Polynomial: Starts with the iterative method. Upon crossing to the other side of the V-Curve, polynomial fitting coefficients along with possible minimum solution are calculated. This algorithm can be faster than a purely iterative approach given a good data set.

Frames: Number of average frames to capture. During each capture, an HFR is recorded. If the instantaneous HFR value is unreliable, you can average a number of frames to increase the signal to noise ratio.

Detection: Select star detection algorithm. Each algorithm has its strengths and weaknesses. It is recommended to keep the default value unless it fails to properly detect stars.

Bahtinov: This detection method can be used when using a Bahtinov mask for focusing. First take an image, then select the star to focus on. A new image will be taken and the diffraction pattern will be analysed. Three lines will be displayed on the diffraction pattern showing how well the pattern is recognized and how good the image is in focus. When the pattern is not well recognized, the 'Num. of rows' parameter can be adjusted to improve recognition. The line with the circles at each end is a magnified indicator for the focus. The shorter the line, the better the image is in focus.

V-Curve
Focus V-Curve
La curva a forma di V mostra la posizione assoluta rispetto ai valori HFR (Half-Flux-Radius). Il centro della curva a V è la posizione di messa a fuoco ottimale. Una volta che Ekos attraversa da un lato all'altro della curva a V, arretra e cerca di trovare la posizione di messa a fuoco ottimale. La posizione finale dello stato attivo è decisa in base a quale algoritmo viene selezionato.

Durante l'inquadratura, l'asse orizzontale indica il numero di fotogramma. Questo per aiutarti nel processo di inquadratura in quanto puoi vedere come l'HFR cambia tra i fotogrammi.

Profilo relativo
Focus Relative Profile
Il profilo relativo è un grafico che visualizza i valori HFR relativi tracciati l'uno contro l'altro. Valori HFR più bassi corrispondono a forme più strette e viceversa. La curva rossa solida è il profilo del valore HFR corrente, mentre la curva verde punteggiata è per il valore HFR precedente. Infine, la curva di magenta denota il primo HFR misurato e viene visualizzata al completamento del processo di messa a fuoco automatica. Ciò consente di giudicare in che modo il processo di messa a fuoco automatica ha migliorato la qualità relativa della messa a fuoco.

guida
Ekos Guide Module
Introduzione
Il modulo guida Ekos consente la capacità di guida automatica utilizzando il potente guider integrato o, a scelta, la guida esterna tramite PHD2 o lin_guider. Utilizzando la guida interna, i fotogrammi CCD del guider vengono acquisiti e inviati a Ekos per l'analisi. A seconda delle deviazioni della stella guida dalla sua posizione di blocco, le correzioni degli impulsi guida vengono inviate al supporto tramite qualsiasi dispositivo che supporta le porte ST4. In alternativa, è possibile inviare direttamente le correzioni al supporto , se supportato dal driver di montaggio. La maggior parte delle opzioni gui nel modulo guida sono ben documentate, quindi basta posizionare il mouse su un elemento e una descrizione comando verrà popup con informazioni utili.

Per eseguire la guida, è necessario selezionare un CCD Guider in Ekos Profile Setup. L'apertura del telescopio e la lunghezza focale devono essere impostate nel driver del telescopio. Se il CCD Guider è collegato a un ambito guida separato, è necessario impostare anche la lunghezza focale e l'apertura dell'ambito guida. È possibile impostare questi valori nella scheda Opzioni del driver del telescopio o dal modulo Mount. La guida automatica è un processo in due fasi: calibrazione e guida.


Guiding introduction

During the two processes, you must set the following:

Guider: Select the Guider CCD.

Via: Selects which device receives the autoguiding correction pulses from Ekos. Usually, guider CCDs have an ST4 port. If you are using the guider's ST4 to autoguide your telescope, set the guider driver in the Via combo box. The guider CCD will receive the correction pulses from Ekos and will relay them to the mount via the ST4 port. Alternatively, some telescopes support pulse commands and you can select the telescope to be a receiver of the Ekos correction pulses.

Exposure: CCD Exposure in seconds.

Binning: CCD Binning.

Box: Size of the box enclosing the guide star. Select a suitable size that is neither too large or too small for the selected star.

Effects: Specify filter to be applied to the image to enhance it.

Dark Frames
Dark frames are immensely helpful in reducing noises in your guide frames. It is highly recommended to take dark frames before you begin and calibration or guiding procedure. To take a dark frame, check the Dark checkbox and then click Capture. For the first time this is performed, Ekos will ask you about your camera shutter. If your camera does not have a shutter, then Ekos will warn you anytime you take a dark frame to cover your camera/telescope before proceeding with the capture. On the other hand, if the camera already includes a shutter, then Ekos will directly proceed with taking the dark frame. All dark frames are automatically saved to Ekos Dark Frame Library. By default, the Dark Library keeps reusing dark frames for 30 days after which it will capture new dark frames. This value is configurable and can be adjusted in Ekos settings in the KStars settings dialog.

Ekos Dark frames library
It is recommended to take dark frames covering several binning and exposure values so that they may be reused transparently by Ekos whenever needed.

Calibration
Calibration Settings
In the calibration phase, you need to capture an image, select a guide star, and click Guide to begin the calibration process. If calibration was already completed successfully before, then the autoguiding process shall begin immediately, otherwise, it would start the calibration process. If Auto Star is checked, then you are only required to click Capture and Ekos will automatically select the best-fit guide star in the image and continues the calibration process automatically. If Auto Star is disabled, Ekos will try to automatically highlight the best guide star in the field. You need to confirm or change the selection before you can start the calibration process. The calibration options are:

Pulse: The duration of pulses in milliseconds to be sent to the mount. This value should be large enough to cause a noticeable movement in the guide star. If you increase the value and you do not notice any movement of the guide star, then this suggests possible mount issues such as jamming or connection issues via the ST4 cable.

Two axis: Check if you want the calibration process makes calibration in both RA & DEC. If unchecked, the calibration is only performed in RA.

Auto Star: If checked, Ekos will attempt to select the best guide star in the frame and begins the calibration process automatically.

The reticle position is the guide star position selected by you (or by the auto selection) in the captured guider image. You should select a star that is not close to the edge. If the image is not clear, you may select different Effects to enhance it.

Ekos begins the calibration process by sending pulses to move the mount in RA and DEC. If the calibration process fails due to short drift, try increasing the pulse duration. To clear calibration, click the trash bin icon next to the Guide button.

Warning
Calibration can fail for a variety of reasons. To improve the chances of success, try the tips below.

Better Polar Alignment: This is critical to the success of any astrophotography session. Perform a quick polar alignment with a polar scope (if available) or by using Ekos Polar Alignment procedure in the Align module.

Set binning to 2x2: Binning improves SNR and is often very important to the success of the calibration and guiding procedures.

Prefer to use ST4 cable between guide-camera and mount over using mount pulse commands.

Select different filter (e.g. High contrast) and see if that makes a difference to bring down the noise.

Smaller Square Size.

Take dark frames to reduce noise.

Play with DEC Proportional Gain or disable DEC control completely and see the difference.

Leave algorithm to the default value (Smart)

Guiding
Guide Settings
Once the calibration process is completed successfully, the guiding shall begin automatically hereafter. The guiding performance is displayed in the Drift Graphics region where Green reflects deviations in RA and Blue deviations in DEC. The colors of the RA/DE lines can be changed in KStars color scheme in KStars settings dialog. The vertical axis denotes the deviation in arcsecs from the guide star central position and the horizontal axis denotes time. You can hover over the line to get the exact deviation at this particular point in time. Furthermore, you can also zoom and drag/pan the graph to inspect a specific region of the graph.

Ekos can utilize multiple algorithms to determine the center of mass of the guide star. By default, the smart algorithm is suited best for most situation. The fast algorithm is based on HFR calculations. You can try switching guiding algorithms if Ekos cannot keep of the guide star within the guiding square properly.

La regione delle informazioni visualizza informazioni sul telescopio e sul FOV, oltre alle deviazioni dalla stella guida insieme agli impulsi di correzione inviati al supporto. Il valore RMS per ogni asse viene visualizzato insieme al valore RMS totale in arcsec. Il guider interno utilizza il controller PID per correggere il tracciamento del montaggio. Attualmente, gli unici guadagni proporzionali e integrali sono utilizzati all'interno dell'algoritmo, quindi regolarlo dovrebbe influenzare la lunghezza degli impulsi generati inviati al supporto in millisecondi.

Per attivare il dithering automatico tra i fotogrammi, assicuratevi di selezionare la casella di controllo Dithering. Per impostazione predefinita, Ekos deve dithering(cioè spostare) la casella guida fino a 3 pixel dopo ogni fotogramma acquisito in Ekos Capture Module. La durata e la direzione del movimento vengono randomizzate. Poiché le prestazioni di guida possono oscillare immediatamente dopo il dithering, è possibile impostare la durata di settle appropriata per attendere il completamento del dithering prima di riprendere il processo di acquisizione. In rari casi in cui il processo di dithering può bloccarsi in un ciclo infinito, impostare il timeout appropriato per interrompere il processo. Ma anche se il dithering non riesce, è possibile selezionare se questo errore deve terminare o meno il processo di guida automatica. Attivare o disattivare la guida automatica di interruzione in caso di mancata selezione del comportamento desiderato.

È supportato anche il dithering non guida. Ciò è utile quando non è disponibile alcuna telecamera guida o quando si eseguono esposizioni brevi. In questo caso, il supporto può essere comandato per dithering in una direzione casuale per un massimo dell'impulso specificato nell'opzione Impulso dithering non guida.

Ekos supporta più metodi di guida: Internal, PHD2 e LinGuider. È necessario selezionare il guider desiderato nel profilo dell'apparecchiatura Ekos:

Guida interna:utilizzare il guider interno Ekos. Questa è l'opzione predefinita e consigliata.

PHD2: Utilizzare PHD2 come guida esterna. Se selezionata, specificare l'host e la porta del DOTTORATO. Lasciare ai valori predefiniti se Ekos e PHD2 sono in esecuzione sulla stessa macchina.

LinGuider: utilizzare LinGuider come guida esterna. Se selezionata, specificare l'host e la porta di LinGuider. Lasciare ai valori predefiniti se Ekos e LinGuider sono in esecuzione sullo stesso computer.

Guiding Direction Control
Controllo della direzione guida
È possibile ottimizzare le prestazioni di guida nella sezione controllo. Il processo di guida automatica funziona come un controller PID quando si inviano comandi di correzione al supporto. Se necessario, è possibile modificare i guadagni proporzionale e integrale per migliorare le prestazioni di guida. Per impostazione predefinita, gli impulsi correttivi guidati vengono inviati a entrambi gli assi di montaggio in tutte le direzioni: positivo e negativo. È possibile ottimizzare il controllo selezionando quale asse deve ricevere impulsi guida correttivi e all'interno di ciascun asse, è possibile indicare quale direzione (Positivo) + o Negativo (-) riceve gli impulsi guida. Ad esempio, per l'asse declinazione, la direzione + è Nord e - è Sud.

Velocità guida
Ogni supporto ha una particolare velocità di guida in (x15"/sec) e di solito varia da 0,1x, a 1,0x con 0,5x come valore comune utilizzato da molti supporti. Il tasso di guida predefinito è 0,5x siderale, che equivale a un guadagno proporzionale di 133,33. Pertanto, impostare il valore della velocità guida su qualsiasi valore utilizzato dal supporto e Ekos deve visualizzare il valore di guadagno proporzionale consigliato che è possibile impostare nel campo di guadagno proporzionale in Parametri di controllo. L'impostazione di questo valore non modifica la velocità di guida del supporto! È necessario modificare la velocità di guida del montaggio tramite il driver INDI, se supportato, o tramite il controller della mano.

Grafica Drift
Drift Graphics
La grafica alla deriva è uno strumento molto utile per monitorare le prestazioni di guida. È un grafico 2D di deviazioni guida e correzioni. Per impostazione predefinita, vengono visualizzate solo le deviazioni guida in RA e DE. L'asse orizzontale è il tempo in secondi dall'avvio del processo di guida automatica mentre l'asse verticale traccia la deriva/deviazione guida in arcsec per ciascun asse. Le correzioni di guida (impulsi) possono anche essere tracciate nello stesso grafico ed è possibile abilitarle selezionando la casella di controllo Corr sotto ogni asse. Le correzioni vengono tracciate come aree ombreggiate sullo sfondo con lo stesso colore di quello dell'asse.

È possibile eseguire la panoramica e lo zoom del tracciato e, quando si passa il mouse sul grafico, viene visualizzata una descrizione comando contenente informazioni su questo specifico momento. Contiene la deriva guida e le eventuali correzioni apportate, oltre all'ora locale, questo evento è stato registrato. Un cursore verticale a destra dell'immagine può essere utilizzato per regolare l'altezza dell'asse Y secondario per le correzioni degli impulsi.

Il dispositivo di scorrimento Orizzontale Traccia nella parte inferiore può essere utilizzato per scorrere la cronologia delle guide. In alternativa, potete fare clic sulla casella di controllo Max per bloccare il grafico sul punto più recente in modo che la grafica alla deriva si svolaizza automaticamente. I pulsanti a destra del dispositivo di scorrimento vengono utilizzati per ridimensionare automaticamente i grafici, esportare i dati della guida in un file CSV, cancellare tutti i dati della guida e ridimensionare la destinazione nel drift plot. Inoltre, il grafico guida include un'etichetta per indicare quando si è verificato un dithering in modo che l'utente sappia che la guida non era male in quei punti.

I colori di ogni asse possono essere personalizzati nella combinazione di colori Impostazioni KStars .

Trama di deriva
Un grafico a dispersione toro-occhio può essere utilizzato per misurare l'accuratezza delle prestazioni di guida complessive. È composto da tre anelli concentrici di raggi variabili con l'anello verde centrale con un raggio predefinito di 2 anelli. L'ultimo valore RMS  viene tracciato come con il suo colore che riflette l'anello concentrico in cui rientra. Potete modificare il raggio del cerchio verde più interno regolando la precisione del tracciato di deriva.

Supporto PHD2
È possibile scegliere di selezionare l'applicazione PHD2 esterna per eseguire la guida anziché il guider integrato.

Ekos Guide PHD2 settings
Se è selezionato PHD2, i pulsanti Connetti e Disconnetti sono abilitati per consentire di stabilire una connessione con il server PHD2. È possibile controllare l'esposizione a PHD2 e le impostazioni della guida DEC. Quando si fa clicsu Guida , PHD2 deve eseguire tutte le azioni necessarie per avviare il processo di guida. PHD2 deve essere avviato e configurato prima di Ekos.

Dopo aver lanciato PHD2, selezionare l'apparecchiatura INDI e impostarne le opzioni. Da Ekos, connettersi a PHD2 facendo clic sul pulsante Connetti. All'avvio, Ekos tenterà di connettersi automaticamente a PHD2. Una volta stabilita la connessione, è possibile iniziare immediatamente la guida cliccando sul pulsante Guida. Phd2 esegue la calibrazione, se necessario. Se si selezione il dithering, a PHD2 deve essere comandato di dithering dati i pixel di offset indicati e una volta che la guida è stabile e stabile, il processo di acquisizione in Ekos riprenderà.

nota
Ekos salva i dati del registro guida CSV che possono essere utili per l'analisi delle prestazioni del supporto in . Questo registro è disponibile solo quando si utilizza il guider incorporato. ~/.local/share/kstars/guide_log.txt

allineare
Introduzione
Ekos Align Module
Il modulo di allineamento Ekos consente di ottenere goto altamente accurati con precisione inferiore ai secondi d'arco e può misurare e correggere gli errori di allineamento polare. Questo è possibile grazie al astrometry.net risolutore. Ekos inizia catturando un'immagine di un campo stellare, alimentando quell'immagine astrometry.net un risolutore e ottenendo le coordinate centrali (RA, DEC) dell'immagine. Il risolutore esegue essenzialmente un riconoscimento di pattern contro un catalogo di milioni di stelle. Una volta determinate le coordinate, è noto il vero puntamento del telescopio.

Spesso, c'è una discrepanza tra dove il telescopio pensa di guardare e dove sta veramente puntando. L'entità di questa discrepanza può variare da pochi minuti d'arco a un paio di gradi. Ekos può quindi correggere la discrepanza sincronizzandosi con le nuove coordinate o facendole salire sul bersaglio desiderato originariamente richiesto.

Inoltre, Ekos fornisce due strumenti per misurare e correggere gli errori di allineamento polare:

Polar Alignment Assistant Tool: A very easy tool to measure and correct polar errors. It takes three images near the celestial pole (Close to Polaris for Northern Hemisphere) and then calculates the offset between the mount axis and polar axis.

Legacy Polar Alignment Tool: If Polaris is not visible, this tool can be used to measure and correct polar alignment errors. It captures a couple of images near the meridian and east/west of the meridian. This will enable the user to adjust the mount until the misalignment is minimized.

At a minimum, you need a CCD/Webcam and a telescope that supports Slew & Sync commands. Most popular commercial telescope nowadays support such commands.

For the Ekos Alignment Module to work, you have an option of either utilizing the online astrometry.net solver, offline, or remote solver

Online Solver: The online solver requires no configuration, and depending on your Internet bandwidth, it might take a while to upload and solve the image.

Offline Solver: The offline solver can be faster and requires no Internet connection. In order to use the offline solver, you must install astrometry.net in addition to the necessary index files.

Remote Solver: The remote solver is an offline solver the resides on a different machine (for example, you can use Astrometry solver on StellarMate). Captured images are solved on the remote machine.

Get astrometry.net
If you are planning to use Offline astrometry then you need to download astrometry.net application.

Note
Astrometry.net is already shipped with StellarMate so there is no need to install it. Index files from 16 arcminutes and above (4206 to 4019) are included with StellarMate. For any additional index files, you need to install them as necessary. To use Astrometry in StellarMate from a remote Ekos on Linux®/Windows®/Mac® OS, make sure to select Remote option in Ekos Alignment Module. Furthermore, make sure that the Astrometry driver is selected in your equipment profile.

Ekos Remote Astrometry
finestre®
Per utilizzare astrometry.net in Windows, è necessario scaricare e installare il risolutore di Astrometry.net ANSVRLocal . L'ANSVR imita il astrometry.net server online sul computer locale; pertanto Internet non è necessario per alcuna query astrometria.

Dopo aver installato il server ANSVR e scaricato i file di indice appropriati per l'installazione, assicurarsi che il server ANSVR sia operativo e quindi passare alle opzioni di allineamento Ekos in cui è sufficiente modificare l'URL dell'API per utilizzare il server ANSVR come illustrato di seguito:

ANSVR Parameters
Nel modulo Ekos Align è necessario impostare il tipo di risolutore su Online in modo che utilizzi il server ANSVR locale per tutte le query astrometria. Quindi puoi usare il modulo di allineamento come faresti normalmente.

Ricorda come indicato sopra che StellarMate include già astrometry.net. Pertanto, se si desidera utilizzare StellarMate da remoto per risolvere le immagini, è sufficiente cambiare il tipo di risolutore in Remoto e assicurarsi che il profilo dell'apparecchiatura includa il driver Astrometry che può essere selezionato sotto l'elenco a discesa Ausiliario. Questo è applicabile a tutti i sistemi operativi e non solo a Windows®.

Mac® OS
Astrometry.net è già incluso in KStars per Mac® sistema operativo,quindi non è necessario installarlo.

Linux®
Astrometry.net è già incluso nella versione sanguinante KStars. Ma se astrometry non è installato, è possibile installarlo eseguendo il comando seguente in Ubuntu:

sudo apt-get installare astrometry.net

Scarica file di indice
Per i risolutori offline (e remoti), i file di indice sono necessari per il lavoro del risolutore. La raccolta completa di file di indice è enorme (oltre 30 GB), ma è necessario scaricare solo ciò che è necessario per la configurazione dell'apparecchiatura. I file di indice vengono ordinati in base all'intervallo FOV (Field-Of-View) di cui si tratta. Esistono due metodi per recuperare i file di indice necessari: il nuovo supporto per il download nel modulo Align e il vecchio modo manuale.

Download automatico
Astrometry.net Indexes Download
Automatic download is only available for Ekos users on Linux® & Mac® OS. For Windows® users, please download ANSVR solver.

To access the download page, click the Options button in the Align module and then select Astrometry Index Files tab. The page displays the current FOV of your current setup and below it a list of available and installed index files. Three icons are used to designate the importance of index files given your current setup as follows:

 Required

 Recommended

 Optional

You must download all the required files, and if you have plenty of hard drive space left, you can also download the recommended indexes. If an index file is installed, the checkmark shall be checked, otherwise check it to download the relevant index file. Please only download one file at a time, especially for larger files. You might be prompted to enter the administrator password (default in StellarMate is smate) to install the files. Once you installed all the required files, you can begin using the offline astrometry.net solver immediately.

Manual Download
You need to download and install the necessary index files suitable for your telescope+CCD field of view (FOV). You need to install index files covering 100% to 10% of your FOV. For example, if your FOV is 60 arcminutes, you need to install index files covering skymarks from 6 arcminutes (10%) to 60 arcminutes (100%). There are many online tools to calculate FOVs, such as Starizona Field of View Calculator.

Table 5.1. Index Files

Nome file indice	FOV (arcminutes)	Pacchetto Debian
indice-4219.fits	1400 - 2000	astrometria-dati-4208-4219
indice-4218.fits	1000 - 1400
indice-4217.fits	680 - 1000
indice-4216.fits	480 - 680
indice-4215.fits	340 - 480
indice-4214.fits	240 - 340
indice-4213.fits	170 - 240
indice-4212.fits	120 - 170
index-4211.fits	85 - 120
index-4210.fits	60 - 85
index-4209.fits	42 - 60
indice-4208.fits	30 - 42
indice-4207-*.fits	22 - 30	astrometria-dati-4207
index-4206-*.fits	16 - 22	Astrometria-dati-4206
index-4205-*.fits	11 - 16	Astrometry-data-4205
index-4204-*.fits	8 - 11	astrometria-dati-4204
index-4203-*.fits	5.6 - 8.0	Astrometria-dati-4203
index-4202-*.fits	4.0 - 5.6	astrometria-dati-4202
index-4201-*.fits	2.8 - 4.0	Astrometria-dati-4201-1 astrometria-dati-4201-2 astrometria-dati-4201-3 astrometria-dati-4201-4
index-4200-*.fits	2.0 - 2.8	Astrometry-data-4200-1 astrometry-data-4200-2 astrometry-data-4200-3 astrometry-data-4200-4

I pacchetti Debian sono adatti per qualsiasi distribuzione a base di Debian (Ubuntu, Mint, ecc.). Se hai scaricato i pacchetti Debian sopra per la tua gamma FOV, puoi installarli dal tuo gestore di pacchetti preferito o tramite il comando seguente:

sudo dpkg -i astrometria-dati-*.deb

D'altra parte, se hai scaricato direttamente i file di indice FITS, copiali nella directory. /usr/share/astrometry

nota
Si consiglia di utilizzare un download manager come tale DownThemAll! per Firefox per scaricare i pacchetti Debian poiché il download manager integrato dei browser potrebbe avere problemi con il download di pacchetti di grandi dimensioni.

Come usare?
Ekos Align Module offre molteplici funzioni per aiutarti a ottenere GOTO accurati. Inizia con il tuo supporto in posizione domestica con il tubo del telescopio che guarda direttamente il polo celeste. Per gli utenti dell'emisfero settentrionale, puntare il telescopio il più vicino possibile a Polaris. Non è necessario eseguire allineamenti a 2 o 3 stelle, ma può essere utile per alcuni tipi di montaggio. Assicurati che la fotocamera sia focalizzata e che le stelle siano risolte.

Cattura e risolvi: catturaun'immagine e determina quale regione nel cielo sta esattamente guardando il telescopio. I risultati dell'astrometria includono le coordinate equatoriali (RA e DEC) del centro dell'immagine acquisita oltre alla scala dei pixel e alla rotazione del campo. A seconda delle impostazioni dell'azione risolutore, i risultati possono essere utilizzati per sincronizzare il montaggio o la sincronizzazione e quindi slew nella posizione di destinazione. Si supponga, ad esempio, di aver inclinato il supporto su Vega, quindi di aver utilizzato Capture & Solve. Se la posizione effettiva del telescopio è diversa da Vega, verrà prima sincronizzata con la coordinata risolta e quindi Ekos comanderà al supporto di inclinare verso Vega. Al termine della slew, il modulo Allineamento ripeterà nuovamente il processo di acquisizione e risoluzione fino a quando l'errore tra la posizione segnalata e quella effettiva scende al di sotto delle soglie di precisione (30 secondi d'arco per impostazione predefinita).

Carica e inclina: caricaun file FITS o JPEG, risolvilo e quindi inclinalo.

Assistente allineamento polare:un semplice strumento per aiutare nell'allineamento polare dei monti equatoriali tedeschi.

Strumento allineamento polare legacy: misura l'errore di allineamento polare quando non è disponibile una vista del polo celeste(ad esempio Polaris per l'emisfero settentrionale).

avvertimento
Non risolvere mai un'immagine al polo celeste o vicino a quello vicino (a meno che non venga utilizzato lo strumento Assistente allineamento polare Ekos). Allontanare almeno 20 gradi dal polo celeste prima di risolvere la prima immagine. Risolvere molto vicino ai poli peggiorerà il tuo supporto puntando, quindi evitalo.

Impostazioni allineamento
Astrometry.net Settings
Prima di iniziare il processo di allineamento, selezionare il CCD e il telescopio desiderati. È possibile esplorare le astrometry.net che vengono passate al risolutore astrometry.net ogni volta che viene acquisita un'immagine:

CCD:selezionare CCD da cui acquisire

Esposizione: Durata dell'esposizione in secondi

Precisione: Differenza accettabile tra la coordinata del telescopio segnalata e la coordinata effettivamente risolta.

Bin X: Impostare l'inzonatura orizzontale del CCD

Bin Y: Impostare l'binning verticale del CCD

Ambito:impostare il telescopio attivo nel caso in cui si abbiano diversi ambiti primario e guida. Fov viene ri-calcolato quando si seleziona un telescopio diverso.

Opzioni:opzioni passate al risolutore astrometry.net ricerca. Fare clic  sul pulsante modifica per esplorare le opzioni in dettaglio.

Risolutore:selezionare il tipo di risolutore (Online, Offline, Remote). Il risolutore remoto è disponibile solo quando ci si connette a un dispositivo remoto.

Per impostazione predefinita, il risolutore cercherà in tutto il cielo per determinare le coordinate dell'immagine acquisita. Questo può richiedere molto tempo; Pertanto, per velocizzare il risolutore, è possibile limitarlo alla ricerca solo all'interno di un'area specificata nel cielo designato dalle opzioni RA, DECe Radius sopra.

opzioni Astrometry.net di Astrometry.net
Opzioni per risolutori offline e online.

Astrometry.net Options
La maggior parte delle opzioni sono sufficienti per impostazione predefinita. Se è stato astrometry.net in una posizione non standard, è possibile modificare i percorsi in base alle esigenze.

WCS: World-Coordinate-System è un sistema per incorporare le informazioni sulle coordinate equatoriali all'interno dell'immagine. Pertanto, quando si visualizza l'immagine, è possibile passarla al passaggio del mouse e visualizzare la coordinata per ogni pixel. Puoi anche fare clic in qualsiasi punto dell'immagine e comandare al telescopio di uccise lì. Si consiglia vivamente di mantenere questa opzione.

Verbose: Se il risolutore non riesce ripetutamente a risolvere, selezionare questa opzione per abilitare l'output dettagliato del risolutore per aiutarti a identificare eventuali problemi.

Sovrapposizione:sovrapporre le immagini acquisite alla mappa del cielo di KStars.

Carica JPG:quando usi i astrometry.net online, carica tutte le immagini sono JPEG per risparmiare larghezza di banda poiché le immagini FITS possono essere grandi.

Opzioni risolutore
Ekos seleziona e aggiorna le opzioni ottimali per impostazione predefinita per accelerare le prestazioni del risolutore. È possibile scegliere di modificare le opzioni passate al risolutore nel caso in cui le opzioni predefinite non siano sufficienti.

Solver Settings
Acquisizione e soluzione
Utilizzando il modulo di allineamento Ekos, l'allineamento del supporto utilizzando l'allineamento a 1, 2 o 3 stelle del controller non è strettamente necessario, anche se per alcuni supporti si consiglia di eseguire un allineamento approssimativo a 1 o 2 stelle prima di utilizzare il modulo di allineamento Ekos. Se si utilizza EQMod, è possibile iniziare immediatamente a utilizzare il modulo di allineamento Ekos. Un flusso di lavoro tipico per l'allineamento GOTO prevede i passaggi seguenti:

Impostare il supporto nella posizione iniziale (di solito l'NCP per i supporti equatoriali)

Selezionare Slew to Target nell'azione Risolutore.

Inclinati verso una stella brillante nelle vicinanze.

Al termine dell'inclinazione, fare clic su Acquisisci e risolvi.

Se il risolutore ha successo, Ekos si sincronizzerà e poi si sfilerà verso la stella. I risultati sono visualizzati nella scheda Risultati soluzione insieme a un diagramma del bullseye che mostra l'offset delle coordinate del telescopio riportate ( cioè dove il telescopio pensa di guardare) rispetto alla sua posizione effettiva nel cielo determinata dal risolutore.

Ogni volta che il risolutore viene eseguito e restituisce risultati positivi, Ekos può essere eseguito sulle seguenti azioni:

Sincronizzazione:sincronizza le coordinate del telescopio con le coordinate della soluzione.

Slew to Target: Sincronizza le coordinate del telescopio con le coordinate della soluzione e quindi si inclina verso il bersaglio.

Niente:basta risolvere l'immagine e visualizzare le coordinate della soluzione.

Allineamento polare
Assistente allineamento polare
Quando si imposta un monte equatoriale tedesco (GEM) per l'imaging, un aspetto critico dell'acquisizione di immagini a lunga esposizione è garantire un corretto allineamento polare. Un supporto GEM ha due assi: asse ascensione destra (RA) e asse declinazione (DE). Idealmente, l'asse RA dovrebbe essere allineato con l'asse polare della sfera celeste. Il compito di una cavalcatura è quello di tracciare il moto della stella intorno al cielo, dal momento in cui si innalzano all'orizzonte orientale, attraverso la mediana e verso ovest fino a quando non si impostano.


Assistente allineamento polare

Nell'imaging a lunga esposizione, una fotocamera è attaccata al telescopio dove il sensore di immagine cattura i fotoni in arrivo da una particolare area del cielo. I fotoni dell'incidente devono colpire lo stesso sito fotografico più e più volte se vogliamo raccogliere un'immagine chiara e nitida. Naturalmente, i fotoni reali non si comportano in questo modo: ottica, atmosfera, vedendo la qualità tutti i fotoni dispersi e rifratti in un modo o nell'altro. Inoltre, i fotoni non arrivano uniformemente ma seguono una distribuzione di Poisson. Per sorgenti di tipo puntino come le stelle, una funzione di diffusione del punto descrive come i fotoni sono distribuiti spazialmente tra i pixel. Tuttavia, l'idea generale che vogliamo mantenere i fotoni sorgente colpiscono gli stessi pixel. Altrimenti, potremmo finire con un'immagine afflitta da vari artefatti del sentiero.

Polar Alignment
Poiché i supporti non sono perfetti, non possono tenere traccia perfettamente dell'oggetto mentre transita attraverso il cielo. Questo può derivare da molti fattori, uno dei quali è il disallineamento dell'asse di ascensione destra del monte rispetto all'asse del polo celeste. L'allineamento polare rimuove una delle maggiori fonti di errori di tracciamento nel supporto, ma altre fonti di errore giocano ancora un fattore. Se allineati correttamente, alcuni supporti possono tenere traccia di un oggetto per alcuni minuti con l'unica deviazione di 1-2 arcsec RMS.

Tuttavia, a meno che tu non abbia un supporto superiore della linea, probabilmente dovresti usare un autoguider per mantenere la stessa stella bloccata nella stessa posizione nel tempo. Nonostante tutto questo, se l'asse del supporto non è correttamente allineato con il polo celeste, anche un supporto meccanicamente perfetto perderebbe il tracciamento con il tempo. Gli errori di tracciamento sono proporzionali all'entità del disallineamento. È quindi molto importante che l'imaging a lunga esposizione si allinei al polare per ridurre eventuali errori residui mentre si estende attraverso il cielo.

Prima di iniziare il processo, puntare il supporto il più vicino possibile al polo celeste. Se vivi nell'emisfero settentrionale, puntalo il più vicino possibile a Polaris.

Lo strumento funziona catturando e risolvendo tre immagini. Dopo averne acquisita, il supporto ruota di una quantità fissa e un'altra immagine viene catturata e risolta.

Polar Alignment Assistant
Dopo la prima acquisizione, è possibile ruotare il supporto di una quantità specifica (30 gradi predefiniti) ovest o est. Dopo aver selezionato la grandezza e la direzione, fare clic su Avanti per continuare e il supporto verrà ruotato. Una volta completata la rotazione, ti verrà chiesto di acquisire un'altra acquisizione, a meno che non sia stata controllata la modalità automatica. In modalità automatizzata, il resto del processo continuerà con le stesse impostazioni e direzione fino a quando non verranno acquisite un totale di tre immagini.

Poiché il vero RA/DE del supporto è risolto dall'astrometria, possiamo costruire un cerchio unico dai tre centri trovati nelle soluzioni di astrometria. Il centro del cerchio è dove il supporto ruota attorno (asse RA) e idealmente, questo punto dovrebbe coincidere con il polo celeste. Tuttavia, se c'è un disallineamento, allora Ekos disegna un vettore di correzione. Questo vettore di correzione può essere posizionato in qualsiasi punto dell'immagine. Successivamente, aggiornare l'alimentazione della fotocamera e apportare correzioni alle manopole Altitude e Azimuth del supporto fino a quando la stella non si trova nei capelli incrociati designati. Per semplificare le correzioni, espandere la visualizzazione facendo clic sul pulsante Schermo intero 

Polar Alignment Result
Se sei lontano da StellarMate o PC, puoi usare il tablet per monitorare il feed della fotocamera mentre apporti correzioni. Utilizza il visualizzatore VNC basato sul Web di StellarMate o utilizza qualsiasi client VNC sul tuo tablet per accedere a StellarMate. Se Ekos è in esecuzione sul PC, è possibile utilizzare applicazioni come TeamViewer per ottenere gli stessi risultati. Di seguito è riportato un video che illustra come utilizzare lo strumento Assistente allineamento polare.


Allineamento polare

Flusso di lavoro di allineamento polare legacy
Utilizzando la modalità Allineamento polare, Ekos può misurare e correggere gli errori di allineamento polare. Per misurare l'errore di Azimuth, puntare il supporto verso una stella vicino al meridiano. Se vivi nell'emisfero settentrionale, intimenterai il monte verso il meridiano meridionale. Fare clic su Misura errore Az per avviare il processo. Ekos cercherà di misurare la deriva tra due immagini e calcola l'errore di conseguenza. Puoi chiedere a Ekos di correggere l'errore di Azimuth facendo clic sul pulsante Correggi errore Az. Ekos si inclina in una nuova posizione e ti chiede di regolare le manopole azimut del supporto fino a quando la stella non è al centro del Campo visivo. È possibile utilizzare la funzione Framing del modulo di messa a fuoco per dare un'occhiata all'immagine durante le regolazioni.

Analogamente, per misurare l'errore altitudine, fare clic sul pulsante Misura alt errore. È necessario puntare il supporto verso est o ovest e impostare di conseguenza la casella combinata Direzione altitudine. Ekos prenderà due immagini e calcolerà l'errore. Puoi chiedere a Ekos di correggere l'errore di altitudine facendo clic sul pulsante Correggi alt error. Come per la correzione di Azimuth, Ekos si inclina in una nuova posizione e ti chiede di regolare le manopole di altitudine del supporto fino a quando la stella non è al centro del FOV.

Dopo aver fatto una correzione, si consiglia di misurare nuovamente gli errori Azimuth e Altitude e misurare la differenza. Potrebbe essere necessario eseguire la correzione più di una volta per ottenere risultati ottimali.

Prima di avviare lo strumento Allineamento polare, è necessario completare il flusso di lavoro GOTO sopra per almeno un punto nel cielo. Una volta allineata la cavalcatura, procedere con quanto segue (supponendo che si viva nell'emisfero settentrionale):

Inclina verso una stella brillante (4a magnitudine o inferiore) vicino al meridiano meridionale (Azimuth 180). Assicurarsi che sia selezionata l'opzione Slew to Target. Cattura e risolvi. La stella dovrebbe essere esattamente centrata nel tuo campo visivo CCD.

Passare alla modalità Polar Alignment. Fare clic su Misura errore Az. Ti chiederà di sfilzare verso una stella al meridiano meridionale che abbiamo già fatto. Fare clic su Continua. Ekos eseguirà ora il calcolo dell'errore.

Se tutto va bene, l'errore viene visualizzato nelle caselle di output. Per correggere l'errore, fare clic su Correggi errore Az. Ekos ora si inclina in un punto diverso del cielo e ti verrà richiesto di regolare SOLO le manopole azimut del supporto per centrare la stella nel campo visivo. Il modo più conveniente per monitorare il campo stellare è andare al modulo Messa a fuoco e fare clic su Avvia inquadratura. Se l'errore dell'azimut è grande, la stella potrebbe non essere visibile nel campo visivo CCD, e quindi è necessario effettuare regolazioni cieche (o semplicemente guardare attraverso il finderscope) fino a quando la stella non entra nel FOV CCD.

Inizia le regolazioni dell'azimut fino a quando la stella luminosa a cui hai deviato inizialmente è il più vicino possibile al centro.

Interrompere l'inquadratura nel modulo Messa a fuoco.

Ripetere l'errore misura Az per assicurarsi di correggere effettivamente l'errore. Potrebbe essere necessario eseguito più di una volta per assicurarsi che i risultati siano validi.

Passare alla modalità GOTO.

Ora inclinati verso una stella brillante all'orizzonte orientale o occidentale, preferibilmente sopra i 20 gradi di altitudine. Deve essere il più vicino possibile ai punti cardinali orientali (90 azimut) o occidentali (270).

Al termine della sfilza, acquisire e risolvere. La stella dovrebbe essere al centro del CCD FOV ora.

Passare alla modalità Polar Alignment.

Fare clic su Misura alt errore. Ti chiederà di inclinare verso una stella all'orizzonte orientale (Azimut 90) o occidentale (Azimut 270) che abbiamo già fatto. Fare clic su Continua. Ekos eseguirà ora il calcolo dell'errore.

Per correggere l'errore, fare clic su Correggi errore alt. Ekos ora si inclina in un punto diverso del cielo e ti verrà richiesto di regolare SOLO le manopole di altitudine del supporto per centrare la stella nel campo visivo. Inizia a inquadrare come fatto prima nel modulo di messa a fuoco per aiutarti con la centratura.

Al termine della centramento, interrompere l'inquadratura.

Ripetere l'errore Measure Alt per assicurarsi di correggere effettivamente l'errore. Potrebbe essere necessario eseguito più di una volta per assicurarsi che i risultati siano validi.

L'allineamento polare è ora completo!

avvertimento
Il supporto potrebbe inclinarsi in una posizione pericolosa e potresti rischiare di colpire il treppiede e / o altre attrezzature. Monitorare attentamente il movimento del supporto. Utilizzare a proprio rischio e pericolo.

Pianificazione
Ekos Scheduler Module
Introduzione
Ekos Scheduler è un arsenale indispensabile nella costruzione del tuo osservatorio robotico. Un osservatorio robotico è un osservatorio composto da diversi sottosistemi orchestrati insieme per raggiungere una serie di obiettivi scientifici senza l'intervento umano. È l'unico modulo Ekos che non richiede l'avvio di Ekos in quanto viene utilizzato per avviare e fermare Ekos. È progettato per essere semplice e intuitivo. Tuttavia, l'utilità di pianificazione dovrebbe essere utilizzata solo dopo aver padroneggiato Ekos e conosce tutte le stranezze della tua attrezzatura. Poiché il processo completo è automatizzato, tra cui messa a fuoco, guida e lancio del meridiano, tutte le apparecchiature devono essere accuratamente utilizzate con Ekos e tutti i loro parametri e impostazioni regolati per ottenere il miglior risultato.

Con Ekos, l'utente può utilizzare la potente coda di sequenza per l'immagine di batch di immagini per una particolare destinazione. Nelle semplici configurazioni, l'utente dovrebbe mettere a fuoco il CCD, allineare il montaggio, inquadrare la destinazione e iniziare a guidare prima di avviare il processo di acquisizione. Per gli ambienti di osservatorio più complessi, di solito esistono procedure personalizzate predefinite da eseguire per preparare l'osservatorio per l'imaging e un altro set di procedure all'arresto. L'utente può pianificare di immagini di uno o più obiettivi durante la notte e si aspetta che i dati siano pronti entro la mattina. In KStars, strumenti come Observation Planner e What's up Tonight aiutano l'utente a selezionare i candidati per l'imaging. Dopo aver selezionato i candidati desiderati, l'utente può aggiungerli all'elenco Ekos Scheduler per la valutazione. L'utente può anche aggiungere le destinazioni direttamente nell'utilità di pianificazione Ekos o selezionare un file FITS di un'immagine precedente.

Impostazioni
Ekos Scheduler fornisce una semplice interfaccia per aiutare l'utente a impostare le condizioni e i vincoli necessari per un processo di osservazione. Ogni lavoro di osservazione è composto dai seguenti:

Nome e coordinate di destinazione:selezionare la destinazione dalla finestra di dialogo Trova o Aggiungila da Pianificazione osservazioni. È inoltre possibile immettere un nome personalizzato.

File FITS facoltativo:se viene specificato un file FITS, il risolutore di astrometria risolve il file e utilizza il RA/DEC centrale come coordinate di destinazione.

File di sequenza: il file di sequenza viene costruito nel modulo di acquisizione Ekos. Contiene il numero di immagini da acquisire, filtri, impostazioni di temperatura, prefissi, directory di download, ecc.

Priorità:impostare la priorità del lavoro nell'intervallo da 1 a 20, dove 1 designa la priorità più alta e 20 la priorità più bassa. La priorità viene applicata nel calcolo dello spessore utilizzato per selezionare la destinazione successiva all'immagine.

Profilo:selezionare il profilo dell'apparecchiatura da utilizzare all'avvio di Ekos. Se Ekos e INDI sono già stati avviati e online, questa selezione viene ignorata.

Passaggi:l'utente seleziona quali moduli Ekos devono essere utilizzati nel flusso di lavoro di esecuzione del processo di osservazione.

Condizioni di avvio:condizioni che devono essere soddisfatte prima dell'avvio del processo di osservazione. Attualmente, l'utente può scegliere di iniziare il prima possibile, al più presto, o quando la destinazione è vicino o passata al culmine o in un momento specifico.

Vincoli:i vincoli sono condizioni che devono essere soddisfatte in ogni momento durante il processo di esecuzione del processo di osservazione. Questi includono altitudine minima del bersaglio, separazione minima della luna, osservazione del crepuscolo e monitoraggio meteorologico.

Condizioni di completamento:Condizioni che innescano il completamento del lavoro di osservazione. La selezione predefinita è semplicemente contrassegnare il processo di osservazione come completato una volta completato il processo di sequenza. Condizioni aggiuntive consentono all'utente di ripetere il processo di sequenza indefinitamente o fino a un momento specifico.

È necessario selezionare la destinazione e la sequenza prima di poter aggiungere un processo all'Utilità di pianificazione. All'avvio dell'utilità di pianificazione, vengono valutate tutte le operazioni in base alle condizioni e ai vincoli specificati e si tenta di selezionare il processo migliore da eseguire. La selezione del lavoro dipende da un semplice algoritmo euristico che segna ogni lavoro date le condizioni e i vincoli, ognuno dei quali è ponderato di conseguenza. Se due destinazioni hanno condizioni e vincoli identici, in genere viene selezionata per l'esecuzione la destinazione con priorità più alta seguita da una destinazione ad altitudine più elevata. Se al momento attuale non sono disponibili candidati, l'utilità di pianificazione passa alla modalità sospensione e si riattiva quando il processo successivo è pronto per l'esecuzione.

Scheduler + Planner
La descrizione precedente affronta solo la fase di acquisizione dei dati del flusso di lavoro dell'osservatorio. La procedura complessiva tipicamente utilizzata in un osservatorio può essere riassunta in tre fasi primarie:

avvio

Acquisizione dati (inclusa la pre-elaborazione e l'archiviazione)

chiusura

Procedura di avvio
La procedura di avvio è unica per ogni osservatorio, ma può includere:

Accensione dell'alimentazione delle apparecchiature

Esecuzione di controlli di sicurezza/sanità mentale

Controllo delle condizioni meteorologiche

Spegnere la luce

Controllo ventola/luce

Cupola di unparking

Montaggio non parcheggiato

and so on.

Ekos Scheduler avvia la procedura di avvio solo una volta chiuso il tempo di avvio per il primo processo di osservazione (il lead time predefinito è di 5 minuti prima del tempo di avvio). Una volta completata correttamente la procedura di avvio, l'utilità di pianificazione sceglie la destinazione del processo di osservazione e avvia il processo di sequenza. Se viene specificato uno script di avvio, deve essere eseguito per primo.

Acquisizione dati
A seconda della selezione dell'utente, il flusso di lavoro tipico procede come segue:

Inclinare il supporto al bersaglio. Se è stato specificato un file FITS, questi vengono prima risoluti e vengono inclinati in base alle coordinate del file.

Destinazione messa a fuoco automatica. Il processo di messa a fuoco automatica seleziona automaticamente la stella migliore nel fotogramma ed esegue l'algoritmo di messa a fuoco automatica contro di esso.

Eseguire la risoluzione delle lastre, sincronizzare il montaggio e slew alle coordinate di destinazione.

Eseguire la messa a fuoco post-allineamento poiché il telaio potrebbe aver spostato durante il processo di risoluzione delle lastre.

Eseguire la calibrazione e avviare la guida automatica: il processo di calibrazione seleziona automaticamente la migliore stella guida, esegue la calibrazione e avvia il processo di guida automatica.

Caricare il file di sequenza nel modulo Capture e avviare il processo di imaging.

chiusura
Una volta completato correttamente il processo di osservazione, l'utilità di pianificazione seleziona la destinazione successiva. Se l'ora pianificata successiva della destinazione non è ancora dovuta, il supporto viene parcheggiato fino a quando la destinazione non è pronta. Inoltre, se la destinazione pianificata successiva non è dovuta a un limite di tempo configurabile dall'utente, l'utilità di pianificazione esegue un arresto automatico per mantenere le risorse ed esegue nuovamente la procedura di avvio quando la destinazione è dovuta.

Se si verifica un errore irreversibile, l'osservatorio avvia la procedura di arresto. Se è disponibile uno script di arresto, verrà eseguito per ultimo.

Il video seguente illustra una versione precedente dell'utilità di pianificazione, ma i principi di base si applicano ancora oggi:


Ekos Scheduler

Monitoraggio meteorologico
Un'altra caratteristica critica di qualsiasi osservatorio robotico telecomandato è il monitoraggio meteorologico. Per gli aggiornamenti meteo, Ekos si affida al driver meteorologico INDI selezionato per monitorare continuamente le condizioni meteorologiche. Per semplicità, le condizioni meteorologiche possono essere riassunte in tre stati:

Ok:le condizioni meteorologiche sono chiare e ottimali per l'imaging.

Attenzione: Le condizioni meteorologiche non sono chiare, la visualizzazione è scadente o parzialmente ostruita e non adatta per l'imaging. Qualsiasi ulteriore processo di imaging viene sospeso fino a quando il tempo non migliora. L'avviso di stato meteo non rappresenta un pericolo per le apparecchiature dell'osservatorio, quindi l'osservatorio è mantenuto operativo. È possibile configurare il comportamento esatto da assumere in Stato avviso.

Allerta- Le condizioni meteorologiche sono dannose per la sicurezza e lo spegnimento dell'osservatorio devono essere avviate al più presto.

Script di avvio e arresto
A causa dell'unicità di ogni osservatorio, Ekos consente all'utente di selezionare script di avvio e arresto. Gli script si occupano di tutte le procedure necessarie che devono avvenire nelle fasi di avvio e arresto. All'avvio, Ekos esegue gli script di avvio e procede al resto della procedura di avvio (unpark dome/unpark mount) solo se lo script viene completato correttamente. Al contrario, la procedura di arresto inizia con il parcheggio del supporto e della cupola prima di eseguire lo script di arresto come procedura finale.

Gli script di avvio e arresto possono essere scritti in qualsiasi lingua che può essere eseguita nel computer locale. Deve restituire 0 per segnalare l'esito positivo, qualsiasi altro valore esistente è considerato un indicatore di errore. L'output standard dello script è anche diretto alla finestra del logger Ekos. Di seguito è riportato uno script di avvio demo di esempio in Python:

#!/usr/bin/env python
# -*- coding: utf-8 -*-

import os
import time
import sys

print "Turning on observatory equipment..."
sys.stdout.flush()

time.sleep(5)

print "Checking safety switches..."
sys.stdout.flush()

time.sleep(5)

print "All systems are GO"
sys.stdout.flush()

exit(0)
        
Gli script di avvio e arresto devono essere eseguibili affinché Ekos possa richiamarli (ad esempio, utilizzare chmod +x startup_script.py per contrassegnare lo script come eseguibile). Ekos Scheduler consente un funzionamento robotico davvero semplice senza la necessità di alcun intervento umano in nessuna fase del processo. Senza presenza umana, diventa sempre più fondamentale riprendersi con grazia dai fallimenti in qualsiasi fase della corsa di osservazione. Utilizzando le notifiche ™ plasma,l'utente può configurare allarmi acustici e notifiche e-mail per i vari eventi nell'utilità di pianificazione.

Mago mosaico
Mosaic Wizard
Le immagini a campi super ampi simili a hubble di galassie e nebulose sono davvero impressionanti, e mentre ci vogliono grandi abilità per ottenere tali immagini ed elaborarle; molti nomi degni di nota nel campo dell'astrofotografia impiegano equipaggiamento che non è molto diverso dal tuo o dal mio. Sottolineo molto perché alcuni hanno effettivamente attrezzature impressionanti e osservatori dedicati del valore di decine di migliaia di dollari. Tuttavia, molti dilettanti possono ottenere immagini stellari a campo largo combinando immagini più piccole in un unico grande mosaico.

Siamo spesso limitati dalla nostra fotocamera + telescopio Field of View (FOV). Aumentando fov per mezzo di un riduttore focale o di un tubo più corto, otteniamo una copertura del cielo più ampia a scapito della risoluzione spaziale. Allo stesso tempo, molti bersagli wide-field attraenti si estendono su più PV attraverso il cielo. Senza alcuna modifica al tuo equipaggiamento astrofiografico, è possibile creare un'immagine super mosaico cucita insieme da diverse immagini più piccole. Ci sono due passaggi principali per realizzare un'immagine super mosaico:

Acquisisci più immagini che si estendono sulla destinazione con una certa sovrapposizione tra le immagini. La sovrapposizione è necessaria per consentire al software di elaborazione di allineare e unire le sotto-immagini.

Elabora le immagini e cucile in un'immagine super mosaico.

Il secondo passaggio è gestito da applicazioni di elaborazione delle immagini come PixInsight, tra gli altri, e non sarà l'argomento di discussione qui. Il primo passo può essere compiuto in Ekos Scheduler dove crea un mosaico adatto alla tua attrezzatura e in conformità con il campo visivo desiderato. Non solo Ekos crea i pannelli a mosaico per il tuo obiettivo, ma costruisce anche i corrispondenti lavori di osservatorio necessari per catturare tutte le immagini. Ciò facilita notevolmente la logistica dell'acquisizione di molte immagini con filtri e fotogrammi di calibrazione diversi su un'ampia area del cielo.

Prima di avviare Mosaic Job Creator in Ekos Scheduler, è necessario selezionare una destinazione e un file di sequenza. Il file di sequenza contiene tutte le informazioni necessarie per acquisire un'immagine, tra cui tempo di esposizione, filtri, impostazione della temperatura, ecc. Avvia il Creatore di lavoro mosaico facendo clic sull'icona accanto al pulsante Trova nel modulo Ekos.

Al primo utilizzo, è necessario inserire le impostazioni dell'apparecchiatura, inclusa la lunghezza focale del telescopio, oltre alla larghezza, all'altezza e alle dimensioni dei pixel della fotocamera. Infine, è necessario inserire la rotazione della fotocamera rispetto a nord o l'angolo di posizione. Se non si conosce questo valore, avviare Ekos e inclinare verso la destinazione desiderata, quindi utilizzare il modulo Allinea per risolvere l'immagine e ottenere l'angolo di posizione.

Immettere quindi il numero desiderato di pannelli orizzontali e verticali ( ad esempio 2x2, 3x3 e così via)e quindi fare clic su Aggiorna. Il FOV di destinazione deve essere calcolato in base al numero di pannelli e al FOV della videocamera e deve essere visualizzata la sovrapposizione del mosaico. Per impostazione predefinita, la percentuale di sovrapposizione tra le immagini è del 5%, ma è possibile modificare questo valore in base al valore desiderato. È inoltre possibile spostare la struttura a mosaico completa per ottimizzare la posizione dei pannelli a mosaico. Una volta soddisfatti, fate clic su Crea processi (Create Jobs) ed Ekos deve creare un processo di osservazione e un file di sequenza personalizzato corrispondente per ciascun pannello. Tutti i processi verranno salvati in un file Ekos Scheduler List () che è possibile caricare su qualsiasi notte di osservazione adatta e verrà scelto da dove si è partiti. Prima di avviare Mosaic Job Creator, verificare che tutte le condizioni, i vincoli e le procedure di avvio/arresto del processo di osservazione siano in base alle proprie esigenze, poiché queste impostazioni devono essere copiate in tutti i processi generati dallo strumento Mosaic. .esl

Con Ekos Scheduler, l'imaging multi-notte è notevolmente facilitato e creare super mosaici non è mai stato così facile.

analizzare
Ekos Analyze Module
Introduzione
Il modulo Analyze registra e visualizza ciò che è accaduto in una sessione di imaging. Cioè, non ne controlla nessuno se la tua immagine, ma piuttosto rivede ciò che è accaduto. Le sessioni vengono archiviate in una cartella, una cartella sorella della cartella di registrazione principale. I file scritti lì possono essere caricati nella scheda Analizza da visualizzare. Analyze può anche visualizzare i dati della sessione di imaging corrente. analyze.analyze

Ci sono due grafici principali, Timeline e Stats. Sono coordinati: visualizzano sempre lo stesso intervallo di tempo della sessione Ekos, anche se l'asse x della timeline mostra i secondi trascorsi dall'inizio del registro e Statistiche mostra l'ora di clock. L'asse x può essere ingrandito e ridotto con il pulsante +/-, larotellina del mouse, così come con le scorciatoie da tastiera standard ( ad esempio zoom-in == CTRL+ +) L'asse x può essere panoramicato con la barra di scorrimento e con i tasti freccia sinistra e destra. È possibile visualizzare la sessione di imaging corrente o rivedere le sessioni precedenti caricando i file utilizzando l'elenco a discesa Input. Selezionando Larghezza intera vengono visualizzati tutti i dati e Più recente vengono visualizzati i dati più recenti (è possibile controllare la larghezza ingrandindo). .analyze

linea temporale
Timeline mostra i principali processi Ekos e quando erano attivi. Ad esempio, la linea Di acquisizione mostra quando sono state scattate le immagini (sezioni verdi) e quando l'imaging è stato interrotto (sezioni rosse). Facendo clic su una sezione verde vengono fornite informazioni su quell'immagine, e facendo doppio clic su una viene mostrata l'immagine scattata quindi in un fitsviewer, se disponibile.

nota
Se sono state spostate le immagini acquisite, è possibile impostare una directory alternativa nel menu di input su una directory che è la base di parte del percorso del file originale.

Facendo clic su un segmento Messa a fuoco vengono visualizzate le informazioni sulla sessione di messa a fuoco e vengono visualizzate le misurazioni posizione rispetto a HFR di tale sessione. Facendo clic su un segmento Guida mostra un grafico di deriva da quella sessione (se sta guidando) e le statistiche RMS della sessione. Altre sequenze temporali mostrano le informazioni sullo stato quando si fa clic su di esso.

statistica
Una varietà di statistiche può essere visualizzata nel grafico Statistiche. Ce ne sono troppi per tutti da mostrarne in modo leggibile, quindi seleziona tra loro con le caselle di controllo. Un modo ragionevole per iniziare potrebbe essere quello di utilizzare rms, snr (utilizzando il guider interno con SEP Multistar) e hfr (se si dispone di HFR di calcolo automatico nelle opzioni FITS). Sperimenta con gli altri. L'asse mostrato (0-5) è appropriato solo per errori ra/dec, drift, rms, impulsi e hfr. Questi possono essere scalati ad asse y (goffamente) usando la rotellina del mouse, ma gli altri grafici non possono essere ridimensionati. Per reimpostare lo zoom dell'asse y, fate clic con il pulsante destro del mouse sul plottaggio Statistiche. Facendo clic sul grafico vengono visualizzati i valori delle statistiche visualizzate. Questo grafico viene ingrandito e panoramica orizzontalmente in coordinamento con la sequenza temporale.

Esercitazioni su Ekos
spettatore
StellarMate viene fornito con un server VNC. Ciò consente di accedere all'intero desktop StellarMate da remoto. Per connettersi a VNC, è possibile utilizzare un client VNC desktop / mobile o semplicemente tramite qualsiasi browser.

L'indirizzo VNC è: http://stellarmate_hostname:6080/vnc.html

Dove stellarmate_hostname è il nome host effettivo (o indirizzo IP) dell'unità e 6080 è la porta. Se non si conosce il nome host dell'unità, è possibile trovare il nome host nell'app StellarMate.

È possibile utilizzare Real VNC che è disponibile su tutte le piattaforme per accedere a stellarmate.

Una volta che accedi a StellarMate, puoi usarlo come qualsiasi computer a tutti gli effetti. Il nome utente predefinito è stellarmate e la password predefinita è smate.
