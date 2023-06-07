%{

#include <stdio.h>
#include <string.h>

%}
%union {
  char* stringValue;
  // Add other data types as needed
}

%token <stringValue>WORD 
%token <stringValue>OPTION 
%token <stringValue>OPTION2 
%token <stringVaule>IOR 
%token <stringValue>IO 
%token <stringValue>AND 
%token <stringValue>lAnd 
%token <stringValue>ADD 
%token <stringValue>COMMENT 
%token <stringValue>PIPE 
%token NEWLINE 

%{
 void yyerror(char *);
 int yylex(void);
 int sym[26];
%}

%%

q00 : NEWLINE {printf("hello\n");return 0;} 
    | cmd q1 q0 
    | com {return 0;}
    |error
    ;
q0 :NEWLINE {printf ("newline\n");return 0;} 
   |com {return 0;}
   | PIPE q00
   | lAnd q00
    ;
q1 : option_list q2 
   | arg_list q3 
   | io_modifier q4
   | background q5
   | io_descr q3
   | /*epsilon*/
   ;
q2 : arg_list q3 
   | io_modifier q4
   | background q5
   |io_descr q3
   |/*epsilon*/
   ;
q3: io_modifier q4
   | background q5
   |io_descr q3
   |/*empty*/
   ;
q4: file q3
  ;
q5: /*empty*/
  ;
arg_list: arg
	|arg arg_list
	;
option_list: option
	   |option option_list
	   ;
arg: WORD { printf("arf value: %s\n", $1);}

   ;
io_modifier: IO {printf ("io %s\n", $1);} 
	   ;
io_descr: IOR
	;
background: AND {printf ("%s\n", $1);} 
	  ;
file: WORD;
com : COMMENT
    | /*eplison*/
    ;
option : OPTION {
  printf("option value: %s\n", $1);
}
       | OPTION2 {
  printf("option2 value: %s\n", $1);
}      ;

cmd : WORD {
  printf("Token value: %s\n", $1);
} 
    ;
%%

/*** command table after parsing**/
struct basicCommand {
	char *command;
	char** options;
	char **options2;
	char **arg;
	int num_of_arguments;
	int num_of_options;
	int num_of_options2;
        void (*insert_arguments)(char *args);
	void (*insert_options)(char* options);
	void (*insert_options2)(char* options2);
};
struct complexCommand {

	struct basicCommand** basic;
	int num_of_basic_command;
	char *pipe;
	char* input_file;
	char* output_file;
	void (*prompt)();
	void (*execute) ();
	void (*clear) ();
        void (*insert_basic)(struct basicCommand* ba);/*isnsert array of simple command*/
};
int main(int argc, char **argv)
{
  printf("enter the commnnd: ");
   int n = yyparse();
   if (n==0)
   	printf("parsing successful\n");
   else
   	printf("parsing not successful %d\n", n);
}

void  yyerror(char *s)
{
  fprintf(stderr, "error: %s\n", s);
} 
