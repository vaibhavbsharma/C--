#include "typetable.h"


mytype_t *insert_type(char *type, type_enum _t) {
    mytype_t *t = malloc(sizeof(mytype_t));
    strcpy(t->name, type);
    t->type = _t;
    h_insert(typetab, type, &t);
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
  if (t!=NULL) return t->type;
  else return INT_TY;
}
  

void init_typetab() {
    typetab = h_init();
}

