%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

FILE *fp;

char* make_expr(char* a, char* op, char* b) {
    char *res = malloc(100);
    sprintf(res, "%s %s %s", a, op, b);
    return res;
}

void yyerror(const char *s);
int yylex();
%}

%union { char* str; }

%token <str> NUMBER ID
%token DHORO JODI NAHOLE LOOP DEKHAO NAO
%token NEWLINE COLON
%token LBRACKET RBRACKET
%token GT LT

%left '+' '-'
%left '*' '/'

%type <str> expr

%%

program:
    program statement
    |
    ;

statement:
    simple_stmt NEWLINE
    ;

simple_stmt:
    DHORO ID '=' expr { fprintf(fp, "int %s = %s;\n", $2, $4); }
    | DHORO ID { fprintf(fp, "int %s;\n", $2); }
    | ID '=' expr { fprintf(fp, "%s = %s;\n", $1, $3); }
    | DEKHAO expr { fprintf(fp, "printf(\"%%d\\n\", %s);\n", $2); }
    | NAO ID { fprintf(fp, "scanf(\"%%d\", &%s);\n", $2); }
    | DHORO ID LBRACKET NUMBER RBRACKET { fprintf(fp, "int %s[%s];\n", $2, $4); }
    | ID LBRACKET NUMBER RBRACKET '=' expr { fprintf(fp, "%s[%s] = %s;\n", $1, $3, $6); }
    ;

expr:
    NUMBER { $$ = $1; }
    | ID { $$ = $1; }
    | expr '+' expr { $$ = make_expr($1, "+", $3); }
    | expr '-' expr { $$ = make_expr($1, "-", $3); }
    | expr '*' expr { $$ = make_expr($1, "*", $3); }
    | expr '/' expr { $$ = make_expr($1, "/", $3); }
    ;

%%

void yyerror(const char *s) {
    printf("Error: %s\n", s);
}

int main() {
    fp = fopen("output.c", "w");
    fprintf(fp, "#include <stdio.h>\nint main() {\n");
    yyparse();
    fprintf(fp, "return 0;\n}");
    fclose(fp);
    printf("Generated output.c\n");
    return 0;
}