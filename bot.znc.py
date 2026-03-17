#!/usr/bin/env python3
import irc.client
import random
import string
import re
import time

# ==================== KONFIGURASI ====================
ZNC_HOST = "47.250.210.218"
ZNC_PORT = 2030
ZNC_USERNAME = "Admin"
ZNC_NETWORK = "irchat"
ZNC_PASSWORD = "solupa"

IRC_SERVER = "irchat.online"
IRC_PORT = 6667
CHANNEL = "#yobayat"
CONTROL_PANEL = "*controlpanel"

ADMINS = ["Lemon"]

# Realname default untuk user ZNC (dengan kode warna IRC)
DEFAULT_REALNAME = "12Y11 O00 B12 A11 Y00 A12 T"

users = {}  # username -> data

def generate_password(length=12):
    chars = string.ascii_letters + string.digits
    return ''.join(random.choice(chars) for _ in range(length))

def is_valid_username(username):
    return re.match(r'^[a-zA-Z0-9_]+$', username) is not None

def is_valid_email(email):
    return '@' in email and '.' in email

class ZNCBot(irc.client.SimpleIRCClient):
    def __init__(self):
        irc.client.SimpleIRCClient.__init__(self)
        self.nickname = "ZNC-BOT"
        self.realname = "Y O B A Y A T"
        self.password = f"{ZNC_USERNAME}/{ZNC_NETWORK}:{ZNC_PASSWORD}"
        self.connection.buffer_class.errors = 'replace'

    def on_welcome(self, conn, event):
        print("Identifikasi berhasil, join channel...")
        conn.join(CHANNEL)

    def on_join(self, conn, event):
        print(f"Bergabung ke {event.target}")

    def on_pubmsg(self, conn, event):
        self.handle_message(event, is_channel=True)

    def on_privmsg(self, conn, event):
        self.handle_message(event, is_channel=False)

    def handle_message(self, event, is_channel):
        msg = event.arguments[0]
        sender = event.source.nick
        target = event.target if is_channel else sender

        print(f"Pesan dari {sender}: {msg}")

        if not msg.startswith('?'):
            return

        parts = msg.split()
        cmd = parts[0][1:].lower()
        args = parts[1:]

        # ========== PERINTAH UNTUK SEMUA USER ==========
        if cmd == 'request':
            if len(args) < 2:
                self.connection.privmsg(target, "Format: ?request <username> <email>")
                return
            username = args[0]
            email = args[1]
            if not is_valid_username(username):
                self.connection.privmsg(target, "Username hanya boleh huruf, angka, underscore.")
                return
            if not is_valid_email(email):
                self.connection.privmsg(target, "Email tidak valid.")
                return
            if username in users:
                self.connection.privmsg(target, f"Username {username} sudah digunakan.")
                return

            users[username] = {
                'nick': sender,
                'email': email,
                'password': generate_password(),
                'status': 'pending'
            }
            self.connection.privmsg(target, f"{sender}: Permintaan akun untuk {username} diterima. Menunggu konfirmasi (bisa kamu konfirmasi sendiri dengan ?confirm {username}).")
            return

        elif cmd == 'confirm':
            if len(args) < 1:
                self.connection.privmsg(target, "Format: ?confirm <username>")
                return
            username = args[0]
            if username not in users or users[username]['status'] != 'pending':
                self.connection.privmsg(target, f"User {username} tidak ditemukan atau sudah diproses.")
                return

            # Cek otorisasi: admin atau pemilik akun
            if sender not in ADMINS and sender != users[username]['nick']:
                self.connection.privmsg(target, "Anda tidak berhak mengkonfirmasi akun ini.")
                return

            u = users[username]
            # Kirim perintah ke controlpanel ZNC
            self.connection.privmsg(CONTROL_PANEL, f"adduser {username} {u['password']}")
            time.sleep(0.3)
            self.connection.privmsg(CONTROL_PANEL, f"addnetwork {username} {ZNC_NETWORK}")
            time.sleep(0.3)
            self.connection.privmsg(CONTROL_PANEL, f"addserver {username} {ZNC_NETWORK} {IRC_SERVER} {IRC_PORT}")
            time.sleep(0.3)
            self.connection.privmsg(CONTROL_PANEL, f"addchan {username} {ZNC_NETWORK} {CHANNEL}")
            time.sleep(0.3)
            self.connection.privmsg(CONTROL_PANEL, f"Set realname {username} {DEFAULT_REALNAME}")
            time.sleep(0.3)
            self.connection.privmsg(CONTROL_PANEL, f"reconnect {username} {ZNC_NETWORK}")

            # Kirim detail ke user via PM
            self.connection.privmsg(u['nick'], "Akun ZNC Anda telah dikonfirmasi dan berhasil dibuat.")
            self.connection.privmsg(u['nick'], f"Username: {username}")
            self.connection.privmsg(u['nick'], f"Password: {u['password']}")
            self.connection.privmsg(u['nick'], f"Server ZNC: {ZNC_HOST}")
            self.connection.privmsg(u['nick'], f"Port ZNC: {ZNC_PORT}")
            self.connection.privmsg(u['nick'], f"Network: {ZNC_NETWORK}")
            self.connection.privmsg(u['nick'], f"Gunakan format username: {username}/{ZNC_NETWORK}")
            self.connection.privmsg(u['nick'], "Setelah login, kamu akan otomatis terhubung ke "+IRC_SERVER+":"+str(IRC_PORT)+" dan join "+CHANNEL)

            u['status'] = 'confirmed'
            if sender != u['nick']:
                self.connection.privmsg(target, f"User {username} telah dikonfirmasi oleh admin.")
            else:
                self.connection.privmsg(target, f"Selamat {sender}, akun Anda telah diaktifkan. Cek PM untuk detail.")
            return

        elif cmd == 'help':
            help_lines = [
                "Perintah umum:",
                "  ?request <username> <email> - Meminta akun ZNC",
                "  ?confirm <username> - Mengkonfirmasi akun sendiri (jika sudah request)",
                "Perintah admin:",
                "  ?listunconfirmed / ?luu - Lihat daftar pending",
                "  ?deny <username> - Tolak permintaan",
                "  ?deluser <username> - Hapus user dari ZNC",
                "  ?help - Tampilkan bantuan ini"
            ]
            for line in help_lines:
                self.connection.privmsg(sender if is_channel else target, line)
            if is_channel:
                self.connection.privmsg(target, f"{sender}: Cek PM untuk bantuan.")
            return

        # ========== PERINTAH KHUSUS ADMIN ==========
        if sender not in ADMINS:
            self.connection.privmsg(target, "Maaf, perintah ini hanya untuk admin.")
            return

        if cmd == 'listunconfirmed' or cmd == 'luu':
            pending = [f"{u} ({d['email']})" for u, d in users.items() if d['status'] == 'pending']
            if not pending:
                self.connection.privmsg(target, "Tidak ada user pending.")
            else:
                self.connection.privmsg(target, "User pending: " + ', '.join(pending))

        elif cmd == 'deny':
            if len(args) < 1:
                self.connection.privmsg(target, "Format: ?deny <username>")
                return
            username = args[0]
            if username not in users or users[username]['status'] != 'pending':
                self.connection.privmsg(target, f"User {username} tidak ditemukan atau sudah diproses.")
                return
            self.connection.privmsg(users[username]['nick'], f"Maaf, permintaan akun ZNC Anda ({username}) ditolak oleh admin.")
            del users[username]
            self.connection.privmsg(target, f"User {username} telah ditolak.")

        elif cmd == 'deluser':
            if len(args) < 1:
                self.connection.privmsg(target, "Format: ?deluser <username>")
                return
            username = args[0]
            self.connection.privmsg(CONTROL_PANEL, f"deluser {username}")
            if username in users:
                del users[username]
            self.connection.privmsg(target, f"User {username} telah dihapus dari ZNC.")

        else:
            self.connection.privmsg(target, "Perintah tidak dikenal. Ketik ?help untuk bantuan.")

def main():
    reactor = irc.client.Reactor()
    try:
        c = reactor.server().connect(
            ZNC_HOST,
            ZNC_PORT,
            "ZNC-BOT",
            password=f"{ZNC_USERNAME}/{ZNC_NETWORK}:{ZNC_PASSWORD}"
        )
    except irc.client.ServerConnectionError as e:
        print(f"Gagal connect: {e}")
        return

    bot = ZNCBot()
    bot.connection = c
    c.add_global_handler("welcome", bot.on_welcome)
    c.add_global_handler("pubmsg", bot.on_pubmsg)
    c.add_global_handler("privmsg", bot.on_privmsg)
    c.add_global_handler("join", bot.on_join)

    reactor.process_forever()

if __name__ == "__main__":
    main()
