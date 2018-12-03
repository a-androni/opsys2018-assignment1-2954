#!/bin/bash
#author: Achilleas Andronikos
#AEM: 2954

urls=();
i=-1;

mkdir -p currentState
mkdir -p previousState
#reading the urls from the txt file(and ignoring the comments)
while read -r -a line; do #read all lines from the list of adresses (!SAVED IN A FILE NAMED list!)
    [[ "$line" =~ ^#.*$ ]] && continue #line that starts with # will be ignored
    urls+=("$line")
    let "i++"
    touch ./previousState/stateOfUrl"$((i))"
    touch ./currentState/currentState"$((i))"
    if [ ! -s ./previousState/stateOfUrl"$((i))" ] #if the script runs for the first time stateOfUrls are blank files
    then
       echo "${urls[$i]} INIT" >&1
       wget -O- -q "${urls[$i]}" 1> ./previousState/stateOfUrl"$((i))"
    else
       wget -O- -q "${urls[$i]}" 1> ./currentState/currentState"$((i))"
       if [ $? -ne 0 ]
       then
          echo "${urls[$i]} FAILED" >&2 #message in case of no internet connection or other problems
          continue
       fi
       DIFF=$(diff -q ./currentState/currentState"$((i))" ./previousState/stateOfUrl"$((i))")
       if [ "$DIFF" != "" ]
       then
          echo "${urls[$i]}" >&2 #echoing the urls which found to be different than their previous State
       fi
    fi
done < $1


