#!/bin/bash
set -e 

function watch
{
	echo "Watching $SYNC_SRC ..."

	# Watch /app changes
	inotifywait -mr -e modify -e attrib -e move -e create -e delete -e delete_self "$SYNC_SRC" | while read path action file; do

		echo "watch: $path, $action, $file"

		FILEPATH="${path#$SYNC_SRC/}$file"

		case "$action" in
			"DELETE_SELF") ;;
			"DELETE"*)
				/scripts/revert-app-symlinks.sh "$FILEPATH"
			;;
			"MOVED_FROM"*)
				/scripts/revert-app-symlinks.sh "$FILEPATH"
			;;
			*)
				/scripts/create-app-symlinks.sh "$FILEPATH"
			;;
		esac

	done
}

if [ -n "$SYNC_DIRS" ]; then
	watch
fi