TARGET = scanner
OBJECT = lex.yy.o symboltable.o hash_table.o hash_functions.o
CC = cc -g
LEX = flex
LIBS = -lfl 
CFLAGS = -c99

scanner: $(OBJECT)
	$(CC) -o scanner $(OBJECT)

symboltable.o: symboltable.c 
	$(CC) -c symboltable.c 

hash_table.o: hash_table.c
	$(CC) $(CFLAGS) -c hash_table.c

hash_functions.o: hash_functions.c
	$(CC) -c hash_functions.c

lex.yy.o: lex.yy.c 
	$(CC) -c lex.yy.c 

lex.yy.c: lexer.lex
	$(LEX) $(LIB) lexer.lex

clean:
	rm -f $(TARGET) $(OBJECT) 

