all:	lexer compiler

lexer:	lexer.l
				flex lexer.l

compiler:	lex.yy.c
					g++ listexpression.cpp lex.yy.c -o listexpression
