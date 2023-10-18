#!/usr/bin/env bash

# Right now we only take into account the case of single tag reading

if [[ $# -lt 1 ]]
then
    echo "Usage: $0 NUMBER_OF_TESTS_TO_RUN"
    exit 1
else
    # number of tests to execute
    TESTS=$1
fi

echo "* Running $1 test(s)"

for (( i = 0; i < TESTS; i++ ))
do
    echo -n "+ [$i] : "
    OUTPUT="$(./run.sh | tail -n 7 | tr -d "|" )"
    #echo "$OUTPUT"

    QUERIES="$(echo "$OUTPUT" | grep "queries" | cut -d":" -f 2 | tr -d "[:space:]")"
    TAGS="$(echo "$OUTPUT" | grep "decoded" | cut -d":" -f 2 | tr -d "[:space:]")"
    ID=$(echo "$OUTPUT" | grep "Tag ID" | cut -d" " -f 5 | tr -d "[:space:]" | tr -d "[:cntrl:]")

    echo -n "$TAGS"'/'"$QUERIES"

    # it shows Tag ID only if we have at least one successful reading
    [[ -n "${ID}" ]] && echo " -> Tag ID:" "$ID" || echo " "
done
