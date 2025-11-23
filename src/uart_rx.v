module uart_rx
   #(parameter DBIT = 8,    // Data bits
     S_TICK = 16)   // Samples per bit
   (
   input                clk,
   input                reset_n,
   input                s_tick,  // Tick at 16x baud rate
   input                rx,      // Serial data input
   output reg [DBIT-1:0]  rx_data, // Received data byte
   output reg             rx_done, // Pulses high when data is ready
   output reg             rx_frame_error // High if stop bit is invalid
   );

   localparam IDLE  = 0,
              START = 1,
              DATA  = 2,
              STOP  = 3;

   reg [1:0] state_reg, state_next;
   reg [3:0] s_reg, s_next; // Sample counter
   reg [$clog2(DBIT)-1:0] n_reg, n_next; // Data bit counter
   reg [DBIT-1:0] b_reg, b_next; // Shift register for received bits

   reg rx_d1, rx_d2; // For falling edge detection

   // Register stage for all state-holding elements
   always @(posedge clk, negedge reset_n)
   begin
      if (~reset_n)
      begin
         state_reg <= IDLE;
         s_reg     <= 0;
         n_reg     <= 0;
         b_reg     <= 0; // Initialize b_reg to 0
         rx_d1     <= 1'b1;
         rx_d2     <= 1'b1;
      end
      else
      begin
         state_reg <= state_next;
         s_reg     <= s_next;
         n_reg     <= n_next;
         b_reg     <= b_next;
         rx_d1     <= rx;
         rx_d2     <= rx_d1;
      end
   end

   // Next-state logic for FSM and other registers
   always @(*)
   begin
      // Default assignments to prevent latches
      state_next      = state_reg;
      s_next          = s_reg;
      n_next          = n_reg;
      b_next          = b_reg;
      rx_done         = 1'b0;
      rx_frame_error  = 1'b0;
      rx_data         = b_reg;

      case (state_reg)
         IDLE:
         begin
            // Wait for a falling edge (start bit)
            if (rx_d2 & ~rx_d1) // Catches falling edge
            begin
               s_next     = 0;
               state_next = START;
            end
         end

         START:
         begin
            if (s_tick)
               // Wait half a bit period to sample in the middle of the start bit
               if (s_reg == (S_TICK/2 - 1))
               begin
                  if (rx_d1 == 1'b0) // Check if it's still low (a valid start bit)
                  begin
                     s_next     = 0;
                     n_next     = 0;
                     state_next = DATA;
                  end
                  else // Glitch, not a real start bit
                     state_next = IDLE;
               end
               else
                  s_next = s_reg + 1;
         end

         DATA:
         begin
            if (s_tick)
               if (s_reg == (S_TICK - 1))
               begin
                  s_next = 0;
                  // Sample in the middle of the bit period, which was 8 ticks ago
                  b_next = {rx_d2, b_reg[DBIT-1:1]}; 
                  if (n_reg == (DBIT - 1))
                     state_next = STOP;
                  else
                     n_next = n_reg + 1;
               end
               else
                  s_next = s_reg + 1;
         end

         STOP:
         begin
            if (s_tick)
               if (s_reg == (S_TICK - 1))
               begin
                  // Stop bit should be high
                  if (rx_d1 == 1'b0)
                     rx_frame_error = 1'b1;
                  
                  rx_done    = 1'b1;
                  rx_data    = b_reg; // Final assignment of received data
                  state_next = IDLE;
               end
               else
                  s_next = s_reg + 1;
         end

         default:
            state_next = IDLE;

      endcase
   end

endmodule
