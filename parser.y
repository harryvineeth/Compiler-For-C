%{
	#include <math.h>
	#include <stdio.h>
	#include <stdlib.h>
	#include "symbol.cpp"
	int g_addr = 300;

	extern "C" {
		int yylex();
		void yyerror(char *);
	}
	string str;
	
%}
%token<str> ID NUM REAL
%token PTR DOT SIZEOF
%token TYPEDEF STRUCT
%token<iValue> INT FLOAT VOID
%token IF ELSE WHILE RETURN FOR 
%token PRINTF SCANF
%token STRING
%token PREPROC
%token ARRAY FUNCTION
%token MAIN
%token<str> GT LT LE GE NE EQ
%left GT LT LE GE NE EQ
%left AND OR
%right '='
%left '+' '-'
%left '*' '/'

%type<iValue> Type
%type<str> Assignment ArrayUsage 
%union {
 		int iValue; /* integer value */
 		float realValue;
 		char *str; /* identifier name */
	}


%%
start:	Function start
	| Declaration start
	| PREPROC start
	|
	;

/* Declaration block */
Declaration: Type Assignment ';' { if(redeclare($2))
					{insert($2,$1,g_addr); g_addr+=4;}
				else
					{printf("Redecleration  %s \n",$2);} }
	| Assignment ';' 
	| ID ';' {  printf("Undeclared Variable %s\n",$1);}	
	| FunctionCall ';' 	
	| ArrayUsage ';' 
	| Type ArrayUsage ';' { insert($2,ARRAY,g_addr);
							insert($2,$1,g_addr); g_addr+=4; } 
	| StructStmt ';'
	| error	
	;

/* Assignment block */
Assignment: pointer Assignment
	| ID{store($1);} '=' {store("=");} Assignment {assign();}
	| ID ',' Assignment
	| NUM ',' Assignment
	| ID{store($1);} '+'{store("+");} Assignment {temp_assign();} 
	| ID{store($1);} '-'{store("-");} Assignment {temp_assign();} 
	| ID{store($1);} '*'{store("*");} Assignment {temp_assign();} 
	| ID{store($1);} '/'{store("/");} Assignment {temp_assign();} 
	| NUM '+' Assignment
	| NUM '-' Assignment
	| NUM '*' Assignment
	| NUM '/' Assignment
	| REAL '+' Assignment
	| REAL '-' Assignment
	| REAL '*' Assignment
	| REAL '/' Assignment
	| '\'' Assignment '\''	
	| '(' Assignment ')'
	| '-' '(' Assignment ')'
	| '-' NUM
	| '-' REAL
	| '-' ID
	|  NUM {$$ = $1; store($1);}
	|   REAL {$$ = $1; store($1);}
	|   ID {$$=$1;store($1);}
	| STRING
	;


/* Function Call Block */
FunctionCall : ID'('')'
	| ID'('Assignment')' 
	;

/* Array Usage */
ArrayUsage : ID'['Assignment']' 
	;


/* Function block */
Function: Type ID '(' ArgListOpt ')' CompoundStmt { insert($2,FUNCTION,g_addr); insert($2,$1,g_addr);g_addr+=4; if($1==268) printf("Wrong return type\n"); } 
	;

ArgListOpt: ArgList
	|
	;
ArgList:  ArgList ',' Arg
	| Arg
	;
Arg:	Type ID
	;
CompoundStmt:	'{'{printf("Entered New scope\n");} StmtList {printf("Exited New Scope\n");}'}' 	
	;
StmtList:	StmtList Stmt
	|
	;
Stmt:	WhileStmt
	| Declaration
	| ForStmt
	| IfStmt
	| PrintFunc
	| ';'
	| RETURN ';'{printf("Wrong return type\n");}
	| RETURN Assignment ';'
	;

/* Type Identifier block */
Type:	INT 
	| FLOAT
	| VOID 
	;

/* Loop Blocks */ 
WhileStmt:WHILE{w_gen1();} '(' Expr ')'{w_gen2();} CompoundStmt{w_gen3();} 
	;

/* For Block */
ForStmt: FOR '(' Expr ';'{f_gen1();} Expr ';'{f_gen2();} Expr ')'{f_gen3();} CompoundStmt {f_gen4();}
	;

/* IfStmt Block */
IfStmt : IF '(' Expr ')'{if_gen1();} CompoundStmt{if_gen2();} ELSE CompoundStmt{if_gen3();}
	
	;

/* Struct Statement */
StructStmt : STRUCT ID '{' Type Assignment ';' '}' { insert($2,STRUCT,g_addr); g_addr+=4; } 
	;

/* Print Function */
PrintFunc : PRINTF '(' Expr ')' ';'
	;


/*Expression Block*/
Expr:	
	| Expr LE Expr 
	| Expr GE Expr
	| Expr NE Expr
	| Expr EQ Expr
	| Expr GT Expr
	| Expr LT Expr
	| Assignment
	| ArrayUsage
	;


/* Pointer handling */
pointer
	: '*'
	| '*' pointer
	;



%%

#include "lex.yy.c"
#include <ctype.h>


int main(int argc,char *argv[])
{
	FILE *file;
		file = fopen(argv[1], "r");
		if (!file)
		{
			fprintf(stderr, "Could not open %s\n", argv[1]);
			exit(1);
		}
		yyin = file;

	if(!yyparse())
		{
		printf("\nParsing done\n");
		printsym();
		}
	else
		printf("\nParsing failed\n");

	fclose(yyin);
	return 0;
}


void yyerror(char *s)
{
	printf("%d 	:	%s  %s \n",yylineno,s,yytext);
}


