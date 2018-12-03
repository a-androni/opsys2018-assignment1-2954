#!/bin/bash
#author: Achilleas Andronikos
#AEM: 2954

mkdir temp
mkdir -p assigments
touch path.txt

tar xvzf $1 -C ./temp #extract the file in a temporary directory (its path should be given as a parameter to the script)
find ./temp -name "*.txt" > ./path.txt #pass the names of the files in a txt file

flag=1 #this flag ensures that only one url for every file will be read and passed to git clone 
while read -r -a path; do #loop for every .txt file
 while read -r -a line && (($flag == 1)) ; do #loop for every line of the .txt file
    [[ "$line" =~ ^#.*$ ]] && continue #ignore lines that starts with #
    [[ "$line" =~ "https*" ]] && continue #ignore lines that are not https
    flag=0;
    git clone --quiet $line ./assigments #save all the repos to a home directory
    if [ $? -ne 0 ]
       then
          echo "$line : Cloning FAILED" >&2 #message in case git clone fails
          continue
    else
       echo "$line : Cloning OK" >&1
    fi    
 done < "$path" 
 let "flag=1"
done < path.txt

rm -r ./temp
cd ./assigments #change directory to /assigments

for i in ./* ; do #loop through all the repos in the assigments directory
  d=$(find $i -not -path '*/\.*' -type d | wc -w) #this counts all the directories in the assigments subfolders 
  t=$(find $i -not -path '*/\.*' -name "*.txt" | wc -w) #this counts all the txt files in the assigments subfolders
  all=$(find $i -not -path '*/\.*' | wc -w) #this counts all the files in the assigments subfolders 
  e1=$(find $i -path "*/more/dataB.txt" | wc -l) #this determinates if dataB.txt exists in subfolder more of a repo
  e2=$(find $i -path "*/more/dataC.txt" | wc -l) #this determinates if dataC.txt exists in subfolder more of a repo
  e3=$(find $i -path "*/dataA.txt" | wc -l) #this determinates if dataA.txt exists inside a repo
  let "d--"
  let "all--"
  echo "$i:"
  echo "Number of directories: $d"
  echo "Number of txt files: $t"
  echo "Number of other files: $(($all-$t-$d))"
  if [ $e1 -eq 1 ] && [ $e2 -eq 1 ] && [ $e3 -eq 1 ]; #if e1 && e2 && e3 then the directory structure is as mentioned
    then
      echo "Directory structure is OK."
    else
      echo "Directory structure is NOT OK."
  fi
done









