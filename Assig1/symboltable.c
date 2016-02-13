#include "symboltable.h"

void init_symtab()	/* Initialize Symbol Table */
{
}

void insert_id(char *text)	/* Populate Symbol Table */
{
}

void print_symtab()	/* Print Symbol Table */
{
}

void cleanup_symtab()	/* Clean Symbol Table */
{
}

void init_comtab()	/* Initialize Comment Table */
{
  comm_idx=0;
}

void insert_comment(char *comment)	/* Insert comments into Comment Table */
{
  strcpy(comments_arr[comm_idx],(const char *)comment);
  comm_idx++;
}

void print_comtab()	/* Print Comment Table */
{
  int i;
  for(i=0;i<comm_idx;i++)
    printf("%s\n",comments_arr[i]);
  //printf("Comment %d = %s\n",i,comments_arr[i]);
}

void cleanup_comtab()	/* Clean Comment Table */
{
  comm_idx=0;
}
