const express = require('express');
const irc = require('irc-upd');
const path = require('path');
const fs = require('fs');
const { spawn } = require('child_process');
const crypto = require('crypto');

// ===================== KONFIGURASI =====================
const config = {
    ytdlBin: "/usr/local/bin/yt-dlp",
    ffmpegBin: "/usr/bin/ffmpeg",
    basePath: "/home/yuzu",
    downloadDir: "downloads",
    publicUrl: "http://47.250.210.218:2025/get/",
    cookiesFile: "/home/yuzu/eggdrop/cookies.txt",
    tmark: "Mp3",                // Nick IRC
    maxQueue: 5,
    maxFileSize: "50M",
    bitrate: "128K",
    proxy: "socks5://5.45.112.10:1080",  // Proxy, bisa dikosongkan jika tidak perlu
    port: 3000,
    socketTimeout: 15,            // Turunkan timeout jadi 15 detik
    retries: 1                     // Cukup 1 kali percobaan ulang (tanpa proxy)
};

const DOWNLOAD_DIR = path.join(config.basePath, config.downloadDir);

// Pastikan folder ada
if (!fs.existsSync(DOWNLOAD_DIR)) fs.mkdirSync(DOWNLOAD_DIR, { recursive: true });

// Sistem antrian
const queue = [];
let isProcessing = false;

// Statistik
const stats = {
    mp3: 0,
    m4a: 0,
    mp4: 0,
    total: 0,
    errors: 0,
    startTime: Date.now()
};

// ===================== FUNGSI BANTU =====================
function generateId() {
    return crypto.randomBytes(4).toString('hex').toUpperCase();
}

function formatSize(bytes) {
    const units = ['B', 'KB', 'MB', 'GB'];
    let size = bytes;
    let unitIdx = 0;
    while (size >= 1024 && unitIdx < units.length - 1) {
        size /= 1024;
        unitIdx++;
    }
    return `${size.toFixed(1)} ${units[unitIdx]}`;
}

function getTimestamp() {
    const now = new Date();
    return `[${now.toLocaleDateString()} ${now.toLocaleTimeString()}]`;
}

// ===================== PROSES ANTRIAN =====================
async function processQueue() {
    if (isProcessing || queue.length === 0) return;
    isProcessing = true;
    const task = queue.shift();

    console.log(`${getTimestamp()} Memproses task ${task.id} (${task.type})`);

    try {
        const result = await downloadWithRetry(task.query, task.type, task.id);
        if (task.callback) task.callback(result);
    } catch (err) {
        console.error(`${getTimestamp()} Error task ${task.id}: ${err.message}`);
        if (task.callback) task.callback({ success: false, error: err.message });
    } finally {
        isProcessing = false;
        stats.total++;
        processQueue();
    }
}

function addToQueue(query, type, callback) {
    if (queue.length >= config.maxQueue) {
        return { success: false, error: 'Antrian penuh (maks 5). Silakan tunggu.' };
    }
    const id = generateId();
    queue.push({ id, query, type, callback });
    console.log(`${getTimestamp()} Task ${id} (${type}) sedang mencari 🔍. Antrian: ${queue.length}`);
    processQueue();
    return { success: true, id, position: queue.length };
}

// ===================== FUNGSI DOWNLOAD DENGAN RETRY =====================
async function downloadWithRetry(query, type, taskId) {
    // Percobaan pertama: tanpa proxy (lebih cepat jika proxy bermasalah)
    try {
        console.log(`${getTimestamp()} Percobaan 1 (tanpa proxy)`);
        return await download(query, type, taskId, true); // withoutProxy = true
    } catch (err) {
        console.log(`${getTimestamp()} Percobaan 1 gagal: ${err.message}`);
        // Jika error bukan karena koneksi, langsung berhenti
        if (!err.message.includes('timed out') && !err.message.includes('Timeout') && !err.message.includes('Connection')) {
            stats.errors++;
            return { success: false, id: taskId, error: err.message };
        }
        // Percobaan kedua: dengan proxy (jika tersedia)
        if (config.proxy) {
            try {
                console.log(`${getTimestamp()} Percobaan 2 (dengan proxy)`);
                return await download(query, type, taskId, false); // with proxy
            } catch (err2) {
                console.log(`${getTimestamp()} Percobaan 2 gagal: ${err2.message}`);
                stats.errors++;
                return { success: false, id: taskId, error: err2.message };
            }
        } else {
            stats.errors++;
            return { success: false, id: taskId, error: err.message };
        }
    }
}

