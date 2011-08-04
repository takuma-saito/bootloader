[BITS 32]
%include "base.inc.asm"
    global io_hlt, io_wait, io_out8, io_out16, io_out32
    global io_cli, io_sti, io_stihlt, print
    global load_gdtr, load_idtr, test

    ;; void i0(void), i1(void) ... void255(void) の宣言
%macro int_global 1
    global i%1
%endmacro

%assign i 0
%rep 256
    int_global i
%assign i i + 1
%endrep

[SECTION .text]
[extern int_handler]

;;; 処理待ち (CPU節約)
io_hlt:
    hlt
    ret

test:
    mov eax, test_msg
    push eax
    call print
    jmp fin
    ret


;;; 処理待ち (CPU稼働)
io_wait:
    jmp $
    ret

;;; GDT をロード
;;; load_gdtr (desc_tbl *gdt)
load_gdtr:
    push ebp
    mov ebp, esp
    mov eax, [bp + 4]
    lgdt [eax]
    pop ebp
    ret

;;; IDT をロード
;;; looad_idtr (desc_tbl *gdt)
load_idtr:
    push ebp
    mov ebp, esp
    mov eax, [bp + 4]
    lidt [eax]
    pop ebp
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

;;; set IF & halt
io_stihlt:
    sti
    hlt
    ret

;;; print (char *string)
print:
    push ebp
    mov ebp, esp
    push eax
    push es
    push edi
    mov eax, VideoSelector
    mov es, eax
    mov esi, [ebp + 8]
    mov edi, 10 * VIDEO_Y
.printf_loop:
    or al, al
    jz .printf_end
    mov al, byte [ds:esi]
    mov byte [es:edi], al
    inc edi
    mov byte [es:edi], 0x06
    inc edi
    inc esi
    jmp .printf_loop
.printf_end:
    pop edi
    pop es
    pop eax
    pop ebp
    ret

fin:
    hlt
    jmp fin

;;; 割り込みルーチン void i0(void), i1(void), ....
%macro int_entry 1
i%1:
    push %1
    jmp int_handler_asm
%endmacro

%assign i 0
%rep 256
    int_entry i
%assign i i + 1
%endrep

int_handler_asm:
    push ds
    push es
    pusha
    
    call int_handler
    
    popa
    pop es
    pop ds
    iret

msg db "This is Func file call.", 0
test_msg db "This is Test Message call.", 0

    
