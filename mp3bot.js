const express = require('express');
const irc = require('irc-upd');
const shell = require('shelljs');
const path = require('path');
const fs = require('fs');
const cors = require('cors');
const { exec } = require('child_process');
const util = require('util');
const execPromise = util.promisify(exec);

// ===================== KONFIGURASI =====================
const config = {
    ytdlBin: "/usr/local/bin/yt-dlp",
    ffmpegBin: "/usr/bin/ffmpeg",
    path: "/home/yuzu",
    downloadDir: "downloads",
    // Base URL web server (dengan trailing slash)
    linkdl: "http://47.250.210.218:2025/get/",
    cookiesFile: "/home/yuzu/eggdrop/cookies.txt",
    tubeRest: 50,
    tmark: "mp3",   // Nick bot di IRC
    ytExtractorArgs: "youtube:player-client=default,mweb"
};

const DOWNLOAD_DIR = path.join(config.path, config.downloadDir);
const PUBLIC_URL = config.linkdl;

// Pastikan folder siap
if (!fs.existsSync(DOWNLOAD_DIR)) {
    shell.mkdir('-p', DOWNLOAD_DIR);
    shell.chmod('755', DOWNLOAD_DIR);
}

// ===================== KONFIGURASI TAMBAHAN =====================
const PORT = 3000; // Port untuk API dan web internal (tidak digunakan untuk publik)

// Warna untuk console
const colors = {
    red: '\x1b[31m',
    green: '\x1b[32m',
    yellow: '\x1b[33m',
    blue: '\x1b[34m',
    cyan: '\x1b[36m',
    purple: '\x1b[35m',
    reset: '\x1b[0m'
};

// Emoji
const emoji = {
    music: '🎵',
    download: '📥',
    success: '✅',
    error: '❌',
    file: '📁',
    size: '📊',
    duration: '⏱️',
    link: '🔗',
    lemon: '🍋',
    clock: '⏳',
    search: '🔍',
    wait: '⏸️',
    fire: '🔥',
    warning: '⚠️',
    album: '💿',
    cover: '🖼️'
};

// Tanda tangan baru
const signature = "𝓨𝓾𝓼 𝓑𝓪𝓼𝓽𝓲𝓪𝓷 〰";

const app = express();
app.use(cors());
app.use(express.json());

// Statistik
const stats = {
    mp3: 0,
    mp4: 0,
    search: 0,
    totalDownloads: 0,
    totalSize: 0,
    startTime: Date.now()
};

console.log(`${colors.cyan}╔══════════════════════════════════════╗${colors.reset}`);
console.log(`${colors.cyan}║${colors.yellow}     🍋 LEMON MP3 v7 ULTIMATE 🍋       ${colors.cyan}║${colors.reset}`);
console.log(`${colors.cyan}╠══════════════════════════════════════╣${colors.reset}`);
console.log(`${colors.cyan}║${colors.green}  ✨ Fitur Keren:${colors.reset}`);
console.log(`${colors.cyan}║${colors.white}  • Download MP3/MP4${colors.reset}`);
console.log(`${colors.cyan}║${colors.white}  • Box border keren${colors.reset}`);
console.log(`${colors.cyan}║${colors.white}  • Auto-delete 60s${colors.reset}`);
console.log(`${colors.cyan}║${colors.white}  • Progress bar${colors.reset}`);
console.log(`${colors.cyan}║${colors.white}  • Metadata album & cover art${colors.reset}`);
console.log(`${colors.cyan}║${colors.white}  • Statistics${colors.reset}`);
console.log(`${colors.cyan}╚══════════════════════════════════════╝${colors.reset}`);

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

