#!/bin/bash
lol=$(cat rawContent/version.txt | awk -F- '//{print $1 "-" $2+1}')
echo "build updated to "$lol
echo $lol > rawContent/version.txt
