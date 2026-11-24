# Makefile for GrabKit
#
# Tools are pinned in .mise.toml and run through `mise exec`.

.PHONY: help test lint export

help:
	@echo "GrabKit Development Commands"
	@echo ""
	@echo "  make test    - swift test"
	@echo "  make lint    - Format, fix and lint (Scripts/lint.sh). CI=1 lints without rewriting"
	@echo "  make export RESULT=<.xcresult> OUTPUT=<folder>"
	@echo "               - Export a run's screenshots with grab-export"

test:
	swift test

lint:
	./Scripts/lint.sh

export:
	swift run -c release grab-export "$(RESULT)" "$(OUTPUT)"
