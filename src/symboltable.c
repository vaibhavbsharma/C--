#include "symboltable.h"


symbol_t *new_symbol(char *name) {
    symbol_t *s = (symbol_t *) malloc(sizeof(symbol_t));
    strcpy(s->name, name);
    s -> freq = 0;
    return s;
}

bool insert_symbol(symbol_t *symbol) {
    if (sym_table == NULL) {
        init_symtab();
    }
    return ght_insert(sym_table, symbol, sizeof(char)*strlen(symbol->name), 
            symbol->name) == 0 ? true : false;
}

void init_symtab() {
    sym_table = ght_create(N_SYM_ENTRY);
    num_ids=0;
}

symbol_t *get_symbol(char *text) {
    return ght_get(sym_table, strlen(text), text);
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
    ght_iterator_t iter;
    void *p_key;
    void *p_e;
    for (p_e = ght_first(sym_table, &iter, &p_key);
            p_e;
            p_e = ght_next(sym_table, &iter, &p_key)) {
        symbol_t *symb = (symbol_t*) p_e;
        printf("symbol: %s\n", symb->name);
    }
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
