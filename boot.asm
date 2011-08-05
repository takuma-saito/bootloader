
;;;;;;;;;;;;;;;;;;;
;; Kernel Start  ;;
;;;;;;;;;;;;;;;;;;;

[ORG 0x10200]
[BITS 16]

%include "config.asm"
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

    ;; 画面描画モードの移行 （時が来たら使用する）
    ;; call change_screen_mode

    ;; グローバルディスクリプタを設定
    cli
    lgdt [gdtr]

    ;; プロテクトモードに移行
    call change_PMmode
    jmp to_PM_Start

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; ***** Sub Routines 16Bit ***** ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; ipt.asm と重複しているコード require Fix !
printf_16:
    push ax
    push es
    mov ax, VIDEO_MEM
    mov es, ax
    mov al, byte [si]
.printf_loop:    
    mov al, byte [si]
    mov byte [es:di], al
    inc di
    inc si
    mov byte [es:di], 0x06
    inc di
    or al, al                  ; al が 0 かどうかを調べる
    jz .printf_end
    jmp .printf_loop
.printf_end:
    pop es
    pop ax
    ret

;;; プロテクテッドモードに移行
change_PMmode:    
    mov eax, cr0
    or eax, 1
    mov cr0, eax
    ret

;;; PM_Start に移行
to_PM_Start:
    jmp $ + 2
    nop
    nop    
    jmp dword SysCodeSelector:PM_Start

;;; スクリーンモードを変更
change_screen_mode:
    ;; 情報を格納するメモリアドレスを指定
    mov ax, 0x9000
    mov es, ax
    mov di, 0
    call get_screen_info
    call get_screen_mode
    jmp fin
    call set_screen_mode
    ret

get_screen_info:
    mov ax, 0x4f00
    int 0x10
    cmp ax, 0x004f
    jnz disp_error
    ret

get_screen_mode:
    mov ax, 0x4f01
    mov cx, VIDEO_MODE
    int 0x10
    cmp ax, 0x004f
    jnz disp_error
    ret

set_screen_mode:
    mov bx, VIDEO_MODE
    mov ax, 0x4f02
    int 0x10
    ret

disp_error:
    mov di, 0
    lea si, [ds:disp_error_msg]
    call printf_16
    jmp fin

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

    ;; A20Gateを設定, 1Mバイト以上読み込めるようにする
    call a20_enable

    ;; カーネルを KERN_START 部分へ読み込む
    call load_kern
    
    mov edi, 0
    lea esi, [ds:hello]
    call printf_32

    ;; C言語のプログラムへ飛ぶ
    jmp dword KernSelector:0x0000

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; ***** Sub Routine 32Bit ***** ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; メッセージを出力する (32bit)
printf_32:
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

;;; A20ゲートを設定
a20_enable:    
    call waitkbdout
    mov al, 0xD1
    out 0x64, al
    call waitkbdout
    mov al, 0xDF
    out 0x60, al
    call waitkbdout
    mov al, 0xFF
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

;;; 終了
fin:
    hlt
    jmp fin

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
disp_error_msg db "Error occured in proccessing display mode.", 0
times 1024 - ($ - $$) db 0
