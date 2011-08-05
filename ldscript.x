OUTPUT_FORMAT("coff-i386")
SEARCH_DIR("/usr/local/gnu/i686-coff/lib");
ENTRY (main)
SECTIONS {
  . = 0x00100000;
  .startup : {
    *(.startup)
  }
  .text . : {
    *(.text)
  }
  .data . : {
    *(.data)
    *(.rodata)
  }
  .bss SIZEOF(.data) + ADDR(.data) : {
    *(.bss)
    *(COMMON)
  }
}
