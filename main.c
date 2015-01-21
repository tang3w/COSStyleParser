#include <stdio.h>
#include <stdlib.h>
#include "COSStyleDefine.h"
#include "COSStyleLex.h"

int main(int argc, char **argv) {
    yyscan_t scanner;
    COSStylelex_init(&scanner);
    COSStyleset_in(stdin, scanner);

    void *parser = ParseAlloc(malloc);

    int token = 0;
    int result = 0;

    do {
        token = COSStylelex(scanner);
        printf("Current token: %d\n", token);
        Parse(parser, token, NULL, &result);
    } while (token > 0 && !result);

    COSStylelex_destroy(scanner);
    ParseFree(parser, free);

    if (token < 0) {
        printf("Scanner encountered an error!\n");
    }

    if (result) {
        printf("Parser encountered an error!\n");
    }

    return 0;
}
