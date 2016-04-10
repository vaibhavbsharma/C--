/** codegen.h
 *
 * Header file for code generation related functions & globals
 *
 * TODO:
 *  -   Implement a stack for label stack (see slide8-page22)
 *  -   Implement stack functions (push, pop, get)
 *  -   Maintain a global variable for label number
 * */
#ifndef CODEGEN_H_
#define CODEGEN_H_

#include "common.h"
#include <stdio.h>
#include <stdbool.h>

#define STACK_SIZ 1000

typedef struct intstack_t {
    int stack[STACK_SIZ];
    int index;
} intstack_t;

/** Initialize a stack
 * @return the pointer to a new stack */
intstack_t *s_init();

/** Push a label to the label stack 
 * @param stack     A pointer to a stack (integer array) 
 * @return false if stack is full
 * */
bool s_push(intstack_t *stack, int n);

/** Peep the stack 
 * @return          Stack top, -1 if empty
 * */
int s_get(intstack_t *stack);

/** Pop an element from the stack top
 * @return false if empty 
 * */
bool s_pop(intstack_t *stack);


/* Generate the prolog and epilogue for a function with name */
void gen_func_prolog(char name[]);
void gen_func_epilog(char name[]);


#endif
