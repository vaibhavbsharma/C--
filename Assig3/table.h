#ifndef TABLE_H
#define TABLE_H
#include <stdio.h>
#include "hashtable.h"
#include <stdlib.h>

void insert_type(entry_t **h_table, char*);

int is_type_exists(entry_t **h_table, char*);

void init(entry_t **h_table);

#endif
