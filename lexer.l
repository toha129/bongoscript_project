%{
#include "parser.tab.h"
#include <stdlib.h>
#include <string.h>
%}

%option noyywrap

%%
"dhoro"        { return DHORO; }
"jodi"         { return JODI; }
"nahole"       { return NAHOLE; }
"loop"         { return LOOP; }
"dekhao"       { return DEKHAO; }
"nao"          { return NAO; }

":"            { return COLON; }
"["            { return LBRACKET; }
"]"            { return RBRACKET; }

">"            { return GT; }
"<"            { return LT; }

"+"            { return '+'; }
"-"            { return '-'; }
"*"            { return '*'; }
"/"            { return '/'; }

"="            { return '='; }

[0-9]+ { yylval.str = strdup(yytext); return NUMBER; }
[a-zA-Z_][a-zA-Z0-9_]* { yylval.str = strdup(yytext); return ID; }

\n             { return NEWLINE; }
[ \t]          ;

.              { return yytext[0]; }

%%