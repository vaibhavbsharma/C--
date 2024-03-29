/* ===== Definition Section ===== */

%{
#include "common.h"
#include <stdio.h>
#include <stdbool.h>
#include <stdlib.h>
#include <string.h>
#include "typetable.h"
#include "symboltable.h"
#include "codegen.h"

static int linenumber = 1;
int cur_scope = 0;

// Keep track of how many local variables have been declared
// and reset at the end of each function
 int local_var_counter = 1;

// label number, for code generation
int label_no = 0;

intstack_t *label_stack;

bool match_type(symtab_entry *s1, symtab_entry *s2) {
  if(!s1) debug("match_type: s1 is NULL, panic!");
  if(!s2) debug("match_type: s2 is NULL, panic!");
    if (s1->type != s2->type) {
        return false;
    } else {
        return true;
    }
// TODO: other type matching. e.g. between arrays or structs.
    if (s1->kind == ARRAY && s2->kind == ARRAY) {
        if (s1->dim == s2->dim) {
            return true;
        }
    }
}

symtab_entry *current_function; // current function symbol
%}

%union {
  symtab_entry *s;
  int const_int;
  double const_float;
  char str[100];
  type_enum type_info;
  struct_field *sf;
  mytype_t *type_obj;
}

%type <type_info> param_type type  
%type <s> var_decl id_list id_tail expr assign_expr_tail assign_expr struct_var_decl
%type <s> lhs
%type <s> function_call param call_param_list call_param_list_tail
%type <s> param_var_decl param_list param_list_tail array_subscript subscript_expr
%type <sf> struct_decl_list 
%type <type_obj> struct_decl;
%type <str> binop

%token <s> ID
%token <s> ICONST
%token <s> FCONST
%token <str> SCONST
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
%token <str>  OP_OR   
%token <str>  OP_AND  
%token <str>  OP_NOT  
%token <str>  OP_EQ   
%token <str>  OP_NE   
%token <str>  OP_GT   
%token <str>  OP_LT   
%token <str>  OP_GE   
%token <str>  OP_LE   
%token <str>  OP_PLUS 
%token <str>  OP_MINUS        
%token <str>  OP_TIMES        
%token <str>  OP_DIVIDE       
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
    debug("parser::global_decl: decl_list function_decl");
}
| function_decl
;

function_decl 
    : type ID MK_LPAREN {
        debug("scope++"); 
        cur_scope++; 
        $2->type = $<type_info>1;
        $2->kind = FUNCTION;
        current_function = $<s>2;
 } param_list MK_RPAREN MK_LBRACE { gen_func_prolog($2->name); } block MK_RBRACE {
      
        // count the number of parameters
        int n_param = 0;
        if ($5) {
            //Q: I don't know why the `param_list` is $5 instead of $4.
            symtab_entry *handle = $<s>5;
            do {
                debug("\tparam (name: %s, type: %d)", 
                        handle->name, handle->type);
                handle = handle->next;
                n_param ++;
            } while (handle);
        }
        $2->n_param = n_param;
        // attach the parameter list to the function id.
        $2->next = $<s>5;

        // warning: order matters! do not `delete_scope` earlier or later.
        delete_scope(cur_scope--);
        if (!insert_symbol($2, cur_scope)) {
            yyerror("variable %s is already declared", $2);
        } else {
            symtab_entry *s = lookup_symtab($2->name, cur_scope);
            debug("function_decl: symbol inserted.");
            debug("\t(name: %s, scope: %d, type: %d, kind: %d, n_param: %d)", 
                    s->name, s->scope, s->type, s->kind, s->n_param);
            symtab_entry *handle = s;
            while ((handle = handle->next)) {
                debug("\tparameter %s: type %d", handle->name, handle->type);
            }
        }
	gen_func_epilog($2->name);
	local_var_counter=1;
    }
;

block:   decl_list stmt_list  {debug("parser::block decl_list stmt_list");} 
|
;

stmt_list: stmt_list stmt  {debug("stmt_list: stmt_list stmt");}
|
;

param_list
    : param_var_decl param_list_tail {
        $1->next = $2 ? $2 : NULL;
        $$ = $1;
        debug("param_list: param_var_decl: %s, param_list_tail: %s", $1, $2);
    }
    | /* empty */ { $$ = NULL; }
; 

param_list_tail
    : MK_COMMA param_var_decl param_list_tail
    {
        debug("param_list_tail: , %s %s", $2, $3);
        $2->next = $3 ? $3 : NULL;
        $$ = $2;
    }
    | /* empty */
    {
        $$ = NULL;
    }
