#!/usr/bin/env bash

source internal/globals.sh

function build_post {
	IN="$1"
	TEMP=$(mktemp)
	OUT="$2"

	strip_comments "${IN}" > "${TEMP}"

	TITLE="$(get_title "${TEMP}")"
	DATE="$(get_date "${TEMP}")"
	DATE="$(date --date="@${DATE}" +'%Y-%m-%d')"

	CONTENT="$(get_content "${TEMP}")"
	CONTENT="$(echo "${CONTENT}" | ${MARKDOWN})"
	CONTENT="$(echo "${CONTENT}" | content_make_tag_links)"

	"${M4}" ${M4_FLAGS} > ${OUT} << EOF
m4_include(include/html.m4)
START_HTML(${TITLE} - ${BLOG_NAME})
HEADER_HTML(${BLOG_NAME}, [[${BLOG_COMMENT}]])
POST_HEADER_HTML(${TITLE}, ${DATE}, $(whoami))
${CONTENT}
FOOTER_HTML
END_HTML
EOF
	rm "${TEMP}"
}

OUT_DIR="$(dirname $1)"
mkdir -p "${OUT_DIR}"

OUT_FILE="$1"
shift

while [ ! -z "$1" ]
do
	IN_NAME_PART="$(basename "$1" ".${POST_EXTENSION}")"
	if [[ $OUT_FILE =~ ^.*$IN_NAME_PART.*$ ]]
	then
		build_post "$1" "$OUT_FILE"
		exit 0
	fi
	shift
done
exit 1
