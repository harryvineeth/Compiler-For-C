alpha [a-zA-Z]
digit [0-9]

%%
[ \t]		;
[ \n]   { yylineno = yylineno + 1;}

int	{ yylval.iValue = INT; return INT; }
float { yylval.iValue = FLOAT; return FLOAT;}
void {yylval.iValue=VOID; return VOID;}
sizeof return SIZEOF;
typedef return TYPEDEF;
for 	return FOR;
while	return WHILE;
if	return IF;
else	return ELSE;
return return RETURN;
printf  return PRINTF;
scanf return SCANF;
struct 	return STRUCT;
^"#include ".+ return PREPROC;
{digit}+       {yylval.realValue=atoi(yytext); return NUM;}
({digit}*\.{digit}+)|({digit}+\.{digit}*) {yylval.realValue=atoi(yytext); return REAL;}
{alpha}({alpha}|{digit})* { yylval.str = strdup(yytext); return ID ;}
"<="    return LE;
">="    return GE;
"=="    return EQ;
"!="    return NE;
">"	return GT;
"<"	return LT;
"."     return DOT;
"&&" return AND;
"||" return OR;
\/\/.* ;
\/\*(.*\n)*.*\*\/ ;
\"(\\.|[^"])*\" {yylval.str=strdup(yytext); return STRING;}
. return yytext[0];

%%
