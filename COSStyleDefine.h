#define YYSTYPE char *

#define COSSTYLE_INVALID_TOKEN -1

void *ParseAlloc(void *(*mallocProc)(size_t));
void Parse(void *parser, int token, void *value, int *result);
void ParseFree(void *p, void (*freeProc)(void*));
