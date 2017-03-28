%{
#ifdef PRINT
#define TOKEN(t) printf("Token: " #t "\n");
#define TOKEN_I(t) printf("Token: " #t " %d\n", atoi(yytext));
#define TOKEN_R(t) printf("Token: " #t " %f\n", atof(yytext));
#define TOKEN_C(t) printf("Token: " #t " %s\n", yytext);
#define TOKEN_ID(t) printf("Token: " #t " %s\n", yytext);
#else
#define TOKEN(t) return(t);
#define TOKEN_I(t) yylval.iVal = atoi(yytext); return(t);
#define TOKEN_C(t) yylval.iVal = installId(yytext, "char"); return(t);
#define TOKEN_ID(t) yylval.iVal = installId(yytext, ""); return(t);
#define TOKEN_R(t) yylval.iVal = installId(yytext, "real"); return(t);

#include <string.h>
extern SYMTABNODEPTR symTab[SYMTABSIZE];
extern int currentSymTabSize;
int installId(char *, char *);
#endif
%}

delim				[ \t\n]
ws					{delim}+
letter				[A-Za-z]
char_const			'{letter}'
digit				[0-9]
id					{letter}({letter}|{digit})*
int_constant		{digit}+		
real_constant		{int_constant}\.{int_constant}

%%

{ws}        ; /* white space, do nothing */

";"				TOKEN(SEMICOLON);
":"				TOKEN(COLON);
","				TOKEN(COMMA);
"."				TOKEN(FULLSTOP);
READ			TOKEN(READ);
WRITE			TOKEN(WRITE);
IF				TOKEN(IF);
THEN			TOKEN(THEN);
ELSE			TOKEN(ELSE);
WHILE     		TOKEN(WHILE);
DO       		TOKEN(DO);
IS				TOKEN(IS);
BY				TOKEN(BY);
FOR				TOKEN(FOR);
TO				TOKEN(TO);
NOT				TOKEN(NOT);
AND				TOKEN(AND);
OR				TOKEN(OR);

NEWLINE			TOKEN(NEWLINE);
ENDIF			TOKEN(ENDIF);
ENDP			TOKEN(ENDP);
ENDDO			TOKEN(ENDDO);
ENDWHILE		TOKEN(ENDWHILE);
ENDFOR			TOKEN(ENDFOR);
"("				TOKEN(BRA);
")"				TOKEN(KET);
DECLARATIONS	TOKEN(DECLARATIONS);

CODE			TOKEN(CODE);
OF				TOKEN(OF);
TYPE      		TOKEN(TYPE)
CHARACTER       TOKEN(CHARACTER)
INTEGER         TOKEN(INTEGER)
REAL            TOKEN(REAL)

{id}		    TOKEN_ID(id);
{int_constant}  TOKEN_I(integer_value);
{real_constant} TOKEN_R(real_value);
{char_const}	TOKEN_C(char_const);

"+"        		TOKEN(PLUS);
"-"         	TOKEN(MINUS);
"*"				TOKEN(TIMES);
"/"				TOKEN(DIVIDE);
"<"				TOKEN(LESSTHAN);
">"				TOKEN(GREATERTHAN);
"="				TOKEN(EQUALS);
"<>"			TOKEN(NOTEQUAL);
"<="			TOKEN(LESSTHANOREQUAL);
">="			TOKEN(GREATERTHANOREQUAL);
"->"			TOKEN(ASSIGNMENT);

%%

/* Here is the code for the library of symbol table routines */

/* code for a simple symbol table, which is an array of pointers to
   structs, each of which contains an identifier.
*/

#ifndef PRINT
SYMTABNODEPTR newSymTabNode()
{
    return ((SYMTABNODEPTR)malloc(sizeof(SYMTABNODE)));
}

int lookup(char *s)
{
    extern SYMTABNODEPTR symTab[SYMTABSIZE];
    extern int currentSymTabSize;
    int i;

    for(i=0; i<currentSymTabSize; i++)
    {
        if(strncmp(s,symTab[i]->identifier,IDLENGTH) == 0)
        {
            return (i);
        }
    }
    return (-1);    
}

/* Look up an identifier in the symbol table, if its there return
   its index.  If its not there, put it in the end position,
   as long as the table isn't full, and return its index.
*/

int installId(char *id, char *type) 
{
    extern SYMTABNODEPTR symTab[SYMTABSIZE]; 
    extern int currentSymTabSize;
    int index;

    index = lookup(id);
    if (index >= 0)
    {
        return (index);
    }
    else 
       if (currentSymTabSize >= SYMTABSIZE) 
          /* SYMTAB is full */
          return (NOTHING) ;
    else
    {
       symTab[currentSymTabSize] = newSymTabNode();
       /* Recommended code for preventing buffer overrun on bounded strings */
       strncpy(symTab[currentSymTabSize]->identifier,id,IDLENGTH);
       strncpy(symTab[currentSymTabSize]->type,type,IDLENGTH);
       symTab[currentSymTabSize]->identifier[IDLENGTH-1] = '\0';
       symTab[currentSymTabSize]->type[IDLENGTH-1] = '\0';
       return(currentSymTabSize++);
    }
}
#endif