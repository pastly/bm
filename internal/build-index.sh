#!/usr/bin/env bash

source internal/globals.sh

OUT_FILE="$1"
shift

cat << EOF > "${OUT_FILE}"
<title>index.html</title>
<body>
<h1>index.html</h1>
<ul>
EOF

while [ ! -z "$1" ]
do
	TITLE=$(get_title "$1")
	cat << EOF >> "${OUT_FILE}"
<li><a href='posts/$(basename "$1" .${POST_EXTENSION}).html'>${TITLE}</a></li>
EOF
	shift
done

cat << EOF >> "${OUT_FILE}"
</ul>
</body>
EOF
