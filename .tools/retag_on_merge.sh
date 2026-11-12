#!/bin/bash
# Moves release tags that point at commits of a merged PR to its merge commit.
# Usage: retag_on_merge.sh <owner/repo> <pr number> <merge sha>
set -eu
repo=$1 pr=$2 merge_sha=$3

pr_commits=$(gh api --paginate "repos/$repo/pulls/$pr/commits" --jq '.[].sha')

gh api --paginate "repos/$repo/git/matching-refs/tags/" --jq '.[] | "\(.object.sha) \(.ref)"' |
while read -r sha ref; do
  if grep -qx "$sha" <<< "$pr_commits"; then
    echo "$ref: $sha -> $merge_sha"
    gh api -X PATCH "repos/$repo/git/$ref" -f sha="$merge_sha" -F force=true > /dev/null
  fi
done
