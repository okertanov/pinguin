/*
    @see http://balau82.wordpress.com/2010/02/28/hello-world-for-bare-metal-arm-using-qemu/
*/

volatile unsigned int * const UART0DR = (unsigned int *)0x101f1000;

void print_uart0(const char *s) {
    while(*s != '\0') { /* Loop until end of string */
        *UART0DR = (unsigned int)(*s); /* Transmit char */
        s++; /* Next char */
    }
}

void c_entry() {
    print_uart0("Hello world!\n");
}

