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

/* Symbol table management routines */
void init_symtab();
void print_symtab();
void cleanup_symtab();
void insert_id(char *text);
int find_id(char *text);
int id_info_cmp(const void *id1,const void *id2);

/* Comment table management routines */
void init_comtab();
void print_comtab();
void cleanup_comtab();
void insert_comment(char *comment);

#endif //SYMBOLTABLE_H
