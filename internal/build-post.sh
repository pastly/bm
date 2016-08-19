#!/usr/bin/env bash

source internal/globals.sh

function build_post {
	IN="$1"
	TEMP=$(mktemp)
	OUT="$2"

	strip_comments "${IN}" > "${TEMP}"

	TITLE="$(get_title "${TEMP}")"
	DATE="$(get_date "${TEMP}")"
	DATE="$(ts_to_date "${DATE}")"
	MOD_DATE="$(get_mod_date "${TEMP}")"
	MOD_DATE="$(ts_to_date "${MOD_DATE}")"
	AUTHOR="$(get_author "${TEMP}")"

	CONTENT="$(get_content "${TEMP}")"
	CONTENT="$(echo "${CONTENT}" | ${MARKDOWN} | content_make_tag_links | parse_out_our_macros)"

	"${M4}" ${M4_FLAGS} > ${OUT} << EOF
m4_include(include/html.m4)
START_HTML([[${TITLE} - ${BLOG_TITLE}]])
HEADER_HTML([[${BLOG_TITLE}]], [[${BLOG_SUBTITLE}]])
POST_HEADER_HTML([[${TITLE}]], [[${DATE}]], [[${AUTHOR}]])
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
