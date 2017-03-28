Languages-and-Compilers" 

A piece of coursework written for a Languages and Compilers module in third year BSc Computer Science. The BNF displays the grammar of a 'made up' language given to us by the module professor. The file spl.l provides a Lexical Analyser that will loop through a code sample of this language and register each 'word' of the code as a Token that is added to a list. This list, along with the grammar in the BNF file is then used by spl.y, a Parser file. In here, the list of tokens or words is split into a binary tree depending on the grammar used. At the base of this binary tree, the 'terminals', ie the words can be found(identifiers, values), whilst the 'nonterminals' (for statement, while statement) are common across both languages and so the language can essentially be translated. 

Through isolation of important terminals, and merely carrying these common features of the program over and manually translating them, the output of the process is a fully compiling ANSI C file which outputs to a console window.
