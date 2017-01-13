#!/usr/bin/env bash

# Expects to be ran from the root bm directory.
# ./tools/count_function_usage.sh
#
# Gets its list of functions from all *.sh files in internal/
#
# It isn't perfect, as it will pick up on function names that are in comments
# and function names that contain other function names.

for f in $( grep function internal/*.sh | grep -vE ".*:#" | cut -d ' ' -f 2 )
do
	echo -n "$f "
	grep -r $f | grep -v \.git | wc -l
done
