#!/bin/bash 
# author: SEB
# auto-data.net car image downloader. writes to ./images folder
# redirect stderr stream (preferably to /dev/null) because xidel uses stderr for redundant messages, but this script uses stdout for errors. 
# Example: ./images.sh 1 10667 2>/dev/null 

if [ "$#" -ne 2 ]; then
	echo "Usage: <from> (inclusive) <to> (exclusive)"; exit 1
fi


if [ ! -d "images" ]; then
	mkdir images
fi

#for (( i=1; i<=10666; i++))
for (( i="$1"; i<"$2"; i++)) 
do
	url='http://www.auto-data.net/tr/?f=showImages&image_id='"$i"
	
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

	#extract image source path. example output: "/images/big1.jpg"
	suburl=`echo "$content" | ./xidel - -e '//*[@id="center"]/div[1]/div[1]/img/@src' `
	imageurl="http://www.auto-data.net$suburl"
	#extract car name (directory name) 
	dirpath=`echo "$content" | ./xidel - -e '//*[@id="right"]/h1' | sed 's/Görüntüler: //g; s/\// /g;' `
	#construct path & create dir if not exists
	dirpath="images/$dirpath"
	if [ ! -d "$dirpath" ]; then
		mkdir -p "$dirpath"
	fi
	filename=`basename "$imageurl"`

	#download image file
	wget -q -O "$dirpath/$filename" "$imageurl"
	
	#check wget return value is 0. 
 	ret_val="$?"
	if [ "$ret_val" -ne 0 ]; then 
		echo "error_wget2 $ret_val $url" 
		continue
	fi

	
done

