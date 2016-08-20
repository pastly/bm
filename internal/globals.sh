#!/usr/bin/env bash

COMMENT_CODE='///'
TAG_CODE='@@'
PREVIEW_STOP_CODE='{preview-stop}'
TITLE_SEPERATOR_CHAR='-'
POST_EXTENSION='bm'
POST_DIR='posts'
M4="$(which m4)"
M4_FLAGS="--prefix-builtins"

source include/bm.conf.example
source include/bm.conf

which "Markdown.pl" &> /dev/null
if [[ $? != 0 ]]
then
	MARKDOWN="./internal/Markdown.pl"
	if [ ! -x "${MARKDOWN}" ]
	then
		echo "Markdown.pl not found"
		exit 1
	fi
else
	MARKDOWN="$(which "Markdown.pl")"
fi

[ ! -x "${MARKDOWN}" ] && [ ! -x "internal/Markdown.pl" ] && echo "Markdown.pl not found" && exit 1
[ ! -x "${M4}" ] && echo "m4 not found" && exit 1

function strip_comments {
	FILE="$1"
	grep --invert-match "^${COMMENT_CODE}" "${FILE}"
}

function get_date {
	FILE="$1"
	strip_comments "${FILE}" | \
		head -n 1
}

function get_mod_date {
	FILE="$1"
	strip_comments "${FILE}" | \
		head -n 2 | tail -n 1
}

function get_author {
	FILE="$1"
	strip_comments "${FILE}" | \
		head -n 3 | tail -n 1
}

function get_title {
	FILE="$1"
	strip_comments "${FILE}" | \
		head -n 4 | tail -n 1
}

function get_content {
	FILE="$1"
	strip_comments "${FILE}" | \
		tail -n +5
}

function to_lower {
	while read DATA
	do
		tr '[:upper:]' '[:lower:]' <<< ${DATA}
	done
}

function strip_punctuation {
	while read DATA
	do
		tr -d '[:punct:]' <<< ${DATA}
	done
}

function strip_space {
	while read DATA
	do
		sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' | \
			tr --squeeze-repeats '[:blank:]' "${TITLE_SEPERATOR_CHAR}" \
			<<< ${DATA}
	done
}

function set_editor {
	if [[ -z ${ED} ]]
	then
		echo "\$ED not set."
		while read -p "Enter name of desired text editor: " ED
		do
			which "${ED}" &> /dev/null
			if [[ $? != 0 ]]
			then
				echo "That doesn't seem to be a valid editor."
			else
				break
			fi
		done
	fi
}

function ts_to_date {
	TS="$1"
	date --date="@${TS}" +"${DATE_FRMT}"
}

function get_tags {
	FILE="$1"
	strip_comments "${FILE}" | \
		grep --extended-regexp --only-matching "${TAG_CODE}[[:alnum:]]+" | \
		sed -e "s|${TAG_CODE}||g" | to_lower | \
		sort | uniq
}

function file_has_tag {
	FILE="$1"
	TAG="${TAG_CODE}$2"
	LINE_COUNT=$(grep --ignore-case "${TAG}" "$FILE" | wc -l)
	[[ "${LINE_COUNT}" > 0 ]] && echo "foobar" || echo ""
}

function content_make_tag_links {
	while read DATA
	do
		echo "${DATA}" | sed -e "s|${TAG_CODE}\([[:alnum:]]\+\)|<a href=/tags/\L\1.html>\E\1</a>|g"
	done
}

function content_will_be_trimmed {
	WORD_COUNT=0
	while read DATA
	do
		WORD_COUNT=$((WORD_COUNT+$(echo "${DATA}" | wc -w)))
		COPY_OF_DATA="${DATA//${PREVIEW_STOP_CODE}}"
		if [[ "${COPY_OF_DATA}" != "${DATA}" ]]
		then
			echo "foobar"
			break
		fi
		if [ "${WORD_COUNT}" -ge "${PREVIEW_MAX_WORDS}" ]
		then
			echo "foobar"
		fi
	done
}

function content_trim_for_preview {
	WORD_COUNT=0
	while read DATA
	do
		WORD_COUNT=$((WORD_COUNT+$(echo "${DATA}" | wc -w)))
		COPY_OF_DATA="${DATA//${PREVIEW_STOP_CODE}}"
		if [[ "${COPY_OF_DATA}" != "${DATA}" ]]
		then
			echo "${COPY_OF_DATA}"
			break
		else
			echo "${DATA}"
		fi
		if [ "${WORD_COUNT}" -ge "${PREVIEW_MAX_WORDS}" ]
		then
			break
		fi
	done
}

function sort_by_date {
	# If sending file names in via stdin,
	# they must be \0 delimited
	ARRAY=( )
	if [ ! -z "$1" ]
	then
		FILE="$1"
		shift
		while [[ "${FILE}" != "" ]]
		do
			DATE="$(get_date "${FILE}")"
			ARRAY["${DATE}"]="${FILE}"
			FILE="$1"
			shift
		done
	else
		while read -d '' FILE
		do
			DATE="$(get_date "${FILE}")"
			ARRAY["${DATE}"]="${FILE}"
		done
	fi
	for I in "${!ARRAY[@]}"
	do
		echo "${ARRAY[$I]}"
	done
}

function parse_out_our_macros {
	while read DATA
	do
		echo "${DATA}" | sed -e "s|${PREVIEW_STOP_CODE}||g"
	done
}
