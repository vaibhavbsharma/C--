#ifndef SYMBOLTABLE_H_
#define SYMBOLTABLE_H_

#include "hashtable.h"
#include <stdbool.h>

#define ID_SIZ 257

typedef struct {
  char name[ID_SIZ];
  int scope;
  enum {
    FUNCTION, ARRAY
  } kind;
  enum {
    INT_TY, FLOAT_TY, VOID_TY, TYPEDEF_TY, STRUCT_TY, UNION_TY, 
    ARR_INT_TY, ARR_FLOAT_TY
  } type;
  int n_arg;
} symtab_entry;

/** A global symbol table */
entry_t **symtab;

/** Initialize symbol table */
void init_symtab();

/** Insert symbol 
* @param s symbol table entry to insert
* @return true if successful, false if an entry with the same name exists in 
*   the same scope.
* */
bool insert_symbol(symtab_entry *s);

/** Lookup ID in symbol table 
* @param id_name identifier name
* @return symbol table entry if the symbol with ID exists, and NULL otherwise 
* */
symtab_entry *lookup_symtab(char *id_name);

#endif
