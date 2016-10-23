#!/usr/bin/env bash

source internal/globals.sh

OUT_FILE="$1"
shift

TEMP="$(mktemp)"
ERROR_FILE="$(mktemp)"

function do_file {
	FILE="$1"
	POST_LINK="${ROOT_URL}/posts/$(basename "${FILE}" ".${POST_EXTENSION}").html"
	TITLE="$(get_title "${FILE}")"
	DATE="$(get_date "${FILE}")"
	MOD_DATE="$(get_mod_date "${FILE}")"
	MODIFIED=""
	(( "$((${MOD_DATE}-${DATE}))" > "${SIGNIFICANT_MOD_AFTER}" )) && MODIFIED="foobar" || MODIFIED=""
	DATE="$(ts_to_date "${DATE_FRMT}" "${DATE}")"
	MOD_DATE="$(ts_to_date "${LONG_DATE_FRMT}" "${MOD_DATE}")"
	AUTHOR="$(get_author "${FILE}")"

	CONTENT_IS_TRIMMED="$(content_will_be_trimmed "${FILE}")"

	OPTIONS="$(parse_options "${FILE}")"
	IS_PINNED="$(op_get "${OPTIONS}" pinned)"
	rm "${OPTIONS}"

	CONTENT="$(get_and_parse_content "${FILE}" "trimmed" "${ERROR_FILE}")"
	if [[ "$(cat "${ERROR_FILE}")" != "" ]]
	then
		cat "${ERROR_FILE}"
		rm "${TEMP}" "${ERROR_FILE}"
		exit 1
	fi

	cat << EOF >> "${TEMP}"
START_HOMEPAGE_PREVIEW_HTML
START_POST_HEADER_HTML([[<a href='${POST_LINK}'>${TITLE}</a>]], [[${DATE}]], [[${AUTHOR}]])
EOF
	if [[ "${MODIFIED}" != "" ]]
	then
		cat << EOF >> "${TEMP}"
POST_HEADER_MOD_DATE_HTML([[${MOD_DATE}]])
EOF
	fi
	if [[ "${IS_PINNED}" != "" ]] && (( "${IS_PINNED}" > "0" ))
	then
		cat << EOF >> "${TEMP}"
POST_HEADER_PINNED_HTML
EOF
	fi
	cat << EOF >> "${TEMP}"
END_POST_HEADER_HTML
${CONTENT}
EOF
	if [[ "${CONTENT_IS_TRIMMED}" != "" ]]
	then
		cat << EOF >> "${TEMP}"
<a href='${POST_LINK}'><em>Read the entire post</em></a>
EOF
	fi
	cat << EOF >> "${TEMP}"
END_HOMEPAGE_PREVIEW_HTML
EOF
}

cat << EOF > "${TEMP}"
m4_include(include/html.m4)
START_HTML([[${ROOT_URL}]], [[${BLOG_TITLE} - Home]])
HOMEPAGE_HEADER_HTML([[${ROOT_URL}]], [[${BLOG_TITLE}]], [[${BLOG_SUBTITLE}]])
EOF

IGNORE_POSTS=( )
NUM_IGNORE_POSTS="0"

while read FILE
do
	do_file "${FILE}"
	IGNORE_POSTS["${NUM_IGNORE_POSTS}"]="${FILE}"
	NUM_IGNORE_POSTS=$((NUM_IGNORE_POSTS+1))
done < <(only_pinned_posts "$@")

POSTS_REMAINING="${POSTS_ON_HOMEPAGE}"

while read FILE
do
	[[ " ${IGNORE_POSTS[@]} " =~ " ${FILE} " ]] && continue
	do_file "${FILE}"
	POSTS_REMAINING=$((POSTS_REMAINING-1))
	[[ "${POSTS_REMAINING}" == "0" ]] && break
done < <(sort_by_date "$@" | tac)

cat << EOF >> "${TEMP}"
HOMEPAGE_FOOTER_HTML([[${ROOT_URL}]], [[${VERSION}]])
END_HTML
EOF

"${M4}" ${M4_FLAGS} "${TEMP}" > "${OUT_FILE}"

rm "${TEMP}" "${ERROR_FILE}"
