import irc.bot
import irc.strings
import threading
import time
import random
import os
import socket
import struct
import sys
import shutil
from collections import defaultdict
from datetime import datetime, timedelta

# ==================== KONFIGURASI ====================
IRC_SERVER = "irchat.online"
IRC_PORT = 6667
IRC_NICK = "Game"
IRC_PASSWORD = ""               # kosong jika tidak pakai NickServ

INITIAL_CHANNELS = ["#yobayat"]

UNO_POINTS_NAME = "Poin"
UNO_SCORE_FILE_TEMPLATE = "UnoScores_{channel}.txt"
UNO_MAX_PLAYERS = 10
UNO_AUTO_SKIP_PERIOD = 30
UNO_START_GRACE_PERIOD = 30
UNO_CYCLE_TIME = 5
UNO_ROBOT_RESTART_PERIOD = 1
UNO_DEBUG = 0

ADMIN_NICKS = ["Lemon"]

UNO_USE_DCC = True
DCC_PORT = 9999
DCC_PUBLIC_IP = "1.2.3.4"          # GANTI DENGAN IP PUBLIK BOT!

# ==================== KONSTANTA WARNA ====================
NICK_COLORS = ["06", "13", "03", "07", "12", "10", "04", "11", "09", "08", "05"]

COLOR_RED    = "\x030,04"
COLOR_GREEN  = "\x030,03"
COLOR_BLUE   = "\x030,12"
COLOR_YELLOW = "\x031,08"
COLOR_CYAN   = "\x0310"
COLOR_ORANGE = "\x0307"
COLOR_PURPLE = "\x0313"
BOLD         = "\x02"
RESET        = "\x0f"

UNO_LOGO = f"{BOLD}{COLOR_GREEN}U{COLOR_BLUE}N{COLOR_YELLOW}O{COLOR_RED}!{RESET}{BOLD}{RESET}"
COLOR_NAMES = {'R': 'Red', 'G': 'Green', 'B': 'Blue', 'Y': 'Yellow'}

# Mapping untuk menampilkan nama warna dengan warna sesuai
COLOR_DISPLAY = {
    'R': f"{COLOR_RED}Red{RESET}",
    'G': f"{COLOR_GREEN}Green{RESET}",
    'B': f"{COLOR_BLUE}Blue{RESET}",
    'Y': f"{COLOR_YELLOW}Yellow{RESET}"
}

UNO_WILD_CARD = f"{BOLD}{COLOR_YELLOW}W{COLOR_GREEN}I{COLOR_RED}L{COLOR_BLUE}D{RESET}{BOLD}{RESET}"
UNO_WILD_DRAW_FOUR_CARD = f"{BOLD}{COLOR_YELLOW}W{COLOR_GREEN}I{COLOR_RED}L{COLOR_BLUE}D {COLOR_YELLOW}D{COLOR_GREEN}r{COLOR_RED}a{COLOR_BLUE}w {COLOR_YELLOW}F{COLOR_GREEN}o{COLOR_RED}u{COLOR_BLUE}r{RESET}{BOLD}{RESET}"

# ==================== GLOBAL DCC CONNECTIONS ====================
dcc_connections = {}

# ==================== FUNGSI UTILITY ====================
def color_nick(nick):
    idx = hash(nick) % len(NICK_COLORS)
    return f"{RESET}\x03{NICK_COLORS[idx]}{nick}{RESET}"

def unocolornick(pnum):
    idx = (pnum - 1) % len(NICK_COLORS)
    return NICK_COLORS[idx]

def duration(seconds):
    m, s = divmod(int(seconds), 60)
    h, m = divmod(m, 60)
    parts = []
    if h: parts.append(f"{h}h")
    if m: parts.append(f"{m}m")
    if s or not parts: parts.append(f"{s}s")
    return " ".join(parts)

def get_score_filename(channel):
    safe_channel = channel.replace('#', '_').replace('!', '_').replace('?', '_')
    return UNO_SCORE_FILE_TEMPLATE.format(channel=safe_channel)

def backup_monthly_scores():
    now = datetime.now()
    backup_suffix = now.strftime("_%Y_%m.txt")
    for filename in os.listdir('.'):
        if filename.startswith("UnoScores_") and filename.endswith(".txt") and not filename.endswith(backup_suffix):
            backup_name = filename.replace(".txt", backup_suffix)
            try:
                shutil.copy(filename, backup_name)
                open(filename, 'w').close()
                print(f"Monthly score reset: backed up {filename} to {backup_name}")
            except Exception as e:
                print(f"Failed to backup {filename}: {e}")

def schedule_monthly_reset():
    now = datetime.now()
    if now.month == 12:
        next_month = now.replace(year=now.year+1, month=1, day=1, hour=0, minute=0, second=0, microsecond=0)
    else:
        next_month = now.replace(month=now.month+1, day=1, hour=0, minute=0, second=0, microsecond=0)
    delta = (next_month - now).total_seconds()
    print(f"Scheduled monthly reset in {delta/3600:.1f} hours (on {next_month})")
    threading.Timer(delta, do_monthly_reset).start()

def do_monthly_reset():
    backup_monthly_scores()
    for ch, game in games.items():
        if game and game.is_on:
            game.msg("Skor bulanan telah di-reset. Permainan dimulai dengan papan skor baru.")
    schedule_monthly_reset()

# ==================== FUNGSI KARTU ====================
def card_color(card): return card[0]
def card_value(card): return card[1] if len(card) > 1 else ''

def card_type(card):
    if len(card) == 1:
        return 'wild' if card == 'W' else 'invalid'
    col, val = card[0], card[1]
    if col == 'W':
        return 'draw4' if val == 'D' else 'wild'
    if val in ('S','R','D'):
        return {'S':'skip','R':'reverse','D':'draw2'}[val]
    return 'number'

def card_points(card):
    t = card_type(card)
    if t in ('wild','draw4'): return 50
    if t in ('skip','reverse','draw2'): return 20
    return int(card_value(card))

def card_display(card):
    if len(card) == 1 and card == 'W': return UNO_WILD_CARD
    col, val = card[0], card[1]
    if col == 'W' and val == 'D': return UNO_WILD_DRAW_FOUR_CARD
    color_name = COLOR_NAMES.get(col, 'Unknown')
    color_code = {'R':COLOR_RED,'G':COLOR_GREEN,'B':COLOR_BLUE,'Y':COLOR_YELLOW}.get(col,'')
    if val == 'S':
        return f"{color_code}{BOLD}{color_name} Skip{RESET}"
    if val == 'R':
        return f"{color_code}{BOLD}{color_name} Reverse{RESET}"
    if val == 'D':
        return f"{color_code}{BOLD}{color_name} Draw Two{RESET}"
    return f"{color_code}{BOLD}{color_name} {val}{RESET}"

def uno_cardcolorall(cards):
    return "  ".join(card_display(c) for c in cards)

def create_deck():
    deck = []
    for color in ['B','R','Y','G']:
        deck.append(f"{color}0")
        for i in range(1,10):
            deck.append(f"{color}{i}")
            deck.append(f"{color}{i}")
        for _ in range(2):
            deck.append(f"{color}S")
            deck.append(f"{color}R")
            deck.append(f"{color}D")
    for _ in range(4):
        deck.append("W")
        deck.append("WD")
    return deck

def shuffle_deck(deck):
    random.shuffle(deck)
    return deck

