function op_get {
	OPTION_FILE="$1"
	OP="$2"
	grep --word-regex "${OP}" "${OPTION_FILE}" | cut -f 2
}

function op_set {
	OPTIONS_FILE="$1"
	OP="$2"
	[[ $# -ge 3 ]] && VALUE="$3" || VALUE="1"
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

