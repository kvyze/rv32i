ENTRY(_crt0)

MEMORY
{
    RAM (rwx) : ORIGIN = 0x00000000, LENGTH = 16K
    ROM (rx)  : ORIGIN = 0x00004000, LENGTH = 16K
}

_stack_top = ORIGIN(RAM) + LENGTH(RAM);

SECTIONS
{
    .text :
    {
        *(.start)
        *(.text*)
    } > ROM

    .data :
    {
        . = ALIGN(4);
        *(.data*)
        *(.sdata*)
        . = ALIGN(4);
    } > RAM AT > ROM

    _data_lma  = LOADADDR(.data);
    _data_vma  = ADDR(.data);
    _data_size = SIZEOF(.data);
}
