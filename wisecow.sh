#!/usr/bin/env bash

SRVPORT=4499
RSPFILE=response

rm -f $RSPFILE
mkfifo $RSPFILE

get_api() {
	read line
	echo $line
}

handleRequest() {
    # 1) Process the request
	get_api
	mod=`fortune`

cat <<EOF > $RSPFILE
HTTP/1.1 200


<pre>`cowsay $mod`</pre>
EOF
}

prerequisites() {
	echo "Install prerequisites."
	
	# Check for cowsay with full path
	if ! command -v cowsay >/dev/null 2>&1 && ! command -v /usr/games/cowsay >/dev/null 2>&1; then
		echo "cowsay is not installed"
		exit 1
	fi

	# Check for fortune with full path
	if ! command -v fortune >/dev/null 2>&1 && ! command -v /usr/games/fortune >/dev/null 2>&1; then
		echo "fortune is not installed"
		exit 1
	fi
	
	echo "Prerequisites check passed."
}

main() {
	prerequisites
	echo "Wisdom served on port=$SRVPORT..."

	while [ 1 ]; do
		cat $RSPFILE | nc -lN $SRVPORT | handleRequest
		sleep 0.01
	done
}

main