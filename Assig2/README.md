Programming Assignment 2
========================

CSCI 5161, Spring 2016  
Wednesday, March 2, 2016  

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
`table.c`, `table.h`: keeps a lookup dictionary for user defined types  
`hashtable.h`, `hashtable.c`: contains the hash table implementation  

Handling User-defined Types
---------------------------

After completing the grammar rules, the biggest challenge we faced was to 
handle user-defined types, or `typedef`s. User-defined types are identifiers, 
but can be placed in the position of `type`s only after it is declared with 
`typedef` construct. We handled this in two steps. 

-   First, we added an action to the production rule of `tyledef_decl` so that 
    whenever there is a `typedef` in source code, we insert the `ID` into the 
    hash table that keeps user-defined types, so that we can look up later. 
-   Second, we introduced a token `TYPEDEF_NAME` for user-defined types. This
    token is produced by the lexer; when it produces `ID`, lexer looks up the
    hash table to see if the identifier is already in the lookup table. If it
    is, which means that the `ID` is declared as a user-defined type, lexer
    returns `TYPEDEF_NAME` token, instead of `ID`.

(we got hint of handling `typedef`s from the *ANSI C Yacc Grammar* presented in
[this page](http://www.quut.com/c/ANSI-C-grammar-y.html#constant_expression).


