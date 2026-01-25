module traceback_unit #(
    parameter int CONSTRAINT_LEN = 4,   // K
    parameter int TRACEBACK_LEN  = 32   // adancimea memoriei (cat privim in trecut)
)(
    input  logic clk,
    input  logic rst_n,
    
    // Deciziile luate de ACS 
    input  logic [(1 << (CONSTRAINT_LEN-1))-1:0] decisions,
    
    // Costul minim curent 
    input  logic [CONSTRAINT_LEN-2:0] best_state_idx, 

    output logic decoded_bit, // Bitul reconstituit
    output logic valid_out    // Semnal ca memoria s-a umplut
);

    localparam MEM_DEPTH  = CONSTRAINT_LEN - 1;
    localparam NUM_STATES = 1 << MEM_DEPTH;

    // Matricea de istorie: 8 randuri (stari) x 32 coloane (timp)
    logic [TRACEBACK_LEN-1:0] history [NUM_STATES];
    logic [TRACEBACK_LEN-1:0] next_history [NUM_STATES];
    
    // Contor pentru a sti cand e valid output-ul
    logic [$clog2(TRACEBACK_LEN):0] counter;

    genvar i;
    generate
        for (i = 0; i < NUM_STATES; i++) begin : tbu_loop
            logic [MEM_DEPTH-1:0] parent0_idx;
            logic [MEM_DEPTH-1:0] parent1_idx;
            assign parent0_idx = {i[MEM_DEPTH-2:0], 1'b0};
            assign parent1_idx = {i[MEM_DEPTH-2:0], 1'b1};
            
            // Bitul care intra in istorie este chiar MSB-ul starii curente 'i'
            logic decision_bit_value;
            assign decision_bit_value = i[MEM_DEPTH-1];

            always_comb begin
                // Daca ACS a decis ca am venit din Parent 0:
                //    Copiem toata istoria lui Parent 0 + adaugam bitul curent.
                // Daca ACS a decis ca am venit din Parent 1:
                //    Copiem toata istoria lui Parent 1 + adaugam bitul curent.
                
                if (decisions[i] == 0) begin
                    next_history[i] = {history[parent0_idx][TRACEBACK_LEN-2:0], decision_bit_value};
                end else begin
                    next_history[i] = {history[parent1_idx][TRACEBACK_LEN-2:0], decision_bit_value};
                end
            end
        end
    endgenerate

    always_ff @(posedge clk) begin
        if (!rst_n) begin
            counter <= 0;
            for (int k = 0; k < NUM_STATES; k++) begin
                history[k] <= 0;
            end
        end else begin
            // Actualizam istoria
            history <= next_history;
            
            // Incrementam counterul pana la maxim
            if (counter < TRACEBACK_LEN)
                counter <= counter + 1;
        end
    end

    // --- OUTPUT ---
    // Output-ul este bitul cel mai vechi (MSB din istorie) 
    // al starii care are costul minim curent (best_state_idx).
    
    assign decoded_bit = history[best_state_idx][TRACEBACK_LEN-1];
    assign valid_out   = (counter == TRACEBACK_LEN);

endmodule