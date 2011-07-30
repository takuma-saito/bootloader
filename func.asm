[BITS 32]
%include "base.inc.asm"
    global io_hlt

[SECTION .text]

io_hlt:
    hlt
    ret