// ===================== FUNGSI DOWNLOAD UTAMA (REVISI) =====================
function download(query, type = 'mp3', taskId, withoutProxy = false) {
    const id = taskId || generateId();
    let input = query.trim();
    if (!input.startsWith('http')) input = `ytsearch1:${input}`;

    let ext;
    if (type === 'mp3') ext = 'mp3';
    else if (type === 'm4a') ext = 'm4a';
    else if (type === 'mp4') ext = 'mp4';
    else throw new Error('Tipe tidak didukung');

    // Bangun argumen untuk yt-dlp dengan parameter anti-captcha
    let args = [
        '--cookies', config.cookiesFile,
        '--no-warnings',
        '--restrict-filenames',
        '--force-overwrites',
        '-o', `${DOWNLOAD_DIR}/%(title)s.%(ext)s`,
        '--max-filesize', config.maxFileSize,
        '--user-agent', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36',
        '--sleep-requests', '1.5',
        '--sleep-interval', '3',          // dinaikkan jadi 3 detik
        '--max-sleep-interval', '7',       // dinaikkan jadi 7 detik
        '--socket-timeout', config.socketTimeout.toString(),
        // --- PARAMETER KHUSUS UNTUK BYPASS CAPTCHA & BLOKIR ---
        '--extractor-args', 'youtube:player_client=web,tv',   // tiru request dari web & TV
        '--remote-components', 'ejs:github',                  // unduh komponen JS terbaru untuk n-sig
        // '--no-check-certificates',                         // (opsional) jika ada masalah SSL
    ];

    // Tambahkan PO Token jika server tersedia (ganti URL sesuai dengan server Anda)
    // Pastikan server PO Token berjalan di 127.0.0.1:4416
    args.push('--extractor-args', 'youtubepot-bgutilhttp:base_url=http://127.0.0.1:4416');

    // Jika proxy digunakan (dan withoutProxy = false)
    if (!withoutProxy && config.proxy) {
        args.push('--proxy', config.proxy);
    }

    // Penanganan format audio/video
    if (type === 'mp3' || type === 'm4a') {
        args.push('-x', '--audio-format', type, '--audio-quality', config.bitrate,
                  '--ffmpeg-location', config.ffmpegBin,
                  '--embed-metadata', '--embed-thumbnail', '--add-metadata',
                  '--parse-metadata', 'uploader:%(album)s');
    } else if (type === 'mp4') {
        args.push('-f', 'bestvideo[height<=1080]+bestaudio/best[height<=1080]',
                  '--merge-output-format', 'mp4',
                  '--embed-metadata');
    }

    args.push('--print-json', input);

    console.log(`${getTimestamp()} Menjalankan: ${config.ytdlBin} ${args.join(' ').substring(0, 300)}...`);

    return new Promise((resolve, reject) => {
        const ytProcess = spawn(config.ytdlBin, args);
        let stdout = '';
        let stderr = '';

        ytProcess.stdout.on('data', (data) => {
            stdout += data.toString();
        });

        ytProcess.stderr.on('data', (data) => {
            stderr += data.toString();
            // Tampilkan stderr agar terlihat progres (bisa dihapus jika ingin lebih tenang)
            process.stderr.write(`[yt-dlp] ${data.toString()}`);
        });

        ytProcess.on('close', (code) => {
            if (code !== 0) {
                reject(new Error(stderr || `Process exited with code ${code}`));
                return;
            }

            try {
                const lines = stdout.trim().split('\n');
                const jsonLine = lines[lines.length - 1];
                const info = JSON.parse(jsonLine);

                // Cari file terbaru
                const files = fs.readdirSync(DOWNLOAD_DIR)
                    .filter(f => f.endsWith(`.${ext}`))
                    .map(f => ({
                        name: f,
                        path: path.join(DOWNLOAD_DIR, f),
                        mtime: fs.statSync(path.join(DOWNLOAD_DIR, f)).mtimeMs
                    }))
                    .sort((a, b) => b.mtime - a.mtime);

                if (files.length === 0) {
                    reject(new Error('File tidak ditemukan setelah download'));
                    return;
                }

                const file = files[0];
                const fileSize = fs.statSync(file.path).size;
                const url = config.publicUrl + encodeURIComponent(file.name);

                // Update statistik
                if (type === 'mp3') stats.mp3++;
                else if (type === 'm4a') stats.m4a++;
                else if (type === 'mp4') stats.mp4++;

                // Hapus file setelah 60 detik
                setTimeout(() => {
                    if (fs.existsSync(file.path)) {
                        fs.unlinkSync(file.path);
                        console.log(`${getTimestamp()} File ${file.name} dihapus.`);
                    }
                }, 60000);

                console.log(`${getTimestamp()} Berhasil: ${file.name} (${formatSize(fileSize)})`);

                resolve({
                    success: true,
                    id,
                    url,
                    fileName: file.name,
                    size: formatSize(fileSize),
                    title: info.title,
                    duration: info.duration ? `${Math.floor(info.duration / 60)}:${(info.duration % 60).toString().padStart(2, '0')}` : 'N/A',
                    uploader: info.uploader || 'Unknown'
                });
            } catch (err) {
                reject(new Error(`Gagal parse JSON: ${err.message}\nStdout: ${stdout.substring(0, 200)}`));
            }
        });

        ytProcess.on('error', (err) => {
            reject(err);
        });
    });
}

