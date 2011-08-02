[BITS 32]
%include "base.inc.asm"
    global io_hlt, io_wait, io_out8, io_out16, io_out32, io_cli, io_sti, print

[SECTION .text]
[extern int_handler]

;;; 処理待ち (CPU節約)
io_hlt:
    mov edi, 10 * VIDEO_Y
    lea esi, [ds:msg]
    call print
    jmp fin
    hlt
    ret
    
;;; 処理待ち (CPU稼働)
io_wait:
    jmp $
    ret

;;; io_out8(int port, int data)
io_out8:
    mov edx, [esp + 4]          ; port
    mov al, byte [esp + 8]     ; data
    out dx, al
    ret
    
;;; io_out16(int port, int data)
io_out16:
    mov edx, [esp + 4]          ; port
    mov ax, word [esp + 8]     ; data
    out dx, ax
    ret

;;; io_out32(int port, int data)
io_out32:
    mov edx, [esp + 4]          ; port
    mov eax, dword [esp + 8]    ; data
    out dx, eax
    ret

;;; clear IF
io_cli:
    cli
    ret

;;; set IF
io_sti:
    sti
    ret

;;; print (char *string)

print:
    push eax
    push es
    mov eax, VideoSelector
    mov es, eax
.printf_loop:
    or al, al
    jz .printf_end
    mov al, byte [esi]
    mov byte [es:edi], al
    inc edi
    mov byte [es:edi], 0x06
    inc edi
    inc esi
    jmp .printf_loop
.printf_end:
    pop es
    pop eax
    ret

fin:
    hlt
    jmp fin

msg db "This is Func file call.", 0

;;; 割り込みルーチン void i0(void), i1(void), ....
%macro int_entry 1
i%1:
    push %1
    jmp int_caller
%endmacro

%assign i 0
%rep 256
    int_entry i
%assign i i + 1
%endrep

int_caller:
    push ds
    push es
    pusha
    
    call int_handler
    
    popa
    pop es
    pop ds
    iret
