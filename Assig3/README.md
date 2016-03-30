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

Handling User-defined Types (same as Assignment 2)
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

Production rules for parsing C-- code (similar to Assignment 2)
--------------------------------------------------------------

The production rules were adapted from sample Context Free Grammar shown in the
slides during the lecture. These rules are present in parser.y. They allow a
program to be described as a global declaration list which consists of a type
and variable declaration list along with a function declaration list. Function
declarations can further contain variable declarations along with C--
statements. Functions may not take any parameters and may contain conditional
statements, assignment statements and return statements. Statements allow
expressions which can index into arrays and refer to member variables of a
structure. Debug information printed by these statements can be ignored and
replaced by creation of corresponding semantic records.

Type checking rules & structures
--------------------------------

Except for rule 3(c) in the Type Checking Rules section of the assignment
specification, we have completed implementation of all the rules. An exception
which we did not implement is support for nested structures and unions. We have
included two sample files which demonstrate the rules our parser works
succesfully with. The first file is named 'vtest' and demonstrates type
checking rules 4(a,b,c,d) as well as the rules mentioned in the Type Coercion
section. Except for rules 3(a,c) in the Type Checking Rules section of the
assignment specification, we have completed implementation of all the rules. An
exception which we did not implement is support for nested structures and
unions. We have included two sample files which demonstrate the rules our
parser works succesfully with. The first file is named 'vtest' and demonstrates
type checking rules 4(a,b,c,d) as well as the rules mentioned in the Type
Coercion section. For implementing Rule 4, for each symbol table entry which is
of type structure, we also include in each such object a pointer to a type
object(mytype\_t in typetable.h) which contains a pointer to the head of a
linked list containing all the fields declared in a structure declaration. This
linked list of stucture fields helps us check for duplicate member variables as
well as capture the type information of each of the member variables in the
structure. It also prevents us from inserting these member variables into the
symbol table. While we have included in our production rules allowance for
defining nested structures and unions, we did not allow use of them in our
production rules.

Rule 2 - Functions and function calls
-------------------------------------

The rules that parses function declarations and function calls are
`function_decl` and `function_call` respectively. In order to check the number
of arguments when called, the list of parameter (at least the number of
parameters) should be recoreded when function is being declared. This is done
in `function_decl` rule by counting the number of parameters defined, and
storing the information in `symtab_entry.n_args` field of `ID`. When function
is called, the number of arguments are checked with the number of formal
parameters, and prints an error message if they do not match. For the return
type checking, we had to keep a global variable that points to the symbol table
entry of the function that is being declared, so that it can be later referred
in `return_stmt` rule. When `RETURN` token is being processed, the semantic
routine infers the type of the expression that comes after `RETURN`, and
matches it with the return type of the function being declared, by referring
the global variable `current_function->type`.

Rule 3 - Array Reference
------------------------

In order to keep track of array dimensions, we defined a field named `dim` in
the structure `symtab_entry`. This variable is set in the parsing rule named
`array_subscript`. Our plan was to compare array dimensions using this
information whenever an array is referenced, but we could not fully implmenet
it for the lack of time. However, we have implemented the rule *3.b* of array
subscript type checking.

