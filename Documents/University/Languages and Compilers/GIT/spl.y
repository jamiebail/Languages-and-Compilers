%{

#include <stdio.h>
#include <stdlib.h>


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
						 CONDITIONAL, CONDITION, COMPARATOR, EXPRESSION, TERM, VALUE, CONSTANT, NUMBER_CONSTANT, REAL, NEGATIVE_INT, NEGATIVE_REAL
};  
						 

char *NodeName[] = {
						"PROGRAM", "BLOCK", "DECLARATION_BLOCK", "IDENTIFIERS", "STATEMENT_LIST", "STATEMENT", "ASSIGNMENT_STATEMENT",
						 "IF_STATEMENT", "DO_STATEMENT", "WHILE_STATEMENT", "FOR_STATEMENT", "WRITE_STATEMENT", "READ_STATEMENT", "OUTPUT_LIST",
						 "CONDITIONAL", "CONDITION", "COMPARATOR", "EXPRESSION", "TERM", "VALUE", "CONSTANT", "NUMBER_CONSTANT", "REAL", "NEGATIVE_INT", "NEGATIVE_REAL" 
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
void WriteCode(TERNARY_TREE);
void PrintTree(TERNARY_TREE);

/* ------------- symbol table definition --------------------------- */

struct symTabNode {
    char identifier[IDLENGTH];
};

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
	   BRA KET DECLARATIONS INTEGER CODE OF TYPE PLUS MINUS TIMES DIVIDE CHARACTER
	   LESSTHAN GREATERTHAN EQUALS NOTEQUAL LESSTHANOREQUAL GREATERTHANOREQUAL DIGITS DIGIT

%token<iVal> identifier integer real char_const

%type<tVal> program block declaration_block identifiers statement_list statement assignment_statement
			if_statement do_statement while_statement for_statement write_statement read_statement output_list
			conditional condition comparator expression term value constant number_constant

%%

program : identifier COLON block ENDP identifier FULLSTOP
			{
				TERNARY_TREE ParseTree;
				ParseTree = create_node($1, PROGRAM, $3, NULL, NULL);
				PrintTree(ParseTree);
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

declaration_block : identifiers OF TYPE constant SEMICOLON 
			{
				$$ = create_node(NOTHING, DECLARATION_BLOCK, $1, $4, NULL);
			}
		| identifiers OF TYPE constant SEMICOLON declaration_block
			{
				$$ = create_node(NOTHING, DECLARATION_BLOCK, $1, $4, $6);
			}
			;

identifiers : identifier 
			{
				$$ = create_node($1, IDENTIFIERS, NULL, NULL, NULL);
			}
		| identifier COMMA identifiers
			{
				$$ = create_node($1, IDENTIFIERS, $3, NULL, NULL);
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
			

assignment_statement : expression ASSIGNMENT identifier
			{
				$$ = create_node($3, ASSIGNMENT, $1, NULL, NULL);
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
 
for_statement : FOR identifier IS expression BY expression TO expression DO statement_list ENDFOR
			{
				$$ = create_node($2, FOR_STATEMENT, create_node(NOTHING, FOR_STATEMENT, $4, $6, $8), $10, NULL);
			}
			;
 
write_statement : WRITE BRA output_list KET
			{
				$$ = create_node(NOTHING, WRITE_STATEMENT, $3, NULL, NULL);
			}
			;
 
read_statement : READ BRA identifier KET
			{
				$$ = create_node($3, READ_STATEMENT, NULL, NULL, NULL);
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
				$$ = create_node(NOT, CONDITIONAL, $2, NULL, NULL);
			}
		| condition AND conditional
			{
				$$ = create_node(AND, CONDITIONAL, $1, $3, NULL);
			}
		| condition OR conditional 
			{
				$$ = create_node(OR, CONDITIONAL, $1, $3, NULL);
			}
			;
 
 
condition : expression comparator expression
			{
				$$ = create_node(NOTHING, CONDITION, $1, $2, $3);
			}
			;
 
comparator :  EQUALS
			{
				$$ = create_node(EQUALS, COMPARATOR, NULL, NULL, NULL);
			}
		| NOTEQUAL
			{
				$$ = create_node(NOTEQUAL, COMPARATOR, NULL, NULL, NULL);
			}
		| GREATERTHAN
			{
				$$ = create_node(GREATERTHAN, COMPARATOR, NULL, NULL, NULL);
			}
		| LESSTHAN
			{
				$$ = create_node(LESSTHAN, COMPARATOR, NULL, NULL, NULL);
			}
		| GREATERTHANOREQUAL
			{
				$$ = create_node(GREATERTHANOREQUAL, COMPARATOR, NULL, NULL, NULL);
			}
		| LESSTHANOREQUAL 
			{
				$$ = create_node(LESSTHANOREQUAL, COMPARATOR, NULL, NULL, NULL);
			}
			;
 
expression :  term PLUS expression
			{
				$$ = create_node(PLUS, EXPRESSION, $1, $3, NULL);			
			}
		| term MINUS expression
			{
				$$ = create_node(MINUS, EXPRESSION, $1, $3, NULL);	
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
				$$ = create_node(TIMES, TERM, $1, $3, NULL);
			}
		| value DIVIDE term 
			{
				$$ = create_node(DIVIDE, TERM, $1, $3, NULL);
			}
			;
 
value : identifier
			{
				$$ = create_node($1, VALUE, NULL, NULL, NULL);
			}
		| constant
			{
				$$ = create_node(NOTHING, VALUE, $1, NULL, NULL);
			}
		| BRA expression KET
			{
				$$ = create_node(NOTHING, VALUE, $2, NULL, NULL);		
			}
			;

constant : number_constant
			{
				$$ = create_node(NOTHING, CONSTANT, $1, NULL, NULL);		
			}
		| char_const
			{
				$$ = create_node($1, CONSTANT, NULL, NULL, NULL);		
			}
			;
  
number_constant : integer
			{
				$$ = create_node($1, NUMBER_CONSTANT, NULL, NULL, NULL);		
			}
		| MINUS integer
			{
				$$ = create_node($2, NEGATIVE_INT, NULL, NULL, NULL);		
			}
		| real
			{
				$$ = create_node($1, REAL, NULL, NULL, NULL);		
			}
		| MINUS real
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

void PrintTree(TERNARY_TREE t)
{
   if (t == NULL) return;
   if (t->item != NOTHING)
   {  
		printf("Item: %d", t->item);
   }
   if (t->nodeIdentifier < 0 || t->nodeIdentifier > sizeof(NodeName))
   {
		printf("Unknown nodeIdentifier: %d\n",t->nodeIdentifier);
   }
   else
   {
		switch(t->nodeIdentifier)
		{
				
		}
   }
   PrintTree(t->first);
   PrintTree(t->second);
   PrintTree(t->third);
}

void WriteCode(TERNARY_TREE t)
{
	return;
}


#include "lex.yy.c"
