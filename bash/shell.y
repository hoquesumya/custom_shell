%{

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <sys/wait.h>
#include <sys/types.h>
#include <unistd.h>
#include <signal.h>
#include <stdbool.h>
#include <fcntl.h>
const int MAXLINE = 100;


struct basicCommand {
	char *command;
	char** options;
	char **options2;
	char **arg;
	int num_of_arguments;
	int num_of_options;
	int num_of_options2;
 };

struct complexCommand {

	struct basicCommand** basic;
	int num_of_basic_command;
	char *pipe;
	char* input_file;
	char* output_file;
	bool input;
	bool output;
        bool output_ap;
};

struct complexCommand *command = NULL;

void insert_arguments(char* );
void init_commandTable();
void insert_basic(struct basicCommand* ba);
void insert_options(char* options); 
void insert_options2(char* options2);
void execute();
void strip_space(char *temp);
void insert_command (char* comm);
void prompt(char* path);
//int yylex(void);
void yy_scan_string(const char* str);

%}
%union {
  char* stringValue;
  // Add other data types as needed
}

%token <stringValue>WORD 
%token <stringValue>OPTION 
%token <stringValue>OPTION2 
%token <stringValue>IOR 
%token <stringValue>IO 
%token <stringValue>AND 
%token <stringValue>lAnd 
%token <stringValue>ADD 
%token <stringValue>SUB 
%token <stringValue>COMMENT 
%token <stringValue>PIPE 
%token NEWLINE 

%{
 void yyerror(char *);
 int yylex(void);
 int sym[26];
%}

%%

q00 : NEWLINE {printf("newline1\n");return 0;} 
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
arg: WORD {         	insert_arguments($1);
          }
    | SUB {insert_arguments($1);} 
   ;
io_modifier: IO {printf ("io %s\n", $1); 
	         strip_space($1);
		 if (strcmp($1 , "<") == 0)
		 	command->input = true;
		 else if (strcmp($1 , ">>") == 0) 
		 	command->output_ap = true;
			
	       	else if (strcmp($1 , ">") == 0)
		 	command->output = true;

              } 
	   ;
io_descr: IOR {printf ("ior %s\n", $1);}
	;
background: AND
	  ;
file: WORD { 
         strip_space($1);
    	if (command->input)
	       command->input_file = $1;
	    else if (command->output_ap)
	       command->output_file = $1;
	    else if (command->output)
	       command->output_file = $1;
          } 
      ;

com : COMMENT
    | /*eplison*/
    ;
option : OPTION {insert_options($1);}
       | OPTION2 {insert_options2($1); }      
	;

cmd : WORD{ 
       insert_command($1);} 
    ;
%%
void strip_space(char *temp) {

	char *temp1 = temp;
 	 do {
        	while (*temp1 == ' ') {
            	++temp1;
         	}
   	 } while (*temp++ = *temp1++);
}

void prompt(char* path){
	char cwd[1024];
        getcwd(cwd, sizeof(cwd));
	char *home = getenv("HOME");
        strcpy(path, cwd);
        if (home != NULL) {
		char *token;

		token = strstr(cwd, home);
		if (token) {
			char pa [1024];
			pa[0] = '~';
			strcpy(pa+1, token+strlen(home));
			//printf("%s\n", pa);
			strcpy(path, pa);
	       	}
	}	
}
/*needs to be examine*/
void execute (){
        
	if (command->num_of_basic_command !=0) {
		pid_t	pid;
		int	status;
		int tmpin = dup(0);
		int tmpout = dup(1);
		int tmperr = dup(2);
		int fdin, fdout;
                //handling input redirection a < hello.txt//
		if (command->input_file) {
			fdin = open (command->input_file, O_RDONLY);
		}
		else {
			fdin = dup(tmpin);

		}

		for (int x = 0; x < command->num_of_basic_command; x++) {
			dup2(fdin, 0);// redirecting the input to stdinput//
			             //will read from fdin pointed file//
			close(fdin);

        		int num_op = command->basic[x]->num_of_options;
			int num_op2 = command->basic[x]->num_of_options2;
			int num_arg = command->basic[x]->num_of_arguments;
			 
			int j = 1; 
			char **argv = malloc((num_op + num_op2 + num_arg + 2) *sizeof(char*));

			argv[0] = command->basic[x]->command;
			for(int i = 0; i < num_op; i++) {
				argv[j] =  command->basic[x]->options[i]; 
				j++;
        		}
			for(int i = 0; i < num_op2; i++) {
				argv[j] =  command->basic[x]->options2[i]; 
				j++;
        		}

			for(int i = 0; i < num_arg; i++) {
				argv[j] =  command->basic[x]->arg[i]; 
				j++;
        		}

        
			argv[j] = NULL;
			/*
			 >> or > handling condition using dup and redirection

			*/
			if ( x == command->num_of_basic_command-1) {
				if(command->output_ap && command->output_file) {
					fdout = open(command->output_file,  O_RDWR | O_APPEND |O_CREAT, 0640);
					printf("hey out %s\n", command->output_file);
				}
				else if (command->output && command->output_file) {
					fdout = open(command->output_file,  O_RDWR | O_CREAT | O_TRUNC, 0644);
					
                                }
				else {
					fdout = dup(tmpout);
				
				}
				
                        }
			else {
			     /*handling pipe*/
				int fdpipe[2];
				pipe(fdpipe);
				fdout = fdpipe[1];
				fdin = fdpipe[0];
			}
                        	dup2(fdout,1);
				close(fdout);

		        	
			if ((pid = fork()) < 0) {
				fprintf(stderr,"error\n");
			} else if (pid == 0) {		/* child */
				execvp(argv[0],argv);
                		perror("execvp");
				fprintf(stderr, "couldn't execute: %s\n", argv[0]);
					exit(127);
			}
		/* parent */
		     	
			if ((pid = waitpid(pid, &status, 0)) < 0)
				fprintf(stderr, "waitpid error\n");
        		free(argv); 
		}
	
		dup2(tmpin, 0);
		dup2(tmpout, 1);
		close (tmpin);
		close (tmpout);
		close (tmperr);

	}
}
void insert_command(char *comm) {
       
        strip_space(comm);
//	printf("len %d\n", strlen(comm));
	command->basic[command->num_of_basic_command]->command = comm;
    	char * com = command->basic[command->num_of_basic_command]->command;
    	command->num_of_basic_command++;
        printf("Token value: %s\n", com);

}

