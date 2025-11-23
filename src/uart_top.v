`include "key_config.vh"

module uart_top
   #(parameter DBIT = 8,
     S_TICK = 16,
     parameter KEY = `KEY_VALUE) // Key now comes from key_config.vh
   (
   // Global signals
   input                clk,
   input                reset_n,
   input                s_tick,

   // TX side inputs
   input                tx_start,
   input  [DBIT-1:0]    tx_din,
   
   // RX side outputs
   output [DBIT-1:0]    rx_data,
   output               rx_done,
   output               rx_frame_error,

   // Optional: Expose the serial line for external monitoring
   output               serial_tx_out
   );

    // Wires for data path
    wire internal_serial_link;
    wire [DBIT-1:0] encrypted_data;
    wire [DBIT-1:0] raw_received_data;

    // 1. Encrypt the data before transmission
    xor_cipher #(
        .WIDTH(DBIT)
    ) ENC_inst (
        .data_in(tx_din),
        .key(KEY),
        .data_out(encrypted_data)
    );

    // 2. Instantiate the Transmitter with the encrypted data
    uart_tx #(
        .DBIT(DBIT)
    ) UUT_TX (
        .clk(clk),
        .reset_n(reset_n),
        .tx_start(tx_start),
        .s_tick(s_tick),
        .tx_din(encrypted_data), // Transmit the encrypted data
        .tx_done_tick(), // Not used in this top-level design
        .tx(internal_serial_link)
    );

    // 3. Instantiate the Receiver
    uart_rx #(
        .DBIT(DBIT)
    ) UUT_RX (
        .clk(clk),
        .reset_n(reset_n),
        .s_tick(s_tick),
        .rx(internal_serial_link),
        .rx_data(raw_received_data), // Receive the raw (still encrypted) data
        .rx_done(rx_done),
        .rx_frame_error(rx_frame_error)
    );

    // 4. Decrypt the data after reception
    xor_cipher #(
        .WIDTH(DBIT)
    ) DEC_inst (
        .data_in(raw_received_data),
        .key(KEY),
        .data_out(rx_data) // Output the final, decrypted data
    );
    
    // Assign the internal link to the output pin for monitoring
    assign serial_tx_out = internal_serial_link;

endmodule
