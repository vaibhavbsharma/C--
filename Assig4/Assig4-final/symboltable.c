#include "symboltable.h"

void init_symtab() {
    symtab = h_init();
}

/** A private function to generate a unique key for a given ID name in a 
 * certain scope.
 * @param name      The name of the ID
 * @param scope     The scope wherein the ID is declared
 * @return          The key generated, of length {common.h::SYMTAB_KEY_SIZ}
 * */
char* gen_key(char *name, int scope) {
    /* note: the length of the string returned by `myitoa(scope)` is 
     * common.h::SYMTAB_KEY_SIZ (260) */
    return strcat(myitoa(scope), name);
}

bool insert_symbol(symtab_entry *s, int scope) {
    //debug("symboltable::insert_symbol(): scope %d, s->name %s", scope, s->name);
    /* use the scope as a prefix of the key in order to differentiate IDs 
     * with the same name in different scopes */
    // name the `place` to `_[identifier_name]`
    strncpy(s->place, "_", 2);
    strncat(s->place, s->name, ID_SIZ-2);
    return h_insert(symtab, gen_key(s->name, scope), s);
}

symtab_entry *lookup_symtab(char *id_name, int scope) {
  debug("lookup_symtab: id_name = %s scope = %d", id_name, scope);
  symtab_entry *ret = ((symtab_entry *) h_get(symtab, gen_key(id_name, scope))); 
  return ret;
}

symtab_entry *lookup_symtab_prevscope(char *id_name, int scope) {
    symtab_entry *s = NULL;
    while (!s && scope >= 0) {
        /* starting from the current scope, lookup all the previous scopes */
        s = ((symtab_entry *) h_get(symtab, gen_key(id_name, scope--)));
    }
    return s;
}

symtab_entry *create_symbol(char *id_name, int scope) {
    assert(strlen(id_name) < 257);
    symtab_entry *s = malloc(sizeof(symtab_entry));
    memset(s, 0, sizeof(symtab_entry));
    strcpy(s->name, id_name);
    s->scope = scope;
    s->next = NULL;
    s->type_ptr = NULL;
    //debug("symboltable::create_symbol() id_name: %s, scope: %d", s->name, s->scope);
    return s;
}

symtab_entry *copy_symbol(symtab_entry *s) {
  debug("copy_symbol(): entering");
    assert(strlen(s->name) < 257);
    symtab_entry *s_ret = malloc(sizeof(symtab_entry));
    memset(s_ret, 0, sizeof(symtab_entry));
    strcpy(s_ret->name, s->name);
    s_ret->type = s->type;
    s_ret->scope = s->scope;
    s_ret->next = s->next;
    s_ret->type_ptr = s->type_ptr;
    debug("symboltable::copy_symbol() id_name: %s, scope: %d", s_ret->name, s_ret->scope);
    return s_ret;
}

void delete_scope(int scope) {
  int sz,i;
    // hasth table entries in a list, for a faster search
    debug("symboltable::delete_scope(%d)", scope);
    void **list = ht_to_list(symtab,&sz);
    debug("sz: %d", sz);
    for (i=0; i<sz; i++) {
        symtab_entry *entry = (symtab_entry *) list[i];
        //debug("\tentry: %s", entry);
        if (!entry) {
            continue;
        }
        if (entry->scope < scope || entry->kind == PARAMETER) {
            /* delete only the symbols that are in current scope and 
             * are not parameter */
            continue;
        }
        debug("delete_scope(%d) deleting %s", entry->scope, entry->name);
        h_remove(symtab, gen_key(entry->name, entry->scope));
    }
    free(list);
}
