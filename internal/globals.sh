#!/usr/bin/env bash

COMMENT_CODE='///'
TAG_CODE='@@'
PREVIEW_STOP_CODE='{preview-stop}'
TITLE_SEPERATOR_CHAR='-'
POST_EXTENSION='bm'
POST_DIR='posts'
M4="$(which m4)"
M4_FLAGS="--prefix-builtins"
MAKE="make"
MAKE_FLAGS="-s"
VERSION="v2.3.0"
TAG_ALPHABET="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-"
ID_ALPHABET="123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz"
KNOWN_HASH_PROGRAMS="sha1sum sha1 sha256sum sha256 md5sum md5 cat"

source include/bm.conf.example
[[ -f include/bm.conf ]] && source include/bm.conf

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

which git &> /dev/null
if [[ $? == 0 ]]
then
	VERSION="${VERSION} ($(git rev-parse --short HEAD))"
#else
#	VERSION="${VERSION} (release)"
fi

which "${MAKE}" &> /dev/null
[[ $? != 0 ]] && echo "make not found" && exit 1

[ ! -x "${MARKDOWN}" ] && echo "Markdown.pl not found" && exit 1
[ ! -x "${M4}" ] && echo "m4 not found" && exit 1

[[ "${MULTI_MATCH_STRAT}" == "" ]] && MULTI_MATCH_STRAT="simple"
[[ "${DEFAULT_INDEX_BY}" == "" ]] && DEFAULT_INDEX_BY="none"
[[ "${POST_INDEX_BY}" == "" ]] && POST_INDEX_BY="${DEFAULT_INDEX_BY}"
[[ "${TAG_INDEX_BY}" == "" ]] && TAG_INDEX_BY="${DEFAULT_INDEX_BY}"
[[ "${SIGNIFICANT_MOD_AFTER}" == "" ]] && SIGNIFICANT_MOD_AFTER="1" || \
	SIGNIFICANT_MOD_AFTER="$((${SIGNIFICANT_MOD_AFTER}))"
[[ "${CREATE_HELP_VERBOSITY}" == "" ]] && CREATE_HELP_VERBOSITY="long"
[[ "${REBUILD_POLICY}" == "" ]] && REBUILD_POLICY="asap"

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

function get_id {
	FILE="$1"
	strip_comments "${FILE}" | \
		head -n 3 | tail -n 1
}

function get_author {
	FILE="$1"
	strip_comments "${FILE}" | \
		head -n 6 | tail -n 1
}

function get_title {
	FILE="$1"
	strip_comments "${FILE}" | \
		head -n 7 | tail -n 1
}

function get_content {
	FILE="$1"
	strip_comments "${FILE}" | \
		tail -n +8
}

function to_lower {
	tr '[:upper:]' '[:lower:]'
}

function strip_punctuation {
	tr -d '[:punct:]'
}

function strip_space {
	sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' | \
		tr --squeeze-repeats '[:blank:]' "${TITLE_SEPERATOR_CHAR}"
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
	FRMT="$1"
	shift
	if [ ! -z "$1" ]
	then
		TS="$1"
		shift
	else
		read TS
	fi
	date --date="@${TS}" +"${FRMT}"
}

function get_tags {
	FILE="$1"
	strip_comments "${FILE}" | \
		grep --extended-regexp --only-matching "${TAG_CODE}[${TAG_ALPHABET}]+" | \
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
	sed -e "s|${TAG_CODE}\([${TAG_ALPHABET}]\+\)|<a href='${ROOT_URL}/tags/\L\1.html'>\E\1</a>|g"
}

function content_will_be_trimmed {
	# while this function takes a file for an argument, it should *not*
	# be a full post file. It should be a temporary file containing only
	# the content.
	FILE="$1"
	PREVIEW_STOP_LINE="$(grep --fixed-strings --line-number "${PREVIEW_STOP_CODE}" "${FILE}")"
	if [[ "${PREVIEW_STOP_LINE}" != "" ]]
	then
		echo "foobar"
	else
		WORD_COUNT=0
		while IFS= read DATA
		do
			WORD_COUNT=$((WORD_COUNT+$(echo "${DATA}" | wc -w)))
			if [ "${WORD_COUNT}" -ge "${PREVIEW_MAX_WORDS}" ]
			then
				echo "foobar"
				break
			fi
		done < "${FILE}"
	fi
}

