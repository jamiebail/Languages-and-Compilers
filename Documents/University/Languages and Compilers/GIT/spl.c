#include <stdio.h>
int yyparse(void);

int main(void)
{
#ifdef YYDEBUG
    extern int yydebug;
    yydebug = 1;
#endif

    return(yyparse());
}

void yyerror(char *s)
{
    fprintf(stderr, "Error : Exiting %s\n", s);
}