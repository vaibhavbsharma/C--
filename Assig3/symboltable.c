#include "symboltable.h"

void init_symtab() {
    symtab = h_init();
}

bool insert_symbol(symtab_entry *s, int scope) {
    debug("symboltable:insert_symbol(): scope %d, s-name %s", 
            scope, s->name);
    char* key = strcat(myitoa(scope), s->name);
    return h_insert(symtab, key, s);
}

symtab_entry *lookup_symtab(char *id_name, int scope) {
    char* key = strcat(myitoa(scope), id_name);
    return ((symtab_entry *) h_get(symtab, key));
}

symtab_entry *create_symbol(char *id_name, int scope) {
    assert(strlen(id_name) < 257);
    symtab_entry *s = malloc(sizeof(symtab_entry));
    strcpy(s->name, id_name);
    s->scope = scope;
    debug("symboltable::create_symbol() id_name: %s, scope: %d", 
            s->name, s->scope);
    return s;
}

