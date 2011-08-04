
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
static void gate_make(gate_t *gate, int offset, int selector, int ar) {
  gate->offset_low = offset & 0xffff;
  gate->selector = selector;
  gate->count = (ar >> 8) & 0xff;
  gate->access_right = ar & 0xff;
  gate->offset_high = (offset >> 16) & 0xffff;
  return;
}

void int_keybd(int *esp) {
  print("This is Interrupt Message.", 3, 0);
  return;
}

/* idt の初期化 */
void idt_init() {
  int i;
  gate_t *idt = (gate_t *) IDT_ADDR;
  pic_init();

  /* 割り込みディスクリプタの初期化 */
  for (i = 0; i < IDT_NUM; i++) {
    gate_make(idt + i, 0, 0, 0);
  }

  /* キーボード割り込み */
  gate_make(idt + INT_KEYBD, (int) asm_int_keybd, SEL_CODE, TYPE_INT_GATE);

  /* idtをロード */
  load_idtr(IDT_NUM_HEX, IDT_ADDR);

  /* CPUの割り込み解除 */
  io_sti();

  /* キーボードの割り込み許可 */
  io_out8(MASTER_OCW, 0xf9);

  return;
}
