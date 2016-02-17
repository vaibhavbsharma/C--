Programming Assignment 1
========================

CSCI 5161, Spring 2016  
Wednesday, February 17, 2016  

Members
-------

Taejoon Byun <taejoon@umn.edu>  
Vaibhav Sharma <vaibhav@umn.edu>

Directory Structure
-------------------

`lexer.lex`: contains all the definitions and rules for all the tokens  
`symboltable.c`: contains code for symbol table manipulation and managing comments  
`symboltable.h`: the header file of `symboltable.c`
`hashtable.c`: contains the hash table implementation  
`hashtable.h`: the header file of `hashtable.c`  

Hash table implementation
-------------------------

We implemented a quick and dirty hash table that maintains a list of linked list of pointers to hash table entry, which is a double pointer to hash table entries.
It uses a simple modulation as a hash function, and provides basic functions such as insertion, retrieval, and deletion. 

Symbol table implementation
---------------------------

Implemented the empty bodies of the functions that _Assignment 1_ provided.
We also added a comparison function for sorting purpose.


