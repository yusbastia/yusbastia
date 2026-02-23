###############################################################################
# Timebomb Gaul - Versi Kocak
# Author: Modifikasi oleh (nama Anda)
# Deskripsi: Game bom waktu dengan gaya bahasa gaul Indonesia
# Perintah: !bom <nick>  - Pasang bom pada target
#           !potong <warna> - Potong kabel (hanya untuk target)
###############################################################################

namespace eval ::Timebomb {
    variable version "0.5-gaul"
    variable active 0
    variable target ""
    variable channel ""
    variable correctWire ""
    variable timerId 0
    variable maxWires 3
    variable minDuration 20
    variable maxDuration 60
    variable wireChoices [list "Merah" "Jingga" "Kuning" "Hijau" "Biru" "Nila" "Ungu" "Hitam" "Putih" "Abu-abu" "Coklat" "Pink" "Mauve" "Beige" "Aquamarine" "Chartreuse" "Bisque" "Crimson" "Fuchsia" "Gold" "Ivory" "Khaki" "Lavender" "Lime" "Magenta" "Maroon" "Navy" "Olive" "Plum" "Silver" "Tan" "Teal" "Turquoise"]
    variable numberNames [list "nol" "satu" "dua" "tiga" "empat" "lima" "enam" "tujuh" "delapan" "sembilan" "sepuluh" "sebelas" "dua belas"]

    # Pesan-pesan lucu
    variable plantMessages [list \
        "dengan hati-hati naro bom dalam cd %s, waktunya cuma %d detik!" \
        "menyelinap dan menyelipkan bom ke dalam saku %s. Waduh, bahaya nih! %d detik lagi meledak!" \
        "ngasih hadiah kejutan buat %s... sebuah bom waktu! Cepet potong kabelnya dalam %d detik!" \
        "kaget-kaget, %s dapet bom di celana! %d detik untuk bertindak!" \
        "wih, %s jadi target bom hari ini. Ayo buruan, %d detik!" \
        "tiba-tiba %s merasa ada yang aneh... ternyata ada bom di dalam saku! %d detik!" \
        "dengan gaya ala film action, %s dipasangi bom. %d detik sebelum bye-bye." \
    ]
    variable diffuseMessages [list \
        "kabel %s dipotong... horee, bom aman! %s selamat!" \
        "dengan gemetar %s memotong kabel %s... *pluk* bom mati. Untung!" \
        "potong kabel %s... eits, ternyata itu kabel yang benar. %s boleh bernapas lega." \
        "kabel %s terputus... bom berhenti berdetak. %s, kamu hebat!" \
        "sukses! %s memotong kabel %s. Bom meledak? enggak ding, becanda." \
        "kabel %s dipotong, lampu indikator mati. %s selamat dari maut." \
    ]
    variable detonateMessages [list \
        "*DUAR* bom meledak! %s hancur berkeping-keping! Wkwkwk" \
        "BOOM! %s jadi abu. Sayang sekali, coba potong kabel yang bener." \
        "terlambat! Bom meledak, %s terpental keluar channel. Kasian." \
        "ledakan dahsyat! %s terbang entah ke mana. Game over." \
        "suara ledakan terdengar... %s hilang dari peredaran." \
        "bom meledak dan %s berubah menjadi debu. RIP." \
    ]
    variable wrongWireMessages [list \
        "kabel %s dipotong... eh salah! *BOOM*" \
        "wah, salah potong kabel %s. Bom meledak!" \
        "kabel %s bukan yang benar. Bye bye %s." \
    ]
    variable chanceWrongExplode 10 ;# Persentase bom meledak meski kabel benar (buat seru)
}

# Prosedur bantuan
proc ::Timebomb::log {msg} {
    putlog "\[Timebomb\] $msg"
}

proc ::Timebomb::ircPrivMsg {target msg} {
    putserv "PRIVMSG $target :$msg"
}

proc ::Timebomb::ircAction {target msg} {
    putserv "PRIVMSG $target :\001ACTION $msg\001"
}

proc ::Timebomb::ircKick {nick chan reason} {
    log "Kicking $nick from $chan: $reason"
    putserv "KICK $chan $nick :$reason"
}

proc ::Timebomb::makeEnglishList {lst} {
    set len [llength $lst]
    if {$len == 0} { return "" }
    if {$len == 1} { return [lindex $lst 0] }
    if {$len == 2} { return "[lindex $lst 0] dan [lindex $lst 1]" }
    set res ""
    for {set i 0} {$i < $len-1} {incr i} {
        append res "[lindex $lst $i], "
    }
    append res "dan [lindex $lst $len-1]"
    return $res
}

proc ::Timebomb::selectWires {count} {
    variable wireChoices
    set total [llength $wireChoices]
    set selected {}
    while {[llength $selected] < $count} {
        set wire [lindex $wireChoices [expr int(rand() * $total)]]
        if {$wire ni $selected} { lappend selected $wire }
    }
    return $selected
}

