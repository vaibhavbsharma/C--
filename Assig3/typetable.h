#ifndef TYPETABLE_H
#define TYPETABLE_H
#include <stdio.h>
#include "hashtable.h"
#include "common.h"
#include <stdlib.h>

typedef struct mytype_t {
  char name[20];
  type_enum type;
} mytype_t;

entry_t **typetab;

mytype_t *insert_type(char*, type_enum _t);

int is_type_exists( char*);

//Should be called only if is_type_exists returns true for the given type
//returns INT_TY by default in case the passed type argument was not 
//found in the type table
type_enum get_type(char *type); 

void init_typetab();

#endif
