%include {
#include <assert.h>
#include "COSStyleDefine.h"
}

%name COSStyleParse
%token_prefix   COSSTYLE_
%extra_argument { int *result  }
%syntax_error   { *result = 1; }

sheet    ::= rulelist .
rulelist ::= .
rulelist ::= rulelist rule .
rule     ::= sellist LBRACE decllist RBRACE .
sellist  ::= sel .
sellist  ::= sellist COMMA sel .
sel      ::= ID .
sel      ::= ID clslist .
clslist  ::= cls .
clslist  ::= clslist cls .
cls      ::= DOT ID .
decllist ::= .
decllist ::= decllist decl .
decl     ::= ID COLON val semi .
val      ::= ID .
val      ::= VAL .
semi     ::= .
semi     ::= SEMI .
