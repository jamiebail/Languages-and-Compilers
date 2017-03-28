%{

#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <string.h>

/* 
   Some constants.
*/

  /* These constants are used later in the code */
#define SYMTABSIZE     50
#define IDLENGTH       15
#define NOTHING        -1
#define INDENTOFFSET    2

enum ParseTreeNodeType { PROGRAM, BLOCK, DECLARATION_BLOCK, IDENTIFIERS, STATEMENT_LIST, STATEMENT, ASSIGNMENT_STATEMENT,
						 IF_STATEMENT, DO_STATEMENT, WHILE_STATEMENT, FOR_STATEMENT, WRITE_STATEMENT, READ_STATEMENT, OUTPUT_LIST,
						 CONDITIONAL, NOT_CONDITIONAL, AND_CONDITIONAL, OR_CONDITIONAL, CONDITION, COMPARATOR, EXPRESSION, TERM, ID_VALUE ,VALUE, BRA_VALUE,CONSTANT, CHAR_CONSTANT, NUMBER,
						 REAL_CONSTANT, NEGATIVE_REAL, NEGATIVE_INT, NEWLINE_STATEMENT, INT, FLOAT, CHAR, IDENTIFIERVAL,
						 EQUAL_COMPARATOR, NOTEQUAL_COMPARATOR, GREATERTHAN_COMPARATOR, LESSTHAN_COMPARATOR, GREATERTHANOREQUAL_COMPARATOR, LESSTHANOREQUAL_COMPARATOR, PLUS_EXPRESSION, MINUS_EXPRESSION, TIMES_TERM, DIVIDE_TERM
};  
						 

char *NodeName[] = {
						"PROGRAM", "BLOCK", "DECLARATION_BLOCK", "IDENTIFIERS", "STATEMENT_LIST", "STATEMENT", "ASSIGNMENT_STATEMENT",
						 "IF_STATEMENT", "DO_STATEMENT", "WHILE_STATEMENT", "FOR_STATEMENT", "WRITE_STATEMENT", "READ_STATEMENT", "OUTPUT_LIST",
						 "CONDITIONAL", "NOT_CONDITIONAL", "AND_CONDITIONAL", "OR_CONDITIONAL", "CONDITION", "COMPARATOR", "EXPRESSION", "TERM", "ID_VALUE", "VALUE", "BRA_VALUE","CONSTANT", "CHAR_CONSTANT","NUMBER", "REAL_CONSTANT", "NEGATIVE_REAL", "NEGATIVE_INT", "NEWLINE_STATEMENT",
						 "NUMBER_CONSTANT", "FLOAT", "CHAR", "IDENTIFIERVAL",  "EQUAL_COMPARATOR", "NOTEQUAL_COMPARATOR", "GREATERTHAN_COMPARATOR", "LESSTHAN_COMPARATOR", "GREATERTHANOREQUAL_COMPARATOR", "LESSTHANOREQUAL_COMPARATOR", "PLUS_EXPRESSION", "MINUS_EXPRESSION", "TIMES_TERM", "DIVIDE_TERM"
};

#ifndef TRUE
#define TRUE 1
#endif

#ifndef FALSE
#define FALSE 0
#endif

#ifndef NULL
#define NULL 0
#endif

/* ------------- parse tree definition --------------------------- */

struct treeNode {
    int  item;
    int  nodeIdentifier;
    struct treeNode *first;
    struct treeNode *second;
    struct treeNode *third;
  };

typedef  struct treeNode TREE_NODE;
typedef  TREE_NODE        *TERNARY_TREE;

/* ------------- forward declarations --------------------------- */

TERNARY_TREE create_node(int,int,TERNARY_TREE,TERNARY_TREE,TERNARY_TREE);
void yyerror(char *);
int yylex(void);
void GenerateCode(TERNARY_TREE, int indent);
#ifdef DEBUG
void PrintTree(TERNARY_TREE, int indent);
#endif
static int indent = 0;
void indentTree(int indent);
void indentCode(int indent);
int returnTerminal(TERNARY_TREE t, int indent);
int isPrinting = FALSE;
int forVariable;
int forCondition;
int forIncrement;
int preventPrint = FALSE;
int hasErrored = FALSE;

/* ------------- symbol table definition --------------------------- */

struct symTabNode {
    char identifier[IDLENGTH];
	char type[IDLENGTH];
};

char currentIdentifier[IDLENGTH];
char currentStatement[IDLENGTH];
char PROGSTART[IDLENGTH];
char PROGEND[IDLENGTH];

typedef  struct symTabNode SYMTABNODE;
typedef  SYMTABNODE        *SYMTABNODEPTR;

SYMTABNODEPTR  symTab[SYMTABSIZE]; 

int currentSymTabSize = 0;

%}

