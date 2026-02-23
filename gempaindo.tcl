package require json

# Daftar channel yang menerima notifikasi otomatis
set setroom "#yobayat"

# File untuk menyimpan ID gempa terakhir
set gempa_file "gempa.txt"
if {![file exists $gempa_file]} {
    close [open $gempa_file w]
}

# Path curl
set curl_path "/usr/bin/curl"

# Binding perintah manual
bind pub - .gempa cmd_gempa
bind pub - !gempa cmd_gempa

proc cmd_gempa {nick uhost hand chan arg} {
    putlog "Gempa manual diminta oleh $nick di $chan"
    gempa_process $chan "manual"
}

# Timer otomatis setiap 5 menit
timer 300 auto_gempa
proc auto_gempa {} {
    putlog "AutoGempa: mengecek gempa baru..."
    gempa_process "room" "auto"
    timer 300 auto_gempa
}

proc gempa_process {target mode} {
    global setroom gempa_file curl_path

    set url "https://data.bmkg.go.id/DataMKG/TEWS/autogempa.json"
    set cmd [list $curl_path -s -k --max-time 10 $url]

    if {[catch {exec {*}$cmd} data]} {
        putlog "Gempa: curl error - $data"
        return
    }

    # Parse JSON
    if {[catch {set parsed [json::json2dict $data]} err]} {
        putlog "Gempa: Gagal parse JSON - $err"
        putlog "Data mentah: $data"
        return
    }

    # Ambil data gempa
    if {[catch {
        set gempa_data [dict get $parsed Infogempa gempa]
        set tanggal   [dict get $gempa_data Tanggal]
        set jam       [dict get $gempa_data Jam]
        set magnitudo [dict get $gempa_data Magnitude]
        set kedalaman [dict get $gempa_data Kedalaman]
        set wilayah   [dict get $gempa_data Wilayah]
        set potensi   [dict get $gempa_data Potensi]
        set dirasakan [dict get $gempa_data Dirasakan]
    } err]} {
        putlog "Gempa: Gagal membaca field JSON - $err"
        return
    }

    if {$mode == "manual"} {
        send_gempa $target $tanggal $jam $magnitudo $kedalaman $wilayah $potensi $dirasakan
    } else {
        set current_id "$tanggal $jam"
        if {[file exists $gempa_file]} {
            set f [open $gempa_file r]
            set last_id [gets $f]
            close $f
        } else {
            set last_id ""
        }
        if {$current_id eq $last_id} {
            putlog "AutoGempa: Tidak ada gempa baru"
            return
        }
        putlog "AutoGempa: Gempa baru ditemukan! ID: $current_id"
        set f [open $gempa_file w]
        puts $f $current_id
        close $f

        foreach chann [channels] {
            if {$setroom == "" || [lsearch -exact [string tolower $setroom] [string tolower $chann]] != -1} {
                send_gempa $chann $tanggal $jam $magnitudo $kedalaman $wilayah $potensi $dirasakan
            }
        }
    }
}

proc send_gempa {chan tanggal jam magnitudo kedalaman wilayah potensi dirasakan} {
    set header "\00305,08\002\037\/!\\\002\017 \00305\002WARNING GEMPA\002\017 \00305,08\002\037\/!\\\002\017"
    set msg1 "Tanggal: \00314$tanggal\017, Jam: \00314$jam\017"
    set msg2 "Magnitudo: \00314$magnitudo\017, Kedalaman: \00314$kedalaman\017"
    set msg3 "Wilayah: \00314$wilayah\017"
    set msg4 "Potensi: \00314$potensi\017"
    set msg5 "Dirasakan: \00314$dirasakan\017"

    putserv "PRIVMSG $chan :$header"
    putserv "PRIVMSG $chan :$msg1"
    putserv "PRIVMSG $chan :$msg2"
    putserv "PRIVMSG $chan :$msg3"
    putserv "PRIVMSG $chan :$msg4"
    putserv "PRIVMSG $chan :$msg5"
}

putlog "tcl BMKG INDO (pakai curl) loaded. by Lemom Notifikasi otomatis setiap 5 menit."
