%include {
#include <assert.h>
#include "COSStyleDefine.h"
}

%extra_argument { int *result  }
%syntax_error   { *result = 1; }

sheet    ::= .
sheet    ::= rulelist .
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
decl     ::= ID COLON val semi.
semi     ::= .
semi     ::= SEMI .
val      ::= VAL .
