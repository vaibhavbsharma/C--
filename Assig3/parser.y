/* ===== Definition Section ===== */

%{
#include "common.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "typetable.h"
#include "symboltable.h"
static int linenumber = 1;
/** a hash table */
 int cur_scope=0;
%}

%union {
  symtab_entry *s;
  int const_int;
  double const_float;
  char* str;
  type_enum type_info;
}

%type <type_info> param_type type 
%type <s> var_decl id_list

%token <s> ID
%token <const_int> ICONST
%token <const_float> FCONST
%token SCONST
%token <type_info> TYPEDEF_NAME
%token <type_info> VOID
%token <type_info> INT
%token <type_info> FLOAT   
%token <type_info> STRUCT  
%token IF
%token ELSE
%token WHILE   
%token FOR
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

program : global_decl_list {
    debug("parser::program");
};

global_decl_list: global_decl_list global_decl {
    debug("parser::global_decl_list");
}
| 
;

global_decl : decl_list function_decl  {
    debug("parser:global_decl: decl_list function_decl");
}
| function_decl
;

function_decl : type ID MK_LPAREN param_list MK_RPAREN MK_LBRACE {cur_scope++;} block MK_RBRACE {cur_scope--;debug("function_decl");}
;

block: decl_list stmt_list  {debug("parser::block decl_list stmt_list");}
|
;

stmt_list: stmt_list stmt  {debug("stmt_list: stmt_list stmt");}
|
;

param_list: 
param_var_decl {debug("param_list: param_var_decl");}
| param_list MK_COMMA param_var_decl {debug("param_list: param_list, param_var_decl");}
|
; 

param_var_decl : param_type param_id_list
;

param_id_list: ID param_id_tail  
;

param_id_tail: MK_LB ICONST MK_RB param_id_tail
| MK_LB MK_RB param_id_tail
|
;

param_type: INT | FLOAT | VOID | STRUCT ID
;

stmt    : MK_LBRACE {cur_scope++;} block MK_RBRACE {cur_scope--;}
        | IF MK_LPAREN expr MK_RPAREN stmt else_tail 
        { debug("stmt: if(expr) stmt"); }
        | WHILE MK_LPAREN expr MK_RPAREN stmt {debug("stmt: while(expr) stmt");}
        | FOR MK_LPAREN assign_expr MK_SEMICOLON expr MK_SEMICOLON assign_expr MK_RPAREN stmt {debug("stmt: for(assign_expr expr expr) stmt");} 
        | assign_expr MK_SEMICOLON {debug("stmt: assign_expr");}
        | WRITE MK_LPAREN SCONST MK_RPAREN MK_SEMICOLON {debug("stmt: write string constant called at %d", linenumber);}
        | WRITE MK_LPAREN lhs MK_RPAREN MK_SEMICOLON {debug("stmt: write lhs called at %d", linenumber);}
        | RETURN expr MK_SEMICOLON {debug("stmt: return expr;");}
        | error { debug("Error in stmt production"); }
        /* other C-- statements */
        ;

else_tail   : ELSE stmt {debug("stmt: if(expr) { stmt } else { stmt}");} 
            |
            ;

assign_expr : lhs OP_ASSIGN assign_expr_tail 
            ;

assign_expr_tail    : expr  {debug("lhs=expr");}
                    | READ MK_LPAREN MK_RPAREN {debug("lhs=read()");} 
                    | FREAD MK_LPAREN MK_RPAREN {debug("lhs=fread()");}
                    | function_call {debug("lhs=function_call");}
                    ;

function_call: ID MK_LPAREN call_param_list MK_RPAREN
;

call_param_list: lhs call_param_list_tail
| ICONST call_param_list_tail
| FCONST call_param_list_tail
|
;

call_param_list_tail: MK_COMMA lhs call_param_list_tail
| MK_COMMA ICONST call_param_list_tail
| MK_COMMA FCONST call_param_list_tail
|
;

lhs: ID expr_id_tail expr_member
;


expr_id_tail: MK_LB ICONST MK_RB expr_id_tail
| MK_LB ID MK_RB expr_id_tail
|
;

expr_member: MK_DOT lhs
|
;


expr    : lhs {}
        | MK_LPAREN expr MK_RPAREN {}
        | expr binop expr {}
        | unop expr {}
        | ICONST {}
        | FCONST {}
        ;

binop: OP_AND | OP_OR | OP_EQ | OP_NE | OP_LT | OP_GT | OP_LE | OP_GE | 
       OP_PLUS | OP_MINUS | OP_TIMES | OP_DIVIDE
;

unop: OP_NOT | OP_MINUS
;

decl_list   : decl_list decl  {}
            | decl 
            |
            ;

decl    : type_decl MK_SEMICOLON 
        | var_decl  MK_SEMICOLON
        ;

var_decl    : type id_list 
            {
                debug("parser::var_decl");
                //Add id in $2 to symbol table with type and scope info
                //$2->type = $1;
                if (!insert_symbol($2, cur_scope)) {
                    yyerror("variable %s is already declared in the same scope", $2);
                } else {
                    $$ = $2;
                }
            }
;

id_list : ID id_tail
        {
            debug("parser::id_list");
            debug("\tID->name: %s", $1->name);
            $$ = $1;
        }
        | id_list MK_COMMA ID id_tail 
        |
        ;

id_tail : MK_LB ICONST MK_RB id_tail 
        | OP_ASSIGN ICONST 
        | OP_ASSIGN FCONST
        |
        ;

type    : INT 
        | FLOAT 
        | VOID 
        | TYPEDEF_NAME 
        | STRUCT ID struct_or_null_block 
        | STRUCT struct_block
        ;

struct_or_null_block    : MK_LBRACE decl_list MK_RBRACE
                        |
                        ;

struct_block    : MK_LBRACE decl_list MK_RBRACE
                ;

type_decl       : struct_decl 
                | typedef_decl
                ;

struct_decl     : STRUCT ID MK_LBRACE decl_list MK_RBRACE;

typedef_decl    : TYPEDEF type ID 
                { 
                    debug("parser::typedef_decl inserting %s", $3->name);
                    insert_type($3->name); 
                }
                ;

%%

#include "lex.yy.c"
main (argc, argv)
int argc;
char *argv[];
  {
    init_typetab();
    init_symtab();
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
