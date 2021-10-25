
//h8_feedback_tb.v
`default_nettype none
`timescale 1ns/10ps

//iverilog -o h8_feedback_tb.vvp h8_feedback_tb.v
//vvp h8_feedback_tb.vvp -lxt2
//start gtkwave h8_feedback_tb.lxt

module h8_feedback_tb ();
    //Parameters for master clock
    localparam mc_freq = 5_000_000;
    localparam mc_p =  (1.0 / mc_freq) * 1_000_000_000;
    localparam mc_hp = mc_p / 2;
    localparam SIMULATION_TIME = 20_000_000; //ns

    //2master clock
    reg clk = 0;
    always #mc_hp clk = !clk;

    reg [7:0] registro;
    wire cout;

    initial registro = 8'h0;
    always @(posedge clk, negedge LD_HCNTn) begin
        if (!LD_HCNTn) begin
            registro = 8'hC0;
        end
        else registro <= #10 registro + 1;
    end

    //INCREASING DELAY FROM #10 TO #20 BROKE THE CIRCUIT OPERATION!!!
    assign #10 cout = !LD_HCNTn ? 1'b0: ~(&registro); 

    //-----------------------------
    wire cout_neg;

    wire p1;
    wire n1;
    wire LD_HCNTn;
    wire p2;
    wire p3;
    wire s1;
    wire n2;
    reg r1;
    wire r1n;
    wire r1n_neg;
    wire H8;   
    initial r1=0;

    assign #2 cout_neg = ~cout;
    assign #15 p1 = cout_neg & r1n_neg;

    assign #2 n1 = ~p1;
    assign LD_HCNTn = n1;

    assign #15 p2 = n1 & & r1n_neg;
    assign #15 p3 = cout_neg & r1n;

    assign #10 s1 = p2 | p3;

    always @(posedge clk) begin
        r1 <= #15 s1;
    end
    assign r1n = ~r1;
    assign #2 r1n_neg = ~r1n;

    assign #2 n2 = ~r1;
    assign H8 = n2;

    initial
    begin
        $dumpfile("h8_feedback_tb.lxt");
        $dumpvars(0,h8_feedback_tb);
        #SIMULATION_TIME;
        $finish;
    end

endmodule
