/* ===== Definition Section ===== */

%{
#include "common.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "typetable.h"
#include "symboltable.h"
static int linenumber = 1;
 int cur_scope=0;
%}

%union {
  symtab_entry *s;
  int const_int;
  double const_float;
  char* str;
  type_enum type_info;
  struct_field *sf;
  mytype_t *type_obj;
}

%type <type_info> param_type type  
%type <s> var_decl id_list id_tail expr assign_expr_tail lhs assign_expr expr_member struct_var_decl
%type <s> param_var_decl param_id_list function_call
%type <sf> struct_decl_list 
%type <type_obj> struct_decl;

%token <s> ID
%token <s> ICONST
%token <s> FCONST
%token SCONST
%token <type_info> TYPEDEF_NAME
%token <str> STRUCT_NAME
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

function_decl : type ID MK_LPAREN  {cur_scope++;} param_list MK_RPAREN MK_LBRACE  block MK_RBRACE {
    delete_scope(cur_scope--);
    $<s>2->type = $<type_info>1;
    $<s>2->kind = FUNCTION;
    if (!insert_symbol($2, cur_scope)) {
        yyerror("variable %s is already declared", $2);
    } else {
        symtab_entry *s = lookup_symtab($2->name, cur_scope);
        debug("function_decl: symbol inserted. (name: %s, scope: %d, type: %d, kind: %d)", s->name, s->scope, s->type, s->kind);
    }
}
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

param_var_decl : param_type param_id_list {
                //Add id in $2 to symbol table with type and scope info
                symtab_entry *handle = $<s>2;
                handle->type = $<type_info>1;
                if (!insert_symbol(handle, cur_scope)) {
                    yyerror("variable %s is already declared", $2);
                } else {
                    symtab_entry *s = lookup_symtab(handle->name, cur_scope);
                    debug("param_var_decl: symbol inserted. (name: %s, scope: %d, type: %d, kind: %d)", s->name, s->scope, s->type, s->kind);
                }
                $2->type = $1;
                }
;

param_id_list: ID param_id_tail {$$=$1;} 
;

param_id_tail: MK_LB ICONST MK_RB param_id_tail
| MK_LB MK_RB param_id_tail
|
;

param_type: 
INT 
| FLOAT 
| VOID 
| STRUCT ID {
  debug("parser::param_type STRUCT ID");
  //TODO Check if ID has already been declared as a struct before in the type table
}
;

stmt    : block_stmt
        | if_stmt
        | while_stmt MK_SEMICOLON
        | for_stmt
        | assign_expr MK_SEMICOLON {debug("stmt: assign_expr");}
        | write_stmt MK_SEMICOLON 
        | write_lhs_stmt MK_SEMICOLON 
        | return_stmt MK_SEMICOLON
        | error { debug("Error in stmt production"); }
        /* other C-- statements */
        ;

block_stmt  : MK_LBRACE {cur_scope++;} block MK_RBRACE {cur_scope--;}

if_stmt     : IF MK_LPAREN expr MK_RPAREN stmt else_tail 

while_stmt  : WHILE MK_LPAREN expr MK_RPAREN stmt {debug("stmt: while(expr) stmt");}

for_stmt    : FOR MK_LPAREN assign_expr MK_SEMICOLON expr MK_SEMICOLON assign_expr MK_RPAREN stmt 

write_stmt  : WRITE MK_LPAREN SCONST MK_RPAREN {debug("stmt: write string constant called at %d", linenumber);}

write_lhs_stmt  : WRITE MK_LPAREN lhs MK_RPAREN {debug("stmt: write lhs called at %d", linenumber);}

return_stmt : RETURN expr {debug("stmt: return expr;");}

else_tail   : ELSE stmt {debug("stmt: if(expr) { stmt } else { stmt}");} 
            |
            ;

assign_expr : lhs OP_ASSIGN assign_expr_tail 
    {
      if($1->type != $3->type) {
        yyerror("type expression mismatch with =");
      }
      if($1->type == STRUCT_TY && $3->type == STRUCT_TY) {
	if($1->type_ptr != $3->type_ptr) {
	  yyerror("Incompatible type");
	}
      }
      $$=$1;
    }
;

assign_expr_tail    : expr  {debug("lhs=expr");$$=$1;}
                    | READ MK_LPAREN MK_RPAREN {debug("lhs=read()");} 
                    | FREAD MK_LPAREN MK_RPAREN {debug("lhs=fread()");}
