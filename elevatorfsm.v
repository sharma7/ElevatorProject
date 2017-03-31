module elevatorfsm(clk, clr_, w);
	
	input clk, clr_;
    
    // The input for floors, is a 3 bit input
    input [2:0]	w;
    
    // Represents current and new states
	reg [2:0] y, Y;
	
	// Each of our states for the floors of elevator
	// Ground Floor, Floor 2, Floor 3, Floor 4
	localparam A=3'b001, B=3'b010, C=3'b011, D=3'b100;
	
	// check when current state changes or when a variable changes
	always @(y,w)
		case (y)
			// Elevator Logic
			A:  if (w == A) Y = A;
				else if (w == B) Y = B;
			 	else if (w == C) Y = C;
				else Y = D;
			B:  if (w == A) Y = A;
				else if (w == B) Y = B;
				else if (w == C) Y = C;
				else Y = D;
			C:  if (w == A) Y = A;
				else if (w == B) Y = B;
				else if (w == C) Y = C;
				else Y = D;
			D:  if (w == A) Y = A;
				else if (w == B) Y = B;
				else if (w == C) Y = C;
				else Y = D;
				
			default: Y = A;
		endcase
	
	// Does the work of changing current state (y) to new state (Y)	
	always @(negedge clr_,  posedge clk)
		if (!clr_) y <= A;
		else y<= Y;

endmodule