#ifndef SYMBOLTABLE_H
#define SYMBOLTABLE_H


#define MAX_COMMENT_SIZE 100
#define MAX_COMMENTS_NUM 100
char comments_arr[MAX_COMMENTS_NUM][MAX_COMMENT_SIZE];
int comm_idx;
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
