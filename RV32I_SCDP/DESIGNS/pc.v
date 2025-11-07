module pc(
    input clk, rst,
    input [`INSTRUCTION_SIZE - 1 : 0] in,
    output [`INSTRUCTION_SIZE - 1 : 0] out
);
always @(posedge clk) begin
    if (rst) begin
        out <= 32'b0;
    end else begin
        out <= in;
    end
end
endmodule