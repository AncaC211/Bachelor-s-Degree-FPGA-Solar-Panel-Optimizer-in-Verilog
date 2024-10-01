module Servo_Controller(
    input        clk,
    input        rst,
    input [11:0] xadc,
    output reg   control
);

    reg [17:0] duty;
    reg [21:0] cnt;

    always @(*) begin
        case (xadc)
            12'd1:   duty = 18'd125000;     // 1   ms. -90 degrees.
            12'd2:   duty = 18'd187500;     // 1.5 ms. 0   degrees.
            12'd3:   duty = 18'd250000;     // 2   ms. 90  degrees.
            default: duty = 18'd0;
        endcase
    end

    // OBS: Valorile 1, 2 si 3 sunt orientative. Trebuie puse valorile pe care le returneaza ADC-ul pentru tensiunile potrivite.

    always @(posedge clk) begin
        if (!rst) begin
            cnt     <= 22'd0;
            control <= 1'b0;
        end
        else begin
            if (cnt < 22'd2499999)
                cnt <= cnt + 1;
            else
                cnt <= 22'd0;
            if (cnt < duty)
                control <= 1'b1;
            else
                control <= 1'b0;
        end
    end

endmodule