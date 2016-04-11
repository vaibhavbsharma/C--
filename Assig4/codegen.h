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
#include <string.h>
#define STACK_SIZ 1000

#define LABEL_SIZE 20

typedef struct stringlabel_t {
  char label[LABEL_SIZE];
  char str[100];
} stringlabel;

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


/* Get the first available register 
 * returns -1 if all registers are currently being used */
int get_free_temp_reg();

/* Check if argument str is pointing to a temporary register,
 * if it is, then mark that temp reg to free, else do nothing */
void mark_temp_reg_free(char *);

/* Check if argument str points to a temporary register */
bool is_temp_reg(char *str);


#endif