function sanitizeFilename(str) {
    return str.replace(/[\\/*?:"<>|]/g, '_').trim();
}

// ===================== FUNGSI DOWNLOAD =====================
async function downloadWithYtDlp(query, type = 'mp3') {
    let input = query.trim();
    if (!input.startsWith('http')) input = `ytsearch1:${input}`;

    console.log(`${colors.cyan}[Processing] ${input}${colors.reset}`);

    try {
        console.log(`${colors.cyan}${emoji.search} Mengambil info video...${colors.reset}`);
        
        const infoCmd = `${config.ytdlBin} --dump-json --cookies "${config.cookiesFile}" --no-warnings --extractor-args "${config.ytExtractorArgs}" "${input}"`;
        const { stdout: infoStdout } = await execPromise(infoCmd);
        
        const videoInfo = JSON.parse(infoStdout);
        const judul = videoInfo.title;
        const durasi = videoInfo.duration || 'N/A';
        const uploader = videoInfo.uploader || 'Unknown';
        const views = videoInfo.view_count || 0;

        let downloadCmd = `${config.ytdlBin} --cookies "${config.cookiesFile}" --no-warnings --extractor-args "${config.ytExtractorArgs}" --restrict-filenames --force-overwrites -o "${config.path}/${config.downloadDir}/%(title)s.%(ext)s"`;
        
        if (type === 'mp3') {
            // Konversi ke mp3, set kualitas, embed metadata (album diisi uploader), dan embed thumbnail
            downloadCmd += ` -x --audio-format mp3 --audio-quality 128K --ffmpeg-location "${config.ffmpegBin}" --parse-metadata "uploader:%(album)s" --embed-metadata --embed-thumbnail`;
        } else {
            // Untuk mp4, embed metadata saja (album diisi uploader), thumbnail tidak diembed karena format video biasanya tidak mendukung cover art
            downloadCmd += ` -f mp4 --parse-metadata "uploader:%(album)s" --embed-metadata`;
        }
        
        downloadCmd += ` "${input}"`;

        console.log(`${colors.cyan}╭──────────────────────────────────────╮${colors.reset}`);
        console.log(`${colors.cyan}│${colors.yellow}      ${type === 'mp3' ? emoji.music : '🎬'} ${type.toUpperCase()} DOWNLOADER ${type === 'mp3' ? emoji.music : '🎬'} ${colors.cyan}     │${colors.reset}`);
        console.log(`${colors.cyan}├──────────────────────────────────────┤${colors.reset}`);
        console.log(`${colors.cyan}│${colors.white}  ${emoji.file} Judul: ${colors.green}${judul.substring(0, 30)}...${colors.reset}`);
        console.log(`${colors.cyan}│${colors.white}  ${emoji.duration} Durasi: ${colors.yellow}${durasi} detik${colors.reset}`);
        console.log(`${colors.cyan}│${colors.white}  ${emoji.download} Mengunduh...${colors.reset}`);
        if (type === 'mp3') {
            console.log(`${colors.cyan}│${colors.white}  ${emoji.cover} Thumbnail akan diembed${colors.reset}`);
        }
        console.log(`${colors.cyan}╰──────────────────────────────────────╯${colors.reset}`);

        await execPromise(downloadCmd);

        const files = fs.readdirSync(DOWNLOAD_DIR)
            .filter(f => f.endsWith(`.${type}`))
            .map(f => ({
                name: f,
                path: path.join(DOWNLOAD_DIR, f),
                time: fs.statSync(path.join(DOWNLOAD_DIR, f)).mtime.getTime()
            }))
            .sort((a, b) => b.time - a.time);

        if (files.length === 0) {
            throw new Error('File tidak ditemukan');
        }

        const latestFile = files[0];
        const filePath = latestFile.path;
        const fileName = latestFile.name;
        const fileSize = fs.statSync(filePath).size;

        stats[type]++;
        stats.totalDownloads++;
        stats.totalSize += fileSize;

        fs.chmodSync(filePath, '644');

        // Gunakan base URL yang sudah diatur (dengan /get/)
        const url = config.linkdl + encodeURIComponent(fileName);
        const sizeFormatted = formatSize(fileSize);
        const viewsFormatted = views > 1000000 ? (views/1000000).toFixed(1) + 'M' : 
                              views > 1000 ? (views/1000).toFixed(1) + 'K' : views;

        console.log(`${colors.green}╭──────────────────────────────────────╮${colors.reset}`);
        console.log(`${colors.green}│${colors.yellow}      ${emoji.success} DOWNLOAD SELESAI! ${emoji.success} ${colors.green}       │${colors.reset}`);
        console.log(`${colors.green}├──────────────────────────────────────┤${colors.reset}`);
        console.log(`${colors.green}│${colors.white}  ${emoji.file} File: ${colors.cyan}${fileName}${colors.reset}`);
        console.log(`${colors.green}│${colors.white}  ${emoji.size} Ukuran: ${colors.yellow}${sizeFormatted}${colors.reset}`);
        console.log(`${colors.green}│${colors.white}  ${emoji.duration} Durasi: ${colors.yellow}${formatDuration(durasi)}${colors.reset}`);
        console.log(`${colors.green}│${colors.white}  👁️ Views: ${colors.purple}${viewsFormatted}${colors.reset}`);
        console.log(`${colors.green}│${colors.white}  🎤 Uploader: ${colors.blue}${uploader}${colors.reset}`);
        console.log(`${colors.green}│${colors.white}  ${emoji.album} Album: ${colors.magenta}${uploader}${colors.reset}`);
        if (type === 'mp3') {
            console.log(`${colors.green}│${colors.white}  ${emoji.cover} Cover art: ✅${colors.reset}`);
        }
        // Gabungkan link dengan signature (hanya spasi)
        console.log(`${colors.green}│${colors.white}  ${emoji.link} Link: ${colors.blue}${url}  ${colors.purple}${signature}${colors.reset}`);
        console.log(`${colors.green}╰──────────────────────────────────────╯${colors.reset}`);

        console.log(`${colors.yellow}${emoji.clock} File akan dihapus dalam ${config.tubeRest} detik...${colors.reset}`);
        setTimeout(() => {
            if (fs.existsSync(filePath)) {
                fs.unlinkSync(filePath);
                console.log(`${colors.yellow}🗑️ File ${fileName} telah dihapus.${colors.reset}`);
            }
        }, config.tubeRest * 1000);

        return {
            success: true,
            url,
            fileName,
            size: sizeFormatted,
            duration: formatDuration(durasi),
            judul,
            uploader,
            views: viewsFormatted,
            hasThumbnail: type === 'mp3',
            filePath
        };

    } catch (error) {
        console.log(`${colors.red}╭──────────────────────────────────────╮${colors.reset}`);
        console.log(`${colors.red}│${colors.white}      ${emoji.error} ERROR ${emoji.error} ${colors.red}                   │${colors.reset}`);
        console.log(`${colors.red}├──────────────────────────────────────┤${colors.reset}`);
        console.log(`${colors.red}│${colors.white}  ${error.message}${colors.reset}`);
        console.log(`${colors.red}╰──────────────────────────────────────╯${colors.reset}`);
        return { success: false, error: error.message };
    }
}

// ===================== API ROUTES =====================
app.post('/api/download', async (req, res) => {
    const { query, type = 'mp3' } = req.body;
    if (!query) return res.status(400).json({ error: 'Query kosong' });
    
    const result = await downloadWithYtDlp(query, type);
    if (result.success) {
        res.json(result);
    } else {
        res.status(500).json({ error: result.error });
    }
});

app.get('/api/stats', (req, res) => {
    const uptime = Math.floor((Date.now() - stats.startTime) / 1000);
    const uptimeFormatted = `${Math.floor(uptime / 3600)}j ${Math.floor((uptime % 3600) / 60)}m ${uptime % 60}d`;
    
    res.json({
        ...stats,
        uptime: uptimeFormatted,
        totalSizeFormatted: formatSize(stats.totalSize)
    });
});

app.get('/api/files', (req, res) => {
    const files = fs.readdirSync(DOWNLOAD_DIR)
        .filter(f => f.endsWith('.mp3') || f.endsWith('.mp4'))
        .map(f => ({
            name: f,
            url: config.linkdl + encodeURIComponent(f),
            size: formatSize(fs.statSync(path.join(DOWNLOAD_DIR, f)).size),
            created: fs.statSync(path.join(DOWNLOAD_DIR, f)).mtime
        }))
        .sort((a, b) => b.created - a.created);
    
    res.json(files);
});

// ===================== BOT IRC =====================
const bot = new irc.Client('irchat.online', config.tmark, {
    channels: ['#yobayat'],
    port: 6667,
    secure: false,
    userName: config.tmark.toLowerCase(),
    realName: `${config.tmark} MP3 Bot v7 (with cover art)`
});

bot.addListener('message', async (from, to, text) => {
    const cleanText = text.replace(/\x1b\[[0-9;]*m/g, '');

    // Command MP3
    if (cleanText.startsWith('!mp3') || cleanText.startsWith('.mp3') || cleanText.startsWith('?mp3')) {
        const q = cleanText.substring(5).trim();
        if (!q) {
            return bot.say(to, `${emoji.warning} ${from}, judul lagunya mana?`);
        }

        bot.say(to, `╭──────────────────────────────────────╮`);
        bot.say(to, `│      🎵 LEMON MP3 BOT 🎵             │`);
        bot.say(to, `├──────────────────────────────────────┤`);
        bot.say(to, `│  Dari: ${from}`);
        bot.say(to, `│  🔍 Mencari: ${q}`);
        bot.say(to, `│  ⏸️ Mohon tunggu...`);
        bot.say(to, `╰──────────────────────────────────────╯`);

        const result = await downloadWithYtDlp(q, 'mp3');

        if (result.success) {
            bot.say(to, `╭──────────────────────────────────────╮`);
            bot.say(to, `│      ✅ FILE DI TEMUKAN! ✅           │`);
            bot.say(to, `├──────────────────────────────────────┤`);
            bot.say(to, `│  📁 File: ${result.fileName}`);
            bot.say(to, `│  📊 Ukuran: ${result.size}`);
            bot.say(to, `│  ⏱️ Durasi: ${result.duration}`);
            bot.say(to, `│  💿 Album: ${result.uploader}`);
            bot.say(to, `│  🖼️ Cover art: ✅ (terembed)`);
            // Gabungkan link dengan signature (hanya spasi, tanpa "|")
            bot.say(to, `│  🔗 Link: ${result.url}  ${signature}`);
            bot.say(to, `╰──────────────────────────────────────╯`);
            
            bot.say(to, `⏳ File akan dihapus dalam ${config.tubeRest} detik...`);
            
        } else {
            bot.say(to, `╭──────────────────────────────────────╮`);
            bot.say(to, `│      ❌ GAGAL ❌                      │`);
            bot.say(to, `├──────────────────────────────────────┤`);
            bot.say(to, `│  ${result.error}`);
            bot.say(to, `╰──────────────────────────────────────╯`);
        }
    }

    // Command MP4
    if (cleanText.startsWith('!mp4') || cleanText.startsWith('.mp4')) {
        const q = cleanText.substring(5).trim();
        if (!q) {
            return bot.say(to, `${emoji.warning} ${from}, judul videonya mana?`);
        }

        bot.say(to, `╭──────────────────────────────────────╮`);
        bot.say(to, `│      🎬 LEMON MP4 BOT 🎬              │`);
        bot.say(to, `├──────────────────────────────────────┤`);
        bot.say(to, `│  Dari: ${from}`);
        bot.say(to, `│  🔍 Mencari: ${q}`);
        bot.say(to, `│  ⏸️ Mohon tunggu...`);
        bot.say(to, `╰──────────────────────────────────────╯`);

        const result = await downloadWithYtDlp(q, 'mp4');

        if (result.success) {
            bot.say(to, `╭──────────────────────────────────────╮`);
            bot.say(to, `│      ✅ FILE DI TEMUKAN! ✅           │`);
            bot.say(to, `├──────────────────────────────────────┤`);
            bot.say(to, `│  📁 File: ${result.fileName}`);
            bot.say(to, `│  📊 Ukuran: ${result.size}`);
            bot.say(to, `│  ⏱️ Durasi: ${result.duration}`);
            bot.say(to, `│  💿 Album: ${result.uploader}`);
            // Gabungkan link dengan signature (hanya spasi)
            bot.say(to, `│  🔗 Link: ${result.url}  ${signature}`);
            bot.say(to, `╰──────────────────────────────────────╯`);
            
            bot.say(to, `⏳ File akan dihapus dalam ${config.tubeRest} detik...`);
            
        } else {
            bot.say(to, `╭──────────────────────────────────────╮`);
            bot.say(to, `│      ❌ GAGAL ❌                      │`);
            bot.say(to, `├──────────────────────────────────────┤`);
            bot.say(to, `│  ${result.error}`);
            bot.say(to, `╰──────────────────────────────────────╯`);
        }
    }

    // Command Help
    if (cleanText === '!help' || cleanText === '.help' || cleanText === '?help') {
        bot.say(to, `╔══════════════════════════════════════╗`);
        bot.say(to, `║     🍋 LEMON MP3 COMMANDS 🍋         ║`);
        bot.say(to, `╠══════════════════════════════════════╣`);
        bot.say(to, `║  🎵 MUSIC`);
        bot.say(to, `║  !mp3 <judul/link> - Download MP3`);
        bot.say(to, `║  !mp4 <judul/link> - Download MP4`);
        bot.say(to, `╠══════════════════════════════════════╣`);
        bot.say(to, `║  📊 INFO`);
        bot.say(to, `║  !stats - Statistik bot`);
        bot.say(to, `║  !files - List file`);
        bot.say(to, `╚══════════════════════════════════════╝`);
    }

    // Command Stats
    if (cleanText === '!stats') {
        const uptime = Math.floor((Date.now() - stats.startTime) / 1000);
        const uptimeFormatted = `${Math.floor(uptime / 3600)}j ${Math.floor((uptime % 3600) / 60)}m`;
        
        bot.say(to, `╔══════════════════════════════════════╗`);
        bot.say(to, `║     📊 LEMON MP3 STATS 📊           ║`);
        bot.say(to, `╠══════════════════════════════════════╣`);
        bot.say(to, `║  🎵 MP3: ${stats.mp3}`);
        bot.say(to, `║  🎬 MP4: ${stats.mp4}`);
        bot.say(to, `║  📈 Total: ${stats.totalDownloads}`);
        bot.say(to, `║  💾 Size: ${formatSize(stats.totalSize)}`);
        bot.say(to, `║  ⏱️ Uptime: ${uptimeFormatted}`);
        bot.say(to, `╚══════════════════════════════════════╝`);
    }

    // Command Files
    if (cleanText === '!files') {
        const files = fs.readdirSync(DOWNLOAD_DIR)
            .filter(f => f.endsWith('.mp3') || f.endsWith('.mp4'))
            .sort()
            .slice(0, 5);

        if (files.length === 0) {
            bot.say(to, `📂 Folder kosong`);
        } else {
            bot.say(to, `╔══════════════════════════════════════╗`);
            bot.say(to, `║     📁 FILE TERBARU                ║`);
            bot.say(to, `╠══════════════════════════════════════╣`);
            files.forEach((f, i) => {
                bot.say(to, `║  ${i+1}. ${f.substring(0, 30)}`);
            });
            bot.say(to, `╚══════════════════════════════════════╝`);
        }
    }
});

bot.addListener('error', (err) => {
    console.log(`${colors.red}IRC Error: ${err}${colors.reset}`);
});

// ===================== JALANKAN SERVER =====================
app.listen(PORT, () => {
    console.log(`${colors.green}╔══════════════════════════════════════╗${colors.reset}`);
    console.log(`${colors.green}║${colors.yellow}     🍋 ${config.tmark} ENGINE v7 READY 🍋      ${colors.green}║${colors.reset}`);
    console.log(`${colors.green}╠══════════════════════════════════════╣${colors.reset}`);
    console.log(`${colors.green}║${colors.white}  🌐 Port: ${colors.cyan}${PORT}${colors.reset}`);
    console.log(`${colors.green}║${colors.white}  📁 Download: ${colors.cyan}${DOWNLOAD_DIR}${colors.reset}`);
    console.log(`${colors.green}║${colors.white}  🔗 Public URL: ${colors.cyan}${PUBLIC_URL}${colors.reset}`);
    console.log(`${colors.green}║${colors.white}  🤖 IRC Bot: ${colors.cyan}${config.tmark}@irchat.online${colors.reset}`);
    console.log(`${colors.green}║${colors.white}  💿 Metadata: Album + Cover Art${colors.reset}`);
    console.log(`${colors.green}║${colors.white}  ✍️ Signature: ${signature}${colors.reset}`);
    console.log(`${colors.green}╚══════════════════════════════════════╝${colors.reset}`);
});
