#!/usr/bin/env bash
# Variable gathering and setting all needs to be auto-exported
set -a

################################################################################
# define some variables that shouldn't be configurable
################################################################################
COMMENT_CODE='///'
TAG_CODE='@@'
PREVIEW_STOP_CODE='{preview-stop}'
TOC_CODE='{toc}'
TITLE_SEPARATOR_CHAR='-'
POST_EXTENSION='bm'
POST_DIR='posts'
BUILD_DIR="build"
METADATA_DIR="meta"
THEME_DIR="themes"
STATIC_DIR="static"
THEME_SYMLINK="${THEME_DIR}/selected"
BUILT_POST_DIR="${BUILD_DIR}/posts"
BUILT_SHORT_POST_DIR="${BUILD_DIR}/p"
BUILT_TAG_DIR="${BUILD_DIR}/tags"
BUILT_STATIC_DIR="${BUILD_DIR}/static"
VERSION="v5.0.0"
TAG_ALPHABET="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-"
ID_ALPHABET="123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz"
KNOWN_HASH_PROGRAMS="sha1sum sha1 sha256sum sha256 md5sum md5 cat"
RSS_DATE_FRMT="%a, %d %b %Y %T %Z"

################################################################################
# import more function definitions
################################################################################
source internal/options.sh

################################################################################
# get and validate all options
################################################################################
source internal/set-defaults.sh

################################################################################
# check for required directories (that even make needs)
################################################################################
[ ! -e "${THEME_SYMLINK}" ] && ln -s default "${THEME_SYMLINK}"
[ ! -d "${STATIC_DIR}" ] && mkdir "${STATIC_DIR}"

################################################################################
# now that options are validated, all required programs definitions can be made
# and required programs checked for
################################################################################
source internal/set-programs.sh

################################################################################
# if git is available, elaborate on the version
################################################################################
if which git &> /dev/null
then
	VERSION="${VERSION} ($(git rev-parse --short HEAD))"
fi

################################################################################
# function definitions
################################################################################
function build_404 {
	cat << EOF
START_CONTENT
<h1>404 Not Found</h1>
<p>It seems you've stumbled upon a bad link. Perhaps these will help you.</p>
<a href='${ROOT_URL}/'>Homepage</a><br/>
<a href='${ROOT_URL}/posts/index.html'>All posts</a><br/>
END_CONTENT
EOF
}

# valid options are: "for-preview"
function build_content_header {
	POST="$1" && shift
	OPTS=( "$@" )
	HEADERS="${METADATA_DIR}/${POST}/headers"
	OPTIONS="${METADATA_DIR}/${POST}/options"
	TITLE="$(get_title "${HEADERS}")"
	POST_FILE="$(echo "${TITLE}" | title_to_post_url)${TITLE_SEPARATOR_CHAR}${POST}.html"
	[[ "${PREFER_SHORT_POSTS}" == "yes" ]] &&
		POST_LINK="${ROOT_URL}/p/${POST}.html" ||
		POST_LINK="${ROOT_URL}/posts/${POST_FILE}"
	(( "${#OPTS[@]}" > 0 )) && [[ " ${OPTS[@]} " =~ " for-preview " ]] &&
		TITLE="<a href='${POST_LINK}'>${TITLE}</a>"
	DATE="$(get_date "${HEADERS}")"
	MOD_DATE="$(get_mod_date "${HEADERS}")"
	(( "$((${MOD_DATE}-${DATE}))" > "${SIGNIFICANT_MOD_AFTER}" )) &&
		MOD_DATE="$(ts_to_date "${LONG_DATE_FRMT}" "${MOD_DATE}")" ||
		MOD_DATE=
	DATE="$(ts_to_date "${DATE_FRMT}" "${DATE}")"
	AUTHOR="$(get_author "${HEADERS}")"
	ID="$(get_id "${HEADERS}")"
	[[ "${MAKE_SHORT_POSTS}" == "yes" ]] &&
		PERMALINK="${ROOT_URL}/p/$(get_id "${HEADERS}").html" ||
		PERMALINK=
	IS_PINNED="$(op_get "${OPTIONS}" pinned)"
	(( "${#OPTS[@]}" > 0 )) && [[ " ${OPTS[@]} " =~ " for-preview " ]] &&
		[[ "${IS_PINNED}" != "" ]] &&
		IS_PINNED="foobar" ||
		IS_PINNED=""
	cat << EOF
POST_HEADER(${TITLE},${AUTHOR},${DATE},${MOD_DATE},${PERMALINK},${IS_PINNED})
EOF
}

