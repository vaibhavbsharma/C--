#include "symboltable.h"
#include "util.h"

void init_symtab() {
    symtab = h_init();
}

bool insert_symbol(symtab_entry *s, int scope) {
    if (DEBUG) {
        printf("symboltable:insert_symbol(): scope %d, s-name %s\n", 
                scope, s->name);
        fflush(stdout);
    }
    char* key = strcat(itoa(scope), s->name);
    return h_insert(symtab, key, s);
}

symtab_entry *lookup_symtab(char *id_name, int scope) {
    char* key = strcat(itoa(scope), id_name);
    return ((symtab_entry *) h_get(symtab, key));
}

symtab_entry *create_symbol(char *id_name, int scope) {
    if (DEBUG) {
        printf("symboltable:create_symbol(): id_name %s, scope %d\n", 
                id_name, scope);
    }
    assert(strlen(id_name) < 257);
    symtab_entry *s = malloc(sizeof(symtab_entry));
    strcpy(s->name, id_name);
    s->scope = scope;
}

