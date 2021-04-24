all: simple.wasm scanlines.wasm fuzzy.wasm

watch:
	python watcher.py . -- mingw32-make
.PHONY: watch

serve:
	node server.js
.PHONY: serve

%.wasm: %.wat
	wat2wasm $< -o $@
