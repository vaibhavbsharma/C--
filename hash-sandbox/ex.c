#include <stdio.h>
#include "ght_hash_table.h"
#include <string.h>

int vo() {
    ght_hash_table_t *p_table;
    int *p_data;
    int *p_he;

    p_table = ght_create(128);

    if ( !(p_data = (int*)malloc(sizeof(int))) )
        return -1; 
    /* Assign the data a value */
    *p_data = 15; 

    /* Insert "blabla" into the hash table */
    ght_insert(p_table,
            p_data,
            sizeof(char)*strlen("blabla"), "blabla");

    /* Search for "blabla" */
    if ( (p_he = ght_get(p_table,
                    sizeof(char)*strlen("blabla"), "blabla")) )
        printf("Found %d\n", *p_he);
    else
        printf("Did not find anything!\n");

    /* Remove the hash table */
    ght_finalize(p_table);
    
    return 0;
}

int main() {
    vo();

    return 0;
}

