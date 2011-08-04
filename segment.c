/**************************************************
 * segment.c - セグメントディスクリプタ関係を定義 *
 **************************************************/

#include "kernel.h"

/* ディスクリプタテーブル */ 
desc_tbl gdt_ptr;

#define SEG_32 0x80             /* segment が 32 bit の場合 */
#define SEG_16 0x40             /* segment が 16 bit の場合 */o

/* セグメントを作る */
static void seg_make(seg_t *seg, unsigned int limit, int addr, int ar) {
  if (limit > 0xfffff) {
    ar |= 0x8000;                /* G flag on */
    limit /= 0x1000;                  /* 4kB分減らす */
  }
  seg->limit_low = limit & 0xffff;
  seg->addr_low = addr & 0xffff;
  seg->addr_mid = (addr >> 16) & 0xff;
  seg->addr_high = (addr >> 24) & 0xff;
  seg->access_right = ar & 0xff;
  seg->limit_high = ((limit >> 16) & 0x0f) | ((ar >> 8) & 0xf0);
  return;
}

void seg_set (seg_t *seg, unsigned int sel, unsigned int limit,
              int addr, int ar) {
  seg_make(&seg[sel >> 3], limit, addr, ar);
}

void gdt_init() {
  int i;
  seg_t *gdt = (seg_t *) GDT_ADDR;
  
  /* GDTの初期化 */
  for (i = 0; i < SEG_NUM; i++) {
    seg_make(gdt + i, 0, 0, 0);
  }
  
  /* データセグメント */
  seg_set(gdt, SEL_DATA, 0xffffffff, 0, 0x4092);
  
  /* コードセグメント */
  seg_set(gdt, SEL_CODE, 0xffffffff, 0, 0x409a);

  /* ビデオセグメント */
  seg_set(gdt, SEL_VIDEO, 0xffff, 0xB8000, 0x4092);

  /* カーネル実行セグメント */
  seg_set(gdt, SEL_KERN, 0xfffff, 0x00100000, 0x409a);
  
  /* GDTをロード */
  load_gdtr(SEG_NUM_HEX, GDT_ADDR);

  return;
}
