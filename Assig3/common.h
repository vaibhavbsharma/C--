#ifndef COMMON_H_
#define COMMON_H_

typedef enum {
  VOID_TY, INT_TY, FLOAT_TY, TYPEDEF_TY, STRUCT_TY, UNION_TY, 
  ARR_INT_TY, ARR_FLOAT_TY
} type_enum;

#define DEBUG

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

/** maximum size of an identifier */
#define ID_SIZ 257

/** size of ID + 3 (for scope prefix which can be up to 3 digits) */
#define SYMTAB_KEY_SIZ 260  

#endif
