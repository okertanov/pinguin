// Test program for bcm2835 library
// You can only expect this to run correctly
// as root on Raspberry Pi hardware
//
// Author: Mike McCauley (mikem@open.com.au)
// Copyright (C) 2011 Mike McCauley
// $Id: test.c,v 1.2 2012/06/26 01:40:50 mikem Exp $

#include <bcm2835.h>
#include <stdio.h>

int main(int argc, char **argv)
{
    if (geteuid() == 0)
    {
	if (!bcm2835_init())
	    return 1;
	if (!bcm2835_close())
	    return 1;
    }
    else
    {
	fprintf(stderr, "****You need to be root to properly run this test program\n");
    }
    return 0;
}
