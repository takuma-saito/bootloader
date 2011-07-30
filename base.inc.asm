
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; CONST, MACRO, BASE FUNCTION ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; 画像処理
%define VIDEO_MEM   0xB800
%define VIDEO_X     25
%define VIDEO_Y     80

;;; ディスク処理
%define KERNEL_START    0x1000  ; メモリへ書き込まれるセグメント
%define R_DISK          0x02    ; 読込のみ
%define W_DISK          0x03    ; 書込のみ
%define S_DISK          0x0c    ; シーク時
%define SECTORS         7       ; 読み込むセクターの数
%define CYLINDER_NUM    0       ; シリンダー番号 (1 ~ 80)
%define SECTOR_NUM      2       ; セクター番号 (1 ~ 18)
%define HEAD_NUM        0       ; ヘッダ番号 (固定)
%define DRIVE_NUM       0       ; ドライブ番号（固定)
%define RETRY_NUM       5       ; 読込失敗時のリトライ回数

;;; グローバルディスクリプタ
SysCodeSelector equ 0x08
SysDataSelector equ 0x10
VideoSelector equ 0x18
