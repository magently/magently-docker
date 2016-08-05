#!/bin/bash
set -e

##
# Creates app symlinks 
##
function create_app_symlinks()
{
	if [ -d "$SYNC_DEST/$1" ]; then
		for FILE in $(ls -1a "$SYNC_SRC/$1" | grep -vP "^\.{1,2}$"); do
			create_app_symlinks "$1/$FILE"
		done
	elif [ ! -h "$SYNC_DEST/$1" ] && [[ "$(readlink -m "$SYNC_DEST/$1")" != "$SYNC_SRC/"* ]]; then
		[ -e "$SAVE_PATH/${1%/*}" ] || mkdir -p "$SAVE_PATH/${1%/*}"

		if [ -f "$SYNC_DEST/$1" ]; then
			mv "$SYNC_DEST/$1" "$SAVE_PATH/$1"
		else
			touch "$SAVE_PATH/$1.fake"
		fi

		DEST="$SYNC_DEST/$1"
		ln -s "$(readlink -m "$SYNC_SRC/$1")" "${DEST%/}"
	fi
}

# Trigger creation
create_app_symlinks "${1%/}"
