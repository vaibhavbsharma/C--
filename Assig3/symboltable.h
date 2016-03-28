#ifndef SYMBOLTABLE_H_
#define SYMBOLTABLE_H_

#include "hashtable.h"
#include <stdbool.h>
#include <assert.h>
#include "common.h"

typedef enum {
  VOID_TY, INT_TY, FLOAT_TY, TYPEDEF_TY, STRUCT_TY, UNION_TY, 
  ARR_INT_TY, ARR_FLOAT_TY
} type_enum;

typedef struct symtab_entry{
    char name[ID_SIZ];
    int scope;
    type_enum type;
    int n_arg;
    enum {
        NONE, FUNCTION, ARRAY
    } kind;
    int dim;                    //< dimension
    struct symtab_entry* next;
} symtab_entry;

/** A global symbol table */
entry_t **symtab;

/** Initialize symbol table */
void init_symtab();

/** Insert symbol 
* @param s      symbol table entry to insert
* @param scope  the current scope to look for
* @return       true if successful, false if an entry with the same name 
*               exists in the same scope.
* */
bool insert_symbol(symtab_entry *s, int scope);

/** Lookup ID in the symbol table, only in the current scope
* @param id_name  identifier name
* @param scope    the current scope to look for
* @return         symbol table entry if the symbol with ID exists, and 
*                 NULL otherwise 
* */
symtab_entry *lookup_symtab(char *id_name, int scope);

/** Lookup ID in the symbol table, including all the previous scopes
* @param id_name  identifier name
* @param scope    the current scope to start with
* @return         symbol table entry if the symbol with ID exists, and 
*                 NULL otherwise 
* */
symtab_entry *lookup_symtab_prevscope(char *id_name, int scope);

/** Lookup ID in symbol table 
* @param id_name  identifier name
* @param scope    the current scope 
* @return         the newly created symtab_entry node without inserting
*                 it into the symbol table
*/
symtab_entry *create_symbol(char *id_name, int scope);

/** Delete IDs in symbol table with a given scope
* @param scope    the scope in which all variables are to be deleted
 */
void delete_scope(int scope);

#endif
