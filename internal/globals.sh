#!/usr/bin/env bash

COMMENT_CODE='///'
TAG_CODE='@@'
PREVIEW_STOP_CODE='{preview-stop}'
TOC_CODE='{toc}'
TITLE_SEPERATOR_CHAR='-'
POST_EXTENSION='bm'
POST_DIR='posts'
M4="$(which m4)"
M4_FLAGS="--prefix-builtins"
MAKE="make"
MAKE_FLAGS="-s"
VERSION="v2.6.0"
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

function op_get {
	OPTION_FILE="$1"
	OP="$2"
	grep --word-regex "${OP}" "${OPTION_FILE}" | cut -f 2
}

function op_set {
	OPTIONS_FILE="$1"
	OP="$2"
	VALUE="$3"
	[[ "${VALUE}" == "" ]] && VALUE="1"
	if [[ ${OP} =~ ^no_ ]]
	then
		OP="${OP#no_}"
		[[ "${VALUE}" == "0" ]] && VALUE="1" || VALUE="0"
	fi
	sed --in-place "/^${OP}\t/d" "${OPTIONS_FILE}"
	echo -e "${OP}\t${VALUE}" >> "${OPTIONS_FILE}"
}

function op_is_set {
	OPTION_FILE="$1"
	OP="$2"
	IS_SET="$(op_get "${OPTION_FILE}" "${OP}")"
	[[ "${IS_SET}" == "" ]] && echo "" || echo "foobar"
}

function parse_options {
	FILE="$1"
	OPTIONS_IN="$(strip_comments "${FILE}" | head -n 4 | tail -n 1)"
	OP_FILE="$(mktemp)"
	for OP_V in $OPTIONS_IN
	do
		OP="$(echo "${OP_V}" | cut -d '=' -f 1)"
		V="$(echo "${OP_V}" | cut -d '=' -f 2)"
		[[ "${OP}" == "${V}" ]] && V="1"
		if [[ ${OP} =~ ^no_ ]]
		then
			OP="${OP#no_}"
			[[ "${V}" == "0" ]] && V="1" || V="0"
		fi
		op_set "${OP_FILE}" "${OP}" "${V}"
	done
	echo "${OP_FILE}"
}

function strip_comments {
	FILE="$1"
	grep --invert-match "^${COMMENT_CODE}" "${FILE}"
}

