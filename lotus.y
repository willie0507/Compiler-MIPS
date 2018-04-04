%{
#include <stdio.h>
#include <string.h>
extern int yylex();
extern int yylineno;
int yyerror(char* str){
	fprintf(stderr, "Syntax error: line %d\n", yylineno);
}
int temp ;
int arith_place ;
int if_boolean_place, while_boolean_place ;
int stack[10] = {9, 8, 7, 6, 5, 4, 3, 2, 1, 0} ;
int top = 9 ;
void putReg(int v){
	top++ ;
	stack[top] = v ;	
}
int getReg(){
	int data ;
	data = stack[top] ;
	top-- ;
	return data ;
}
int newLabel(){
	static int label = 0 ;
	return ++label ;
}
%}
%union{
	int integer ;
	char* string ;
	int boolean[3]; // 1: true, 0: false, 2: inherited
}
%token <string> ID
%token <integer> NUMBER
%token ELSE RBB LBB RSB LSB COMMA SEMI ASSIGHN NOT AND OR LE LESS GE GREAT NEQ EQ MUL DIV MOD PLUS MINUS WRITE WHILE RETURN READ IF INT EXIT
%type <boolean> bool_primary bool_factor bool_term bool_expression M1 M2 while_statement if_statement
%type <integer> arith_primary arith_factor arith_term arith_expression
%%
program: {printf("\t.data\n");} ID LSB RSB function_body
;
function_body: LBB variable_declarations {printf("\t.text\nmain:\n");} statements RBB 
;
variable_declarations: /* empty */ 
| variable_declarations variable_declaration
;
variable_declaration: INT ID SEMI {printf("%s .word 0\n", $2);}
;
statements: /* empty */
| statements statement
;
statement: assignment_statement
| compound_statement
| if_statement
| while_statement
| exit_statement
| read_statement
| write_statement
;
assignment_statement: ID ASSIGHN arith_expression SEMI {temp = getReg(); printf("\tla\t$t%d, %s\n", temp, $1); printf("\tsw\t$t%d, 0($%d)\n", $3, temp); putReg(temp); putReg($3);}
;
compound_statement: LBB statements RBB
;
if_statement: IF LSB bool_expression RSB {printf("L%d:\n", $3[1]);} statement {printf("L%d:\n", $3[0]);}
| IF {if_boolean_place = newLabel();} LSB bool_expression RSB {printf("L%d:\n", $4[1]);} statement {printf("\tb\tL%d", if_boolean_place);} ELSE {printf("L%d:\n", $4[0]);} statement {printf("L%d:\n", if_boolean_place);}
;
while_statement: {while_boolean_place = newLabel(); printf("L%d:\n", while_boolean_place);} WHILE LSB bool_expression RSB {printf("L%d:\n", $4[1]);} statement {printf("\tb%d\nL%d\n", while_boolean_place, $4[0]);}
;
exit_statement: EXIT SEMI {printf("\tli\t$v0, 10\n\tsyscall\n");}
;
read_statement: READ ID SEMI {printf("\tli\t$v0, 5\n\tsyscall\n\tla\t$t0, %s\n\tsw\t$v0, 0($t0)\n", $2);}
;
write_statement: WRITE arith_expression SEMI {printf("\tmove\t$a0, $t%d\n\tli\t$v0, 1\n\tsyscall\n", $2);}
;
bool_expression: bool_term {$$[0] = $1[0]; $$[1] = $1[1];}
| bool_expression OR {printf("L%d:\n", $1[0]); } M1 {$4[1] = $1[1];} bool_term {$$[1] = $4[1]; $$[0] = $6[0];}
;
M1: 
;
bool_term: bool_factor {$$[0] = $1[0]; $$[1] = $1[1];}
| bool_term AND {printf("L%d:\n", $1[1]); } M2 {$4[0] = $1[0];} bool_factor {$$[0] = $4[0]; $$[1] = $6[1];}
;
M2:
;
bool_factor: bool_primary {$$[0] = $1[0]; $$[1] = $1[1];}
| NOT bool_primary {$$[1] = $2[0]; $$[0] = $2[1];}
;
bool_primary: arith_expression EQ arith_expression {
	$$[1] = newLabel(); $$[0] = newLabel(); printf("\tbeq\t$t%d, $t%d, L%d\n", $1, $3, $$[1]); printf("\tb\tL%d\n", $$[0]); putReg($1); putReg($3);
	}
| arith_expression NEQ arith_expression {
	$$[1] = newLabel(); $$[0] = newLabel(); printf("\tbnq\t$t%d, $t%d, L%d\n", $1, $3, $$[1]); printf("\tb\tL%d\n", $$[0]); putReg($1); putReg($3);
	}
| arith_expression GREAT arith_expression {
	$$[1] = newLabel(); $$[0] = newLabel(); printf("\tbgt\t$t%d, $t%d, L%d\n", $1, $3, $$[1]); printf("\tb\tL%d\n", $$[0]); putReg($1); putReg($3);
	}
| arith_expression GE arith_expression {
	$$[1] = newLabel(); $$[0] = newLabel(); printf("\tbge\t$t%d, $t%d, L%d\n", $1, $3, $$[1]); printf("\tb\tL%d\n", $$[0]); putReg($1); putReg($3);
	}	
| arith_expression LESS arith_expression {
	$$[1] = newLabel(); $$[0] = newLabel(); printf("\tblt\t$t%d, $t%d, L%d\n", $1, $3, $$[1]); printf("\tb\tL%d\n", $$[0]); putReg($1); putReg($3);
	}
| arith_expression LE arith_expression {
	$$[1] = newLabel(); $$[0] = newLabel(); printf("\tble\t$t%d, $t%d, L%d\n", $1, $3, $$[1]); printf("\tb\tL%d\n", $$[0]); putReg($1); putReg($3);
	}
;
arith_expression: arith_term {$$ = $1;}
| arith_expression PLUS arith_term {printf("\tadd\t$t%d, $t%d, $t%d\n", $1, $1, $3); putReg($3); $$ = $1;}
| arith_expression MINUS arith_term {printf("\tsub\t$t%d, $t%d, $t%d\n", $1, $1, $3); putReg($3); $$ = $1;}
;
arith_term: arith_factor {$$ = $1;}
| arith_term MUL arith_factor {printf("\tmul\t$t%d, $t%d, $t%d\n", $1, $1, $3); putReg($3); $$ = $1;}
| arith_term DIV arith_factor {printf("\tdiv\t$t%d, $t%d, $t%d\n", $1, $1, $3); putReg($3); $$ = $1;} 
| arith_term MOD arith_factor {printf("\trem\t$t%d, $t%d, $t%d\n", $1, $1, $3); putReg($3); $$ = $1;}
;
arith_factor: arith_primary {$$ = $1;}
| MINUS arith_primary {printf("\tneg $t%d, $t%d\n", $2, $2); $$ = $2;}
;
arith_primary: NUMBER {$$ = getReg(); printf("\tli\t$t%d, %d\n", $$, $1);}
| ID {$$ = getReg(); printf("\tla\t$t%d, %s\n", $$, $1); printf("\tlw\t$t%d, 0($t%d)\n", $$, $$);}
| LSB arith_expression RSB {$$ = $2;}
;
%%
int main(){
	yyparse() ;

	return 0 ;
}
