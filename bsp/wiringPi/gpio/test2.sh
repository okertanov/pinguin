#!/bin/bash

# Test using GPIO pins

pins="17 18 21 22 23 24 25 4 0 1 8 7 10 9 11 14 15"

for i in $pins ;
do
  gpio -g mode  $i out
  gpio -g write $i   0
done

while true;
do
  echo -n " on: "
  for i in $pins ;
  do
    echo -n "$i "
    gpio -g write $i 1
    sleep 0.1
  done
  echo ""

  echo -n "off: "
  for i in $pins ;
  do
    echo -n "$i "
    gpio -g write $i 0
    sleep 0.1
  done
  echo ""
done
