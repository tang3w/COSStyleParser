%{
#include <stdio.h>
#include "COSStyleDefine.h"
#include "COSStyleParser.h"
%}

%option noyywrap
%option reentrant
%option case-insensitive
%option prefix="COSStyle"
%option header-file="COSStyleLex.h"
%option noinput
%option nounput

i            [0-9]+
digit        [-+]?{i}
float        [-+]?({i}\.{i}?|{i}?\.{i})
number       {digit}|{float}[fF]?
percentage   ({digit}|{float})%
string1      \"[^\n\r\f"]*\"
string2      \'[^\n\r\f']*\'
string       {string1}|{string2}
id           -?[_a-z][_a-z0-9-]*
val          {id}|{number}|{percentage}|{string}

%%

[ \n\r\t\f]

"{" { return LBRACE; }
"}" { return RBRACE; }
"," { return COMMA;  }
"." { return DOT;    }
":" { return COLON;  }
";" { return SEMI;   }

{id}   { return ID;  }
{val}  { return VAL; }

. { return -1; }

%%
