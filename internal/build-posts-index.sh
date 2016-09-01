#!/usr/bin/env bash

source internal/globals.sh

OUT_FILE="$1"
shift

TEMP=$(mktemp)

cat << EOF > "${TEMP}"
m4_include(include/html.m4)
START_HTML([[${ROOT_URL}]], [[${BLOG_TITLE} - Home]])
CONTENT_PAGE_HEADER_HTML([[${ROOT_URL}]], [[${BLOG_TITLE}]], [[${BLOG_SUBTITLE}]])
<h1>Posts</h1>
<ul>
EOF

while read FILE
do
	TITLE="$(get_title "${FILE}")"
	AUTHOR="$(get_author "${FILE}")"
	DATE="$(get_date "${FILE}" | ts_to_date "${DATE_FRMT}")"
	cat << EOF >> "${TEMP}"
<li><a href='${ROOT_URL}/posts/$(basename "$FILE" .${POST_EXTENSION}).html'>${TITLE}</a> by ${AUTHOR} on ${DATE}</li>
EOF
	shift
done < <(sort_by_date "$@" | tac)

cat << EOF >> "${TEMP}"
</ul>
CONTENT_PAGE_FOOTER_HTML([[${ROOT_URL}]], [[${VERSION}]])
END_HTML
EOF

"${M4}" ${M4_FLAGS} "${TEMP}" > "${OUT_FILE}"

rm "${TEMP}"
