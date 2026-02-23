###############################################################################
# Timebomb Simple - Versi Debug
# Perintah: !bom <nick>   - Pasang bom
#           !potong <warna> - Potong kabel
###############################################################################

set timebomb_version "1.0-debug"
set timebomb_active 0
set timebomb_target ""
set timebomb_channel ""
set timebomb_correct_wire ""
set timebomb_timer_id 0
set timebomb_max_wires 3
set timebomb_min_duration 20
set timebomb_max_duration 60
set timebomb_wire_choices {Merah Jingga Kuning Hijau Biru Nila Ungu Hitam Putih Abu-abu Coklat Pink}
set timebomb_number_names {nol satu dua tiga empat lima enam tujuh delapan sembilan sepuluh sebelas dua belas}
set timebomb_plant_messages {
    "dengan hati-hati naro bom dalam cd %s, waktunya cuma %d detik!"
    "menyelinap dan menyelipkan bom ke dalam saku %s. Waduh, bahaya nih! %d detik lagi meledak!"
    "ngasih hadiah kejutan buat %s... sebuah bom waktu! Cepet potong kabelnya dalam %d detik!"
}
set timebomb_diffuse_messages {
    "kabel %s dipotong... horee, bom aman! %s selamat!"
    "dengan gemetar %s memotong kabel %s... *pluk* bom mati. Untung!"
}
set timebomb_detonate_messages {
    "*DUAR* bom meledak! %s hancur berkeping-keping! Wkwkwk"
    "BOOM! %s jadi abu. Sayang sekali, coba potong kabel yang bener."
}
set timebomb_wrong_wire_messages {
    "kabel %s dipotong... eh salah! *BOOM*"
}
set timebomb_chance_wrong_explode 10

proc timebomb_log {msg} {
    putlog "\[TIMEBOMB\] $msg"
}

proc timebomb_privmsg {target msg} {
    putserv "PRIVMSG $target :$msg"
}

proc timebomb_action {target msg} {
    putserv "PRIVMSG $target :\001ACTION $msg\001"
}

proc timebomb_kick {nick chan reason} {
    timebomb_log "Kicking $nick from $chan: $reason"
    putserv "KICK $chan $nick :$reason"
}

