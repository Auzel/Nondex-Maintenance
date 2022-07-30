#!/bin/bash

action=$1
NUM_PROCESSES=50

if [[ $# -ne 1 || ($action != 'compile' && $action != 'test' && $action != 'nondex') ]]; then
    echo "Please provide a valid task as an argument from the list: compile, test, nondex."
    exit 1
fi

find -maxdepth 2 -type f -name "pom.xml" -print0 | xargs -0 -n 1 dirname -z | 
if [[ $action == 'compile' ]]; then
    xargs -0 -P $NUM_PROCESSES -I {} bash -c "cd {}; mvn clean package -DskipTests |& tee mavenCompile.log"
elif [[ $action == 'test' ]]; then
    xargs -0 -P $NUM_PROCESSES -I {} bash -c "cd {}; mvn test |& tee mavenTest.log"
elif [[ $action == 'nondex' ]]; then
    xargs -0 -P $NUM_PROCESSES -I {} bash -c "cd {}; mvn edu.illinois:nondex-maven-plugin:1.1.3-SNAPSHOT:nondex |& tee nondexTest.log"
fi


