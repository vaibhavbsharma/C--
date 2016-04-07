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