| function_call {debug("lhs=function_call");$$=$1;}
                    ;

function_call: ID MK_LPAREN call_param_list MK_RPAREN 
{
    symtab_entry *s=lookup_symtab($<s>1->name,0);
    if (!s) { 
        yyerror("ID undeclared");
    } else {
        $$=s;//TODO maybe free the symtab_entry in $1 ?
    }
}
;

call_param_list : lhs call_param_list_tail
                | ICONST call_param_list_tail
                | FCONST call_param_list_tail
                |
                ;

call_param_list_tail    : MK_COMMA lhs call_param_list_tail
                        | MK_COMMA ICONST call_param_list_tail
                        | MK_COMMA FCONST call_param_list_tail
                        |
                        ;

lhs: ID expr_id_tail MK_DOT ID {
  symtab_entry *s = lookup_symtab($<s>1->name,cur_scope);
  if(!s) s=lookup_symtab($<s>1->name,0);
  if(!s) yyerror("ID undeclared");
  else $$=s;//TODO maybe free the symtab_entry in $1 ?
}
| ID expr_id_tail {
  symtab_entry *s = lookup_symtab($<s>1->name,cur_scope);
  if(!s) s=lookup_symtab($<s>1->name,0);
  if(!s) yyerror("ID undeclared");
  else $$=s;//TODO maybe free the symtab_entry in $1 ?
}
| ID MK_DOT ID {
  symtab_entry *s = lookup_symtab($<s>1->name,cur_scope);
  if(!s) s=lookup_symtab($<s>1->name,0);
  if(!s) yyerror("ID undeclared");
  else $$=s;//TODO maybe free the symtab_entry in $1 ?
  if(s->type != STRUCT_TY) {
    yyerror("%s is not of type structure");
  }
  if(s->type_ptr != NULL) {
    mytype_t *type_obj = (mytype_t *)s->type_ptr;
    struct_field *sf=type_obj->head;
    int found=0;
    while(sf != NULL) {
      if(strcmp(sf->f_name,$<s>3->name)==0) {
	found=1;
	$$=s;
	$<s>$->type=sf->f_type;
      }
      debug("field %s(%d)",sf->f_name,sf->f_type);
      sf = sf -> next; 
    }
    if(found == 0) { 
      debug("Structure %s has no member named %s",type_obj->name,$<s>3->name);
      yyerror("missing member in structure");
    }
  }
}
| ID {
  symtab_entry *s = lookup_symtab($<s>1->name,cur_scope);
  if(!s) s=lookup_symtab($<s>1->name,0);
  if(!s) yyerror("lhs: ID ID undeclared");
  else $$=s;//TODO maybe free the symtab_entry in $1 ?
}
;

expr_id_tail    : MK_LB ICONST MK_RB expr_id_tail
                | MK_LB ID MK_RB expr_id_tail
                ;



expr    : lhs {}
        | MK_LPAREN expr MK_RPAREN {}
        | expr binop expr 
{
  debug("expr: expr binop expr");
  if($1->type != $3->type) {
    yyerror("type expression mismatch with binary operator");
    //TODO: get these %s's to work
    //yyerror("%s and %s type expression mismatch",$1,$3);
  }
  if($1 -> type == STRUCT_TY || $3 -> type == STRUCT_TY) {
    yyerror("Invalid operands to binary operator");
  }
  $$=$1;
}
        | unop expr {$$=$2;}
        | ICONST {$$=$1;}
        | FCONST {$$=$1;}
        ;

binop: OP_AND | OP_OR | OP_EQ | OP_NE | OP_LT | OP_GT | OP_LE | OP_GE | 
       OP_PLUS | OP_MINUS | OP_TIMES | OP_DIVIDE
;

unop: OP_NOT | OP_MINUS
;

decl_list   : decl_list decl  {debug("parser::decl_list decl_list decl");}
            | decl {debug("parser::decl_list decl");} 
            |  {debug("parser::decl_list empty string");} 
            ;

decl    : 
type_decl MK_SEMICOLON {debug("parser::decl type_decl ;"); } 
| var_decl  MK_SEMICOLON {debug("parser::decl var_decl ;"); }
;

