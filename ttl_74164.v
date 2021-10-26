//ttl_74l164.v
//SN74LS164 Serial-In Parallel-Out Shift Register (8-bits)
// @RndMnkIII 15/10/2021.
// Based on On Semiconductor SN74LS164 Datasheet
// MRn to Q propagation delay (typ): 24ns
// clock to Q propagation delay (typ): (21+17)/2 = 19ns
//                   ---------------
//        A       ->| 1          14 |--  VCC
//        B       ->| 2          13 |->  Q7
//        Q0      ->| 3          12 |->  Q6
//        Q1      ->| 4          11 |->  Q5
//        Q2      ->| 5          10 |->  Q4
//        Q3      ->| 6          9  |O<- /MR        _
//        GND     --| 7          8  |<-  CP (CLK) _| |_
//                   ---------------
`default_nettype none
`timescale 1ns/10ps

module ttl_74164 (
    input A, B, //serial input data
    input clk,
    input MRn, //Master Reset (async)
    output reg Q0, Q1, Q2, Q3, Q4, Q5, Q6, Q7
);
    localparam MRDLY = 24;
    localparam REGDLY = 19;

    wire serdata;
    assign serdata = A & B;

    always @(posedge clk, negedge MRn) begin
        if (!MRn) begin
            Q0 <= #MRDLY 1'b0;
            Q1 <= #MRDLY 1'b0;
            Q2 <= #MRDLY 1'b0;
            Q3 <= #MRDLY 1'b0;
            Q4 <= #MRDLY 1'b0;
            Q5 <= #MRDLY 1'b0;
            Q6 <= #MRDLY 1'b0;
            Q7 <= #MRDLY 1'b0;
        end else begin
            Q0 <= #REGDLY serdata;
            Q1 <= #REGDLY Q0;
            Q2 <= #REGDLY Q1;
            Q3 <= #REGDLY Q2;
            Q4 <= #REGDLY Q3;
            Q5 <= #REGDLY Q4;
            Q6 <= #REGDLY Q5;
            Q7 <= #REGDLY Q6;
        end
    end
endmodule

