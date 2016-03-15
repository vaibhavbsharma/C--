#include "table.h"

typedef struct mytype_t {
    char name[20];
} mytype_t;

void insert_type(char *type) {
    mytype_t *t = malloc(sizeof(mytype_t));
    strcpy(t->name, type);
    h_insert(type, &t);
}

int is_type_exists(char *type) {
    if (h_get(type) == NULL) {
        return 0;
    } else {
        return 1;
    }
}

void init() {
    h_init();
}

