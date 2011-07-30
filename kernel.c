
extern void io_hlt(void);

int kernel_main(void) {
  io_hlt();
  return 0;
}
