/* ===== Definition Section ===== */

%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
static int linenumber = 1;
%}


%token ID
%token CONST
%token SCONST
%token VOID    
%token INT     
%token FLOAT   
%token IF      
%token ELSE    
%token WHILE   
%token FOR
%token STRUCT  
%token TYPEDEF

%token READ
%token FREAD
%token WRITE

%token OP_ASSIGN  
%token OP_OR   
%token OP_AND  
%token OP_NOT  
%token OP_EQ   
%token OP_NE   
%token OP_GT   
%token OP_LT   
%token OP_GE   
%token OP_LE   
%token OP_PLUS 
%token OP_MINUS        
%token OP_TIMES        
%token OP_DIVIDE       
%token MK_LB 
%token MK_RB 
%token MK_LPAREN       
%token MK_RPAREN       
%token MK_LBRACE       
%token MK_RBRACE       
%token MK_COMMA        
%token MK_SEMICOLON    
%token MK_DOT  
%token ERROR
%token RETURN

%start program

%%

/* ==== Grammar Section ==== */

/* Productions */               /* Semantic actions */
 /*program		: global_decl_list
		;

global_decl_list: global_decl_list global_decl
                |
		;

global_decl	: function_decl
		| function_decl
		;

function_decl	: 
		;
 */

program : global_decl_list;

global_decl_list: global_decl_list global_decl
                  | 
;

global_decl : decl_list function_decl |
              function_decl
;

function_decl : type ID MK_LPAREN param_list MK_RPAREN MK_LBRACE block MK_RBRACE {printf("function_decl\n");}
;

block: decl_list stmt_list  {printf("bloc: decl_list stmt_list \n");}
       |
;

stmt_list: stmt_list stmt  {printf("stmt_list: stmt_list stmt\n");}
           |
;

param_list: 
param_var_decl {printf("param_list: param_var_decl\n");}
| param_list MK_COMMA param_var_decl {printf("param_list: param_list, param_var_decl\n");}
|
; 

param_var_decl : param_type param_id_list
;

param_id_list: ID param_id_tail  
;

param_id_tail: MK_LB CONST MK_RB param_id_tail
| MK_LB MK_RB param_id_tail
|
;

param_type: INT | FLOAT | VOID | STRUCT ID
;

stmt: 
MK_LBRACE block MK_RBRACE {printf("stmt: {block}\n");}
| IF MK_LPAREN expr MK_RPAREN stmt  {printf("stmt: if(expr) stmt\n");}
| IF MK_LPAREN expr MK_RPAREN stmt ELSE stmt  {printf("stmt: if(expr) { stmt_list } else {stmt_list }\n");}
| WHILE MK_LPAREN expr MK_RPAREN stmt {printf("stmt: while(expr) stmt\n");}
| FOR MK_LPAREN assign_expr expr MK_SEMICOLON expr MK_RPAREN stmt {printf("stmt: for(assign_expr expr expr) stmt\n");} 
| assign_expr {printf("stmt: assign_expr\n");}
| WRITE MK_LPAREN SCONST MK_RPAREN MK_SEMICOLON {printf("stmt: write called at %d\n", linenumber);}
| RETURN expr MK_SEMICOLON {printf("stmt: return expr;");}
| error { printf("Error in stmt production \n"); }
/* other C-- statements */
;

assign_expr: 
lhs OP_ASSIGN expr MK_SEMICOLON {printf("id=expr;\n");}
| lhs OP_ASSIGN READ MK_LPAREN MK_RPAREN MK_SEMICOLON {printf("id=read();\n");}
| lhs OP_ASSIGN FREAD MK_LPAREN MK_RPAREN MK_SEMICOLON {printf("id=fread();\n");}
;

lhs: ID id_tail lhs_member
;

lhs_member: MK_DOT lhs
|
;


expr: MK_LPAREN expr MK_RPAREN {printf("expr: (expr)\n");}  
| expr binop ID {printf("expr: expr binop ID\n");}
| unop expr {printf("expr: unop expr\n");}
| expr binop CONST  {printf("expr: expr binop CONST\n");}
| ID  {printf("expr: ID\n");}
| CONST {printf("expr: CONST\n");}
;

binop: OP_AND | OP_OR | OP_EQ | OP_NE | OP_LT | OP_GT | OP_LE | OP_GE | 
       OP_PLUS | OP_MINUS | OP_TIMES | OP_DIVIDE
;

unop: OP_NOT
;

decl_list : decl_list decl
| decl
|
;

decl : type_decl MK_SEMICOLON 
       | var_decl
;

var_decl : type id_list MK_SEMICOLON
;

id_list: ID id_tail id_list_tail 
;

id_list_tail: MK_COMMA id_list
|
;

id_tail: MK_LB CONST MK_RB id_tail
|
;

type: INT | FLOAT | VOID | STRUCT ID struct_block
;

struct_block:
MK_LBRACE decl_list MK_RBRACE
|
;

type_decl: STRUCT ID MK_LBRACE decl_list MK_RBRACE 
           | TYPEDEF type ID 
;

%%

#include "lex.yy.c"
main (argc, argv)
int argc;
char *argv[];
  {
     	yyin = fopen(argv[1],"r");
     	yyparse();
     	printf("%s\n", "Parsing completed. No errors found.");
  } 


yyerror (mesg)
char *mesg;
{
	printf("%s\t%d\t%s\t%s\n", "Error found in Line ", linenumber, "next token: ", yytext );
  	printf("%s\n", mesg);
  	exit(1);
}
