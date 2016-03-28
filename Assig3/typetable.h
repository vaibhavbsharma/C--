#ifndef TYPETABLE_H
#define TYPETABLE_H
#include <stdio.h>
#include "hashtable.h"
#include <stdlib.h>

entry_t **typetab;

void insert_type(char*);

int is_type_exists( char*);

void init_typetab();

#endif
