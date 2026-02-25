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

// Tanda tangan khas
const signature = "𝓨𝓾𝓼 𝓑𝓪𝓼𝓽𝓲𝓪𝓷 〰";

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

function formatDuration(seconds) {
    if (!seconds || seconds === 'N/A') return 'N/A';
    const mins = Math.floor(seconds / 60);
    const secs = seconds % 60;
    return `${mins}:${secs.toString().padStart(2, '0')}`;
}

// ===================== ENDPOINT API UNTUK DAFTAR FILE =====================
app.get('/api/files', (req, res) => {
    try {
        const files = fs.readdirSync(config.downloadDir)
            .filter(f => f.endsWith('.mp3') || f.endsWith('.mp4'))
            .map(f => {
                const filePath = path.join(config.downloadDir, f);
                const stat = fs.statSync(filePath);
                // Cari file metadata dengan nama yang sama + .json
                const metaPath = filePath + '.json';
                let metadata = {};
                if (fs.existsSync(metaPath)) {
                    try {
                        metadata = JSON.parse(fs.readFileSync(metaPath, 'utf8'));
                    } catch (e) {
                        console.warn(`Gagal baca metadata ${metaPath}:`, e.message);
                    }
                }
                return {
                    name: f,
                    url: `/get/${encodeURIComponent(f)}`,
                    size: formatSize(stat.size),
                    created: stat.mtime,
                    title: metadata.title || f.replace(/\.(mp3|mp4)$/, ''),
                    uploader: metadata.uploader || 'Unknown',
                    duration: metadata.duration ? formatDuration(metadata.duration) : '?',
                    album: metadata.uploader || 'Unknown' // album = uploader
                };
            })
            .sort((a, b) => b.created - a.created);
        
        res.json({ files, signature });
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
                max-width: 1000px;
                width: 100%;
                background: rgba(255, 255, 255, 0.95);
                backdrop-filter: blur(10px);
                border-radius: 24px;
                padding: 40px;
                box-shadow: 0 30px 60px rgba(0,0,0,0.3);
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
            }
            button:hover {
                transform: translateY(-2px);
                box-shadow: 0 10px 25px rgba(102,126,234,0.4);
            }
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
            .success h3 { margin-bottom: 15px; display: flex; align-items: center; gap: 8px; }
            .track-info {
                background: white;
                border-radius: 12px;
                padding: 20px;
                margin-top: 15px;
                box-shadow: 0 2px 8px rgba(0,0,0,0.05);
            }
            .track-row {
                display: flex;
                padding: 10px 0;
                border-bottom: 1px dashed #e0e0e0;
            }
            .track-row:last-child { border-bottom: none; }
            .track-label {
                width: 100px;
                font-weight: 600;
                color: #666;
            }
            .track-value {
                flex: 1;
                color: #333;
                word-break: break-word;
            }
            .signature-text {
                color: #888;
                font-style: italic;
                margin-left: 5px;
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
                border-radius: 12px;
                padding: 15px;
                display: grid;
                grid-template-columns: 2fr 1fr 1fr 1fr auto;
                gap: 15px;
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
            .file-title {
                font-weight: 600;
                color: #333;
                overflow: hidden;
                text-overflow: ellipsis;
                white-space: nowrap;
            }
            .file-artist {
                color: #666;
                font-size: 0.9rem;
            }
            .file-album {
                color: #888;
                font-size: 0.9rem;
            }
            .file-duration {
                color: #555;
                font-size: 0.9rem;
                background: #eee;
                padding: 4px 8px;
                border-radius: 20px;
                text-align: center;
                width: fit-content;
            }
            .file-download {
                color: #764ba2;
                text-decoration: none;
                font-weight: 600;
                padding: 6px 12px;
                border-radius: 20px;
                transition: all 0.3s ease;
                white-space: nowrap;
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
                Download video & audio dari YouTube, Facebook, dan banyak lagi — dengan metadata lengkap!
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
                <p>File akan tersedia selama 60 detik setelah download. Signature: ${signature}</p>
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

                    // Baca metadata dari header
                    const title = response.headers.get('X-Metadata-Title') || 'Unknown';
                    const uploader = response.headers.get('X-Metadata-Uploader') || 'Unknown';
                    const duration = response.headers.get('X-Metadata-Duration') || '?';
                    const filesize = response.headers.get('X-Metadata-Size') || '?';
                    const filename = response.headers.get('X-Metadata-Filename') || 'download.' + type;

                    const blob = await response.blob();
                    const downloadUrl = window.URL.createObjectURL(blob);
                    const a = document.createElement('a');
                    a.href = downloadUrl;
                    a.download = filename;
                    document.body.appendChild(a);
                    a.click();
                    document.body.removeChild(a);
                    window.URL.revokeObjectURL(downloadUrl);

                    loading.style.display = 'none';
                    
                    // Ambil signature dari server
                    const fileApi = await fetch('/api/files');
                    const data = await fileApi.json();
                    const globalSignature = data.signature || "${signature}";
                    
                    successDiv.style.display = 'block';
                    successDiv.innerHTML = \`
                        <h3>✅ Download selesai!</h3>
                        <div class="track-info">
                            <div class="track-row">
                                <span class="track-label">Judul</span>
                                <span class="track-value">\${title}</span>
                            </div>
                            <div class="track-row">
                                <span class="track-label">Artis</span>
                                <span class="track-value">\${uploader}</span>
                            </div>
                            <div class="track-row">
                                <span class="track-label">Album</span>
                                <span class="track-value">\${uploader}</span>
                            </div>
                            <div class="track-row">
                                <span class="track-label">Durasi</span>
                                <span class="track-value">\${duration}</span>
                            </div>
                            <div class="track-row">
                                <span class="track-label">Ukuran</span>
                                <span class="track-value">\${filesize}</span>
                            </div>
                            <div class="track-row">
                                <span class="track-label">Link</span>
                                <span class="track-value">
                                    <a href="/get/\${encodeURIComponent(filename)}" target="_blank">/get/\${filename}</a>
                                    <span class="signature-text">\${globalSignature}</span>
                                </span>
                            </div>
                        </div>
                    \`;

                    loadFileList();

                } catch (err) {
                    loading.style.display = 'none';
                    errorDiv.style.display = 'block';
                    errorDiv.textContent = err.message;
                }
            });

            async function loadFileList() {
                try {
                    const response = await fetch('/api/files');
                    const data = await response.json();
                    
                    if (data.error) {
                        fileListContainer.innerHTML = '<div class="empty-list">' + data.error + '</div>';
                        return;
                    }

                    const files = data.files || [];
                    const globalSignature = data.signature || "${signature}";

                    if (files.length === 0) {
                        fileListContainer.innerHTML = '<div class="empty-list">Belum ada file.</div>';
                        return;
                    }

                    let html = '<ul class="file-list">';
                    files.slice(0, 15).forEach(file => {
                        html += \`
                            <li class="file-item">
                                <span class="file-title" title="\${file.title}">\${file.title}</span>
                                <span class="file-artist">\${file.uploader}</span>
                                <span class="file-album">\${file.album}</span>
                                <span class="file-duration">\${file.duration}</span>
                                <a href="\${file.url}" class="file-download" download>⬇️</a>
                            </li>
                        \`;
                    });
                    html += '</ul>';
                    html += '<p style="text-align:right; color:#888; margin-top:10px;">' + globalSignature + '</p>';
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
        // Ambil metadata video terlebih dahulu
        const infoCmd = `${config.ytdlBin} --dump-json --no-warnings ${config.cookiesFile ? `--cookies "${config.cookiesFile}"` : ''} --extractor-args "${config.ytExtractorArgs}" "${url}"`;
        const { stdout } = await execPromise(infoCmd);
        const info = JSON.parse(stdout);
        const title = info.title || 'Unknown';
        const uploader = info.uploader || 'Unknown';
        const duration = info.duration ? info.duration : 'N/A';

        // Download file
        let downloadCmd = `${config.ytdlBin} --no-warnings ${config.cookiesFile ? `--cookies "${config.cookiesFile}"` : ''} --extractor-args "${config.ytExtractorArgs}" --restrict-filenames -o "${outputTemplate}" "${url}"`;
        if (type === 'mp3') {
            downloadCmd += ` -x --audio-format mp3 --audio-quality 128K --ffmpeg-location "${config.ffmpegBin}" --embed-metadata --embed-thumbnail`;
        } else {
            downloadCmd += ` -f mp4 --embed-metadata`;
        }
        await execPromise(downloadCmd);

        // Cari file hasil download
        const files = fs.readdirSync(config.downloadDir)
            .filter(f => f.includes(`dl_${timestamp}_${randomStr}`))
            .sort((a, b) => fs.statSync(path.join(config.downloadDir, b)).mtimeMs - fs.statSync(path.join(config.downloadDir, a)).mtimeMs);

        if (files.length === 0) throw new Error('File tidak ditemukan');

        const fileName = files[0];
        const filePath = path.join(config.downloadDir, fileName);
        const fileSize = fs.statSync(filePath).size;

        // Simpan metadata ke file .json
        const metaPath = filePath + '.json';
        const metadata = {
            title,
            uploader,
            duration,
            size: fileSize,
            filename: fileName
        };
        fs.writeFileSync(metaPath, JSON.stringify(metadata, null, 2));

        // Set header untuk metadata
        res.setHeader('X-Metadata-Title', encodeURIComponent(title));
        res.setHeader('X-Metadata-Uploader', encodeURIComponent(uploader));
        res.setHeader('X-Metadata-Duration', formatDuration(duration));
        res.setHeader('X-Metadata-Size', formatSize(fileSize));
        res.setHeader('X-Metadata-Filename', encodeURIComponent(fileName));
        res.setHeader('Content-Disposition', `attachment; filename="${encodeURIComponent(fileName)}"`);
        res.setHeader('Content-Type', type === 'mp3' ? 'audio/mpeg' : 'video/mp4');

        const fileStream = fs.createReadStream(filePath);
        fileStream.pipe(res);

        fileStream.on('end', () => {
            setTimeout(() => {
                // Hapus file utama dan metadata
                fs.unlink(filePath, (err) => {
                    if (!err) console.log(`🗑️ File ${fileName} dihapus`);
                });
                fs.unlink(metaPath, (err) => {
                    if (!err) console.log(`🗑️ Metadata ${fileName}.json dihapus`);
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
    console.log(`✍️ Signature: ${signature}`);
});
