######################################################################
#                 BOT MANAGEMENT & MODERATION v2.0                    #
#                 Fitur Lengkap: IP, DNS, Moderasi, dll               #
######################################################################
# Fitur utama:                                                        #
# - Autentikasi owner via PM (hai, pass)                              #
# - Cek IP publik dan detail geolokasi (!ip, !myip, !ipinfo)          #
# - Cek DNS (!dns)                                                    #
# - Perintah publik untuk semua user: !auth, !logout, !ping, !port,  #
#   !jam, !whois, !ver                                                #
# - Manajemen bot (owner): `+chan, `+owner, `+friend, `rehash,       #
#   `restart, `die, `status, `channels                                #
# - Moderasi channel (owner): !kick, !ban, !unban, !op, !deop,       #
#   !voice, !devoice, !halfop, !dehalfop, !topic, !clear, !mode      #
# - Join/Part channel (owner): !join, !part                           #
# - Keamanan: !statuskeamanan, !listowner                             #
# - Bantuan: !help atau PM help                                       #
######################################################################

# =================== KONFIGURASI ===================
set flo_Tzone "2"               # 1=WIB, 2=WITA, 3=WIT
set ip_api_url "http://ip-api.com/json/"
set ip_timeout 10               # Timeout curl/wget (detik)
set ban_time_default 5          # Waktu ban default (menit)
set basechan "#yourbasechannel" # Ganti dengan channel utama bot

# ============= Variabel dan Flag =============
setudef flag guard
setudef flag jam
setudef flag ping
setudef flag wb
setudef flag port
setudef flag whois
setudef flag dns
setudef flag version
setudef flag idle

# ============= Bindings =============
# Publik (tanpa auth)
bind pub - !dns      flo_pub_dns
bind pub - !ip       flo_pub_ip
bind pub - !myip     flo_pub_myip
bind pub - !ipinfo   flo_pub_ipinfo
bind pub - !whois    whois:nick
bind pub - !ver      kversion:nick
bind pub - !ping     flo_ping
bind pub - !port     flo_portchk
bind pub - !jam      flo_jam2

# Publik (hanya owner)
bind pub n !auth     flo_pub_auth
bind pub n !logout   flo_pub_logout
bind pub n `+chan    flo_pub_addchan
bind pub n `+owner   flo_pub_addowner
bind pub n `+friend  flo_pub_addfriend
bind pub n `rehash   flo_pub_rehash
bind pub n `restart  flo_pub_restart
bind pub n `die      flo_pub_die
bind pub n `status   flo_status
bind pub n `channels flo_channels

# Moderasi (hanya owner)
bind pub n !kick     flo_kick
bind pub n !ban      flo_ban
bind pub n !unban    flo_unban
bind pub n !op       flo_op
bind pub n !deop     flo_deop
bind pub n !voice    flo_voice
bind pub n !devoice  flo_devoice
bind pub n !halfop   flo_halfop
bind pub n !dehalfop flo_dehalfop
bind pub n !topic    flo_topic
bind pub n !clear    flo_clear
bind pub n !mode     flo_mode

# Join/Part channel (owner)
bind pub n !join     flo_join_channel
bind pub n !part     flo_part_channel

# Private (PM)
bind msg - hai       flo_msg_hai
bind msg - pass      flo_msg_pass
bind msg - auth      flo_msg_auth
bind msg - logout    flo_msg_logout
bind msg n help      flo_msg_help
bind msg n +chan     flo_msg_addchan
bind msg n +owner    flo_msg_addowner
bind msg n +friend   flo_msg_addfriend
bind msg n rehash    flo_msg_rehash
bind msg n restart   flo_msg_restart
bind msg n die       flo_msg_die

# Event & Time
bind evnt - init-server flo_init
bind time - "00 *"    flo_jam
bind time - "30 *"    flo_jam
bind time - "*/5 * * * *" flo_security_check

