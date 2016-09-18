#!/usr/bin/env bash

source internal/globals.sh

function build_post {
	IN="$1"
	IN_TEMP=$(mktemp)
	OUT="$2"
	OUT_TEMP=$(mktemp)

	strip_comments "${IN}" > "${IN_TEMP}"

	TITLE="$(get_title "${IN_TEMP}")"
	DATE="$(get_date "${IN_TEMP}")"
	MOD_DATE="$(get_mod_date "${IN_TEMP}")"
	MODIFIED=""
	(( "$((${MOD_DATE}-${DATE}))" > "${SIGNIFICANT_MOD_AFTER}" )) && MODIFIED="foobar" || MODIFIED=""
	DATE="$(ts_to_date "${DATE_FRMT}" "${DATE}")"
	MOD_DATE="$(ts_to_date "${LONG_DATE_FRMT}" "${MOD_DATE}")"
	AUTHOR="$(get_author "${IN_TEMP}")"

	CONTENT="$(get_and_parse_content "${IN_TEMP}")"

	cat > ${OUT_TEMP} << EOF
m4_include(include/html.m4)
START_HTML([[${ROOT_URL}]], [[${TITLE} - ${BLOG_TITLE}]])
CONTENT_PAGE_HEADER_HTML([[${ROOT_URL}]], [[${BLOG_TITLE}]], [[${BLOG_SUBTITLE}]])
EOF
	if [[ "${MODIFIED}" != "" ]]
	then
		cat >> ${OUT_TEMP} << EOF
POST_HEADER_MOD_DATE_HTML([[${TITLE}]], [[${DATE}]], [[${AUTHOR}]], [[${MOD_DATE}]])
EOF
	else
		cat >> ${OUT_TEMP} << EOF
POST_HEADER_HTML([[${TITLE}]], [[${DATE}]], [[${AUTHOR}]])
EOF
	fi
	cat >> ${OUT_TEMP} << EOF
${CONTENT}
CONTENT_PAGE_FOOTER_HTML([[${ROOT_URL}]], [[${VERSION}]])
END_HTML
EOF
	"${M4}" ${M4_FLAGS} "${OUT_TEMP}" > "${OUT}"
	rm "${IN_TEMP}" "${OUT_TEMP}"
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
