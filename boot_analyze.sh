#!/bin/bash

SVG_PATH="/tmp/systemd-analyze.svg"
MAIN_UNIT="lightdm.service"
ACTION="$1"
shift

case "$ACTION" in
	critical-chain)
		exec systemd-analyze critical-chain "${1:-MAIN_UNIT}"
		;;
	plot)
		systemd-analyze plot > "$SVG_PATH" || exit 1
		exec konqueror "$SVG_PATH"
		;;
	dot)
		systemd-analyze dot "$@" | dot -Tsvg > "$SVG_PATH" || exit 1
		exec konqueror "$SVG_PATH"
		;;
	*)
		exit 1
esac
