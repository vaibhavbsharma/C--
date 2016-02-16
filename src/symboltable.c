#include "symboltable.h"

symbol_t *new_symbol(char *name) {
    symbol_t *s = (symbol_t *) malloc(sizeof(symbol_t));
    strcpy(s->name, name);
    s->freq = 0;
    return s;
}

bool insert_symbol(symbol_t *symbol) {
    return h_insert(symbol->name, symbol);
}

void init_symtab() {
    h_init();   // initialize hash table
    num_ids=0;
}

/* Populate Symbol Table */
void insert_id(char *text) {
#if DEBUG
    printf("insert_id(\"%s\")\n", text);
#endif
    symbol_t *sym = (symbol_t*) h_get(text);
    if (sym != NULL) {
        /* if already exists, increase frequency attr */
        sym->freq ++;
        return;
    }
    if (h_insert(text, new_symbol(text))) {
        symbol_t *sym = (symbol_t*) h_get(text);
        sym->freq ++;
    } else {
        /* insertion failure (collision) */
        // TODO: error message
    }
    num_ids ++;
}

/* compare between two sym_t entries */
int sym_cmp(const void *s1, const void *s2) {
    symbol_t **_s1 = (symbol_t **) s1;
    symbol_t **_s2 = (symbol_t **) s2;
#if DEBUG
    printf("compare %s %s\n", (*_s1)->name, (*_s2)->name);
#endif
    return strcmp((*_s1)->name, (*_s2)->name);
}

/* Print Symbol Table */
void print_symtab()	{
    int size;   // size of the list of symbols
    // retrieve all the entries of the hash table
    symbol_t **sym_list = (symbol_t **) ht_to_list(&size);
    qsort(sym_list, size, sizeof(symbol_t*), sym_cmp);
    printf("\nFrequency of identifiers\n");
    for (int i=0; i<size; i++) {
        printf("%-10s %2d\n", sym_list[i]->name, sym_list[i]->freq);
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
