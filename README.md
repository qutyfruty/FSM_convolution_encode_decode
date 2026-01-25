# FSM Convolutional Coding (Encoder & Viterbi Decoder)

Acest proiect implementează un sistem de comunicații digitale în SystemVerilog capabil să **corecteze erorile**. Proiectul conține un Codificator (care protejează datele) și un Decodor (care repară datele stricate de zgomot).

**Fluxul de date:**
> Date Intrare (1)  →  Encoder (11)  →  Canal Zgomotos (01)  →  Decoder Viterbi  →  Date Corectate (1)

## 📂 Structura Proiectului
* **`encoder/`** - Codul sursă pentru Codificator (Transmisie).
* **`decoder/`** - Codul sursă pentru Decodor (Recepție).
* **`encoder/tb/` si `decoder/tb/`** - Testbench-uri pentru verificare.

## Cum funcționează?

### 1. Codarea (Convolutional Encoding)
Encoderul funcționează ca un FSM (Finite State Machine). Pentru fiecare bit de intrare, generează OUTPUT_WIDTH biți de ieșire (Rata 1/numarul de biti de iesire) pe baza unor polinoame matematice. Această redundanță permite corecția ulterioară.

### 2. Decodarea (Viterbi Decoding)
Decodorul primește mesajul alterat și reconstruiește șirul original în 3 pași:
1.  **BMU (Branch Metric):** Calculează diferențele dintre ce a primit și ce trebuia să primească.
2.  **ACS (Add-Compare-Select):** Găsește calea cea mai probabilă (cu costul minim) prin stările FSM-ului.
3.  **Traceback:** Parcurge memoria înapoi pentru a reconstitui biții originali.
