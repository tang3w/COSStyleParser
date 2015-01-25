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
    A = ctx->ast = COSStyleASTCreate(COSStyleNodeTypeSheet, NULL, NULL, B);
}

rulelist ::= .

rulelist(A) ::= rulelist(B) rule(C) . {
    A = ctx->ast = COSStyleASTCreate(COSStyleNodeTypeRuleList, NULL, B, C);
}

rule(A) ::= sellist(B) LBRACE decllist(C) RBRACE . {
    A = ctx->ast = COSStyleASTCreate(COSStyleNodeTypeRule, NULL, B, C);
}

sellist(A) ::= sel(B) . {
    A = ctx->ast = COSStyleASTCreate(COSStyleNodeTypeSelList, NULL, NULL, B);
}

sellist(A) ::= sellist(B) COMMA sel(C) . {
    A = ctx->ast = COSStyleASTCreate(COSStyleNodeTypeSelList, NULL, B, C);
}

sel(A) ::= ID(B) . {
    A = ctx->ast = COSStyleASTCreate(COSStyleNodeTypeSel, B, NULL, NULL);
}

sel(A) ::= clslist(B) . {
    A = ctx->ast = COSStyleASTCreate(COSStyleNodeTypeSel, NULL, NULL, B);
}

sel(A) ::= ID(B) clslist(C) . {
    A = ctx->ast = COSStyleASTCreate(COSStyleNodeTypeSel, B, NULL, C);
}

clslist(A) ::= cls(B) . {
    A = ctx->ast = COSStyleASTCreate(COSStyleNodeTypeClsList, NULL, NULL, B);
}

clslist(A) ::= clslist(B) cls(C) . {
    A = ctx->ast = COSStyleASTCreate(COSStyleNodeTypeClsList, NULL, B, C);
}

cls(A) ::= DOT ID(B) . {
    A = ctx->ast = COSStyleASTCreate(COSStyleNodeTypeCls, B, NULL, NULL);
}

decllist ::= .

decllist(A) ::= decllist(B) decl(C) . {
    A = ctx->ast = COSStyleASTCreate(COSStyleNodeTypeDeclList, NULL, B, C);
}

decl(A) ::= prop(B) COLON val(C) semi . {
    A = ctx->ast = COSStyleASTCreate(COSStyleNodeTypeDecl, NULL, B, C);
}

prop(A) ::= ID(B) . {
    A = ctx->ast = COSStyleASTCreate(COSStyleNodeTypeProp, B, NULL, NULL);
}

val(A) ::= VAL(B) . {
    A = ctx->ast = COSStyleASTCreate(COSStyleNodeTypeVal, B, NULL, NULL);
}

val(A) ::= ID(B) . {
    A = ctx->ast = COSStyleASTCreate(COSStyleNodeTypeVal, B, NULL, NULL);
}

semi ::= .
semi ::= SEMI .

%code {

char *COSStyleNodeTypeToStr(COSStyleNodeType nodeType) {
    switch (nodeType) {
    case COSStyleNodeTypeVal      : return "val";
    case COSStyleNodeTypeProp     : return "prop";
    case COSStyleNodeTypeDecl     : return "decl";
    case COSStyleNodeTypeDeclList : return "decllist";
    case COSStyleNodeTypeCls      : return "cls";
    case COSStyleNodeTypeClsList  : return "clslist";
    case COSStyleNodeTypeSel      : return "sel";
    case COSStyleNodeTypeSelList  : return "sellist";
    case COSStyleNodeTypeRule     : return "rule";
    case COSStyleNodeTypeRuleList : return "rulelist";
    case COSStyleNodeTypeSheet    : return "sheet";
    default: break;
    }

    return "undefined";
}

void COSStylePrintAstNodes(COSStyleAST *astp) {
    if (astp == NULL) return;

    printf("_%p\n", astp);
    printf("_%p[label=%s]\n", astp, COSStyleNodeTypeToStr(astp->nodeType));

    COSStyleAST *l = astp->l;
    COSStyleAST *r = astp->r;

    if (l != NULL) printf("_%p -> _%p\n", astp, l);
    if (r != NULL) printf("_%p -> _%p\n", astp, r);

    COSStylePrintAstNodes(l);
    COSStylePrintAstNodes(r);
}

void COSStylePrintAstAsDot(COSStyleAST *astp) {
    printf("digraph G {\n");
    printf("node[shape=rect]\n");
    COSStylePrintAstNodes(astp);
    printf("}");
}

COSStyleAST *COSStyleASTCreate(COSStyleNodeType nodeType, void *nodeValue, COSStyleAST *l, COSStyleAST *r) {
    COSStyleAST *astp = (COSStyleAST *)malloc(sizeof(COSStyleAST));
    astp->nodeType  = nodeType;
    astp->nodeValue = nodeValue;
    astp->data = NULL;
    astp->l = l;
    astp->r = r;
    return astp;
}

void COSStyleCtxInit(COSStyleCtx *ctx) {
    ctx->result = 0;
    ctx->ast = NULL;
}

void COSStyleAstFree(COSStyleAST *ast) {
    if (ast == NULL) return;

    COSStyleAST *l = ast->l;
    COSStyleAST *r = ast->r;

    COSStyleAstFree(l);
    COSStyleAstFree(r);

    if (ast->nodeValue != NULL)
        free(ast->nodeValue);

    free(ast);
}

void COSStyleCtxFree(COSStyleCtx ctx) {
    if (ctx.ast != NULL) {
        COSStyleAstFree(ctx.ast);
    }
}

}