void insert_basic(struct basicCommand* ba){

}
void insert_arguments(char *args) {
	int num_arg = command->basic[command->num_of_basic_command-1]->num_of_arguments;
     	strip_space(args);
	
	char *token;
	char arg[4096];
	token = strstr(args, "~");
	if(token) {
		char *home = getenv("HOME");
		strncpy(arg, home, strlen(home));
		strcpy(arg+strlen(home), token+1);
		args = arg;
        }	  
	command->basic[command->num_of_basic_command-1]->arg[num_arg] = args; 
      	command->basic[command->num_of_basic_command-1]->num_of_arguments++;

}
void insert_options(char* options) {
	int num_op = command->basic[command->num_of_basic_command-1]->num_of_options;
      	strip_space(options);
  	command->basic[command->num_of_basic_command-1]->options[num_op] = options; 
    	command->basic[command->num_of_basic_command-1]->num_of_options++;

}
void insert_options2(char* options2){
	int num_op = command->basic[command->num_of_basic_command - 1 ]->num_of_options2;
     	strip_space(options2);
   	command->basic[command->num_of_basic_command-1]->options2[num_op] = options2; 
      	command->basic[command->num_of_basic_command-1]->num_of_options2++;
};
void clear (){

	for (int i = 0; i< 50; i++) {
		
		command->basic[i]->command = NULL;
                free(command->basic[i]->options);
		free(command->basic[i]->options2);
		free(command->basic[i]->arg);
		command->basic[i]->num_of_arguments = 0;
		command->basic[i]->num_of_options = 0;
		command->basic[i]->num_of_options2 = 0;
	}
	for (int i = 0; i< 50; i++) {
		free(command->basic[i]);
	}
	free(command->basic);
  	command->num_of_basic_command = 0;
  	command->pipe = NULL;
  	command->output_file = NULL;
  	command->input_file = NULL;
	free(command);


}

void init_commandTable() {
  
  command = malloc(sizeof(struct complexCommand));
  if (command) {
  	command->basic = malloc(50 * sizeof (struct basicCommand *));
  	command->num_of_basic_command = 0;
  	command->pipe = NULL;
  	command->output_file = NULL;
  	command->input_file = NULL;
	command->input = false;
	command->output =false;
	command->output_ap =false;


	if(command->basic) {
	       
	       //printf("pritning\n"); 
               for (int i = 0; i< 50; i++) {
			//printf("pritning\n");

			command->basic[i] = malloc(sizeof(struct basicCommand));
		}

		for (int i = 0; i< 50; i++) {
			//printf("pritning\n");

			command->basic[i]->command = NULL;
                        //printf("pritning\n");

			command->basic[i]->options = malloc(50 * sizeof(char*));
			command->basic[i]->options2 = malloc(50 * sizeof(char*));

			command->basic[i]->arg = malloc(50 * sizeof(char*));
			command->basic[i]->num_of_arguments = 0;
			command->basic[i]->num_of_options = 0;
			command->basic[i]->num_of_options2 = 0;
		}
       	}
   }
}
extern int yy_flex_debug;
int main(int argc, char **argv)
{
	char path[1024]; 	
	prompt(path);
	printf("%s$ ", path);
	char	buf[MAXLINE];	
 

        while(fgets(buf, MAXLINE, stdin) != NULL) {

        	init_commandTable();
	        yy_scan_string(buf);
		int n = yyparse();
		if (n==0) {
   			                      	
	        	execute();

       			clear();
		//yy_delete_buffer(YY_CURRENT_BUFFER); needs to be fixed shows error//
			printf("%s $",path); 
		}
		else
			break;
    }
}

void  yyerror(char *s)
{
  fprintf(stderr, "error: %s\n", s);
} 
