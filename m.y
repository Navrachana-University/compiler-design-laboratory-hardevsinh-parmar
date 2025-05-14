%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int yylex(void);
void yyerror(const char *s);

int tempCount = 0;
char* newTemp() {
    char* t = (char*)malloc(10);
    sprintf(t, "t%d", tempCount++);
    return t;
}

FILE *output_file;
extern FILE *yyin;
%}

%union {
    int num;
    char* str;
    char* id;
    char* expr;
}

%token <num> NUMBER
%token <id> ID
%token <str> STRING
%token START END ASSIGN PRINT IF ELSE FOR REPEAT
%token ADD SUB MUL DIV LT GT EQ TO

%type <expr> expr

%left ADD SUB
%left MUL DIV
%nonassoc LT GT EQ

%%

S : START SL END { printf("Program executed successfully.\n"); }
  ;

SL : stmt SL
   | /* empty */
   ;

stmt : PRINT ID ';'
        {
            printf("print %s\n", $2);
            fprintf(output_file, "print %s\n", $2);
            free($2);
        }
     | PRINT STRING ';'
        {
            printf("print \"%s\"\n", $2);
            fprintf(output_file, "print \"%s\"\n", $2);
            free($2);
        }
     | ID ASSIGN expr ';'
        {
            printf("%s = %s\n", $1, $3);
            fprintf(output_file, "%s = %s\n", $1, $3);
            free($1);
            free($3);
        }
     | IF expr ':' stmt ELSE ':' stmt
        {
            char* ltrue = newTemp();
            char* lfalse = newTemp();
            char* lend = newTemp();

            printf("if %s goto %s\n", $2, ltrue);
            fprintf(output_file, "if %s goto %s\n", $2, ltrue);
            printf("goto %s\n", lfalse);
            fprintf(output_file, "goto %s\n", lfalse);

            printf("%s:\n", ltrue);
            fprintf(output_file, "%s:\n", ltrue);

            printf("goto %s\n", lend);
            fprintf(output_file, "goto %s\n", lend);

            printf("%s:\n", lfalse);
            fprintf(output_file, "%s:\n", lfalse);

            printf("%s:\n", lend);
            fprintf(output_file, "%s:\n", lend);

            free($2);
            free(ltrue);
            free(lfalse);
            free(lend);
        }
     | FOR ID ASSIGN expr TO expr ':' SL REPEAT ';'
        {
            char* loop = newTemp();
            char* end = newTemp();

            printf("%s = %s\n", $2, $4);
            fprintf(output_file, "%s = %s\n", $2, $4);

            printf("%s:\n", loop);
            fprintf(output_file, "%s:\n", loop);

            printf("if %s > %s goto %s\n", $2, $6, end);
            fprintf(output_file, "if %s > %s goto %s\n", $2, $6, end);

            printf("%s = %s + 1\n", $2, $2);
            fprintf(output_file, "%s = %s + 1\n", $2, $2);

            printf("goto %s\n", loop);
            fprintf(output_file, "goto %s\n", loop);

            printf("%s:\n", end);
            fprintf(output_file, "%s:\n", end);

            free($2);
            free($4);
            free($6);
            free(loop);
            free(end);
        }
     ;

expr : expr ADD expr
     | expr SUB expr
     | expr MUL expr
     | expr DIV expr
     | expr LT expr
     | expr GT expr
     | expr EQ expr
     | ID { $$ = strdup($1); free($1); }
     | NUMBER { $$ = (char*)malloc(10); sprintf($$, "%d", $1); }
     ;

%%

void yyerror(const char *s) {
    fprintf(stderr, "Error: %s\n", s);
}

int main(int argc, char **argv) {
    if (argc < 2) {
        printf("Usage: %s <input_file>\n", argv[0]);
        return 1;
    }

    FILE *input_file = fopen(argv[1], "r");
    if (!input_file) {
        fprintf(stderr, "Error: Unable to open input file %s\n", argv[1]);
        return 1;
    }

    output_file = fopen("output.tac", "w");
    if (!output_file) {
        fprintf(stderr, "Error: Unable to create output.tac file\n");
        fclose(input_file);
        return 1;
    }

    yyin = input_file;
    yyparse();

    fclose(input_file);
    fclose(output_file);
    return 0;
}