/****************/
/* Start symbol */
/****************/

%start  program

/**********************/
/* Action value types */
/**********************/

%union {
    int iVal;
    TERNARY_TREE  tVal;
}

/* Whereas Rules return a tVal type (Tree) */


%token SEMICOLON COLON COMMA FULLSTOP READ WRITE IF THEN ELSE WHILE DO
	   IS BY FOR TO NOT AND OR NEWLINE ENDIF ENDP ENDDO ENDWHILE ENDFOR ASSIGNMENT
	   BRA KET DECLARATIONS CODE OF TYPE PLUS MINUS TIMES DIVIDE CHARACTER INTEGER REAL
	   LESSTHAN GREATERTHAN EQUALS NOTEQUAL LESSTHANOREQUAL GREATERTHANOREQUAL DIGITS DIGIT 

%token<iVal> id integer_value real_value char_const

%type<tVal> program block declaration_block type identifiers statement_list statement assignment_statement
			if_statement do_statement while_statement for_statement write_statement read_statement output_list
			conditional condition comparator expression term value constant number_constant identifiervalue

%%

program : identifiervalue COLON block ENDP identifiervalue FULLSTOP
			{
				TERNARY_TREE ParseTree;
				ParseTree = create_node(NOTHING, PROGRAM, $1, $3, $5);
				#ifdef DEBUG
				PrintTree(ParseTree, indent);
				#else
				GenerateCode(ParseTree, indent);
				#endif
			}
			;

block : DECLARATIONS declaration_block CODE statement_list
			{
				$$ = create_node(NOTHING, BLOCK, $2, $4, NULL);
			}
		| CODE statement_list
			{
				$$ = create_node(NOTHING, BLOCK, $2, NULL, NULL);
			}
			;

declaration_block : identifiers OF TYPE type SEMICOLON 
			{
				$$ = create_node(NOTHING, DECLARATION_BLOCK, $1, $4, NULL);
			}
		| identifiers OF TYPE type SEMICOLON declaration_block
			{
				$$ = create_node(NOTHING, DECLARATION_BLOCK, $1, $4, $6);
			}
			;

type : CHARACTER
			{
				$$ = create_node(NOTHING, CHAR, NULL, NULL, NULL);
			}
		| INTEGER
			{
				$$ = create_node(NOTHING, INT, NULL, NULL, NULL);
			}
		| REAL
			{
				$$ = create_node(NOTHING, FLOAT, NULL, NULL, NULL);
			}
			;
			
identifiers : identifiervalue
			{
				$$ = create_node(NOTHING, IDENTIFIERS, $1, NULL, NULL);
			}
		| identifiervalue COMMA identifiers
			{
				$$ = create_node(NOTHING, IDENTIFIERS, $1, $3, NULL);
			}
			;
			
identifiervalue : id
			{
				$$ = create_node($1, IDENTIFIERVAL, NULL, NULL, NULL);
			}
			;
  
statement_list : statement 
			{
				$$ = create_node(NOTHING, STATEMENT_LIST, $1, NULL, NULL);
			}
		| statement SEMICOLON statement_list
			{
				$$ = create_node(NOTHING, STATEMENT_LIST, $1, $3, NULL);
			}
			;