proc ::Timebomb::diffuse {wireCut} {
    variable active
    variable target
    variable channel
    variable correctWire
    variable timerId
    variable diffuseMessages
    variable chanceWrongExplode

    killutimer $timerId
    set timerId 0
    set active 0

    # Kemungkinan bom tetap meledak meski kabel benar (untuk efek lucu)
    if { [expr int(rand() * 100)] < $chanceWrongExplode } {
        set msg [lindex $detonateMessages [expr int(rand() * [llength $detonateMessages])]]
        ircKick $target $channel [format $msg $target]
        log "Bom meledak meski kabel benar! (keberuntungan)"
        return
    }

    set msg [lindex $diffuseMessages [expr int(rand() * [llength $diffuseMessages])]]
    ircPrivMsg $channel [format $msg $wireCut $target]
    log "$target berhasil memotong kabel $wireCut. Bom aman."
}

proc ::Timebomb::detonate {kickMsg} {
    variable active
    variable target
    variable channel
    variable timerId
    variable detonateMessages

    killutimer $timerId
    set timerId 0
    set active 0
    set msg [lindex $detonateMessages [expr int(rand() * [llength $detonateMessages])]]
    ircKick $target $channel [format $msg $target]
    log "Bom meledak! $target kena."
}

proc ::Timebomb::start {starter targetNick chan} {
    variable active
    variable target
    variable channel
    variable correctWire
    variable timerId
    variable minDuration
    variable maxDuration
    variable maxWires
    variable wireChoices
    variable numberNames
    variable plantMessages

    if {$active} {
        if {$chan ne $channel} {
            ircPrivMsg $chan "Maap, lagi ada bom aktif di $channel. Sabar ya."
        } else {
            ircAction $chan "sibuk nge-jaga bom di $target, ntar dulu."
        }
        return
    }

    set duration [expr $minDuration + int(rand() * ($maxDuration - $minDuration + 1))]
    set target $targetNick
    set channel $chan

    set wireCount [expr 1 + int(rand() * $maxWires)]
    set wires [selectWires $wireCount]
    set correctWire [lindex $wires [expr int(rand() * $wireCount)]]

    set wireList [makeEnglishList $wires]
    set wireCountWord [lindex $numberNames $wireCount]

    # Pilih pesan pemasangan secara acak
    set plantMsg [lindex $plantMessages [expr int(rand() * [llength $plantMessages])]]
    ircAction $chan [format $plantMsg $target $duration]

    if {$wireCount == 1} {
        ircPrivMsg $chan "Cuma ada $wireCountWord kabel, warna $wireList. Potong yang bener!"
    } else {
        ircPrivMsg $chan "Ada $wireCountWord kabel: $wireList. Pilih dengan bijak!"
    }

    set active 1
    set timerId [utimer $duration [list [namespace current]::detonate "*BOOM* waktu habis!"]]
    log "Bom dipasang oleh $starter kepada $target, durasi $duration detik, kabel benar: $correctWire"
}

# Binding perintah
bind pub - !bom [namespace current]::cmdBom
bind pub - !potong [namespace current]::cmdPotong

proc ::Timebomb::cmdBom {nick uhost hand chan arg} {
    variable active
    variable target
    variable botnick
    set targetNick [lindex $arg 0]
    if {$targetNick eq ""} {
        ircPrivMsg $chan "Mau ngebom siapa? Ketik: !bom <nick>"
        return
    }
    if {[string tolower $targetNick] eq [string tolower $botnick]} {
        ircKick $nick $chan "Jangan coba-coba ngebom bot, goblok!"
        return
    }
    if {[validuser $targetNick] && [matchattr $targetNick b]} {
        ircKick $nick $chan "Itu bot, nda lucu!"
        return
    }
    start $nick $targetNick $chan
}

proc ::Timebomb::cmdPotong {nick uhost hand chan arg} {
    variable active
    variable target
    variable correctWire
    if {!$active} {
        ircPrivMsg $chan "Bom mana? Ngga ada bom aktif."
        return
    }
    if {[string tolower $nick] ne [string tolower $target]} {
        ircPrivMsg $chan "Hei, itu bom punya $target, jangan ikut-ikutan!"
        return
    }
    set wire [lindex $arg 0]
    if {$wire eq ""} {
        ircPrivMsg $chan "Mau potong kabel mana? Ketik: !potong <warna>"
        return
    }
    if {[string tolower $wire] eq [string tolower $correctWire]} {
        diffuse $wire
    } else {
        # Salah potong, langsung ledak
        detonate "salah potong kabel $wire!"
    }
}

# Inisialisasi
namespace eval ::Timebomb {
    log "Timebomb Gaul v$version loaded. Perintah: !bom <nick> dan !potong <warna>"
}
