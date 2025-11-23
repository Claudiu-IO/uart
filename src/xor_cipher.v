module xor_cipher
   #(parameter WIDTH = 8)
   (
   input  [WIDTH-1:0] data_in,
   input  [WIDTH-1:0] key,
   output [WIDTH-1:0] data_out
   );

   // XOR the input data with the key. This is a purely combinational circuit.
   assign data_out = data_in ^ key;

endmodule
