#include <stdio.h>
#include <stdint.h>
#include <unistd.h>

// Mock UART pins
uint8_t RxD = 1;
uint8_t TxD = 1;

// UART registers
uint8_t DBUS = 0x00;
uint8_t ADDR = 0x00;
uint8_t R_W = 0;
uint8_t SCI_sel = 0;
uint8_t IRQ = 0;

// UART function prototypes
void UART_write(uint8_t address, uint8_t data);
uint8_t UART_read(uint8_t address);
void UART_process();

// Clock simulation
void delay_ns(int ns) {
    usleep(ns / 1000);   // crude simulation
}

int main() {

    // Reset values (equivalent to initial VHDL signals)
    RxD = 1;
    TxD = 1;
    DBUS = 0;
    ADDR = 0;
    R_W = 0;
    SCI_sel = 0;

    printf("Starting UART C-based simulation...\n");

    // Write a byte (TX test)
    SCI_sel = 1;
    R_W = 1;        // write
    ADDR = 0x01;    // TX buffer address
    DBUS = 0xA5;    // test byte

    UART_write(ADDR, DBUS);

    // Allow UART to process (fake clock cycles)
    for (int i = 0; i < 20; i++) {
        UART_process();
        delay_ns(5000);
    }

    // Read a byte (RX test)
    SCI_sel = 1;
    R_W = 0;        // read
    ADDR = 0x02;    // RX buffer

    uint8_t rx_byte = UART_read(ADDR);
    printf("Received Byte: 0x%02X\n", rx_byte);

    return 0;
}

// UART write simulation
void UART_write(uint8_t address, uint8_t data) {
    printf("UART WRITE -> ADDR: %d  DATA: 0x%02X\n", address, data);

    if (address == 0x01) {
        TxD = data;  // mock TX
        IRQ = 1;
    }
}

// UART read simulation
uint8_t UART_read(uint8_t address) {
    printf("UART READ  -> ADDR: %d\n", address);

    if (address == 0x02) {
        IRQ = 0;
        return RxD;   // mock RX
    }

    return 0x00;
}

// UART background process
void UART_process() {
    // Fake data transfer RX = TX
    RxD = TxD;
}
