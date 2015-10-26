#!/bin/bash 
# author: SEB
# starts cardata.sh processes. 

if [ "$#" -ne 3 ]; then
	echo "Usage: <from> (inclusive) <to> (exclusive) <per_process>"; echo "Example: 0 19000 100"; exit 1
fi

remainder=$(( ($2 - $1) % $3))
if [ "$remainder" -ne "0" ]; then
	echo "Must be uniform"
	exit 1
fi

for (( i="$1"; i<"$2"; i=i+"$3"))
do
	j=$(( i+$3 ))
	./cardata.sh "$i" "$j" 2>/dev/null & 
done

echo "Processes started"


