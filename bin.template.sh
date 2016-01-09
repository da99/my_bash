#!/usr/bin/env bash
#
#
THE_ARGS="$@"

if [[ -z "$@" ]]; then
  action="watch"
else
  action=$1
  shift
fi

set -u -e -o pipefail

watch () {
  cmd () {
    if [[ -z "$@" ]]; then
      path="some.file"
    else
      path="$1"
      shift
    fi
  }
  cmd

  echo -e "\n=== Watching: $files"
  while read -r CHANGE; do
    dir=$(echo "$CHANGE" | cut -d' ' -f 1)
    path="${dir}$(echo "$CHANGE" | cut -d' ' -f 3)"
    file="$(basename $path)"

    echo -e "\n=== $CHANGE ($path)"

    if [[ "$path" =~ "$0" ]]; then
      echo "=== Reloading..."
      break
    fi

    if [[ "$file" =~ ".some_ext" ]]; then
      cmd $path
    fi
  done < <(inotifywait --quiet --monitor --event close_write some_file "$0") || exit 1
  $0 watch $THE_ARGS
}

case $action in
  help|--help)
    bash_setup print_help $0
    ;;

  *)
    $action $THE_ARGS
    ;;

esac
