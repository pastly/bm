#!/usr/bin/env bash

source globals.sh

function build_post {
	IN="$1"
	TEMP=$(mktemp)
	OUT="$2"

	strip_comments "${IN}" > "${TEMP}"
	TITLE="$(get_title "${TEMP}")"

	CONTENT="$(get_content "${TEMP}")"
	CONTENT="$(echo "${CONTENT}" | ${MARKDOWN})"
	cat << EOF > "${OUT}"
<title>${TITLE}</title>
<body>
<h1>${TITLE}</h1>
${CONTENT}
</body>
EOF
rm "${TEMP}"
}

OUT_DIR="$(dirname $1)"
mkdir -p "${OUT_DIR}"

OUT_FILE="$1"
shift

while [ ! -z "$1" ]
do
	IN_NAME_PART="$(basename "$1" ".${POST_EXTENSION}")"
	if [[ $OUT_FILE =~ ^.*$IN_NAME_PART.*$ ]]
	then
		build_post "$1" "$OUT_FILE"
		exit 0
	fi
	shift
done
exit 1