proc timebomb_make_english_list {lst} {
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

proc timebomb_select_wires {count} {
    global timebomb_wire_choices
    set total [llength $timebomb_wire_choices]
    set selected {}
    while {[llength $selected] < $count} {
        set wire [lindex $timebomb_wire_choices [expr int(rand() * $total)]]
        if {$wire ni $selected} { lappend selected $wire }
    }
    return $selected
}

proc timebomb_diffuse {wire_cut} {
    global timebomb_active timebomb_target timebomb_channel timebomb_correct_wire timebomb_timer_id
    global timebomb_diffuse_messages timebomb_detonate_messages timebomb_chance_wrong_explode

    killutimer $timebomb_timer_id
    set timebomb_timer_id 0
    set timebomb_active 0

    if { [expr int(rand() * 100)] < $timebomb_chance_wrong_explode } {
        set msg [lindex $timebomb_detonate_messages [expr int(rand() * [llength $timebomb_detonate_messages])]]
        timebomb_kick $timebomb_target $timebomb_channel [format $msg $timebomb_target]
        timebomb_log "Bom meledak meski kabel benar! (keberuntungan)"
        return
    }

    set msg [lindex $timebomb_diffuse_messages [expr int(rand() * [llength $timebomb_diffuse_messages])]]
    timebomb_privmsg $timebomb_channel [format $msg $wire_cut $timebomb_target]
    timebomb_log "$timebomb_target berhasil memotong kabel $wire_cut. Bom aman."
}

proc timebomb_detonate {kick_msg} {
    global timebomb_active timebomb_target timebomb_channel timebomb_timer_id
    global timebomb_detonate_messages

    killutimer $timebomb_timer_id
    set timebomb_timer_id 0
    set timebomb_active 0
    set msg [lindex $timebomb_detonate_messages [expr int(rand() * [llength $timebomb_detonate_messages])]]
    timebomb_kick $timebomb_target $timebomb_channel [format $msg $timebomb_target]
    timebomb_log "Bom meledak! $timebomb_target kena."
}

proc timebomb_start {starter target_nick chan} {
    global timebomb_active timebomb_target timebomb_channel timebomb_correct_wire timebomb_timer_id
    global timebomb_min_duration timebomb_max_duration timebomb_max_wires
    global timebomb_number_names timebomb_plant_messages

    if {$timebomb_active} {
        if {$chan ne $timebomb_channel} {
            timebomb_privmsg $chan "Maap, lagi ada bom aktif di $timebomb_channel. Sabar ya."
        } else {
            timebomb_action $chan "sibuk nge-jaga bom di $timebomb_target, ntar dulu."
        }
        return
    }

    set duration [expr $timebomb_min_duration + int(rand() * ($timebomb_max_duration - $timebomb_min_duration + 1))]
    set timebomb_target $target_nick
    set timebomb_channel $chan

    set wire_count [expr 1 + int(rand() * $timebomb_max_wires)]
    set wires [timebomb_select_wires $wire_count]
    set timebomb_correct_wire [lindex $wires [expr int(rand() * $wire_count)]]

    set wire_list [timebomb_make_english_list $wires]
    set wire_count_word [lindex $timebomb_number_names $wire_count]

    set plant_msg [lindex $timebomb_plant_messages [expr int(rand() * [llength $timebomb_plant_messages])]]
    timebomb_action $chan [format $plant_msg $target_nick $duration]

    if {$wire_count == 1} {
        timebomb_privmsg $chan "Cuma ada $wire_count_word kabel, warna $wire_list. Potong yang bener!"
    } else {
        timebomb_privmsg $chan "Ada $wire_count_word kabel: $wire_list. Pilih dengan bijak!"
    }

    set timebomb_active 1
    set timebomb_timer_id [utimer $duration [list timebomb_detonate "*BOOM* waktu habis!"]]
    timebomb_log "Bom dipasang oleh $starter kepada $target_nick, durasi $duration detik, kabel benar: $timebomb_correct_wire"
}

bind pub - !bom timebomb_cmd_bom
bind pub - !potong timebomb_cmd_potong

proc timebomb_cmd_bom {nick uhost hand chan arg} {
    global botnick
    timebomb_log "Perintah !bom dari $nick, arg: $arg"
    set target_nick [lindex $arg 0]
    if {$target_nick eq ""} {
        timebomb_privmsg $chan "Mau ngebom siapa? Ketik: !bom <nick>"
        return
    }
    if {[string tolower $target_nick] eq [string tolower $botnick]} {
        timebomb_kick $nick $chan "Jangan coba-coba ngebom bot, goblok!"
        return
    }
    if {[validuser $target_nick] && [matchattr $target_nick b]} {
        timebomb_kick $nick $chan "Itu bot, nda lucu!"
        return
    }
    timebomb_start $nick $target_nick $chan
}

proc timebomb_cmd_potong {nick uhost hand chan arg} {
    global timebomb_active timebomb_target timebomb_correct_wire
    timebomb_log "Perintah !potong dari $nick, arg: $arg"
    if {!$timebomb_active} {
        timebomb_privmsg $chan "Bom mana? Ngga ada bom aktif."
        return
    }
    if {[string tolower $nick] ne [string tolower $timebomb_target]} {
        timebomb_privmsg $chan "Hei, itu bom punya $timebomb_target, jangan ikut-ikutan!"
        return
    }
    set wire [lindex $arg 0]
    if {$wire eq ""} {
        timebomb_privmsg $chan "Mau potong kabel mana? Ketik: !potong <warna>"
        return
    }
    if {[string tolower $wire] eq [string tolower $timebomb_correct_wire]} {
        timebomb_diffuse $wire
    } else {
        timebomb_detonate "salah potong kabel $wire!"
    }
}

timebomb_log "Timebomb Simple v$timebomb_version loaded. Perintah: !bom <nick> dan !potong <warna>"
