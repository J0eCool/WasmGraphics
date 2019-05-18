async function loadWasm(filename, imports) {
  let bytes = fetch(filename);
  let wasm = await new WebAssembly.instantiateStreaming(bytes, imports);
  return wasm.instance;
}

async function main() {
  let url = new URL(window.location.href);
  let wasmName = url.searchParams.get('wasm') || 'simple';
  let canvas = document.getElementById('canvas');
  let imageStart = 1024;
  let canvasWidth = canvas.width;
  let canvasHeight = canvas.height;
  let imports = {
    consts: {
      imageStart,
      canvasWidth,
      canvasHeight,
    },
  };
  let wasm = await loadWasm(wasmName + '.wasm', imports);

  let memory = wasm.exports.memory;
  let pixelSlice = new Uint8Array(memory.buffer, imageStart, 4 * canvasWidth * canvasHeight);

  let context = canvas.getContext('2d');
  let image = context.createImageData(canvasWidth, canvasHeight);

  function update() {
    requestAnimationFrame(update);
    wasm.exports.update();
    image.data.set(pixelSlice);
    context.putImageData(image, 0, 0);
  }
  update();
}

main();
