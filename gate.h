#ifndef __GATE_H
#define __GATE_H

/* セグメント属性を表す (Descriptor Type) */
#define TYPE_CODE 0x9A
#define TYPE_DATA 0x92
#define TYPE_STACK 0x96
#define TYPE_LDT 0x82
#define TYPE_TSS 0x89
#define TYPE_TSS_BUSY 0x8b
#define TYPE_CALL_GATE 0x84
#define TYPE_INT_GATE 0x8e
#define TYPE_TRAP_GATE 0x8f
#define TYPE_TASK_GATE 0x85

/* ディスクリプタテーブル */
typedef struct {
  unsigned short limit;
  unsigned long base;
} desc_tbl;

/* コールゲート */
typedef struct gate_tag {
  unsigned short offset_low;
  unsigned short selector;
  unsigned char count;
  unsigned char type;
  unsigned short offset_high;
} gate_t;

/* ゲート作成 */
void gate_make (gate_t *gate, unsigned short selector, void (*f()),
                unsigned short count, unsigned short type, unsigned short dpl);

#endif // __GATE_H
