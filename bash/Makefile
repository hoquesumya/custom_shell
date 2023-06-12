LEX = lex
YACC = yacc
CC = gcc
CFLAGS = -Wall

TARGET = shell

all: $(TARGET)

$(TARGET): lex.yy.c y.tab.c
	$(CC) $(CFLAGS) -o $(TARGET) lex.yy.c y.tab.c	
lex.yy.c: shell.l
	$(LEX) shell.l

y.tab.c: shell.y
	$(YACC) -d shell.y

PHONY += clean
clean:
	rm -rf $(TARGET) lex.yy.c y.tab.c y.tab.h a.out *.o

.PHONY: $(PHONY)
