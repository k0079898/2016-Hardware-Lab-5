module Q1_Mealy_Sequence_Detector(Dec, In, CLK, RESET);
	output Dec;
	input In, CLK, RESET;
	//104062261
	parameter S0 = 3'b000;
    parameter S1 = 3'b001;
    parameter S2 = 3'b010;
    parameter S3 = 3'b011;
    parameter S4 = 3'b100;
    reg [2:0] state;
    reg [1:0] count;
    reg Dec;
	always@(posedge CLK) begin
      if(!RESET) begin
        state <= S0;
        count <= 0;
      end else begin
        if(count==2'b11) begin
          count <= 0;
        end else begin 
          count <= count + 1;
        end
        case (state)
          S0 : if(In) state <= S1;
               else state <= S0;
          S1 : if(In) state <= S2;
               else state <= S0;
          S2 : if(In) state <= S4;
               else state <= S3;
          S3 : if(In) state <= S1;
               else state <= S0;
          S4 : if(In) state <= S4;
               else state <= S3;
        endcase
      end
    end    	
    always@(*) begin
      case (state)
        S3 : if(count==3) Dec = ~In;
             else Dec = 1'b0;
        S4 : if(count==3) Dec = In;
             else Dec = 1'b0;
        default : Dec = 1'b0;
      endcase
    end
	//104062261	
endmodule

module Q2_Sliding_Window_Detector(Dec1, Dec2, In, CLK, RESET);
	output Dec1, Dec2;
	input In, CLK, RESET;
	//103062162
	reg Dec1, Dec2, stop;
	reg [1:0] state, n_state, s, n_s, fin, n_fin;
	parameter S0 = 2'b00;
    parameter S1 = 2'b01;
    parameter S2 = 2'b10;
    parameter S3 = 2'b11;
    always@(posedge CLK) begin
      if(!RESET) begin
        state <= S0;
        s <= S0;
        fin <= S0;
        stop <= 1'b0;
        Dec1 <= 1'b0;
        Dec2 <= 1'b0;
      end else begin
        state <= n_state;
        s <= n_s;
        fin <= n_fin;
      end
    end
    always@(*) begin //Dec1
      if(stop==0) begin
        case (s)
          S0 : if(In) n_s = S1;
               else n_s = S0;
          S1 : if(In) n_s = S1;
               else n_s = S2;
          S2 : if(In) n_s = S1;
               else n_s = S0;
        endcase
      end
    end 
    always@(*) begin //detect 111
      if(stop==0) begin
        case (fin)
          S0 : if(In) n_fin  = S1;
               else n_fin = S0;
          S1 : if(In) n_fin = S2;
               else n_fin = S0;
          S2 : if(In)  n_fin = S3;
               else n_fin = S0;  
          S3 : stop = 1'b1;   
        endcase
      end
    end
    always@(*) begin //Dec2
      case (state)
        S0 : if(In) n_state = S0;
             else n_state = S1;
        S1 : if(In) n_state = S2;
             else n_state = S1;
        S2 : if(In) n_state = S3;
             else n_state = S1;
        S3 : if(In) n_state = S0;
             else n_state = S1;          
      endcase
    end
    always@(*) begin
      case (s)
        S2 : Dec1 = In;
        default : Dec1 = 1'b0;
      endcase
      case (state)
        S3 : Dec2 = ~In;
        default : Dec2 = 1'b0;
      endcase
    end
	//103062162
endmodule

module Q3_GCD(GCD, Done, Start, A, B, CLK, RESET);
	output [7:0] GCD;
	output Done;
	input  Start;
	input [7:0] A;
	input [7:0] B;
	input CLK, RESET;
	//103062162, 104062261
	reg [1:0] state;
    reg [7:0] GCD, at ,bt;
    reg Done;
    parameter S0 = 2'b00;
    parameter S1 = 2'b01;
    parameter S2 = 2'b10;
    always@(posedge CLK) begin
      if(!RESET) begin
        state <= S0;
      end else begin
        case (state)
          S0 : begin
                 if(Start==1) begin
                   at <= A;
                   bt <= B;
                   state <= S1;
                 end
                 GCD <= 0;
                 Done <= 0;
               end
          S1 : begin
                 if(at==0) begin
                   GCD <= bt;
                   Done <= 1;
                 end else begin
                   if(bt==0) begin
                     state <= S2;
                     GCD <= at;
                     Done <= 1;
                   end else begin
                     if(at>bt) begin
                       at <= at - bt;
                       state <= S1;
                     end else begin
                       bt <= bt - at;
                       state <= S1;
                     end
                   end
                 end
               end
          S2 : state <= S0;
        endcase
      end
    end
	//103062162, 104062261
endmodule

module debounce (pb_debounced, pb, clk);
    output pb_debounced; // signal of a pushbutton after being debounced
    input pb; // signal from a pushbutton
    input clk;
    reg [3:0] DFF; // use shift_reg to filter pushbutton bounce
    always @(posedge clk) begin
      DFF[3:1] <= DFF[2:0];
      DFF[0] <= pb;
    end
    assign pb_debounced = ((DFF == 4'b1111) ? 1'b1 : 1'b0);
endmodule

module OQ1_Vending_Machine(CLK, AN, Seg, SW, LED, Five, Ten, Fifty, RESET, Cancel);
	// Try to add the ports yourself!
	//104062261
	input        CLK, Five, Ten, Fifty, RESET, Cancel;
	input  [3:0] SW; 
	output [3:0] LED;
 	output [3:0] AN;
	output  [6:0] Seg;
	reg [23:0] divider_ds;
	reg [16:0] divider_ms;
	reg [6:0]  money, Seg=7'b0000000;
	reg [3:0]  display_value, AN=4'b1110, count;
	reg [1:0]  state;
	wire       RTC_s, RTC_ds, RTC_ms, Five_db, Ten_db, Fifty_db, RESET_db, Cancel_db;
	wire [3:0] Digit [0:1];
	parameter Wait   = 2'b00;
    parameter Buy    = 2'b01;
    parameter Return = 2'b10;
	always@ (posedge CLK) begin
	  if(divider_ms==100000) divider_ms <= 0;
      else divider_ms <= divider_ms + 1;
      if(divider_ds==10000000) divider_ds <= 0;
      else divider_ds <= divider_ds + 1;
	end
	assign RTC_ds = divider_ds[23];
	assign RTC_ms = divider_ms[16];
	debounce DB1(Five_db, Five, CLK);
	debounce DB2(Ten_db, Ten, CLK);
	debounce DB3(Fifty_db, Fifty, CLK);
	debounce DB4(RESET_db, RESET, CLK);
	debounce DB5(Cancel_db, Cancel, CLK);
	assign Digit[0] = money % 10;
	assign Digit[1] = money / 10 % 10;;
	assign LED[3] = (money >= 40) ? 1:0;
	assign LED[2] = (money >= 15) ? 1:0;
	assign LED[1] = (money >= 20) ? 1:0;
	assign LED[0] = (money >= 30) ? 1:0;
	always@(posedge RTC_ds) begin
	  if(RESET_db)begin
	    state <= Wait;
	    money <= 0;
	    count <= 0;
	  end else begin
	    case (state)
	      Wait : state <= Buy;
	      Buy  : begin
	               if(SW[3] && LED[3]) begin
	                 money <= money - 40;
	                 state <= Return;
	                 count <= 0;
	               end else if(SW[2] && LED[2]) begin
	                 money <= money - 15;
	                 state <= Return;
	                 count <= 0;
	               end else if(SW[1] && LED[1]) begin
	                 money <= money - 20;
	                 state <= Return;
	                 count <= 0;
	               end else if(SW[0] && LED[0]) begin
	                 money <= money - 30;
	                 state <= Return;
	                 count <= 0;
	               end else if(Cancel_db) begin
	                 state <= Return;
	                 count <= 0;
	               end else if(Five_db) begin
                     if(money+5<=70) money <= money + 5;
                     else money <= 70;
                     state <= Buy;
                    end else if(Ten_db) begin
                      if(money+10<=70) money <= money + 10;                   
                      else money <= 70;
                      state <= Buy;
                    end else if(Fifty_db) begin
                      if(money+50<=70) money <= money + 50;
                      else money <= 70;
                      state <= Buy;
                    end else begin
                      state <= Buy;
                    end
	             end
	      Return : begin
	                 if(money>0) begin
	                   if(count==10) begin
	                     count <= 0;
	                     money <= money - 5;
	                   end else count <= count + 1;
	                   state <= Return;
	                 end else state <= Wait;
	               end
	    endcase
	  end
	end
	always @(posedge RTC_ms) begin
	  case (AN)
	    4'b1110 : begin
	                AN <= 4'b1101;
	                display_value <= Digit[1];
	              end
	    4'b1101 : begin
	                AN <= 4'b1110;
	                display_value <= Digit[0];
	              end
	    default : AN <= 4'b1110;
	  endcase
	end
	always@(*) begin
      case (display_value)
        0 : Seg = 7'b1000000;  
        1 : Seg = 7'b1111001;                                               
        2 : Seg = 7'b0100100;                                      
        3 : Seg = 7'b0110000;                                           
        4 : Seg = 7'b0011001;                                        
        5 : Seg = 7'b0010010;                                           
        6 : Seg = 7'b0000010; 
        7 : Seg = 7'b1111000;  
        8 : Seg = 7'b0000000;   
        9 : Seg = 7'b0010000;   
        default : Seg = 7'b0111111;
      endcase
    end
    //104062261
endmodule

module OQ2_Calculator();
	// Try to add the ports yourself!
endmodule