function get_headers {
	FILE="$1"
	head -n 7 "${FILE}"
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

function file_has_toc_code {
	FILE="$1"
	LINE_COUNT=$(grep --ignore-case "${TOC_CODE}" "${FILE}" | wc -l)
	[[ "${LINE_COUNT}" > 0 ]] && echo "foobar" || echo ""
}

function content_make_tag_links {
	sed -e "s|${TAG_CODE}\([${TAG_ALPHABET}]\+\)|<a href='${ROOT_URL}/tags/\L\1.html'>\E\1</a>|g"
}

function content_will_be_trimmed {
	FILE="$1"
	CONTENT="$(mktemp)"
	get_content "${FILE}" > "${CONTENT}"
	OPTIONS="$(parse_options "${FILE}")"
	PREVIEW_STOP_LINE="$(grep --fixed-strings --line-number "${PREVIEW_STOP_CODE}" "${CONTENT}")"
	if [[ "${PREVIEW_STOP_LINE}" != "" ]]
	then
		echo "foobar"
	else
		local PREVIEW_MAX_WORDS="${PREVIEW_MAX_WORDS}"
		if [[ "$(op_is_set "${OPTIONS}" preview_max_words)" != "" ]]
		then
			PREVIEW_MAX_WORDS="$(op_get "${OPTIONS}" preview_max_words)"
		fi
		WORD_COUNT=0
		while IFS= read DATA
		do
			WORD_COUNT=$((WORD_COUNT+$(echo "${DATA}" | wc -w)))
			if (( "${WORD_COUNT}" >= "${PREVIEW_MAX_WORDS}" ))
			then
				echo "foobar"
				break
			fi
		done < "${CONTENT}"
	fi
	rm "${CONTENT}"
	rm "${OPTIONS}"
}

function trim_content {
	FILE="$1"
	CONTENT="$(mktemp)"
	get_content "${FILE}" > "${CONTENT}"
	OPTIONS="$(parse_options "${FILE}")"
	PREVIEW_STOP_LINE="$(grep --fixed-strings --line-number "${PREVIEW_STOP_CODE}" "${CONTENT}")"
	if [[ "${PREVIEW_STOP_LINE}" != "" ]]
	then
		PREVIEW_STOP_LINE="$(echo "${PREVIEW_STOP_LINE}" | head -n 1 | sed -E 's|^([0-9]+):.*|\1|')"
		head -n "${PREVIEW_STOP_LINE}" "${CONTENT}"
	else
		local PREVIEW_MAX_WORDS="${PREVIEW_MAX_WORDS}"
		if [[ "$(op_is_set "${OPTIONS}" preview_max_words)" != "" ]]
		then
			PREVIEW_MAX_WORDS="$(op_get "${OPTIONS}" preview_max_words)"
		fi
		WORD_COUNT=0
		while IFS= read DATA
		do
			echo "${DATA}"
			WORD_COUNT=$((WORD_COUNT+$(echo "${DATA}" | wc -w)))
			if (( "${WORD_COUNT}" >= "${PREVIEW_MAX_WORDS}" ))
			then
				break
			fi
		done < "${CONTENT}"
	fi
	rm "${CONTENT}" "${OPTIONS}"
}

function get_and_parse_content {
	FILE="$1"
	shift
	DO_TRIM="$1"
	shift
	if [[ "${DO_TRIM}" != "" ]]
	then
		TEMP="$(mktemp)"
		get_headers "${FILE}" > "${TEMP}"
		get_content "${FILE}" | build_toc "${FILE}" >> "${TEMP}"
		trim_content "${TEMP}" | ${MARKDOWN} | content_make_tag_links | parse_out_our_macros
		rm "${TEMP}"
	else
		get_content "${FILE}" | build_toc | ${MARKDOWN} | content_make_tag_links | parse_out_our_macros
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
	elif [ -p /dev/stdin ]
	then
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
	sed -e "s|${PREVIEW_STOP_CODE}||g" | \
	sed -e "s|${TOC_CODE}||g" # shouldn't be necessary as it will have been replaced already
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

function only_pinned_posts {
	ARRAY=( )
	FILE="$1"
	shift
	while [[ "${FILE}" != "" ]]
	do
		OPTIONS="$(parse_options "${FILE}")"
		PINNED="$(op_get "${OPTIONS}" "pinned")"
		if [[ "${PINNED}" != "" ]] && (( "${PINNED}" > "0" ))
		then
			ARRAY["${PINNED}"]="${FILE}"
		fi
		rm "${OPTIONS}"
		FILE="$1"
		shift
	done
	for I in "${!ARRAY[@]}"
	do
		echo "${ARRAY[$I]}"
	done
}

function build_toc {
	IN_FILE="$(mktemp)"
	FILENAME="$1"
	[[ "${FILENAME}" != "" ]] && FILENAME="${ROOT_URL}/posts/$(basename "${FILENAME}" ".${POST_EXTENSION}").html"
	cat > "${IN_FILE}"
	if [[ "$(file_has_toc_code "${IN_FILE}")" != "" ]]
	then
		TEMP_HTML="$(mktemp)"
		cat "${IN_FILE}" | "${MARKDOWN}" > "${TEMP_HTML}"
		HEADINGS=( )
		LINE_NUMBERS=( )
		while read -r LINE
		do
			LINE_NUMBERS+=("$(echo ${LINE} | cut -d ':' -f 1)")
			HEADING="$(echo ${LINE} | cut -d ':' -f 2- | sed 's|<h[[:digit:]]>\(.*\)</h[[:digit:]]>|\1|')"
			HEADING="$(echo "${HEADING}" | to_lower | strip_punctuation | strip_space)"
			WORKING_HEADING="#${HEADING}"
			I="0"
			while [[ " ${HEADINGS[@]} " =~ " ${WORKING_HEADING} " ]]
			do
				I=$((I+1))
				WORKING_HEADING="#${HEADING}-${I}"
			done
			HEADINGS+=(${WORKING_HEADING})
		done < <(grep --line-number "<h[[:digit:]]>" "${TEMP_HTML}")
		I="0"
		for HEADING in ${HEADINGS[@]}
		do
			LINE_NUM="${LINE_NUMBERS["${I}"]}"
			sed --in-place \
				-e "${LINE_NUM}s|<h\([[:digit:]]\)>|<h\1><a href=\'${FILENAME}${HEADING}\'>|" \
				-e "${LINE_NUM}s|</h\([[:digit:]]\)>|</a></h\1>|" \
				"${TEMP_HTML}"
			I=$((I+1))
			#(( "${I}" > "2" )) && break
		done
		TOC="$(grep "<h[[:digit:]]>" "${TEMP_HTML}" |\
			sed 's|<h1>|- |' |\
			sed 's|<h2>|   - |' |\
			sed 's|<h3>|      - |' |\
			sed 's|<h4>|         - |' |\
			sed 's|<h5>|            - |' |\
			sed 's|<h6>|               - |' |\
			sed 's|<h7>|                  - |' |\
			sed 's|<h8>|                     - |' |\
			sed 's|<h9>|                        - |' |\
			sed 's|</h[[:digit:]]>||')"
		TOC_ESCAPED="$(printf '%s\n' "${TOC}" | sed 's|[\/&]|\\&|g;s|$|\\|')"
		TOC_ESCAPED="${TOC_ESCAPED%?}"
		sed "s|${TOC_CODE}|\\n${TOC_ESCAPED}\\n|" "${IN_FILE}"
		rm "${TEMP_HTML}"
	else
		cat "${IN_FILE}"
	fi
	rm "${IN_FILE}"
}
