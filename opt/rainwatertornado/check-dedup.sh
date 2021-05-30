#!/bin/sh

# Verify that the deduplicated file path matches the content

# Requirements:
# * POSIX-compatible shell and system utilities (sh, sed, test)
# * "sha256sum" utility from GNU Coreutils
#   <https://www.gnu.org/software/coreutils/>

# Usage:
# Run with sh, passing the path as the first argument. (Multiple files are
# not supported. To apply this across all files in a directory, use "find" or
# another similar utility. For example:
# "find [directory] -type f -exec check-dedup.sh '{}' ';'")

# Notes:
# * The sha256sum utility may be replaced with a different program to calculate
#   the hash, such as the "sha256" utility found on BSD systems (and the exact
#   hash algorithm is not important, as long as it is collision-resistant).
#   However, the commands to extract the actual hash value from the output may
#   have to be adjusted.

FILE=$1
KEY_FROM_PATH="$(echo "$FILE" | sed 's/.*\([^\/]\{4,4\}\)\/\([^\/]*\)/\1\2/')"
KEY_FROM_CONTENT=$(sha256sum "$FILE" | cut -d ' ' -f 1)
if [ "$KEY_FROM_PATH" != "$KEY_FROM_CONTENT" ]; then
	echo "Mismatch between filename $FILE and content hash $KEY_FROM_CONTENT"
fi
