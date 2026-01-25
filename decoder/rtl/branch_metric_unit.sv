module branch_metric_unit #(
    parameter int OUTPUT_WIDTH = 2 // Rata 1/n
)(
    input  logic [OUTPUT_WIDTH-1:0] rx_bits,
    // Calculam dinamic cati biti ne trebuie pentru a stoca distanta maxima $clog2
    output logic [$clog2(OUTPUT_WIDTH + 1)-1:0] metrics [1 << OUTPUT_WIDTH]
);

    localparam NUM_POSSIBILITIES = 1 << OUTPUT_WIDTH;

    always_comb begin
        for (int k = 0; k < NUM_POSSIBILITIES; k++) begin
            logic [OUTPUT_WIDTH-1:0] pattern;
            logic [OUTPUT_WIDTH-1:0] diff;
            
            // Folosim 'integer' pentru suma temporara
            integer distance; 
            
            // k e pe mai multi biti, fiind int si luam doar cati avem nevoie
            pattern = k[OUTPUT_WIDTH-1:0];
            
            // 1. XOR
            diff = rx_bits ^ pattern;
            
            // 2. Numarare biti (Hamming)
            distance = 0;
            for (int i = 0; i < OUTPUT_WIDTH; i++) begin
                distance = distance + diff[i];
            end
            
            // 3. Atribuire
            metrics[k] = distance; 
        end
    end

endmodule