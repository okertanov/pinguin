#!/usr/bin/env python

# see http://elinux.org/RPi_Low-level_peripherals
# and http://pypi.python.org/pypi/RPi.GPIO

import RPi.GPIO as GPIO

# Set up the GPIO channels - one input and one output
GPIO.setup(11, GPIO.IN)
GPIO.setup(12, GPIO.OUT)

# Input from pin 11
input_value = GPIO.input(11)

# Output to pin 12
GPIO.output(12, True)

# The same script as above but using BCM GPIO 00..nn numbers
GPIO.setmode(GPIO.BCM)
GPIO.setup(17, GPIO.IN)
GPIO.setup(18, GPIO.OUT)
input_value = GPIO.input(17)
GPIO.output(18, True)

