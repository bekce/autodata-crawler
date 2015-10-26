#!/bin/bash 
# author: SEB
# auto-data.net car data crawler. run with cardata_starter.sh 
# redirect stderr stream (preferably to /dev/null) because xidel uses stderr for redundant messages, but this script uses stdout for errors. 

if [ "$#" -ne 2 ]; then
	echo "Usage: <from> (inclusive) <to> (exclusive)"; exit 1
fi


if [ ! -d "cardata" ]; then
	mkdir cardata
fi

#for (( i=1; i<=19144; i++))
for (( i="$1"; i<"$2"; i++)) 
do
	url='http://www.auto-data.net/tr/?f=showCar&car_id='"$i"
	
	#create temp file for wget header information dump
	tempfile=`mktemp`

	#download content & write headers (-S) to tempfile. 
	content=`wget --user-agent="Mozilla/5.0 (Windows NT 5.2; rv:2.0.1) Gecko/20100101 Firefox/4.0.1" -q -O - -S "$url" 2>"$tempfile"`

	#check wget return value is 0. 
	ret_val="$?"
	if [ "$ret_val" -ne 0 ]; then 
		rm "$tempfile" #delete temp file
		echo "error_wget $ret_val $url" 
		continue
	fi
	
	#check http status code
	ret_val=`cat "$tempfile" | grep "HTTP" | awk '{print $2}'`
	rm "$tempfile" #delete temp file
	if [ "$ret_val" -ne 200 ]; then
		echo "error_http $ret_val $url"
		continue
	fi
	
	#strip title of page and use it as filename
	title=`echo "$content" | ./xidel - -e //title | sed 's/ - Teknik özellikler, yakıt tüketimi//g; s/\// /g'`
	filename="cardata/$title"'_'"$i.xml"
	
	#parse & extract info with xidel
	echo "$content" | ./xidel - --extract-file=template.html --output-format=xml-wrapped > "$filename" 
	
	#check xidel return value is 0. 
 	ret_val="$?"
	if [ "$ret_val" -ne 0 ]; then 
		rm "$filename" #delete output file
		echo "error_xidel $ret_val $url" 
		continue
	fi
	
	#remove object tags, inplace sed
	sed -i'' 's/<object>//g; s/<\/object>//g' "$filename"
	
done

