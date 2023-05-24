#include <stdio.h>
#include <sys/wait.h>
#include <sys/types.h>
#include <unistd.h>
#include <string.h>
#include <stdlib.h>
#include <signal.h>

void signal_handler(int signum) 
{
	printf("signal recieved\n");

}
int
main(void)
{
	const int MAXLINE = 100;
	char cwd[1024];
        getcwd(cwd, sizeof(cwd));
	char *home = getenv("HOME");

        char path[1024]; 
	char	buf[MAXLINE];	/* from apue.h */
	pid_t	pid;
	int	status;
	struct sigaction sa;
    	sa.sa_handler = SIG_IGN;
    	sigemptyset(&sa.sa_mask);
        sa.sa_flags = 0;

    // Ignore SIGINT (Ctrl+C)
    	if (sigaction(SIGINT, &sa, NULL) == -1) {
       		 perror("sigaction");
       		 return 1;
    	}

    // Ignore EOF (Ctrl+D)
    	if (sigaction(SIGQUIT, &sa, NULL) == -1) {
        	perror("sigaction");
        	return 1;
    	}


	strcpy(path, cwd);
        if (home != NULL) {
		char *token;

		token = strstr(cwd, home);
		if (token) {
			char pa [1024];
			pa[0] = '~';
			strcpy(pa+1, token+strlen(home));
			printf("%s\n", pa);
			strcpy(path, pa);
	       
		}
	}

	printf("%s $", path);	/* print prompt (printf requires %% to print %) */
start:
	while (fgets(buf, MAXLINE, stdin) != NULL) {
		if (buf[strlen(buf) - 1] == '\n')
			buf[strlen(buf) - 1] = 0; /* replace newline with null */
		printf("%s$ ", buf);		

		if(buf[0] == 0) {
                 	printf("%s$ ", path);
			continue;
		}

		if ((pid = fork()) < 0) {
			fprintf(stderr,"error\n");
		} else if (pid == 0) {		/* child */
			execlp(buf, buf, (char *)0);
			fprintf(stderr, "couldn't execute: %s\n", buf);
			exit(127);
		}

		/* parent */
		if ((pid = waitpid(pid, &status, 0)) < 0)
			fprintf(stderr, "waitpid error\n");
		printf("%s $ ", path);
	}
	if (buf[0]== EOF)
		goto start;
	exit(0);
}
