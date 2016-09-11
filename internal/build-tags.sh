#!/usr/bin/env bash

source internal/globals.sh

INDEX_FILE="$1"
shift
TEMP_INDEX_FILE=$(mktemp)
TEMP_TAG_FILE=$(mktemp)
OUT_DIR=$(dirname "${INDEX_FILE}")
mkdir -p "${OUT_DIR}"

FILES_WITH_TAGS=""
FWT_I=0
ALL_TAGS=""
AT_I=0

while [ ! -z "$1" ]
do
	TAGS_FOR_FILE=$(get_tags "$1")
	if [ ! -z "${TAGS_FOR_FILE}" ]
	then
		FILES_WITH_TAGS[$FWT_I]="$1"
		FWT_I=$((FWT_I+1))
		for TAG in $TAGS_FOR_FILE
		do
			COPY_OF_ALL_TAGS="${ALL_TAGS[@]//$TAG}"
			if [[ "${COPY_OF_ALL_TAGS[@]}" == "${ALL_TAGS[@]}" ]]
			then
				ALL_TAGS[$AT_I]="${TAG}"
				AT_I=$((AT_I+1))
			fi
		done
	fi
	shift
done
cat << EOF > "${TEMP_INDEX_FILE}"
m4_include(include/html.m4)
START_HTML([[${ROOT_URL}]], [[Tags - ${BLOG_TITLE}]])
CONTENT_PAGE_HEADER_HTML([[${ROOT_URL}]], [[${BLOG_TITLE}]], [[${BLOG_SUBTITLE}]])
EOF
for TAG in ${ALL_TAGS[@]}
do
	TAG_FILE="${OUT_DIR}/${TAG}.html"
	cat << EOF > "${TEMP_TAG_FILE}"
m4_include(include/html.m4)
START_HTML([[${ROOT_URL}]], [[$TAG - ${BLOG_TITLE}]])
CONTENT_PAGE_HEADER_HTML([[${ROOT_URL}]], [[${BLOG_TITLE}]], [[${BLOG_SUBTITLE}]])
<h1>$TAG</h1>
<ul>
EOF
	cat << EOF >> "${TEMP_INDEX_FILE}"
<h1>${TAG}</h1>
<ul>
EOF
	CURRENT_EPOCH=""
	for FILE in $(sort_by_date "${FILES_WITH_TAGS[@]}" | tac)
	do
		FILE_HAS_TAG=$(file_has_tag "${FILE}" "${TAG}")
		if [ ! -z "$FILE_HAS_TAG" ]
		then
			TITLE="$(get_title "${FILE}")"
			AUTHOR="$(get_author "${FILE}")"
			DATE="$(get_date "${FILE}")"
			DATE_PRETTY="$(get_date "${FILE}" | ts_to_date "${DATE_FRMT}")"
			if [[ "${TAG_INDEX_BY}" == "month" ]] && [[ "$(ts_to_date "${MONTHLY_INDEX_DATE_FRMT}" "${DATE}")" != "${CURRENT_EPOCH}" ]]
			then
				CURRENT_EPOCH="$(ts_to_date "${MONTHLY_INDEX_DATE_FRMT}" "${DATE}")"
				EPOCH_CHANGED="foobar"
			elif [[ "${TAG_INDEX_BY}" == "year" ]] && [[ "$(ts_to_date "${YEARLY_INDEX_DATE_FRMT}" "${DATE}")" != "${CURRENT_EPOCH}" ]]
			then
				CURRENT_EPOCH="$(ts_to_date "${YEARLY_INDEX_DATE_FRMT}" "${DATE}")"
				EPOCH_CHANGED="foobar"
			fi
			if [[ "${EPOCH_CHANGED}" != "" ]]
			then
				EPOCH_CHANGED=""
				cat << EOF >> "${TEMP_TAG_FILE}"

</ul>
<h2>${CURRENT_EPOCH}</h2>
<ul>
EOF
				cat << EOF >> "${TEMP_INDEX_FILE}"
</ul>
<h2>${CURRENT_EPOCH}</h2>
<ul>
EOF
			fi
			FILE_NAME_PART="$(basename "${FILE}" ".${POST_EXTENSION}").html"
			echo "<li><a href='${ROOT_URL}/posts/${FILE_NAME_PART}'>${TITLE}</a> by ${AUTHOR} on ${DATE_PRETTY}</li>" >> "${TEMP_TAG_FILE}"
			echo "<li><a href='${ROOT_URL}/posts/${FILE_NAME_PART}'>${TITLE}</a> by ${AUTHOR} on ${DATE_PRETTY}</li>" >> "${TEMP_INDEX_FILE}"
		fi
	done
	cat << EOF >> "${TEMP_TAG_FILE}"
</ul>
CONTENT_PAGE_FOOTER_HTML([[${ROOT_URL}]], [[${VERSION}]])
END_HTML
EOF
	"${M4}" ${M4_FLAGS} "${TEMP_TAG_FILE}" > "${TAG_FILE}"
	echo "</ul>" >> "${TEMP_INDEX_FILE}"
done
cat << EOF >> "${TEMP_INDEX_FILE}"
CONTENT_PAGE_FOOTER_HTML([[${ROOT_URL}]], [[${VERSION}]])
END_HTML
EOF

"${M4}" ${M4_FLAGS} "${TEMP_INDEX_FILE}" > "${INDEX_FILE}"
rm "${TEMP_INDEX_FILE}" "${TEMP_TAG_FILE}"
