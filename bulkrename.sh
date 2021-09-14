#!/bin/sh

# You MUST quote expression if you want space to be treated as such

# ~/.cache/BR_filelist.tmp		Original list
# /tmp/BR_filetoEdit			File to edit
# /tmp/BR_renameScript			Renaming Script 

[ -z "$1" ] && echo "Missing argument" && exit 1
[ -f /tmp/BR_filetoEdit ] && echo "RENAME ALREADY IN PROCESS" && exit 2

# Create file list
while [ -n "$1" ]; do
	printf "%s\n" "$1" >> /tmp/BR_filetoEdit
	shift
done

cp -f /tmp/BR_filetoEdit ~/.cache/BR_filelist.tmp
FileCount="$(wc -l < /tmp/BR_filetoEdit)"

while true; do
	$EDITOR /tmp/BR_filetoEdit # Edit files name

	# Confirmations
	if [ "$(wc -l < /tmp/BR_filetoEdit)" -ne "$FileCount" ]; then
		echo "Line count does not match!" >> /tmp/BR_filetoEdit
	
	else
		i=1
		
		printf "#!/bin/sh\n# This file will be executed when you close the editor.\n" > /tmp/BR_renameScript
		
		# Spotting differences in file lists and writing renaming script
		until [ $i -gt "$FileCount" ]; do
			First="$(sed -n ${i}p ~/.cache/BR_filelist.tmp)"
			Second="$(sed -n ${i}p /tmp/BR_filetoEdit)"
			[ "$First" != "$Second" ] && printf "mv \"%s\" -vi -- \"%s\"\n" "$First" "$Second" >> /tmp/BR_renameScript
			i=$(( i+1 ))
		done
		
		[ "$(wc -l < /tmp/BR_renameScript)" -lt 3 ] && break # There were no renaming needed
		
		# Look at the script before it's executed, edit if necessary
		$EDITOR /tmp/BR_renameScript
		chmod +x /tmp/BR_renameScript
		/tmp/BR_renameScript
		break
	fi
	
done

# Force ?
rm /tmp/BR_renameScript
rm ~/.cache/BR_filelist.tmp || exit 3
rm /tmp/BR_filetoEdit || exit 3