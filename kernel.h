#ifndef __KERNEL_H
#define __KERNEL_H

/* 各セレクタを定義 */
#define SEL_DATA 0x08
#define SEL_CODE 0x10
#define SEL_VIDEO 0x18
#define SEL_KERN 0x20
#define SEL_IDT 0x28

/* ディスクリプタテーブルが読み込まれるアドレス */
#define GDT_ADDR 0x00270000
#define IDT_ADDR 0x0026f800
#define SEG_NUM 8192          /* segment descriptor の limit 最大値 */
#define IDT_NUM 256           /* interrupt descriptor の limit 最大値 */
#define SEG_NUM_HEX 0xffff
#define IDT_NUM_HEX 0x07ff

/* func.asm で定義 */
void lidt(void);
void io_hlt(void);
void io_wait(void);
void io_cli();
void io_sti();
void io_stihlt();
void load_gdtr();
void load_idtr();
void io_out8(int port, int data);
void io_out16(int port, int data);
void io_out32(int port, int data);
void print(char *string, int y, int x);
void test(void);
void fin(void);

/* セグメントディスクリプタ */
typedef struct {
  unsigned short limit_low;                  /* limit 0 ~ 15 */
  unsigned short addr_low;                   /* base 0 ~ 15 */
  unsigned char addr_mid;                    /* base 16 ~ 23 */
  unsigned char access_right;                /* P, DPL, S, Type */
  unsigned char limit_high;                  /* G, D, 0, AVL, limit 16 ~ 19 */
  unsigned char addr_high;                   /* base 24 ~ 31 */
} seg_t;

/* ディスクリプタテーブル */
typedef struct {
  unsigned short limit;         /* limit 0 ~ 16 */
  unsigned int addr;           /* base address */
} desc_tbl;

/* コールゲート */
typedef struct gate_tag {
  unsigned short offset_low;    /* ハンドラのオフセット 0 ~ 15 */
  unsigned short selector;      /* ハンドラのセレクタ値 */
  unsigned char count;          /* 引数の個数 */
  unsigned char access_right;           /* P, DPL, 0, D, 1, 1, 0 */
  unsigned short offset_high;   /* ハンドラのオフセット 16 ~ 31 */
} gate_t;

/* セグメントをセットする */
void seg_set (seg_t *seg, unsigned int sel, unsigned int limit,
              int addr, int ar);

/* GDT を初期化する */
void gdt_init();

/* IDT を初期化する */
void idt_init();
  
#endif //__KERNEL_H
