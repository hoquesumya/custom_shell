%{
#include <string.h>
#include <stdio.h>
void yyerror(char *);
#include "y.tab.h"
%}


word \% |\= | \+ | \' | \" | [\(\\)]\$* | \/ | \_ | \-|\.|\?|\*|\~a-zA-Z0-9]+
ior  [ 1-2]">&"[1-2 ] 
pipe "|" 
and "&"
logicand "&&"
add "+"
sub "-"
div "\\"
mul "*"
option [ ]-[a-zA-Z0-9]+
option2 [ ]"-""-"[a-zA-Z=a-zA-Z]+
comment \s*#+[(?s).]*
command \s*[^#]$*['"($]*[a-zA-Z0-9_.=]+['")]*\s*
%%
"#" { yylval.stringValue = strdup(yytext);return IO; }
[ 1 ]?">" { yylval.stringValue = strdup(yytext);return IO; }
"" { yylval.stringValue = strdup(yytext);return IO;}
[ 1]?">>" { yylval.stringValue = strdup(yytext);return IO; }
{comment} { return COMMENT;}
{logicand} { return lAnd;}
{command} { yylval.stringValue = strdup(yytext);return WORD; }
{ior} { yylval.stringValue = strdup(yytext);return IOR;}
{and} { yylval.stringValue = strdup(yytext);return AND;}
{add} { yylval.stringValue = strdup(yytext);return ADD; }
{pipe} { yylval.stringValue = strdup(yytext);return PIPE;}
{option} { yylval.stringValue = strdup(yytext);return OPTION;} 
{option2} { yylval.stringValue = strdup(yytext); return OPTION2;}
\n        { return NEWLINE; }
%%

int yywrap(void) {
    return 1;
}


