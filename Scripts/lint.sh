#!/bin/bash
#
# Formats, fixes and lints every Swift file in GrabKit: Package.swift,
# Sources/ and Tests/.
#
# Outside CI it rewrites files in place (swift-format, swiftlint --fix and the
# BrightDigit MIT header) before linting. With CI set it only lints.
# LINT_MODE=NONE skips everything.

set -e  # Exit on any error

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
PROJECT_ROOT="$( cd -- "$SCRIPT_DIR/.." &> /dev/null && pwd )"
CONFIG_PATH="$PROJECT_ROOT/.swiftlint.yml"
COPYRIGHT_HOLDER="BrightDigit"
PROJECT_NAME="GrabKit"
ERRORS=0

run_command() {
	"$@" || ERRORS=$((ERRORS + 1))
}

echo "LintMode: $LINT_MODE"

if [ "$LINT_MODE" == "NONE" ]; then
	exit
fi

# Tools are pinned in .mise.toml.
if ! command -v mise >/dev/null 2>&1; then
	for candidate in "$HOME/.local/bin" /opt/homebrew/bin /usr/local/bin; do
		if [ -x "$candidate/mise" ]; then
			PATH="$candidate:$PATH"
			break
		fi
	done
fi
if ! command -v mise >/dev/null 2>&1; then
	echo "mise is required (https://mise.jdx.dev)"
	exit 1
fi

run_command mise install

run_tool() {
	mise exec -- "$@"
}

# Formats (outside CI) and lints the given files or directories.
lint_paths() {
	if [ -z "$CI" ]; then
		run_command run_tool swift-format format --recursive --parallel --in-place "$@"
		run_command run_tool swiftlint lint --fix --quiet --config "$CONFIG_PATH" "$@"
		run_command "$SCRIPT_DIR/header.sh" -c "$COPYRIGHT_HOLDER" -p "$PROJECT_NAME" "$@"
	fi

	run_command run_tool swiftlint lint --strict --quiet --config "$CONFIG_PATH" "$@"
	run_command run_tool swift-format lint --recursive --parallel --strict "$@"
}

cd "$PROJECT_ROOT"

echo "Linting GrabKit..."
lint_paths Package.swift Sources Tests

if [ $ERRORS -gt 0 ]; then
	echo "Linting failed with $ERRORS error(s)"
	exit 1
fi

echo "Linting passed"
