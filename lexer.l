%{
#include "parser.tab.h"
#include <stdlib.h>
#include <string.h>
#include <stdio.h>

/* ── Indentation tracking stack ── */
int indent_stack[100] = {0};
int indent_top = 0;

/* ── Pending token queue (LIFO stack) ── */
int pending[100];
int npending = 0;

/* ── EOF guard ── */
int eof_done = 0;
%}

%option noyywrap

%%
    /* ── Drain any pending tokens before matching new input ── */
    if (npending > 0) {
        return pending[--npending];
    }

\n[ ]* {
    int spaces = yyleng - 1;

    /* Increase in indentation → queue INDENT, return NEWLINE */
    if (spaces > indent_stack[indent_top]) {
        indent_stack[++indent_top] = spaces;
        pending[npending++] = INDENT;
        return NEWLINE;
    }

    /* Decrease in indentation → queue one or more DEDENTs, return NEWLINE */
    while (indent_top > 0 && spaces < indent_stack[indent_top]) {
        indent_top--;
        pending[npending++] = DEDENT;
    }

    return NEWLINE;
}

"dhoro"        { return DHORO; }

"\""[^"\n]*"\""  { yylval.str = strdup(yytext); return STRING; }
"jodi"         { return JODI; }
"nahole"       { return NAHOLE; }
"loop"         { return LOOP; }
"dekhao"       { return DEKHAO; }
"nao"          { return NAO; }

":"            { return COLON; }
"["            { return LBRACKET; }
"]"            { return RBRACKET; }

"=="           { return EQ; }
">"            { return GT; }
"<"            { return LT; }

"+"            { return '+'; }
"-"            { return '-'; }
"*"            { return '*'; }
"/"            { return '/'; }

"="            { return '='; }

[0-9]+         { yylval.str = strdup(yytext); return NUMBER; }
[a-zA-Z_][a-zA-Z0-9_]* { yylval.str = strdup(yytext); return ID; }

[ \t]          ;
.              { return yytext[0]; }

<<EOF>> {
    if (!eof_done) {
        eof_done = 1;
        /* Emit closing DEDENTs for every remaining open indentation level */
        while (indent_top > 0) {
            indent_top--;
            pending[npending++] = DEDENT;
        }
        /* Return a NEWLINE to close the last statement; pending DEDENTs follow */
        return NEWLINE;
    }
    return 0;
}

%%