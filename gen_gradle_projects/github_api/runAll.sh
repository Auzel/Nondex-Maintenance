#!/bin/bash

STARTDATE=$1
ENDDATE=$2

seq 1 10 | xargs -n1 ./gen_json.sh $STARTDATE $ENDDATE 



