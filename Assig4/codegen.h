/** codegen.h
 *
 * Header file for code generation related functions & globals
 *
 * TODO:
 *  -   Implement a stack for label stack (see slide8-page22)
 *  -   Implement stack functions (push, pop, get)
 *  -   Maintain a global variable for label number
 * */

#include "common.h"
#include "stdbool.h"

#define STACK_SIZ 1000

/** A global counter for label number */
int label_no = 0;

int label_stack[STACK_SIZ];
int index = -1;

/** Push a label to the label stack 
 * @param stack     A pointer to a stack (integer array) 
 * @return false if stack is full
 * */
bool label_push(int n);

/** Peep the stack 
 * @return          Stack top, -1 if empty
 * */
int label_get();

/** Pop an element from the stack top
 * @return the top if exists, -1 if empty
 * */
void label_pop();

