[[ -f internal/bm.conf.example ]] &&
	source internal/bm.conf.example
[[ -f posts/bm.conf ]] &&
	source posts/bm.conf

# Set defaults in case something was still unset
#
# Parts of this code are only going to be executed if bm.conf.example was messed
# with or removed. It shouldn't have been, as per the big warning at the top
# of it.

[[ "${BLOG_SUBTITLE}" == "" ]] &&
	BLOG_SUBTITLE="Where super awesome things happen"
[[ "${BLOG_TITLE}" == "" ]] &&
	BLOG_TITLE="My Super Awesome Blog"
[[ "${CP_SRC_FILES_TO_BUILD}" == "" ]] &&
	CP_SRC_FILES_TO_BUILD="no"
[[ "${CREATE_HELP_VERBOSITY}" == "" ]] &&
	CREATE_HELP_VERBOSITY="long"
[[ "${DATE_FRMT}" == "" ]] &&
	DATE_FRMT="%d %b %Y"
[[ "${DEFAULT_AUTHOR}" == "" ]] &&
	DEFAULT_AUTHOR="$(whoami)"
[[ "${DEFAULT_INDEX_BY}" == "" ]] &&
	DEFAULT_INDEX_BY="none"
[[ "${ED}" == "" ]] &&
	ED="${EDITOR}"
[[ "${GPG_FINGERPRINT}" == "" ]] &&
	GPG_FINGERPRINT=""
[[ "${GPG_SIGN_PAGES}" == "" ]] &&
	GPG_SIGN_PAGES="no"
[[ "${LICENSE_TEXT}" == "" ]] &&
	LICENSE_TEXT=""
[[ "${LONG_DATE_FRMT}" == "" ]] &&
	LONG_DATE_FRMT="%d %b %Y at %l:%M %P"
[[ "${MAKE_RSS_FEED}" == "" ]] &&
	MAKE_RSS_FEED="no"
[[ "${MAKE_SHORT_POSTS}" == "" ]] &&
	MAKE_SHORT_POSTS="yes"
[[ "${MONTHLY_INDEX_DATE_FRMT}" == "" ]] &&
	MONTHLY_INDEX_DATE_FRMT="%b %Y"
[[ "${MULTI_MATCH_STRAT}" == "" ]] &&
	MULTI_MATCH_STRAT="simple"
[[ "${POST_INDEX_BY}" == "" ]] &&
	POST_INDEX_BY="${DEFAULT_INDEX_BY}"
[[ "${POSTS_ON_HOMEPAGE}" == "" ]] &&
	POSTS_ON_HOMEPAGE="5"
[[ "${PREFER_SHORT_POSTS}" == "" ]] &&
	PREFER_SHORT_POSTS="no"
[[ "${PREVIEW_MAX_WORDS}" == "" ]] &&
	PREVIEW_MAX_WORDS="300"
[[ "${REBUILD_POLICY}" == "" ]] &&
	REBUILD_POLICY="asap"
[[ "${ROOT_URL}" == "" ]] &&
	ROOT_URL=""
[[ "${RSS_DESCRIPTION}" == "" ]] &&
	RSS_DESCRIPTION="${BLOG_SUBTITLE}"
[[ "${RSS_HOST}" == "" ]] &&
	RSS_HOST="https://example.com/"
[[ "${RSS_TITLE}" == "" ]] &&
	RSS_TITLE="${BLOG_TITLE}"
[[ "${SIGNIFICANT_MOD_AFTER}" == "" ]] &&
	SIGNIFICANT_MOD_AFTER="1" ||
	SIGNIFICANT_MOD_AFTER="$((${SIGNIFICANT_MOD_AFTER}))"
[[ "${TAG_INDEX_BY}" == "" ]] &&
	TAG_INDEX_BY="${DEFAULT_INDEX_BY}"
[[ "${YEARLY_INDEX_DATE_FRMT}" == "" ]] &&
	YEARLY_INDEX_DATE_FRMT="%Y"

# Error checking
#
# This should always end up being executed. There are certain combinations of
# options that can be created that are invalid.

[[ "${PREFER_SHORT_POSTS}" == "yes" ]] &&
[[ "${MAKE_SHORT_POSTS}" != "yes" ]] &&
	echo "error: PREFER_SHORT_POSTS requires MAKE_SHORT_POSTS" &&
	exit 1

[[ "${GPG_FINGERPRINT}" != "" ]] &&
! which gpg &> /dev/null &&
	echo "error: GPG_FINGERPRINT set but gnupg doesn't seem to be installed" &&
	exit 1

[[ "${GPG_FINGERPRINT}" == "" ]] &&
[[ "${GPG_SIGN_PAGES}" == "yes" ]] &&
	echo "error: GPG_SIGN_PAGES enabled but GPG_FINGERPRINT needs to be set" &&
	exit 1
