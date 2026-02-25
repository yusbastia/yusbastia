const express = require('express');
const path = require('path');
const fs = require('fs');
const { exec } = require('child_process');
const util = require('util');
const execPromise = util.promisify(exec);
const crypto = require('crypto');

// ===================== KONFIGURASI =====================
const config = {
    ytdlBin: "/usr/local/bin/yt-dlp",
    ffmpegBin: "/usr/bin/ffmpeg",
    downloadDir: "/home/yuzu/downloads",
    cookiesFile: "/home/yuzu/eggdrop/cookies.txt",
    ytExtractorArgs: "youtube:player-client=default,mweb",
    autoDeleteDelay: 60000 // hapus file setelah 60 detik
};

// Buat folder download jika belum ada
if (!fs.existsSync(config.downloadDir)) {
    fs.mkdirSync(config.downloadDir, { recursive: true });
}

const app = express();
const PORT = 2025;

// Middleware
app.use(express.urlencoded({ extended: true }));
app.use(express.json());

// ===================== FUNGSI BANTU =====================
function formatSize(bytes) {
    if (bytes < 1024) return bytes + ' B';
    const units = ['KB', 'MB', 'GB', 'TB'];
    let size = bytes;
    for (const unit of units) {
        size /= 1024;
        if (size < 1024) {
            return size.toFixed(1) + ' ' + unit;
        }
    }
    return 'Inf';
}

// ===================== ENDPOINT API UNTUK DAFTAR FILE =====================
app.get('/api/files', (req, res) => {
    try {
        const files = fs.readdirSync(config.downloadDir)
            .filter(f => f.endsWith('.mp3') || f.endsWith('.mp4'))
            .map(f => ({
                name: f,
                url: `/get/${encodeURIComponent(f)}`,
                size: formatSize(fs.statSync(path.join(config.downloadDir, f)).size),
                created: fs.statSync(path.join(config.downloadDir, f)).mtime
            }))
            .sort((a, b) => b.created - a.created);
        
        res.json(files);
    } catch (err) {
        console.error('Gagal membaca folder download:', err);
        res.status(500).json({ error: 'Gagal memuat daftar file' });
    }
});

