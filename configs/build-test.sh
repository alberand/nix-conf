#!/usr/bin/env bash

# Iterate over jj's revset and run "make -j$(nproc)" on them
# This is used for xfsprogs releases, to check that every commit builds. Build
# failures will cause bisecting to fail.

set -e

# Default values
REVSET=""

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -r|--range)
            REVSET="$2"
            shift 2
            ;;
        -h|--help)
            echo "Usage: $0 -r/--range REVSET"
            echo "  -r, --range REVSET    Jujutsu revset to test"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Check if revset is provided
if [ -z "$REVSET" ]; then
    echo "Error: -r/--range argument is required"
    exit 1
fi

# Track results
FAILED_REVS=()
SUCCESS_COUNT=0
FAIL_COUNT=0

if [[ "${REVSET: -1}" == ":" ]]; then
	REVSET="${REVSET}@-"
fi

jj log --reversed -r "$REVSET" --no-graph -T 'change_id ++ "\n"' | while read -r revision; do
  echo ""
  echo "========================================="
  echo "Testing revision: $rev"
  echo "========================================="

  # Edit to the revision
  jj new "$revision"

  # Run make
  if make -j$(nproc); then
      echo "✓ Build succeeded for $revision"
      ((SUCCESS_COUNT+=1))
  else
      echo "✗ Build failed for $revision"
      FAILED_REVS+=("$revision")
      ((FAIL_COUNT+=1))
  fi
done

if [ ${#FAILED_REVS[@]} -gt 0 ]; then
    echo ""
    echo "Failed revisions:"
    for rev in "${FAILED_REVS[@]}"; do
        echo "  - $rev"
    done
fi
echo "========================================="

# Determine exit code
if [ $FAIL_COUNT -gt 0 ]; then
    exit 1
fi

exit 0
