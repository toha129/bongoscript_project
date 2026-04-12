%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

FILE *fp;

char* make_expr(char* a, char* op, char* b) {
    char *res = malloc(256);
    sprintf(res, "%s %s %s", a, op, b);
    return res;
}

void yyerror(const char *s);
int yylex();
%}

%union { char* str; }

%token <str> NUMBER ID STRING
%token DHORO JODI NAHOLE LOOP DEKHAO NAO
%token INDENT DEDENT NEWLINE COLON
%token LBRACKET RBRACKET
%token GT LT EQ

%left GT LT EQ
%left '+' '-'
%left '*' '/'

%type <str> expr

%%

/* ── Top-level program ── */
program:
    program statement
    | program NEWLINE
    |
    ;

/* ── Statements ── */
statement:
    simple_stmt NEWLINE
    | if_stmt
    | loop_stmt
    ;

/* ── Indented block (Python-style) ── */
block:
    INDENT stmts DEDENT
    ;

stmts:
    stmts statement
    | stmts NEWLINE
    | statement
    | NEWLINE
    ;

/* ── if / else ── */
if_stmt:
    JODI expr COLON NEWLINE
    { fprintf(fp, "if (%s) {\n", $2); }
    block nahole_part
    { fprintf(fp, "}\n"); }
    ;

nahole_part:
    /* empty */
    | NAHOLE COLON NEWLINE
      { fprintf(fp, "} else {\n"); }
      block
    ;

/* ── while loop ── */
loop_stmt:
    LOOP expr COLON NEWLINE
    { fprintf(fp, "while (%s) {\n", $2); }
    block
    { fprintf(fp, "}\n"); }
    ;

/* ── Simple (single-line) statements ── */
simple_stmt:
    DHORO ID '=' expr
    { fprintf(fp, "int %s = %s;\n", $2, $4); }

    | DHORO ID
    { fprintf(fp, "int %s;\n", $2); }

    | ID '=' expr
    { fprintf(fp, "%s = %s;\n", $1, $3); }

    | DEKHAO expr
    { fprintf(fp, "printf(\"%%d\\n\", %s);\n", $2); }

    | DEKHAO STRING
    { fprintf(fp, "printf(\"%%s\\n\", %s);\n", $2); }

    | NAO ID
    { fprintf(fp, "scanf(\"%%d\", &%s);\n", $2); }

    | DHORO ID LBRACKET expr RBRACKET
    { fprintf(fp, "int %s[%s];\n", $2, $4); }

    | ID LBRACKET expr RBRACKET '=' expr
    { fprintf(fp, "%s[%s] = %s;\n", $1, $3, $6); }
    ;

/* ── Expressions (includes arithmetic + comparisons) ── */
expr:
    NUMBER          { $$ = $1; }
    | ID            { $$ = $1; }
    | ID LBRACKET expr RBRACKET
    {
        char *res = malloc(256);
        sprintf(res, "%s[%s]", $1, $3);
        $$ = res;
    }
    | expr '+' expr { $$ = make_expr($1, "+", $3); }
    | expr '-' expr { $$ = make_expr($1, "-", $3); }
    | expr '*' expr { $$ = make_expr($1, "*", $3); }
    | expr '/' expr { $$ = make_expr($1, "/", $3); }
    | expr GT expr  { $$ = make_expr($1, ">", $3); }
    | expr LT expr  { $$ = make_expr($1, "<", $3); }
    | expr EQ expr  { $$ = make_expr($1, "==", $3); }
    | '(' expr ')'  { $$ = $2; }
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