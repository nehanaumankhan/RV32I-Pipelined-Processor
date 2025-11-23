// ==================== HEX TO 7-SEGMENT MODULE ====================
module hex_to_7seg(
    input [3:0] hex,
    output reg [7:0] seg // {a,b,c,d,e,f,g}
);
    always @(*) begin
        case(hex)
            4'h0: seg = 8'b10000001;
            4'h1: seg = 8'b11001111;
            4'h2: seg = 8'b10010010;
            4'h3: seg = 8'b10000110;
            4'h4: seg = 8'b11001100;
            4'h5: seg = 8'b10100100;
            4'h6: seg = 8'b10100000;
            4'h7: seg = 8'b10001111;
            4'h8: seg = 8'b10000000;
            4'h9: seg = 8'b10000100;
            4'hA: seg = 8'b10001000;
            4'hB: seg = 8'b11100000;
            4'hC: seg = 8'b10110001;
            4'hD: seg = 8'b11000010;
            4'hE: seg = 8'b10110000;
            4'hF: seg = 8'b10111000;
            default: seg = 8'b11111111; // all off
        endcase
    end
endmodule