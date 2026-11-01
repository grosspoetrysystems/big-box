#!/usr/bin/env sh
set -eu

msg_file=${1:?commit message file required}
# Drop git's comment lines and surrounding blanks, then take the subject line.
header=$(git stripspace --strip-comments < "$msg_file" | sed -n '1p' | tr -d '\r')

if [ -z "$header" ]; then
  echo "commit message header is required" >&2
  exit 1
fi

case "$header" in
  Merge\ *|Revert\ *|fixup!\ *|squash!\ *)
    exit 0
    ;;
esac

if [ "${#header}" -gt 100 ]; then
  echo "commit message header must be 100 characters or fewer" >&2
  exit 1
fi

pattern='^(build|chore|ci|docs|feat|fix|perf|refactor|revert|style|test)(\([a-z0-9._/-]+\))?!?: [^ ].+$'

if ! printf '%s\n' "$header" | grep -Eq "$pattern"; then
  echo "commit message must match Conventional Commits: type(scope): subject" >&2
  exit 1
fi
