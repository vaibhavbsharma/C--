#ifndef COMMON_H_
#define COMMON_H_

#include <stdio.h>

typedef enum {
  VOID_TY, INT_TY, FLOAT_TY, TYPEDEF_TY, STRUCT_TY, UNION_TY, 
  ARR_INT_TY, ARR_FLOAT_TY
} type_enum;

/** a pseudo-itoa that converts an integer to string 
* @param i    an integer to convert
* @return     the integer converted to string
* */
char* myitoa(int i);

#ifdef DEBUG
#include <stdio.h>
#include <stdlib.h>

#define debug(M, ...) fprintf(stderr, "DEBUG %s:%d: " M "\n", __FILE__, __LINE__, ##__VA_ARGS__)
#else
#define debug(M, ...)
#endif

extern FILE *yyout;
/** macros and globals for code generation */
#define emit(CODE, ...) fprintf(yyout, CODE "\n", ##__VA_ARGS__)

/** maximum size of an identifier */
#define ID_SIZ 257

/** size of ID + 3 (for scope prefix which can be up to 3 digits) */
#define SYMTAB_KEY_SIZ 260  

#endif

/** A function to generate a unique key for a given ID name in a 
 * certain scope.
 * @param name      The name of the ID
 * @param scope     The scope wherein the ID is declared
 * @return          The key generated, of length {common.h::SYMTAB_KEY_SIZ}
 * */
char* gen_key(char *name, int scope);

