#!/bin/sh

# Deduplicate a file by replacing it with a symbolic link to a hash-based name

# Requirements:
# * POSIX-compatible shell and system utilities (sh, cmp, mv, etc.)
# * "ln" utility with "-r" option to create a symbolic link with a relative
#   target, as found in GNU Coreutils <https://www.gnu.org/software/coreutils/>
# * "sha256sum" utility from GNU Coreutils
#   <https://www.gnu.org/software/coreutils/>

# Usage:
# Set the DEDUP_BASE variable to the base directory for the deduplicated
# hash-based names. Run with sh, passing the original filename as the first
# argument. (Multiple files are not supported. To apply run this across all
# files in a torrent, use "find" or another similar utility. For example:
# "find [directory] -type f -exec dedup.sh '{}' ';'")

# Notes:
# * The "-r" option to ln is not strictly needed, but without it the links will
#   be created with absolute targets. This script was originally designed for
#   the case of the original files and the deduplicated files on the same
#   filesystem, and the relative targets allow the filesystem to be remounted
#   to a different path without breaking the links.
# * The sha256sum utility may be replaced with a different program to calculate
#   the hash, such as the "sha256" utility found on BSD systems (and the exact
#   hash algorithm is not important, as long as it is collision-resistant).
#   However, the commands to extract the actual hash value from the output may
#   have to be adjusted.

DEDUP_BASE=/mnt/rwt_data/dedup

FILE=$1
KEY=$(sha256sum "$FILE" | cut -d ' ' -f 1)
DEDUP_PATH="$(echo "$KEY" | cut -b 1-4)/$(echo "$KEY" | cut -b 5-)"
DEDUP_FILE="$DEDUP_BASE/$DEDUP_PATH"
if [ -f "$DEDUP_FILE" ]; then
	if cmp "$FILE" "$DEDUP_FILE"; then
		rm "$FILE"
		ln -sr "$DEDUP_FILE" "$FILE"
	else
		echo "Collision between $FILE and $DEDUP_FILE"
	fi
else
	mkdir -p $(dirname "$DEDUP_FILE")
	mv "$FILE" "$DEDUP_FILE"
	ln -sr "$DEDUP_FILE" "$FILE"
fi
