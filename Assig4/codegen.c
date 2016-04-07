/** codegen.c 
 * Functions related to code generation
 * */

bool label_push(int n) {
    if (index >= STACK_SIZ) {
        debug("stack is full");
    }
    label_stack[++index] = n;
}

int label_get() {
    if (index < 0) {
        debug("stack is empty");
        return -1;
    }
    return label_stack[index];
}

int label_pop() {
    if (index < 0) {
        // stack is empty
        debug("stack is empty");
        return -1;
    }
    return label_stack[index--];
}

