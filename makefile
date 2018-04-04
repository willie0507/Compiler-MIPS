OBJ = lex.yy.o lotus.tab.o

parser: $(OBJ)
	gcc -o parser $(OBJ) -lfl
lex.yy.o: lex.yy.c
	gcc -c lex.yy.c
lex.yy.c: lotus.l lotus.tab.h
	flex lotus.l
lotus.tab.o: lotus.tab.c
	gcc -c lotus.tab.c
lotus.tab.h: lotus.y
	bison -d lotus.y
lotus.tab.c: lotus.y
	bison -d lotus.y
clean:
	rm -f parser *.c *.o *.h