var_decl    : type id_list 
            {
                //Add id in $2 to symbol table with type and scope info
                symtab_entry *handle = $2;
                do {
                    handle->type = $<type_info>1;
                    if (!insert_symbol(handle, cur_scope)) {
                        yyerror("variable %s is already declared", $2);
                    } else {
                        symtab_entry *s = lookup_symtab(handle->name, cur_scope);
                        debug("var_decl: type id_list symbol inserted. (name: %s, scope: %d, type: %d, kind: %d)", s->name, s->scope, s->type, s->kind);
                    }
                } while((handle = handle->next));
                $2->type = $1;
		$$=$2;
            }

| STRUCT STRUCT_NAME id_list {
  debug("parser::var_decl STRUCT STRUCT_NAME %s",$<str>2);
  mytype_t *struct_type_obj = get_type_obj($<str>2);
  //Add id in $2 to symbol table with type and scope info
  symtab_entry *handle = $<s>3;
  do {
    handle->type = STRUCT_TY;
    handle->type_ptr = (void*) struct_type_obj;
    if (!insert_symbol(handle, cur_scope)) {
      yyerror("variable %s is already declared", handle->name);
    } else {
      symtab_entry *s = lookup_symtab(handle->name, cur_scope);
      debug("var_decl: STRUCT STRUCT_NAME id_list symbol inserted. (name: %s, scope: %d, type: %d, kind: %d)", s->name, s->scope, s->type, s->kind);
    }
  } while((handle = handle->next));
  $3->type = STRUCT_TY;
  $$=$3;
}
| STRUCT struct_block id_list {
  debug("parser::type STRUCT struct_block");
}
| struct_decl id_list {
  debug("parser::type struct_decl"); $<type_info>$=STRUCT_TY; 
  //Add id in $2 to symbol table with type and scope info
  symtab_entry *handle = $2;
  do {
    handle->type = STRUCT_TY;
    handle->type_ptr = (void*) $<type_obj>1;
    if (!insert_symbol(handle, cur_scope)) {
      yyerror("variable %s is already declared", $2);
    } else {
      symtab_entry *s = lookup_symtab(handle->name, cur_scope);
      debug("var_decl: struct_decl id_list symbol inserted. (name: %s, scope: %d, type: %d, kind: %d)", s->name, s->scope, s->type, s->kind);
    }
  } while((handle = handle->next));
  $2->type = STRUCT_TY;
  $$=$2;
}
;

id_list : ID id_tail
        {
	  debug("parser::id_list ID id_tail");
	  /*if ($2 && $2->dim > 0) {
                $1->kind = ARRAY;
                $$->dim= $2->dim;
                debug("id_list: ID %s is %d-dim array", $1->name, $1->dim);
		}*/
            $$ = $1;
        }
        | id_list MK_COMMA ID id_tail 
        {
	  debug("parser::id_list id_list , ID id_tail");
	  /*if ($4->dim > 0) {
                $3->kind = ARRAY;
                $3->dim= $4->dim;
                debug("id_list: ID %s is %d-dim array", $3->name, $3->dim);
		}*/
            // append at the end of the list ($1)
            symtab_entry *handle = $<s>1;
            while (handle->next) {
                handle = handle->next;
            } 
            handle->next = $3;
            $$ = $1;
        }
        ;

id_tail : MK_LB ICONST MK_RB id_tail 
        {   
	  //$<s>$->dim= $<s>4->dim+ 1;
        }
        | OP_ASSIGN ICONST 
        | OP_ASSIGN FCONST
        | { // nullable, no dimension
	  //if($<s>$ != NULL) 
	  //  $<s>$->dim = 0; 
        }
        ;

type    : 
INT  {debug("parser::type INT");}
| FLOAT {debug("parser::type FLOAT");} 
| VOID {debug("parser::type VOID");} 
| TYPEDEF_NAME {debug("parser::type TYPEDEF_NAME");$<type_info>$=TYPEDEF_TY;} 
;

struct_or_null_block    : 
MK_LBRACE struct_decl_list MK_RBRACE {debug("parser::struct_or_null_block { struct_decl_list }");}
| {debug("parser::struct_or_null_block empty string");}
;

struct_block    : 
MK_LBRACE struct_decl_list MK_RBRACE {debug("parser::struct_block { struct_decl_list }");}
;