statement : assignment_statement 
			{
				$$ = create_node(NOTHING, STATEMENT, $1, NULL, NULL);
			}
		| if_statement 
			{
				$$ = create_node(NOTHING, STATEMENT, $1, NULL, NULL);
			}
		| do_statement 
			{
				$$ = create_node(NOTHING, STATEMENT, $1, NULL, NULL);
			}
		| while_statement 
			{
				$$ = create_node(NOTHING, STATEMENT, $1, NULL, NULL);
			}	
		| for_statement 
			{
				$$ = create_node(NOTHING, STATEMENT, $1, NULL, NULL);
			}
		| write_statement 
			{
				$$ = create_node(NOTHING, STATEMENT, $1, NULL, NULL);
			}
		| read_statement
			{	
				$$ = create_node(NOTHING, STATEMENT, $1, NULL, NULL);
			}
			;
			

assignment_statement : expression ASSIGNMENT identifiervalue
			{
				$$ = create_node(NOTHING, ASSIGNMENT_STATEMENT, $3, $1, NULL);
			}
			;

if_statement : IF conditional THEN statement_list ENDIF 	
			{
				$$ = create_node(NOTHING, IF_STATEMENT, $2, $4, NULL);
			}			
		| IF conditional THEN statement_list ELSE statement_list ENDIF
			{
				$$ = create_node(NOTHING, IF_STATEMENT, $2, $4, $6);
			}
			;
			 
do_statement : DO statement_list WHILE conditional ENDDO
			{
				$$ = create_node(NOTHING, DO_STATEMENT, $2, $4, NULL);
			}
			;

while_statement : WHILE conditional DO statement_list ENDWHILE
			{
				$$ = create_node(NOTHING, WHILE_STATEMENT, $2, $4, NULL);
			}
			;
 
for_statement : FOR identifiervalue IS expression BY expression TO expression DO statement_list ENDFOR
			{
				$$ = create_node(NOTHING, FOR_STATEMENT, $2, create_node(NOTHING, FOR_STATEMENT, $4, $6, $8), $10);
			}
			;
 
write_statement : WRITE BRA output_list KET
			{
				$$ = create_node(NOTHING, WRITE_STATEMENT, $3, NULL, NULL);
			}
		| NEWLINE
			{
				$$ = create_node(NOTHING, NEWLINE_STATEMENT, NULL, NULL, NULL);
			}
			;
 
read_statement : READ BRA identifiervalue KET
			{
				$$ = create_node(NOTHING, READ_STATEMENT, $3, NULL, NULL);
			}
			;

output_list : value
			{
				$$ = create_node(NOTHING, OUTPUT_LIST, $1, NULL, NULL);
			}
		| value COMMA output_list
			{
				$$ = create_node(NOTHING, OUTPUT_LIST, $1, $3, NULL);
			}
			;		
 
conditional :  condition
			{
				$$ = create_node(NOTHING, CONDITIONAL, $1, NULL, NULL);
			}
		| NOT conditional
			{
				$$ = create_node(NOT, NOT_CONDITIONAL, $2, NULL, NULL);
			}
		| condition AND conditional
			{
				$$ = create_node(AND, AND_CONDITIONAL, $1, $3, NULL);
			}
		| condition OR conditional 
			{
				$$ = create_node(OR, OR_CONDITIONAL, $1, $3, NULL);
			}
			;
 
 
condition : expression comparator expression
			{
				$$ = create_node(NOTHING, CONDITION, $1, $2, $3);
			}
			;
 