function build_index {
	POSTS="$1"
	PINNED_POSTS="$(mktemp)"
	UNPINNED_POSTS="$(mktemp)"
	INCLUDED_POSTS=( )
	INCLUDED_POSTS_INDEX="0"
	only_pinned_posts "${POSTS}" > "${PINNED_POSTS}"
	only_unpinned_posts "${POSTS}" > "${UNPINNED_POSTS}"
	for POST in $(cat "${PINNED_POSTS}") $(tac "${UNPINNED_POSTS}" | head -n "${POSTS_ON_HOMEPAGE}")
	do
		echo "START_CONTENT"
		HEADERS="${METADATA_DIR}/${POST}/headers"
		CONTENT="${METADATA_DIR}/${POST}/previewcontent"
		TITLE="$(get_title "${HEADERS}")"
		POST_FILE="$(echo "${TITLE}" | title_to_post_url)${TITLE_SEPARATOR_CHAR}${POST}.html"
		[[ "${PREFER_SHORT_POSTS}" == "yes" ]] &&
			POST_LINK="${ROOT_URL}/p/${POST}.html" ||
			POST_LINK="${ROOT_URL}/posts/${POST_FILE}"
		[[ "$(cat "${METADATA_DIR}/${POST}/previewcontent" | hash_data)" != \
			"$(cat "${METADATA_DIR}/${POST}/content" | hash_data)" ]] &&
			CONTENT_IS_TRIMMED="foobar" ||
			CONTENT_IS_TRIMMED=""
		build_content_header "${POST}" "for-preview"
		< "${CONTENT}" \
		pre_markdown "$(get_id "${HEADERS}")" |\
		${MARKDOWN} ${MARKDOWN_FLAGS} |\
		post_markdown "$(get_id "${HEADERS}")" "for-preview"
		[[ "${CONTENT_IS_TRIMMED}" != "" ]] &&
			echo "<a href='${POST_LINK}'><em>Read the entire post</em></a>"
		echo "END_CONTENT"

		INCLUDED_POSTS["${INCLUDED_POSTS_INDEX}"]="${POST}"
		INCLUDED_POSTS_INDEX=$((INCLUDED_POSTS_INDEX+1))
	done
	rm "${PINNED_POSTS}" "${UNPINNED_POSTS}"
}

function build_page_foot {
	echo "PAGE_FOOTER"
}

function build_page_head {
	echo "PAGE_HEADER"
}

