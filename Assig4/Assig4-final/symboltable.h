#ifndef SYMBOLTABLE_H_
#define SYMBOLTABLE_H_

#include "hashtable.h"
#include <stdbool.h>
#include <assert.h>
#include "common.h"

typedef struct symtab_entry{
    char name[ID_SIZ];
    int scope;
    type_enum type;
    enum {
        NONE, FUNCTION, ARRAY, PARAMETER
    } kind;
    int n_param;                //< number of parameter (when FUNCTION)
    int dim;                    //< dimension
    struct symtab_entry *next;
    void *type_ptr;             //< points to mytype_t object if at all
    char place[ID_SIZ];     //< memory location (label) where this symbol lies
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

/* Copies a symtab_entry object */
symtab_entry *copy_symbol(symtab_entry *s);

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
