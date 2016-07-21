#!/bin/bash
set -e

##
# Reverts stored symlinks
##
function revert_app_symlinks()
{
	if [ -h "$DOCROOT_PATH/$1" ] && [[ "$(readlink -m "$DOCROOT_PATH/$1")" == "$APP_PATH"* ]]; then
		rm "$DOCROOT_PATH/$1"
		[ ! -e "$SAVE_PATH/$1" ] || mv "$SAVE_PATH/$1" "$DOCROOT_PATH/$1"
		[ ! -e "$SAVE_PATH/$1.fake" ] || rm "$SAVE_PATH/$1.fake"
	elif [ -d "$SAVE_PATH/$1" ]; then
		for FILE in $(ls -1a "$SAVE_PATH/$1" | grep -vP "^\.{1,2}$"); do
			revert_app_symlinks "$1/${FILE%.fake}/"
		done
	fi
}

# Trigger revert
revert_app_symlinks "${1%/}"
