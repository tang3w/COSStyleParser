%{
#include <stdio.h>
#include "COSStyleDefine.h"
#include "COSStyleParser.h"

#define COSSTYLE_COPY_YYTEXT(charpp)                               \
do {                                                               \
    *charpp = (char *)malloc((strlen(yytext) + 1) * sizeof(char)); \
    strcpy(*charpp, yytext);                                       \
} while (0)

%}

%option noyywrap
%option reentrant
%option case-insensitive
%option prefix="COSStyle"
%option header-file="COSStyleLex.h"
%option noinput
%option nounput

i            [0-9]+
h            [0-9a-f]
digit        [-+]?{i}
float        [-+]?({i}\.{i}?|{i}?\.{i})
number       {digit}|{float}[fF]?
percentage   ({digit}|{float})%
string1      \"[^\n\r\f"]*\"
string2      \'[^\n\r\f']*\'
string       {string1}|{string2}
id           -?[_a-z][_a-z0-9-]*
hexcolor     #{h}+
val          {number}|{percentage}|{string}|{hexcolor}

%%

[ \n\r\t\f]
\/\*[^*]*\*+([^/*][^*]*\*+)*\/

"{" { return COSSTYLE_LBRACE; }
"}" { return COSSTYLE_RBRACE; }
"," { return COSSTYLE_COMMA;  }
"." { return COSSTYLE_DOT;    }
":" { return COSSTYLE_COLON;  }
";" { return COSSTYLE_SEMI;   }

{id} {
    COSSTYLE_COPY_YYTEXT(token_value);
    return COSSTYLE_ID;
}

{val} {
    COSSTYLE_COPY_YYTEXT(token_value);
    return COSSTYLE_VAL;
}

. { return COSSTYLE_INVALID; }

%%
