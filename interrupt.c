
/******************************************
 * intrrupt.c: 割り込み処理を行うルーチン *
 ******************************************/

#include "kernel.h"
#include "interrupt.h"

/* ディスクリプタテーブル */ 
desc_tbl idt_ptr;

/* pic の初期化 */
static void pic_init(void) {

  io_cli();

  /* ICW1 の初期化 */
  io_out8(MASTER_ICW, 0x11);
  io_out8(SLAVE_ICW, 0x11);

  /* ICW2 の初期化, 割り込み地点の設定 */
  io_out8(MASTER_OCW, INT_BASE);
  io_out8(SLAVE_OCW, INT_BASE | 0x08);

  /* ICW3 の初期化, 連結方法の設定 */
  io_out8(MASTER_OCW, 0x04);
  io_out8(SLAVE_OCW, 0x02);

  /* ICW4 の初期化, 追加命令, 8086モードを使用する */
  io_out8(MASTER_OCW, 0x01);
  io_out8(SLAVE_OCW, 0x01);

  /* 割り込みを防ぐ */
  io_out8(MASTER_OCW, 0xFB);
  io_out8(SLAVE_OCW, 0xFF);
}

/* コールゲートを作成 */
static void gate_make(gate_t *gate, unsigned short selector, void (*f)(),
                unsigned short count, unsigned short type, unsigned short dpl) {
  gate->offset_low = (unsigned short) f;
  gate->selector = selector;
  gate->count = count;
  gate->type = type | (dpl << 5);
  gate->offset_high = 0;
}

/* コールゲートをセット */
void gate_set(gate_t *gate, unsigned short sel, void (*f)(),
                  unsigned short count, unsigned short type) {
  gate_make(gate, sel, f, count, type, 0);
}

/* idt の初期化 */
void idt_init() {
  int i;
  gate_t *idt = (gate_t *) IDT_ADDR;
  pic_init();

  /* 割り込みディスクリプタの初期化 */
  for (i = 0; i < IDT_NUM; i++) {
    gate_make(idt + i, SEL_IDT, 0, 0, 0, 0);
  }

  /* idtをロード */
  idt_ptr.addr = (unsigned int) IDT_ADDR;
  idt_ptr.limit = (unsigned short) IDT_NUM;
  load_idtr(&idt_ptr);

  return;
}
