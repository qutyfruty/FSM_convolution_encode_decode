`timescale 1ns/1ps

module testbench_decoder;

    logic clk;
    logic rst_n;
    logic [1:0] rx_bits;   
    logic decoded_bit;     
    logic valid_out;       
    localparam TRACEBACK_LEN = 32;

    viterbi_decoder #(
        .OUTPUT_WIDTH(2),
        .CONSTRAINT_LEN(4),
        .TRACEBACK_LEN(TRACEBACK_LEN)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .rx_bits(rx_bits),
        .decoded_bit(decoded_bit),
        .valid_out(valid_out)
    );

    // --- Generare Ceas ---
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        rst_n = 0;
        rx_bits = 2'b00; 
        #20;            
        rst_n = 1;     
        @(negedge clk); 

        // --- TRANSMITEM SECVENTA: 1, 1, 0, 1 ---
        // Stare Encoder: 000
        
        // Input '1' (Stare devine 100) -> Output 10
        rx_bits = 2'b10; 
        @(negedge clk);

        // Input '1' (Stare devine 110) -> Output 11
        // !!! EROARE: Trimitem 01 in loc de 11
        rx_bits = 2'b01; 
        @(negedge clk);

        // Input '0' (Stare devine 011) -> Output 11
        rx_bits = 2'b11; 
        @(negedge clk);

        // Input '1' (Stare devine 101) -> Output 01
        rx_bits = 2'b01;
        @(negedge clk);

        // --- FLUSH CORECT ---
        // Encoderul a ramas in starea 101. Trebuie sa il ducem in 000
        
        // Input 0 -> Starea devine 010
        // Output-ul matematic pentru tranzitia asta este 00
        rx_bits = 2'b00; 
        @(negedge clk);

        // Suntem in 010. Input 0 -> Starea devine 001
        // Output-ul matematic este 10
        rx_bits = 2'b10; 
        @(negedge clk);

        // Flush Pas 3: Suntem in 001. Input 0 -> Starea devine 000
        // Output-ul matematic este 01
        rx_bits = 2'b01; 
        @(negedge clk);

        // Flush Pas 4: Suntem in 000. Input 0 -> Starea ramane 000
        // Acum putem trimite 00 in continuu
        rx_bits = 2'b00; 
        
        repeat(40) begin 
            @(negedge clk);
        end
        $stop;
    end

    // --- Monitorizare ---
    always @(posedge clk) begin
        if (valid_out) begin
            $display("Out: %b", decoded_bit);
        end
    end

endmodule