#!/bin/bash

#Format of date is yyyy-mm-ddd


STARTDATE=$1
ENDDATE=$2
PAGE=$3
DESTINATION_FOLDER=output
DESTINATION_FILE=${DESTINATION_FOLDER}/projects_${STARTDATE}_to_${ENDDATE}_${PAGE}.json
URL="https://api.github.com/search/repositories?q=stars:%3E1+pushed%3A${STARTDATE}..${ENDDATE}+language:java&sort=stars&order=desc&per_page=100&page=${PAGE}"

if [[ $# -ne 3 ]]; then
	echo "Need to supply 3 arguments: startdate, enddate, page#."	
	exit 1
fi

if [[ ! -d $DESTINATION_FOLDER ]]; then
	mkdir $DESTINATION_FOLDER
fi

if [[ -f $DESTINATION_FILE ]]; then
	echo "file already exist for that date range and page."
	exit 1
fi

curl -s -o $DESTINATION_FILE $URL 
