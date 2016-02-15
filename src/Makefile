TARGET = scanner
OBJECT = lex.yy.o symboltable.o hashtable.o 
CC = cc -g
LEX = flex
LIBS = -lfl 
CFLAGS = -std=c99

scanner: $(OBJECT)
	$(CC) -o scanner $(OBJECT)

symboltable.o: symboltable.c 
	$(CC) -c symboltable.c 

hashtable.o: hashtable.c
	$(CC) $(CFLAGS) -c hashtable.c

lex.yy.o: lex.yy.c 
	$(CC) -c lex.yy.c 

lex.yy.c: lexer.lex
	$(LEX) $(LIB) lexer.lex

clean:
	rm -f $(TARGET) $(OBJECT) 

