#include "table.h"

typedef struct mytype_t {
    char name[20];
} mytype_t;

void insert_type(entry_t **h_table, char *type) {
    mytype_t *t = malloc(sizeof(mytype_t));
    strcpy(t->name, type);
    h_insert(h_table, type, &t);
}

int is_type_exists(entry_t **h_table, char *type) {
  if (h_get(h_table,type) == NULL) {
        return 0;
    } else {
        return 1;
    }
}

void init(entry_t **h_table ) {
    h_init(h_table);
}