function build_postindex {
	ALL_POSTS=( $(find "${METADATA_DIR}/" -mindepth 2 -type f -name headers) )
	ALL_POSTS=( $(sort_by_date ${ALL_POSTS[@]} | tac) )
	CURRENT_EPOCH=
	echo "START_CONTENT"
	echo "<h1>Posts</h1>"
	echo "<ul>"
	for P in ${ALL_POSTS[@]}
	do
		ID="$(basename $(dirname "${P}"))"
		TITLE="$(get_title "${P}")"
		[[ "${PREFER_SHORT_POSTS}" == "yes" ]] &&
			LINK="/p/${ID}.html" ||
			LINK="/posts/$(echo "${TITLE}" | title_to_post_url)${TITLE_SEPARATOR_CHAR}${ID}.html"
		AUTHOR="$(get_author "${P}")"
		DATE="$(get_date "${P}")"
		DATE_PRETTY="$(ts_to_date "${DATE_FRMT}" "${DATE}")"
		if [[ "${POST_INDEX_BY}" == "month" ]] && [[ "$(ts_to_date "${MONTHLY_INDEX_DATE_FRMT}" "${DATE}")" != "${CURRENT_EPOCH}" ]]
		then
			CURRENT_EPOCH="$(ts_to_date "${MONTHLY_INDEX_DATE_FRMT}" "${DATE}")"
			echo "</ul>"
			echo "<h2>${CURRENT_EPOCH}</h2>"
			echo "<ul>"
		elif [[ "${POST_INDEX_BY}" == "year" ]] && [[ "$(ts_to_date "${YEARLY_INDEX_DATE_FRMT}" "${DATE}")" != "${CURRENT_EPOCH}" ]]
		then
			CURRENT_EPOCH="$(ts_to_date "${YEARLY_INDEX_DATE_FRMT}" "${DATE}")"
			echo "</ul>"
			echo "<h2>${CURRENT_EPOCH}</h2>"
			echo "<ul>"
		fi
		echo "<li><a href='${LINK}'>${TITLE}</a> by ${AUTHOR} on ${DATE_PRETTY}</li>"
	done
	echo "</ul>"
	echo "END_CONTENT"
}

