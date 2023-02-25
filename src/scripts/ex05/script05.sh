# #!/bin/bash
# brew install coreutils

#if arg with path exists
if [[ $# -eq 0 ]]
then
    pathArg=$(pwd)
else
    if [ ! -d $1 ]; then
    	echo "Error: invalid path."
        exit;
    fi
    pathArg=$1
fi

start_sec=`date +%s`
start_msec=`date +%s.%N`
echo "Total number of folders (including all nested ones) = $(find $pathArg -depth -type d | wc -l)"
echo "TOP 5 folders of maximum size arranged in descending order (path and size):"
for (( i=1; i <= $(du | wc -l) && i <= 5; ++i ))
do
line=$(du -h |  tail -n +1 | sort -rn | sed -n "${i}p")
echo "$i - $(echo $line | awk '{print $2}'), $(echo $line | awk '{print $1}') "
done
echo "Total number of files = $(find $pathArg -type f | wc -l)"
echo "Number of:  "
echo "Configuration files (with the .conf extension) = $(find $pathArg -type f -name "*.conf" | wc -l)"
echo "Text files = $(find $pathArg -type f -exec grep -Iq $pathArg {} \; -print | wc -l)"
echo "Executable files =  $(find $pathArg -executable -type f | wc -l)"
echo "Log files (with the extension .log) = $(find $pathArg -type f -name "*.log" | wc -l)"
echo "Archive files = $(find $pathArg -type f \( -iname \*.tar -o -iname \*.zip -o -iname \*.zip -o -iname \*.jar -o -iname \*.tgz \) | wc -l)"
echo "Symbolic links = $(ls -lR $pathArg | grep ^l | wc -l)"
echo "TOP 10 files of maximum size arranged in descending order (path, size and type):"
count=$(find $pathArg ! -type d -ls | sort -rnk7 | wc -l)
for (( i=1; i <= $count && i <= 10; ++i ))
do
line=$(find $pathArg ! -type d -ls | sort -rnk7 | sed -n "${i}p")
size=$(echo $line | awk '{print $7}')
filepath=$(echo $line | awk '{print $11}')
filename=$(basename "$filepath")
extension=${filename##*.}
if [[ $(echo $filename | grep -o "\." | wc -l) -lt 1 ]]; then
extension="no extension"
fi
echo "$i - ${filepath}, ${size} B, ${extension}"
done
echo "TOP 10 executable files of the maximum size arranged in descending order (path, size and MD5 hash of file)"
count=$(find $pathArg -executable -type f | sort -rnk7 | wc -l)
for (( i=1; i <= $count && i <= 10; ++i ))
do
line=$(find $pathArg -executable -type f -ls | sort -rnk7 | sed -n "${i}p")
size=$(echo $line | awk '{print $7}')
filepath=$(echo $line | awk '{print $11}')
md5hash=$(md5sum $filepath | awk '{print $1}')
echo "$i - ${filepath}, ${size} B, ${md5hash}"
done
end_sec=`date +%s`
end_msec=`date +%s.%N`
echo "Script execution time (in seconds) = $((end_sec-start_sec))$( echo "$end_msec - $start_msec" | bc -l )"
