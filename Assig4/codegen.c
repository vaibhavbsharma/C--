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
  emit("sw $ra, 0($sp)");
  emit("sw $fp, -4($sp)");
  emit("add $fp, $sp, -4");
  emit("add $sp, $sp, -8");
  emit("lw $2, _framesize_main");
  emit("sub $sp, $sp, $2");
  emit("sw $8, 32($sp)");
  emit("sw $9, 28($sp)");
  emit("sw $10, 24($sp)");
  emit("sw $11, 20($sp)");
  emit("sw $12, 16($sp)");
  emit("sw $13, 12($sp)");
  emit("sw $14, 8($sp)");
  emit("sw $15, 4($sp)");
  emit("_begin_main:");
}

void gen_func_epilog(char name[]) {
  emit("_end_main:");
  emit("lw $8, 32($sp)");
  emit("lw $9, 28($sp)");
  emit("lw $10, 24($sp)");
  emit("lw $11, 20($sp)");
  emit("lw $12, 16($sp)");
  emit("lw $13, 12($sp)");
  emit("lw $14, 8($sp)");
  emit("lw $15, 4($sp)");
  emit("lw $ra, 4($fp)");
  emit("add $sp, $fp, 4");
  emit("lw $fp, 0($fp)");
  emit("li $v0, 10");
  emit("syscall");
  emit(".data");
  emit("_framesize_main: .word 36");

}
