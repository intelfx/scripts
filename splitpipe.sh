#!/bin/bash

function log() {
	echo "$*" >&2
}

function die() {
	log "$*"
	exit 1
}

function main_to() {
	# data on stdin
	local PIECE_NR="1"
	while :; do
		local TEMP_FILE="$(mktemp -p "$TMPDIR")"
		trap "rm -f '$TEMP_FILE'" RETURN EXIT
		log ":: Piece $PIECE_NR, retry 1 via tee."
		head -c "$SIZE" | tee --output-error=warn "$TEMP_FILE" | "${COMMAND[@]//$PATTERN/$PIECE_NR}" || {
			# the command had failed
			RETRY_NR=2
			while :; do
				log ":: Piece $PIECE_NR, retry $RETRY_NR."
				"${COMMAND[@]//$PATTERN/$PIECE_NR}" < "$TEMP_FILE" && {
					break
				}
			done
		}

		if [[ ! -s "$TEMP_FILE" ]]; then
			log ":: Piece of zero size, exiting with total of $PIECE_NR pieces of which last is empty."
			return
		fi

		rm -f "$TEMP_FILE"
		trap - RETURN EXIT
		(( ++PIECE_NR ))
	done
}

function main_from() {
	die "E: Not implemented."
}

set -e

ARGS="$(getopt --long "to,from,size:,tempdir:" -o "tfs:d:" -- "$@")"
eval set -- "$ARGS"

SIZE="1K"
TMPDIR="/tmp"
PATTERN="{}"

while (( $# )); do
	case "$1" in
	-t|--to)
		MODE=to
		;;
	-f|--from)
		MODE=from
		;;
	-s|--size)
		shift
		SIZE="$1"
		;;
	-d|--tempdir)
		shift
		TMPDIR="$1"
		;;
	--)
		shift
		break
		;;
	*)
		die "E: Invalid option: '$1'"
		;;
	esac
	shift
done

COMMAND=( "$@" )

log "N: using piece size $SIZE."
log "N: using temporary directory $TEMPDIR to store at most one piece."
log "N: using command $(printf "'%s' " "${COMMAND[@]}"), piece id pattern is '$PATTERN'."
log "N: piping $MODE command."

case "$MODE" in
to)
	main_to "$@"
	;;
from)
	main_from "$@"
	;;
*)
	die "E: Invalid mode: '$MODE'"
	;;
esac