# ============= Fungsi Validasi IP & Domain =============
proc is_valid_ip {ip} {
    if {[regexp {^(\d{1,3})\.(\d{1,3})\.(\d{1,3})\.(\d{1,3})$} $ip -> a b c d]} {
        if {$a>=0 && $a<=255 && $b>=0 && $b<=255 && $c>=0 && $c<=255 && $d>=0 && $d<=255} {
            return 1
        }
    }
    return 0
}

proc is_valid_domain {domain} {
    if {[regexp {^[a-zA-Z0-9][a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,}$} $domain]} {
        return 1
    }
    return 0
}

# ============= Ambil Informasi IP =============
proc get_ip_info {ip} {
    global ip_api_url ip_timeout
    if {[catch {exec which curl} res]==0} {
        set cmd "curl -s --max-time $ip_timeout \"${ip_api_url}${ip}\""
    } elseif {[catch {exec which wget} res]==0} {
        set cmd "wget -q -O - --timeout=$ip_timeout \"${ip_api_url}${ip}\""
    } else {
        return "ERROR: curl/wget tidak tersedia"
    }
    if {[catch {set data [exec sh -c $cmd]} error]} {
        return "ERROR: $error"
    }
    return $data
}

proc parse_ip_info {json} {
    set result ""
    if {[regexp {\"status\":\"([^\"]+)\"} $json -> status] && $status!="success"} {
        if {[regexp {\"message\":\"([^\"]+)\"} $json -> msg]} { return "ERROR: $msg" }
        return "ERROR: gagal ambil data"
    }
    if {[regexp {\"query\":\"([^\"]+)\"} $json -> ip]}        { append result "IP: \00303$ip\003 " }
    if {[regexp {\"country\":\"([^\"]+)\"} $json -> cnt]}     { append result "Negara: \00303$cnt\003 " }
    if {[regexp {\"regionName\":\"([^\"]+)\"} $json -> reg]}  { append result "Region: \00303$reg\003 " }
    if {[regexp {\"city\":\"([^\"]+)\"} $json -> city]}       { append result "Kota: \00303$city\003 " }
    if {[regexp {\"isp\":\"([^\"]+)\"} $json -> isp]}         { append result "ISP: \00303$isp\003 " }
    if {[regexp {\"org\":\"([^\"]+)\"} $json -> org]}         { append result "Org: \00303$org\003 " }
    if {[regexp {\"as\":\"([^\"]+)\"} $json -> asn]}          { append result "ASN: \00303$asn\003 " }
    return [string trim $result]
}

proc get_my_public_ip {} {
    global ip_timeout
    set services { "http://api.ipify.org" "http://icanhazip.com" "http://ifconfig.me" }
    foreach svc $services {
        if {[catch {exec which curl}]==0} {
            set cmd "curl -s --max-time $ip_timeout \"$svc\""
        } elseif {[catch {exec which wget}]==0} {
            set cmd "wget -q -O - --timeout=$ip_timeout \"$svc\""
        } else {
            continue
        }
        if {[catch {set ip [string trim [exec sh -c $cmd]]}]==0 && [is_valid_ip $ip]} {
            return $ip
        }
    }
    return ""
}

# ============= Perintah Publik =============
proc flo_pub_ip {nick uhost hand chan text} {
    set target [lindex $text 0]
    if {$target==""} { puthelp "PRIVMSG $chan :Cara: !ip <IP/domain>"; return }
    if {[is_valid_ip $target]} { set query $target; set display $target
    } elseif {[is_valid_domain $target]} {
        if {[catch {set ip [exec nslookup $target]} error]} {
            puthelp "PRIVMSG $chan :Gagal resolve domain"; return
        }
        set ip [lindex [split $ip] end]
        if {$ip==""} { puthelp "PRIVMSG $chan :Domain tidak ditemukan"; return }
        set query $ip; set display "$target ($ip)"
    } else { puthelp "PRIVMSG $chan :Format IP/domain salah"; return }
    set json [get_ip_info $query]
    if {[string match "ERROR:*" $json]} { puthelp "PRIVMSG $chan :$json"; return }
    set info [parse_ip_info $json]
    if {[string match "ERROR:*" $info]} { puthelp "PRIVMSG $chan :$info"; return }
    puthelp "PRIVMSG $chan :\00314Informasi untuk $display\003"
    puthelp "PRIVMSG $chan :$info"
}

proc flo_pub_myip {nick uhost hand chan text} {
    puthelp "PRIVMSG $chan :Mencari IP publik Anda..."
    set myip [get_my_public_ip]
    if {$myip==""} { puthelp "PRIVMSG $chan :Gagal mendapat IP publik"; return }
    puthelp "PRIVMSG $chan :IP Anda: \00303$myip\003"
    set json [get_ip_info $myip]
    if {![string match "ERROR:*" $json]} {
        set info [parse_ip_info $json]
        if {![string match "ERROR:*" $info]} { puthelp "PRIVMSG $chan :$info" }
    }
}

proc flo_pub_ipinfo {nick uhost hand chan text} {
    set target [lindex $text 0]
    if {$target==""} { puthelp "PRIVMSG $chan :Cara: !ipinfo <host>"; return }
    if {![is_valid_ip $target] && ![is_valid_domain $target]} {
        puthelp "PRIVMSG $chan :Host tidak valid"; return
    }
    puthelp "PRIVMSG $chan :nslookup untuk $target..."
    if {[catch {set ns [exec nslookup $target]} error]} {
        puthelp "PRIVMSG $chan :Gagal: $error"; return
    }
    set lines [split $ns \n]
    foreach line $lines {
        set line [string trim $line]
        if {$line!=""} { puthelp "PRIVMSG $chan :$line" }
    }
}

proc flo_pub_dns {nick uhost hand chan text} {
    if {![channel get $chan dns]} { return }
    set host [lindex $text 0]
    if {$host==""} { puthelp "NOTICE $nick :Format: !dns <host>"; return }
    if {[catch {set data [exec host $host]} error]} {
        puthelp "PRIVMSG $chan :Tidak ada data DNS untuk $host"; return
    }
    puthelp "PRIVMSG $chan :\00314Hasil DNS untuk $host:\003 $data"
}

proc flo_pub_auth {nick uhost hand chan text} {
    if {[matchattr $nick Q]} { puthelp "PRIVMSG $chan :Anda sudah login"; return }
    putquick "WHOIS $nick $nick"
    chattr $nick +W
    utimer 3 [list chattr $nick -W]
}

proc flo_pub_logout {nick uhost hand chan text} {
    if {[matchattr $nick Q]} { chattr $nick -Q; puthelp "PRIVMSG $chan :Logout..!!!" }
}

proc flo_pub_addchan {nick uhost hand chan text} {
    set newchan [lindex $text 0]
    if {$newchan==""} { puthelp "NOTICE $nick :Format: `+chan #channel"; return }
    if {![validchan $newchan]} { channel add $newchan; puthelp "NOTICE $nick :Chan $newchan ditambahkan" } \
    else { puthelp "NOTICE $nick :Chan $newchan sudah ada" }
    savechan
}

proc flo_pub_addowner {nick uhost hand chan text} {
    set target [lindex $text 0]
    if {$target==""} { puthelp "NOTICE $nick :Format: `+owner nick"; return }
    if {![validuser $target]} {
        adduser $target "$target!*@*"
        chattr $target "fhjlmnoptxZ"
        puthelp "NOTICE $nick :$target ditambah ke daftar owner"
        puthelp "PRIVMSG $target :$nick menambahkan anda sebagai owner, ketik `pass password`"
    } else {
        if {[matchattr $target n]} { puthelp "NOTICE $nick :$target sudah owner" } \
        else { chattr $target "fhjlmnoptxZ"; puthelp "NOTICE $nick :$target diupgrade ke owner" }
    }
    saveuser
}

proc flo_pub_addfriend {nick uhost hand chan text} {
    set target [lindex $text 0]
    if {$target==""} { puthelp "NOTICE $nick :Format: `+friend nick"; return }
    if {![validuser $target]} {
        adduser $target "$target!*@*"
        chattr $target +f-hp
        puthelp "NOTICE $nick :$target ditambah ke friend"
    } else { puthelp "NOTICE $nick :$target sudah ada" }
    saveuser
}

proc flo_pub_rehash {nick uhost hand chan text} {
    puthelp "NOTICE $nick :Rehashing..."
    utimer 3 rehash
}

proc flo_pub_restart {nick uhost hand chan text} {
    putserv "QUIT :Restarted by $nick"
}

proc flo_pub_die {nick uhost hand chan text} {
    putlog "Bot dimatikan oleh $nick dari $chan"
    die "Dimatikan oleh $nick"
}

proc flo_status {nick uhost hand chan text} {
    set info [channel info $chan]
    puthelp "PRIVMSG $chan :Status $chan: $info"
}

proc flo_channels {nick uhost hand chan text} {
    set chlist ""
    foreach c [channels] {
        append chlist "\00302$c\003 "
    }
    puthelp "NOTICE $nick :Channel: $chlist"
}

# ============= Perintah Moderasi =============
proc flo_kick {nick uhost hand chan text} {
    set target [lindex $text 0]
    set reason [join [lrange $text 1 end]]
    if {$target == ""} { puthelp "NOTICE $nick :Cara: !kick <nick> [alasan]"; return }
    if {![botisop $chan]} { puthelp "NOTICE $nick :Saya tidak memiliki op di $chan"; return }
    if {![onchan $target $chan]} { puthelp "NOTICE $nick :$target tidak ada di channel"; return }
    if {$reason == ""} { set reason "Kicked by $nick" }
    putserv "KICK $chan $target :$reason"
}

proc flo_ban {nick uhost hand chan text} {
    set target [lindex $text 0]
    set reason [join [lrange $text 1 end]]
    if {$target == ""} { puthelp "NOTICE $nick :Cara: !ban <nick> [alasan]"; return }
    if {![botisop $chan]} { puthelp "NOTICE $nick :Saya tidak memiliki op di $chan"; return }
    if {![onchan $target $chan]} { puthelp "NOTICE $nick :$target tidak ada di channel"; return }
    set hostmask [maskhost [getchanhost $target $chan]]
    if {$reason == ""} { set reason "Banned by $nick" }
    putserv "MODE $chan +b $hostmask"
    putserv "KICK $chan $target :$reason"
}

proc flo_unban {nick uhost hand chan text} {
    set target [lindex $text 0]
    if {$target == ""} { puthelp "NOTICE $nick :Cara: !unban <nick> atau !unban <hostmask>"; return }
    if {![botisop $chan]} { puthelp "NOTICE $nick :Saya tidak memiliki op di $chan"; return }
    set hostmask ""
    if {[onchan $target $chan]} {
        set hostmask [maskhost [getchanhost $target $chan]]
    } elseif {[regexp {[!@]} $target]} {
        set hostmask $target
    } else {
        puthelp "NOTICE $nick :$target bukan nick yang online atau hostmask tidak valid"
        return
    }
    putserv "MODE $chan -b $hostmask"
}

proc flo_op {nick uhost hand chan text} {
    set target [lindex $text 0]
    if {$target == ""} { puthelp "NOTICE $nick :Cara: !op <nick>"; return }
    if {![botisop $chan]} { puthelp "NOTICE $nick :Saya tidak memiliki op di $chan"; return }
    if {![onchan $target $chan]} { puthelp "NOTICE $nick :$target tidak ada di channel"; return }
    putserv "MODE $chan +o $target"
}

proc flo_deop {nick uhost hand chan text} {
    set target [lindex $text 0]
    if {$target == ""} { puthelp "NOTICE $nick :Cara: !deop <nick>"; return }
    if {![botisop $chan]} { puthelp "NOTICE $nick :Saya tidak memiliki op di $chan"; return }
    if {![onchan $target $chan]} { puthelp "NOTICE $nick :$target tidak ada di channel"; return }
    putserv "MODE $chan -o $target"
}

proc flo_voice {nick uhost hand chan text} {
    set target [lindex $text 0]
    if {$target == ""} { puthelp "NOTICE $nick :Cara: !voice <nick>"; return }
    if {![botisop $chan]} { puthelp "NOTICE $nick :Saya tidak memiliki op di $chan"; return }
    if {![onchan $target $chan]} { puthelp "NOTICE $nick :$target tidak ada di channel"; return }
    putserv "MODE $chan +v $target"
}

proc flo_devoice {nick uhost hand chan text} {
    set target [lindex $text 0]
    if {$target == ""} { puthelp "NOTICE $nick :Cara: !devoice <nick>"; return }
    if {![botisop $chan]} { puthelp "NOTICE $nick :Saya tidak memiliki op di $chan"; return }
    if {![onchan $target $chan]} { puthelp "NOTICE $nick :$target tidak ada di channel"; return }
    putserv "MODE $chan -v $target"
}

proc flo_halfop {nick uhost hand chan text} {
    set target [lindex $text 0]
    if {$target == ""} { puthelp "NOTICE $nick :Cara: !halfop <nick>"; return }
    if {![botisop $chan]} { puthelp "NOTICE $nick :Saya tidak memiliki op di $chan"; return }
    if {![onchan $target $chan]} { puthelp "NOTICE $nick :$target tidak ada di channel"; return }
    putserv "MODE $chan +h $target"
}

proc flo_dehalfop {nick uhost hand chan text} {
    set target [lindex $text 0]
    if {$target == ""} { puthelp "NOTICE $nick :Cara: !dehalfop <nick>"; return }
    if {![botisop $chan]} { puthelp "NOTICE $nick :Saya tidak memiliki op di $chan"; return }
    if {![onchan $target $chan]} { puthelp "NOTICE $nick :$target tidak ada di channel"; return }
    putserv "MODE $chan -h $target"
}

proc flo_topic {nick uhost hand chan text} {
    set topic [join $text]
    if {$topic == ""} { puthelp "NOTICE $nick :Cara: !topic <topic baru>"; return }
    if {![botisop $chan]} { puthelp "NOTICE $nick :Saya tidak memiliki op di $chan"; return }
    putserv "TOPIC $chan :$topic"
}

proc flo_clear {nick uhost hand chan text} {
    if {![botisop $chan]} { puthelp "NOTICE $nick :Saya tidak memiliki op di $chan"; return }
    set banlist [chanbans $chan]
    foreach ban $banlist {
        set mask [lindex $ban 0]
        putserv "MODE $chan -b $mask"
    }
    foreach user [chanlist $chan] {
        if {$user == $::botnick} { continue }
        if {[matchattr $user n] || [matchattr $user Q]} { continue }
        putserv "KICK $chan $user :Channel cleared by $nick"
    }
    puthelp "NOTICE $nick :Channel $chan telah dibersihkan (ban dihapus, user non-owner dikick)"
}

proc flo_mode {nick uhost hand chan text} {
    set modestring [join $text]
    if {$modestring == ""} { puthelp "NOTICE $nick :Cara: !mode <modestring>"; return }
    if {![botisop $chan]} { puthelp "NOTICE $nick :Saya tidak memiliki op di $chan"; return }
    putserv "MODE $chan $modestring"
}

# ============= Join/Part Channel =============
proc flo_join_channel {nick uhost hand chan text} {
    set target [lindex $text 0]
    if {$target == ""} {
        puthelp "NOTICE $nick :Cara: !join <#channel>"
        return
    }
    if {[validchan $target]} {
        puthelp "NOTICE $nick :Sudah berada di $target"
        return
    }
    channel add $target
    puthelp "NOTICE $nick :Bergabung ke $target"
    savechan
}

proc flo_part_channel {nick uhost hand chan text} {
    global basechan
    set target [lindex $text 0]
    if {$target == ""} {
        # part current channel
        if {[string tolower $chan] == [string tolower $basechan]} {
            puthelp "NOTICE $nick :Tidak bisa part dari base channel"
            return
        }
        if {[validchan $chan]} {
            channel remove $chan
            puthelp "NOTICE $nick :Part dari $chan"
            savechan
        } else {
            puthelp "NOTICE $nick :Tidak berada di $chan"
        }
        return
    }
    if {[string tolower $target] == [string tolower $basechan]} {
        puthelp "NOTICE $nick :Tidak bisa part dari base channel"
        return
    }
    if {[validchan $target]} {
        channel remove $target
        puthelp "NOTICE $nick :Part dari $target"
        savechan
    } else {
        puthelp "NOTICE $nick :Tidak berada di $target"
    }
}

# ============= Perintah Private =============
proc flo_msg_hai {nick uhost hand text} {
    global owner
    if {$nick!=$owner} { puthelp "PRIVMSG $nick :Maaf, anda bukan owner"; return }
    if {![validuser $nick]} {
        adduser $nick "$nick!*@*"
        chattr $nick "fhjlmnoptxZ"
        puthelp "PRIVMSG $nick :Hai bos, ketik `pass password`"
    } else { puthelp "PRIVMSG $nick :Hai juga bos" }
    saveuser
}

proc flo_msg_pass {nick uhost hand text} {
    set pw [lindex $text 0]
    if {$pw==""} { puthelp "PRIVMSG $nick :Format: pass password"; return }
    if {[validuser $nick]} {
        if {[matchattr $nick n] && [passwdok $nick "-"]} {
            setuser $nick PASS $pw
            puthelp "PRIVMSG $nick :Password diset $pw. Ketik `auth $pw` untuk login"
            saveuser
        } else { puthelp "PRIVMSG $nick :Anda sudah punya password atau bukan owner" }
    } else { puthelp "PRIVMSG $nick :Anda belum terdaftar, hubungi owner" }
}

proc flo_msg_auth {nick uhost hand text} {
    set pw [lindex $text 0]
    if {$pw==""} { puthelp "PRIVMSG $nick :Format: auth password"; return }
    if {![validuser $nick]} { puthelp "PRIVMSG $nick :Anda belum terdaftar"; return }
    if {[matchattr $nick Q]} { puthelp "PRIVMSG $nick :Sudah login"; return }
    if {[passwdok $nick $pw]} { chattr $nick +Q; puthelp "PRIVMSG $nick :Login sukses!" } \
    else { puthelp "PRIVMSG $nick :Password salah" }
}

proc flo_msg_logout {nick uhost hand text} {
    if {[matchattr $nick Q]} { chattr $nick -Q; puthelp "PRIVMSG $nick :Logout..!!!" }
}

proc flo_msg_addchan {nick uhost hand text} {
    if {![matchattr $nick Q]} { puthelp "PRIVMSG $nick :Harus login"; return }
    set newchan [lindex $text 0]
    if {$newchan==""} { puthelp "PRIVMSG $nick :Format: +chan #channel"; return }
    if {![validchan $newchan]} { channel add $newchan; puthelp "PRIVMSG $nick :Chan $newchan ditambahkan" } \
    else { puthelp "PRIVMSG $nick :Chan $newchan sudah ada" }
    savechan
}

proc flo_msg_addowner {nick uhost hand text} {
    if {![matchattr $nick Q]} { puthelp "PRIVMSG $nick :Harus login"; return }
    set target [lindex $text 0]
    if {$target==""} { puthelp "PRIVMSG $nick :Format: +owner 
