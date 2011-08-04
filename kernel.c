
/************************************
 * kernel: カーネルのメインルーチン *
 ************************************/

#include "kernel.h"
#define PRINT_Y(string, y) print(string, y, 0)

/* 
 * kernel_main がカーネルローダーから読み込まれる
 * この前に関数を定義してはならない (コンパイルしても動作しないため)
 */
int kernel_main(void) {
  gdt_init();
  idt_init();
  while (1) {
    PRINT_Y("This is Kernel Caller.", 15);
    io_hlt();
  }
  return 0;
}

void fuga() {
}

