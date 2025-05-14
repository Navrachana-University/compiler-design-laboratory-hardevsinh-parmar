%{
#include "m.tab.h"
#include <string.h>
#include <stdlib.h>
%}

%option noyywrap

%%

"Prarambh"      { return START; }
"Shevat"        { return END; }
"Sanga"         { return ASSIGN; }
"Mudrit"        { return PRINT; }
"Jar"           { return IF; }
"Nahitar"       { return ELSE; }
"Sathi"         { return FOR; }
"Paryant"       { return TO; }
"Parat"         { return REPEAT; }

"+"             { return ADD; }
"-"             { return SUB; }
"*"             { return MUL; }
"/"             { return DIV; }
"<"             { return LT; }
">"             { return GT; }
"=="            { return EQ; }

\"([^\"]*)\" { yylval.str = strdup(yytext + 1); yylval.str[strlen(yylval.str) - 1] = '\0'; return STRING; }

[0-9]+          { yylval.num = atoi(yytext); return NUMBER; }

[a-zA-Z_][a-zA-Z0-9_]* { yylval.id = strdup(yytext); return ID; }


";"             { return ';'; }
":"             { return ':'; }

[ \t\r\n]+      { /* skip whitespace */ }

.               { fprintf(stderr, "Error: Unknown character '%s'\n", yytext); exit(1); }

%%