
;;;;;;;;;;;;;;;;;;;;;;;;;
;; Initial Boot Loader ;;
;;;;;;;;;;;;;;;;;;;;;;;;;

[ORG 0x7C00]
[BITS 16]

%include "base.inc.asm"

;;;;;;;;;;;;;;;;;;
;; Main Routine ;;
;;;;;;;;;;;;;;;;;;
    
    jmp start

start:
    mov ax, cs
    mov ds, ax
    mov es, ax

    ;; 背景を点で埋める（デバック用）
    call print_bg

    ;; セクターの読込
    call read_sectors

    ;; カーネルスタート
    jmp KERNEL_START:0x0000

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; ***** Sub Routine ***** ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; 背景の出力
print_bg:
    mov ax, VIDEO_MEM
    mov es, ax
    mov ax, word [msg_bg]
    mov di, 0
    mov cx,  VIDEO_X * VIDEO_Y 
print_loop:
    mov word [es:di], ax
    add di, 2
    dec cx
    jnz print_loop
    ret

;;; セクターの読込
read_sectors:
    mov cx, RETRY_NUM
read_retry: 
    mov ax, KERNEL_START
    mov es, ax
    mov bx, 0                   ; es:bx にディスク内容を展開する
    mov ah, R_DISK
    mov al, SECTORS
    mov ch, CYLINDER_NUM
    mov cl, SECTOR_NUM
    mov dh, HEAD_NUM
    mov dl, DRIVE_NUM

    int 0x13
    jnc read_end
    
    ;; 失敗時にリトライを行う
    dec cx
    jz read_false
    jmp read_retry    
read_end:       
    ret

;;; 読込失敗
read_false:
    mov si, msg_false
    mov di, 0
    call printf
    jmp fin

;;; 文字列の出力
printf:
    push ax
    push es
    mov ax, VIDEO_MEM
    mov es, ax
    mov al, byte [si]
printf_loop:    
    mov al, byte [si]
    mov byte [es:di], al
    inc di
    inc si
    mov byte [es:di], 0x06
    inc di
    or al, al                  ; al が 0 かどうかを調べる
    jz printf_end
    jmp printf_loop
printf_end:
    pop es
    pop ax
    ret

fin:
    hlt
    jmp fin

;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; ***** Data Area ***** ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;

msg_bg db ".", 0x06
msg_false db "READ ERROR !!!", 0
times 510 - ($ - $$) db 0
dw 0xAA55
