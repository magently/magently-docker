#!/bin/bash
set -e 

echo "Watching $APP_PATH ..."

# Watch /app changes
inotifywait -mr -e modify -e attrib -e move -e create -e delete -e delete_self "$APP_PATH" | while read path action file; do

	echo "watch: $path, $action, $file"

	FILEPATH="${path#$APP_PATH/}$file"

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