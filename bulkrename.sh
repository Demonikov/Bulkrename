#!/bin/sh

# You MUST use quotes when passing arguments if you want space to be treated as such

# ~/.cache/BR_filelist.tmp		Original list
# /tmp/BR_filetoEdit			File to edit
# /tmp/BR_renameScript			Renaming Script 

[ -z "$1" ] && echo "Missing argument" && exit 1
[ -f /tmp/BR_filetoEdit ] && echo "RENAME ALREADY IN PROCESS" && exit 2

### Create file list ###
while [ -n "$1" ]; do
	printf "%s\n" "$1" >> /tmp/BR_filetoEdit
	shift
done

cp -f /tmp/BR_filetoEdit ~/.cache/BR_filelist.tmp
FileCount="$(wc -l < /tmp/BR_filetoEdit)"


### Edit name list ###
while true; do
	${EDITOR:-nano} /tmp/BR_filetoEdit # Edit files name
	[ "$(wc -l < /tmp/BR_filetoEdit)" -eq "$FileCount" ] &&
		break ||
		printf "# Line count does not match! REMOVE THIS MESSAGE\n" >> /tmp/BR_filetoEdit
done


### Create renaming script ###
printf "#!/bin/sh\n" > /tmp/BR_renameScript
printf "# This file will be executed when you close the editor.\n" >> /tmp/BR_renameScript

i=1
until [ $i -gt "$FileCount" ]; do
	First="$(sed -n ${i}p ~/.cache/BR_filelist.tmp)"
	Second="$(sed -n ${i}p /tmp/BR_filetoEdit)"
	[ "$First" != "$Second" ] && printf "mv \"%s\" -vi -- \"%s\"\n" "$First" "$Second" >> /tmp/BR_renameScript
	i=$(( i+1 ))
done


### Review and execute ###
if [ "$(wc -l < /tmp/BR_renameScript)" -gt 2 ]; then
	# Look at the script before it's executed, edit if necessary
	${EDITOR:-nano} /tmp/BR_renameScript
	chmod +x /tmp/BR_renameScript
	/tmp/BR_renameScript
fi

rm -f ~/.cache/BR_filelist.tmp
rm -f /tmp/BR_filetoEdit
rm -f /tmp/BR_renameScript
