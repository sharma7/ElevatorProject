module elevatorfsm(clk, clr_, w);

    input clk, clr_;

    // The input for floors, is a 3 bit input
    input [2:0] w;

    // Represents current and new states
    reg [2:0] y, Y;

    // Each of our states for the floors of elevator
    // Ground Floor, Floor 2, Floor 3, Floor 4
    localparam A=3'b001, B=3'b010, C=3'b011, D=3'b100;
    always @(w,y)
        case (y)
            A: if (w == A) Y = A;
               else if (w == B)
                    begin
                        stop = 1'b0;
                        direction = 1'b1;
                        start = 1'b1;
                        if (count == 4'b0011)
                            begin
                                stop = 1'b1;
                                start = 1'b0;
                                Y = B;
                            end
                    end
                else if (w == C) Y = C;
                else Y = D;
            B: if (w == A) Y = A;
               else if (w == B) Y = B;
               else if (w == C) Y = C;
               else Y = D;
            C: if (w == A) Y = A;
               else if (w == B) Y = B;
               else if (w == C) Y = C;
               else Y = D;
            D: if (w == A) Y = A;
               else if (w == B) Y = B;
               else if (w == C) Y = C;
               else Y = D;
            default: Y = A;
    endcase

always @(negedge SW[3],  posedge CLOCK_50)
    if (!SW[3]) y <= A;
    else y<= Y;

endmodule