#!/usr/bin/env bash

source internal/globals.sh

set_editor

SEARCH_VALUE="$@"
SEARCH_VALUE="$(echo ${SEARCH_VALUE} | to_lower | strip_space)"

NUM_FOUND_FILES=$(find "${POST_DIR}" -type f -name "*${SEARCH_VALUE}*" | wc --lines)

if [[ "${NUM_FOUND_FILES}" == "1" ]]
then
	${ED} $(find ${POST_DIR} -type f -name "*${SEARCH_VALUE}*")
	make
elif [[ "${NUM_FOUND_FILES}" > "1" ]]
then
	echo "Ambiguous search term ${SEARCH_VALUE}"
	find ${POST_DIR} -type f -name "*${SEARCH_VALUE}*"
else
	echo "Could not find posts matching ${SEARCH_VALUE}"
fi
