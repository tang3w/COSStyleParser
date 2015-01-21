#define YYSTYPE char *

#define COSSTYLE_INVALID -1
#define YY_DECL int COSStylelex (yyscan_t yyscanner, char **token_value)

void *COSStyleParseAlloc(void *(*mallocProc)(size_t));
void COSStyleParse(void *parser, int token, void *value, int *result);
void COSStyleParseFree(void *p, void (*freeProc)(void*));
