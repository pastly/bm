#!/usr/bin/env bash

COMMENT_CODE='##'
TAG_CODE='@@'
TITLE_SEPERATOR_CHAR='-'
POST_EXTENSION='bbg'
POST_DIR='posts'
ED="${EDITOR}"
MARKDOWN="$(which Markdown.pl)"
M4="$(which m4)"
M4_FLAGS="--prefix-builtins"

[ ! -x "${MARKDOWN}" ] && echo "Markdown.pl not found" && exit 1
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

function get_title {
	FILE="$1"
	strip_comments "${FILE}" | \
		head -n 2 | tail -n 1
}

function get_content {
	FILE="$1"
	strip_comments "${FILE}" | \
		tail -n +3

}

function to_lower {
	while read DATA
	do
		tr '[:upper:]' '[:lower:]' <<< ${DATA}
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
	if [[ -z ${EDITOR} ]]
	then
		echo "\$EDITOR not set."
		read -p "Enter name of desired text editor: " ED
		which "${ED}" &> /dev/null
		[[ $? != 0 ]] && exit
	else
		ED="$(which ${EDITOR})"
	fi
}

function get_tags {
	FILE="$1"
	strip_comments "${FILE}" | \
		grep --extended-regexp --only-matching "${TAG_CODE}[[:alnum:]]+" | \
		sort | uniq | to_lower
}

function content_make_tag_links {
	while read DATA
	do
		echo "${DATA}" | sed -e 's|@@\([[:alnum:]]\+\)|<a href=/tags/\L\1>\E\1</a>|g'
	done
}
