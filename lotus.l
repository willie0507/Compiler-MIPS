%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "lotus.tab.h"
%}
delim [ \t\n]
ws {delim}+
letter [A-Za-z]
digit [0-9]
id {letter}({letter}|{digit})*
number {digit}+
%x comment
%option yylineno
%%
"//" {BEGIN(comment);}
<comment>\n {BEGIN(INITIAL);}
<comment>. {/* do nothing */}

{ws} {/* no action and no return */}
else {return (ELSE);}
exit {return (EXIT);}
int {return (INT);}
if {return (IF);}
read {return (READ);}
return {return (RETURN);}
while {return (WHILE);}
write {return (WRITE);}
{id} {yylval.string = strdup(yytext); return (ID);}
{number} {yylval.integer = atoi(yytext); return (NUMBER);}
"+" {return (PLUS);}
"-" {return (MINUS);}
"*" {return (MUL);}
"/" {return (DIV);}
"%" {return (MOD);}
"==" {return (EQ);}
"!=" {return (NEQ);}
">" {return (GREAT);}
">=" {return (GE);}
"<" {return (LESS);}
"<=" {return (LE);}
"&&" {return (AND);}
"||" {return (OR);}
"!" {return (NOT);}
"=" {return (ASSIGHN);}
";" {return (SEMI);}
"," {return (COMMA);}
"(" {return (LSB);}
")" {return (RSB);}
"{" {return (LBB);}
"}" {return (RBB);}
. {fprintf(stderr, "Lexical error: line %d: unknown cheracter %s\n", yylineno, yytext);} 
%%
/*
int main(int argc, char* argv[]){
	if(argc == 2 && (strcmp(argv[1], "-s") == 0)){
		while(1 == 1){
			switch(yylex()){
				case EOF:
					return 0 ;
				case ELSE:
				case EXIT:
				case INT:	
				case IF:
				case READ:
				case RETURN:
				case WHILE:
				case WRITE:
					printf("Keyword: %s\n", yytext);
					break ;
				case PLUS:
				case MINUS:
				case MUL:
				case DIV:
				case MOD:
				case EQ:
				case NEQ:
				case GREAT:
				case GE:
				case LESS:
				case LE:
				case AND:
				case OR:
				case NOT:
				case ASSIGHN:
				case SEMI:
				case COMMA:
				case LSB:
				case RSB:
				case LBB:
				case RBB:
					printf("Operator: %s\n", yytext);
					break ;
				case ID:
					printf("Identifier: %s\n", yylval.string);
					break ;
				case NUMBER:
					printf("Integer Constant: %d\n", yylval.integer);
					break ; 	
			}
		}
	}
	else {
		while(yylex() != EOF){
		}
	}
}*/
