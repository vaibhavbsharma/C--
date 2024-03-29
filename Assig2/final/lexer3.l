/*lexer file*/

%{
#ifndef DEBUG
#define DEBUG false
#endif
#include <stdio.h>
#include "table.h"
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
constant {digit}+(("."){digit}+)?
comment	"/*"(([^*])|([*]+[^/*]))*("*")+"/"
s-const \"([^"\n])*\"
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
{kwInt}         return INT;
{kwFloat}       return FLOAT;
{kwVoid}	return VOID;
{kwIf}          return IF;
{kwElse}        return ELSE;
{kwWhile}       return WHILE;
{kwFor}      	return FOR;
{kwStruct}	return STRUCT;
{kwUnion}	return STRUCT;
{kwTypedef}     return TYPEDEF;
{kwReturn}      return RETURN;

{libRead}       return READ;
{libFRead}      return FREAD;
{libWrite}      return WRITE;

{ID}            { 
    yylval = yytext;
    if (is_type_exists(yytext)) {
        if (DEBUG) {
            printf("%s is a user defined type\n", yytext);
        }
        return TYPEDEF_NAME;
    } else {
        return ID; 
    }
    }
{op_assign}     return OP_ASSIGN; 
{op_and}        return OP_AND;
{op_or}         return OP_OR;
{op_not}        return OP_NOT;
{op_eq}         return OP_EQ;
{op_ne}         return OP_NE;
{op_lt}         return OP_LT;
{op_gt}         return OP_GT;
{op_le}         return OP_LE;
{op_ge}         return OP_GE;
{op_plus}       return OP_PLUS;
{op_minus}      return OP_MINUS;
{op_times}      return OP_TIMES;
{op_divide}     return OP_DIVIDE;
{constant}      {  
    yylval = yytext; 
    return CONST;
    }
{s-const}       { return SCONST;}
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

