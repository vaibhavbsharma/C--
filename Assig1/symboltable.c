#include "symboltable.h"


void insert_symbol(symbol s) {
}


void init_symtab() {
  num_ids=0;
}

int find_id(char *text) {
  int i;
  for(i=0;i<num_ids;i++)
    if(strcmp(symtab[i].id_name,text)==0) return i;
  return -1;
}

void insert_id(char *text)	/* Populate Symbol Table */
{
  int pos=find_id(text);
  if(pos==-1) {
    strcpy(symtab[num_ids].id_name,(const char *)text);
    symtab[num_ids].id_freq=1;
    num_ids++;
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
  for(i=0;i<num_ids;i++) {
    printf("%s %d\n",symtab[i].id_name,symtab[i].id_freq);
  }
}

void cleanup_symtab()	/* Clean Symbol Table */
{
  num_ids=0;
}

// comment table functions ////////////////////////////////////////////////////

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
