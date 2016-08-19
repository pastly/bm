#!/usr/bin/env bash

source internal/globals.sh

OUT_FILE="$1"
shift

TEMP=$(mktemp)

cat << EOF > "${TEMP}"
m4_include(include/html.m4)
START_HTML([[${BLOG_TITLE} - Home]])
HEADER_HTML([[${BLOG_TITLE}]], [[${BLOG_SUBTITLE}]])
EOF

while read FILE
do
	POST_LINK="/posts/$(basename "${FILE}" ".${POST_EXTENSION}").html"
	TITLE="$(get_title "${FILE}")"
	DATE="$(ts_to_date "$(get_date "${FILE}")")"
	AUTHOR="$(get_author "${FILE}")"
	CONTENT="$(get_content "${FILE}")"
	CONTENT_IS_TRIMMED="$(echo "${CONTENT}" | content_will_be_trimmed)"
	CONTENT="$(echo "${CONTENT}" | content_trim_for_preview | "${MARKDOWN}" | content_make_tag_links } )"
	cat << EOF >> "${TEMP}"
POST_HEADER_HTML([[<a href='${POST_LINK}'>${TITLE}</a>]], [[${DATE}]], [[${AUTHOR}]])
${CONTENT}
EOF
	if [[ "${CONTENT_IS_TRIMMED}" != "" ]]
	then
		cat << EOF >> "${TEMP}"
<a href='${POST_LINK}'><em>Read the entire post</em></a>
EOF
	fi
	echo "<hr>" >> "${TEMP}"
	shift
done < <(sort_by_date "$@" | tac | head -n "${POSTS_ON_HOMEPAGE}")

cat << EOF >> "${TEMP}"
<a href='/tags/index.html'>Posts by tag</a><br/>
<a href='/posts/index.html'>All posts</a>
FOOTER_HTML
END_HTML
EOF

"${M4}" ${M4_FLAGS} "${TEMP}" > "${OUT_FILE}"

rm "${TEMP}"
