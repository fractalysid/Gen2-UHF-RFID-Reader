#!/usr/bin/env bash

# Right now we only take into account the case of single tag reading

# TODO: add run duration as an additional argument
if [[ $# -lt 2 ]]
then
    echo "Usage: $0 NUMBER_OF_MEASUREMENT NUMBER_OF_MEASUREMENTS_TO_RUN"
    exit 1
else
    # number of tests to execute
    TESTS=$2
    NAME=$1
fi

echo "* Running $2 measurements for #$1"

for (( i = 1; i <= TESTS; i++ ))
do
    echo -n " - [$i] "
    ./run.sh >/dev/null 2>&1
    mkdir -p ./data/measurements/$NAME
    cp ./data/source ./data/measurements/${NAME}/source${NAME}_${i}
    cp ./data/decoder ./data/measurements/${NAME}/decoder${NAME}_${i}
    echo " -> COMPLETED"
done
