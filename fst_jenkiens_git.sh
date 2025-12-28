#!/bin/bash

NAME=$1
LASTNAME=$2
SHOW=$3

if [ "$SHOW" = "true" ]; then
  echo "hello, $NAME $LASTNAME"
else
  echo "if you want see the name, submit values for 3rd parameter"
fi