comparator :  EQUALS
			{
				$$ = create_node(NOTHING, EQUAL_COMPARATOR, NULL, NULL, NULL);
			}
		| NOTEQUAL
			{
				$$ = create_node(NOTHING, NOTEQUAL_COMPARATOR, NULL, NULL, NULL);
			}
		| GREATERTHAN
			{
				$$ = create_node(NOTHING, GREATERTHAN_COMPARATOR, NULL, NULL, NULL);
			}
		| LESSTHAN
			{
				$$ = create_node(NOTHING, LESSTHAN_COMPARATOR, NULL, NULL, NULL);
			}
		| GREATERTHANOREQUAL
			{
				$$ = create_node(NOTHING, GREATERTHANOREQUAL_COMPARATOR, NULL, NULL, NULL);
			}
		| LESSTHANOREQUAL 
			{
				$$ = create_node(NOTHING, LESSTHANOREQUAL_COMPARATOR, NULL, NULL, NULL);
			}
			;
 
expression :  term PLUS expression
			{
				$$ = create_node(NOTHING, PLUS_EXPRESSION, $1, $3, NULL);			
			}
		| term MINUS expression
			{
				$$ = create_node(NOTHING, MINUS_EXPRESSION, $1, $3, NULL);	
			}
		| term
			{
				$$ = create_node(NOTHING, EXPRESSION, $1, NULL, NULL);	
			}
			;

term : value
			{
				$$ = create_node(NOTHING, TERM, $1, NULL, NULL);
			}
		| value TIMES term
			{
				$$ = create_node(NOTHING, TIMES_TERM, $1, $3, NULL);
			}
		| value DIVIDE term 
			{
				$$ = create_node(NOTHING, DIVIDE_TERM, $1, $3, NULL);
			}
			;
 
value : identifiervalue
			{
				$$ = create_node(NOTHING, ID_VALUE, $1, NULL, NULL);
			}
		| constant
			{
				$$ = create_node(NOTHING, VALUE, $1, NULL, NULL);
			}
		| BRA expression KET
			{
				$$ = create_node(NOTHING, BRA_VALUE, $2, NULL, NULL);		
			}
			;

constant : number_constant
			{
				$$ = create_node(NOTHING, CONSTANT, $1, NULL, NULL);		
			}
		| char_const
			{
				$$ = create_node($1, CHAR_CONSTANT, NULL, NULL, NULL);		
			}
			;
  
number_constant : integer_value
			{
				$$ = create_node($1, NUMBER, NULL, NULL, NULL);	
			}
		| MINUS integer_value
			{
				$$ = create_node($2, NEGATIVE_INT, NULL, NULL, NULL);					
			}
		| real_value
			{
				$$ = create_node($1, REAL_CONSTANT, NULL, NULL, NULL);				
			}
		| MINUS real_value
			{
				$$ = create_node($2, NEGATIVE_REAL, NULL, NULL, NULL);
			}
			;
 
%%

TERNARY_TREE create_node(int ival, int case_identifier, TERNARY_TREE p1,
			 TERNARY_TREE  p2, TERNARY_TREE  p3)
{
    TERNARY_TREE t;
    t = (TERNARY_TREE)malloc(sizeof(TREE_NODE));
    t->item = ival;
    t->nodeIdentifier = case_identifier;
    t->first = p1;
    t->second = p2;
    t->third = p3;
    return (t);
}

