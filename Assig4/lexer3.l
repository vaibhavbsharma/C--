/*lexer file*/

%{
#include <stdio.h>
#include "typetable.h"
#include "common.h"
%}
letter   [A-Za-z]
digit    [0-9]
kwInt    "int"
kwFloat  "float"
kwVoid   "void"
kwIf     "if"
kwElse   "else"
kwWhile  "while"
kwFor	 "for"
kwStruct "struct"
kwUnion  "union"
kwTypedef "typedef"
kwReturn "return"

libRead "read"
libFRead "fread"
libWrite "write"

ID       ({letter})({letter}|{digit}|"_")*
op_assign        "="
op_or   "||"
op_and  "&&"
op_not  "!"
op_eq   "=="
op_ne   "!="
op_lt   "<"
op_gt   ">"
op_le   "<="
op_ge   ">="
op_plus "+"
op_minus "-"
op_times "*"
op_divide "/"
i_constant {digit}+
f_constant {digit}+(("."){digit}+)?
comment	"/*"(([^*])|([*]+[^/*]))*("*")+"/"
s_const \"([^"\n])*\"
ws       [ \t]+
newline  "\n"
mk_lparen "("
mk_rparen ")"
mk_lbrace "{"
mk_rbrace "}"
mk_lsqbrace "["
mk_rsqbrace "]"
mk_comma  ","
mk_semicolon ";"
mk_dot  "."
error    .

%%

{ws}            ;   /* do nothing with whitespace */
{comment}	;
{kwInt}         {
    yylval.type_info = INT_TY; 
    return INT;
    }
{kwFloat}       {
    yylval.type_info = FLOAT_TY; 
    return FLOAT;
    }
{kwVoid}	{
    yylval.type_info = VOID_TY; 
    return VOID;
    }
{kwIf}          return IF;
{kwElse}        return ELSE;
{kwWhile}       return WHILE;
{kwFor}      	return FOR;
{kwStruct}	{
    yylval.type_info = STRUCT_TY; 
    return STRUCT;
    }
{kwUnion}	{
    yylval.type_info = UNION_TY; 
    return STRUCT;
    }
{kwTypedef}     {
    yylval.type_info = TYPEDEF_TY; 
    return TYPEDEF;
    }
{kwReturn}      return RETURN;

{libRead}       return READ;
{libFRead}      return FREAD;
{libWrite}      return WRITE;

{ID} { 
    symtab_entry *s = lookup_symtab(yytext, cur_scope);
    if (!s) {
        yylval.s = create_symbol(yytext, cur_scope);
    } else  {
        yylval.s = s;
        //debug("lexer::ID ID \"%s\" already exists", yytext);
    }
    //debug("ID yytext: %s, yyval.s->name: %s", yytext, yylval.s->name);

    if (is_type_exists(yytext)) {
        type_enum tmp_type = get_type(yytext);
        //Try to set this type_info in the parser
        //yylval.type_info = tmp_type;
        debug("lexer::ID\"%s\" is a user defined type", yytext);
        if (tmp_type == TYPEDEF_TY) {
          debug("lexer::ID\"%s\" is a typedef", yytext);
          return TYPEDEF_NAME;
        }
        if (tmp_type == STRUCT_TY) {
          strcpy(yylval.str,yytext);
          debug("lexer::ID\"%s\" is a struct", yytext);
          return STRUCT_NAME;
        }
        return ID;
    } else {
        return ID; 
    }
    }
{op_assign}     {strcpy(yylval.str, yytext); return OP_ASSIGN; }
{op_and}        {strcpy(yylval.str, yytext); return OP_AND; }
{op_or}         {strcpy(yylval.str, yytext); return OP_OR; }
{op_not}        {strcpy(yylval.str, yytext); return OP_NOT; }
{op_eq}         {strcpy(yylval.str, yytext); return OP_EQ; }
{op_ne}         {strcpy(yylval.str, yytext); return OP_NE; }
{op_lt}         {strcpy(yylval.str, yytext); return OP_LT; }
{op_gt}         {strcpy(yylval.str, yytext); return OP_GT; }
{op_le}         {strcpy(yylval.str, yytext); return OP_LE; }
{op_ge}         {strcpy(yylval.str, yytext); return OP_GE; }
{op_plus}       {strcpy(yylval.str, yytext); return OP_PLUS; }
{op_minus}      {strcpy(yylval.str, yytext); return OP_MINUS; }
{op_times}      {strcpy(yylval.str, yytext); return OP_TIMES; }
{op_divide}     {strcpy(yylval.str, yytext); return OP_DIVIDE; }
{i_constant}      {  
    //yylval.const_int = atoi(yytext); 
    symtab_entry *s = lookup_symtab(yytext, cur_scope);
    if (!s) {
        yylval.s = create_symbol(yytext, cur_scope);
    } else  {
        yylval.s = s;
    }
    yylval.s->type = INT_TY;
    return ICONST;
}

{f_constant}      {  
    //yylval.const_float = atof(yytext); 
    symtab_entry *s = lookup_symtab(yytext, cur_scope);
    if (!s) {
        yylval.s = create_symbol(yytext, cur_scope);
    } else  {
        yylval.s = s;
    }
    yylval.s->type = FLOAT_TY;
    return FCONST;
    }

{s_const}       { return SCONST;}
{mk_lparen}     return MK_LPAREN;
{mk_rparen}     { return MK_RPAREN; }
{mk_lbrace}     { return MK_LBRACE; }
{mk_rbrace}     { return MK_RBRACE; }
{mk_lsqbrace}   return MK_LB;
{mk_rsqbrace}   return MK_RB;
{mk_comma}      return MK_COMMA;
{mk_semicolon}  return MK_SEMICOLON;
{mk_dot}	return MK_DOT;
{newline}       linenumber += 1;
{error}         return ERROR;

%%

