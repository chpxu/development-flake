#!/bin/bash
name=$1
path="$name"

if [ "$2" = "compile" ]; then
  clang++ -g -Wall -Werror -std=c++17 "$path.cpp" -o "$path.o"
elif [ "$2" = "run" ]; then
  ./"$path".o > "output.txt"
elif [ "$2" = "valgrind" ]; then
  valgrind --keep-debuginfo=yes --leak-check=full --show-leak-kinds=all --track-origins=yes -s "./$path.o"
else
  echo "COMMAND NOT FOUND"
fi

if [ "$1" = "test" ]; then
  echo "TEST" 
fi
# gcc -g -fsanitize=undefined -fsanitize=thread -Wall -Werror -std=c99 -lm -o assign3 assign3.c 

echo "TERMINATED"