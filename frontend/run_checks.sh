#!/bin/bash

set -e
cd app || (echo "Please run the script from the frontend directory." && exit 1)
dart format --output=none --set-exit-if-changed . || (echo "Incorrect formatting. Run 'dart format app/' to autoformat all files." && exit 1)
dart analyze --fatal-infos || (echo "Code analysis failed. Please solve problems." && exit 1)
flutter test || (echo "Some unit tests failed." && exit 1)
echo "All checks passed. You should be good to go!"
exit 0