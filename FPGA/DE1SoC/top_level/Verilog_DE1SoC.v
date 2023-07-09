module Verilog_DE1SoC (
    input i_RX,
    input i_CLK,
    input i_RST,
    output o_TX,
    output [9:0] o_LEDR,
    output [6:0] o_HEX5,
    output [6:0] o_HEX4,
    output [6:0] o_HEX3,
    output [6:0] o_HEX2,
    output [6:0] o_HEX1,
    output [6:0] o_HEX0
);

wire w_CLK;
wire w_LOCKED;
wire w_PLLRST;
wire [9:0] LEDR;
wire [6:0] HEX5;
wire [6:0] HEX4;
wire [6:0] HEX3;
wire [6:0] HEX2;
wire [6:0] HEX1;
wire [6:0] HEX0;
wire [9:0] SW;
wire [3:0] KEY;

assign o_LEDR = LEDR;
assign o_HEX5 = HEX5;
assign o_HEX4 = HEX4;
assign o_HEX3 = HEX3;
assign o_HEX2 = HEX2;
assign o_HEX1 = HEX1;
assign o_HEX0 = HEX0;

DE1SoC #(
    .baud(9600),
    .clock(50000000)
) U1 (
    .i_CLK(i_CLK),
    .i_RX(i_RX),
    .i_RST(i_RST),
    .i_LEDS(LEDR),
    .i_7S5(HEX5),
    .i_7S4(HEX4),
    .i_7S3(HEX3),
    .i_7S2(HEX2),
    .i_7S1(HEX1),
    .i_7S0(HEX0),
    .o_SWITCH(SW),
    .o_BUTTON(KEY),
    .o_TX(o_TX)
);

// Implement your logic inside this region


// End of logic implementation region

endmodule