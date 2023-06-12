# custom_shell
A custom shell is designed and deeloped written in C. The program is written in Linux 5.10 . The shell takes input from command line and fork() and execute() that. 
Inorder to undersatnd the command line input, Lex and Yacc have been used which are regex and parser generator. 

<b><h2><i>Lex</h2></i></b>: Multiple regex has been initialized based on the type of the input. for instance, for command such as ls, echo, expr , grep, etc a regex called word is generated. Fo options , arguments, pipe, IO, IOR separate regex are defined. The lex returns token based on the matched regex. <b> yylex() </b> is the backbone of the Lex program which is later called by yacc parser function. yylex() invoke the lexer and return tokens basied on the matched patterns. 

<b><i><h2>YACC</i></h2></b>: the parser generator uses bottom up parsing method. The grammers are designed and defined based on the parsing method. 
<b>yyparse()</b> is mainly responsible for parsing for a given input

Here is the diagram how lex and yacc interact with each other: 


<img width="497" alt="Screen Shot 2023-06-12 at 1 56 58 PM" src="https://github.com/hoquesumya/custom_shell/assets/65731158/147eadeb-d222-4b10-b192-40b38f2b485d">

<b><h2>Executor </h2></b>:
during parsing in yacc, a customized table of complex commands is generated. The table consists of simple commands and some modifiers such as <b>|</b>, <b>&& , > , >>, <, >& </b> etc. The executor will read the elements from the command table and execute them using fork() and exec(). To handle comlex commands such as <b><i>a|b|c|d >>output.txt </i></b>, io redirection method has been used by calling dup() and pipe() functions. 
  
<img width="726" alt="Screen Shot 2023-06-12 at 2 21 34 PM" src="https://github.com/hoquesumya/custom_shell/assets/65731158/fb5eca6b-a655-42d6-8f8f-97c0d07caedf">
  
  <h3><i>How to use the shell</i></h3>
  <li>
    cd bash
  </li>
  <li>
    make
    </li>
   <li>
    run ./shell
    </li>
   <li>
    insert the commands- such as ls -al | grep "shell"
    </li>
   <li>
    after the output, type another command
  </li>
  <li>
    To terminate, press ctrl+C 
  </li>
  
  
