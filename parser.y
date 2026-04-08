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

%type <str> expr condition

%%

program:
    program statement
    |
    ;

statement:
    simple_stmt NEWLINE
    | jodi_stmt
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

jodi_stmt:
    JODI condition COLON { fprintf(fp, "if (%s) {\n", $2); } NEWLINE simple_stmt NEWLINE nahole_part { fprintf(fp, "}\n"); }
    ;

nahole_part:
    /* empty */
    | NAHOLE COLON { fprintf(fp, "} else {\n"); } NEWLINE simple_stmt NEWLINE
    ;

condition:
    expr GT expr {
        char *res = malloc(200);
        sprintf(res, "%s > %s", $1, $3);
        $$ = res;
    }
    | expr LT expr {
        char *res = malloc(200);
        sprintf(res, "%s < %s", $1, $3);
        $$ = res;
    }
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
    fprintf(fp, "#include <stdio.h>\nint main() {\nsetvbuf(stdout, NULL, _IONBF, 0);\n");
    yyparse();
    fprintf(fp, "return 0;\n}");
    fclose(fp);
    printf("Generated output.c\n");
    return 0;
}