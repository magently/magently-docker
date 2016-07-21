#!/bin/bash
set -e

##
# Creates app symlinks 
##
function create_app_symlinks()
{
	if [ -d "$DOCROOT_PATH/$1" ]; then
		for FILE in $(ls -1a "$APP_PATH/$1" | grep -vP "^\.{1,2}$"); do
			create_app_symlinks "$1/$FILE"
		done
	elif [ ! -h "$DOCROOT_PATH/$1" ] && [[ "$(readlink -m "$DOCROOT_PATH/$1")" != "$APP_PATH/"* ]]; then
		[ -e "$SAVE_PATH/${1%/*}" ] || mkdir -p "$SAVE_PATH/${1%/*}"

		if [ -f "$DOCROOT_PATH/$1" ]; then
			mv "$DOCROOT_PATH/$1" "$SAVE_PATH/$1"
		else
			touch "$SAVE_PATH/$1.fake"
		fi

		ln -s "$(readlink -m "$APP_PATH/$1")" "$DOCROOT_PATH/$1"
	fi
}

# Trigger creation
create_app_symlinks "${1%/}"
