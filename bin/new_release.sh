#!/bin/sh
# Creates a new release of this plugin on GitHub.

set -e

root_dir="$(git rev-parse --show-toplevel)"
composer_file="$root_dir/composer.json"
tag="$(jq -r ".version" "$composer_file")"

tag_already_exists() {
  git show-ref --tags --quiet --verify -- "refs/tags/$tag"
}

# --- Main

if tag_already_exists; then
  echo "A tag already exists for version $tag."
  exit 1
fi

git add -A
git commit -m "Update to version $tag"
git tag -a "$tag" -m "$tag"
git push origin master --tags

