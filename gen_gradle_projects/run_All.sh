#!/bin/bash

if [ $# -eq 0 ]; then
    echo "No arguments provided"
    exit 1
fi

target=$1
files="$target/*"

for f in $files
do
  ./download_java_projects.sh "$f"
done



