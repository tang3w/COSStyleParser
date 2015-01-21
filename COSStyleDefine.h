#define YYSTYPE char *

#define COSSTYLE_INVALID -1

void *COSStyleParseAlloc(void *(*mallocProc)(size_t));
void COSStyleParse(void *parser, int token, void *value, int *result);
void COSStyleParseFree(void *p, void (*freeProc)(void*));
