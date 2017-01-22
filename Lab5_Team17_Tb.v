`timescale 1ns/10ps
module Tb_Q1; //104062261
    wire Dec;
	reg In, CLK, RESET;
	Q1_Mealy_Sequence_Detector Q1(Dec, In, CLK, RESET);
	always begin
      #20
      CLK = ~CLK;
    end
    initial begin
      CLK = 0;
      RESET = 1;
      In = 0;
      #40  RESET = 0;
      #40  RESET = 1;
           In = 1;
      #80  In = 0;
      #80  In = 1;
      #200 In = 0;
      #40  In = 1;
      #200 In = 0;
      #40  In = 1;
      #80  In = 0;
    end
endmodule

module Tb_Q2; //103062162, 104062261
    reg  In, CLK, RESET;
    wire Dec1, Dec2;
    Q2_Sliding_Window_Detector Q2(Dec1, Dec2, In, CLK, RESET);
    initial begin
      CLK = 0;
      RESET = 1;
      In = 0;
      #40 RESET = 0;
      #40 RESET = 1;
          In = 0; 
      #40 In = 1; 
      #40 In = 0; 
      #40 In = 1;
      #40 In = 0; 
      #40 In = 1; 
      #80 In = 0; 
      #40 In = 1; 
      #120 In = 0; 
      #40 In = 1;  
      #80 In = 0; 
      #40 RESET = 0;
      #40 RESET = 1;
          In = 1;
      #40 In = 0; 
      #40 In = 1; 
    end
    always begin
      #20
      CLK = ~CLK;
    end
endmodule

module Tb_Q3; //103062162
  reg CLK, RESET, Start;
  reg [7:0]	A, B;
  wire Done;
  wire [7:0] GCD;
  Q3_GCD Q3(GCD, Done, Start, A, B, CLK, RESET);
  initial begin
    CLK = 0;
    Start = 0;
    RESET = 1;
    #40  RESET = 0;
    #40  RESET = 1;
         A = 60;
         B = 25;
    #80  Start = 1;
    #40  Start = 0;
    #480 A = 90;
         B = 30;
         Start = 1;
    #40  Start = 0;
  end
  always begin
    #20
    CLK = ~CLK;
  end
endmodule
