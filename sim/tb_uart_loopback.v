`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Gemini
// 
// Create Date: 2025-11-23
// Design Name: UART Top-Level Loopback Testbench (Corrected)
// Module Name: tb_uart_loopback
// Project Name: uart
// Description: 
// A testbench to verify the complete uart_top module, including XOR encryption.
// 
//////////////////////////////////////////////////////////////////////////////////

module tb_uart_loopback;

    // Parameters
    localparam DBIT       = 8;
    localparam S_TICK     = 16;
    localparam CLK_PERIOD = 10; // 100 MHz clock

    // Testbench Registers and Wires
    reg clk;
    reg reset_n;
    
    // TX side signals
    reg  tx_start;
    reg  [DBIT-1:0] tx_data_in;

    // RX side signals
    wire [DBIT-1:0] rx_data_out;
    wire rx_done;
    wire rx_frame_error;

    // Instantiate the Unit Under Test (UUT) - uart_top
    // The KEY parameter will be set by the Tcl script
    uart_top #(
        .DBIT(DBIT),
        .S_TICK(S_TICK)
    ) UUT (
        .clk(clk),
        .reset_n(reset_n),
        .s_tick(1'b1), // For this simple testbench, we provide a tick every clock
        
        .tx_start(tx_start),
        .tx_din(tx_data_in),
        
        .rx_data(rx_data_out),
        .rx_done(rx_done),
        .rx_frame_error(rx_frame_error),

        .serial_tx_out() // The internal loopback is handled by uart_top
    );

    // Clock Generation
    always #(CLK_PERIOD/2) clk = ~clk;

    // Test Sequence
    initial begin
        // 1. Initialize and Reset
        clk = 0;
        reset_n = 0;
        tx_start = 0;
        tx_data_in = 0;
        
        repeat(5) @(posedge clk);
        reset_n = 1; // Release reset
        
        $display("Testbench: Reset released. Starting UART loopback test with encryption.");

        // 2. Test 1: Send a byte
        @(posedge clk);
        tx_data_in = 8'hA5; // Data to send (10100101)
        tx_start = 1;
        @(posedge clk);
        tx_start = 0;
        
        $display("Testbench: Transmitting 0x%h...", tx_data_in);

        // 3. Wait for the receiver to finish
        wait(rx_done == 1'b1);
        $display("Testbench: Receiver finished.");
        
        // 4. Check the results
        @(posedge clk); // Allow signals to settle
        if (rx_data_out == tx_data_in && rx_frame_error == 0) begin
            $display("Testbench: SUCCESS! Sent 0x%h and received 0x%h.", tx_data_in, rx_data_out);
        end else begin
            $display("Testbench: FAILURE! Sent 0x%h, received 0x%h. Frame Error: %b", tx_data_in, rx_data_out, rx_frame_error);
        end

        // 5. Test 2: Send a different byte
        #50;
        tx_data_in = 8'h3C; // Data to send (00111100)
        tx_start = 1;
        @(posedge clk);
        tx_start = 0;
        
        $display("Testbench: Transmitting 0x%h...", tx_data_in);
        wait(rx_done == 1'b1);
        $display("Testbench: Receiver finished.");
        
        @(posedge clk);
        if (rx_data_out == tx_data_in && rx_frame_error == 0) begin
            $display("Testbench: SUCCESS! Sent 0x%h and received 0x%h.", tx_data_in, rx_data_out);
        end else begin
            $display("Testbench: FAILURE! Sent 0x%h, received 0x%h. Frame Error: %b", tx_data_in, rx_data_out, rx_frame_error);
        end

        // End simulation
        #100;
        $display("Testbench: All tests complete.");
        $finish;
    end

endmodule
