%include {
#include <assert.h>
#include <stdlib.h>
#include <string.h>
#include <stdarg.h>
#include "COSStyleDefine.h"

inline static
char *COSStyleStrDup(const char *s) {
    if (!s)
        return NULL;

    size_t len = (strlen(s) + 1);
    char *p = malloc(len * sizeof(char));

    if (p)
        return memcpy(p, s, len);
    else
        return NULL;
}

inline static
char *COSStyleStrDupPrintf(const char *format, ...) {
    char *ptr = NULL;

    va_list ap;
    va_start(ap, format);

    vasprintf(&ptr, format, ap);

    va_end(ap);

    return ptr;
}

void COSStyleCtxInit(COSStyleCtx *ctx);

COSStyleAST *COSStyleASTCreate(COSStyleNodeType nodeType, void *nodeValue, COSStyleAST *l, COSStyleAST *r);

void COSStyleAstFree(COSStyleAST *ast);

}

%name COSStyleParse
%token_prefix   COSSTYLE_
%extra_argument { COSStyleCtx *ctx }
%syntax_error   { ctx->result = 1; }

%token_type    { char * }
%type atom     { COSStyleAST * }
%type item     { COSStyleAST * }
%type expr     { COSStyleAST * }
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

val(A) ::= ID(B) . {
    COSStyleAST *ast = COSStyleASTCreate(COSStyleNodeTypeVal, B, NULL, NULL);
    ast->nodeValueType = COSStyleNodeValTypeID;

    A = ctx->ast = ast;
}

val(A) ::= STRING(B) . {
    COSStyleAST *ast = COSStyleASTCreate(COSStyleNodeTypeVal, B, NULL, NULL);
    ast->nodeValueType = COSStyleNodeValTypeString;

    A = ctx->ast = ast;
}

val(A) ::= HEX(B) . {
    COSStyleAST *ast = COSStyleASTCreate(COSStyleNodeTypeVal, B, NULL, NULL);
    ast->nodeValueType = COSStyleNodeValTypeHex;

    A = ctx->ast = ast;
}

val(A) ::= expr(B) . {
    void *nodeValue = COSStyleStrDup(B->nodeValue);

    COSStyleAST *ast = COSStyleASTCreate(COSStyleNodeTypeVal, nodeValue, NULL, NULL);

    ast->nodeValueType = COSStyleNodeValTypeExpression;

    A = ctx->ast = ast;

    COSStyleAstFree(B);
}

val(A) ::= NUMBER(B) COMMA NUMBER(C) . {
    void *nodeValue = COSStyleStrDupPrintf("%s, %s", B, C);

    COSStyleAST *ast = COSStyleASTCreate(COSStyleNodeTypeVal, nodeValue, NULL, NULL);

    ast->nodeValueType = COSStyleNodeValTypeSize;

    A = ctx->ast = ast;

    free(B);
    free(C);
}

expr(A) ::= item(B) . {
    void *nodeValue = COSStyleStrDup(B->nodeValue);

    COSStyleAST *ast = COSStyleASTCreate(COSStyleNodeTypeVal, nodeValue, NULL, NULL);

    A = ctx->ast = ast;

    COSStyleAstFree(B);
}

expr(A) ::= expr(B) ADD item(C) . {
    void *nodeValue = COSStyleStrDupPrintf("%s + %s", B->nodeValue, C->nodeValue);

    COSStyleAST *ast = COSStyleASTCreate(COSStyleNodeTypeVal, nodeValue, NULL, NULL);

    A = ctx->ast = ast;

    COSStyleAstFree(B);
    COSStyleAstFree(C);
}

expr(A) ::= expr(B) SUB item(C) . {
    void *nodeValue = COSStyleStrDupPrintf("%s - %s", B->nodeValue, C->nodeValue);

    COSStyleAST *ast = COSStyleASTCreate(COSStyleNodeTypeVal, nodeValue, NULL, NULL);

    A = ctx->ast = ast;

    COSStyleAstFree(B);
    COSStyleAstFree(C);
}

item(A) ::= atom(B) . {
    void *nodeValue = COSStyleStrDup(B->nodeValue);

    COSStyleAST *ast = COSStyleASTCreate(COSStyleNodeTypeVal, nodeValue, NULL, NULL);

    A = ctx->ast = ast;

    COSStyleAstFree(B);
}

item(A) ::= item(B) MUL atom(C) . {
    void *nodeValue = COSStyleStrDupPrintf("%s * %s", B->nodeValue, C->nodeValue);

    COSStyleAST *ast = COSStyleASTCreate(COSStyleNodeTypeVal, nodeValue, NULL, NULL);

    A = ctx->ast = ast;

    COSStyleAstFree(B);
    COSStyleAstFree(C);
}

item(A) ::= item(B) DIV atom(C) . {
    void *nodeValue = COSStyleStrDupPrintf("%s / %s", B->nodeValue, C->nodeValue);

    COSStyleAST *ast = COSStyleASTCreate(COSStyleNodeTypeVal, nodeValue, NULL, NULL);

    A = ctx->ast = ast;

    COSStyleAstFree(B);
    COSStyleAstFree(C);
}

atom(A) ::= LPAREN expr(B) RPAREN . {
    void *nodeValue = COSStyleStrDupPrintf("( %s )", B->nodeValue);

    COSStyleAST *ast = COSStyleASTCreate(COSStyleNodeTypeVal, nodeValue, NULL, NULL);

    A = ctx->ast = ast;

    COSStyleAstFree(B);
}

atom(A) ::= PERCENTAGE(B) . {
    A = ctx->ast = COSStyleASTCreate(COSStyleNodeTypeVal, B, NULL, NULL);
}

atom(A) ::= NUMBER(B) . {
    A = ctx->ast = COSStyleASTCreate(COSStyleNodeTypeVal, B, NULL, NULL);
}

semi ::= SEMI .
semi ::= .

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

    astp->nodeType = nodeType;
    astp->nodeValue = nodeValue;
    astp->nodeValueType = 0;
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
