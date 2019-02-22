#!/bin/bash

out_dir=./img
logfile=./log
did_list=.did
cnt=0

mkdir ${out_dir}


function download_jpeg()
{
	outfile0=`echo $1 | tr ':' '-' | tr '/' '-'`
	outfile=${out_dir}/${outfile0}

	if [ -f ${outfile} ]; then
		# Already Downloaded
		echo "Already Downloaded"
		return
	fi

	curl -s -H "user-agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_13_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/71.0.3578.98 Safari/537.36" $1 > ${outfile}
	
	if [ $? -eq 0 ]; then
		echo $1 >> ${did_list}
		cnt=$(($cnt+1))
	fi
}

function download_dcimg()
{
	url=$1
	cookie_file=./.cookie
	body_file=./.body
	
	curl -s -c $cookie_file -H "User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_13_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/71.0.3578.98 Safari/537.36" $url > $body_file
	
	line=`grep "img src" $body_file`
	endpoint=`echo $line | cut -d "\"" -f 2`
	#echo $endpoint
	
	out_file0=`basename $endpoint`
	out_file=${out_dir}/_${out_file0}.jpeg
	if [ -f ${out_file} ]; then
		# Already Downloaded
		echo "Already Downloaded"
		return
	fi
	
	curl -s -b $cookie_file -H "User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_13_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/71.0.3578.98 Safari/537.36" http://dcimg.awalker.jp${endpoint} > ${out_file}
	
	if [ $? -eq 0 ]; then
		echo $1 >> ${did_list}
		cnt=$(($cnt+1))
	fi
}



rss=atom.xml


# get rss
curl -s -H "user-agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_13_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/71.0.3578.98 Safari/537.36" http://blog.nogizaka46.com/atom.xml > $rss



grep "<!\[CDATA\[" $rss > .tmp

cat .tmp | tr '\"' '\n' > .tmp2

grep http .tmp2 > .tmp3

grep ".jpeg" .tmp3 > jpeg_url
grep "dcimg" .tmp3 > dcimg_url


# download jpeg
while read line
do
	grep $line $did_list > /dev/null
	if [ $? -ne 0 ]; then
		download_jpeg $line
	fi
done < ./jpeg_url


# download dcimg
while read line
do
	grep $line $did_list > /dev/null
	if [ $? -ne 0 ]; then
		download_dcimg $line
	fi
done < ./dcimg_url

date >> $logfile
echo "$cnt downloaded" >> $logfile