void Debugger(int good)
{
	if(1)
		printf("good");
	else
		printf("bad");
		
}
#ifdef DEBUG
void PrintTree(TERNARY_TREE t, int indent)
{
   if (t == NULL) return;

		indentCode(indent);
		if (t->item != NOTHING){
			printf("%s\n",NodeName[t->nodeIdentifier]);
			switch(t->nodeIdentifier)
			{
				case CHAR_CONSTANT:
					indentTree(indent);
					printf("[%s]\n", symTab[t->item]->identifier);
					return;	
				case IDENTIFIERVAL:
					indentTree(indent);
					printf("[%s]\n", symTab[t->item]->identifier);
					return;
				case NUMBER:
					indentTree(indent);
					printf("%d\n", t->item);
					return;
				case REAL_CONSTANT:
					indentTree(indent);
					printf(symTab[t->item]->identifier);
					printf("\n");
					return;
				case NEGATIVE_INT:	
					indentTree(indent);
					printf("-%d\n", t->item);
					return;
				case NEGATIVE_REAL:	
					indentTree(indent);
					printf(symTab[t->item]->identifier);
					printf("\n");
					return;
				case PROGRAM:
					indentTree(indent);
					printf("[%s]\n", symTab[t->item]->identifier);
					break;
				case VALUE:
					if(t->item != NOTHING){
						indentTree(indent);
						printf("[%s]\n", symTab[t->item]->identifier);
					}
			}
		}
	else{
				printf("%s\n",NodeName[t->nodeIdentifier]);
		}  
   indent += INDENTOFFSET;
   PrintTree(t->first, indent);
   PrintTree(t->second, indent);
   PrintTree(t->third, indent);
   indent -= INDENTOFFSET;
}
#endif

void indentTree(int indent){
	for(int i = 0; i < indent; i++){ printf(" ");};
	printf("|");
}

void indentCode(int indent){
	for(int i = 0; i < indent; i++){ printf(" ");};
}


int returnTerminal(TERNARY_TREE t,  int indent){
	preventPrint = TRUE;
	GenerateCode(t, indent);
	preventPrint = FALSE;
}