// ===================== HALAMAN UTAMA =====================
app.get('/', (req, res) => {
    res.send(`
    <!DOCTYPE html>
    <html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>LEMON Downloader</title>
        <style>
            * { margin: 0; padding: 0; box-sizing: border-box; }
            body {
                font-family: 'Inter', sans-serif;
                background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                min-height: 100vh;
                padding: 20px;
                display: flex;
                align-items: center;
                justify-content: center;
            }
            .container {
                max-width: 800px;
                width: 100%;
                background: rgba(255, 255, 255, 0.95);
                backdrop-filter: blur(10px);
                border-radius: 24px;
                padding: 40px;
                box-shadow: 0 30px 60px rgba(0,0,0,0.3);
                transition: transform 0.3s ease;
            }
            h1 {
                font-size: 2.5rem;
                font-weight: 700;
                background: linear-gradient(135deg, #667eea, #764ba2);
                -webkit-background-clip: text;
                -webkit-text-fill-color: transparent;
                margin-bottom: 10px;
                display: flex;
                align-items: center;
                gap: 10px;
            }
            .subtitle {
                color: #666;
                margin-bottom: 30px;
                font-size: 1.1rem;
                border-left: 4px solid #764ba2;
                padding-left: 15px;
            }
            .form-group { margin-bottom: 25px; }
            label {
                display: block;
                margin-bottom: 8px;
                font-weight: 600;
                color: #444;
                font-size: 0.95rem;
                text-transform: uppercase;
                letter-spacing: 0.5px;
            }
            input, select {
                width: 100%;
                padding: 15px 20px;
                border: 2px solid #e0e0e0;
                border-radius: 12px;
                font-size: 1rem;
                transition: all 0.3s ease;
                background: white;
            }
            input:focus, select:focus {
                outline: none;
                border-color: #764ba2;
                box-shadow: 0 0 0 4px rgba(118,75,162,0.1);
            }
            button {
                width: 100%;
                padding: 16px;
                background: linear-gradient(135deg, #667eea, #764ba2);
                color: white;
                border: none;
                border-radius: 12px;
                font-size: 1.2rem;
                font-weight: 600;
                cursor: pointer;
                transition: all 0.3s ease;
                position: relative;
                overflow: hidden;
            }
            button:hover {
                transform: translateY(-2px);
                box-shadow: 0 10px 25px rgba(102,126,234,0.4);
            }
            button:active { transform: translateY(0); }
            .loading {
                display: none;
                text-align: center;
                margin: 20px 0;
            }
            .spinner {
                display: inline-block;
                width: 50px;
                height: 50px;
                border: 4px solid rgba(118,75,162,0.2);
                border-top-color: #764ba2;
                border-radius: 50%;
                animation: spin 1s linear infinite;
            }
            @keyframes spin { to { transform: rotate(360deg); } }
            .error {
                background: #fee;
                color: #c33;
                padding: 15px;
                border-radius: 12px;
                margin: 20px 0;
                display: none;
                align-items: center;
                gap: 10px;
                border: 1px solid #fcc;
            }
            .success {
                background: #e8f5e9;
                color: #2e7d32;
                padding: 20px;
                border-radius: 12px;
                margin: 20px 0;
                border: 1px solid #a5d6a7;
            }
            .success h3 { margin-bottom: 10px; display: flex; align-items: center; gap: 8px; }
            .file-info {
                background: white;
                border-radius: 8px;
                padding: 15px;
                margin-top: 15px;
            }
            .file-info p {
                margin: 8px 0;
                display: flex;
                align-items: center;
                gap: 8px;
            }
            .file-info a {
                color: #764ba2;
                text-decoration: none;
                font-weight: 600;
                word-break: break-all;
            }
            .recent-files {
                margin-top: 40px;
                border-top: 2px dashed #e0e0e0;
                padding-top: 30px;
            }
            .recent-files h2 {
                font-size: 1.5rem;
                color: #333;
                margin-bottom: 20px;
                display: flex;
                align-items: center;
                gap: 8px;
            }
            .file-list {
                list-style: none;
                display: grid;
                gap: 12px;
            }
            .file-item {
                background: #f8f9fa;
                border-radius: 10px;
                padding: 12px 15px;
                display: flex;
                justify-content: space-between;
                align-items: center;
                transition: all 0.3s ease;
                border: 1px solid #eee;
            }
            .file-item:hover {
                background: white;
                border-color: #764ba2;
                transform: translateX(5px);
                box-shadow: 0 5px 15px rgba(0,0,0,0.1);
            }
            .file-name {
                font-weight: 500;
                color: #333;
                overflow: hidden;
                text-overflow: ellipsis;
                white-space: nowrap;
                max-width: 300px;
            }
            .file-size {
                color: #666;
                font-size: 0.9rem;
                background: #eee;
                padding: 4px 10px;
                border-radius: 20px;
            }
            .file-download {
                color: #764ba2;
                text-decoration: none;
                font-weight: 600;
                padding: 6px 12px;
                border-radius: 20px;
                transition: all 0.3s ease;
            }
            .file-download:hover {
                background: #764ba2;
                color: white;
            }
            .empty-list {
                text-align: center;
                color: #999;
                padding: 30px;
                font-style: italic;
            }
            footer {
                margin-top: 30px;
                text-align: center;
                color: #888;
                font-size: 0.9rem;
            }
        </style>
    </head>
    <body>
        <div class="container">
            <h1>🍋 LEMON Downloader</h1>
            <div class="subtitle">
                Download video & audio dari YouTube, Facebook, dan banyak lagi — langsung!
            </div>

            <form id="downloadForm">
                <div class="form-group">
                    <label for="url">🔗 URL</label>
                    <input type="text" id="url" name="url" placeholder="https://www.youtube.com/watch?v=..." required>
                </div>
                <div class="form-group">
                    <label for="type">📁 Format</label>
                    <select id="type" name="type">
                        <option value="mp4">MP4 (Video)</option>
                        <option value="mp3">MP3 (Audio)</option>
                    </select>
                </div>
                <button type="submit">⬇️ Download Sekarang</button>
            </form>

            <div class="loading" id="loading">
                <div class="spinner"></div>
                <p style="margin-top:10px; color:#666;">Memproses, mohon tunggu...</p>
            </div>

            <div class="error" id="error"></div>
            <div class="success" id="success" style="display: none;"></div>

            <div class="recent-files">
                <h2>📂 File Terbaru</h2>
                <div id="fileListContainer">Memuat...</div>
            </div>

            <footer>
                <p>File akan tersedia selama 60 detik setelah download.</p>
            </footer>
        </div>

        <script>
            const form = document.getElementById('downloadForm');
            const loading = document.getElementById('loading');
            const errorDiv = document.getElementById('error');
            const successDiv = document.getElementById('success');
            const fileListContainer = document.getElementById('fileListContainer');

            loadFileList();

            form.addEventListener('submit', async (e) => {
                e.preventDefault();
                const url = document.getElementById('url').value;
                const type = document.getElementById('type').value;

                loading.style.display = 'block';
                errorDiv.style.display = 'none';
                successDiv.style.display = 'none';

                try {
                    const response = await fetch('/download', {
                        method: 'POST',
                        headers: { 'Content-Type': 'application/json' },
                        body: JSON.stringify({ url, type })
                    });

                    if (!response.ok) {
                        const errorText = await response.text();
                        throw new Error(errorText);
                    }

                    const blob = await response.blob();
                    const contentDisposition = response.headers.get('Content-Disposition');
                    let filename = 'download.' + type;
                    if (contentDisposition) {
                        const match = contentDisposition.match(/filename="(.+)"/);
                        if (match) filename = match[1];
                    }

                    const downloadUrl = window.URL.createObjectURL(blob);
                    const a = document.createElement('a');
                    a.href = downloadUrl;
                    a.download = filename;
                    document.body.appendChild(a);
                    a.click();
                    document.body.removeChild(a);
                    window.URL.revokeObjectURL(downloadUrl);

                    loading.style.display = 'none';
                    
                    successDiv.style.display = 'block';
                    successDiv.innerHTML = \`
                        <h3>✅ Download selesai!</h3>
                        <div class="file-info">
                            <p><strong>📁 File:</strong> \${filename}</p>
                            <p><strong>🔗 Link:</strong> <a href="/get/\${encodeURIComponent(filename)}" target="_blank">/get/\${filename}</a></p>
                        </div>
                    \`;

                    loadFileList();

                } catch (err) {
                    loading.style.display = 'none';
                    errorDiv.style.display = 'flex';
                    errorDiv.textContent = err.message;
                }
            });

            async function loadFileList() {
                try {
                    const response = await fetch('/api/files');
                    const files = await response.json();
                    
                    if (files.length === 0) {
                        fileListContainer.innerHTML = '<div class="empty-list">Belum ada file.</div>';
                        return;
                    }

                    let html = '<ul class="file-list">';
                    files.slice(0, 10).forEach(file => {
                        html += \`
                            <li class="file-item">
                                <span class="file-name" title="\${file.name}">\${file.name}</span>
                                <span class="file-size">\${file.size}</span>
                                <a href="/get/\${encodeURIComponent(file.name)}" class="file-download" download>⬇️</a>
                            </li>
                        \`;
                    });
                    html += '</ul>';
                    fileListContainer.innerHTML = html;
                } catch (err) {
                    fileListContainer.innerHTML = '<div class="empty-list">Gagal memuat daftar file.</div>';
                }
            }
        </script>
    </body>
    </html>
    `);
});

