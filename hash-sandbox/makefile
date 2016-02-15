TARGET = ex
CC = cc -g
OBJECT = ex.o hash_table.o hash_functions.o

ex: $(OBJECT)
	$(CC) -o ex $(OBJECT)

ex.o: ex.c
	$(CC) -c ex.c

hash_table.o: hash_table.c
	$(CC) -c hash_table.c

hash_functions.o: hash_functions.c
	$(CC) -c hash_functions.c

clean:
	rm -f $(TARGET) $(OBJECT)

