
//h8_feedback_tb.v
`default_nettype none
`timescale 1ns/10ps

//iverilog -o h8_feedback_tb.vvp h8_feedback_tb.v ttl_74169.v
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

    wire FLIP;
    assign FLIP = 1'b1;
    wire FLIPn;
    assign #5 FLIPn = ~FLIP;

    reg [7:0] registro;
    wire cout;

    initial registro = 8'h0;
    always @(posedge clk, negedge LD_HCNTn) begin
        if (!LD_HCNTn) begin
            registro <= #15 8'hC0; //constant value at input
        end
        else registro <= #15 registro + 1;
    end

    //INCREASING DELAY FROM #10 TO #20 BROKE THE CIRCUIT OPERATION!!!
    assign #10 cout = !LD_HCNTn ? 1'b0: ~(&registro); 


    //-----------------------------
    //Using two 74LS169 modules
    wire ic17_rco;
    wire [7:0] H;
    wire cout2;
    ttl_74169 ic17(.clk(clk), .direction(1'b1), .load_n(LD_HCNTn), .ent_n(1'b0), .enp_n(1'b0),
                 .P({4'H0}), .rco_n(ic17_rco), .Q(H[3:0]));

    ttl_74169 ic23(.clk(clk), .direction(1'b1), .load_n(LD_HCNTn), .ent_n(ic17_rco), .enp_n(ic17_rco),
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

    assign #15 p2 = n1 & & r1n_neg;
    assign #15 p3 = cout_neg & r1n;

    assign #10 s1 = p2 | p3;

    //wire term1;
    wire term2;
    
    assign #25 term2 = (n1 & & r1n_neg) | (cout_neg & r1n);
    always @(posedge clk) begin
        r1 <= #15 term2;
    end
    assign r1n = ~r1;
    assign #2 r1n_neg = ~r1n;

    assign #2 n2 = ~r1;
    assign H8 = n2;

    //--------------------------
    //1111 F, 1110 E, 1101 D, 1100 C, 1011 B, 1010 A, 1001 9, 1000 8, 0111 7, 0110 6, 0101 5, 0100 4, 0011 3, 0010 2, 0001 1, 0000 0
    wire HSYNCn;
    wire [5:0] H5;
    assign H5 = H[5:0];
    assign #25 HSYNCn = ~(  ( H[1] & ~H[2] &  H[3] & ~H[4] & ~H[5] & H8 &  FLIP) | //00 101x 0A,0B
                            (         H[2] &  H[3] & ~H[4] & ~H[5] & H8 &  FLIP) | //00 11xx 0C, 0D, 0E, 0F
                            (                         H[4] & ~H[5] & H8 &  FLIP) | //01 xxxx 10-1F
                            (~H[1] & ~H[2] & ~H[3] & ~H[4] &  H[5] & H8 &  FLIP) | //10 000x 20,21

                            (~H[1] &  H[2] & ~H[3] &  H[4] &  H[5] & H8 & ~FLIP) | //11 010x 35, 34
                            (        ~H[2] & ~H[3] &  H[4] &  H[5] & H8 & ~FLIP) | //11 00xx 33,32,31,30
                            (                        ~H[4] &  H[5] & H8 & ~FLIP) | //10 xxxx 2F-20
                            ( H[1] &  H[2] &  H[3] & H[4] &  ~H[5] & H8 & ~FLIP)); //01 111x 1F,1E

    //-------------------------
    wire CPUn;
    assign #25 CPUn = ~(( H[0] &  H[1] &  H[2] & ~H[3] & H[4] &  H[5] & H8) | //11 0111 //37
                        ( H[0] &  H[1] &  H[2] &  H[3] & H[4] & ~H[5] & H8)); //01 1111 //1F

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

    initial
    begin
        $dumpfile("h8_feedback_tb.lxt");
        $dumpvars(0,h8_feedback_tb);
        #SIMULATION_TIME;
        $finish;
    end

endmodule
