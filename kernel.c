
/************************************
 * kernel: カーネルのメインルーチン *
 ************************************/

/* #include "kernel.h" */
void io_hlt();

void int_handler() {
}

/* main */
int kernel_main(void) {
 fin:
  io_hlt();
  goto fin;
  return 0;
}