# ==================== DCC HANDLING ====================
class DCCConnection:
    def __init__(self, nick, sock, addr):
        self.nick = nick
        self.sock = sock
        self.addr = addr
        self.running = True
        self.thread = threading.Thread(target=self._handle)
        self.thread.daemon = True
        self.thread.start()
        self.send("Terhubung ke UnoBot DCC. Gunakan ca untuk melihat kartu Anda.")

    def _handle(self):
        try:
            while self.running:
                data = self.sock.recv(1024)
                if not data: break
        except Exception:
            pass
        finally:
            self.sock.close()
            if self.nick in dcc_connections and dcc_connections[self.nick] is self:
                del dcc_connections[self.nick]
                if UNO_DEBUG: print(f"DCC: {self.nick} disconnected")

    def send(self, msg):
        try:
            self.sock.sendall(msg.encode('utf-8') + b'\n')
        except Exception:
            pass

class DCCServer:
    def __init__(self, bot, port):
        self.bot = bot
        self.port = port
        self.sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        self.sock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
        self.sock.bind(('0.0.0.0', port))
        self.sock.listen(5)
        self.running = True
        self.thread = threading.Thread(target=self._run)
        self.thread.daemon = True
        self.thread.start()
        print(f"DCC server listening on port {port}")

    def _run(self):
        while self.running:
            try:
                client, addr = self.sock.accept()
                client.settimeout(10)
                data = client.recv(1024).decode('utf-8', errors='ignore').strip()
                if data:
                    nick = data
                    if nick in dcc_connections:
                        try: dcc_connections[nick].sock.close()
                        except: pass
                    conn = DCCConnection(nick, client, addr)
                    dcc_connections[nick] = conn
                    if UNO_DEBUG: print(f"DCC: {nick} connected from {addr}")
                else:
                    client.close()
            except Exception as e:
                if UNO_DEBUG: print(f"DCC server error: {e}")

    def stop(self):
        self.running = False
        self.sock.close()

# ==================== KELAS PEMAIN ====================
class Player:
    def __init__(self, nick):
        self.nick = nick
        self.hand = []
        self.dcc_idx = -1
        self.color_code = None
        self.team = None
        self.idle_streak = 0

    def add_card(self, card): self.hand.append(card)
    def remove_card(self, card): self.hand.remove(card)
    def hand_size(self): return len(self.hand)
    def hand_value(self): return sum(card_points(c) for c in self.hand)
    def has_card(self, card): return card in self.hand

    def sort_hand(self):
        order = {'B':0,'R':1,'Y':2,'G':3,'W':4}
        self.hand.sort(key=lambda c: (order.get(c[0],5), c[1:] if len(c)>1 else ''))

# ==================== KELAS TIM ====================
class Team:
    def __init__(self, name, captain):
        self.name = name
        self.captain = captain
        self.members = []
        self.team_points = 0

    def add_member(self, player):
        if player not in self.members:
            self.members.append(player)
            player.team = self

    def remove_member(self, player):
        if player in self.members:
            self.members.remove(player)
            player.team = None

    def is_captain(self, nick):
        return self.captain.nick == nick

    def member_nicks(self):
        return [p.nick for p in self.members]

