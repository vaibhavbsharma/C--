#include "symboltable.h"

void init_symtab() {
  symtab = h_init();
}

bool insert_symbol(symtab_entry *s) {
  return h_insert(symtab,s->name,s);
}

symtab_entry *lookup_symtab(char *id_name) {
  return ((symtab_entry *)h_get(symtab,id_name));
}
 
symtab_entry *create_symbol(char *id_name, int scope) {
  assert(strlen(id_name) < 257);
  symtab_entry *s = malloc(sizeof(symtab_entry));
  strcpy(s->name, id_name);
  s->scope = scope;
}
