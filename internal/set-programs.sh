# Options must be validated before this code is run. Some dependencies are only
# necessary if certain features are enabled.

################################################################################
# define programs and options to pass to them
################################################################################
M4="$(which m4)"
M4_FLAGS="--prefix-builtins"
MAKE="$(which make)"
MAKE_FLAGS="-j 8 --makefile internal/Makefile --quiet"
MKDIR="$(which mkdir)"
MKDIR_FLAGS="-p"
GPG="$(which gpg)"
GPG_SIGN_FLAGS="--yes --armor --detach-sign --local-user ${GPG_FINGERPRINT}"
GPG_EXPORT_FLAGS="--armor --export ${GPG_FINGERPRINT}"
RM="rm"
RM_FLAGS="-fr"
MARKDOWN="./internal/cmark-gfm"
# --unsafe is needed in order to render manually-entered HTML when generating
# the table of contents. If you do not trust the markdown-formatted text
# content of your blog, then it may not be safe to use the --unsafe flag.
MARKDOWN_FLAGS="--unsafe -e footnotes -e table -e strikethrough -e autolink -e tagfilter -e tasklist"

################################################################################
# check for always required programs
################################################################################
# Do not search for system cmark-gfm. It may be older than we expect, thus not
# supporting all extensions
#if ! which "cmark-gfm" &> /dev/null
#then
#	MARKDOWN="./internal/cmark-gfm"
#else
#	MARKDOWN="$(which "cmark-gfm")"
#fi
[ ! -x "${MARKDOWN}" ] && echo "error: cmark-gfm not found" && exit 1
[ ! -x "${MAKE}" ] && echo "error: make not found" && exit 1
[ ! -x "${M4}" ]  && echo "error: m4 not found" && exit 1

################################################################################
# check for programs that are only sometimes needed
################################################################################
if [[ "${GPG_SIGN_PAGES}" == "yes" ]]
then
	[ ! -x "${GPG}" ] &&
		echo "error: gpg not found" &&
		exit 1
fi

