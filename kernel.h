#ifndef __KERNEL_H
#define __KERNEL_H

/* 各セレクタを定義 */
#define SEL_CODE 0x08
#define SEL_DATA 0x10
#define SEL_VIDEO 0x18
#define SEL_IDT 0x20
#define IDT_ADDR_BASE 0x20000

/* func.asm で定義 */
void lidt(void);
void io_hlt(void);
void io_wait(void);
void io_cli();
void io_sti();
void io_out8(int port, int data);
void io_out16(int port, int data);
void io_out32(int port, int data);
void print(char *);


#endif //__KERNEL_H
