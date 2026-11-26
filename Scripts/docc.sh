#!/bin/bash
#
# Builds GrabKit's DocC documentation (GrabSupport and GrabTesting) without
# the swift-docc-plugin dependency: `swift package dump-symbol-graph` emits the
# symbol graphs, then `docc convert` renders each catalog. Keeping the plugin
# out of Package.swift means apps that depend on GrabKit never resolve it.
#
# Usage:
#   ./Scripts/docc.sh                      # build .build/docs/<Target>.doccarchive
#   DOCC_TARGETS=GrabSupport ./Scripts/docc.sh
#   DOCC_PREVIEW=1 DOCC_TARGETS=GrabTesting ./Scripts/docc.sh   # live preview
#
# Warnings (including unresolved symbol links) fail the build.

set -euo pipefail

SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
cd "${SCRIPT_DIR}/.."

read -r -a TARGETS <<< "${DOCC_TARGETS:-GrabSupport GrabTesting}"
DOCC=(xcrun docc)
OUTPUT_DIR=".build/docs"

# The output folder depends on the build system, so read it from SwiftPM's
# own message.
DUMP_LOG=$(swift package dump-symbol-graph --minimum-access-level public 2>&1) || {
	echo "$DUMP_LOG" >&2
	exit 1
}
DUMP_DIR=$(printf '%s\n' "$DUMP_LOG" | sed -n 's/^Files written to //p' | tail -n 1)
if [ -z "$DUMP_DIR" ] || [ ! -d "$DUMP_DIR" ]; then
	echo "$DUMP_LOG" >&2
	echo "error: couldn't find the symbol graph output folder" >&2
	exit 1
fi

for TARGET in "${TARGETS[@]}"; do
	SYMBOL_GRAPH_DIR="${OUTPUT_DIR}/symbol-graphs/${TARGET}"
	ARCHIVE="${OUTPUT_DIR}/${TARGET}.doccarchive"
	rm -rf "$SYMBOL_GRAPH_DIR" "$ARCHIVE"
	mkdir -p "$SYMBOL_GRAPH_DIR"
	# Keep only this target's graphs (dependencies' and the SDK's aren't ours).
	cp "$DUMP_DIR/${TARGET}.symbols.json" "$SYMBOL_GRAPH_DIR/"
	find "$DUMP_DIR" -maxdepth 1 -name "${TARGET}@*.symbols.json" \
		-exec cp {} "$SYMBOL_GRAPH_DIR/" \;

	ARGS=(
		"Sources/${TARGET}/${TARGET}.docc"
		--fallback-display-name "$TARGET"
		--fallback-bundle-identifier "com.brightdigit.${TARGET}"
		--additional-symbol-graph-dir "$SYMBOL_GRAPH_DIR"
	)
	if [ -n "${DOCC_PREVIEW:-}" ]; then
		exec "${DOCC[@]}" preview "${ARGS[@]}"
	fi
	"${DOCC[@]}" convert "${ARGS[@]}" --warnings-as-errors --output-path "$ARCHIVE"
	echo "Documentation archive: ${ARCHIVE}"
done
