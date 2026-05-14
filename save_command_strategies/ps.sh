#!/usr/bin/env bash

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

PANE_PID="$1"
PS_CACHE="${TMPDIR:-/tmp}/tmux-resurrect-ps-cache"

exit_safely_if_empty_ppid() {
	if [ -z "$PANE_PID" ]; then
		exit 0
	fi
}

ps_output() {
	local now mtime
	now=$(date +%s)
	if [ -f "$PS_CACHE" ]; then
		mtime=$(stat -f %m "$PS_CACHE" 2>/dev/null || stat -c %Y "$PS_CACHE" 2>/dev/null || echo 0)
		if [ $(( now - mtime )) -lt 60 ]; then
			cat "$PS_CACHE"
			return
		fi
	fi
	local tmpfile="${PS_CACHE}.$$"
	ps -ao "ppid,args" > "$tmpfile"
	mv -f "$tmpfile" "$PS_CACHE"
	cat "$PS_CACHE"
}

full_command() {
	ps_output |
		sed "s/^ *//" |
		grep "^${PANE_PID} " |
		cut -d' ' -f2-
}

main() {
	exit_safely_if_empty_ppid
	full_command
}
main
