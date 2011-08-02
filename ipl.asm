
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
    jmp BOOT_START_SEG:0x0200

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
    mov ax, BOOT_START_SEG
    mov es, ax
    mov si, RETRY_NUM
    mov ch, CYLINDER_NUM
    mov dh, HEAD_NUM
    mov cl, SECTOR_NUM
.read_loop:
    mov ah, R_DISK
    mov al, SECTORS
    mov bx, 0                   ; es:bx にディスク内容を展開する
    mov dl, DRIVE_NUM

    int 0x13
    jnc .read_next
    
    ;; 失敗時にリトライを行う
    jmp read_false
    dec si
    jz read_false
    jmp .read_loop    
.read_next:
    mov ax, es
    add ax, 0x0020              ; 512B 進める
    mov es, ax
    inc cl
    cmp cl, 18
    jbe .read_loop
    mov cl, 1
    inc dh                      ; ヘッド番号をインクリメント
    cmp dh, 2                   ; ヘッドが1の場合は繰り返し
    jb .read_loop
    mov dh, 0
    inc ch
    cmp ch, CYLINDER_MAX
    jb .read_loop
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
