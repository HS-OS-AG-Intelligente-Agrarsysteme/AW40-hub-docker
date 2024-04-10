#!/bin/bash

set -e
# Set working directory to script directory.
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
cd "$SCRIPT_DIR"

dart format --output=none --set-exit-if-changed . || (echo "Incorrect formatting. Run 'dart format .' to autoformat all files." && exit 1)
dart analyze --fatal-infos || (echo "Code analysis failed. Please solve problems." && exit 1)
flutter test || (echo "Some unit tests failed." && exit 1)

echo "All checks passed. You should be good to go!"
exit 0
