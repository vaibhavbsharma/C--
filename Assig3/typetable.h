#ifndef TYPETABLE_H
#define TYPETABLE_H
#include <stdio.h>
#include "hashtable.h"
#include "common.h"
#include <stdlib.h>

//This structere used to create a linked list of field names and types
// for structures and unions

typedef struct struct_field_t {
  type_enum f_type;
  char f_name[20];
  struct struct_field_t *next;
} struct_field;

struct_field *create_field(char *name, type_enum type);


//Type information code below

typedef struct mytype {
  char name[20];
  type_enum type;
  struct_field *head;//points to the first field in a linked list of struct_field objects
} mytype_t;

entry_t **typetab;

mytype_t *insert_type(char*, type_enum _t);

int is_type_exists( char*);

//Should be called only if is_type_exists returns true for the given type
//returns INT_TY by default in case the passed type argument was not 
//found in the type table
type_enum get_type(char *type); 

mytype_t *get_type_obj(char *);

void init_typetab();


#endif