void GenerateCode(TERNARY_TREE t, int indent)
{
   if (t == NULL) return;
        bool printing = false;
		switch(t->nodeIdentifier)
			{
				case PROGRAM:
				if(!hasErrored){
				// create_node(NOTHING, PROGRAM, $1, $3, $5);
				// Program start and end check
				strcpy(PROGSTART, symTab[t->first->item]->identifier);
				strcpy(PROGEND, symTab[t->third->item]->identifier);
				if(!strcmp(PROGSTART, PROGEND) == 0)  
				{
					yyerror("| Program start and end do not match");
					break;
				}
				printf("#include <stdio.h>\n\n");
				printf("int main(void)\n{\n");				
				GenerateCode(t->second, indent);
				printf("}\n");
				printing = false;
				}
				return;

				case BLOCK:
				if(!hasErrored){
					// create_node(NOTHING, BLOCK, $2, $4, NULL);
					GenerateCode(t->first, indent);
					printf("\n");
					if(t->second);
						GenerateCode(t->second, indent);
				}
				 return;
				 
				case DECLARATION_BLOCK:		
					if(!hasErrored){
					//create_node(NOTHING, DECLARATION_BLOCK, $1, $3, $5)
						GenerateCode(t->second, indent);
						GenerateCode(t->first, indent);
						printf("; \n");
					if(t->third)
					{
						GenerateCode(t->third, indent);
					}
					}
				 return;				 
				case IDENTIFIERS:
					if(!hasErrored){
					//$$ = create_node(NOTHING, IDENTIFIERS, $1, NULL, NULL);	
					if(t->first->item > 0 && t->first->item < SYMTABSIZE)
						strcpy(symTab[t->first->item]->type, currentIdentifier);					
					else{
						printf("Unknown Identifier");
					}
					GenerateCode(t->first, indent);
					if(t->second)
					{
						printf(", ");
						GenerateCode(t->second, indent);
					}
					}
					//create_node($1, IDENTIFIERS, NULL, NULL, NULL);
				 return;
				case NEWLINE_STATEMENT:
					if(!hasErrored){
					printf("printf(\"\\n\");\n");
					}
					return;
				case IDENTIFIERVAL:
				if(strcmp(PROGSTART, symTab[t->item]->identifier) == 0)
				{
					yyerror("Used program start value as an identifier");
					hasErrored = TRUE;
				}
					if(!hasErrored){
					if(isPrinting)
					{
						if(t->item > 0 && t->item < SYMTABSIZE)
						{
						if(strcmp(symTab[t->item]->type, "char") == 0)
							printf("\"%%c\", ");
						if(strcmp(symTab[t->item]->type, "int") == 0)
							printf("\"%%d\", ");
						if(strcmp(symTab[t->item]->type, "float") == 0)
							printf("\"%%f\", ");
						if(strcmp(currentStatement, "READ_STATEMENT") == 0)
						{
							printf("&_%s", symTab[t->item]->identifier);
						}
						else
							printf("_%s", symTab[t->item]->identifier);
						printf(");\n");
						}
					}									
					else{
					if(!preventPrint)
						printf("_%s", symTab[t->item]->identifier);
					}
					}
					return;
				case CHAR:
					if(!hasErrored){
					printf("char ");
					strcpy(currentIdentifier, "char");
					}
					return;
				case INT:
					if(!hasErrored){
					printf("int ");
					strcpy(currentIdentifier, "int");
					}
					return;
				case FLOAT:
					if(!hasErrored){
					printf("float ");
					strcpy(currentIdentifier, "float");
					}
					return;
				case STATEMENT_LIST:
					if(!hasErrored){
					//create_node(NOTHING, STATEMENT_LIST, $1, NULL, NULL);
					//create_node(NOTHING, STATEMENT_LIST, $1, $3, NULL);
					GenerateCode(t->first, indent);
					if(t->second)
					{
						GenerateCode(t->second, indent);
					}
					}
				 return;
				 
				case STATEMENT:
					if(!hasErrored){
					indentCode(indent);
					GenerateCode(t->first, indent);
					}
				 return;
				 
				case ASSIGNMENT_STATEMENT:
					if(!hasErrored){
				//create_node($3, ASSIGNMENT_STATEMENT, $1, NULL, NULL);
					strcpy(currentStatement, "ASSIGNMENT_STATEMENT");
					GenerateCode(t->first, indent);					
					printf(" = ");
					GenerateCode(t->second, indent);
					printf(";\n");
					}
				 return;
				 
				case IF_STATEMENT:	
					if(!hasErrored){
					strcpy(currentStatement, "IF_STATEMENT");
					printf("if (");
					//$$ = create_node(NOTHING, IF_STATEMENT, $2, $4, NULL);
					GenerateCode(t->first, indent);
				printf(")\n");
				indentCode(indent);
				printf("{\n");
				indent += INDENTOFFSET;
					GenerateCode(t->second, indent);
				indent -= INDENTOFFSET;
				indentCode(indent);
				printf("}\n");
					//$$ = create_node(NOTHING, IF_STATEMENT, $2, $4, $6);
					if(t->third){
						printf("else\n{\n");
						GenerateCode(t->third, indent);
						printf("}\n");						
					}
					}
				 return;
				
				case DO_STATEMENT:	
					if(!hasErrored){
					strcpy(currentStatement, "DO_STATEMENT");
					printf("do {\n");
					indent += INDENTOFFSET;
					GenerateCode(t->first, indent);
					indent += INDENTOFFSET;
					printf("}while(");
					GenerateCode(t->second, indent);
					printf(");\n");
					}
				 return;
				 
				case WHILE_STATEMENT:
					if(!hasErrored){
					strcpy(currentStatement, "WHILE_STATEMENT");
					indentCode(indent);
					printf("while(");
					GenerateCode(t->first, indent);
					printf(")\n{\n");
					indent += INDENTOFFSET;
					GenerateCode(t->second, indent);
					indent -= INDENTOFFSET;
					printf("}\n");
					}
				 return;
				 
				case FOR_STATEMENT:		
					if(!hasErrored){
					// Code to print header of the for loop.
					//TO = t->second->third
					//BY = t->second->second
					//IS = t->second->first
					returnTerminal(t->second->first,indent);
					int forVar = forVariable;
					returnTerminal(t->second->third,indent);
					int forCond = forCondition;
					returnTerminal(t->second->second, indent);
					int forInc = forIncrement;
					int loops = forCond - forVar;
					
					// Loop unwinding, check if difference between TO and IS, if one simply print statement.
					if(loops == 1)
					{
						if(forInc > 0)
						{
							printf("/* For loop unwinding */\n");
							indent += INDENTOFFSET;
							GenerateCode(t->third, indent);
							indent -= INDENTOFFSET;
						}
						else{
							yyerror("For loop increment prevents successful looping, check your iteration.");
							hasErrored = TRUE;
						}
					}
					else if(loops == -1){
						if(forInc < 0)
						{
							printf("/* For loop unwinding */\n");
							indent += INDENTOFFSET;
							GenerateCode(t->third, indent);
							indent -= INDENTOFFSET;
						}
					else{
							yyerror("For loop increment prevents successful looping, check your iteration.");
							hasErrored = TRUE;
						}
					}
					//If no loop unwinding
					else{
					indent+=INDENTOFFSET;
					printf("if (");
					GenerateCode(t->second->second, indent);
					printf(" > 0)\n{\n");
					indentCode(indent);
					printf("for(");
						GenerateCode(t->first, indent);
						printf(" = ");
						GenerateCode(t->second->first, indent);
						printf("; ");
						GenerateCode(t->first, indent);
						printf(" <= ");
						GenerateCode(t->second->third, indent);
						printf("; ");
						GenerateCode(t->first, indent);
							printf(" += ");
							GenerateCode(t->second->second, indent);
						printf(")\n");
						
						// Genereate loop body
						printf("  {\n");
						indent += INDENTOFFSET;
						GenerateCode(t->third, indent);
						indent -= INDENTOFFSET;
						printf("  }\n}\n");
						
						printf("else \n {\n");
						//second for statement
						indentCode(indent);
						printf("for(");
						GenerateCode(t->first, indent);
						printf(" = ");
						GenerateCode(t->second->first, indent);
						printf("; ");
						GenerateCode(t->first, indent);
						printf(" >= ");
						GenerateCode(t->second->third, indent);
						printf("; ");
						GenerateCode(t->first, indent);
						printf(" += ");
						GenerateCode(t->second->second, indent);
					    printf(")\n");							
						// Genereate loop body
						printf("  {\n");
						indent += INDENTOFFSET;
						GenerateCode(t->third, indent);
						indent -= INDENTOFFSET;
						printf("  }\n}\n");
						indent-=INDENTOFFSET;
					}
					}
				 return;
				 
				case WRITE_STATEMENT:
					if(!hasErrored){
					strcpy(currentStatement, "WRITE_STATEMENT");
					//$$ = create_node(NOTHING, WRITE_STATEMENT, $3, NULL, NULL);
					if(t->first){
						isPrinting = TRUE;
						GenerateCode(t->first, indent);
						isPrinting=FALSE;
					}		
					}
				 return;
				 
				case READ_STATEMENT:
					if(!hasErrored){
					strcpy(currentStatement, "READ_STATEMENT");
					printf("scanf(");
					isPrinting = TRUE;
					GenerateCode(t->first, indent);
					isPrinting=FALSE;
					printf("\n");
					}
				 return;
				 
				case OUTPUT_LIST:
					if(!hasErrored){
					GenerateCode(t->first, indent);
					if(t->second){
						GenerateCode(t->second, indent);
					}
					}
				 return;
				case ID_VALUE:
					if(!hasErrored){
					if(isPrinting){
						printf("printf(");
					}
					GenerateCode(t->first, indent);
					}
					return;
				case CONDITIONAL:
				if(!hasErrored){
					GenerateCode(t->first, indent);
				}
				 return;
				 
				case CONDITION:
					if(!hasErrored){
					printf("(");
					GenerateCode(t->first, indent);
					GenerateCode(t->second, indent);
					GenerateCode(t->third, indent);
					printf(")");
					}
				 return;
				
				case NOT_CONDITIONAL:
					if(!hasErrored){
					printf("!");
					GenerateCode(t->first, indent);
					}
					return;
					
				case AND_CONDITIONAL:
					if(!hasErrored){
					GenerateCode(t->first, indent);
					printf(" && ");
					GenerateCode(t->second, indent);
					}
					return;
					
				case OR_CONDITIONAL:
					if(!hasErrored){
					GenerateCode(t->first, indent);
					printf(" || ");
					GenerateCode(t->second, indent);
					}
					return;
				case EXPRESSION:	
					if(!hasErrored){
					GenerateCode(t->first, indent);
					}
				 return;
				 
				case TERM:	
					if(!hasErrored){
					GenerateCode(t->first, indent);
					}
				 return;
				case VALUE:	
					if(!hasErrored){
					GenerateCode(t->first, indent);	
					}					
				 return;
				case BRA_VALUE:
				if(!hasErrored){
				if(isPrinting){
				   printf("printf(\"%%d\", (");
				  }
				else{
				   printf("(");		
				  }
				   
					GenerateCode(t->first, indent);
					printf(")");
				if(isPrinting)	
					printf(");\n");	
				}				
					return;
				 case CHARACTER:
				 if(!hasErrored){
					printf("char ");
				 }
				 return;
				case CONSTANT:
				if(!hasErrored){
					GenerateCode(t->first, indent);
				}
				 return;
				 
				case CHAR_CONSTANT:
				if(!hasErrored){
				if(isPrinting){
					printf("printf(\"%%c\", ");
				}
				printf("%s", symTab[t->item]->identifier);
				if(isPrinting)
					printf(");\n");
				}
				return;
				
				case NUMBER:
				if(!hasErrored){
				forCondition = t->item;
				forVariable = t->item;
				forIncrement = t->item;
				if(!preventPrint)
					printf("%d", t->item);
				if(preventPrint)
					return;
				}
				return;
				 
				case NEGATIVE_INT:
				if(!hasErrored){
				forCondition = -t->item;
				forVariable = -t->item;
				forIncrement = -t->item;
				if(!preventPrint)
					printf("-%d", t->item);
				if(preventPrint)
					return;
				}
				return;
				
				 case REAL_CONSTANT:
					if(!hasErrored){
					printf(symTab[t->item]->identifier);
					}
				return;
				 
				case NEGATIVE_REAL:
					if(!hasErrored){
					printf("-");
					printf(symTab[t->item]->identifier);
					}					
				return;
				case EQUAL_COMPARATOR:
					if(!hasErrored){
					printf(" == ");
					}
					return;
					
				case NOTEQUAL_COMPARATOR:
					if(!hasErrored){
					printf(" != ");
					}
					return;
					
				case GREATERTHAN_COMPARATOR:
					if(!hasErrored){
					printf(" > ");
					}
					return;
					
				case LESSTHAN_COMPARATOR:
					if(!hasErrored){
					printf(" < ");
					}
					return;
					
				case GREATERTHANOREQUAL_COMPARATOR:
					if(!hasErrored){
					printf(" >= ");
					}
					return;
					
				case LESSTHANOREQUAL_COMPARATOR:
					if(!hasErrored){
					printf(" <= ");
					}
					return;
					
				case PLUS_EXPRESSION:
					if(!hasErrored){
					GenerateCode(t->first, indent);
					printf(" + ");
					GenerateCode(t->second, indent);
					}
					return;
					
				case MINUS_EXPRESSION:
					if(!hasErrored){
					GenerateCode(t->first, indent);
					printf(" - ");
					GenerateCode(t->second, indent);
					}
					return;
					
				case TIMES_TERM:
					if(!hasErrored){
				if(!preventPrint){
					GenerateCode(t->first, indent);
					printf(" * ");
					GenerateCode(t->second, indent);
					}
					}
					return;
					
				case DIVIDE_TERM:
					if(!hasErrored){
					GenerateCode(t->first, indent);
					printf(" / ");
					GenerateCode(t->second, indent);
					}
					return;
					
			}
}


#include "lex.yy.c"
