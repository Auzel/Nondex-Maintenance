#!/bin/bash

STARTDATE=$1
ENDDATE=$2



for i in {1..10}
do
	./gen_json.sh $STARTDATE $ENDDATE $i 
done
