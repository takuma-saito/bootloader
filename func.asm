[BITS 32]
%include "config.asm"
    global io_out8, io_out16, io_out32, io_in8, io_in16, io_in32
    global io_cli, io_sti, io_stihlt, io_hlt, io_wait,
    global load_gdtr, load_idtr
    global test, fin, print
    global asm_int_keybd

    ;; void i0(void), i1(void) ... void255(void) の宣言
;; %macro int_global 1
;;     global i%1
;; %endmacro

;; %assign i 0
;; %rep 256
;;     int_global i
;; %assign i i + 1
;; %endrep

;;; スタートアップルーチン
[SECTION .startup]
[EXTERN main]
_start:
    jmp main

[SECTION .text]
[EXTERN int_handler]

;;; 処理待ち (CPU節約)
io_hlt:
    hlt
    ret

;;; 処理待ち (CPU稼働)
io_wait:
    jmp $
    ret

;;; GDT をロード
;;; load_gdtr (int limit, int addr)
load_gdtr:
    push ebp
    mov ebp, esp
    mov ax, [ebp + 8]           ; limit
    mov [esp + 10], ax
    lgdt [esp + 10]
    pop ebp
    ret

;;; IDT をロード
;;; looad_idtr (desc_tbl *gdt)
load_idtr:
    push ebp
    mov ebp, esp
    mov eax, [ebp + 8]
    mov [esp + 10], ax
    lidt [esp + 10]
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

;;; io_in8(int port)
io_in8:
    mov edx, [esp + 4]
    xor eax, eax
    mov dl, al
    ret

;;; io_in16(int port)
io_in16:
    mov edx, [esp + 4]
    xor eax, eax
    mov dx, ax
    ret

;;; io_in32(int port)
io_in32:
    mov edx, [esp + 4]
    xor eax, eax
    mov edx, eax
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

;;; print (char *string, int VIDEO_Y, int VIDEO_X)
print:
    push ebp
    mov ebp, esp
    push es
    push edi
    mov eax, VideoSelector
    mov es, eax
    mov esi, [ebp + 8]
    mov eax, [ebp + 12]         ; video y
    mov ecx, [ebp + 16]         ; video x
    imul eax, VIDEO_Y
    add eax, ecx
    imul eax, 2
    mov edi, eax
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
    pop ebp
    ret

fin:
    hlt
    jmp fin

;;; 割り込みルーチン void i0(void), i1(void), ....
;; %macro int_entry 1
;; i%1:
;;     push %1
;;     jmp int_handler_asm
;; %endmacro

;; %assign i 0
;; %rep 256
;;     int_entry i
;; %assign i i + 1
;; %endrep

;; int_handler_asm:
;;     push ds
;;     push es
;;     pusha
    
;;     call int_handler
    
;;     popa
;;     pop es
;;     pop ds
;;     iret

;;; 割り込み処理ルーチン
[extern int_keybd]
asm_int_keybd:
    push es
    push ds
    pushad

    mov eax, esp
    push eax
    mov ax, ss
    mov es, ax
    mov es, ax
    call int_keybd
    pop eax
    
    popad
    pop ds
    pop es
    iret

[SECTION .data]
msg db "This is Func file call.", 0
test_msg db "This is Test Message call.", 0

    