// ===================== API ENDPOINT =====================
const app = express();
app.use(express.json());

app.post('/api/download', async (req, res) => {
    const { query, type = 'mp3' } = req.body;
    if (!query) return res.status(400).json({ error: 'Query diperlukan' });
    if (!['mp3', 'm4a', 'mp4'].includes(type)) {
        return res.status(400).json({ error: 'Tipe harus mp3, m4a, atau mp4' });
    }

    const result = addToQueue(query, type, (downloadResult) => {});
    if (!result.success) return res.status(429).json(result);

    res.json({
        success: true,
        message: 'Ditambahkan ke antrian',
        taskId: result.id,
        position: result.position
    });
});

app.get('/api/stats', (req, res) => {
    const uptime = Math.floor((Date.now() - stats.startTime) / 1000);
    res.json({
        mp3: stats.mp3,
        m4a: stats.m4a,
        mp4: stats.mp4,
        total: stats.total,
        errors: stats.errors,
        queue: queue.length,
        processing: isProcessing,
        uptime: `${Math.floor(uptime / 60)}m ${uptime % 60}s`
    });
});

// ===================== BOT IRC =====================
const bot = new irc.Client('irchat.online', config.tmark, {
    channels: ['#yobayat'],
    port: 6667,
    userName: config.tmark.toLowerCase(),
    realName: 'MP3/M4A/MP4 Downloader'
});

bot.addListener('registered', () => {
    console.log(`${getTimestamp()} IRC connected as ${config.tmark}`);
});

bot.addListener('message', async (from, to, text) => {
    const target = to.startsWith('#') ? to : from;
    const cmd = text.trim();

    const handleDownload = (prefix, type) => {
        const q = cmd.substring(prefix.length).trim();
        if (!q) return bot.say(target, `Gunakan: ${prefix} <judul/link>`);

        const queueResult = addToQueue(q, type, (result) => {
            if (result.success) {
                bot.say(target, `✅ ${result.title} | Ukuran: ${result.size} | Durasi: ${result.duration} | Download: ${result.url} (File akan dihapus dalam 60 detik)`);
            } else {
                bot.say(target, `❌ Gagal: ${result.error.substring(0, 200)}`);
            }
        });

        if (queueResult.success) {
            bot.say(target, `⏳ Task ${queueResult.id} dalam antrian (posisi ${queueResult.position})`);
        } else {
            bot.say(target, `⚠️ ${queueResult.error}`);
        }
    };

    if (/^[!.?]mp3\b/i.test(cmd)) handleDownload(cmd.match(/^[!.?]mp3/i)[0], 'mp3');
    else if (/^[!.?]m4a\b/i.test(cmd)) handleDownload(cmd.match(/^[!.?]m4a/i)[0], 'm4a');
    else if (/^[!.?]mp4\b/i.test(cmd)) handleDownload(cmd.match(/^[!.?]mp4/i)[0], 'mp4');
    else if (cmd === '!queue') bot.say(target, `Antrian: ${queue.length} | Diproses: ${isProcessing ? 'Ya' : 'Tidak'}`);
    else if (cmd === '!stats') {
        const uptime = Math.floor((Date.now() - stats.startTime) / 1000);
        bot.say(target, `MP3: ${stats.mp3} | M4A: ${stats.m4a} | MP4: ${stats.mp4} | Total: ${stats.total} | Error: ${stats.errors} | Uptime: ${Math.floor(uptime / 60)}m`);
    } else if (cmd === '!help' || cmd === '.help') {
        bot.say(target, 'Perintah: !mp3 <query>, !m4a <query>, !mp4 <query>, !queue, !stats');
    }
});

bot.addListener('error', (err) => {
    console.log(`IRC Error: ${err}`);
});

// ===================== JALANKAN SERVER =====================
app.listen(config.port, () => {
    console.log(`${getTimestamp()} Server berjalan di port ${config.port}`);
    console.log(`${getTimestamp()} Folder download: ${DOWNLOAD_DIR}`);
    console.log(`${getTimestamp()} IRC bot: ${config.tmark}@irchat.online`);
    console.log(`${getTimestamp()} Tipe didukung: mp3, m4a, mp4`);
});
