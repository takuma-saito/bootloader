#include "kernel.h"
#include "interrupt.h"
#include "gate.h"

desc_tbl idt_ptr;
gate_t idt[IDT_NUM];

/* pic の初期化 */
static void pic_init() {

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

/* IDTコールゲートの作成 */
void idt_set_gate(int i, unsigned short sel, void (*f)(),
                  unsigned short count, unsigned short type) {
  gate_make(idt + i, sel, f, count, type, 0);
}

/* idt の初期化 */
void idt_init() {
  int i;
  idt = (gate_t *) IDT_ADDR;
  pic_init();

  /* 割り込みディスクリプタの初期化 */
  for (i = 0; i < IDT_NUM; i++) {
    idt_set_gate(i, SEL_IDT, int_vector[i], 0, TYPE_INT_GATE, 0);
  }
  idt_ptr.limit = IDTNUM * sizeof(gate_t);
  idt_ptr.base = IDT_ADDR_BASE;
}

    
