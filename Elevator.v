`timescale 1ns / 1ns

module Elevator(CLOCK_50, SW, HEX0, LEDR, GPIO); 
	
	input [5:0] SW;
	output [2:0] LEDR;
	output [4:0] GPIO;
	output [6:0] HEX0;
	input CLOCK_50;
	
	reg stop = 1'b0;
	
	wire [3:0] count;
	
	// Initialize a counter for use, that starts based on Clear_b
	Counter counter(.Clear_b(SW[0]), .clock(CLOCK_50), .ParLoad(2'b01), .q(count));
	// Hex for the user to see the state of the counter
	hex_decoder hexd0(.hex_digit(count[3:0]), .segments(HEX0));
	
	// Check the 
	always @ (posedge CLOCK_50)
	begin
		if (count == 4'b0011)
			stop <= 1'b1;
	end
	
	// Initialize our stepper control, with switches for direction and reset
	// stop is used to stop the motor when we'd like to
    StepperControl driver(CLOCK_50, SW[3], SW[4], stop, LEDR[2:0], GPIO[3:0]);
	
endmodule

module Counter(Clear_b, clock, ParLoad, q);
  input Clear_b;
  input clock;
  input [1:0] ParLoad;
  output reg [3:0] q;

  wire Enable;
  reg [27:0] f;

  // Choose the rate of our counter	
  always @(ParLoad)
  begin
	  if (ParLoad == 2'b00)
		 f = 28'd1;
	  else if (ParLoad == 2'b01)
		 f = 28'd49_999_999;
	  else if (ParLoad == 2'b10)
		 f = 28'd99_999_999;
	  else
	    f = 28'd199_499_999;
   end

  // delay depending on the rate of the counter we have chosen
  stop slow_rate(.delay(Enable), .CLOCK_50(clock), .rate(f));
  
  // The actual count
  always @(posedge clock)
  begin
    if (Clear_b == 1'b0) 
      q <= 0;
    // reset after 1111
    else if (q == 4'b1111)
      q <= 0; 
    else if (Enable == 1'b1) 
      q <= q + 1'b1;
  end

endmodule

// acts as delay/wait, so we can increment our 
// count at any rate we'd like
module stop(delay, CLOCK_50, rate);
  output reg delay;
  input CLOCK_50;
  input [27:0] rate;
  reg	[27:0] count;
	
  // only output a pulse once rate has been reached 
  always @(posedge CLOCK_50)
  begin
    if(count==limit)
      begin
        count<=28'd0;
        // we delayed for the time we want
        delay<=1;
      end
    else
      begin
        count<=count+1;
        delay<=0;
      end
  end
  
endmodule

// hex decoder so we can show the user our timer
module hex_decoder(hex_digit, segments);
    input [3:0] hex_digit;
    output reg [6:0] segments;
    always @(*)
        case (hex_digit)
            4'h0: segments = 7'b100_0000;
            4'h1: segments = 7'b111_1001;
            4'h2: segments = 7'b010_0100;
            4'h3: segments = 7'b011_0000;
            4'h4: segments = 7'b001_1001;
            4'h5: segments = 7'b001_0010;
            4'h6: segments = 7'b000_0010;
            4'h7: segments = 7'b111_1000;
            4'h8: segments = 7'b000_0000;
            4'h9: segments = 7'b001_1000;
            4'hA: segments = 7'b000_1000;
            4'hB: segments = 7'b000_0011;
            4'hC: segments = 7'b100_0110;
            4'hD: segments = 7'b010_0001;
            4'hE: segments = 7'b000_0110;
            4'hF: segments = 7'b000_1110;
            default: segments = 7'h7f;
        endcase
endmodule
