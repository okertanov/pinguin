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

#if (defined unix)
#include <sys/utsname.h>
#define get_platform_signature()    get_platform_signature_posix()
#elif (defined _WIN32)
#include <windows.h>
#define get_platform_signature()    get_platform_signature_windows()
#if (!defined snprintf)
#define snprintf _snprintf
#endif
#endif

#if (defined unix)
/**
    @fn get_platform_signature_posix()
    @brief Query runtime for the UNIX/POSIX platform signature.

    @warning The caller is responsible for releasing returned buffer.

    @return platform signature string
*/
char* get_platform_signature_posix()
{
    const char const uname_fmt[] = "%s %s %s %s %s";
    struct utsname uts = { {0}, {0}, {0}, {0}, {0}, {0} };
    char* buff = NULL;
    const size_t buf_num = sizeof(uname_fmt) + sizeof(uts.sysname) + sizeof(uts.nodename) +
                           sizeof(uts.release) + sizeof(uts.version) + sizeof(uts.machine);

    int rc = uname(&uts);

    if ( rc == 0 )
    {
        buff = (char*) calloc(buf_num, sizeof(char));
        if ( buff && buf_num )
        {
            rc = snprintf( buff, buf_num * sizeof(char),
                           uname_fmt,
                           uts.sysname,
                           uts.nodename,
                           uts.release,
                           uts.version,
                           uts.machine );

            if ( rc > 0 )
            {
                return buff;
            }
            else
            {
                free(buff);
            }
        }
    }

    return NULL;
}
#endif

#if (defined _WIN32)
/**
    @fn get_platform_signature_windows()
    @brief Query runtime for the Windows platform signature.

    @warning The caller is responsible for releasing returned buffer.

    @return platform signature string
*/
char* get_platform_signature_windows()
{
    const char const version_fmt[] = "Windows %d.%d (%d)";
    char* buff = NULL;
    const size_t buf_num = sizeof(version_fmt) + sizeof(size_t) * 3;
    unsigned int major = 0, minor = 0, build = 0;

    unsigned long version = GetVersion();

    if ( version > 0 )
    {
        major = (unsigned int) LOBYTE( LOWORD(version) );
        minor = (unsigned int) HIBYTE( LOWORD(version) );
        if ( version < 0x80000000 )
        {
            build = (unsigned int) HIWORD( version );
        }

        buff = (char*) calloc(buf_num, sizeof(char));
        if ( buff && buf_num )
        {
            int rc = snprintf( buff, buf_num * sizeof(char),
                               version_fmt,
                               major, minor, build );

            if ( rc > 0 )
            {
                return buff;
            }
            else
            {
                free(buff);
            }
        }
    }

    return NULL;
}
#endif

/**
    @fn main()
    @brief Runtime entry point.

    @param[in] argc - argument count
    @param[in] argv - argument vector

    @return EXIT_SUCCESS, EXIT_FAILURE
*/
int main(int argc, char** argv)
{
    int rc = EXIT_SUCCESS;
    const char const out_fmt[] = "%s(%d) %s\n%s\n";
    const int exec_pcount = argc;
    char* const exec_name = strdup(argv[0]);
    char* const plat_info = get_platform_signature();

    if ( plat_info && strlen(plat_info) && exec_name )
    {
        fprintf( stdout,
                 out_fmt, exec_name, exec_pcount,
                 "System info:", plat_info );
    }
    else
    {
        perror("Fail to obtain system info.");
        rc = EXIT_FAILURE;
    }

    if ( plat_info )
    {
        free(plat_info);
    }

    if ( exec_name )
    {
        free(exec_name);
    }

    return (rc);
}

