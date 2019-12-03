#!/bin/bash
# Accepts a path to a directory containing the upstream package, and pulls any
# changes into the current repository with rsync.

root="$(git rev-parse --show-toplevel)"
composer_file="$root/composer.json"

# Options
upstream=''
update_version=''
quiet=''

print_usage() {
cat <<EOM
Usage: pull_package_from_upstream [OPTION] directory

Options:
  -h         display this help message
  -d         upstream directory to sync up with
  -V [arg]   update version number

EOM
}

get_options() {
  while getopts 'hd:V:' flag; do
    case "${flag}" in
      h) print_usage; exit ;;
      d) upstream="${OPTARG}" ;;
      V) update_version="${OPTARG}" ;;
      q) quiet='true' ;;
      *) print_usage; exit 1 ;;
    esac
  done

  [ -n "$upstream" ]
}

info() {
  [ -n "$quiet" ] || echo -e "$1"
}

error() {
  echo -e >&2 "Error: $1"
  exit 1
}

synchronize() {
  rsync -r "$upstream/." "$root"
}

update_version_check() {
  [ -z "$update_version" ] || update_version
}

update_version() {
  jq '.version |= $update_version' \
    --arg update_version \
    "$update_version" \
    "$composer_file" \
  > tmp.$$.json && mv tmp.$$.json "$composer_file"
}

get_options "$@" || error "provide an upstream directory path with the -d flag"
synchronize
update_version_check
