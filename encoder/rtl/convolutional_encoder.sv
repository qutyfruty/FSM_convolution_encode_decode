
module convolutional_encoder #(
    // la intrare va fi mereu un bit
    parameter int OUTPUT_WIDTH  = 2, // rata, default 1/2 (un bit de intrare si doi de iesire)
    parameter int CONSTRAINT_LEN = 4, // default =4 (Memorie = 3 biti, tinem cont de 3 stari din trecut + cea curenta = 4)
    parameter logic [CONSTRAINT_LEN-1:0] POLYS [OUTPUT_WIDTH] = '{4'b0101, 4'b1010} // polinomi generatori, default G1=[0101], G2=[1010]
) (
    input  logic clk,
    input  logic rst_n,  
    input  logic in_bit,   // i_n
    output logic [OUTPUT_WIDTH-1:0] out_bits  // [c1n, c2n ...]
);

localparam MEM_DEPTH = CONSTRAINT_LEN - 1;
logic [MEM_DEPTH-1:0] state;
logic [CONSTRAINT_LEN-1:0] data_window;

always_ff @(posedge clk) begin
    if (!rst_n) begin
        state <= '0; 
    end else begin
        state <= {in_bit, state[MEM_DEPTH-1:1]};
    end
end

assign data_window = {in_bit, state};

always_comb begin
    for (int i = 0; i < OUTPUT_WIDTH; i++) begin
        out_bits[i] = ^(data_window & POLYS[i]);
    end
end

endmodule