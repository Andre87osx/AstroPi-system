# Pubblicare release AstroPi

Questa guida descrive come rendere disponibile una nuova versione dal menu
`AstroPi System`.

## Concetti chiave

Per AstroPi sono coinvolti tre elementi distinti:

| Elemento | Dove si crea | Cosa fa |
| --- | --- | --- |
| Commit | Git | Contiene il codice della versione. |
| Tag `vX.Y.Z` | Git | Blocca un commit preciso che l'installer puo scaricare. |
| GitHub Release | GitHub | Rende il tag visibile come aggiornamento stabile o Beta. |

Un tag da solo non compare nel menu Beta: deve avere una GitHub Release
pubblicata e marcata come **pre-release**.

- **Aggiornamento stabile**: usa la GitHub Release piu recente che non sia una
  pre-release.
- **Aggiornamento Beta**: cerca una GitHub Release con l'opzione
  **Set as a pre-release** attiva e scarica il tag associato.

L'installer scarica l'archivio del tag, ad esempio
`v1.8.4.tar.gz`. Percio il tag deve indicare esattamente il commit che si vuole
installare.

## Prima di pubblicare

Eseguire questi comandi dalla radice del repository:

```powershell
git fetch upstream --tags
git switch main
git pull --ff-only upstream main
git status --short
```

`git status --short` non deve produrre output. Prima del tag, allineare tutte
le etichette di versione pubbliche: `include/functions.sh` (`minorRelease` e
`KStars_v`), `kstars-astropi/CMakeLists.txt` (`KSTARS_BUILD_RELEASE`) e gli
esempi correnti in questa guida. Non aggiornare le voci storiche del changelog.
Verificare quindi che le modifiche siano state testate e che il commit sia gia
su `upstream/main`.

Questo repository usa `upstream` per pubblicare. Non usare `origin` per il
push: il suo URL di push e disabilitato.

## Creare una Beta

Usare una Beta per distribuire una versione in prova senza renderla
l'aggiornamento stabile.

1. Scegliere una versione nuova, per esempio `1.8.4`.
2. Creare e pubblicare il tag sul commit corrente:

   ```powershell
    git tag -a v1.8.4 -m "AstroPi System v1.8.4"
    git push upstream v1.8.4
    git ls-remote --tags upstream refs/tags/v1.8.4 refs/tags/v1.8.4^{}
   ```

3. Aprire la pagina delle release:
   `https://github.com/Andre87osx/AstroPi-system/releases/new`
4. In **Choose a tag**, selezionare `v1.8.4`. Non creare un tag diverso dalla
   pagina GitHub.
5. Impostare il titolo, ad esempio `AstroPi System v1.8.4 Beta`.
6. Scrivere note di rilascio concise: novita, correzioni, rischi noti e
   istruzioni speciali per l'aggiornamento.
7. Attivare **Set as a pre-release** e non attivare **Set as a draft**.
8. Selezionare **Publish release**.

Controllo finale: nella pagina Releases la versione deve mostrare il badge
**Pre-release**. Dal menu AstroPi, **Check for Beta update** deve proporre quel
tag.

## Pubblicare una stabile

Usare una release stabile solo dopo aver verificato la Beta.

### Promuovere la stessa Beta

Non serve creare un nuovo tag se la Beta e gia il commit definitivo.

1. Aprire la release `vX.Y.Z` su GitHub e selezionare **Edit**.
2. Disattivare **Set as a pre-release**.
3. Aggiornare il titolo e le note, se necessario.
4. Selezionare **Update release**.

La stessa release diventera l'ultima stabile e sara usata da **Check for
System update**.

### Pubblicare una nuova stabile

Se dopo la Beta sono state fatte correzioni, creare un nuovo tag con i comandi
del capitolo precedente, quindi creare la GitHub Release senza attivare
**Set as a pre-release**. Esempio: dopo `v1.8.4` Beta, una correzione puo essere
pubblicata come `v1.8.5` stabile.

## Verifica prima e dopo

Prima di creare una nuova versione, verificare che il tag non esista gia:

```powershell
git ls-remote --tags upstream refs/tags/v1.8.4 refs/tags/v1.8.4^{}
```

Dopo il push, confrontare il tag con il commit locale:

```powershell
git rev-parse HEAD
git rev-parse v1.8.4
git diff --quiet v1.8.4 HEAD
```

I primi due hash devono coincidere e l'ultimo comando deve terminare senza
segnalare differenze. In questo caso l'installer scarichera esattamente il
contenuto verificato in locale.

## Se qualcosa e sbagliato

- **Tag pubblicato sul commit errato**: non spostare il tag e non riutilizzare
  il numero. Creare un nuovo commit corretto e un nuovo tag, per esempio
  `v1.8.4`.
- **Tag corretto ma non compare nel menu Beta**: creare o modificare la GitHub
  Release del tag e attivare **Set as a pre-release**.
- **Una Beta deve diventare stabile**: modificare la Release esistente e
  disattivare il flag pre-release; non serve un nuovo tag.
- **Il menu Beta mostra una versione inattesa**: controllare che la GitHub
  Release desiderata sia pubblicata, non sia una bozza e sia marcata come
  pre-release. Evitare di lasciare piu Beta concorrenti pubblicate.

## Checklist

- [ ] La versione del progetto e aggiornata.
- [ ] Tutte le modifiche previste sono committate e testate.
- [ ] `main` e gia pubblicato su `upstream`.
- [ ] Il tag `vX.Y.Z` punta al commit verificato.
- [ ] E stato eseguito `git push upstream vX.Y.Z`.
- [ ] Il tag e stato verificato con `git ls-remote --tags upstream ...`.
- [ ] La GitHub Release e pubblicata, non Draft.
- [ ] Per Beta: **Set as a pre-release** e attivo.
- [ ] Per stabile: **Set as a pre-release** e disattivo.