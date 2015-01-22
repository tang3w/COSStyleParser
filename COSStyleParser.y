%include {
#include <assert.h>
#include <stdlib.h>
#include "COSStyleDefine.h"

void COSStyleCtxInit(COSStyleCtx *ctx);

COSStyleAST *COSStyleASTCreate(COSStyleNodeType nodeType, void *nodeValue, COSStyleAST *l, COSStyleAST *r);

}

%name COSStyleParse
%token_prefix   COSSTYLE_
%extra_argument { COSStyleCtx *ctx }
%syntax_error   { ctx->result = 1; }

%token_type    { char * }
%type val      { COSStyleAST * }
%type decl     { COSStyleAST * }
%type decllist { COSStyleAST * }
%type prop     { COSStyleAST * }
%type cls      { COSStyleAST * }
%type clslist  { COSStyleAST * }
%type sel      { COSStyleAST * }
%type sellist  { COSStyleAST * }
%type rule     { COSStyleAST * }
%type rulelist { COSStyleAST * }
%type sheet    { COSStyleAST * }

sheet(A) ::= rulelist(B) . {
    A = COSStyleASTCreate(COSStyleNodeTypeSheet, NULL, B, NULL);
}

rulelist ::= .

rulelist(A) ::= rulelist(B) rule(C) . {
    A = COSStyleASTCreate(COSStyleNodeTypeRuleList, NULL, B, C);
}

rule(A) ::= sellist(B) LBRACE decllist(C) RBRACE . {
    A = COSStyleASTCreate(COSStyleNodeTypeRule, NULL, B, C);
}

sellist(A) ::= sel(B) . {
    A = COSStyleASTCreate(COSStyleNodeTypeSelList, NULL, B, NULL);
}

sellist(A) ::= sellist(B) COMMA sel(C) . {
    A = COSStyleASTCreate(COSStyleNodeTypeSelList, NULL, B, C);
}

sel(A) ::= ID(B) . {
    A = COSStyleASTCreate(COSStyleNodeTypeSel, B, NULL, NULL);
}

sel(A) ::= ID(B) clslist(C) . {
    A = COSStyleASTCreate(COSStyleNodeTypeSel, B, NULL, C);
}

clslist(A) ::= cls(B) . {
    A = COSStyleASTCreate(COSStyleNodeTypeClsList, NULL, B, NULL);
}

clslist(A) ::= clslist(B) cls(C) . {
    A = COSStyleASTCreate(COSStyleNodeTypeClsList, NULL, B, C);
}

cls(A) ::= DOT ID(B) . {
    A = COSStyleASTCreate(COSStyleNodeTypeCls, B, NULL, NULL);
}

decllist ::= .

decllist(A) ::= decllist(B) decl(C) . {
    A = COSStyleASTCreate(COSStyleNodeTypeDeclList, NULL, B, C);
}

decl(A) ::= prop(B) COLON val(C) semi . {
    A = COSStyleASTCreate(COSStyleNodeTypeDecl, NULL, B, C);
}

prop(A) ::= ID(B) . {
    A = COSStyleASTCreate(COSStyleNodeTypeProp, B, NULL, NULL);
}

val(A) ::= VAL(B) . {
    A = COSStyleASTCreate(COSStyleNodeTypeVal, B, NULL, NULL);
}

val(A) ::= ID(B) . {
    A = COSStyleASTCreate(COSStyleNodeTypeVal, B, NULL, NULL);
}

semi ::= .
semi ::= SEMI .

%code {

COSStyleAST *COSStyleASTCreate(COSStyleNodeType nodeType, void *nodeValue, COSStyleAST *l, COSStyleAST *r) {
    COSStyleAST *astp = (COSStyleAST *)malloc(sizeof(COSStyleAST));
    astp->nodeType  = nodeType;
    astp->nodeValue = nodeValue;
    astp->l = l;
    astp->r = r;
    return astp;
}

void COSStyleCtxInit(COSStyleCtx *ctx) {
    ctx->result = 0;
    ctx->ast = NULL;
}

}
