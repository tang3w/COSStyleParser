#include <stdio.h>
#include <stdlib.h>
#include "COSStyleDefine.h"
#include "COSStyleLex.h"

int main(int argc, char **argv) {
    yyscan_t scanner;
    COSStylelex_init(&scanner);
    COSStyleset_in(stdin, scanner);

    void *parser = COSStyleParseAlloc(malloc);

    int token = 0;
    int result = 0;

    do {
        token = COSStylelex(scanner);
        printf("Current token: %d\n", token);
        COSStyleParse(parser, token, NULL, &result);
    } while (token > 0 && !result);

    COSStylelex_destroy(scanner);
    COSStyleParseFree(parser, free);

    if (token < 0) {
        printf("Scanner encountered an error!\n");
    }

    if (result) {
        printf("Parser encountered an error!\n");
    }

    return 0;
}
