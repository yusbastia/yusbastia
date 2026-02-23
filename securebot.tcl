###############################################################################
# Modern Eggdrop Security Script by Lemon
# Fitur: autentikasi bcrypt, manajemen channel, seen, proteksi badword
# Disesuaikan untuk keamanan dan kemudahan pemeliharaan
# Memerlukan package: bcrypt (tcl-bcrypt), http, tls, json (opsional)
###############################################################################

package require bcrypt
package require http
package require tls
package require json

namespace eval ::SecureBot {
    variable version "2.0"
    variable debug 0
    variable botnick ""
    variable owner ""
    variable notc "\002\00304Secure\003Bot\002"
    variable notm $notc
    variable notd $notc
    variable ban-time 5
    variable badwords [list "pendo" "luji" "pemai" "kontol" "memek" "bangsat" "fuck" "shit" "anjing" "babi"]
    variable channels_allow "*"
    variable cmd_prefix "`"
    variable pub_flags "-"
    variable throttle_user 5
    variable throttle_chan 5
    variable throttle_link 5
    variable seen_data  ;# array untuk seen
}

# Prosedur logging debug
proc ::SecureBot::debug {msg} {
    variable debug
    if {$debug} { putlog "\[SecureBot\] $msg" }
}

# Prosedur untuk mengirim pesan dengan prefix
proc ::SecureBot::putmsg {target msg} {
    variable notc
    puthelp "PRIVMSG $target :$notc $msg"
}

proc ::SecureBot::putnotice {target msg} {
    variable notc
    puthelp "NOTICE $target :$notc $msg"
}

# ====================== AUTENTIKASI ======================

# Menyimpan password dengan bcrypt
proc ::SecureBot::set_password {nick pass} {
    if {[bcrypt::crypt $pass] eq ""} { return 0 }
    setuser $nick PASS [bcrypt::crypt $pass 10]
    save
    return 1
}

# Verifikasi password
proc ::SecureBot::check_password {nick pass} {
    set stored [getuser $nick PASS]
    if {$stored eq ""} { return 0 }
    return [bcrypt::check $pass $stored]
}

# Perintah /msg pass <password>
bind msg - pass ::SecureBot::msg_pass
proc ::SecureBot::msg_pass {nick uhost hand rest} {
    variable notc
    set pass [string trim $rest]
    if {$pass eq ""} {
        putnotice $nick "Usage: pass <password>"
        return
    }
    if {[getuser $nick PASS] ne ""} {
        putnotice $nick "You already have a password. Use auth <password>"
        return
    }
    if {[set_password $nick $pass]} {
        putnotice $nick "Password set successfully (hashed)."
    } else {
        putnotice $nick "Error setting password."
    }
}

# Perintah /msg auth <password>
bind msg - auth ::SecureBot::msg_auth
proc ::SecureBot::msg_auth {nick uhost hand rest} {
    variable notc
    set pass [string trim $rest]
    if {$pass eq ""} {
        putnotice $nick "Usage: auth <password>"
        return
    }
    if {[check_password $nick $pass]} {
        # Beri flag +Q (user terautentikasi)
        chattr $nick +Q
        putnotice $nick "Authentication successful."
        # Hapus hostmask lama dan set hostmask saat ini
        foreach h [getuser $nick HOSTS] { delhost $nick $h }
        setuser $nick HOSTS "*!*@[lindex [split $uhost @] 1]"
        save
    } else {
        putnotice $nick "Wrong password."
    }
}

# Perintah /msg deauth
bind msg - deauth ::SecureBot::msg_deauth
proc ::SecureBot::msg_deauth {nick uhost hand rest} {
    variable notc
    if {![matchattr $nick Q]} {
        putnotice $nick "You are not logged in."
        return
    }
    chattr $nick -Q
    putnotice $nick "Logged out."
}

# ====================== PERINTAH CHANNEL ======================
# Perintah publik dengan prefix (misal `op, `kick, dll)
bind pub $::SecureBot::pub_flags "${::SecureBot::cmd_prefix}*" ::SecureBot::pub_cmd
proc ::SecureBot::pub_cmd {nick uhost hand chan text} {
    variable notc
    if {![matchattr $nick Q]} {
        putmsg $chan "$nick, you are not logged in. Use .auth <password>"
        return
    }
    set cmd [lindex $text 0]
    set args [lrange $text 1 end]
    switch -exact -- $cmd {
        "op" { pub_op $nick $uhost $hand $chan $args }
        "deop" { pub_deop $nick $uhost $hand $chan $args }
        "voice" { pub_voice $nick $uhost $hand $chan $args }
        "devoice" { pub_devoice $nick $uhost $hand $chan $args }
        "kick" { pub_kick $nick $uhost $hand $chan $args }
        "kickban" { pub_kickban $nick $uhost $hand $chan $args }
        "ban" { pub_ban $nick $uhost $hand $chan $args }
        "unban" { pub_unban $nick $uhost $hand $chan $args }
        "mode" { pub_mode $nick $uhost $hand $chan $args }
        "topic" { pub_topic $nick $uhost $hand $chan $args }
        "invite" { pub_invite $nick $uhost $hand $chan $args }
        "join" { pub_join $nick $uhost $hand $chan $args }
        "part" { pub_part $nick $uhost $hand $chan $args }
        "cycle" { pub_cycle $nick $uhost $hand $chan $args }
        "seen" { pub_seen $nick $uhost $hand $chan $args }
        "ping" { pub_ping $nick $uhost $hand $chan $args }
        "help" { pub_help $nick $uhost $hand $chan $args }
        default { putmsg $chan "Unknown command. Try `help" }
    }
}

