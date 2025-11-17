`timescale 1ns / 1ps

module tb_uart_tx;

    // Parametri pentru test
    parameter CLK_PERIOD_NS = 10;   // Ceas de 100MHz (perioada de 10ns)
    parameter DBIT = 8;
    parameter SB_TICK = 16;
    parameter DATA_TO_SEND = 8'h41; // Trimitem litera 'A' (cod ASCII 0x41)

    // Semnalele de test (REG pentru intrări, WIRE pentru ieșiri)
    reg clk;
    reg reset_n;
    reg tx_start;
    reg s_tick;
    reg [DBIT-1:0] tx_din;

    wire tx_done_tick;
    wire tx;

    // 1. Instanțierea modulului pe care îl testăm (Unit Under Test - UUT)
    uart_tx #(
        .DBIT(DBIT),
        .SB_TICK(SB_TICK)
    )
    UUT (
        .clk(clk),
        .reset_n(reset_n),
        .tx_start(tx_start),
        .s_tick(s_tick),         // Îl vom ține pe '1' (mereu activ)
        .tx_din(tx_din),
        
        .tx_done_tick(tx_done_tick),
        .tx(tx)
    );

    // 2. Generatorul de ceas (Clock Generator)
    // Va rula la infinit, creând un ceas de 100MHz
    always begin
        clk = 0; #(CLK_PERIOD_NS / 2);
        clk = 1; #(CLK_PERIOD_NS / 2);
    end

    // 3. Scenariul de Test (Test Scenario)
    initial begin
        // Inițializare
        $display("Incepem testul...");
        reset_n = 0;    // Ținem în reset
        tx_start = 0;
        s_tick = 1'b1;  // Presupunem că tick-ul e mereu activ (simplificare)
        tx_din = 0;
        
        // Eliberăm din reset după 100 ns
        #(100);
        reset_n = 1;
        
        // Așteptăm un ciclu de ceas
        @(posedge clk);
        
        // Trimitem comanda de start
        $display("Trimitem comanda de start pentru 0x%h...", DATA_TO_SEND);
        tx_din = DATA_TO_SEND;
        tx_start = 1;
        
        // Așteptăm un ciclu de ceas
        @(posedge clk);
        
        // Oprim semnalul de start
        tx_start = 0;
        
        // Așteptăm până când modulul ne anunță că a terminat
        $display("Asteptam tx_done_tick...");
        wait (tx_done_tick == 1);
        
        $display("Transmisie finalizata! Oprim simularea.");
        
        // Oprim simularea
        $finish;
    end

endmodule
