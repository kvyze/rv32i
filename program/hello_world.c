#define UART_TX (*(volatile int*)0x8000)
#define putchar(c) (UART_TX = c)

void putstr(const char* _Str)
{
    while (*_Str != '\0')
        putchar(*_Str++);
}

void main(void)
{
    putstr("Hello World!");

    while (1) {}
}
