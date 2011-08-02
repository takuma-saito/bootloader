
/******************************
 * kernel: カーネルの主幹部分 *
 ******************************/

#include "kernel.h"

void int_handler() {
}

/* main */
int kernel_main(void) {
 fin:
  io_hlt();
  goto fin;
  return 0;
}
