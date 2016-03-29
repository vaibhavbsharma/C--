#include "typetable.h"


mytype_t *insert_type(char *type, type_enum _t) {
    mytype_t *t = malloc(sizeof(mytype_t));
    strcpy(t->name, type);
    t->type = _t;
    t->head = NULL;
    h_insert(typetab, type, t);
    printf("typetable.c::insert_type %s(%d) inserted succesfully\n",type,_t);
    return t;
}

int is_type_exists(char *type) {
  if (h_get(typetab,type) == NULL) {
        return 0;
    } else {
        return 1;
    }
}

type_enum get_type(char *type) {
  mytype_t *t = (mytype_t *)h_get(typetab,type);
  if (t!=NULL) {
    printf("typetable.c::get_type %s has type (%d)\n",type,t->type);
    return t->type;
  }
  else {
    printf("typetable.c::get_type %s returning default type\n", type);
    return INT_TY;
  }
}
  

void init_typetab() {
    typetab = h_init();
}


struct_field *create_field(char *name, type_enum type) {
  struct_field *sf = malloc(sizeof(struct_field));
  strcpy(sf->f_name,name);
  sf->f_type=type;
  sf->next=NULL;
  debug("typetable.c::create_field field %s(%d) created\n",name,type);
  return sf;
}

mytype_t *get_type_obj(char *type ){
  mytype_t *t = (mytype_t *)h_get(typetab,type);
  return t;
}
