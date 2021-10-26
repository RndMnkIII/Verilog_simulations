
//h8_feedback_tb.v
`default_nettype none
`timescale 1ns/10ps

//iverilog -o h8_feedback_tb.vvp h8_feedback_tb.v ttl_74169.v ttl_74164_half.v ttl_74109_cl.v
//iverilog -o h8_feedback_tb.vvp h8_feedback_tb.v ttl_74169.v ttl_74164.v ttl_74109_cl.v
//vvp h8_feedback_tb.vvp -lxt2
//start gtkwave h8_feedback_tb.lxt

module h8_feedback_tb ();
    //Parameters for master clock
    localparam mc_freq = 5_000_000;
    localparam mc_p =  (1.0 / mc_freq) * 1_000_000_000;
    localparam mc_hp = mc_p / 2;
    localparam SIMULATION_TIME = 40_000_000; //ns

    //2master clock
    reg clk = 0;
    always #mc_hp clk = !clk;
    
    reg DMAEND = 1'b0;
    reg KILL = 1'b0;
    wire FLIP;
    assign FLIP = 1'b1;
    wire FLIPn;
    assign #5 FLIPn = ~FLIP;

    // reg [7:0] registro;
    // wire cout;

    // initial registro = 8'h0;
    // always @(posedge clk, negedge LD_HCNTn) begin
    //     if (!LD_HCNTn) begin
    //         registro <= #15 8'hC0; //constant value at input
    //     end
    //     else registro <= #15 registro + 1;
    // end

    //INCREASING DELAY FROM #10 TO #20 BROKE THE CIRCUIT OPERATION!!!
    //assign #10 cout = !LD_HCNTn ? 1'b0: ~(&registro); 

    //SEGA 315-5152
    //-----------------------------
    //Using two 74LS169 modules
    wire hcnt_low_rco;
    wire [7:0] H;
    wire cout2;
    ttl_74169 hcnt_low(.clk(clk), .direction(1'b1), .load_n(LD_HCNTn), .ent_n(1'b0), .enp_n(1'b0),
                 .P({4'H0}), .rco_n(hcnt_low_rco), .Q(H[3:0]));

    ttl_74169 hcnt_hight(.clk(clk), .direction(1'b1), .load_n(LD_HCNTn), .ent_n(hcnt_low_rco), .enp_n(hcnt_low_rco),
                 .P({4'hC}), .Q(H[7:4]), .rco_n(cout2));
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

    assign #2 cout_neg = ~cout2;
    assign #15 p1 = cout_neg & r1n_neg;

    assign #2 n1 = ~p1;
    assign LD_HCNTn = n1;

    assign #15 p2 = n1 & r1n_neg;
    assign #15 p3 = cout_neg & r1n;

    assign #10 s1 = p2 | p3;
    //--------------------------
    //wire term1;
    wire term2;
    
    assign #25 term2 = (n1 & r1n_neg) | (cout_neg & r1n);
    always @(posedge clk) begin
        r1 <= #15 term2;
    end
    assign r1n = ~r1;
    assign #2 r1n_neg = ~r1n;

    assign #2 n2 = ~r1;
    assign H8 = n2;

    //--------------------------
    wire HSYNCn;
    wire [5:0] H5;
    assign H5 = H[5:0];
    wire term7;
    reg r6;
    initial r6=0;
    wire r6n, r6n_neg, n7;
    assign #25 term7 = (    ( H[1] & ~H[2] &  H[3] & ~H[4] & ~H[5] & H8 &  FLIP) | //00 101x 0A,0B
                            (         H[2] &  H[3] & ~H[4] & ~H[5] & H8 &  FLIP) | //00 11xx 0C, 0D, 0E, 0F
                            (                         H[4] & ~H[5] & H8 &  FLIP) | //01 xxxx 10-1F
                            (~H[1] & ~H[2] & ~H[3] & ~H[4] &  H[5] & H8 &  FLIP) | //10 000x 20,21

                            (~H[1] &  H[2] & ~H[3] &  H[4] &  H[5] & H8 & ~FLIP) | //11 010x 35, 34
                            (        ~H[2] & ~H[3] &  H[4] &  H[5] & H8 & ~FLIP) | //11 00xx 33,32,31,30
                            (                        ~H[4] &  H[5] & H8 & ~FLIP) | //10 xxxx 2F-20
                            ( H[1] &  H[2] &  H[3] & H[4] &  ~H[5] & H8 & ~FLIP)); //01 111x 1F,1E

    always @(posedge clk) begin
        r6 <= #15 term7;
    end
    assign r6n = ~r6;
    assign #2 r6n_neg = ~r6n;

    assign #2 n7 = ~r6;
    assign HSYNCn = n7;
    //-------------------------
    reg r8;
    initial r8=0;
    wire CPUn, r8n, r8n_neg, n9, term9;
    assign #25 term9 = (( H[0] &  H[1] &  H[2] & ~H[3] & H[4] &  H[5] & H8) | //11 0111 //37
                        ( H[0] &  H[1] &  H[2] &  H[3] & H[4] & ~H[5] & H8)); //01 1111 //1F

    always @(posedge clk) begin
        r8 <= #15 term9;
    end
        assign r8n = ~r8;
    assign #2 r8n_neg = ~r8n;

    assign #2 n9 = ~r8;
    assign CPUn = n9;
    //-------------------------
    wire SER_OUT;
    wire [2:0] H2;
    assign H2 = H[2:0];
    // 0000     1
    // 0001     1
    // 0010     1
    // 0011     1
    // 0100     1
    // 0101     1
    // 0110     0
    // 0111     1
    // 1000     1
    // 1001     1
    // 1010     1
    // 1011     1
    // 1100     1
    // 1101     1
    // 1110     0
    // 1111     1
    //ENABLING/DISABLING HIGHER LEVER PRODUCT TERM GENERATES A SIGNAL X2, X4, X8 OF THE MAIN CLOCK (5MHz)
    assign #25 SER_OUT = ~( (                ~H[2] &  FLIP) | //xxxx x0xx each 4 steps starting at H[2] == 1'b0
                            (        ~H[1] &          FLIP) | //xxxx xx0x each 2 steps starting at H[1] == 1'b0
                            (~H[0] &  H[1] &  H[2] &  FLIP) | //xxxx x110 each 8 steps starting at H[2:0] == 3'h6

                            (                 H[2] & ~FLIP) | //xxxx x1xx each 4 steps starting at H[2] == 1'b1
                            (         H[1] &         ~FLIP) | //xxxx xx1x each 2 steps starting at H[1] == 1'b1
                            ( H[0] & ~H[1] & ~H[2] & ~FLIP)); //xxxx x001 each 8 steps starting at H[2:0] == 3'h1
    //--------------------------
    reg r7;
    initial r7=0;
    wire DMAONn, r7n, r7n_neg, n8, term8;
    assign #25 term8 = ( (~H[0] & ~H[1] & ~H[2] & ~H[3] & ~H[4] & ~H[5] & VB_IL & H8 &  FLIP) |
                         ( H[0] &  H[1] &  H[2] &  H[3] &  H[4] &  H[5] & VB_IL & H8 & ~FLIP) |
                         (~DMAEND & r7n_neg));

    always @(posedge clk) begin
        r7 <= #15 term8;
    end
        assign r7n = ~r7;
    assign #2 r7n_neg = ~r7n;

    assign #2 n8 = ~r7;
    assign DMAONn = n8;
    //--------------------------

    //-------------------------
    //315-5138
    //Using two 74LS169 modules
    wire vcnt_low_rco;
    wire [7:0] V;
    
    ttl_74169 vcnt_low(.clk(H8), .direction(1'b1), .load_n(ILINEn), .ent_n(1'b0), .enp_n(1'b0),
                 .P({4'h0}), .rco_n(vcnt_low_rco), .Q(V[3:0]));

    ttl_74169 vcnt_hight(.clk(H8), .direction(1'b1), .load_n(ILINEn), .ent_n(vcnt_low_rco), .enp_n(vcnt_low_rco),
                 .P({4'h0}), .Q(V[7:4]));
    //-------------------------
    reg r2;
    initial r2=0;
    wire VB_IL, r2n, r2n_neg, n3, term3;
    assign #25 term3 = r3n_neg | (~V[1] & FLIP & r2n_neg) |(V[1] & ~FLIP & r2n_neg) | (V[5] & r2n_neg);
    
    always @(posedge H8) begin
        r2 <= #15 term3;
    end
    assign r2n = ~r2;
    assign #2 r2n_neg = ~r2n;

    assign #2 n3 = ~r2;
    assign VB_IL = n3;
    //-------------------------
    reg r3;
    initial r3=0;
    wire INTn, r3n, r3n_neg, n4, term4;
    assign #25 term4 = (~V[0] & V[1] & V[2] & V[3] & V[4] & ~V[5] & V[6] & V[7] & FLIP) |
         (V[0] & ~V[1] & ~V[2] & ~V[3] & ~V[4] & ~V[5] & ~V[6] & ~V[7] & ~FLIP);

    always @(posedge H8) begin
        r3 <= #15 term4;
    end
        assign r3n = ~r3;
    assign #2 r3n_neg = ~r3n;

    assign #2 n4 = ~r3;
    assign INTn = n4;
    //-------------------------
    reg r4;
    initial r4=0;
    wire VBLANKn, r4n, r4n_neg, n5, term5;
    assign #25 term5 = r5n_neg | (r3n & r4n_neg) | (V[0] & V[1] & V[2] & V[3] & ~V[4] & ~V[5] & V[6] & V[7]);

    always @(posedge H8) begin
        r4 <= #15 term5;
    end
        assign r4n = ~r4;
    assign #2 r4n_neg = ~r4n;

    assign #2 n5 = ~r4;
    assign VBLANKn = n5;
    //-------------------------
    reg r5;
    initial r5=0;
    wire ILINEn, r5n, r5n_neg, n6, term6;
    assign #25 term6 =  (~V[0] & V[1] & ~V[2] & ~V[3] & ~V[4] & ~V[5] & ~V[6] & ~V[7] & FLIP & r4n) |
         (V[0] & ~V[1] & V[2] & V[3] & V[4] & ~V[5] & V[6] & V[7] & ~FLIP & r4n);

    always @(posedge H8) begin
        r5 <= #15 term6;
    end
        assign r5n = ~r5;
    assign #2 r5n_neg = ~r5n;

    assign #2 n6 = ~r5;
    assign ILINEn = n6;
    //-------------------------
    wire ic49;
    wire BLANKn;
    assign #20 ic49 = ~(KILL | VBLANKn | H8);
    ttl_74109_cl #(.BLOCKS(1), .DELAY_RISE(20), .DELAY_FALL(20)) ic43 (.Clear_bar(ic49), .J(ic49), .Kn(ic49), .Clk(FIXST), .Q(BLANKn));
    //------------------------
    wire CMPSYNCn;
    assign #25 CMPSYNCn = ~(~HSYNCn | (V[2] & V[3] & ~V[4] & FLIP & r4n) | (~V[2] & ~V[3] & V[4] & ~FLIP & r4n));
    //------------------------
    wire MUXn;
    assign #25 MUXn = ~(~V[0] & ~V[1] & ~V[2] & ~V[3] & V[4] & V[5] & V[6] & V[7] & ~HSYNCn);
    //------------------------
    wire SYNCn;
    assign #20 SYNCn = CMPSYNCn ^ 1'b1; //positive-negative sync jumper on pcb
    //-----------------------
    wire SRLDS;
    wire FIXST;
    wire  FIXDS;
    //ttl_74164_half ic42(.A(SER_OUT), .B(SER_OUT), .clk(clk), .MRn(1'b1), .Q0(SRLDS), .Q2(FIXST), .Q3(FIXDS));
    ttl_74164 ic42(.A(SER_OUT), .B(SER_OUT), .clk(clk), .MRn(1'b1), .Q0(SRLDS), .Q3(FIXST), .Q4(FIXDS));

    //-----------------------
    initial
    begin
        $dumpfile("h8_feedback_tb.lxt");
        $dumpvars(0,h8_feedback_tb);
        #SIMULATION_TIME;
        $finish;
    end

endmodule