# ==================== KELAS GAME ====================
class UnoGame:
    def __init__(self, bot, channel):
        self.bot = bot
        self.channel = channel
        self.is_on = False
        self.mode = 0
        self.paused = False
        self.players = []
        self.current_idx = 0
        self.deck = []
        self.discard = []
        self.top_card = None
        self.current_color = None
        self.current_rank = None
        self.color_picker = None
        self.is_color_change = False
        self.is_draw = False
        self.start_time = None
        self.last_winner = None
        self.wins_in_a_row = 0
        self.cards_played = 0
        self.unplayed_rounds = 0

        self.start_timer = None
        self.skip_timer = None
        self.cycle_timer = None
        self.bot_timer = None
        self.ad_timer = None

        self.robot_nick = self.bot.connection.get_nickname()
        self.auto_skip_period = UNO_AUTO_SKIP_PERIOD
        self.start_grace_period = UNO_START_GRACE_PERIOD
        self.cycle_time = UNO_CYCLE_TIME
        self.robot_restart_period = UNO_ROBOT_RESTART_PERIOD

        self.team_mode = False
        self.teams = []
        self.team_ready = False

        self.aggressive_mode = True
        self.auto_kick_enabled = True
        self.difficulty = 'hard'

        self.turn_symbols = ["||"]

        self.opponent_card_memory = defaultdict(lambda: defaultdict(int))
        self.opponent_last_played = {}
        self.opponent_favorite_color = defaultdict(lambda: {'R':0, 'G':0, 'B':0, 'Y':0})

        self.lock = threading.RLock()

    def _cancel_timers(self):
        with self.lock:
            for t in [self.start_timer, self.skip_timer, self.cycle_timer, self.bot_timer, self.ad_timer]:
                if t:
                    t.cancel()

    def _reset_skip_timer(self):
        with self.lock:
            if self.skip_timer:
                self.skip_timer.cancel()
            self.skip_timer = threading.Timer(self.auto_skip_period, self._auto_skip)
            self.skip_timer.daemon = True
            self.skip_timer.start()

    def _cancel_skip_timer(self):
        with self.lock:
            if self.skip_timer:
                self.skip_timer.cancel()
                self.skip_timer = None

    def _schedule_bot_move(self):
        with self.lock:
            if self.bot_timer:
                self.bot_timer.cancel()
            self.bot_timer = threading.Timer(self.robot_restart_period, self._robot_play)
            self.bot_timer.daemon = True
            self.bot_timer.start()

    def msg(self, text):
        self.bot.connection.privmsg(self.channel, f"{UNO_LOGO} {text}")

    def notice(self, nick, text):
        self.bot.connection.notice(nick, text)

    def unomsg(self, text):
        self.bot.connection.privmsg(self.channel, text)

    def send_private(self, nick, text):
        global dcc_connections
        if UNO_USE_DCC and nick in dcc_connections:
            dcc_connections[nick].send(text)
        else:
            self.notice(nick, text)

    def start(self, nick):
        with self.lock:
            if self.is_on:
                self.msg("Game sudah berjalan.")
                return
            self.is_on = True
            self.mode = 1
            self.players = []
            self.teams = []
            self.team_mode = False
            self.current_idx = 0
            self.deck = shuffle_deck(create_deck())
            self.discard = []
            self.start_time = int(time.time())
            self.unomsg(f"{COLOR_CYAN}UNO GAME{RESET}")
            self.msg(f"Game UNO dimulai! Ketik jo untuk bergabung ( {self.start_grace_period} detik )")
            self.start_timer = threading.Timer(self.start_grace_period, self._auto_start)
            self.start_timer.daemon = True
            self.start_timer.start()

    def _auto_start(self):
        with self.lock:
            if self.mode != 1:
                return
            if not self.players:
                self.msg("Tidak ada pemain. Game dibatalkan.")
                self.stop()
            else:
                self._begin_game()

    def stop(self, nick="console"):
        with self.lock:
            self._cancel_timers()
            self.is_on = False
            self.mode = 0
            self.players = []
            self.teams = []
            self.team_mode = False
            self.msg(f"{COLOR_RED}Game dihentikan oleh {nick}.{RESET}")

    def pause_game(self, nick):
        with self.lock:
            if not self.is_on or self.mode != 2:
                return
            if not self.paused:
                self.paused = True
                self._cancel_skip_timer()
                self.msg(f"{COLOR_ORANGE}Game dijeda oleh {nick}.{RESET}")
            else:
                self.msg("Game sudah dalam keadaan jeda.")

    def resume_game(self, nick):
        with self.lock:
            if not self.is_on or self.mode != 2:
                return
            if self.paused:
                self.paused = False
                self._reset_skip_timer()
                self.msg(f"{COLOR_GREEN}Game dilanjutkan oleh {nick}.{RESET}")
            else:
                self.msg("Game tidak dalam keadaan jeda.")

    def join(self, nick):
        with self.lock:
            if self.team_mode:
                self.notice(nick, "Gunakan .team join untuk bergabung dalam mode tim.")
                return
            if self.mode != 1 or self.paused:
                return
            if any(p.nick == nick for p in self.players):
                self.notice(nick, "Anda sudah bergabung.")
                return
            if len(self.players) >= UNO_MAX_PLAYERS:
                self.notice(nick, "Game sudah penuh.")
                return
            player = Player(nick)
            for _ in range(7):
                if not self.deck:
                    self._reshuffle_deck()
                player.add_card(self.deck.pop())
            player.sort_hand()
            player.color_code = unocolornick(len(self.players) + 1)
            self.players.append(player)
            self.unomsg(f"{COLOR_GREEN}>> {color_nick(nick)} bergabung {UNO_LOGO}{RESET}")
            self.send_private(nick, f"Kartu Anda: {uno_cardcolorall(player.hand)}")

    def join_bot(self):
        with self.lock:
            if any(p.nick == self.robot_nick for p in self.players):
                return
            bot_player = Player(self.robot_nick)
            for _ in range(7):
                if not self.deck:
                    self._reshuffle_deck()
                bot_player.add_card(self.deck.pop())
            bot_player.sort_hand()
            bot_player.color_code = unocolornick(len(self.players) + 1)
            self.players.append(bot_player)
            self.unomsg(f"{COLOR_GREEN}>> {color_nick(self.robot_nick)} bergabung {UNO_LOGO}{RESET}")

    def remove_player(self, nick, by_nick=None):
        with self.lock:
            player = self._get_player(nick)
            if not player:
                return
            idx = self.players.index(player)
            if by_nick:
                self.unomsg(f"{COLOR_RED}<< {color_nick(nick)} telah dikeluarkan dari uno oleh {by_nick}{RESET}")
            else:
                self.unomsg(f"{COLOR_RED}<< {color_nick(nick)} meninggalkan Uno{RESET}")

            if self.team_mode and player.team:
                player.team.remove_member(player)

            if self.is_color_change and nick == self.color_picker:
                cip = self._random_color()
                self.unomsg(f"{color_nick(nick)} telah memilih warna... Saya pilih secara acak {cip}")
                self.current_color = cip
                self.current_rank = ''
                self.is_color_change = False
                self.color_picker = None

            if nick == self._current_player().nick:
                self._next_player()
                if len(self.players) > 2:
                    self.unomsg(f"{color_nick(nick)} adalah pemain saat ini, dilanjutkan dengan {color_nick(self._current_player().nick)}")
                self._reset_skip_timer()

            self.players.pop(idx)
            for card in player.hand:
                self.discard.append(card)

            if len(self.players) == 1:
                self._win_default(self.players[0].nick)
                return
            if not self.players:
                self.unomsg("tidak ada pemain, tidak ada pemenang... rotasi")
                self._cycle()
                return
            if self._current_player().nick == self.robot_nick:
                self._schedule_bot_move()

    # ========== Mode Tim ==========
    def team_start_mode(self, nick):
        with self.lock:
            if self.is_on:
                self.notice(nick, "Game sudah berjalan. Gunakan .stop untuk menghentikan.")
                return
            self.is_on = True
            self.mode = 1
            self.team_mode = True
            self.players = []
            self.teams = []
            self.current_idx = 0
            self.deck = shuffle_deck(create_deck())
            self.discard = []
            self.start_time = int(time.time())
            self.unomsg(f"{COLOR_CYAN}UNO TEAM MODE{RESET}")
            self.msg("Mode tim diaktifkan. Buat tim dengan .team create <nama>")

    def team_create(self, nick, team_name):
        with self.lock:
            if not self.is_on or not self.team_mode or self.mode != 1:
                self.notice(nick, "Tidak dalam sesi mode tim. Mulai dengan .unotim")
                return
            if any(t.name.lower() == team_name.lower() for t in self.teams):
                self.notice(nick, f"Tim {team_name} sudah ada.")
                return
            if any(p.nick == nick for p in self.players):
                self.notice(nick, "Anda sudah tergabung dalam tim lain.")
                return
            player = Player(nick)
            team = Team(team_name, player)
            team.add_member(player)
            self.teams.append(team)
            self.players.append(player)
            self.unomsg(f"Tim {team_name} dibuat oleh {color_nick(nick)}. {nick} otomatis masuk game.")

    def team_join(self, nick, team_name):
        with self.lock:
            if not self.is_on or not self.team_mode or self.mode != 1:
                self.notice(nick, "Tidak dalam sesi mode tim. Mulai dengan .unotim")
                return
            if any(p.nick == nick for p in self.players):
                self.notice(nick, "Anda sudah tergabung dalam tim.")
                return
            team = next((t for t in self.teams if t.name.lower() == team_name.lower()), None)
            if not team:
                self.notice(nick, f"Tim {team_name} tidak ditemukan.")
                return
            player = Player(nick)
            team.add_member(player)
            self.players.append(player)
            self.unomsg(f"{color_nick(nick)} bergabung ke tim {team.name}.")

    def team_leave(self, nick):
        with self.lock:
            if not self.is_on or not self.team_mode or self.mode != 1:
                self.notice(nick, "Tidak dalam sesi mode tim.")
                return
            player = self._get_player(nick)
            if not player or not player.team:
                self.notice(nick, "Anda tidak tergabung dalam tim mana pun.")
                return
            team = player.team
            team.remove_member(player)
            self.players.remove(player)
            self.unomsg(f"{color_nick(nick)} meninggalkan tim {team.name}.")
            if not team.members:
                self.teams.remove(team)
                self.unomsg(f"Tim {team.name} dibubarkan karena kosong.")

    def team_list(self, nick):
        with self.lock:
            if not self.is_on or not self.team_mode:
                self.notice(nick, "Tidak dalam sesi mode tim.")
                return
            if not self.teams:
                self.unomsg("Belum ada tim.")
                return
            msg = "Daftar tim: "
            for t in self.teams:
                members = ", ".join(color_nick(m.nick) for m in t.members)
                msg += f"{t.name} ({members})  "
            self.unomsg(msg)

    def team_start_game(self, nick):
        with self.lock:
            if not self.is_on or not self.team_mode or self.mode != 1:
                self.notice(nick, "Tidak dalam sesi mode tim atau game sudah dimulai.")
                return
            if len(self.teams) < 2:
                self.notice(nick, "Butuh minimal 2 tim untuk memulai.")
                return
            if any(len(t.members) == 0 for t in self.teams):
                self.notice(nick, "Ada tim kosong. Hapus tim tersebut atau isi.")
                return
            self._begin_team_game()

    def _begin_team_game(self):
        with self.lock:
            max_members = max(len(t.members) for t in self.teams)
            ordered_players = []
            for i in range(max_members):
                for t in self.teams:
                    if i < len(t.members):
                        ordered_players.append(t.members[i])
            self.players = ordered_players

            for player in self.players:
                for _ in range(7):
                    if not self.deck:
                        self._reshuffle_deck()
                    player.add_card(self.deck.pop())
                player.sort_hand()
                player.color_code = unocolornick(self.players.index(player)+1)

            self.mode = 2
            self.current_idx = 0
            while True:
                if not self.deck:
                    self._reshuffle_deck()
                card = self.deck.pop()
                if card_type(card) == 'number':
                    self.discard.append(card)
                    self.top_card = card
                    self.current_color = card_color(card)
                    self.current_rank = card_value(card)
                    break
                self.deck.append(card)
                shuffle_deck(self.deck)

            self.unomsg(f"Selamat datang di {UNO_LOGO} mode tim!")
            team_list = "  ".join(f"{BOLD}{COLOR_CYAN}{t.name}{RESET}: {', '.join(color_nick(m.nick) for m in t.members)}" for t in self.teams)
            self.unomsg(f"Tim: {team_list}")
            self.unomsg(f"{COLOR_YELLOW}Urutan giliran:{RESET} " + " -> ".join(color_nick(p.nick) for p in self.players))
            self.unomsg(f"{BOLD}{COLOR_PURPLE}Kartu pertama: {card_display(self.top_card)}{RESET}")
            if card_type(self.top_card) == 'draw2':
                self._add_draw_to_hand(self._current_player(), 2)
                self.unomsg(f"{color_nick(self._current_player().nick)} mengambil dua kartu")
            self._show_cards_to_player(self._current_player())
            self._start_turn()

    def _begin_game(self):
        with self.lock:
            if len(self.players) == 1:
                self.join_bot()
            self.mode = 2
            random.shuffle(self.players)
            self.current_idx = 0
            while True:
                if not self.deck:
                    self._reshuffle_deck()
                card = self.deck.pop()
                if card_type(card) == 'number':
                    self.discard.append(card)
                    self.top_card = card
                    self.current_color = card_color(card)
                    self.current_rank = card_value(card)
                    break
                self.deck.append(card)
                shuffle_deck(self.deck)

            self.unomsg(f"Selamat datang di {UNO_LOGO}")
            self.unomsg(f"{len(self.players)} pemain pada putaran ini: " + " ".join(color_nick(p.nick) for p in self.players))
            self.unomsg(f"{BOLD}{COLOR_PURPLE}Kartu pertama: {card_display(self.top_card)}{RESET}")
            if card_type(self.top_card) == 'draw2':
                self._add_draw_to_hand(self._current_player(), 2)
                self.unomsg(f"{color_nick(self._current_player().nick)} mengambil dua kartu")
            self._show_cards_to_player(self._current_player())
            self._start_turn()

    def _reshuffle_deck(self):
        with self.lock:
            if len(self.discard) <= 1:
                return
            top = self.discard[-1]
            rest = self.discard[:-1]
            self.deck = shuffle_deck(rest)
            self.discard = [top]
            self.unomsg("\00304\002Re-shuffling deck\002")

    def _start_turn(self):
        with self.lock:
            player = self._current_player()
            symbol = random.choice(self.turn_symbols)
            self.unomsg(f"{symbol} GILIRAN {symbol} {color_nick(player.nick)}")
            self.is_draw = False
            self._reset_skip_timer()
            if player.nick == self.robot_nick:
                self._schedule_bot_move()

    def _next_player(self):
        with self.lock:
            self.current_idx = (self.current_idx + 1) % len(self.players)
            self.is_draw = False
            self._reset_skip_timer()
            self._start_turn()

    def _current_player(self):
        return self.players[self.current_idx]

    def _auto_skip(self):
        with self.lock:
            if self.mode != 2 or self.paused:
                return
            player = self._current_player()
            player.idle_streak += 1
            if self.auto_kick_enabled and player.idle_streak >= 2:
                self.unomsg(f"{color_nick(player.nick)} telah idle selama {self.auto_skip_period * player.idle_streak} detik dan dikeluarkan dari permainan.")
                self.remove_player(player.nick)
                return
            self.unomsg(f"{color_nick(player.nick)} telah idle dan dilewati. (idle ke-{player.idle_streak})")
            if self.is_color_change and player.nick == self.color_picker:
                cip = self._random_color()
                self.unomsg(f"{color_nick(player.nick)} telah memilih warna... Saya pilih secara acak {cip}")
                self.current_color = cip
                self.current_rank = ''
                self.is_color_change = False
                self.color_picker = None
            self._next_player()
            self._show_cards_to_player(self._current_player())
            if self._current_player().nick == self.robot_nick:
                self._schedule_bot_move()

    # ========== MEMORI LAWAN & AI ==========
    def _update_opponent_memory(self, nick, card):
        if nick == self.robot_nick:
            return
        col = card_color(card)
        if col in ['R','G','B','Y']:
            self.opponent_favorite_color[nick][col] += 1
        self.opponent_last_played[nick] = card

    def _predict_opponent_hand(self, nick):
        if nick not in self.opponent_favorite_color:
            return {'R':1, 'G':1, 'B':1, 'Y':1}
        return self.opponent_favorite_color[nick]

    def _get_opponents_near_win(self):
        return [p for p in self.players if p.nick != self.robot_nick and p.hand_size() <= 2]

    def _evaluate_card(self, card):
        ct = card_type(card)
        my_size = self._current_player().hand_size()
        base_scores = {'number':10, 'skip':150, 'reverse':150, 'draw2':200, 'wild':250, 'draw4':350}
        score = base_scores.get(ct, 10)
        if my_size == 1: score += 1000000
        if my_size == 2: score += 50000
        opponents_near_win = self._get_opponents_near_win()
        for opp in opponents_near_win:
            if opp.hand_size() == 1:
                if ct in ('skip','reverse','draw2','draw4'): score += 200000
                else: score += 20000
            elif opp.hand_size() == 2:
                if ct in ('skip','reverse','draw2','draw4'): score += 50000
        points = card_points(card)
        if ct == 'number':
            score += points * 5
            if my_size > 4: score += 100
        elif ct in ('skip','reverse','draw2'): score += points * 2
        elif ct in ('wild','draw4'):
            score += points * 2
            if any(opp.hand_size() <= 2 for opp in opponents_near_win): score += 100000
        return score

    def _bot_choose_card(self):
        player = self._current_player()
        valid_cards = [(i, card) for i, card in enumerate(player.hand) if self._is_valid_play(player, card)]
        if not valid_cards: return None
        scored = [(i, self._evaluate_card(card), card) for i, card in valid_cards]
        scored.sort(key=lambda x: x[1], reverse=True)
        return scored[0][0]

    def _bot_pick_color(self, card):
        player = self._current_player()
        remaining = [c for c in player.hand if c != card]
        my_colors = {'R':0,'G':0,'B':0,'Y':0}
        for c in remaining:
            col = card_color(c)
            if col in my_colors: my_colors[col] += 1
        if max(my_colors.values()) > 0:
            best = [col for col,cnt in my_colors.items() if cnt == max(my_colors.values())]
            return random.choice(best)
        opponent_fav = {'R':0,'G':0,'B':0,'Y':0}
        for p in self.players:
            if p.nick != self.robot_nick:
                fav = self._predict_opponent_hand(p.nick)
                for col in opponent_fav: opponent_fav[col] += fav.get(col, 1)
        if sum(opponent_fav.values()) > 0:
            return min(opponent_fav, key=opponent_fav.get)
        return random.choice(['R','G','B','Y'])

    def _is_valid_play(self, player, card):
        ct = card_type(card)
        if ct == 'draw4':
            for c in player.hand:
                if c == card: continue
                t = card_type(c)
                if t in ('wild','draw4'): continue
                if card_color(c) == self.current_color: return False
            return True
        if ct == 'wild': return True
        if card_color(card) == self.current_color: return True
        if card_value(card) == self.current_rank: return True
        return False

    def _robot_play(self):
        with self.lock:
            if self.mode != 2 or self.paused: return
            player = self._current_player()
            if player.nick != self.robot_nick: return
            if self.is_draw:
                idx = self._bot_choose_card()
                if idx is not None:
                    self.play_card_internal(self.robot_nick, player.hand[idx], from_bot=True)
                else:
                    self.pass_turn(self.robot_nick)
                return
            idx = self._bot_choose_card()
            if idx is not None:
                self.play_card_internal(self.robot_nick, player.hand[idx], from_bot=True)
            else:
                self.draw_card(self.robot_nick, from_bot=True)

    def play_card(self, nick, card_code):
        with self.lock:
            if self.mode != 2 or self.paused: return
            player = self._get_player(nick)
            if not player: return
            if nick != self._current_player().nick:
                self.notice(nick, "Bukan giliran Anda.")
                return
            card = next((c for c in player.hand if c == card_code), None)
            if not card:
                self.notice(nick, "Anda tidak memiliki kartu itu.")
                return
            if not self._is_valid_play(player, card):
                self.notice(nick, "Kartu tidak valid.")
                return
            self.play_card_internal(nick, card, from_bot=False)

    def play_card_internal(self, nick, card, from_bot=False):
        with self.lock:
            player = self._get_player(nick)
            player.idle_streak = 0
            player.remove_card(card)
            if nick != self.robot_nick:
                self._update_opponent_memory(nick, card)
            self.check_uno(player)
            self.discard.append(card)
            self.top_card = card
            self.cards_played += 1
            self._cancel_skip_timer()
            if player.hand_size() == 0:
                self._win(nick, card)
                return

            # Tampilkan kartu (hanya sekali, tanpa kata tambahan)
            self.unomsg(f"{color_nick(nick)} {card_display(card)}")

            ct = card_type(card)
            if ct in ('wild','draw4'):
                self._handle_wild_or_draw4(nick, card, ct, from_bot)
                return

            self.current_color = card_color(card)
            self.current_rank = card_value(card)
            if ct == 'skip':
                self._handle_skip(nick, from_bot)
            elif ct == 'reverse':
                self._handle_reverse(nick, from_bot)
            elif ct == 'draw2':
                self._handle_draw2(nick, from_bot)
            else:
                self._next_player()
                self._show_cards_to_player(self._current_player())
                if self._current_player().nick == self.robot_nick:
                    self._schedule_bot_move()

    def _handle_wild_or_draw4(self, nick, card, ct, from_bot):
        with self.lock:
            player = self._get_player(nick)
            if player.hand_size() == 0:
                self._win(nick, card)
                return
            if from_bot:
                chosen = self._bot_pick_color(card)
                self.unomsg(f"{color_nick(nick)} memilih warna {COLOR_DISPLAY[chosen]}")
                self.current_color = chosen
                self.current_rank = ''
                self.is_color_change = False
                if ct == 'draw4':
                    self._next_player()
                    victim = self._current_player()
                    self._add_draw_to_hand(victim, 4)
                    self.unomsg(f"{color_nick(victim.nick)} mengambil 4 kartu!")
                    self._next_player()
                else:
                    self._next_player()
                self._show_cards_to_player(self._current_player())
                if self._current_player().nick == self.robot_nick:
                    self._schedule_bot_move()
            else:
                self.is_color_change = True
                self.color_picker = nick
                self.unomsg(f"{color_nick(nick)}, pilih warna dengan co <R|G|B|Y>")
                self._cancel_skip_timer()

    def _handle_skip(self, player_nick, from_bot):
        with self.lock:
            self._next_player()
            victim = self._current_player()
            self._next_player()
            self.unomsg(f"{color_nick(player_nick)} SKIP! {color_nick(victim.nick)} dilewati.")
            self._show_cards_to_player(self._current_player())
            if self._current_player().nick == self.robot_nick:
                self._schedule_bot_move()

    def _handle_reverse(self, player_nick, from_bot):
        with self.lock:
            if len(self.players) > 2:
                self.players.reverse()
                self.current_idx = len(self.players) - 1 - self.current_idx
                self.unomsg("Arah permainan dibalik!")
                self._next_player()
            else:
                self._next_player()
                self._next_player()
            self._show_cards_to_player(self._current_player())
            if self._current_player().nick == self.robot_nick:
                self._schedule_bot_move()

    def _handle_draw2(self, player_nick, from_bot):
        with self.lock:
            self._next_player()
            victim = self._current_player()
            self._add_draw_to_hand(victim, 2)
            self.unomsg(f"{color_nick(victim.nick)} mengambil 2 kartu!")
            self._next_player()
            self._show_cards_to_player(self._current_player())
            if self._current_player().nick == self.robot_nick:
                self._schedule_bot_move()

    def _add_draw_to_hand(self, player, num):
        with self.lock:
            drawn = []
            for _ in range(num):
                if not self.deck: self._reshuffle_deck()
                card = self.deck.pop()
                player.add_card(card)
                drawn.append(card)
            player.sort_hand()
            return drawn

    def draw_card(self, nick, from_bot=False):
        with self.lock:
            if self.mode != 2 or self.paused: return
            player = self._get_player(nick)
            if not player: return
            player.idle_streak = 0
            for card in player.hand:
                if card_type(card) == 'draw4' and self._is_valid_play(player, card):
                    self.notice(nick, "Anda memiliki kartu Wild Draw Four yang bisa dimainkan! Anda harus memainkannya.")
                    return
            if nick != self._current_player().nick and not from_bot:
                self.notice(nick, "Bukan giliran Anda.")
                return
            if self.is_draw and not from_bot:
                self.notice(nick, "Anda telah mengambil kartu, mainkan atau pass.")
                return
            self.is_draw = True
            drawn = self._add_draw_to_hand(player, 1)
            self.check_uno(player)
            self.unomsg(f"{color_nick(nick)} mengambil 1 kartu.")
            if not from_bot:
                self.send_private(nick, f"Anda mengambil {card_display(drawn[0])}")
            else:
                self._schedule_bot_move()
            self._reset_skip_timer()

    def pass_turn(self, nick):
        with self.lock:
            if self.mode != 2 or self.paused: return
            if nick != self._current_player().nick:
                self.notice(nick, "Bukan giliran Anda.")
                return
            if not self.is_draw:
                self.notice(nick, "Anda hanya bisa pass setelah mengambil kartu (dr).")
                return
            player = self._get_player(nick)
            if player: player.idle_streak = 0
            self.unomsg(f"{color_nick(nick)} melewati giliran.")
            self.is_draw = False
            self._next_player()
            self._show_cards_to_player(self._current_player())
            if self._current_player().nick == self.robot_nick:
                self._schedule_bot_move()

    def color_change(self, nick, color):
        with self.lock:
            if self.mode != 2 or self.paused: return
            if not self.is_color_change or nick != self.color_picker: return
            player = self._get_player(nick)
            if player: player.idle_streak = 0
            color = color.upper()
            if color not in ('R','G','B','Y'):
                self.notice(nick, "Pilih R, G, B, atau Y.")
                return
            self.current_color = color
            self.current_rank = ''
            self.unomsg(f"{color_nick(nick)} memilih warna {COLOR_DISPLAY[color]}")
            self.is_color_change = False
            self.color_picker = None
            if card_type(self.discard[-1]) == 'draw4':
                self._next_player()
                victim = self._current_player()
                self._add_draw_to_hand(victim, 4)
                self.unomsg(f"{color_nick(victim.nick)} mengambil 4 kartu!")
                self._next_player()
            else:
                self._next_player()
            self._reset_skip_timer()
            self._show_cards_to_player(self._current_player())
            if self._current_player().nick == self.robot_nick:
                self._schedule_bot_move()

    def check_uno(self, player):
        if player.hand_size() == 1:
            self.unomsg(f"{BOLD}{COLOR_RED}° UNO °{RESET} {color_nick(player.nick)} tinggal 1 kartu!")

    # ==================== PERINTAH INFORMASI ====================
    def show_cards(self, nick):
        player = self._get_player(nick)
        if player and self.mode == 2:
            self.send_private(nick, f"Kartu Anda: {uno_cardcolorall(player.hand)}")

    def show_top_card(self):
        self.unomsg(f"{BOLD}{COLOR_CYAN}KARTU ATAS: {card_display(self.top_card)}{RESET}")

    def show_turn(self):
        self.unomsg(f"{BOLD}{COLOR_YELLOW}Current player: {color_nick(self._current_player().nick)}{RESET}")

    def show_order(self):
        order = "  ".join(color_nick(p.nick) for p in self.players)
        self.unomsg(f"{BOLD}{COLOR_CYAN}Player order:{RESET} {order}")

    def show_time(self):
        elapsed = time.time() - self.start_time
        self.unomsg(f"{BOLD}{COLOR_CYAN}Game time: {duration(elapsed)}{RESET}")

    def show_card_count(self):
        bars = []
        for p in self.players:
            bar = "|" * p.hand_size()
            bars.append(f"{color_nick(p.nick)} {bar} ({p.hand_size()})")
        self.unomsg("  ".join(bars))

    def show_stats(self):
        self.unomsg(f"{BOLD}{COLOR_CYAN}Cards played: {self.cards_played}{RESET}")

    def show_help(self, nick):
        self.send_private(nick, f"{BOLD}{COLOR_GREEN}UNO COMMANDS{RESET}")
        self.send_private(nick, "Game: .uno, .unotim, .stop, .remove [nick]")
        self.send_private(nick, "Info: .top10, .won [nick], .row, .version, .cmds")
        self.send_private(nick, "Admin: .pause, .play, .resetpoint, .reload, .aggressive, .autokick, .difficulty, .join, .part")
        self.send_private(nick, "Team: .team create|join|leave|list|start")
        self.send_private(nick, "In-game: jo, od, ti, ca, pl <kode>, a <kode>, cd, tu, dr, d, co <warna>, c <warna>, pa, ct, st")

    def show_version(self):
        self.unomsg(f"{BOLD}{COLOR_BLUE}Uno Bot v3.0 (by Lemon){RESET}")
        self.unomsg(f"{COLOR_GREEN}Features: team mode, colors, bot cards shown on loss, fixed Blackjack bonus{RESET}")

    def show_current_row(self):
        if self.last_winner:
            self.unomsg(f"{color_nick(self.last_winner)} sedang dalam {self.wins_in_a_row} kemenangan beruntun!")
        else:
            self.unomsg("Belum ada streak kemenangan")

    def _get_player(self, nick):
        for p in self.players:
            if p.nick == nick: return p
        return None

    def _show_cards_to_player(self, player):
        if player.nick != self.robot_nick:
            self.send_private(player.nick, f"Kartu Anda: {uno_cardcolorall(player.hand)}")

    def _random_color(self):
        return random.choice(['R','G','B','Y'])

    # ==================== PERHITUNGAN KEMENANGAN DENGAN BLACKJACK YANG BENAR ====================
    def _win(self, winner_nick, winning_card=None):
        with self.lock:
            self.mode = 3
            winner = self._get_player(winner_nick)
            if self.team_mode:
                winning_team = winner.team
                if not winning_team:
                    self._win_normal(winner_nick, winning_card)
                    return
                losing_teams = [t for t in self.teams if t != winning_team]
                total_loser_value = 0
                for team in losing_teams:
                    for p in team.members:
                        if p in self.players:
                            total_loser_value += p.hand_value()
                winner_points = total_loser_value + 50
                bonus_streak = 0
                if winner_nick == self.last_winner:
                    self.wins_in_a_row += 1
                else:
                    if self.last_winner:
                        self.unomsg(f"{color_nick(winner_nick)} mengakhiri streak {self.last_winner} ({self.wins_in_a_row} kemenangan).")
                    self.last_winner = winner_nick
                    self.wins_in_a_row = 1
                if winner_nick != self.robot_nick:
                    streak = self.wins_in_a_row
                    if 3 <= streak <= 15 and streak % 3 == 0:
                        bonus_streak = (streak // 3) * 350
                        self.unomsg(f"{color_nick(winner_nick)} bonus {bonus_streak} {UNO_POINTS_NAME} untuk {streak} win streak!")
                total = winner_points + bonus_streak
                # PERBAIKAN BLACKJACK: total nilai kartu lawan == 21
                if total_loser_value == 21:
                    total += 2100
                    self.unomsg(f"{BOLD}{COLOR_GREEN}BLACKJACK! Tim {winning_team.name} +2100 {UNO_POINTS_NAME}!{RESET}")
                self.unomsg(f"{BOLD}{COLOR_YELLOW} WINNER {RESET} Tim {winning_team.name} ({', '.join(color_nick(m.nick) for m in winning_team.members)})")
                self.unomsg(f"  {COLOR_GREEN}->{RESET} Mendapat {total} {UNO_POINTS_NAME}.")
                if winner_nick != self.robot_nick:
                    update_score(self.channel, winner_nick, total)
                for team in losing_teams:
                    for p in team.members:
                        penalty = p.hand_value() * 2
                        update_score(self.channel, p.nick, -penalty)
                        self.unomsg(f"{color_nick(p.nick)} kalah! {p.hand_size()} kartu (nilai {p.hand_value()}), -{penalty} {UNO_POINTS_NAME}.")
                        self.unomsg(f"  Kartu: {uno_cardcolorall(p.hand)}")
                self.unomsg(f"{BOLD}{COLOR_CYAN}STATS{RESET} Duration: {duration(time.time()-self.start_time)}  Cards: {self.cards_played}")
                self._cycle()
                return
            self._win_normal(winner_nick, winning_card)

    def _win_normal(self, winner_nick, winning_card=None):
        with self.lock:
            winner = self._get_player(winner_nick)
            total_loser = 0
            loser_vals = {}
            for p in self.players:
                if p.nick != winner_nick:
                    val = p.hand_value()
                    loser_vals[p.nick] = val
                    total_loser += val
            winner_points = total_loser + 50
            bonus = 0
            if winner_nick == self.last_winner:
                self.wins_in_a_row += 1
            else:
                if self.last_winner:
                    self.unomsg(f"{color_nick(winner_nick)} mengakhiri streak {self.last_winner} ({self.wins_in_a_row} kemenangan).")
                self.last_winner = winner_nick
                self.wins_in_a_row = 1
            if winner_nick != self.robot_nick:
                streak = self.wins_in_a_row
                if 3 <= streak <= 15 and streak % 3 == 0:
                    bonus = (streak // 3) * 350
                    self.unomsg(f"{color_nick(winner_nick)} bonus {bonus} {UNO_POINTS_NAME} untuk {streak} win streak!")
            total = winner_points + bonus
            # PERBAIKAN BLACKJACK: total nilai kartu lawan == 21
            if total_loser == 21:
                total += 2100
                self.unomsg(f"{BOLD}{COLOR_GREEN}BLACKJACK! {color_nick(winner_nick)} +2100 {UNO_POINTS_NAME}!{RESET}")
            if winning_card and winner_nick == self.robot_nick:
                self.unomsg(f"{BOLD}{COLOR_YELLOW} WINNER {RESET} {color_nick(winner_nick)} memainkan {card_display(winning_card)}!")
            else:
                self.unomsg(f"{BOLD}{COLOR_YELLOW} WINNER {RESET} {color_nick(winner_nick)}")
            self.unomsg(f"  {COLOR_GREEN}->{RESET} Mendapat {total} {UNO_POINTS_NAME}.")
            if winner_nick != self.robot_nick:
                update_score(self.channel, winner_nick, total)
            # Tampilkan semua pemain kalah termasuk bot
            for nick, val in loser_vals.items():
                penalty = val * 2
                update_score(self.channel, nick, -penalty)
                self.unomsg(f"{color_nick(nick)} kalah! {len(self._get_player(nick).hand)} kartu (nilai {val}), -{penalty} {UNO_POINTS_NAME}.")
                p = self._get_player(nick)
                if p:
                    self.unomsg(f"  Kartu: {uno_cardcolorall(p.hand)}")
            self.unomsg(f"{BOLD}{COLOR_CYAN}STATS{RESET} Duration: {duration(time.time()-self.start_time)}  Cards: {self.cards_played}")
            self._cycle()

    def _win_default(self, winner_nick):
        self.unomsg(f"{color_nick(winner_nick)} menang by default {UNO_LOGO}")
        self._win(winner_nick)

    def _cycle(self):
        with self.lock:
            self.mode = 4
            self._cancel_timers()
            self.cycle_timer = threading.Timer(self.cycle_time, self._restart)
            self.cycle_timer.daemon = True
            self.cycle_timer.start()

    def _restart(self):
        with self.lock:
            self.is_on = False
            self.mode = 0
            self.players = []
            self.teams = []
            self.team_mode = False
            self.start(self.robot_nick)

# ==================== MANAJEMEN SKOR ====================
def _read_scores(channel):
    scores = {}
    filename = get_score_filename(channel)
    if os.path.exists(filename):
        with open(filename, 'r') as f:
            for line in f:
                parts = line.strip().split()
                if len(parts) >= 3:
                    nick = parts[0]
                    games = int(parts[1])
                    points = int(parts[2])
                    scores[nick] = (games, points)
    return scores

def _write_scores(channel, scores):
    filename = get_score_filename(channel)
    with open(filename, 'w') as f:
        for nick, (games, points) in scores.items():
            f.write(f"{nick} {games} {points} 0\n")

def update_score(channel, nick, delta_points):
    scores = _read_scores(channel)
    games, points = scores.get(nick, (0, 0))
    games += 1 if delta_points > 0 else 0
    points += delta_points
    scores[nick] = (games, points)
    _write_scores(channel, scores)

def get_top10(channel, by='points'):
    scores = _read_scores(channel)
    items = [(nick, games, points) for nick, (games, points) in scores.items()]
    items.sort(key=lambda x: x[2 if by=='points' else 1], reverse=True)
    return items[:10]

def get_player_score(channel, nick):
    scores = _read_scores(channel)
    return scores.get(nick, (0, 0))

# ==================== DISPATCHER PERINTAH ====================
games = {}

def handle_pubmsg(bot, connection, nick, channel, message):
    if channel not in games:
        games[channel] = None
    game = games[channel]

    if message.startswith('.'):
        parts = message[1:].split()
        if not parts:
            return
        cmd = parts[0].lower()
        args = parts[1:]

        if cmd == 'join' and args:
            if nick not in ADMIN_NICKS:
                connection.notice(nick, "Anda tidak memiliki izin.")
                return
            target = args[0]
            if not target.startswith('#'):
                target = '#' + target
            connection.join(target)
            connection.privmsg(channel, f"{UNO_LOGO} Mencoba join {target}...")
            return

        if cmd == 'part' and args:
            if nick not in ADMIN_NICKS:
                connection.notice(nick, "Anda tidak memiliki izin.")
                return
            target = args[0]
            if target.lower() == channel.lower():
                connection.notice(nick, "Tidak bisa part dari channel tempat perintah.")
                return
            connection.part(target, f"Diminta oleh {nick}")
            if target in games:
                if games[target] and games[target].is_on:
                    games[target].stop("console")
                del games[target]
            return

        if cmd == 'uno':
            if game and game.is_on:
                connection.privmsg(channel, f"{UNO_LOGO} Game sudah berjalan.")
            else:
                game = UnoGame(bot, channel)
                games[channel] = game
                game.start(nick)
            return

        if cmd == 'unotim':
            if game and game.is_on:
                connection.privmsg(channel, f"{UNO_LOGO} Game sudah berjalan. Hentikan dulu dengan .stop")
                return
            game = UnoGame(bot, channel)
            games[channel] = game
            game.team_start_mode(nick)
            return

        if cmd == 'stop':
            if not game or not game.is_on:
                connection.notice(nick, "Tidak ada game aktif.")
                return
            if nick not in ADMIN_NICKS:
                connection.notice(nick, "Anda tidak memiliki izin.")
                return
            game.stop(nick)
            return

        if cmd == 'pause':
            if not game or not game.is_on:
                connection.notice(nick, "Tidak ada game aktif.")
                return
            if nick not in ADMIN_NICKS:
                connection.notice(nick, "Anda tidak memiliki izin.")
                return
            game.pause_game(nick)
            return

        if cmd == 'play':
            if not game or not game.is_on:
                connection.notice(nick, "Tidak ada game aktif.")
                return
            if nick not in ADMIN_NICKS:
                connection.notice(nick, "Anda tidak memiliki izin.")
                return
            game.resume_game(nick)
            return

        if cmd == 'remove':
            if not game or not game.is_on:
                connection.notice(nick, "Tidak ada game aktif.")
                return
            target = args[0] if args else nick
            if target != nick and nick not in ADMIN_NICKS:
                connection.notice(nick, "Anda tidak memiliki izin.")
                return
            game.remove_player(target, by_nick=nick if target != nick else None)
            return

        if cmd == 'resetpoint':
            if nick not in ADMIN_NICKS:
                connection.notice(nick, "Anda tidak memiliki izin.")
                return
            target = args[0] if args else None
            try:
                if target:
                    scores = _read_scores(channel)
                    if target in scores:
                        scores[target] = (0, 0)
                        _write_scores(channel, scores)
                        connection.privmsg(channel, f"{UNO_LOGO} Skor {target} di-reset.")
                    else:
                        connection.notice(nick, f"Pemain {target} tidak ditemukan.")
                else:
                    open(get_score_filename(channel), 'w').close()
                    connection.privmsg(channel, f"{UNO_LOGO} Semua skor di channel ini di-reset.")
            except Exception as e:
                connection.notice(nick, f"Gagal reset skor: {e}")
            return

        if cmd == 'reload':
            if nick not in ADMIN_NICKS:
                connection.notice(nick, "Anda tidak memiliki izin.")
                return
            if game and game.is_on:
                connection.notice(nick, "Stop game dulu dengan .stop")
                return
            connection.privmsg(channel, f"{UNO_LOGO} Bot akan di-reload...")
            os.execv(sys.executable, ['python'] + sys.argv)

        if cmd == 'aggressive':
            if nick not in ADMIN_NICKS:
                connection.notice(nick, "Izin ditolak.")
                return
            if not game:
                connection.notice(nick, "Game belum dimulai.")
                return
            game.aggressive_mode = not game.aggressive_mode
            state = "on" if game.aggressive_mode else "off"
            connection.privmsg(channel, f"{UNO_LOGO} Mode agresif bot {state} oleh {nick}.")
            return

        if cmd == 'autokick':
            if nick not in ADMIN_NICKS:
                return
            if not game:
                connection.notice(nick, "Game belum dimulai.")
                return
            if args and args[0].lower() in ('on','off'):
                game.auto_kick_enabled = (args[0].lower() == 'on')
                state = "diaktifkan" if game.auto_kick_enabled else "dinonaktifkan"
                connection.privmsg(channel, f"{UNO_LOGO} Auto-kick {state}.")
            else:
                connection.notice(nick, "Gunakan .autokick on/off")
            return

        if cmd == 'difficulty':
            if nick not in ADMIN_NICKS:
                return
            if not game:
                connection.notice(nick, "Game belum dimulai.")
                return
            if args and args[0].lower() in ('hard','medium','easy'):
                game.difficulty = args[0].lower()
                connection.privmsg(channel, f"{UNO_LOGO} Difficulty diubah ke {game.difficulty.upper()}.")
            else:
                connection.notice(nick, "Gunakan .difficulty hard/medium/easy")
            return

        if cmd in ('top10','rank'):
            by = args[0].lower() if args and args[0].lower() in ('games','points') else 'points'
            top = get_top10(channel, by)
            if not top:
                connection.privmsg(channel, f"{UNO_LOGO} Belum ada data.")
                return
            msg = f"{UNO_LOGO} Top 10 ({'poin' if by=='points' else 'menang'}): "
            for i, (n, g, p) in enumerate(top, 1):
                color = '03' if p >= 0 else '04'
                msg += f"{i}. \x03{color}{n}\x03 ({p})  "
            connection.privmsg(channel, msg)
            return

        if cmd == 'won':
            target = args[0] if args else nick
            games_cnt, points = get_player_score(channel, target)
            color = '03' if points >= 0 else '04'
            connection.privmsg(channel, f"{UNO_LOGO} \x03{color}{target}\x03: {points} {UNO_POINTS_NAME} dalam {games_cnt} game.")
            return

        if cmd == 'version':
            if game:
                game.show_version()
            else:
                connection.privmsg(channel, f"{UNO_LOGO} UnoBot Python - colors, team mode, bot cards shown on loss")
            return

        if cmd == 'row':
            if game:
                game.show_current_row()
            else:
                connection.notice(nick, "Tidak ada game aktif.")
            return

        if cmd in ('cmds','help'):
            if game:
                game.show_help(nick)
            else:
                connection.notice(nick, "Perintah: .uno .stop .top10 .won .version .row .pause .play .resetpoint .reload .aggressive .autokick .difficulty .join .part .remove .help .team")
            return

        if cmd == 'team':
            if not game or not game.is_on or not game.team_mode:
                connection.notice(nick, "Tidak dalam mode tim. Mulai dengan .unotim")
                return
            sub = args[0].lower() if args else None
            if sub == 'create' and len(args) >= 2:
                game.team_create(nick, args[1])
            elif sub == 'join' and len(args) >= 2:
                game.team_join(nick, args[1])
            elif sub == 'leave':
                game.team_leave(nick)
            elif sub == 'list':
                game.team_list(nick)
            elif sub == 'start':
                game.team_start_game(nick)
            else:
                connection.notice(nick, "Perintah tim: .team create <nama>, .team join <nama>, .team leave, .team list, .team start")
            return
        return

    if not game or not game.is_on:
        return

    cmd, *args = message.split()
    cmd = cmd.lower()
    if cmd == 'jo': game.join(nick)
    elif cmd == 'od': game.show_order()
    elif cmd == 'ti': game.show_time()
    elif cmd == 'ca': game.show_cards(nick)
    elif cmd == 'pl' and args: game.play_card(nick, args[0].upper())
    elif cmd == 'a' and args: game.play_card(nick, args[0].upper())
    elif cmd == 'cd': game.show_top_card()
    elif cmd == 'tu': game.show_turn()
    elif cmd == 'dr': game.draw_card(nick)
    elif cmd == 'd': game.draw_card(nick)
    elif cmd == 'co' and args: game.color_change(nick, args[0])
    elif cmd == 'c' and args: game.color_change(nick, args[0])
    elif cmd == 'pa': game.pass_turn(nick)
    elif cmd == 'ct': game.show_card_count()
    elif cmd == 'st': game.show_stats()

# ==================== BOT UTAMA ====================
class UnoBot(irc.bot.SingleServerIRCBot):
    def __init__(self):
        super().__init__([(IRC_SERVER, IRC_PORT)], IRC_NICK, IRC_NICK)
        self.initial_channels = INITIAL_CHANNELS
        if UNO_USE_DCC:
            self.dcc_port = DCC_PORT
            self.dcc_ip = DCC_PUBLIC_IP
            self.dcc_server = DCCServer(self, self.dcc_port)

    def on_nicknameinuse(self, c, e):
        c.nick(c.get_nickname() + "_")

    def on_welcome(self, c, e):
        try:
            if hasattr(c, 'buffer'):
                c.buffer.encoding = 'latin-1'
                c.buffer.errors = 'ignore'
        except Exception:
            pass
        for ch in self.initial_channels:
            c.join(ch)
            print(f"Joined {ch}")
        if IRC_PASSWORD:
            c.privmsg("NickServ", f"identify {IRC_PASSWORD}")
        schedule_monthly_reset()

    def on_pubmsg(self, c, e):
        nick = e.source.nick
        channel = e.target
        message = e.arguments[0]
        handle_pubmsg(self, c, nick, channel, message)

    def on_ctcp(self, c, e):
        if e.arguments[0].upper() == 'DCC' and UNO_USE_DCC:
            parts = e.arguments[1].split()
            if len(parts) >= 3 and parts[0].upper() == 'CHAT':
                ip_int = struct.unpack('>I', socket.inet_aton(self.dcc_ip))[0]
                response = f"DCC CHAT chat {ip_int} {self.dcc_port}"
                c.ctcp_reply(e.source.nick, response)
        else:
            super().on_ctcp(c, e)

if __name__ == "__main__":
    bot = UnoBot()
    print(f"Bot {IRC_NICK} mulai. Join ke channel: {', '.join(INITIAL_CHANNELS)} di {IRC_SERVER}...")
    if UNO_USE_DCC:
        print(f"DCC enabled on port {DCC_PORT} dengan IP {DCC_PUBLIC_IP} (GANTI jika perlu)")
    bot.start()