// ===================== ENDPOINT DOWNLOAD =====================
app.post('/download', async (req, res) => {
    const { url, type = 'mp4' } = req.body;
    if (!url) return res.status(400).send('URL tidak boleh kosong');

    const timestamp = Date.now();
    const randomStr = crypto.randomBytes(4).toString('hex');
    const outputTemplate = path.join(config.downloadDir, `dl_${timestamp}_${randomStr}_%(title)s.%(ext)s`);

    try {
        const infoCmd = `${config.ytdlBin} --dump-json --no-warnings ${config.cookiesFile ? `--cookies "${config.cookiesFile}"` : ''} --extractor-args "${config.ytExtractorArgs}" "${url}"`;
        const { stdout } = await execPromise(infoCmd);
        const info = JSON.parse(stdout);
        const title = info.title;
        const safeTitle = title.replace(/[^\w\s]/gi, '_').replace(/\s+/g, '_').substring(0, 100);

        let downloadCmd = `${config.ytdlBin} --no-warnings ${config.cookiesFile ? `--cookies "${config.cookiesFile}"` : ''} --extractor-args "${config.ytExtractorArgs}" --restrict-filenames -o "${outputTemplate}" "${url}"`;
        if (type === 'mp3') {
            downloadCmd += ` -x --audio-format mp3 --audio-quality 128K --ffmpeg-location "${config.ffmpegBin}"`;
        } else {
            downloadCmd += ` -f mp4`;
        }
        await execPromise(downloadCmd);

        const files = fs.readdirSync(config.downloadDir)
            .filter(f => f.includes(`dl_${timestamp}_${randomStr}`))
            .sort((a, b) => fs.statSync(path.join(config.downloadDir, b)).mtimeMs - fs.statSync(path.join(config.downloadDir, a)).mtimeMs);

        if (files.length === 0) throw new Error('File tidak ditemukan');

        const fileName = files[0];
        const filePath = path.join(config.downloadDir, fileName);

        res.setHeader('Content-Disposition', `attachment; filename="${encodeURIComponent(safeTitle)}.${type}"`);
        res.setHeader('Content-Type', type === 'mp3' ? 'audio/mpeg' : 'video/mp4');

        const fileStream = fs.createReadStream(filePath);
        fileStream.pipe(res);

        fileStream.on('end', () => {
            setTimeout(() => {
                fs.unlink(filePath, (err) => {
                    if (!err) console.log(`🗑️ File ${fileName} dihapus`);
                });
            }, config.autoDeleteDelay);
        });

    } catch (error) {
        console.error('Download error:', error.message);
        res.status(500).send(error.message);
    }
});

// ===================== ROUTE UNTUK MENGAKSES FILE =====================
app.get('/get/:filename', (req, res) => {
    const filename = req.params.filename;
    const safeFilename = path.basename(filename);
    const filePath = path.join(config.downloadDir, safeFilename);

    if (!fs.existsSync(filePath)) {
        return res.status(404).send('File tidak ditemukan atau sudah dihapus.');
    }

    res.setHeader('Content-Disposition', `attachment; filename="${encodeURIComponent(safeFilename)}"`);
    const ext = path.extname(safeFilename).toLowerCase();
    if (ext === '.mp3') {
        res.setHeader('Content-Type', 'audio/mpeg');
    } else if (ext === '.mp4') {
        res.setHeader('Content-Type', 'video/mp4');
    } else {
        res.setHeader('Content-Type', 'application/octet-stream');
    }

    const fileStream = fs.createReadStream(filePath);
    fileStream.pipe(res);
});

// ===================== JALANKAN SERVER =====================
app.listen(PORT, () => {
    console.log(`🚀 Web server berjalan di http://localhost:${PORT}`);
    console.log(`📁 Download folder: ${config.downloadDir}`);
});
