#ifndef SYMBOLTABLE_H
#define SYMBOLTABLE_H

/* Symbol table management routines */
void init_symtab();
void print_symtab();
void cleanup_symtab();
void insert_id(char *text);

/* Comment table management routines */
void init_comtab();
void print_comtab();
void cleanup_comtab();
void insert_comment(char *comment);

#endif //SYMBOLTABLE_H
