/**
    @file       Cross.c
    @brief      Raspi Cross-compilation test

    @author     Oleg Kertanov <okertanov@gmail.com>
    @date       July 2012
    @copyright  Copyright (C) 2012 Oleg Kertanov <okertanov@gmail.com>
    @license    BSD
    @see LICENSE file
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/utsname.h>

/**
    @fn main()
    @brief

    @param[in] argc - argument count
    @param[in] argv - argument vector

    @return EXIT_SUCCESS, EXIT_FAILURE
*/
int main(int argc, char** argv)
{
    const char* exec_name = strdup(argv[0]);
    const char* uname_fmt = "\n%s:\n\t%s\n\t\t%s : %s : %s : %s : %s : %s\n";
    struct utsname uts = {0};

    int rc = uname(&uts);

    if ( rc == 0 && exec_name && uname_fmt )
    {
        fprintf( stdout,
                 uname_fmt, exec_name, "System info:",
                 uts.sysname,
                 uts.nodename,
                 uts.release,
                 uts.version,
                 uts.machine );
    }
    else
    {
        perror("uname() failed for this system.");
    }

    if ( exec_name )
    {
        free(exec_name);
    }

    return ( rc == 0 ? EXIT_SUCCESS : EXIT_FAILURE );
}

