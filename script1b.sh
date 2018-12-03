#!/bin/bash
#author: Achilleas Andronikos
#AEM: 2954

i=-1;
mkdir -p currentState
mkdir -p previousState

#copy the adresses in a local array and creates/updates the state files
while read -r -a line; do
    [[ "$line" =~ ^#.*$ ]] && continue
    urls+=("$line")
    let "i++"
    touch ./previousState/stateOfUrl"$((i))" & touch ./currentState/currentState"$((i))"
done < $1 
wait

i=-1;
#loop through all adresses and do stuff
for j in ${urls[*]}; do 
 let "i++" 
(
 if [ ! -s ./previousState/stateOfUrl"$((i))" ] #occurs only the first time this script runs
    then
       wget -O- -q "$j" 1> ./previousState/stateOfUrl"$((i))" && echo "$j INIT" >&1
     else
       wget -O- -q "$j" 1> ./currentState/currentState"$((i))" #this is the current content of urls
       if [ $? -ne 0 ] 
       then
          echo "$j FAILED" >&2 #message in case of no internet connection or other wget problems
          continue
       fi
       DIFF=$(diff -q ./currentState/currentState"$((i))" ./previousState/stateOfUrl"$((i))") #differences between previous and current state of urls
       if [ "$DIFF" != "" ]
       then
          echo "$j" >&2
       fi
    fi
)&
done
wait

