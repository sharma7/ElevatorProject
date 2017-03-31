module StepperControl(clock, reset, direction, stop, led, stepperPins);

input clock, reset, direction, stop;
output [2:0] led;

reg [2:0] SevenCount;
reg [31:0] Count1;

localparam RATE = 50000000;
 
// Count to 7, in rate of actual seconds
// Gives us a basis of how fast the motor will spin
// relative to actual seconds 
always @ (posedge clock)
begin
    if(SevenCount == 3'b111 || reset == 0)
        SevenCount <= 1'b0;
 
    Count1 = Count1 + 1'b1;
    
    if(Count1 == RATE)
        begin
            Count1 <= 1'b0;
            SevenCount <= SevenCount + 1'b1;
        end
end

// diagnostic LEDs 
assign led = ~SevenCount;

// GPIO output pins
output [3:0] stepperPins;
reg [3:0] stepperPins;

// Count to help determine how often to increase our step 
reg [31:0] Count2;
// The stepper motor takes 8 steps for a complete rotation
reg [2:0] step; 
 
always @ (posedge clock)
begin
	// if stop is high, we slow the motor down
	// to the point it is not spinning at all
	if (stop) 
		begin
			if(Count2 >= 5000000 * (SevenCount + 1))
				begin
					step <= step + 1'b1;
					Count2 <= 1'b0;
				end
			else
				Count2 <= Count2 + 1'b1;
		 end
	// otherwise spin the motor as fast as we can
	// 450000 seems to be the sweet spot.
	else
		if(Count2 >= 45000 * (SevenCount + 1))
			begin
				step <= step + 1'b1;
				Count2 <= 1'b0;
			end
		else
			Count2 <= Count2 + 1'b1;
end

// every time step changes, we we will change StepperPins depending on direction
always @ (step)
begin
    case(step)
    	// ternary operator that checks direction
        0: stepperPins <= direction ? 4'b1000 : 4'b0001;
        1: stepperPins <= direction ? 4'b1100 : 4'b0011;
        2: stepperPins <= direction ? 4'b0100 : 4'b0010;
        3: stepperPins <= direction ? 4'b0110 : 4'b0110;
        4: stepperPins <= direction ? 4'b0010 : 4'b0100;
        5: stepperPins <= direction ? 4'b0011 : 4'b1100;
        6: stepperPins <= direction ? 4'b0001 : 4'b1000;
        7: stepperPins <= direction ? 4'b1001 : 4'b1001;
    endcase
end
 
endmodule
