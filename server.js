const http = require('http');
const fs = require('fs');
const path = require('path');

const PORT = process.env.PORT || 8080;
const CSV_DIR = path.join(__dirname, 'csv');
const MIME_TYPES = {
    '.html': 'text/html',
    '.css': 'text/css',
    '.js': 'application/javascript',
    '.json': 'application/json',
    '.csv': 'text/csv',
    '.png': 'image/png',
    '.jpg': 'image/jpeg',
    '.jpeg': 'image/jpeg',
    '.gif': 'image/gif',
    '.svg': 'image/svg+xml',
    '.ico': 'image/x-icon'
};

const server = http.createServer((req, res) => {
    // Local-only helper for the Species Data panel: lists the .csv files sitting
    // in the csv/ folder next to this script, so the app can offer "pick a file
    // already saved here" instead of always needing a manual browse/drag-drop.
    // This route doesn't exist on GitHub Pages (no server there), so the page
    // treats a failed fetch of it as "not running locally" and hides that option.
    if (req.url === '/list-csv') {
        fs.readdir(CSV_DIR, (error, files) => {
            if (error) {
                res.writeHead(200, { 'Content-Type': 'application/json' });
                res.end('[]');
                return;
            }
            const csvFiles = files.filter((f) => f.toLowerCase().endsWith('.csv'));
            res.writeHead(200, { 'Content-Type': 'application/json' });
            res.end(JSON.stringify(csvFiles));
        });
        return;
    }

    let filePath = '.' + req.url;
    if (filePath === './') {
        filePath = './index.html';
    }

    const extname = path.extname(filePath).toLowerCase();
    const contentType = MIME_TYPES[extname] || 'application/octet-stream';

    fs.readFile(filePath, (error, content) => {
        if (error) {
            if (error.code === 'ENOENT') {
                res.writeHead(404);
                res.end('404 Not Found');
            } else {
                res.writeHead(500);
                res.error('Server Error: ' + error.code);
            }
        } else {
            res.writeHead(200, { 'Content-Type': contentType });
            res.end(content, 'utf-8');
        }
    });
});

server.listen(PORT, () => {
    console.log(`Server running at http://localhost:${PORT}/`);
    console.log('Press Ctrl+C to stop the server');
});
