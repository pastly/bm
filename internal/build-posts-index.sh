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
	DATE="$(get_date "${FILE}")"
	DATE_PRETTY="$(get_date "${FILE}" | ts_to_date "${DATE_FRMT}")"
	if [[ "${POST_INDEX_BY}" == "month" ]] && [[ "$(ts_to_date "${MONTHLY_INDEX_DATE_FRMT}" "${DATE}")" != "${CURRENT_EPOCH}" ]]
	then
		CURRENT_EPOCH="$(ts_to_date "${MONTHLY_INDEX_DATE_FRMT}" "${DATE}")"
		EPOCH_CHANGED="foobar"
	elif [[ "${POST_INDEX_BY}" == "year" ]] && [[ "$(ts_to_date "${YEARLY_INDEX_DATE_FRMT}" "${DATE}")" != "${CURRENT_EPOCH}" ]]
	then
		CURRENT_EPOCH="$(ts_to_date "${YEARLY_INDEX_DATE_FRMT}" "${DATE}")"
		EPOCH_CHANGED="foobar"
	fi
	if [[ "${EPOCH_CHANGED}" != "" ]]
	then
		EPOCH_CHANGED=""
		cat << EOF >> "${TEMP}"
</ul>
<h2>${CURRENT_EPOCH}</h2>
<ul>
EOF
	fi
	cat << EOF >> "${TEMP}"
<li><a href='${ROOT_URL}/posts/$(basename "$FILE" .${POST_EXTENSION}).html'>${TITLE}</a> by ${AUTHOR} on ${DATE_PRETTY}</li>
EOF
	shift
done < <(sort_by_date "$@" | tac)

cat << EOF >> "${TEMP}"
</ul>
CONTENT_PAGE_FOOTER_HTML([[${ROOT_URL}]], [[${VERSION}]])
END_HTML
EOF

OUT_DIR="$(dirname "${OUT_FILE}")"
mkdir -p "${OUT_DIR}"
"${M4}" ${M4_FLAGS} "${TEMP}" > "${OUT_FILE}"

rm "${TEMP}"