;

param_var_decl : param_type ID array_subscript
{
    //Add id in $2 to symbol table with type and scope info
    $2->type = $<type_info>1;
    $2->kind = PARAMETER;
    if (!insert_symbol($2, cur_scope)) {
        yyerror("variable %s is already declared", $2);
    } else {
        symtab_entry *s = lookup_symtab($2->name, cur_scope);
        debug("param_var_decl: symbol inserted. (name: %s, scope: %d, type: %d, kind: %d)", 
            s->name, s->scope, s->type, s->kind);
    }
    $$ = $2;
}
;

array_subscript 
    : MK_LB subscript_expr MK_RB array_subscript
    {
        debug("array_subscript: [ subscript_expr ] array_subscript");
        if ($4) {
            $<s>$->dim = $<s>4->dim + 1;
        } else {
            $<s>$->dim = 1;
        }
        // check if the subscript is of integer type
        if ($2->type != INT_TY) {
            yyerror("Array subscript is not an integer");
        }
    }
    | /* empty */ {
        $$ = NULL; 
    }
;

subscript_expr : ID | ICONST | FCONST | expr | /* empty */;

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
| while_stmt 
| for_stmt
|  assign_expr MK_SEMICOLON {debug("stmt: assign_expr");} 
| write_stmt MK_SEMICOLON 
| write_lhs_stmt MK_SEMICOLON 
| return_stmt MK_SEMICOLON
| function_call MK_SEMICOLON
| error { debug("Error in stmt production"); }
/* other C-- statements */
;

block_stmt 
    : MK_LBRACE {
        cur_scope++; 
        emit("\tnop");
    } block MK_RBRACE {
        cur_scope--;
    }

if_stmt 
    : IF MK_LPAREN expr { // simple IF (slide8-page21)
/*
TJ Note:
    I first tried to refactor the rule as appears on the lecture slide,
    but it didn't work possibly due to some parser conflict. Instead,
    I tried to come up with a clever way of code generation that works in both
    cases either when `else_part` is nullable or not. But still not sure if it
    would work as expected..
*/
        // #gen_test
        emit("\tbeqz %s, _Lelse%d", $3->place, ++label_no);
        s_push(label_stack, label_no);
    } MK_RPAREN stmt {
        // #gen_label
        emit("\tj _Lexit%d", s_get(label_stack));
        emit("_Lelse%d:", s_get(label_stack));
    } else_part {
        emit("_Lexit%d:", s_get(label_stack));
        s_pop(label_stack);
    }

else_part 
    : ELSE stmt 
    | /* empty */ 
;

while_stmt  : 
WHILE MK_LPAREN { 
  /*gen_head*/ 
  debug("stmt: while(expr) stmt");
  emit("_Test%d: ",++label_no); 
  s_push(label_stack, label_no);
} expr { 
  /*gen_test*/ 
  emit("\tbeqz %s, _Lexit%d #%s",$<s>4->place, label_no, $<s>4->name);
} MK_RPAREN stmt {
  /* gen_label */
  emit("\tj _Test%d", s_get(label_stack));
  emit("_Lexit%d: ", s_get(label_stack));
  s_pop(label_stack);
}

for_stmt    : FOR MK_LPAREN assign_expr MK_SEMICOLON expr MK_SEMICOLON assign_expr MK_RPAREN stmt 

write_stmt  : WRITE MK_LPAREN SCONST MK_RPAREN {
  debug("stmt: write string constant called at %d", linenumber);
  char *sconst_label = push_string_label($<str>3);
  emit("\tla $a0, %s",sconst_label);
  emit("\tli $v0, 4");
  emit("\tsyscall");
  free(sconst_label);
}

write_lhs_stmt  : WRITE MK_LPAREN lhs MK_RPAREN {
  debug("stmt: write lhs called at %d", linenumber);
  int reg;
  char reg_str[3];
  if(is_temp_reg($3->place)) {
    strcpy(reg_str,$3->place);
  }
  else {
    reg=get_free_temp_reg();
    sprintf(reg_str,"$%d",reg);
    emit("\tlw %s, %s # %s",reg_str,$3->place,$3->name);
  }
  emit("\tmove $a0, %s",reg_str);
  mark_temp_reg_free(reg_str);
  mark_temp_reg_free($3->place);
  emit("\tli $v0, 1");
  emit("\tsyscall");
}

