
/************************************
 * kernel: カーネルのメインルーチン *
 ************************************/

#include "kernel.h"
#define PRINT_Y(string, y) print(string, y, 0)

void empty() {
}

/* 
 * ローダーによって main 関数が呼び出される
 */
int main(void) {
  gdt_init();
  idt_init();
  while (1) {
    PRINT_Y("This is Kernel Caller.", 15);
    io_hlt();
  }
  return 0;
}

