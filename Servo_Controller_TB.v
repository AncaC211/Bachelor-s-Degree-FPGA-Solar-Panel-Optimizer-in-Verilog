`timescale 1ns / 1ps

module Servo_Controller_TB();

    reg        clk;
    reg        rst;
    reg [11:0] xadc;
    wire       control;

    Servo_Controller DUT(
        .clk(clk),
        .rst(rst),
        .xadc(xadc),
        .control(control)
    );

    initial begin
        clk = 1'b0;
        forever #4 clk = !clk;  // T = 8 ns <=> f = 125 MHz
    end

    initial begin
        #1.5;
        rst = 1'b0;
        xadc = 12'd1;
        #13;
        rst = 1'b1;
        repeat (2800000) @(posedge clk);
        xadc = 12'd2;
        repeat (5500000) @(posedge clk);
        xadc = 12'd3;
        repeat (7200000) @(posedge clk);
        $finish;
    end


endmodule