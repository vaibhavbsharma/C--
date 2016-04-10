TARGET = parser
OBJECT = parser.tab.c parser.tab.o lex.yy.c hashtable.o typetable.o symboltable.o common.o codegen.o lex.yy.c
CC = gcc -g -std=gnu99
LEX = flex
YACC = bison -v
YACCFLAG = 
LIBS = -lfl 

parser: parser.tab.o typetable.o symboltable.o common.o codegen.o
	$(CC) -o $(TARGET) parser.tab.o typetable.o hashtable.o symboltable.o common.o codegen.o $(LIBS)

mac: parser.tab.o typetable.o symboltable.o common.o codegen.o
	$(CC) -o $(TARGET) parser.tab.o typetable.o hashtable.o symboltable.o common.o codegen.o -ll

parser.tab.o: parser.tab.c lex.yy.c
	$(CC) -c parser.tab.c

typetable.o: typetable.c hashtable.o common.o
	$(CC) -c -o typetable.o typetable.c 

hashtable.o: hashtable.c
	$(CC) -c -o hashtable.o hashtable.c

symboltable.o: symboltable.c common.o
	$(CC) -c -o symboltable.o symboltable.c 

common.o: common.c
	$(CC) -c -o common.o common.c 

codegen.o: codegen.c
	$(CC) -c -o codegen.o codegen.c 

lex.yy.c: lexer3.l
	$(LEX) lexer3.l

parser.tab.c: parser.y 
	$(YACC) $(YACCFLAG) parser.y

test_codegen: test_codegen.c codegen.c common.c
	$(CC) -o test_codegen.out codegen.c common.c test_codegen.c

clean:
	rm -f $(TARGET) $(OBJECT) parser.output

