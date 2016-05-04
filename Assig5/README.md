Programming Assignment 5
========================

CSCI 5161, Spring 2016  
Wednesday, May 4, 2016  

Members
-------

Vaibhav Sharma <vaibhav@umn.edu>  
Taejoon Byun <taejoon@umn.edu>  

Directory Structure
-------------------

`README.md`: this file  
`test.c`: a test file which generates redundant store instructions
`StoresRemoval/StoresRemoval.cpp`: the compiler pass implementation which erases redundant stores  
`StoresRemoval/CMakeLists.txt`: a makefile to add this compiler pass to the LLVM compilation process  
`StoresRemoval/StoresRemoval.exports`: an empty file, can be ignored

Useless Stores Removal: a Peephole Optimization Pass
----------------------------------------------------

The general idea when implementing this optimization is to store the operands of every store instruction and to erase store instructions which are storing values to an operand which is being overwritten in a later instruction within the same basic block. We handled this in the following steps

-   First, we created a class inheriting the `BasicBlockPass` class which contains a `runOnBasicBlock` function which is called for every basic block in the compiled LLVM bitcode file
-   For every basic block, we iterated through the instructions and checked the opcode of every instruction
-   For every instruction with the `Store` opcode, we saved non-empty operands into a C++ `vector`
-   We then iterated through the instructions once again, checking the number of times the operand of a store instruction apppeared in the saved `vector` of non-empty operands from the previous step
-   For every store instruction whose operand that appeared more than once in this `vector`, we erased that instruction and its operand from the saved `vector` of non-empty store operands

This resulted in store instructions made redundant within a basic block to be removed from the basic block.

We tested this on the LLVM bitcode file compiled from `test.c` and found redundant stores being removed. 

Note
----

We modified the version of the `Hello` LLVM compiler pass to create our StoresRemoval pass. In order to test our pass, please use the command - `opt -load $LLVM_LOC/build/lib/LLVMStoresRemoval.so -storesremoval2 -stats < test.bc > /dev/null`. Our actual StoresRemoval compiler pass is available when used with the `-storesremoval2` option. We also maintain a counter of erased instructions and print it out at the end.

Sample Output
-------------
$ opt -load ../../../LLVM/build/lib/LLVMStoresRemoval.so -storesremoval2 -stats < test.bc > /dev/null
Erasing   store i32 %0, i32* @global, align 4
Erasing   store i32 %1, i32* @global, align 4
===-------------------------------------------------------------------------===
                          ... Statistics Collected ...
===-------------------------------------------------------------------------===

2 storesremoval - Number of insts removed by DIE pass
