#!/usr/bin/env bash

source internal/globals.sh

function do_it {
	TEMP="$(mktemp)"
	while read FILE
	do
		cp "${FILE}" "${TEMP}"
		TITLE="$(get_title "${TEMP}" | to_lower | strip_punctuation | strip_space)"
		ID="$(get_id "${TEMP}")"
		ID="$(echo "${ID}" | cut -c 1-8)"
		head -n 2 "${TEMP}" > "${FILE}"
		echo "${ID}" >> "${FILE}"
		tail -n +4 "${TEMP}" >> "${FILE}"
		NEW_FILE="$(dirname "${FILE}")/${TITLE}${TITLE_SEPARATOR_CHAR}${ID}.${POST_EXTENSION}"
		[[ "${NEW_FILE}" != "${FILE}" ]] && mv "${FILE}" "${NEW_FILE}"
	done < <(find "${POST_DIR}" -type f -name "*.${POST_EXTENSION}")
	rm "${TEMP}"
}

echo "This script will convert v1.2.1 posts into valid v2.0.0 posts. The changes
made are:

- post ids are trimmed to their first 8 characters

    YF4ciVY665x59Frf           --> YF4ciVY6

- last part of filename will be the new post id instead of a random number

    my-newest-post-43193.bm    --> my-newest-post-YF4ciVY6.bm

- if the title + id is different than the current filename, the filename will
  change

    my-newest-post-YF4ciVY6.bm --> about-me-YF4ciVY6.bm

The most common breakage that this will cause is if you have linked from one
post to another, those links will now be broken as the final filename will be
different.

Press enter to see the list of files that will be affected..."

read BLAH

find "${POST_DIR}" -type f -name "*.${POST_EXTENSION}" -print0 |\
sort_by_date

echo ""
read -p "Would you like to make the changes listed above?" ANSWER
while [ 1 ]
do
	case $ANSWER in
		[Yy]* )
			do_it
			break;;
		* )
			echo "Whew. That was close."
			break;;
	esac
done

exit 0

