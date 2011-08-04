
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; CONST, MACRO, BASE FUNCTION ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; 画像処理
%define VIDEO_MEM   0xB800
%define VIDEO_X     25
%define VIDEO_Y     80

;;; ディスク処理
%define BOOT_START_SEG  0x1000  ; ブートセグメント
%define BOOT_START      0x10000 ; ブートアドレス
%define KERN_START      0x00100000 ; カーネルスタート
%define R_DISK          0x02    ; 読込のみ
%define W_DISK          0x03    ; 書込のみ
%define S_DISK          0x0c    ; シーク時
%define SECTORS         1       ; 読み込むセクターの数
%define CYLINDER_NUM    0       ; シリンダー番号 (0 ~ 79)
%define CYLINDER_MAX    10      ; シリンダー番号 (0 ~ 79) この値変更に注意!
%define SECTOR_NUM      1       ; セクター番号 (1 ~ 18)
%define SECTOR_MAX      18      ; セクター番号 (1 ~ 18)
%define HEAD_NUM        0       ; ヘッド番号 
%define DRIVE_NUM       0       ; ドライブ番号（固定)
%define RETRY_NUM       5       ; 読込失敗時のリトライ回数

;;; グローバルディスクリプタ
%define SysCodeSelector 0x08
%define SysDataSelector 0x10
%define VideoSelector 0x18
%define KernSelector 0x20
    
