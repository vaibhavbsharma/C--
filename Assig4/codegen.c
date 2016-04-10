/** codegen.c 
 * Functions related to code generation
 * */
#include "codegen.h"
#include <stdlib.h>

intstack_t *s_init() {
    intstack_t *s = (intstack_t*) malloc(sizeof(intstack_t));
    s->index = -1;
    return s;
}

bool s_push(intstack_t *s, int n) {
    if (s->index >= STACK_SIZ) {
        debug("stack is full");
        return false;
    }
    s->stack[++(s->index)] = n;
    return true;
}

int s_get(intstack_t *s) {
    if (s->index < 0) {
        debug("stack is empty");
        return -1;
    }
    return s->stack[s->index];
}

bool s_pop(intstack_t *s) {
    if (s->index < 0) {
        // stack is empty
        debug("stack is empty");
        return false;
    }
    (s->index)--;
    return true;
}

void gen_func_prolog(char name[]) {
  emit(".text");
  emit("main:");
  emit("\tsw $ra, 0($sp)");
  emit("\tsw $fp, -4($sp)");
  emit("\tadd $fp, $sp, -4");
  emit("\tadd $sp, $sp, -8");
  emit("\tlw $2, _framesize_main");
  emit("\tsub $sp, $sp, $2");
  emit("\tsw $8, 32($sp)");
  emit("\tsw $9, 28($sp)");
  emit("\tsw $10, 24($sp)");
  emit("\tsw $11, 20($sp)");
  emit("\tsw $12, 16($sp)");
  emit("\tsw $13, 12($sp)");
  emit("\tsw $14, 8($sp)");
  emit("\tsw $15, 4($sp)");
  emit("_begin_main:");
}

void gen_func_epilog(char name[]) {
  emit("_end_main:");
  emit("\tlw $8, 32($sp)");
  emit("\tlw $9, 28($sp)");
  emit("\tlw $10, 24($sp)");
  emit("\tlw $11, 20($sp)");
  emit("\tlw $12, 16($sp)");
  emit("\tlw $13, 12($sp)");
  emit("\tlw $14, 8($sp)");
  emit("\tlw $15, 4($sp)");
  emit("\tlw $ra, 4($fp)");
  emit("\tadd $sp, $fp, 4");
  emit("\tlw $fp, 0($fp)");
  emit("\tli $v0, 10");
  emit("\tsyscall");
  emit(".data");
  emit("\t_framesize_main: .word 36");

}
