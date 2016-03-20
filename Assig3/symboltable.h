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
    int_ty, float_ty, void_ty, typedef_ty, struct_ty, union_ty, arr_int_ty, 
    arr_float_ty
  } type_info;
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
