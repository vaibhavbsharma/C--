/** @file symboltable.h
 * @brief header file for symbol table manipulation
 * @author Vaibhav Sharma (vaibhav)
 * @author Taejoon Byun (taejoon)
 */

#ifndef SYMBOLTABLE_H
#define SYMBOLTABLE_H

#include <stdbool.h>
#include <assert.h>
#include <stdio.h>
#include <string.h>
#include "ght_hash_table.h"

#define MAX_COMMENT_SIZE 100
#define MAX_COMMENTS_NUM 100
char comments_arr[MAX_COMMENTS_NUM][MAX_COMMENT_SIZE];
int num_comments;

int num_ids;

#define N_SYM_ENTRY 100
ght_hash_table_t *sym_table = NULL;

#define SYM_NAME_LEN 256
/** A symbol table entry */
typedef struct symbol_t {
    char name[SYM_NAME_LEN];    /**< symbol name (a unique identifier) */
    int freq;
} symbol_t;


/* --- Symbol table management routines --- */

bool insert_symbol(symbol_t *s);

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
