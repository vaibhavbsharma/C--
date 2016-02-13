#include "symboltable.h"

void init_symtab()	/* Initialize Symbol Table */
{
  id_idx=0;
}

int find_id(char *text) {
  int i;
  for(i=0;i<id_idx;i++)
    if(strcmp(symtab[i].id_name,text)==0) return i;
  return -1;
}

void insert_id(char *text)	/* Populate Symbol Table */
{
  int pos=find_id(text);
  if(pos==-1) {
    strcpy(symtab[id_idx].id_name,(const char *)text);
    symtab[id_idx].id_freq=1;
    id_idx++;
  }
  else symtab[pos].id_freq++;
}

int id_info_cmp(const void *_id1, const void *_id2) {
  id_info *id1 = (id_info *)_id1;
  id_info *id2 = (id_info *)_id2;
  return strcmp(id1->id_name,id2->id_name);
}

void print_symtab()	/* Print Symbol Table */
{
  int i;
  for(i=0;i<id_idx;i++) {
    printf("%s %d\n",symtab[i].id_name,symtab[i].id_freq);
  }
}

void cleanup_symtab()	/* Clean Symbol Table */
{
  id_idx=0;
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
