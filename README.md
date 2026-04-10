# FSM Convolutional Coding (Encoder & Viterbi Decoder)

---

## Română

### 📖 Descriere
Acest proiect implementează un sistem de comunicații digitale în **SystemVerilog** capabil să **corecteze erorile de transmisie**. Sistemul utilizează codarea convoluțională pentru a adăuga redundanță datelor și algoritmul Viterbi pentru a reconstrui mesajul original, chiar și în prezența zgomotului pe canal.

**Fluxul de date:**
> Date Intrare (1)  →  Encoder (11)  →  Canal Zgomotos (01)  →  Decoder Viterbi  →  Date Corectate (1)

### 📂 Structura Proiectului
* `encoder/`: Implementarea codificatorului (Finite State Machine).
* `decoder/`: Implementarea decodorului (BMU, ACS, Traceback).
* `encoder/tb/` si `decoder/tb/` - Testbench-uri pentru verificare.

### ⚙️ Detalii Tehnice
1. **Codarea (Convolutional Encoding):** Funcționează ca un FSM. Pentru fiecare bit de intrare, generează biți de paritate pe baza unor polinoame generatoare, creând redundanța necesară corecției.
2. **Decodarea (Viterbi Decoding):** Reconstruiește șirul original în 3 pași critici:
    * **BMU (Branch Metric Unit):** Calculează distanța Hamming între datele primite și tranzițiile posibile.
    * **ACS (Add-Compare-Select):** Determină calea supraviețuitoare cu costul minim prin trellis-ul de stări.
    * **Traceback:** Parcurge memoria înapoi pentru a extrage biții originali decodați.

---

## English

### 📖 Description
This project implements a digital communication system in **SystemVerilog** designed for **Error Correction Code (ECC)**. It features a Convolutional Encoder to protect data and a Viterbi Decoder to repair bits corrupted by channel noise.

**Data Flow:**
> Input Data (1)  →  Encoder (11)  →  Noisy Channel (01)  →  Viterbi Decoder  →  Corrected Data (1)

### 📂 Project Structure
* **`encoder/`**: Source code for the Convolutional Encoder (FSM-based).
* **`decoder/`**: Source code for the Viterbi Decoder modules.
* **`encoder/tb/`**, **`decoder/tb/`**: Testbenches for verifying system integrity and error correction capability.

### ⚙️ Technical Details
1. **Convolutional Encoding:** Implemented as a Finite State Machine (FSM). For each input bit, it generates output parity bits based on mathematical polynomials, providing the redundancy needed for error recovery.
2. **Viterbi Decoding:** Reconstructs the original sequence using a three-stage pipeline:
    * **BMU (Branch Metric Unit):** Calculates differences (Hamming distance) between received signals and expected states.
    * **ACS (Add-Compare-Select):** Computes the most likely path (minimum cost) through the FSM state trellis.
    * **Traceback Unit:** Traverses the stored paths in reverse to reconstruct the original bitstream.

---

### 🚀 Simulation
1. Navigate to the `decoder/tb/` folder.
2. Run simulation in **Vivado** or **ModelSim**.
3. Observe how the decoder successfully recovers the original data even when bits are flipped in the noisy channel.