function build_tagindex {
	TMP_TAG_FILE="$(mktemp)"
	ALL_TAGS=( $(cat "${METADATA_DIR}/tags") )
	# first get all post headers
	TMP=( $(find "${METADATA_DIR}/" -mindepth 2 -type f -name headers) )
	# then sort the headers by date
	TMP=( $(sort_by_date ${TMP[@]} | tac) )
	# then change from headers to tags
	ALL_POSTS=( )
	for P in ${TMP[@]}; do ALL_POSTS[${#ALL_POSTS[@]}]="$(dirname ${P})/tags"; done
	# finally, build page
	echo "START_CONTENT"
	(( "${#ALL_TAGS[@]}" > 0 )) &&
		for T in ${ALL_TAGS[@]}
		do
			CURRENT_EPOCH=
			TAG_FILE="${BUILT_TAG_DIR}/${T}.html"
			echo "m4_include(${THEME_SYMLINK}/html.m4)" >> "${TMP_TAG_FILE}"
			echo "START_HTML([[${T} - ${BLOG_TITLE}]])" >> "${TMP_TAG_FILE}"
			echo "PAGE_HEADER" >> "${TMP_TAG_FILE}"
			echo "START_CONTENT" >> "${TMP_TAG_FILE}"
			echo "<h1>${T}</h1>" | tee -a "${TMP_TAG_FILE}"
			echo "<ul>" | tee -a "${TMP_TAG_FILE}"
			for P in ${ALL_POSTS[@]}
			do
				if grep --quiet --line-regexp "${T}" "${P}"
				then
					ID="$(basename $(dirname "${P}"))"
					HEADERS="${METADATA_DIR}/${ID}/headers"
					DATE="$(get_date "${HEADERS}")"
					DATE_PRETTY="$(ts_to_date "${DATE_FRMT}" "$(get_date "${HEADERS}")")"
					if [[ "${TAG_INDEX_BY}" == "month" ]] && [[ "$(ts_to_date "${MONTHLY_INDEX_DATE_FRMT}" "${DATE}")" != "${CURRENT_EPOCH}" ]]
					then
						CURRENT_EPOCH="$(ts_to_date "${MONTHLY_INDEX_DATE_FRMT}" "${DATE}")"
						echo "</ul>" | tee -a "${TMP_TAG_FILE}"
						echo "<h2>${CURRENT_EPOCH}</h2>" | tee -a "${TMP_TAG_FILE}"
						echo "<ul>" | tee -a "${TMP_TAG_FILE}"
					elif [[ "${TAG_INDEX_BY}" == "year" ]] && [[ "$(ts_to_date "${YEARLY_INDEX_DATE_FRMT}" "${DATE}")" != "${CURRENT_EPOCH}" ]]
					then
						CURRENT_EPOCH="$(ts_to_date "${YEARLY_INDEX_DATE_FRMT}" "${DATE}")"
						echo "</ul>" | tee -a "${TMP_TAG_FILE}"
						echo "<h2>${CURRENT_EPOCH}</h2>" | tee -a "${TMP_TAG_FILE}"
						echo "<ul>" | tee -a "${TMP_TAG_FILE}"
					fi
					TITLE="$(get_title "${HEADERS}")"
					if [[ "${PREFER_SHORT_POSTS}" == "yes" ]]
					then
						LINK="/p/${ID}.html"
					else
						LINK="/posts/$(echo "${TITLE}" | title_to_post_url)${TITLE_SEPARATOR_CHAR}${ID}.html"
					fi
					AUTHOR="$(get_author "${HEADERS}")"
					echo "<li><a href='${LINK}'>${TITLE}</a> by ${AUTHOR} on ${DATE_PRETTY}</li>" | tee -a "${TMP_TAG_FILE}"
				fi
			done
		echo "</ul>" | tee -a "${TMP_TAG_FILE}"
		echo "END_CONTENT" >> "${TMP_TAG_FILE}"
		echo "PAGE_FOOTER" >> "${TMP_TAG_FILE}"
		echo "END_HTML" >> "${TMP_TAG_FILE}"
		cat "${TMP_TAG_FILE}" | "${M4}" ${M4_FLAGS} > "${TAG_FILE}"
		echo "" > "${TMP_TAG_FILE}"
		[[ "${GPG_SIGN_PAGES}" == "yes" ]] && \
			</dev/null "${GPG}" ${GPG_SIGN_FLAGS} "${TAG_FILE}"
	done
	echo "END_CONTENT"
	rm "${TMP_TAG_FILE}"
}

function end_html {
	echo "END_HTML"
}

function file_has_toc_code {
	FILE="$1"
	LINE_COUNT=$(strip_comments "${FILE}" | grep --ignore-case "${TOC_CODE}" | wc -l)
	[[ "${LINE_COUNT}" > 0 ]] && echo "foobar" || echo ""
}

function generate_id {
	cat /dev/urandom | tr -cd "${ID_ALPHABET}" | head -c 8
}

function get_author {
	FILE="$1"
	strip_comments "${FILE}" | \
		head -n 6 | tail -n 1
}

function get_content {
	FILE="$1"
	strip_comments "${FILE}" | \
		tail -n +8
}

function get_date {
	FILE="$1"
	strip_comments "${FILE}" | \
		head -n 1
}

function get_hash_program {
	for PROGRAM in ${KNOWN_HASH_PROGRAMS} # No quotes on purpose
	do
		if which ${PROGRAM} &> /dev/null
		then
			echo "${PROGRAM}"
			break
		fi
	done
}

function get_headers {
	FILE="$1"
	head -n 7 "${FILE}"
}

function get_id {
	FILE="$1"
	strip_comments "${FILE}" | \
		head -n 3 | tail -n 1
}

function get_mod_date {
	FILE="$1"
	strip_comments "${FILE}" | \
		head -n 2 | tail -n 1
}

function get_preview_content {
	CONTENT="$1"
	shift
	OPTIONS="$1"
	shift
	PREVIEW_STOP_LINE="$(grep --fixed-strings --line-number "${PREVIEW_STOP_CODE}" "${CONTENT}")"
	if [[ "${PREVIEW_STOP_LINE}" != "" ]]
	then
		PREVIEW_STOP_LINE="$(echo "${PREVIEW_STOP_LINE}" | head -n 1 | sed -E 's|^([0-9]+):.*|\1|')"
		head -n "${PREVIEW_STOP_LINE}" "${CONTENT}" | sed 's|{preview-stop}||'
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
}

function get_tags {
	FILE="$1"
	cat ${FILE} | grep --extended-regexp --only-matching "${TAG_CODE}[${TAG_ALPHABET}]+" | \
		sed -e "s|${TAG_CODE}||g" | to_lower | \
		sort | uniq
}

function get_title {
	FILE="$1"
	strip_comments "${FILE}" | \
		head -n 7 | tail -n 1
}

function get_toc {
	FILE="$1"
	[[ "$(file_has_toc_code "${FILE}")" == "" ]] && return
	TEMP_HTML="$(mktemp)"
	< "${FILE}" "${MARKDOWN}" ${MARKDOWN_FLAGS} > "${TEMP_HTML}"
	HEADINGS=( )
	LINE_NUMBERS=( )
	while read -r LINE
	do
		LINE_NUMBERS+=("$(echo ${LINE} | cut -d ':' -f 1)")
		HEADING="$(echo ${LINE} | cut -d ':' -f 2- |\
			sed 's|<h[[:digit:]]>\(.*\)</h[[:digit:]]>|\1|' |\
			title_to_heading_id)"
		WORKING_HEADING="#${HEADING}"
		if [[ -z ${!HEADINGS[@]} ]]
		then
			HEADINGS+=(${WORKING_HEADING})
		else
			I="0"
			while [[ " ${HEADINGS[@]} " =~ " ${WORKING_HEADING} " ]]
			do
				I=$((I+1))
				WORKING_HEADING="#${HEADING}-${I}"
			done
			HEADINGS+=(${WORKING_HEADING})
		fi
	done < <(grep --line-number "<h[[:digit:]]>" "${TEMP_HTML}")
	[[ -z ${!HEADINGS[@]} ]] && rm "${TEMP_HTML}" && return
	I="0"
	for HEADING in ${HEADINGS[@]}
	do
		LINE_NUM="${LINE_NUMBERS["${I}"]}"
		sed --in-place \
			-e "${LINE_NUM}s|<h\([[:digit:]]\)>|<h\1><a href=\'${HEADING}\'>|" \
			-e "${LINE_NUM}s|</h\([[:digit:]]\)>|</a></h\1>|" \
			"${TEMP_HTML}"
		I=$((I+1))
		#(( "${I}" > "2" )) && break
	done
	grep "<h[[:digit:]]>" "${TEMP_HTML}" |\
	sed 's|<h1>|- |' |\
	sed 's|<h2>|   - |' |\
	sed 's|<h3>|      - |' |\
	sed 's|<h4>|         - |' |\
	sed 's|<h5>|            - |' |\
	sed 's|<h6>|               - |' |\
	sed 's|<h7>|                  - |' |\
	sed 's|<h8>|                     - |' |\
	sed 's|<h9>|                        - |' |\
	sed 's|</h[[:digit:]]>||'
	rm "${TEMP_HTML}"
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

# give this function a file name containing all post ids
# it echos the ids of pinned posts in the correct order
function only_pinned_posts {
	ARRAY=( )
	for ID in $(cat $1)
	do
		OPTIONS="${METADATA_DIR}/${ID}/options"
		PINNED="$(op_get "${OPTIONS}" "pinned")"
		if [[ "${PINNED}" != "" ]] && (( "${PINNED}" > "0" ))
		then
			ARRAY["${PINNED}"]="${ID}"
		fi
	done
	for I in "${!ARRAY[@]}"
	do
		echo "${ARRAY[$I]}"
	done
}

# give this function a file name containing all post ids
# it calls only_pinned_posts and echos post ids that aren't pinned
function only_unpinned_posts {
	PINNED=( $(only_pinned_posts $1) )
	(( "${#PINNED[@]}" < "1" )) &&
		cat $1 && return
	for ID in $(cat $1)
	do
		[[ ! " ${PINNED[@]} " =~ " ${ID} " ]] \
			&& echo "${ID}"
	done
}

# Parses the options in FILE into OP_FILE and returns the contents of OP_FILE.
function parse_options {
	FILE="$1"
	OPTIONS_IN="$(head -n 4 "${FILE}" | tail -n 1)"
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
	cat "${OP_FILE}"
	rm "${OP_FILE}"
}

# first arg is the post id
# remaining args are options
# valid options are: "for-preview"
function post_markdown {
	TMP1="$(mktemp)"
	TMP2="$(mktemp)"
	ID="$1" && shift
	OPTS=( "$@" )
	# 1: make tags into links

	sed -e "s|${TAG_CODE}\([${TAG_ALPHABET}]\+\)|<a href='${ROOT_URL}/tags/\L\1.html'>\E\1</a>|g" > "${TMP1}"

	# 2: remove various macros

	cat "${TMP1}" | \
		sed -e "s|${PREVIEW_STOP_CODE}||g" | \
		sed -e "s|${TOC_CODE}||g" > "${TMP2}" # TOC_CODE shouldn't be necessary as it will have been replaced already

	# 3: make heading ids if needed

	OPTIONS="${METADATA_DIR}/${ID}/options"
	if [[ "$(op_is_set "${OPTIONS}" heading_ids)" == "" ]]
	then
		cat "${TMP2}" > "${TMP1}"
	else
		HEADINGS=( )
		while read LINE
		do
			if [[ "$(echo "${LINE}" | grep "^<h[[:digit:]]>.*</h[[:digit:]]>" )" == "" ]]
			then
				echo "${LINE}"
				continue
			fi
			HEADING="$(echo ${LINE} | sed 's|^<h[[:digit:]]>\(.*\)</h[[:digit:]]>|\1|')"
			HEADING="$(echo "${HEADING}" | title_to_heading_id)"
			WORKING_HEADING="${HEADING}"
			I="0"
			while (( "${#HEADINGS[@]}" > "0" )) && [[ " ${HEADINGS[@]} " =~ " ${WORKING_HEADING} " ]]
			do
				I=$((I+1))
				WORKING_HEADING="${HEADING}-${I}"
			done
			HEADINGS+=(${WORKING_HEADING})
			echo "${LINE}" | sed \
				-e "s|^<h\([[:digit:]]\)>|<h\1 id=\'${WORKING_HEADING}'>|" \
				-e "s|</h\([[:digit:]]\)>|</h\1>|"
		done < "${TMP2}" > "${TMP1}"
	fi

	# 4: make relative #section-links into absolute #section-links
	# like for the table of contents

	if (( "${#OPTS[@]}" > 0 )) && [[ " ${OPTS[@]} " =~ " for-preview " ]]
	then
		[[ "${PREFER_SHORT_POSTS}" == "yes" ]] && \
			LINK="/p/${ID}.html" || \
			LINK="/posts/$(get_title "${METADATA_DIR}/${ID}/headers" | title_to_post_url)${TITLE_SEPARATOR_CHAR}${ID}.html"
		sed "s|\(<a href=['\"]\)\(#.*\)|\1${LINK}\2|" "${TMP1}" > "${TMP2}"
	else
		cat "${TMP1}" > "${TMP2}"
	fi

	# DONE

	cat "${TMP2}" # output the final temp file. Odd num of steps means tmp1
	rm "${TMP1}" "${TMP2}"
}

function pre_markdown {
	ID="$1"
	METADATA="${METADATA_DIR}/${ID}"

	# 1: do table of contents

	TOC="$(cat "${METADATA}/toc")"
	# Somehow this works to allow sed to replace '{toc}' (single line) with
	# ${TOC_ESCAPED} (many lines)
	TOC_ESCAPED="$(printf '%s\n' "${TOC}" | sed 's|[\/&]|\\&|g;s|$|\\|')"
	TOC_ESCAPED="${TOC_ESCAPED%?}"
	sed "s|${TOC_CODE}|\\n${TOC_ESCAPED}\\n|"
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

function set_editor {
	if [[ "${ED}" == "" ]]
	then
		echo "\$ED not set."
		while read -p "Enter name of desired text editor: " ED
		do
			if ! which "${ED}" &> /dev/null
			then
				echo "That doesn't seem to be a valid editor."
			else
				break
			fi
		done
	fi
}

function start_html {
	TITLE="$1"
	echo "m4_include(${THEME_SYMLINK}/html.m4)"
	echo "START_HTML(${TITLE})"
}

function start_rss {
	echo "<?xml version='1.0' encoding='utf-8' ?>"
	echo "<rss version='2.0' xmlns:atom='http://www.w3.org/2005/Atom'>"
	echo "<channel>"
	echo "<title>$RSS_TITLE</title>"
	echo "<link>$RSS_HOST</link>"
	echo "<description>$RSS_DESCRIPTION</description>"
	echo "<atom:link href='${RSS_HOST}${ROOT_URL}/feed.rss' rel='self' type='application/rss+xml' />"
}

function end_rss {
	echo "</channel>"
	echo "</rss>"
}

function rss_item_for_post {
	POST="$1"
	HEADERS="${METADATA_DIR}/${POST}/headers"
	OPTIONS="${METADATA_DIR}/${POST}/options"
	TITLE="$(get_title "${HEADERS}")"
	POST_FILE="$(echo "${TITLE}" | title_to_post_url)${TITLE_SEPARATOR_CHAR}${POST}.html"
	[[ "${PREFER_SHORT_POSTS}" == "yes" ]] &&
		POST_LINK="${RSS_HOST}${ROOT_URL}/p/${POST}.html" ||
		POST_LINK="${RSS_HOST}${ROOT_URL}/posts/${POST_FILE}"
	DATE="$(get_date "${HEADERS}")"
	DATE="$(ts_to_date "${RSS_DATE_FRMT}" "${DATE}")"
	echo "<item>"
	echo "<title>$(get_title ${HEADERS})</title>"
	echo "<link>$POST_LINK</link>"
	echo "<guid isPermaLink='false'>$POST</guid>"
	echo "<pubDate>$DATE</pubDate>"
	echo "</item>"
}

function sort_by_date {
	# If sending file names in via stdin,
	# they must be \0 delimited
	ARRAY=( )
	if [[ $# -ge 1 ]]
	then
		FILE="$1"
		shift
		while [ 1 ]
		do
			DATE="$(get_date "${FILE}")"
			ARRAY["${DATE}"]="${FILE}"
			[[ $# -ge 1 ]] && FILE="$1" && shift || break
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

function strip_comments {
	FILE="$1"
	grep --invert-match "^${COMMENT_CODE}" "${FILE}"
}

function strip_punctuation {
	tr -d '[:punct:]'
}

function strip_space {
	sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' | \
		tr --squeeze-repeats '[:blank:]' "${TITLE_SEPARATOR_CHAR}"
}

function title_to_heading_id {
	to_lower | strip_punctuation | strip_space | cut -d '-' -f -3
}

function title_to_post_url {
	to_lower | strip_punctuation | strip_space | cut -d '-' -f -3
}

function to_lower {
	tr '[:upper:]' '[:lower:]'
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

# checks that the combination of options is valid for the given file.
# FILE is a full post file. We need the content to look for {toc}.
# Also sets any options in the OPTIONS file that need setting
# For example, if heading_ids is __unset__ coming in but FILE has a {toc}
# then heading_ids will be set to true here
function validate_options {
	FILE="$1"
	OPTIONS="$2"
	if [[ "${FILE}" == "" ]] || [[ "${OPTIONS}" == "" ]]
	then
		echo "missing file or options file"
		return 1
	fi
	# If user wants a TOC, then heading_ids must be unset or set to on.
	# Set it to true if unset
	[[ "$(file_has_toc_code "${FILE}")" != "" ]] && \
		[[ "$(op_is_set "${OPTIONS}" heading_ids)" != "" ]] && \
		[[ "$(op_get "${OPTIONS}" heading_ids)" == "0" ]] && \
		echo "table of contents requested but heading_ids is off" && return 2
	[[ "$(file_has_toc_code "${FILE}")" != "" ]] && op_set "${OPTIONS}" heading_ids
	return 0
}

set +a
