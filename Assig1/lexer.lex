%option noyywrap 
%{
#include <stdio.h>
#include <string.h>
#include "symboltable.h"

int linenumber=0;
int tokens=0;
int comments=0;
%}


letter [A-Za-z]
digit [0-9]
elphanum ({letter}|{digit})
ID {letter}({letter}|{digit}|"_")*
RESERVED (return|typedef|if|else|int|float|for|struct|union|void|while)
OPERATOR ("+"|"-"|"*"|"*"|"<"|">"|">="|"<="|"!="|"=="|"||"|"&&"|"!"|"=")
SEPARATOR ("{"|"}"|"("|")"|"["|"]"|";"|","|".")
STRING_LITERAL \".*\"
INT_CONST (digit)+
%%


\n	{++linenumber;}

{OPERATOR} {
  tokens++;printf("found operator: %s\n",yytext);
}

{RESERVED} {
  tokens++;
  printf("found reserved keyword: %s\n", yytext );
}


{SEPARATOR} {
  tokens++;
  printf("found separator: %s\n", yytext );
}

{STRING_LITERAL} {
  tokens++;
  printf("found string literal: %s\n",yytext);
}

{ID}    { tokens++; insert_id(yytext); printf("found identifier: %s\n",yytext);}

"/*"    {//https://www.cs.princeton.edu/~appel/modern/c/software/flex/flex.html
  comments++;
  tokens++;
  char c;
  int i;
  char this_comment[MAX_COMMENT_SIZE];
  int this_comment_idx=0;
  for(i=0;i<MAX_COMMENT_SIZE;i++) this_comment[i]='\0';
  this_comment[this_comment_idx++]='/';
  this_comment[this_comment_idx++]='*';
  for ( ; ; )
    {
      while ( (c = input()) != '*' &&
	      c != EOF ) {
	if(c=='\n') linenumber++;
	//strcat(this_comment,&c);
	this_comment[this_comment_idx++]=c;
      }    /* eat up text of comment */
      
      if(c == '*')
	{
	  //strcat(this_comment,&c);
	  this_comment[this_comment_idx++]=c;
	  while ( (c = input()) == '*' ) {
	    //strcat(this_comment,&c);
	    this_comment[this_comment_idx++]=c;
	  }
	  //strcat(this_comment,&c);
	  this_comment[this_comment_idx++]=c;
	  if ( c == '/' )
	    break;    /* found the end */
	}
      
      if ( c == EOF )
	{
	  printf( "Error: EOF in comment" );
	  break;
	}
    }
  //printf("Comment = %s\n",this_comment);
  insert_comment(this_comment);
}
%%

int main(int argc, char **argv)
{
    argc--; ++argv;
    init_symtab();	/* Initialize Symbol/Comment tables */
    init_comtab();
    if (argc > 0)
        yyin = fopen(argv[0], "r");
    else
        yyin = stdin;
    yylex();
    printf("number of tokens %d\n",tokens);
    printf("number of lines %d\n",linenumber);
    printf("There are %d comments:\n",comments);
    print_comtab();	/* Print Comments and Symbols */
    print_symtab();
    cleanup_comtab();	/* Clean up tables */
    cleanup_symtab();
    return 0;
}

