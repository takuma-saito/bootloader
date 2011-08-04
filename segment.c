/**************************************************
 * segment.c - セグメントディスクリプタ関係を定義 *
 **************************************************/

#include "kernel.h"

/* ディスクリプタテーブル */ 
desc_tbl gdt_ptr;

#define SEG_32 0x80             /* segment が 32 bit の場合 */
#define SEG_16 0x40             /* segment が 16 bit の場合 */o

/* セグメントを作る */
static void seg_make(seg_t *seg, unsigned int limit, unsigned int addr,
             unsigned char segtype, unsigned char dpl) {
  if (limit > 0xfffff) {
    segtype |= 0x8000;                /* G flag on */
    limit /= 0x1000;                  /* 4kB分減らす */
  }
  seg->limit_low = limit & 0xffff;
  seg->addr_low = addr & 0xffff;
  seg->addr_mid = (addr >> 16) & 0xff;
  seg->addr_high = (addr >> 24) & 0xff;
  seg->segtype = (segtype & 0xff) | (dpl << 5);
  seg->limit_high = ((limit >> 16) & 0x0f) | SEG_32;
  return;
}

/* セグメントをセットする */
void seg_set(seg_t *gdt, unsigned short sel, unsigned int limit, unsigned int addr,
             unsigned char segtype, unsigned char dpl) {
  seg_make(&gdt[sel >> 3], limit, addr, segtype, dpl);
}

void gdt_init() {
  int i;
  seg_t *gdt = (seg_t *) GDT_ADDR;
  
  /* GDTの初期化 */
  for (i = 0; i < SEG_NUM; i++) {
    seg_make(gdt + i, 0, 0, 0, 0);
  }
  
  /* データセグメント */
  seg_set(gdt, SEL_DATA, 0xffffffff, 0, TYPE_DATA, 0);
  
  /* コードセグメント */
  seg_set(gdt, SEL_CODE, 0x00100000, 0, TYPE_CODE, 0);
  
  /* GDTをロード */
  gdt_ptr.addr = (unsigned int) GDT_ADDR;
  gdt_ptr.limit = (unsigned short) SEG_NUM_HEX;
  load_gdtr(&gdt_ptr);

  return;
}
