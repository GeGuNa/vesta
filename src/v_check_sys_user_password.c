/***************************************************************************/
/*  v_check_passwd.c                                                       */
/*                                                                         */
/*  This program compare user pasword from input with /etc/shadow          */
/*  To compile run:                                                        */
/*  "gcc -lcrypt v_check_sys_user_password.c -o v_check_sys_user_password" */
/*                                                                         */
/*  Thanks to: bogolt, richie and burus                                    */
/*                                                                         */
/***************************************************************************/

#define _XOPEN_SOURCE
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/types.h>
#include <pwd.h>
#include <shadow.h>
#include <time.h>
#include <string.h>


int main (int argc, char** argv) {
    // defining ip
    char *ip = "127.0.0.1";

    // checking argument list
    if (3 > argc) {
        printf("Error: bad args\n",argv[0]);
        printf("Usage: %s user password [ip]\n",argv[0]);
        exit(3);
    };

    // checking ip
    if (4 <= argc) {
      ip = (char*)malloc(strlen(argv[3]));
      strcpy(ip, argv[3]);
    }

    // formating current time
    time_t lt = time(NULL);
    struct tm* ptr = localtime(&lt);
    char str[280];
    strftime(str, 100, "%m-%d-%y %H:%m:%S ", ptr);

    // openning log file
    FILE* pFile = fopen ("/usr/local/vesta/log/auth.log","a+");
    if (NULL == pFile) {
        printf("Error: can not open file %s \n", argv[0]);
        exit(7);
    }

    // parsing user argument
    struct passwd* userinfo = getpwnam(argv[1]);
    if (NULL != userinfo) {
        struct spwd* passw = getspnam(userinfo->pw_name);
        if (NULL != passw) {
            char* cryptedPasswrd = (char*)crypt(argv[2], passw->sp_pwdp);
            if (strcmp(passw->sp_pwdp,crypt(argv[2],passw->sp_pwdp))==0) {
                // concatinating time with user and ip
                strcat(str, userinfo->pw_name);
                strcat(str, " ");
                strcat(str, ip);
                strcat(str, " successfully logged in \n");
                fputs (str,pFile);      // writing
                fclose (pFile);         // closing
                exit(EXIT_SUCCESS);     // exiting
            } else {
                // concatinating time with user string
                printf ("Error: password missmatch\n");
                strcat(str, userinfo->pw_name);
                strcat(str, " ");
                strcat(str, ip);
                strcat(str, " failed to login \n");
                fputs (str,pFile);      // writing
                fclose (pFile);         // closing
                exit(24);               // exiting
            };
        }
    } else {
        printf("Error: no such user\n",argv[1]);
        exit(21);
    };

    return EXIT_SUCCESS;
};
