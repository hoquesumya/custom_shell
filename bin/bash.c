#include <stdio.h>
#include <sys/wait.h>
#include <sys/types.h>
#include <unistd.h>
#include <string.h>
#include <stdlib.h>

int
main(void)
{
	const int MAXLINE = 100;
	char cwd[1024];
        getcwd(cwd, sizeof(cwd));
	char *home = getenv("HOME");
	printf("home : %s\n", home);
        char path[1024]; 
	char	buf[MAXLINE];	/* from apue.h */
	pid_t	pid;
	int	status;
	strcpy(path, cwd);
        if (home != NULL) {
		char *token;
		token = strstr(cwd, home);
		if (token)
			printf("token is %s\n", token);
	}

	printf("%s $", path);	/* print prompt (printf requires %% to print %) */
	while (fgets(buf, MAXLINE, stdin) != NULL) {
		if (buf[strlen(buf) - 1] == '\n')
			buf[strlen(buf) - 1] = 0; /* replace newline with null */

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
		printf("%s $ ", cwd);
	}
	exit(0);
}
