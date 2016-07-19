#!/bin/bash
set -e

##
# Reverts stored symlinks
##
function revert_app_symlinks()
{
	for FILE in $(ls -1a "/var/www/htdocs.save/$1" | grep -vP "^\.{1,2}$"); do
		if [ ! -h "/var/www/htdocs/$1/$FILE" ]; then
			revert_app_symlinks "$1/$FILE"
		else
			rm "/var/www/htdocs/$1/$FILE"
			mv -s "/var/www/htdocs.save/$1/$FILE" "/var/www/htdocs/$1/$FILE"
		fi
	done
}

# Trigger revert
[ -d "/var/www/htdocs.save" ] &&  revert_app_symlinks "$1"
