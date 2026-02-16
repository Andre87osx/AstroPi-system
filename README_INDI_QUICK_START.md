# 🚀 INDI Dependencies Fix - Quick Start

## Il Problema
Quando compili INDI su Debian Buster, fallisce con errori di dipendenze mancanti.

## La Soluzione in 3 Step

### Step 1: Prepara il Sistema (una volta sola)
```bash
./bin/AstroPi.sh
# Seleziona: "System Pre Update"
```
Questo aggiunge i repository Raspberry Pi e configura APT per Buster archiviato.

### Step 2: Pre-risolvi le Dipendenze (consigliato)
```bash
sudo bash bin/quick-fix-indi.sh
```
Questo installa tutti i pacchetti critici e risolve dipendenze rotte.

**Tempo**: 5-10 minuti

### Step 3: Compila INDI
```bash
./bin/AstroPi.sh
# Seleziona: "Check INDI"
```
Ora ha fallback automatico e gestione intelligente delle dipendenze.

---

## ✅ Verifica Rapida

Prima di compilare, controlla se tutto è pronto:

```bash
bash bin/check-indi-deps.sh
```

Output:
- ✅ Verde = OK, pacchetto installato
- ❌ Rosso = Critico, mancante (blocca compilazione)
- ⚠️ Giallo = Opzionale, compilazione continua comunque

---

## 🆘 Se Continua a Fallire

### Opzione 1: Esecuzione Manuale Completa
```bash
sudo bash bin/fix-indi-dependencies.sh
```
(Versione estesa di quick-fix, più dettagliata)

### Opzione 2: Controlla i Log
```bash
cat ~/indi-deps-install.log
```
Leggi gli errori specifici e ricerca la soluzione.

### Opzione 3: Fix Manuale Passo-Passo
```bash
# Aggiorna
sudo apt-get update -y

# Risolvi dipendenze rotte
sudo apt-get install -f -y

# Pulisci
sudo apt-get autoremove -y
sudo apt-get autoclean -y

# Reinstalla pacchetti critici
sudo apt-get install -y --no-install-recommends \
    build-essential cmake make git \
    libev-dev libgsl-dev libgsl0-dev

# Riprova INDI
./bin/AstroPi.sh → Check INDI
```

---

## 📚 Documentazione

- **Guida Completa**: [`INDI_DEPENDENCIES_FIX.md`](INDI_DEPENDENCIES_FIX.md)
- **Dettagli Tecnici**: [`FIX_INDI_DEPENDENCIES_v1_7_1.md`](FIX_INDI_DEPENDENCIES_v1_7_1.md)
- **Changelog Completo**: [`CHANGELOG_INDI_FIX.md`](CHANGELOG_INDI_FIX.md)

---

## 🔧 Cosa è Stato Fatto

✅ Aggiunto repository Raspberry Pi per pacchetti ARM  
✅ Aggiunto fallback automatico per dipendenze rotte  
✅ Separazione tra pacchetti critici e opzionali  
✅ Log dettagliato per debugging  
✅ 3 script helper per pre-risoluzione  
✅ Documentazione completa  

---

## ⏱️ Tempi Stimati

| Operazione | Tempo |
|-----------|-------|
| System Pre Update | 5-15 minuti |
| quick-fix-indi.sh | 5-10 minuti |
| Check INDI | 30-60 minuti (a seconda della velocità di compilazione) |
| check-indi-deps.sh | < 1 minuto |

**Totale Prima Compilazione**: ~45-85 minuti (inclusa compilazione)

---

## 💡 Pro Tips

1. **Primo Tentativo**: Esegui sempre `System Pre Update` primo
2. **Consigliato**: Esegui `quick-fix-indi.sh` prima di `Check INDI`
3. **Verifica**: Usa `check-indi-deps.sh` se hai dubbi
4. **Background**: Puoi usare `screen` o `tmux` per eseguire in background:
   ```bash
   screen -S indi_build
   # (Esegui ./bin/AstroPi.sh → Check INDI)
   # Ctrl+A, D per staccare
   screen -r indi_build  # Per riagganciarsi
   ```

---

## 🎓 FAQ

**D: Posso saltare il System Pre Update?**  
R: No, è necessario per aggiungere i repository Raspberry Pi.

**D: Devo sempre eseguire quick-fix-indi.sh?**  
R: Consigliato la prima volta. Dopo puoi provare direttamente Check INDI.

**D: Cosa significa "pacchetto opzionale"?**  
R: Se manca, compilazione continua con funzionalità limitate.

**D: Cosa significa "pacchetto critico"?**  
R: Se manca, compilazione fallisce immediatamente.

**D: Quanto tempo ci vuole?**  
R: Prima volta ~50-90 minuti (inclusa compilazione INDI che è lunga).

**D: Posso eseguire in background?**  
R: Si, usa `screen`, `tmux`, o `nohup`.

---

## 📞 Problemi?

1. Controlla i log: `cat ~/indi-deps-install.log`
2. Esegui il check: `bash bin/check-indi-deps.sh`
3. Leggi la guida completa: [`INDI_DEPENDENCIES_FIX.md`](INDI_DEPENDENCIES_FIX.md)
4. Crea issue: https://github.com/Andre87osx/AstroPi-system/issues

---

**Buona Compilazione! 🚀**

*Modifica implementata il 18 Gennaio 2026 per risolvere problemi di dipendenze su Debian Buster.*
