#!/usr/bin/env bash

[ ! -d posts ] &&
	echo "Nothing to do :)" &&
	exit 0

[ ! -d include ] &&
	echo "Nothing to do :)" &&
	exit 0

[ ! -f include/bm.conf ] &&
	echo "Nothing to do :)" &&
	exit 0

[ ! -f posts/bm.conf ] &&
[ -f include/bm.conf ] &&
	mv -v include/bm.conf posts/bm.conf &&
	echo "Moved current bm.conf to new location. Done." &&
	echo "You can delete the include/ directory now" &&
	echo "If it isn't empty, something is wrong." &&
	exit 0

# Have both files
# If posts/bm.conf is internal/bm.conf.example, then overwriting it is okay.

diff <( grep -vE '^#' posts/bm.conf ) internal/bm.conf.example &> /dev/null &&
	mv -v include/bm.conf posts/bm.conf &&
	echo "posts/bm.conf looks like the example config. Overwriting with old config. Done" &&
	echo "You can delete the include/ directory now" &&
	echo "If it isn't empty, something is wrong." &&
	exit 0

# Have both files
# If posts/bm.conf is the same as include/bm.conf, then delete old one

diff posts/bm.conf include/bm.conf &> /dev/null &&
	rm -v include/bm.conf &&
	echo "posts/bm.conf is exactly the same as include/bm.conf. Deleted the old" &&
	echo "one. Done." &&
	echo "You can delete the include/ directory now" &&
	echo "If it isn't empty, something is wrong." &&
	exit 0

# Have both files
# And don't know what to do

echo "Both the old config file (include/bm.conf) and the new config file
(posts/bm.conf) exist and it doesn't seem safe to overwrite the new one. It's
up to you to figure out what you want to do. Afterwards, you can delete the
include/ directory if bm.conf was the only file in it. If it wasn't the only
file, something is wrong."
exit 1
