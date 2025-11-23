# 🛰️ UART-Vault: Secure Serial Communication in Hardware

This project implements a secure UART (Universal Asynchronous Receiver-Transmitter) communication system in Verilog. It addresses the need for privacy in serial data transmission by integrating a lightweight XOR encryption layer directly into the hardware.

The design features a complete UART loopback, where data is encrypted before being sent by the UART transmitter and then decrypted upon reception by the UART receiver. This entire process is handled by synthesizable Verilog, making it suitable for FPGA implementations.

## ✨ How It Works:

The security model is elegant in its simplicity, using a dynamic XOR cipher.

1.  **A Secret Key is Forged:** A C program (`keygen.c`) acts as our keymaker, generating a unique, random key and writing it to a Verilog header. Every time you run it, a new secret is created.

2.  **Data is Encrypted:** Before the UART transmitter sends the data down the wire, our `xor_cipher` module instantly encrypts it using the secret key.

3.  **Secure Transmission:** The encrypted data travels across the wire. To an outside observer, it looks like noise.

4.  **Data is Decrypted:** The UART receiver picks up the scrambled data, and the same `xor_cipher` module, armed with the same secret key, instantly decrypts it, restoring the original message.

## 🚀 Features

*   **Standard UART Protocol:** A synthesizable 8-N-1 UART transmitter and receiver.
*   **Lightweight Encryption:** A low-resource XOR cipher provides a fast and effective privacy layer.
*   **Dynamic Key Generation:** Easily generate a new secret key for each build or session.
*   **Ready for Simulation:** Includes a self-verifying testbench to demonstrate the encrypted loopback functionality.

## 🛠️ Demonstrating the Secure Loopback

See the security in action by running the included simulation.

### Step 1: Forge the Key

First, you must create the secret key. You'll need `gcc` or another C compiler.

```sh
# Compile the keymaker
gcc keygen.c -o keygen

# Run it to generate the secret key file (src/key_config.vh)
./keygen
```

### Step 2: Launch the Simulation in Vivado

1.  **Set up the Project:** Add all `.v` files from the `src/` and `sim/` directories to your Vivado simulation sources (`sim_1`).
2.  **Assign the Leader:** Set `tb_uart_loopback.v` as the top-level simulation module.
3.  **Run the Simulation:** Click `Run Simulation`.

## 3. Verify the Mission

The testbench will transmit data, which is encrypted, looped back, and decrypted. You will see messages in the Tcl Console confirming that the data received perfectly matches the data sent, proving the secure communication loop is working.

A successful mission looks like this:
```
Testbench: SUCCESS! Sent 0xa5 and received 0xa5.
Testbench: SUCCESS! Sent 0x3c and received 0x3c.
```
This confirms that even after being scrambled for transmission, your data arrived safely.
