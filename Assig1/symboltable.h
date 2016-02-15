/** @file symboltable.h
 * @brief header file for symbol table manipulation
 * @author Vaibhav Sharma (vaibhav)
 * @author Taejoon Byun (taejoon)
 */

#ifndef SYMBOLTABLE_H
#define SYMBOLTABLE_H

#define MAX_COMMENT_SIZE 100
#define MAX_COMMENTS_NUM 100
char comments_arr[MAX_COMMENTS_NUM][MAX_COMMENT_SIZE];
int num_comments;

#define MAX_ID_SIZE 256
#define MAX_ID_NUM 100
typedef struct _id_info {
  char id_name[MAX_ID_SIZE];
  int id_freq;
}id_info;
id_info symtab[MAX_ID_NUM];
int num_ids;

/** An enumeration for symbol type. (Not implemented yet) */
typedef enum symbol_type {
    TYPE1, TYPE2
} symbol_type;

#define SYM_NAME_LEN 256
/** A symbol table entry */
typedef struct symbol {
    char name[SYM_NAME_LEN];    /**< symbol name (a unique identifier) */
    symbol_type type;
} symbol;


/* --- Symbol table management routines --- */

void insert_symbol(symbol s);

/** Initialize the symbol table */
void init_symtab();

/** print symbol table to <tt>stdout</tt> */
void print_symtab();

/** Clean up symbol table */
void cleanup_symtab();

/** @brief populate symbol table 
 * @param text  
 * */
void insert_id(char *text);

/** */
int find_id(char *text);

int id_info_cmp(const void *id1,const void *id2);


/* --- Comment table management routines --- */

void init_comtab();
void print_comtab();
void cleanup_comtab();
void insert_comment(char *comment);


#endif //SYMBOLTABLE_H