struct_decl     : 
STRUCT ID MK_LBRACE struct_decl_list MK_RBRACE {
  debug("parser::struct_decl STRUCT ID { struct_decl_list }");
  mytype_t *tmp = insert_type($<s>2->name,STRUCT_TY); //maybe free $<s>3 here ?
  tmp->head = $<sf>4;
  entry_t **tmp_hashtable = h_init();
  struct_field *sf_tmp = $<sf>4;
  while(sf_tmp!=NULL) {
    void *v_tmp = h_get(tmp_hashtable,sf_tmp->f_name);
    //debug("parser::struct_decl STRUCT ID {struct_decl_list } with name = %s",sf_tmp->f_name);
    if(v_tmp != NULL) {
      yyerror("Duplicate member (name)");
    }
    h_insert(tmp_hashtable,sf_tmp->f_name, sf_tmp);
    sf_tmp = sf_tmp -> next;
  }
  $$=tmp;
}
;

struct_decl_list   : 
struct_decl_list type_decl MK_SEMICOLON {debug("parser::struct_decl_list struct_decl_list type_decl");}
| type_decl MK_SEMICOLON {debug("parser::struct_decl_list type_decl");} 
| struct_decl_list struct_var_decl MK_SEMICOLON {
  debug("parser::struct_decl_list struct_decl_list struct_var_decl ;");
  struct_field *head = $<sf>1;
  while(head->next != NULL) head = head->next;
  struct_field *sf = create_field($<s>2->name, $<s>2->type);
  head->next = sf; 
  symtab_entry *s = $<s>2->next;
  while(s != NULL) {
    struct_field *sf_new = create_field(s->name, s->type);
    sf->next = sf_new;
    sf = sf_new;
    s = s -> next;
  }  
  $$=$1;
}
| struct_var_decl MK_SEMICOLON {
  debug("parser::struct_decl_list struct_var_decl ;");
  struct_field *sf = create_field($<s>1->name, $<s>1->type);
  struct_field *ret;
  ret=sf;
  symtab_entry *s = $<s>1->next;
  while(s != NULL) {
    struct_field *sf_new = create_field(s->name, s->type);
    sf->next = sf_new;
    sf = sf_new;
    s = s -> next;
  }
  $$=ret;
  struct_field *sf_t = $$;
  while(sf_t != NULL){
    debug("struct_decl_list: struct_var_decl ; %s(%d)",sf_t->f_name, sf_t->f_type);
    sf_t = sf_t -> next;
  }
} 
;

type_decl       : 
struct_decl {debug("parser::type_decl struct_decl"); } 
| typedef_decl {debug("parser::type_decl typedef_decl"); }
;


typedef_decl    : TYPEDEF type ID 
                { 
                    debug("parser::typedef_decl inserting %s", $3->name);
                    insert_type($3->name,TYPEDEF_TY); 
                }
                ;

struct_var_decl    : type id_list 
            {
                //Add id in $2 to symbol table with type and scope info
                symtab_entry *handle = $2;
                do {
		  handle->type = $<type_info>1;
                  debug("struct_var_decl setting type %s(%d)",handle->name, handle->type);  
                } while((handle = handle->next));
                $2->type = $1;
		$$=$2;
            }

| STRUCT STRUCT_NAME id_list {
  debug("parser::type STRUCT STRUCT_NAME %s",$<str>2);
  mytype_t *struct_type_obj = get_type_obj($<str>2);
  //Add id in $2 to symbol table with type and scope info
  symtab_entry *handle = $<s>3;
  do {
    handle->type = STRUCT_TY;
    handle->type_ptr = (void*) struct_type_obj;
  } while((handle = handle->next));
  $3->type = STRUCT_TY;
  $$=$3;
}
| STRUCT struct_block id_list {
  debug("parser::type STRUCT struct_block");
}
| struct_decl id_list {
  debug("parser::type struct_decl"); $<type_info>$=STRUCT_TY; 
  //Add id in $2 to symbol table with type and scope info
  symtab_entry *handle = $2;
  do {
    handle->type = STRUCT_TY;
    handle->type_ptr = (void*) $<type_obj>1;
  } while((handle = handle->next));
  $2->type = STRUCT_TY;
  $$=$2;
}
| STRUCT ID ID {debug("field(%s) undeclared",$<s>3->name);yyerror("field undeclared");}
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


yyerror (char *mesg)
{
	printf("%s\t%d\t%s\t%s\n", "Error found in Line ", linenumber, "next token: ", yytext );
  	printf("%s\n", mesg);
  	exit(1);
}
