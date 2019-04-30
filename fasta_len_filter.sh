#! /bin/bash 

#unwraps INPUT then pipes to length filter with a cut off of > $3  

INPUT=$1
OUTPUT=$2


awk '/^>/ {printf("\n%s\n",$0);next; } { printf("%s",$0);}  END {printf("\n");}' < $INPUT | awk -v LEN="$3" '!/^>/ { next } { getline seq } length(seq) >= LEN { print $0 "\n" seq }' > $OUTPUT
