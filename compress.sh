#!/bin/bash

#TODO: Other compression algorithms: zip 7z lz4 pigz pixz plzip lzop zstd pbzip2 p7zip
algorithms=("gzip" "bzip2" "xz")
files=("gz" "bz2" "xz")

[[ -z $1 ]] && echo no param entered && exit 1
[[ -d $1 ]] && tar -cf $1.tar $1 
[[ -f $1 ]] || echo not a valid file || exit 2

originalDir=`pwd`
cp $1 /tmp
cd /tmp

echo "`wc -c $1 | awk '{ print $1 }'` original" > rating.txt
for ((i=0; i<${#algorithms[@]}; i++)); do
	`${algorithms[i]} -f -k -9 $1` &
	declare ${algorithms[i]}="`wc -c $1.${files[i]} | awk '{ print $1 }'` ${algorithms[i]}"
	echo ${!algorithms[i]} >> rating.txt
done

#TODO: Display in human readable form
#TODO: Display in a sexy table
sort -n rating.txt > formated.txt
column -t formated.txt
smallest=`head -1 formated.txt | awk '{ print $2}'`

index=0
for ((i=0; i<${#algorithms[@]}; i++)); do
	if [[ $smallest == ${algorithms[i]} ]]; then
		index=$i
		break
	fi
done

mv $1.${files[$index]} $originalDir &
rm $1 $1* 2> /dev/null &
rm rating.txt formated.txt &
