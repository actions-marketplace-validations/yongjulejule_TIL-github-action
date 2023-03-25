#!/bin/bash

set -x
set -euo pipefail

function cleanup {
  echo "cleanup"
  local jobs=$(jobs -p)
  if [ -n "$jobs" ]; then
    kill $jobs
  fi
  exit 1
}

trap cleanup SIGTERM SIGINT EXIT

tmp_file=$(mktemp)
dest_file='/dev/null'

if [ $# -eq 2 ] && [ "$1" == "-f" ]; then
	input="Y"
	if [ -f "$2" ]; then
		echo "File named [$2] Aleady exists. Overwrite? (Y/n)"
		read input
	fi
	if [ "$input" == "Y" ]; then
		echo "Replace file [$2]"
    dest_file=$2
		exec 1>$tmp_file
	else
		echo "Exiting"
		exit 1
	fi
fi


cat <<EOF
# TIL

Today I Learned

새로 알게 된 내용들을 저장하는 곳입니다.

EOF

echo "# Index"

dirs=($(find $PWD -type d ! -path './.*' | sed 's/^\.\///' | sort))

unset dirs[0]
 
IFS=$'\n'

for d in ${dirs[@]}; do
	if [[ $d = "image" ]]; then
		continue
	fi
	filepath=$(find $d -maxdepth 1 -type f -name "*.md" ! -name "README.md" | sort)
  if [[ -z $filepath ]]; then
    continue
  fi
  filename=($filepath)
	filename=${filepath[@]//.md/}
  if [[ -z $filename ]]; then
    continue
  fi
	echo -e "\n## $d\n"
	echo -e "|Title|Modified at|"
	echo -e "|:---|:---|"

	for f in $filename; do
		date=$(git log -1 --format=%ci -- $f.md)
		echo "|[${f//*\/}]($f.md)| ${date/ *} |"
	done
done

[ $input == "Y" ] && mv $tmp_file $dest_file
