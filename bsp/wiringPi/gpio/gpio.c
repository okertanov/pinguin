/*
 * wiringPi:
 *	Arduino compatable (ish) Wiring library for the Raspberry Pi
 *	Copyright (c) 2012 Gordon Henderson
 *
 *	Thanks to code samples from Gert Jan van Loo and the
 *	BCM2835 ARM Peripherals manual, however it's missing
 *	the clock section /grr/mutter/
 ***********************************************************************
 * This file is part of wiringPi:
 *	https://projects.drogon.net/raspberry-pi/wiringpi/
 *
 *    wiringPi is free software: you can redistribute it and/or modify
 *    it under the terms of the GNU General Public License as published by
 *    the Free Software Foundation, either version 3 of the License, or
 *    (at your option) any later version.
 *
 *    wiringPi is distributed in the hope that it will be useful,
 *    but WITHOUT ANY WARRANTY; without even the implied warranty of
 *    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *    GNU General Public License for more details.
 *
 *    You should have received a copy of the GNU General Public License
 *    along with wiringPi.  If not, see <http://www.gnu.org/licenses/>.
 ***********************************************************************
 */

/*
 * gpio.c:
 *	Command-line program to fiddle with the GPIO pins on the
 *	Raspberry Pi
 */

#include <wiringPi.h>

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>
#include <unistd.h>
#include <sys/types.h>

#ifndef TRUE
#define	TRUE (1==1)
#define	FALSE (1==2)
#endif


static char *usage = "Usage: gpio [-g] <read/write/pwm/mode> ..." ;

static int gpioMode = FALSE ;

/*
 * pinCheck:
 *	Just to be safe
 *********************************************************************************
 */

static int validGpioPins [] =
{
//  0  1  2  3  4  5  6  7  8  9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25
    1, 1, 0, 0, 1, 0, 0, 1, 1, 1, 1, 1, 0, 0, 1, 1, 0, 1, 1, 0, 0, 1, 1, 1, 1, 1
} ;

static void pinCheck (int pin)
{
  if (gpioMode)
  {
    if ((pin < 0) || (pin > 25))
    {
      fprintf (stderr, "GPIO Pin number %d out of range\n", pin) ;
      exit (1) ;
    }
    if (validGpioPins [pin] == 0)
    {
      fprintf (stderr, "Not a usable GPIO Pin: %d \n", pin) ;
      exit (1) ;
    }

  }
  else
  {
    if ((pin < 0) || (pin > NUM_PINS))
    {
      fprintf (stderr, "Pin number out of range\n") ;
      exit (1) ;
    }
  }
}


/*
 * doMode:
 *	gpio mode pin mode ...
 *********************************************************************************
 */

void doMode (int argc, char *argv [])
{
  int pin ;
  char *mode ;

  if (argc != 4)
  {
    fprintf (stderr, "Usage: %s mode pin mode\n", argv [0]) ;
    exit (1) ;
  }

  pin = atoi (argv [2]) ;
  pinCheck (pin) ;

  mode = argv [3] ;

  /**/ if (strcasecmp (mode, "in")   == 0)
    pinMode (pin, INPUT) ;
  else if (strcasecmp (mode, "out")  == 0)
    pinMode (pin, OUTPUT) ;
  else if (strcasecmp (mode, "pwm")  == 0)
    pinMode (pin, PWM_OUTPUT) ;
  else if (strcasecmp (mode, "up")   == 0)
    pullUpDnControl (pin, PUD_UP) ;
  else if (strcasecmp (mode, "down") == 0)
    pullUpDnControl (pin, PUD_DOWN) ;
  else if (strcasecmp (mode, "tri") == 0)
    pullUpDnControl (pin, PUD_OFF) ;
  else
  {
    fprintf (stderr, "%s: Invalid mode: %s. Should be in/out/pwm/up/down/tri\n", argv [1], mode) ;
    exit (1) ;
  }
}

/*
 * doWrite:
 *	gpio write pin value
 *********************************************************************************
 */

void doWrite (int argc, char *argv [])
{
  int pin, val ;

  if (argc != 4)
  {
    fprintf (stderr, "Usage: %s write pin value\n", argv [0]) ;
    exit (1) ;
  }

  pin = atoi (argv [2]) ;
  pinCheck (pin) ;

  val = atoi (argv [3]) ;

  /**/ if (val == 0)
    digitalWrite (pin, LOW) ;
  else
    digitalWrite (pin, HIGH) ;
}


/*
 * doRead:
 *	Read a pin and return the value
 *********************************************************************************
 */

void doRead (int argc, char *argv []) 
{
  int pin, val ;

  if (argc != 3)
  {
    fprintf (stderr, "Usage: %s read pin\n", argv [0]) ;
    exit (1) ;
  }

  pin = atoi (argv [2]) ;
  pinCheck (pin) ;

  val = digitalRead (pin) ;

  printf ("%s\n", val == 0 ? "0" : "1") ;
}


/*
 * doPwm:
 *	Output a PWM value on a pin
 *********************************************************************************
 */

void doPwm (int argc, char *argv [])
{
  int pin, val ;

  if (argc != 4)
  {
    fprintf (stderr, "Usage: %s pwm <pin> <value>\n", argv [0]) ;
    exit (1) ;
  }

  pin = atoi (argv [2]) ;
  pinCheck (pin) ;

  val = atoi (argv [3]) ;

  pwmWrite (pin, val) ;
}


/*
 * main:
 *	Start here
 *********************************************************************************
 */

int main (int argc, char *argv [])
{
  int i ;

  if (argc == 1)
  {
    fprintf (stderr, "%s: %s\n", argv [0], usage) ;
    return 1 ;
  }

  if (geteuid () != 0)
  {
    fprintf (stderr, "%s: Must be root to run\n", argv [0]) ;
    return 1 ;
  }

  if (wiringPiSetup () == -1)
  {
    fprintf (stderr, "%s: Unable to initialise GPIO\n", argv [0]) ;
    exit (1) ;
  }

// Check for -g argument

  if (strcasecmp (argv [1], "-g") == 0)
  {
    wiringPiGpioMode (WPI_MODE_GPIO) ;
    for (i = 2 ; i < argc ; ++i)
      argv [i - 1] = argv [i] ;
    --argc ;
    gpioMode = TRUE ;
  }

  /**/ if (strcasecmp (argv [1], "write") == 0)
    doWrite (argc, argv) ;
  else if (strcasecmp (argv [1], "read" ) == 0)
    doRead  (argc, argv) ;
  else if (strcasecmp (argv [1], "mode" ) == 0)
    doMode  (argc, argv) ;
  else if (strcasecmp (argv [1], "pwm"  ) == 0)
    doPwm   (argc, argv) ;
  else
  {
    fprintf (stderr, "%s: Unknown command: %s. (read/write/pwm/mode expected)\n", argv [0], argv [1]) ;
    exit (1) ;
  }
  return 0 ;
}
