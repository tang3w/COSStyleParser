#include <stdio.h>
#include <stdlib.h>
#include "COSStyleDefine.h"
#include "COSStyleLex.h"

extern int COSStylelex (yyscan_t yyscanner, char **token_value);

int main(int argc, char **argv) {
    yyscan_t scanner;
    COSStylelex_init(&scanner);
    COSStyleset_in(stdin, scanner);

    void *parser = COSStyleParseAlloc(malloc);

    COSStyleCtx ctx;
    COSStyleCtxInit(&ctx);

    int token = 0;

    do {
        char *token_value = NULL;
        token = COSStylelex(scanner, &token_value);
        printf("Current token: %d = %s\n", token, token_value ? token_value : "");
        COSStyleParse(parser, token, token_value, &ctx);
    } while (token > 0 && !ctx.result);

    COSStylelex_destroy(scanner);
    COSStyleParseFree(parser, free);

    if (token < 0) {
        printf("Scanner encountered an error!\n");
    }

    if (ctx.result) {
        printf("Parser encountered an error!\n");
    }

    return 0;
}
