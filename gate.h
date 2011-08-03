#ifndef __GATE_H
#define __GATE_H


/* ゲート作成 */
void gate_make (gate_t *gate, unsigned short selector, void (*f()),
                unsigned short count, unsigned short type, unsigned short dpl);

#endif // __GATE_H
