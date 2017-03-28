Supporting Files for 08348 (Language and their Compilers) Laboratory and Assessed Coursework
--------------------------------------------------------------------------------------------
Inventory
---------

README.txt        -- This file
BNF.txt         -- A text file containing the BNF of the SPL language specification. 
spl.l           -- Flex lexical analyser for ACW submission.
spl.y           -- Bison parser for ACW submission.
spl.c           -- C main program used in compiling the spl executable.	
results.txt     -- RunCompiler result set. 		
				  
Optimisations
-------------
	For loop unwinding : 
		- Line 724-751 spl.y
		- If constant values and for loop has a single iteration, print statement on its own without for loop header. 
		- Visible in C code output as /* For loop unwinding */ if match.
	Assumption - If increment/decrement causes an infinite loop / doesn't match IS/TO, forces error/program halt with an output.

Flags
------
spl.l |	
		-DPRINT 
			- Print tokens to console.
		Default
			- Push tokens to bison.
spl.y |
		-DDEBUG (gcc -o spl.exe spl.tab.c spl.c -lfl -DDEBUG)
			- Print parse tree to console
		Default 
			- Generate Code


Assumptions
----------
		- Program start and end identifiers must match.
		- Using the program start/end identifier in the program returns an error.
		
	



