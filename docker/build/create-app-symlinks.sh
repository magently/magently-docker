#!/bin/bash
set -e

##
# Creates app symlinks 
##
function create_app_symlinks()
{
	for FILE in $(ls -1a "$1" | grep -vP "^\.{1,2}$"); do
		if [ -d "/var/www/htdocs/$1/$FILE" ]; then
			create_app_symlinks "$1/$FILE"
		else
			mkdir -p "/var/www/htdocs.save/$1"

			if [ -f "/var/www/htdocs/$1/$FILE" ]; then
				mv "/var/www/htdocs/$1/$FILE" "/var/www/htdocs.save/$1/$FILE"
			else
				touch "/var/www/htdocs.save/$1/$FILE"
			fi

			ln -s "$(readlink -e "$1/$FILE")" "/var/www/htdocs/$1/$FILE"
		fi
	done
}

# Create htdocs.save
[ -e "/var/www/htdocs.save" ] || mkdir "/var/www/htdocs.save"

# Make sure app/code/local exists
[ -e "/var/www/htdocs/app/code/local" ] || mkdir "/var/www/htdocs/app/code/local"

# Revert symlinks at first
/scripts/revert-app-symlinks.sh "$1"

# Trigger creation
[ -d "$1" ] && create_app_symlinks "$1"
