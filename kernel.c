
/************************************
 * kernel: カーネルのメインルーチン *
 ************************************/

#include "kernel.h"

/* main */
int kernel_main(void) {
  /* gdt_init(); */
  while (1) {
    print("This is Kernel Caller.");
    io_hlt();
  }
  return 0;
}

void int_handler() {
}

