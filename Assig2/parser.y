/* ===== Definition Section ===== */

%{
#include "common.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "table.h"
static int linenumber = 1;
%}

%token ID
%token TYPEDEF_NAME
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

function_decl : type ID MK_LPAREN param_list MK_RPAREN MK_LBRACE block MK_RBRACE {if(DEBUG) printf("function_decl\n");}
;

block: decl_list stmt_list  {if(DEBUG) printf("bloc: decl_list stmt_list \n");}
       |
;

stmt_list: stmt_list stmt  {if(DEBUG) printf("stmt_list: stmt_list stmt\n");}
           |
;

param_list: 
param_var_decl {if(DEBUG) printf("param_list: param_var_decl\n");}
| param_list MK_COMMA param_var_decl {if(DEBUG) printf("param_list: param_list, param_var_decl\n");}
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
MK_LBRACE block MK_RBRACE {if(DEBUG) printf("stmt: {block}\n");}
| IF MK_LPAREN expr MK_RPAREN stmt else_tail {if(DEBUG) printf("stmt: if(expr) stmt\n");}
| WHILE MK_LPAREN expr MK_RPAREN stmt {if(DEBUG) printf("stmt: while(expr) stmt\n");}
| FOR MK_LPAREN assign_expr MK_SEMICOLON expr MK_SEMICOLON assign_expr MK_RPAREN stmt {if(DEBUG) printf("stmt: for(assign_expr expr expr) stmt\n");} 
| assign_expr MK_SEMICOLON {if(DEBUG) printf("stmt: assign_expr\n");}
| WRITE MK_LPAREN SCONST MK_RPAREN MK_SEMICOLON {if(DEBUG) printf("stmt: write string constant called at %d\n", linenumber);}
| WRITE MK_LPAREN lhs MK_RPAREN MK_SEMICOLON {if(DEBUG) printf("stmt: write lhs called at %d\n", linenumber);}
| RETURN expr MK_SEMICOLON {if(DEBUG) printf("stmt: return expr;");}
| error {if(DEBUG)  printf("Error in stmt production \n"); }
/* other C-- statements */
;

else_tail:
ELSE stmt {if(DEBUG) printf("stmt: if(expr) { stmt } else { stmt} \n");} 
|
;

assign_expr: 
lhs OP_ASSIGN assign_expr_tail 
;

assign_expr_tail:
expr  {if(DEBUG) printf("lhs=expr\n");}
| READ MK_LPAREN MK_RPAREN {if(DEBUG) printf("lhs=read()\n");} 
| FREAD MK_LPAREN MK_RPAREN {if(DEBUG) printf("lhs=fread()\n");}
| function_call {if(DEBUG) printf("lhs=function_call\n");}
;

function_call: ID MK_LPAREN call_param_list MK_RPAREN
;

call_param_list: lhs call_param_list_tail
| CONST call_param_list_tail
|
;

call_param_list_tail: MK_COMMA lhs call_param_list_tail
| MK_COMMA CONST call_param_list_tail
|
;

lhs: ID expr_id_tail expr_member
;


expr_id_tail: MK_LB CONST MK_RB expr_id_tail
| MK_LB ID MK_RB expr_id_tail
|
;

expr_member: MK_DOT lhs
|
;


expr: lhs {if(DEBUG) printf("expr: lhs\n");}
| MK_LPAREN expr MK_RPAREN {if(DEBUG) printf("expr: (expr)\n");}  
| expr binop expr {if(DEBUG) printf("expr: expr binop expr\n");}
| unop expr {if(DEBUG) printf("expr: unop expr\n");}
/*| expr binop CONST  {printf("expr: expr binop CONST\n");}*/
/*| ID  {printf("expr: ID\n");}*/
| CONST {if(DEBUG) printf("expr: CONST\n");}
;

binop: OP_AND | OP_OR | OP_EQ | OP_NE | OP_LT | OP_GT | OP_LE | OP_GE | 
       OP_PLUS | OP_MINUS | OP_TIMES | OP_DIVIDE
;

unop: OP_NOT | OP_MINUS
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
| OP_ASSIGN CONST
|
;

type: INT | FLOAT | VOID | TYPEDEF_NAME | STRUCT ID struct_or_null_block | STRUCT struct_block
;

struct_or_null_block:
MK_LBRACE decl_list MK_RBRACE
|
;

struct_block: MK_LBRACE decl_list MK_RBRACE;

type_decl: struct_decl | typedef_decl;

struct_decl: STRUCT ID MK_LBRACE decl_list MK_RBRACE;

typedef_decl: TYPEDEF type ID 
            { 
if (DEBUG) 
    printf("inserting %s\n", $3); 
insert_type($3); }
;

%%

#include "lex.yy.c"
main (argc, argv)
int argc;
char *argv[];
  {
        init();
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
