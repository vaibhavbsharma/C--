Programming Assignment 3
========================

CSCI 5161, Spring 2016  
Wednesday, March 29, 2016  

Members
-------

Vaibhav Sharma <vaibhav@umn.edu>  
Taejoon Byun <taejoon@umn.edu>  

Directory Structure
-------------------

`README.md`: this file  
`Makefile`: make file
`lexer3.l`: lexer rules  
`parser.y`: parsing grammar  
`common.h`: a common header file  
`hashtable.h`, `hashtable.c`: contains the hash table implementation  
`symboltable.h`, `symboltable.c`: contains the symbol table implementation  
`typetable.h`, `typetable.c`: keeps a lookup dictionary for user defined types   

Handling User-defined Types(same as Assignment 2)
-------------------------------------------------

After completing the grammar rules, the biggest challenge we faced was to 
handle user-defined types, or `typedef`s. User-defined types are identifiers, 
but can be placed in the position of `type`s only after it is declared with 
`typedef` construct. We handled this in three steps. 

-   First, we added an action to the production rule of `tyledef_decl` so that 
    whenever there is a `typedef` in source code, we insert the `ID` into the 
    hash table that keeps user-defined types, so that we can look up later. 
-   Second, we introduced a token `TYPEDEF_NAME` for user-defined types, and 
    placed it in the production rule of `type`. This
-   Third, we implemented an action in the lexer to produce `TYPEDEF_NAME` for 
    user-defined types. This is implemented in the action for `ID`; when lexer
    matches `ID`, it looks up the hash table to see if the identifier is 
    already in the lookup table. If it is, which means that the `ID` is 
    declared as a user-defined type, lexer returns `TYPEDEF_NAME` token 
    instead of `ID`.

(we got hint of handling `typedef`s from the *ANSI C Yacc Grammar* presented in
[this page](http://www.quut.com/c/ANSI-C-grammar-y.html#constant_expression).

Production rules for parsing C-- code(similar to Assignment 2)
--------------------------------------------------------------

The production rules were adapted from sample Context Free Grammar shown in the slides during the lecture. These rules are present in parser.y. They allow a program to be described as a global declaration list which consists of a type and variable declaration list along with a function declaration list. Function declarations can further contain variable declarations along with C-- statements. Functions may not take any parameters and may contain conditional statements, assignment statements and return statements. Statements allow expressions which can index into arrays and refer to member variables of a structure.
Debug information printed by these statements can be ignored and replaced by creation of corresponding semantic records.

Type checking rules implemented
-------------------------------
Except for rule 3(c) in the Type Checking Rules section of the assignment specification, we have completed implementation of all the rules. 
An exception which we did not implement is support for nested structures and unions.
We have included two sample files which demonstrate the rules our parser works succesfully with.
The first file is named 'vtest' and demonstrates type checking rules 4(a,b,c,d) as well as the rules mentioned in the Type Coercion section.