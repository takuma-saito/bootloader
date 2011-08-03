#ifndef __KERNEL_H
#define __KERNEL_H

/* 各セレクタを定義 */
#define SEL_DATA 0x08
#define SEL_CODE 0x10
#define SEL_VIDEO 0x18
#define SEL_IDT 0x20

/* ディスクリプタテーブルが読み込まれるアドレス */
#define GDT_ADDR 0x0026f800
#define IDT_ADDR 0x00270000
#define SEG_NUM 8192          /* segment descriptor の limit 最大値 */
#define IDT_NUM 256           /* segment descriptor の limit 最大値 */
#define SEG_NUM_HEX 0xffff


/* ディスクリプタのセグメント属性を表す */
#define TYPE_CODE 0x9A
#define TYPE_DATA 0x92
#define TYPE_STACK 0x96
#define TYPE_LDT 0x82
#define TYPE_TSS 0x89
#define TYPE_TSS_BUSY 0x8b
#define TYPE_CALL_GATE 0x84
#define TYPE_INT_GATE 0x8e
#define TYPE_TRAP_GATE 0x8f
#define TYPE_TASK_GATE 0x85

/* func.asm で定義 */
void lidt(void);
void io_hlt(void);
void io_wait(void);
void io_cli();
void io_sti();
void load_gdtr();
void load_idtr();
void io_out8(int port, int data);
void io_out16(int port, int data);
void io_out32(int port, int data);
void print(char *);

/* セグメントディスクリプタ */
typedef struct {
  unsigned short limit_low;                  /* limit 0 ~ 15 */
  unsigned short addr_low;                   /* base 0 ~ 15 */
  unsigned char addr_mid;                    /* base 16 ~ 23 */
  unsigned char segtype;                        /* P, DPL, S, Type */
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
  unsigned char type;           /* P, DPL, 0, D, 1, 1, 0 */
  unsigned short offset_high;   /* ハンドラのオフセット 16 ~ 31 */
} gate_t;

/* セグメントをセットする */
void seg_set(unsigned short sel, unsigned int limit, unsigned int addr,
             unsigned char segtype, unsigned char dpl);

/* セグメントをロードする */
void gdt_init();

  
#endif //__KERNEL_H