return_stmt 
    : RETURN expr {
        if (!current_function) {
            yyerror("Misplaced return statement");
        }
        debug("stmt: return expr;");
        if ($2->type != current_function->type) {
            debug("type of current function %s: %d, return type: %d",
                    current_function->name, current_function->type, $2->type);
            yyerror("Incompatible return type.");
        }
	int reg;
	char reg_str[3];
	if(!is_temp_reg($<s>2->place)) {
	  reg=get_free_temp_reg();
	  sprintf(reg_str,"$%d",reg);
	  emit("\tlw %s, %s # %s",reg_str,$2->place,$2->name);
	}
	else {
	  strcpy(reg_str,$<s>2->place);
	}
	emit("\tmove $v0, %s",reg_str);
	mark_temp_reg_free($<s>2->place);
	mark_temp_reg_free(reg_str);
        $<s>$ = $2;
    }

assign_expr :  lhs OP_ASSIGN assign_expr_tail 
{
    if (!match_type($<s>1, $<s>3)  
     && !($<s>1->type==FLOAT_TY && $<s>3->type==INT_TY) )
        yyerror("type expression mismatch with assignment (=) ");
    if($<s>1->type == STRUCT_TY && $<s>3->type == STRUCT_TY) {
      if($<s>1->type_ptr != $<s>3->type_ptr) {
	yyerror("Incompatible type");
      }
    }
    $$=$<s>1;
    int reg;
    char reg_str[3];
    if(!is_temp_reg($<s>3->place)) {
      reg=get_free_temp_reg();
      sprintf(reg_str,"$%d",reg);
      emit("\tlw %s, %s # %s",reg_str,$3->place,$3->name);
    }
    else {
      strcpy(reg_str,$<s>3->place);
    }
    emit("\tsw %s, %s # %s, %s", reg_str, $<s>1->place, $<s>3->name, $<s>1->name);
    mark_temp_reg_free($<s>3->place);
    mark_temp_reg_free(reg_str);
}
;

assign_expr_tail    : expr  {
  debug("assign_expr_tail = expr %s", $<s>1->name);
  $$=$1;
}
| READ MK_LPAREN MK_RPAREN {
  debug("lhs=read()");
  emit("\tli $v0, 5");
  emit("\tsyscall");
  $$=create_symbol("read_syscall",0);
  strcpy($$->place,"$v0");
  $$->type=INT_TY;
} 
| FREAD MK_LPAREN MK_RPAREN {debug("lhs=fread()");}
| function_call {debug("lhs=function_call");$$=$1;}
        ;

function_call
    : ID MK_LPAREN call_param_list MK_RPAREN 
    {
        debug("function_call : ID ( call_param_lilst )");
        symtab_entry *s = lookup_symtab($<s>1->name,0);
        //The strcmp comparison allows recursive functions
	//but prevents arg counting check on recursive functions
	if (!s && strcmp($1->name, current_function->name)!=0) { 
            yyerror("ID undeclared");
        } else {
            $$ = s; //TODO maybe free the symtab_entry in $1 ?
        }
        if ($3 && s!=NULL) {
            /* check if the number of arguments matches */
            int cnt = 1;
            symtab_entry *handle = $<s>3;
            while (handle->next) {
                handle = handle->next;
                cnt++;
            }
            debug("\tn_param: %d, expected: %d", cnt, s->n_param);
            if (cnt > s->n_param) {
                yyerror("too many arguments to function (function)");
            } else if (cnt < s->n_param) {
                yyerror("too few arguments to function (function)");
            }
        }
	emit("\taddi $sp, $sp, -4");
	emit("\tjal %s",$<s>1->name);
	emit("\taddi $sp, $sp, 4");
	$$=$1;
	if(!s)
	  $$->type = current_function->type;
	else
	  $$->type = s->type;
	strcpy($$->place,"$v0");
    }
;

call_param_list 
    : param call_param_list_tail
    {
        debug("call_param_list : param call_param_list_tail");
        if ($2) {
            $1->next = $2;
        } else {
            $1->next = NULL;
        }
        $$ = $1;
    }
    | /* empty */ {$$ = NULL;}
    ;

call_param_list_tail
    : MK_COMMA param call_param_list_tail
    {
        debug("call_param_list_tail : , param call_param_list_tail");
        if ($3) {
            $2->next = $3;
        } else {
            $2->next = NULL;
        }
        $$ = $2;
    }
    | /* empty */ {$$ = NULL;}
    ;

