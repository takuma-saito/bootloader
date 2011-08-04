OUTPUT_FORMAT("coff-i386")
SEARCH_DIR("/usr/local/gnu/i686-coff/lib");
ENTRY (kernel_main)
SECTIONS {
  . = 0x00100000;
  .text . : {
    *(.init)
    *(.text)
    *(.fini)
  }
  .data . : {
    *(.data)
    *(.rodata)
  }
  .bss SIZEOF(.data) + ADDR(.data) : {
    *(.bss)
    *(COMMON)
  }
  .stab  0 (NOLOAD) :
  {
    [ .stab ]
  }
  .stabstr  0 (NOLOAD) :
  {
    [ .stabstr ]
  }
}
