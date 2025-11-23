`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Gemini
// 
// Create Date: 2025-11-22 12:30:00
// Design Name: UART Loopback Testbench
// Module Name: tb_uart_loopback
// Project Name: uart
// Target Devices: 
// Tool Versions: 
// Description: A testbench to verify uart_tx and uart_rx in a loopback configuration.
// 
//////////////////////////////////////////////////////////////////////////////////

module tb_uart_loopback();

    // Parameters
    parameter DBIT    = 8;
    parameter S_TICK  = 16;
    parameter CLK_PERIOD = 10; // 100 MHz clock

    // Testbench Registers and Wires
    reg clk;
    reg reset_n;
    reg s_tick;
    
    // TX side signals
    reg  tx_start;
    reg  [DBIT-1:0] tx_data_in;
    wire tx_done;

    // RX side signals
    wire [DBIT-1:0] rx_data_out;
    wire rx_done;
    wire rx_frame_error;

    // The "wire" connecting TX to RX
    wire serial_link;

    // Instantiate the Transmitter (UUT1)
    uart_tx #(
        .DBIT(DBIT),
        .SB_TICK(S_TICK)
    ) UUT_TX (
        .clk(clk),
        .reset_n(reset_n),
        .tx_start(tx_start),
        .s_tick(s_tick),
        .tx_din(tx_data_in),
        .tx_done_tick(tx_done),
        .tx(serial_link) // Output connects to the link
    );

    // Instantiate the Receiver (UUT2)
    uart_rx #(
        .DBIT(DBIT),
        .S_TICK(S_TICK)
    ) UUT_RX (
        .clk(clk),
        .reset_n(reset_n),
        .s_tick(s_tick),
        .rx(serial_link), // Input comes from the link
        .rx_data(rx_data_out),
        .rx_done(rx_done),
        .rx_frame_error(rx_frame_error)
    );

    // Clock Generation
    always #(CLK_PERIOD/2) clk = ~clk;

    // s_tick Generation (for this testbench, we will make it simple)
    // In a real design, this would be a proper baud rate generator.
    // Here, we just pulse it every clock cycle for max speed simulation.
    always @(posedge clk) s_tick <= 1'b1;

    // Test Sequence
    initial begin
        // 1. Initialize and Reset
        clk = 0;
        reset_n = 0;
        tx_start = 0;
        tx_data_in = 0;
        
        repeat(5) @(posedge clk);
        reset_n = 1; // Release reset
        
        $display("Testbench: Reset released. Starting UART loopback test.");

        // 2. Test 1: Send a byte with alternating bits
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
