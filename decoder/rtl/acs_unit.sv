module acs_unit #(
    parameter int OUTPUT_WIDTH   = 2,       // Rata 1/n
    parameter int CONSTRAINT_LEN = 4,       // K
    parameter int PM_WIDTH       = 16,      // Latimea registrului de cost
    // Polinoamele pentru a calcula ce output asteptam
    parameter logic [CONSTRAINT_LEN-1:0] POLYS [OUTPUT_WIDTH] = '{4'b0101, 4'b1010}
)(
    // Inputuri
    input  logic [PM_WIDTH-1:0] old_path_metrics [1 << (CONSTRAINT_LEN-1)], // Costurile vechi
    input  logic [$clog2(OUTPUT_WIDTH+1)-1:0] branch_metrics [1 << OUTPUT_WIDTH], // Distantele de la BMU
    
    // Outputuri
    output logic [PM_WIDTH-1:0] new_path_metrics [1 << (CONSTRAINT_LEN-1)], // Costurile noi
    output logic [(1 << (CONSTRAINT_LEN-1))-1:0] decisions // Bitii de decizie pentru Traceback
);

    localparam MEM_DEPTH  = CONSTRAINT_LEN - 1;
    localparam NUM_STATES = 1 << MEM_DEPTH;

    // --- Functie: Calculeaza ce iesire trebuia sa dea encoderul ---
    function logic [OUTPUT_WIDTH-1:0] get_expected_output(input logic [MEM_DEPTH-1:0] state, input logic input_bit);
        logic [CONSTRAINT_LEN-1:0] data_window;
        logic [OUTPUT_WIDTH-1:0] result;
        
        data_window = {input_bit, state}; // Reconstituim fereastra {i_n, ... i_n-3}
        
        for (int i = 0; i < OUTPUT_WIDTH; i++) begin
            result[i] = ^(data_window & POLYS[i]);
        end
        return result;
    endfunction

    // --- Generarea Hardware-ului pentru fiecare stare ---
    genvar i;
    generate
        for (i = 0; i < NUM_STATES; i++) begin : acs_loop // eticheta pt blocurile generate
            
            // parintii starii 'i' sunt {i fără MSB, 0} si {i fără MSB, 1}.
            logic [MEM_DEPTH-1:0] parent0_idx;
            logic [MEM_DEPTH-1:0] parent1_idx;
            
            // Bitul de intrare care a cauzat tranzitia este chiar MSB-ul starii curente
            logic input_bit; 
            
            assign parent0_idx = {i[MEM_DEPTH-2:0], 1'b0};
            assign parent1_idx = {i[MEM_DEPTH-2:0], 1'b1};
            assign input_bit   = i[MEM_DEPTH-1]; // ia fix pe cel care a intrat, MSB-ul

            // Variabile temporare pentru logica combinationala
            logic [OUTPUT_WIDTH-1:0] expected_out0, expected_out1;
            logic [PM_WIDTH-1:0] cost_from_p0, cost_from_p1;
            logic [PM_WIDTH-1:0] branch_cost0, branch_cost1;

            always_comb begin
                expected_out0 = get_expected_output(parent0_idx, input_bit);
                branch_cost0  = branch_metrics[expected_out0];
                
                expected_out1 = get_expected_output(parent1_idx, input_bit);
                branch_cost1  = branch_metrics[expected_out1];

                // ADD: Adunam costul istoric + costul tranzitiei
                cost_from_p0 = old_path_metrics[parent0_idx] + branch_cost0;
                cost_from_p1 = old_path_metrics[parent1_idx] + branch_cost1;

                // COMPARE & SELECT (Cu regula <= pentru egalitate)
                if (cost_from_p0 <= cost_from_p1) begin
                    new_path_metrics[i] = cost_from_p0;
                    decisions[i]        = 0; // Am ales parintele cu LSB=0
                end else begin
                    new_path_metrics[i] = cost_from_p1;
                    decisions[i]        = 1; // Am ales parintele cu LSB=1
                end
            end
        end
    endgenerate

endmodule