param : lhs | ICONST | FCONST;

lhs:  ID array_subscript MK_DOT ID {
  debug("lhs: ID [] . ID");
  symtab_entry *s = lookup_symtab_prevscope($<s>1->name,cur_scope);
  if(!s) yyerror("ID undeclared");
  else $$=s;//TODO maybe free the symtab_entry in $1 ?
}
| ID array_subscript {
  debug("lhs: ID []");
  symtab_entry *s = lookup_symtab_prevscope($<s>1->name,cur_scope);
  if(!s) yyerror("ID undeclared");
  else $$=s;//TODO maybe free the symtab_entry in $1 ?
}
| ID MK_DOT ID {
  debug("lhs: ID . ID");
  symtab_entry *s = lookup_symtab_prevscope($<s>1->name,cur_scope);
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
  debug("lhs: ID entering with $1 = %p", $<s>1);
  debug("lhs: ID entering with $1->type = %d", $<s>1->type);
  symtab_entry *s1 = lookup_symtab($<s>1->name,cur_scope);
  if(s1==$<s>1) debug("lhs: ID the pointers are equal");
  if(s1 == NULL) debug("lhs: ID lookup_symtab failed");
  else {
    debug("lhs: ID s = %p",s1);
    debug("lhs: ID %s ", s1->name);
    debug("lhs: ID %d ", s1->type);
  }
  fflush(stdout);
  if(!s1) {
    s1=lookup_symtab_prevscope($<s>1->name,0);
  }
  if(!s1) yyerror("lhs: ID ID undeclared");
  else $<s>$=s1;
  fflush(stdout);
  debug("lhs: ID %s %d", $<s>$->name, $<s>$->type);
}
;

expr    :  lhs {debug("expr: lhs");  $$=$<s>1;}
| MK_LPAREN expr MK_RPAREN {debug("expr: ( expr ) "); $$=$<s>2;}
| expr binop expr 
{
  debug("expr: expr binop expr");
  if(($<s>1->type != $<s>3->type) && !($<s>1->type==INT_TY && $<s>3->type==FLOAT_TY)
     && !($<s>1->type==FLOAT_TY && $<s>3->type==INT_TY)) {
    yyerror("type expression mismatch with binary operator");
    //TODO: get these %s's to work
    //yyerror("%s and %s type expression mismatch",$1,$3);
  }
  debug("expr: expr binop expr after type check");
  if($1 -> type == STRUCT_TY || $3 -> type == STRUCT_TY) {
    yyerror("Invalid operands to binary operator");
  }
  /* At this point, it is not ok to return $$ as $1 because we want to update
     $$->place but we do NOT want to update $1->place */
  $$=copy_symbol($1);
  
  /* Code Generation */
  emit("\t#%s %s %s",$1->name, $2, $3->name);
  char reg1_str[3], reg2_str[3], reg_dest_str[3];
  int reg1,reg2;
  if(is_temp_reg($1->place)) {
    strcpy(reg1_str,$1->place);
  }
  else {
    reg1=get_free_temp_reg();
    sprintf(reg1_str,"$%d",reg1);
    emit("\tlw %s, %s # %s",reg1_str,$1->place,$1->name);
  }
 
  if(is_temp_reg($3->place)) {
    strcpy(reg2_str,$3->place);
  }
  else {
    reg2=get_free_temp_reg();
    sprintf(reg2_str,"$%d",reg2);
    emit("\tlw %s, %s # %s", reg2_str, $3->place, $3->name);
  }
  
  int reg_dest = get_free_temp_reg();
  sprintf(reg_dest_str,"$%d",reg_dest);
  debug("binop = %s",$<str>2);
  char op_str[5];
  if($<str>2[0]=='-') {
    strcpy(op_str,"sub");
  }
  else if($<str>2[0]=='+') {
    strcpy(op_str,"add");
  }
  else if($<str>2[0]=='*') {
    strcpy(op_str,"mul");
  }
  else if($<str>2[0]=='/') {
    strcpy(op_str,"div");
  }
  else if(strcmp($<str>2,"&&")==0) {
    strcpy(op_str,"and");
  }
  else if(strcmp($<str>2,"||")==0) {
    strcpy(op_str,"or");
  }
  else if(strcmp($<str>2,"<=")==0) {
    strcpy(op_str,"sle");
  }
  else if(strcmp($<str>2,">=")==0) {
    strcpy(op_str,"sge");
  }
  else if($<str>2[0]=='<') {
    strcpy(op_str,"slt");
  }
  else if($<str>2[0]=='>') {
    strcpy(op_str,"sgt");
  }
  else if(strcmp($<str>2,"==")==0) {
    strcpy(op_str,"seq");
  }
  else if(strcmp($<str>2,"!=")==0) {
    strcpy(op_str,"sne");
  }
  else  /* Fallback for now */ {
    yyerror("operator not supported");
  }

  emit("\t%s %s, %s, %s",op_str,reg_dest_str,reg1_str,reg2_str);
  
  strcpy($$->place,reg_dest_str);
  
  mark_temp_reg_free(reg1_str);
  mark_temp_reg_free(reg2_str);
  
  /* If reg1_str is same as $1->place, this duplicates the free marking of the 
     temp register, but that should be ok.
     ditto for reg2_str*/
  mark_temp_reg_free($1->place);
  mark_temp_reg_free($3->place);
  debug("expr binop expr returning %s",$$->place);
}
| unop expr {$$=$2;}
| ICONST {
  $<s>$=$<s>1;
  int reg=get_free_temp_reg();
  char reg_str[3];
  sprintf(reg_str,"$%d",reg);
  emit("\tli %s, %s",reg_str ,$1->name);
  strcpy($$->place,reg_str);
}
| FCONST {$$=$1;}
| function_call {debug("expr: function_call");$$=$1;}
;

