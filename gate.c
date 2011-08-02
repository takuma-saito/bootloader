
/* ゲート作成 */
void gate_make (gate_t *gate, unsigned short selector, void (*f()),
                unsigned short count, unsigned short type, unsigned short dpl) {
  gate->offset_low = (unsigned short) f;
  gate->selector = selector;
  gate->count = count;
  gate->type = type | (dpl << 5);
  gate->offset_high = (unsigned short) (f >> 16);
}

