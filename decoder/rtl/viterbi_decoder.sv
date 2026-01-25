module viterbi_decoder #(
    parameter int OUTPUT_WIDTH   = 2,       // Rata 1/n
    parameter int CONSTRAINT_LEN = 4,       // K
    parameter int TRACEBACK_LEN  = 32,      // Adancimea memoriei
    parameter int PM_WIDTH       = 16,      // Latimea registrului de cost
    // Polinoamele (identice cu encoder)
    parameter logic [CONSTRAINT_LEN-1:0] POLYS [OUTPUT_WIDTH] = '{4'b0101, 4'b1010}
)(
    input  logic clk,
    input  logic rst_n,
    input  logic [OUTPUT_WIDTH-1:0] rx_bits, // Simbolul receptionat
    output logic decoded_bit,                // Bitul corectat
    output logic valid_out                   // Semnal valid
);

    // --- Constante si Semnale Interne ---
    localparam NUM_STATES = 1 << (CONSTRAINT_LEN - 1);
    
    // Fire intre module
    logic [$clog2(OUTPUT_WIDTH+1)-1:0] branch_metrics [1 << OUTPUT_WIDTH];
    
    // Registrii de cost (Path Metrics)
    logic [PM_WIDTH-1:0] current_path_metrics [NUM_STATES]; // Costul acum
    logic [PM_WIDTH-1:0] next_path_metrics    [NUM_STATES]; // Costul calculat de ACS pt ceasul viitor
    
    // Deciziile de la ACS catre TBU
    logic [NUM_STATES-1:0] decisions;

    // Indexul starii cu costul cel mai mic (pentru TBU)
    logic [CONSTRAINT_LEN-2:0] best_state_idx;

    // --- Instantiere BMU (Branch Metric Unit) ---
    branch_metric_unit #(
        .OUTPUT_WIDTH(OUTPUT_WIDTH)
    ) bmu_inst (
        .rx_bits(rx_bits),
        .metrics(branch_metrics)
    );

    // --- Instantiere ACS (Add-Compare-Select) ---
    acs_unit #(
        .OUTPUT_WIDTH(OUTPUT_WIDTH),
        .CONSTRAINT_LEN(CONSTRAINT_LEN),
        .PM_WIDTH(PM_WIDTH),
        .POLYS(POLYS)
    ) acs_inst (
        // ACS primeste costurile curente si distantele de la BMU
        .old_path_metrics(current_path_metrics),
        .branch_metrics(branch_metrics),
        // ACS scoate noile costuri si deciziile luate
        .new_path_metrics(next_path_metrics),
        .decisions(decisions)
    );

    // --- Actualizarea Costurilor (Registrii) ---
    always_ff @(posedge clk) begin
        if (!rst_n) begin
            // INITIALIZARE CRITICA:
            // Starea 0 pleaca de la cost 0.
            // Toate celelalte stari pleaca de la cost MAXIM (infinit).
            // Asta forteaza decodorul sa presupuna ca encoderul a inceput in 000.
            for (int i = 0; i < NUM_STATES; i++) begin
                if (i == 0)
                    current_path_metrics[i] <= 0;
                else
                    current_path_metrics[i] <= '1; // '1 umple cu 1 (Maxim)
            end
        end else begin
            // La fiecare ceas, costurile viitoare devin costuri curente
            current_path_metrics <= next_path_metrics;
        end
    end

    // --- Gasirea Costului Minim ---
    // Trebuie sa ii spunem TBU-ului care stare a castigat cursa pana acum
    always_comb begin
        logic [PM_WIDTH-1:0] min_val;
        min_val = '1;   // Pornim cu maxim
        best_state_idx = 0;
        
        for (int i = 0; i < NUM_STATES; i++) begin
            if (current_path_metrics[i] < min_val) begin
                min_val = current_path_metrics[i];
                best_state_idx = i[CONSTRAINT_LEN-2:0];
            end
        end
    end

    // --- Instantiere TBU (Traceback Unit) ---
    traceback_unit #(
        .CONSTRAINT_LEN(CONSTRAINT_LEN),
        .TRACEBACK_LEN(TRACEBACK_LEN)
    ) tbu_inst (
        .clk(clk),
        .rst_n(rst_n),
        .decisions(decisions),
        .best_state_idx(best_state_idx), // Ii dam starea castigatoare
        .decoded_bit(decoded_bit),
        .valid_out(valid_out)
    );

endmodule