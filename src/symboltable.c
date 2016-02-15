#include "symboltable.h"

symbol_t *new_symbol(char *name) {
    symbol_t *s = (symbol_t *) malloc(sizeof(symbol_t));
    strcpy(s->name, name);
    s -> freq = 0;
    return s;
}

bool insert_symbol(symbol_t *symbol) {
    return h_insert(symbol->name, symbol);
}

void init_symtab() {
    h_init();   // initialize hash table
    num_ids=0;
}

symbol_t *get_symbol(char *text) {
    return h_get(text);
}

/* Populate Symbol Table */
void insert_id(char *text) {
    if(get_symbol(text) != NULL) {
        /* already exists */
        // TODO: increase frequency
        return;
    }
    if(!insert_symbol(new_symbol(text))) {
        // could not insert
        // TODO: error message
    }
    num_ids ++;
}

/* Print Symbol Table */
void print_symtab()	{
    //TODO
}

/* Clean Symbol Table */
void cleanup_symtab() {
    num_ids=0;
}


/* --- comment table functions --- */

void init_comtab()	/* Initialize Comment Table */
{
    num_comments=0;
}

void insert_comment(char *comment)	/* Insert comments into Comment Table */
{
    strcpy(comments_arr[num_comments],(const char *)comment);
    num_comments++;
}

void print_comtab()	/* Print Comment Table */
{
    int i;
    for(i=0;i<num_comments;i++)
        printf("%s\n",comments_arr[i]);
    //printf("Comment %d = %s\n",i,comments_arr[i]);
}

void cleanup_comtab()	/* Clean Comment Table */
{
    num_comments=0;
}