# Implementasi perintah dasar
proc ::SecureBot::pub_op {nick uhost hand chan args} {
    variable botnick
    if {![botisop $chan]} { putmsg $chan "I'm not op."; return }
    set target [lindex $args 0]
    if {$target eq ""} { set target $nick }
    if {[onchan $target $chan]} {
        pushmode $chan +o $target
    } else { putmsg $chan "$target not on channel." }
}

proc ::SecureBot::pub_deop {nick uhost hand chan args} {
    variable botnick
    if {![botisop $chan]} { putmsg $chan "I'm not op."; return }
    set target [lindex $args 0]
    if {$target eq ""} { set target $nick }
    if {[onchan $target $chan] && [isop $target $chan]} {
        pushmode $chan -o $target
    } else { putmsg $chan "$target not op or not on channel." }
}

proc ::SecureBot::pub_voice {nick uhost hand chan args} {
    if {![botisop $chan]} { putmsg $chan "I'm not op."; return }
    set target [lindex $args 0]
    if {$target eq ""} { set target $nick }
    if {[onchan $target $chan]} {
        pushmode $chan +v $target
    } else { putmsg $chan "$target not on channel." }
}

proc ::SecureBot::pub_devoice {nick uhost hand chan args} {
    if {![botisop $chan]} { putmsg $chan "I'm not op."; return }
    set target [lindex $args 0]
    if {$target eq ""} { set target $nick }
    if {[onchan $target $chan] && [isvoice $target $chan]} {
        pushmode $chan -v $target
    } else { putmsg $chan "$target not voice or not on channel." }
}

proc ::SecureBot::pub_kick {nick uhost hand chan args} {
    if {![botisop $chan]} { putmsg $chan "I'm not op."; return }
    set target [lindex $args 0]
    set reason [join [lrange $args 1 end]]
    if {$target eq ""} { putmsg $chan "Usage: `kick <nick> [reason]"; return }
    if {[onchan $target $chan]} {
        putkick $chan $target "$reason (by $nick)"
    } else { putmsg $chan "$target not on channel." }
}

proc ::SecureBot::pub_kickban {nick uhost hand chan args} {
    if {![botisop $chan]} { putmsg $chan "I'm not op."; return }
    set target [lindex $args 0]
    set reason [join [lrange $args 1 end]]
    if {$target eq ""} { putmsg $chan "Usage: `kickban <nick> [reason]"; return }
    if {[onchan $target $chan]} {
        set banmask "*!*@[lindex [split [getchanhost $target $chan] @] 1]"
        pushmode $chan +b $banmask
        putkick $chan $target "$reason (by $nick)"
    } else { putmsg $chan "$target not on channel." }
}

proc ::SecureBot::pub_ban {nick uhost hand chan args} {
    if {![botisop $chan]} { putmsg $chan "I'm not op."; return }
    set target [lindex $args 0]
    if {$target eq ""} { putmsg $chan "Usage: `ban <nick|hostmask>"; return }
    if {[string match "*@*" $target]} {
        pushmode $chan +b $target
    } elseif {[onchan $target $chan]} {
        set banmask "*!*@[lindex [split [getchanhost $target $chan] @] 1]"
        pushmode $chan +b $banmask
    } else {
        putmsg $chan "$target not on channel."
    }
}

proc ::SecureBot::pub_unban {nick uhost hand chan args} {
    if {![botisop $chan]} { putmsg $chan "I'm not op."; return }
    set target [lindex $args 0]
    if {$target eq ""} { putmsg $chan "Usage: `unban <hostmask>"; return }
    pushmode $chan -b $target
}

proc ::SecureBot::pub_mode {nick uhost hand chan args} {
    if {![botisop $chan]} { putmsg $chan "I'm not op."; return }
    set modestr [join $args]
    if {$modestr eq ""} { putmsg $chan "Usage: `mode <mode>"; return }
    putserv "MODE $chan $modestr"
}

proc ::SecureBot::pub_topic {nick uhost hand chan args} {
    if {![botisop $chan]} { putmsg $chan "I'm not op."; return }
    set topic [join $args]
    if {$topic eq ""} { putmsg $chan "Usage: `topic <new topic>"; return }
    putserv "TOPIC $chan :$topic"
}

