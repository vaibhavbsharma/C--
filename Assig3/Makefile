TARGET = parser
OBJECT = parser.tab.c parser.tab.o lex.yy.c hashtable.o typetable.o symboltable.o common.o
CC = gcc -g
LEX = flex
YACC = bison -v
YACCFLAG = 
LIBS = -lfl 

parser: parser.tab.o typetable.o symboltable.o common.o
	$(CC) -o $(TARGET) parser.tab.o typetable.o hashtable.o symboltable.o common.o $(LIBS)

mac: parser.tab.o typetable.o symboltable.o common.o
	$(CC) -o $(TARGET) parser.tab.o typetable.o hashtable.o symboltable.o common.o -ll

parser.tab.o: parser.tab.c lex.yy.c
	$(CC) -c parser.tab.c

typetable.o: typetable.c hashtable.o
	$(CC) -c typetable.c hashtable.c

hashtable.o: hashtable.c
	$(CC) -c -o hashtable.o hashtable.c

symboltable.o: symboltable.c common.o
	$(CC) -c -o symboltable.o symboltable.c 

common.o: common.c
	$(CC) -c -o common.o common.c 

lex.yy.c: lexer3.l
	$(LEX) lexer3.l

parser.tab.c: parser.y 
	$(YACC) $(YACCFLAG) parser.y

clean:
	rm -f $(TARGET) $(OBJECT) parser.output

