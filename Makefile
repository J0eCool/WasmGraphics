all: simple.wasm scanlines.wasm

serve:
	node server.js
.PHONY: serve

%.wasm: %.wat
	wat2wasm $< -o $@
