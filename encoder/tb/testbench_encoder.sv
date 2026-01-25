`timescale 1ns / 1ps
// Testbench pentru verificare parametri default
module testbench;
    logic clk;
    logic rst_n;
    logic in_bit;
    logic [1:0] out_bits;

    // Instantiere
    convolutional_encoder dut(
        .clk(clk),
        .rst_n(rst_n),
        .in_bit(in_bit),
        .out_bits(out_bits)
    );

    // Generare ceas
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        // Resetare initiala
        rst_n = 0; 
        in_bit = 0;
        
        @(posedge clk); 
        #1;         
        rst_n = 1;  

        // --- 1 -> 0 -> 1 -> 0 ---
        @(posedge clk); 
        #1; 
        in_bit = 1;

        @(posedge clk); 
        #1; 
        in_bit = 0;

        @(posedge clk); 
        #1; 
        in_bit = 1;

        @(posedge clk); 
        #1; 
        in_bit = 0;

        #20;
        $finish;
    end

    always @(negedge clk) begin
        if (rst_n) begin
            $display("In=%b | State=%b | Out: %b%b", 
                     in_bit, dut.state, out_bits[0], out_bits[1]);
        end
    end

endmodule