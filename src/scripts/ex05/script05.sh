# #!/bin/bash
# brew install coreutils

start_sec=`date +%s`
start_msec=`date +%s.%N`
echo "Total number of folders (including all nested ones) = $(find . -depth -type d | wc -l)"
echo "TOP 5 folders of maximum size arranged in descending order (path and size):"
for (( i=1; i <= $(du | wc -l) && i <= 5; ++i ))
do
line=$(du -h |  tail -n +1 | sort -rn | sed -n "${i}p")
echo "$i - $(echo $line | awk '{print $2}'), $(echo $line | awk '{print $1}') "
done
echo "Total number of files = $(find ./ -type f | wc -l)"
echo "Number of:  "
echo "Configuration files (with the .conf extension) = $(find ./ -type f -name "*.conf" | wc -l)"
echo "Text files = $(find . -type f -exec grep -Iq . {} \; -print | wc -l)"
echo "Executable files =  $(find . -executable -type f | wc -l)"
echo "Log files (with the extension .log) = $(find ./ -type f -name "*.log" | wc -l)"
echo "Archive files = $(find . -type f \( -iname \*.tar -o -iname \*.zip -o -iname \*.zip -o -iname \*.jar -o -iname \*.tgz \) | wc -l)"
echo "Symbolic links = $(ls -lR . | grep ^l | wc -l)"
echo "TOP 10 files of maximum size arranged in descending order (path, size and type):"
count=$(find . ! -type d -ls | sort -rnk7 | wc -l)
for (( i=1; i <= $count && i <= 10; ++i ))
do
line=$(find . ! -type d -ls | sort -rnk7 | sed -n "${i}p")
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
count=$(find . -executable -type f | sort -rnk7 | wc -l)
for (( i=1; i <= $count && i <= 10; ++i ))
do
line=$(find . -executable -type f -ls | sort -rnk7 | sed -n "${i}p")
size=$(echo $line | awk '{print $7}')
filepath=$(echo $line | awk '{print $11}')
md5hash=$(md5sum $filepath | awk '{print $1}')
echo "$i - ${filepath}, ${size} B, ${md5hash}"
done
end_sec=`date +%s`
end_msec=`date +%s.%N`
echo "Script execution time (in seconds) = $((end_sec-start_sec))$( echo "$end_msec - $start_msec" | bc -l )"
