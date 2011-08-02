
;;;;;;;;;;;;;;;;;;;
;; Kernel Start  ;;
;;;;;;;;;;;;;;;;;;;

[ORG 0x10200]
[BITS 16]

%include "base.inc.asm"
%define GDT_LIMIT gdt_end - gdt - 1
%define GDT_BASE gdt

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; ***** Main Routine ***** ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

start:
    cld
    mov ax, cs                  ; cs には 0x1000 が入っている
    mov ds, ax
    xor ax, ax
    mov ss, ax

    ;; グローバルディスクリプタを設定
    cli
    lgdt [gdtr]

    ;; プロテクトモードに移行
    mov eax, cr0
    or eax, 1
    mov cr0, eax

    ;; A20Gateを設定, 1Mバイト以上読み込めるようにする
    call open_a20

    ;; magic words
    jmp $ + 2
    nop
    nop

    jmp dword SysCodeSelector:PM_Start

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; ***** Main Routine (Protected Mode)  ***** ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

[BITS 32]

PM_Start:
    mov bx, SysDataSelector
    mov ss, bx
    mov ds, bx
    mov es, bx
    mov fs, bx
    mov gs, bx

    ;; カーネルを KERN_START 部分へ読み込む
    call load_kern
    
    mov edi, 0
    lea esi, [ds:hello]
    call print

    ;; C言語のプログラムへ飛ぶ
    jmp dword KernSelector:0x0000

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; ***** Sub Routine ***** ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    
;;; メッセージを出力する
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

;;; A20ゲートを設定
open_a20:    
    call waitkbdout
    mov al, 0xD1
    out 0x64, al
    call waitkbdout
    mov al, 0xDF
    out 0x64, al
    call waitkbdout
    ret

waitkbdout:
    in al, 0x64
    and al, 0x02
    jnz waitkbdout
    ret

load_kern:
    mov esi, 0x10600
    mov edi, KERN_START
    mov ecx, 512 * 18 * 2 * CYLINDER_MAX
    rep movsb
    ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; ***** Data Area ***** ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; Global Descriptor Table

gdtr:
    dw GDT_LIMIT                ; GDTのLIMIT
    dd GDT_BASE                 ; GDTのベースアドレス

gdt:
    dw 0                        ; LIMIT 0 ~ 15bit
    dw 0                        ; ベースアドレス 0 ~ 15 bit
    db 0                        ; ベースアドレス 16 ~ 23 bit
    db 0                        ; TYPE
    db 0                        ; LIMIT 16 ~ 19 bit + FLAG
    db 0                        ; ベースアドレスの 24 ~ 31 bit

;;; SysCodeSelector
    dw 0xFFFF                   ; limit 1Mバイト
    dw 0x0000                   ; ベースアドレス 0 ~ 15 bit
    db 0x00                     ; ベースアドレス 16 ~ 23 bit
    db 0x9A                     ; P:1, DPL:0, Code, non-conforming, readable
    db 0xCF                     ; G:1, D:1, limit 16 ~ 19 bit:0xF
    db 0x00                     ; base 24 ~ 31 bit

;;; SysDataSelector
    dw 0xFFFF                   ; limit 1Mバイト
    dw 0x0000                   ; base 0 ~ 15bit
    db 0x00                     ; base 16 ~ 23bit
    db 0x92                     ; P:1, DPL:0, data, expand-up, writable
    db 0xCF                     ; G:1, D:1, limit 16 ~ 19 bit:0xF Gフラグが1なので1Mバイト使用できる
    db 0x00                     ; base 24 ~ 31 bit    
    
;;; VideoSelector
    dw 0xFFFF                   ; limit 0xFFFF
    dw 0x8000                   ; base 0 ~ 15 bit
    db 0x0B                     ; base 16 ~ 23 bit
    db 0x92                     ; P:1, DPL:0, data, expand-up, writeable
    db 0x40                     ; G:1, D:1, limit 16 ~ 19 bit:0
    db 0x00                     ; base 24 ~ 31 bit

;;; KernSelector
    dw 0xFFFF                   ; limit 1Mバイト
    dw 0x0000                   ; ベースアドレス 0 ~ 15 bit
    db 0x10                     ; ベースアドレス 16 ~ 23 bit
    db 0x9A                     ; P:1, DPL:0, Code, non-conforming, readable
    db 0xCF                     ; G:1, D:1, limit 16 ~ 19 bit:0xF
    db 0x00                     ; base 24 ~ 31 bit
    
gdt_end:    

hello db "Hello World!!", 0
times 1024 - ($ - $$) db 0
