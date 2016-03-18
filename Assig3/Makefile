TARGET = parser
OBJECT = parser.tab.c parser.tab.o lex.yy.c hashtable.o table.o
CC = gcc
LEX = flex
YACC = bison -v
YACCFLAG = 
LIBS = -lfl 

parser: parser.tab.o table.o
	$(CC) -o $(TARGET) parser.tab.o table.o hashtable.o $(LIBS)

parser-mac: parser.tab.o table.o
	$(CC) -o $(TARGET) parser.tab.o table.o hashtable.o -ll

parser.tab.o: parser.tab.c lex.yy.c
	$(CC) -c parser.tab.c

table.o: table.c hashtable.o
	$(CC) -c table.c hashtable.c

hashtable.o: hashtable.c
	$(CC) -c -o hashtable.o hashtable.c

lex.yy.c: lexer3.l
	$(LEX) lexer3.l

parser.tab.c: parser.y 
	$(YACC) $(YACCFLAG) parser.y

clean:
	rm -f $(TARGET) $(OBJECT) 