function trim_content {
	# while this function takes a file for an argument, it should *not*
	# be a full post file. It should be a temporary file containing only
	# the content.
	FILE="$1"
	PREVIEW_STOP_LINE="$(grep --fixed-strings --line-number "${PREVIEW_STOP_CODE}" "${FILE}")"
	if [[ "${PREVIEW_STOP_LINE}" != "" ]]
	then
		PREVIEW_STOP_LINE="$(echo "${PREVIEW_STOP_LINE}" | head -n 1 | sed -E 's|^([0-9]+):.*|\1|')"
		head -n "${PREVIEW_STOP_LINE}" "${FILE}"
	else
		WORD_COUNT=0
		while IFS= read DATA
		do
			echo "${DATA}"
			WORD_COUNT=$((WORD_COUNT+$(echo "${DATA}" | wc -w)))
			if [ "${WORD_COUNT}" -ge "${PREVIEW_MAX_WORDS}" ]
			then
				break
			fi
		done < "${FILE}"
	fi
}

function get_and_parse_content {
	FILE="$1"
	shift
	DO_TRIM="$1"
	shift
	if [[ "${DO_TRIM}" != "" ]]
	then
		TEMP="$(mktemp)"
		get_content "${FILE}" > "${TEMP}"
		trim_content "${TEMP}" | ${MARKDOWN} | content_make_tag_links | parse_out_our_macros
		rm "${TEMP}"
	else
		get_content "${FILE}" | ${MARKDOWN} | content_make_tag_links | parse_out_our_macros
	fi
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

function get_hash_program {
	for PROGRAM in ${KNOWN_HASH_PROGRAMS} # No quotes on purpose
	do
		which ${PROGRAM} &> /dev/null
		if [[ "$?" == "0" ]]
		then
			echo "${PROGRAM}"
			break
		fi
	done
}

function hash_data {
	if [[ "${HASH_PROGRAM}" == "" ]]
	then
		HASH_PROGRAM=$(get_hash_program)
		if [[ "${HASH_PROGRAM}" == "" ]]
		then
			echo "Couldn't find any of: ${KNOWN_HASH_PROGRAMS}"
			echo "You need one, or to set HASH_PROGRAM to something which can"
			echo "hash data given on stdin for bm to work."
			exit 1
		fi
	fi
	${HASH_PROGRAM}
}

function parse_out_our_macros {
	sed -e "s|${PREVIEW_STOP_CODE}||g"
}

function generate_id {
	cat /dev/urandom | tr -cd "${ID_ALPHABET}" | head -c 8
}

function pretty_print_post_info {
	FILE="$1"
	echo "$(get_date "${FILE}" | ts_to_date "${DATE_FRMT}") (id=$(get_id "${FILE}")): $(get_title "${FILE}")"
}

# args: search terms
# returns 0 or more matched post file names
function search_posts {
	[[ ! -d "${POST_DIR}" ]] && return
	# valid TYPEs are 'both' and 'title'
	# where 'both' means title and post id
	[[ "$1" == "$@" ]] && TYPE="both" || TYPE="title"
	if [[ "${TYPE}" == "both" ]]
	then
		POSTS="$(search_posts_by_id "$@")"
		[[ "${POSTS}" != "" ]] && echo "${POSTS}" && return
		POSTS="$(search_posts_by_title "$@")"
		[[ "${POSTS}" != "" ]] && echo "${POSTS}" && return
	else
		POSTS="$(search_posts_by_title "$@")"
		[[ "${POSTS}" != "" ]] && echo "${POSTS}" && return
	fi
}

# args: search term
# returns 0 or 1 matched post file names
function search_posts_by_id {
	[[ "$1" != "$@" ]] && return
	[[ "$1" == "" ]] && return
	while read FILE
	do
		ID="$(get_id "${FILE}")"
		if [[ $ID =~ ^.*$1.*$ ]]
		then
			[[ "${POSTS}" != "" ]] && POSTS="${POSTS} ${FILE}" || POSTS="${FILE}"
		fi
	done < <(find "${POST_DIR}" -type f -name "*.${POST_EXTENSION}")
	COUNT="$(echo "${POSTS}" | wc -w)"
	[[ "${COUNT}" != "1" ]] && return
	echo "${POSTS}"
}

# args: search terms
# returns 0 or more matched post file names sorted by date
function search_posts_by_title {
	[[ "$1" == "" ]] && return
	while read FILE
	do
		TERMS="$(echo "$@" | to_lower | strip_punctuation | strip_space)"
		TITLE="$(get_title "${FILE}" | to_lower | strip_punctuation | strip_space)"
		if [[ $TITLE =~ ^.*${TERMS}.*$ ]]
		then
			[[ "${POSTS}" != "" ]] && POSTS="${POSTS} ${FILE}" || POSTS="${FILE}"
		fi
	done < <(find "${POST_DIR}" -type f -name "*.${POST_EXTENSION}")
	COUNT="$(echo "${POSTS}" | wc -w)"
	(( "${COUNT}" < "1" )) && return
	sort_by_date ${POSTS}
}