binop: 
OP_AND {strcpy($<str>$,$<str>1);}
| OP_OR {strcpy($<str>$,$<str>1);}
| OP_EQ {strcpy($<str>$,$<str>1);}
| OP_NE {strcpy($<str>$,$<str>1);}
| OP_LT {strcpy($<str>$,$<str>1);}
| OP_GT {strcpy($<str>$,$<str>1);}
| OP_LE {strcpy($<str>$,$<str>1);}
| OP_GE {strcpy($<str>$,$<str>1);}
| OP_PLUS {strcpy($<str>$,$<str>1);}
| OP_MINUS {strcpy($<str>$,$<str>1);}
| OP_TIMES {strcpy($<str>$,$<str>1);}
| OP_DIVIDE {strcpy($<str>$,$<str>1);}
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
		char stack_entry[ID_SIZ];
                do {
                    handle->type = $<type_info>1;
                    if (!insert_symbol(handle, cur_scope)) {
                        yyerror("variable %s is already declared", $2);
                    } else {
                        symtab_entry *s = lookup_symtab(handle->name, cur_scope);
			if(cur_scope>0) {
			  sprintf(stack_entry,"-%d($fp)",local_var_counter*4);
			  local_var_counter++;
			}
			else {
			  sprintf(stack_entry,"____%s",s->name);
			  push_string_label(stack_entry);
			}
			strcpy(s->place,stack_entry);
                        debug("var_decl: type id_list symbol inserted. (address: %p, name: %s, scope: %d, type: %d, kind: %d, place: %s)", s, s->name, s->scope, s->type, s->kind, s->place);
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

id_list 
    : ID array_subscript id_tail {
        if ($2) {
            $<s>1->kind = ARRAY;
            $<s>1->dim = $2->dim;
            debug("parser::id_list: %s is a %d-dim array", $1->name, $1->dim);
        }
        $$ = $1;
    }
    | id_list MK_COMMA ID array_subscript id_tail {
        if ($4) {
            $3->kind = ARRAY;
            $3->dim = $4->dim;
            debug("id_list: %s is a %d-dim array", $3->name, $3->dim);
        }
        // append at the end of the list ($1)
        symtab_entry *handle = $<s>1;
        while (handle->next) {
            handle = handle->next;
        } 
        handle->next = $3;
        $$ = $1;
    }
;

id_tail 
    : OP_ASSIGN ICONST 
    | OP_ASSIGN FCONST
    | /* empty */ { 
        $$ = NULL; 
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
int main (int argc, char *argv[]) {
    label_stack = s_init();
    init_typetab();
    init_symtab();
    yyin = fopen(argv[1],"r");
    yyout = fopen(argv[2], "w");
    if (!yyout) {
        debug("output file is not specified. "
                "code will be emitted to <stdout>.\n");
        yyout = stdout;
    }
    yyparse();
    debug("%s\n", "Parsing completed. No errors found.");
} 


yyerror (char *mesg)
{
	printf("%s\t%d\t%s\t%s\n", "Error found in Line ", linenumber, "next token: ", yytext );
  	printf("%s\n", mesg);
  	exit(1);
}

