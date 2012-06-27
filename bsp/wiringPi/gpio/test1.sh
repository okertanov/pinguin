#!/bin/bash

# Test using witingPi pins

max=16

for i in `seq 0 $max`;
do
  gpio mode  $i out
  gpio write $i   0
done

while true;
do
  echo -n " on: "
  for i in `seq 0 $max`;
  do
    echo -n "$i "
    gpio write $i 1
    sleep 0.1
  done
  echo ""

  echo -n "off: "
  for i in `seq 0 $max`;
  do
    echo -n "$i "
    gpio write $i 0
    sleep 0.1
  done
  echo ""
done
