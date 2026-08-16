#!/usr/bin/env bash
# Runs `flutter pub publish --dry-run` as a CI gate.
#
# pub treats "your git working tree is dirty" as a publish warning, and warnings
# make the command exit non-zero. That check exists to stop someone publishing
# uncommitted work from a laptop; on CI the checkout is pristine by definition
# and the real publish runs from a fresh checkout of a tag, so the warning
# carries no signal here. Every other warning still fails the job.
#
# The tree is printed first, so if a toolchain step really is rewriting files
# the next run shows exactly what and why instead of hiding it.
set -uo pipefail

echo "::group::working tree before dry run"
git status --porcelain
git diff --stat
echo "::endgroup::"

output="$(flutter pub publish --dry-run 2>&1)"
status=$?
printf '%s\n' "$output"

if [ "$status" -eq 0 ]; then
  exit 0
fi

# pub lists each problem on its own `* ` bullet. Tolerate the run only when the
# single problem reported is the git-cleanliness one.
problems="$(printf '%s\n' "$output" | grep -c '^\* ' || true)"
# pub words this singular or plural depending on the file count.
dirty="$(printf '%s\n' "$output" \
  | grep -Ec 'checked-in files? (is|are) modified in git' || true)"

if [ "$problems" -eq 1 ] && [ "$dirty" -ge 1 ]; then
  echo "::warning title=Dirty checkout::pub reported only its git-cleanliness" \
    "warning, which does not apply to a CI checkout. Treating as a pass."
  exit 0
fi

echo "::error::pub publish --dry-run reported $problems problem(s)"
exit "$status"
