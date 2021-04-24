let fs = require('fs');
let http = require('http');
let path = require('path');
let url = require('url');
let port = 8080;

http.createServer((request, response) => {
  let uri = url.parse(request.url).pathname;
  let filename = path.join(process.cwd(), uri);

  fs.exists(filename, (exists) => {
    if (!exists) {
      response.writeHead(404, {'Content-Type': 'text/html'});
      response.write('<h2>404</h2><p>File not found</p>')
      response.end();
      return;
    }

    if (fs.statSync(filename).isDirectory()) {
      filename += '/index.html';
    }

    fs.readFile(filename, 'binary', (err, file) => {
      if (err) {
        response.writeHead(503, {'Content-Type': 'text/html'});
        response.write('<h2>503</h2><p>Something went wrong</p>')
        response.end();
        return;
      }

      // Certain file types require special MIME types
      let mime = 'text/plain';
      let ext = path.extname(filename);
      let exts = {
        '.css': 'text/css',
        '.html': 'text/html',
        '.wasm': 'application/wasm',
      };
      mime = exts[ext] || mime;

      response.writeHead(200, {'Content-Type': mime});
      response.write(file, 'binary');
      response.end();
      console.log('Serving file', filename, 'with mime type', mime);
    });
  });
}).listen(port);

console.log('server started...');