proc ::SecureBot::pub_invite {nick uhost hand chan args} {
    set target [lindex $args 0]
    if {$target eq ""} { putmsg $chan "Usage: `invite <nick>"; return }
    putserv "INVITE $target $chan"
}

proc ::SecureBot::pub_join {nick uhost hand chan args} {
    variable owner
    if {![matchattr $nick n] && $nick ne $owner} { putmsg $chan "Only owner can make me join."; return }
    set newchan [lindex $args 0]
    if {$newchan eq ""} { putmsg $chan "Usage: `join <#channel>"; return }
    if {[string first "#" $newchan] != 0} { set newchan "#$newchan" }
    channel add $newchan
    putserv "JOIN $newchan"
}

proc ::SecureBot::pub_part {nick uhost hand chan args} {
    variable owner
    if {![matchattr $nick n] && $nick ne $owner} { putmsg $chan "Only owner can make me part."; return }
    set partchan [lindex $args 0]
    if {$partchan eq ""} { set partchan $chan }
    if {[validchan $partchan]} {
        putserv "PART $partchan"
        channel remove $partchan
    }
}

proc ::SecureBot::pub_cycle {nick uhost hand chan args} {
    if {![botisop $chan]} { putmsg $chan "I'm not op."; return }
    putserv "PART $chan :Cycling..."
    putserv "JOIN $chan"
}

proc ::SecureBot::pub_ping {nick uhost hand chan args} {
    putserv "PRIVMSG $chan :Pong!"
}

proc ::SecureBot::pub_help {nick uhost hand chan args} {
    putmsg $chan "Commands: op, deop, voice, devoice, kick, kickban, ban, unban, mode, topic, invite, join, part, cycle, seen, ping"
}

# ====================== SEEN ======================
# Prosedur sederhana untuk mencatat aktivitas user
bind join - * ::SecureBot::seen_join
bind part - * ::SecureBot::seen_part
bind sign - * ::SecureBot::seen_quit
bind kick - * ::SecureBot::seen_kick
bind nick - * ::SecureBot::seen_nick

proc ::SecureBot::seen_join {nick uhost hand chan} {
    variable seen_data
    set seen_data($nick) [list join [unixtime] $chan]
}

proc ::SecureBot::seen_part {nick uhost hand chan msg} {
    variable seen_data
    set seen_data($nick) [list part [unixtime] $chan $msg]
}

proc ::SecureBot::seen_quit {nick uhost hand chan msg} {
    variable seen_data
    set seen_data($nick) [list quit [unixtime] $chan $msg]
}

proc ::SecureBot::seen_kick {nick uhost hand chan target reason} {
    variable seen_data
    set seen_data($target) [list kick [unixtime] $chan $nick $reason]
}

proc ::SecureBot::seen_nick {nick uhost hand chan newnick} {
    variable seen_data
    set seen_data($nick) [list nick [unixtime] $chan $newnick]
    set seen_data($newnick) [list rnck [unixtime] $chan $nick]
}

proc ::SecureBot::pub_seen {nick uhost hand chan args} {
    variable seen_data
    set target [lindex $args 0]
    if {$target eq ""} { putmsg $chan "Usage: `seen <nick>"; return }
    if {[string tolower $target] eq [string tolower $nick]} {
        putmsg $chan "$nick, that's you!"
        return
    }
    if {[onchan $target $chan]} {
        putmsg $chan "$target is currently on $chan."
        return
    }
    if {![info exists seen_data($target)]} {
        putmsg $chan "I haven't seen $target."
        return
    }
    set data $seen_data($target)
    set type [lindex $data 0]
    set time [lindex $data 1]
    set where [lindex $data 2]
    set ago [duration [expr [unixtime] - $time]]
    switch $type {
        join { putmsg $chan "$target was last seen joining $where $ago ago." }
        part { putmsg $chan "$target left $where $ago ago: [lindex $data 3]" }
        quit { putmsg $chan "$target quit from $where $ago ago: [lindex $data 3]" }
        kick { putmsg $chan "$target was kicked from $where $ago ago by [lindex $data 3]: [lindex $data 4]" }
        nick { putmsg $chan "$target changed nick to [lindex $data 3] $ago ago." }
        rnck { putmsg $chan "$target changed nick from [lindex $data 3] $ago ago." }
        default { putmsg $chan "Unknown event." }
    }
}

# ====================== PROTEKSI SPAM ======================
# Sederhana: deteksi badword
bind pubm - * ::SecureBot::check_badword
proc ::SecureBot::check_badword {nick uhost hand chan text} {
    variable badwords
    if {[matchattr $nick f] || [isop $nick $chan]} { return }
    set lower [string tolower $text]
    foreach bad $badwords {
        if {[string match *$bad* $lower]} {
            putkick $chan $nick "Badword detected: $bad"
            return
        }
    }
}

# ====================== INISIALISASI ======================
proc ::SecureBot::init {} {
    variable version
    putlog "SecureBot v$version loaded. Use `help in channel."
}

::SecureBot::init
