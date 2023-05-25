#######################################################
#                             #
#   Mp3 and Mp4 Downloader                #
#         Version 1.2                 #
#                             #
# Author: Vaksin & Uploaded by kazuya                 #
# Copyright © 2016 All Rights Reserved.               #
#######################################################
#                       
# ############                  
# REQUIREMENTS                  
# ############                  
#  "/home/KocHi/.local/bin/youtube-dl" and "ffmpeg" package installed. 
#                       
# ###########
# CHANGELOG#
############
# 1.0                           
# -Enable or Disable the script. (For Owner)        
# -Clear all file in folder.    (For Owner)     
# -Check mp3 or mp4 file in folder.(For Op or Owner)
# 1.1                           
# -Error message now with full reply.                                                                   
# -Fixed some bugs.                                                                                             
# 1.2                                                                                                                           
# -Added block and unblock commands for owner.                                          
#  Examples: block donald       (Prevent donald for download)                       
#                    unblock donald (Remove block)                                              
# -Fixed bug.                                                                                                           
#                                                                                                                           
# #######                                                                                                               
# CONTACT                                                                                                               
# #######                                                                                                               
#  If you have any suggestions, comments, questions or report bugs,         
#  you can find me on IRC AllNetwork                                            
#                                                                                                                               
#  /server irc.allnetwork.org:6667   Nick: uKi`                                       
#                                                                                                                                   
######################################################
setudef flag mp3

###############################################################################
### Settings ###
###############################################################################

# This is antiflood trigger, set how long you want (time in second)
set tube(rest) 50

# This is link for download the mp3 or mp4 file.
set linkdl " http://radio.tapaaog.my.id/~yus/dl/"

# This is your public_html folder patch
set path "/home/yus/public_html"

#set forcd "\u24c0\u24c4\u24b8\u24bd\u24be"
#set ucode [encoding convertto utf-8 "$forcd"]
set tmark "\00304\u24c0\u24c4\u24b8\u24bd\u24be\003"

###############################################################################
### End of Settings ###
###############################################################################

bind pub - .mp3 mptiga
bind pub - !mp3 mptiga
bind pub - .mp4 mpempat
bind pub - !mp4 mpempat
bind pub - .clear delete_file
bind pub - .check cekfolder
bind pub - .help help
bind pub n "$botnick" pub:onoff

proc blokk { nick host hand chan text } {
    if {[matchattr $nick n]} {
        set tnick [lindex $text 0]
        set hostmask [getchanhost $tnick $chan]
        set hostmask "*!*@[lindex [split $hostmask @] 1]"
        if {[isignore $hostmask]} {
            puthlp "NOTICE $nick :$tnick is alreay set on ignore."
            return 0
        }
        newignore $hostmask $hand "*" 0
        puthelp "NOTICE $nick :Ignoring $tnick"
    } else {
        putquick "NOTICE $nick :Access Denied!!!"
    }
}

proc unblokk { nick host hand chan text } {
    if {[matchattr $nick n]} {
        set tnick [lindex $text 0]
        set hostmask [getchanhost $tnick $chan]
        set hostmask "*!*@[lindex [split $hostmask @] 1]"
        if {![isignore $hostmask]} {
            puthlp "NOTICE $nick :$tnick is not on ignore list."
            return 0
        }
        killignore $hostmask
        puthelp "NOTICE $nick :Unignoring $tnick"
        saveuser
    } else {
        putquick "NOTICE $nick :Access Denied!!!"
    }
}

proc mpempat { nick host hand chan text } {
    global tube
    if {![channel get $chan mp3]} { return 0 }
    if {[lindex $text 0] == ""} {
        puthelp "NOTICE $nick :Ketik \002.help\002 untuk melihat perintah."
        return 0
    }
    if {[info exists tube(protection)]} {
        set rest [expr [clock seconds] - $tube(protection)]
        if {$rest < $tube(rest)} {
            puthelp "PRIVMSG $chan :Tunggu [expr $tube(rest) - $rest] detik lagi."
            return 0
        }
        catch { unset rest }
    }
    set tube(protection) [clock seconds]
    if {[string match "*http*" [lindex $text 0]]} {
        pub_getlinkk $nick $host $hand $chan $text
    } else {
        pub_gett $nick $host $hand $chan $text
    }
}

proc pub_gett {nick host hand chan text } {
    global path linkdl tmark
    putquick "PRIVMSG $chan :\u004d\u00f8\u0127\u00f8\u006e \u0167\u1d7e\u006e\u01e5\u01e5\u1d7e..."
   catch [list exec /home/yus/.local/bin/youtube-dl --get-title "ytsearch1:$text"] judul
   catch [list exec /home/yus/.local/bin/youtube-dl --get-duration "ytsearch1:$text"] durasi
   catch [list exec /home/yus/.local/bin/youtube-dl "ytsearch1:$text"  --no-playlist --youtube-skip-dash-manifest -f mp4 --output "$path/dl/$judul.%(ext)s"] runcmdd
   set f [open "a.txt" a+]
   puts $f $runcmdd
   close $f
   set fp [open "a.txt" r]
   while { [gets $fp line] >= 0 } {
       if {[string match *ERROR:* $line]} {
           puthelp "PRIVMSG $chan :$line"
           exec rm -f /home/yus/eggdrop/a.txt
           return 0
       }
    }
    close $fp
    set ukuran [file size "$path/dl/$judul.mp4"]
    set besar [fixform $ukuran]
   regsub -all " " $judul "%20" judulbaru
   puthelp "PRIVMSG $chan :\00307\u0141\u0268\u006e\ua741: \00311$linkdl$judulbaru.mp4 \00304(\00307\u1d7e\ua741\u1d7e\u024d\u023a\u006e: \00311$besar\00304) (\00307\u0110\u1d7e\u024d\u023a\u0073\u0268: \00311$durasi \u004d\u0247\u006e\u0268\u0167\00304) $tmark\026"
   puthelp "PRIVMSG $chan :\u023a\u006e\u0111\u023a \u1d7d\u1d7e\u006e\u024f\u023a \u0077\u023a\ua741\u0167\u1d7e 40 \u006d\u0247\u006e\u0268\u0167 \u1d7e\u006e\u0167\u1d7e\ua741 \u0111\u00f8\u0077\u006e\u0142\u00f8\u023a\u0111"
   timer 40 [list apus $chan $judul]
   return 0
}

proc pub_getlinkk {nick host hand chan text } {
    global path linkdl tmark
    putquick "PRIVMSG $chan :\u004d\u00f8\u0127\u00f8\u006e \u0167\u1d7e\u006e\u01e5\u01e5\u1d7e..."
   catch [list exec /home/yus/.local/bin/youtube-dl --get-title "$text"] judul
   catch [list exec /home/yus/.local/bin/youtube-dl --get-duration "$text"] durasi
   catch [list exec /home/yus/.local/bin/youtube-dl --no-playlist --youtube-skip-dash-manifest -f mp4 --output "$path/dl/$judul.%(ext)s" $text] runcmdd
   set f [open "a.txt" a+]
   puts $f $runcmdd
   close $f
   set fp [open "a.txt" r]
   while { [gets $fp line] >= 0 } {
       if {[string match *ERROR:* $line]} {
           puthelp "PRIVMSG $chan :$line"
           exec rm -f /home/yus/eggdrop/a.txt
           return 0
       }
    }
    close $fp
    set ukuran [file size "$path/dl/$judul.mp4"]
    set besar [fixform $ukuran]
   regsub -all " " $judul "%20" judulbaru
   puthelp "PRIVMSG $chan :\00307\u0141\u0268\u006e\ua741: \00311$linkdl$judulbaru.mp4 \00304(\00307\u1d7e\ua741\u1d7e\u024d\u023a\u006e: \00311$besar\00304) (\00307\u0110\u1d7e\u024d\u023a\u0073\u0268: \00311$durasi \u004d\u0247\u006e\u0268\u0167\00304) $tmark\026"
   puthelp "PRIVMSG $chan :\u023a\u006e\u0111\u023a \u1d7d\u1d7e\u006e\u024f\u023a \u0077\u023a\ua741\u0167\u1d7e 40 \u006d\u0247\u006e\u0268\u0167 \u1d7e\u006e\u0167\u1d7e\ua741 \u0111\u00f8\u0077\u006e\u0142\u00f8\u023a\u0111"
   timer 40 [list apus $chan $judul]
   return 0
}

proc mptiga { nick host hand chan text } {
    global tube
    if {![channel get $chan mp3]} { return 0 }
    if {[lindex $text 0] == ""} {
        puthelp "NOTICE $nick :Ketik \002.help\002 untuk melihat perintah."
        return 0
    }
    if {[info exists tube(protection)]} {
        set rest [expr [clock seconds] - $tube(protection)]
        if {$rest < $tube(rest)} {
            puthelp "PRIVMSG $chan :Tunggu [expr $tube(rest) - $rest] detik lagi."
            return 0
        }
        catch { unset rest }
    }
    set tube(protection) [clock seconds]
    if {[string match "*http*" [lindex $text 0]]} {
        pub_getylink $nick $host $hand $chan $text
    } else {
        pub_get $nick $host $hand $chan $text
    }
}
proc pub_get {nick host hand chan text } {
    global path linkdl tmark
    putquick "PRIVMSG $chan :\u004d\u00f8\u0127\u00f8\u006e \u0167\u1d7e\u006e\u01e5\u01e5\u1d7e..."
    set judul [lrange $text 0 end]
   catch [list exec /home/yus/.local/bin/youtube-dl --get-duration "ytsearch1:$text"] durasi
   catch [list exec /home/yus/.local/bin/youtube-dl "ytsearch1:$text" -x --audio-format mp3 --audio-quality 0 --output "$path/dl/$judul.%(ext)s"] runcmd
   set f [open "a.txt" a+]
   puts $f $runcmd
   close $f
   set fp [open "a.txt" r]
   while { [gets $fp line] >= 0 } {
       if {[string match *ERROR:* $line]} {
           puthelp "PRIVMSG $chan :$line"
           exec rm -f /home/yus/eggdrop/a.txt
           return 0
       }
    }
    close $fp
    set ukuran [file size "$path/dl/$judul.mp3"]
    set besar [fixform $ukuran]
   regsub -all " " $judul "%20" judulbaru
   puthelp "PRIVMSG $chan :\00307\u0141\u0268\u006e\ua741: \00311$linkdl$judulbaru.mp3 \00304(\00307\u1d7e\ua741\u1d7e\u024d\u023a\u006e: \00311$besar\00304) (\00307\u0110\u1d7e\u024d\u023a\u0073\u0268: \00311$durasi \u004d\u0247\u006e\u0268\u0167\00304) $tmark\026"
   puthelp "PRIVMSG $chan :\u023a\u006e\u0111\u023a \u1d7d\u1d7e\u006e\u024f\u023a \u0077\u023a\ua741\u0167\u1d7e 20 \u006d\u0247\u006e\u0268\u0167 \u1d7e\u006e\u0167\u1d7e\ua741 \u0111\u00f8\u0077\u006e\u0142\u00f8\u023a\u0111"
   timer 20 [list hapus $chan $judul]
   return 0
}
proc pub_getylink {nick host hand chan text } {
    global path linkdl tmark
    putquick "PRIVMSG $chan :\u004d\u00f8\u0127\u00f8\u006e \u0167\u1d7e\u006e\u01e5\u01e5\u1d7e..."
   catch [list exec /home/yus/.local/bin/youtube-dl --get-title "$text"] judul
   catch [list exec /home/yus/.local/bin/youtube-dl --get-duration "$text"] durasi
   catch [list exec /home/yus/.local/bin/youtube-dl -x --audio-format mp3 --audio-quality 0 --output "$path/dl/$judul.%(ext)s" $text] runcmd
   set f [open "a.txt" a+]
   puts $f $runcmd
   close $f
   set fp [open "a.txt" r]
   while { [gets $fp line] >= 0 } {
       if {[string match *ERROR:* $line]} {
           puthelp "PRIVMSG $chan :$line"
           exec rm -f /home/yus/eggdrop/a.txt
           return 0
       }
    }
    close $fp
    set ukuran [file size "$path/dl/$judul.mp3"]
    set besar [fixform $ukuran]
   regsub -all " " $judul "%20" judulbaru
   puthelp "PRIVMSG $chan :\00307\u0141\u0268\u006e\ua741: \00311$linkdl$judulbaru.mp3 \00304(\00307\u1d7e\ua741\u1d7e\u024d\u023a\u006e: \00311$besar\00304) (\00307\u0110\u1d7e\u024d\u023a\u0073\u0268: \00311$durasi \u004d\u0247\u006e\u0268\u0167\00304) $tmark\026"
   puthelp "PRIVMSG $chan :\u023a\u006e\u0111\u023a \u1d7d\u1d7e\u006e\u024f\u023a \u0077\u023a\ua741\u0167\u1d7e 20 \u006d\u0247\u006e\u0268\u0167 \u1d7e\u006e\u0167\u1d7e\ua741 \u0111\u00f8\u0077\u006e\u0142\u00f8\u023a\u0111"
   timer 20 [list hapus $chan $judul]
   return 0
}
proc help {nick host hand chan args} {
    if {[channel get $chan mp3]} {
    puthelp "PRIVMSG $nick :Perintah Youtube:"
    puthelp "PRIVMSG $nick :\002.c artis - judul\002 | Contoh: .c naif - buta hati"
    puthelp "PRIVMSG $nick :Perintah Mp3:"
    puthelp "PRIVMSG $nick :\002.mp3 <judul + penyanyi>\002 | Contoh: .mp3 naif buta hati"
    puthelp "PRIVMSG $nick :\002.mp3 <link>\002 | Contoh: .mp3 https://www.youtube.com/watch?v=tTjyHBptj5Y"
    puthelp "PRIVMSG $nick :Perintah Mp4:"
    puthelp "PRIVMSG $nick :\002.mp4 <judul>\002 | Contoh: .mp4 naif buta hati"
    puthelp "PRIVMSG $nick :\002.mp4 <link>\002 | Contoh: .mp4 https://www.youtube.com/watch?v=tTjyHBptj5Y"
    puthelp "PRIVMSG $nick :-"
    puthelp "PRIVMSG $nick :Perintah untuk OP:"
    puthelp "PRIVMSG $nick :\002.check\002 | Cek file di folder."
    puthelp "PRIVMSG $nick :-"
    puthelp "PRIVMSG $nick :Perintah untuk Owner:"
    puthelp "PRIVMSG $nick :\002<botnick on/off>\002 | Enable/Disable the downloader."
    puthelp "PRIVMSG $nick :\002<botnick block/unblock nick>\002 | Block/Unblock user."
    puthelp "PRIVMSG $nick :\002.clear\002 | Delete file in server."
 }
}
proc delete_file {nick host hand chan text} {
    if {[matchattr $nick n]} {
        if {[llength $text] < 1} {
            catch [list exec ~/eggdrop/a.sh] vakz
            if {[string match *kosong* [string tolower $vakz]]} {
                puthelp "PRIVMSG $chan :Folder kosong."
            } else {
                puthelp "PRIVMSG $chan :Semua file telah di hapus."
            }
        }
    } else {
        puthelp "NOTICE $nick :Access Denied"
    }
}
proc apus {chan judulbaru} {
    global path
    if {[file exists $path/dl/$judulbaru.mp4] == 1} {
        exec rm -f $path/dl/$judulbaru.mp4
        puthelp "PRIVMSG $chan :File\002 $judulbaru.mp4 \002telah di hapus."
    }
}
proc hapus {chan judulbaru} {
    global path
    if {[file exists $path/dl/$judulbaru.mp3] == 1} {
        exec rm -f $path/dl/$judulbaru.mp3
        puthelp "PRIVMSG $chan :File\002 $judulbaru.mp3 \002telah di hapus."
    }
}
proc pub:onoff {nick uhost hand chan arg} {
    global tmark
    putlog "tes jadi"
    switch [lindex $arg 0] {
        "on" {
            if {[channel get $chan mp3]} {
                puthelp "NOTICE $nick :Already Opened"
                return 0
            }
            channel set $chan +mp3
            putquick "PRIVMSG $chan :- ENABLE -"
            putquick "PRIVMSG $chan :Silahkan download lagu dan video kesukaan anda. Ketik \002.help\002 $tmark"
        }
        "off" {
            if {![channel get $chan mp3]} {
                puthelp "NOTICE $nick :Already Closed"
                return 0
            }
            channel set $chan -mp3
            putquick "PRIVMSG $chan :- DISABLE -"
        }
        "blok" {
            set tnick [lindex $arg 1]
            if {[matchattr $tnick n]} {
                puthelp "NOTICE $nick :$tnick is my owner. -ABORTED-"
                return 0
            }
            set hostmask [getchanhost $tnick $chan]
            set hostmask "*!*@[lindex [split $hostmask @] 1]"
            if {[isignore $hostmask]} {
                puthlp "NOTICE $nick :$tnick is alreay ignored."
                return 0
            }
            newignore $hostmask $hand "*" 0
            puthelp "NOTICE $nick :Ignoring $tnick"
        }
        "unblok" {
            set tnick [lindex $arg 1]
            set hostmask [getchanhost $tnick $chan]
            set hostmask "*!*@[lindex [split $hostmask @] 1]"
            if {![isignore $hostmask]} {
                puthlp "NOTICE $nick :$tnick is not on ignore list."
                return 0
            }
            killignore $hostmask
            puthelp "NOTICE $nick :Unignoring $tnick"
            saveuser
        }
    }
}

proc cekfolder {nick uhost hand chan arg} {
    global path
    if {[isop $nick $chan]==1 || [matchattr $nick n]} {
        if {[llength $arg] < 1} {
            set isi [glob -nocomplain [file join $path/dl/ *]]
            if {[llength $isi] != 0} {
                puthelp "PRIVMSG $chan :Ada [llength $isi] files"
            } else {
                puthelp "PRIVMSG $chan :Folder kosong."
            }
        }
    } else {
        putquick "NOTICE $nick :Access Denied!!!"
    }
}

proc fixform n {
    if {wide($n) < 1000} {return $n}
    foreach unit {KB MB GB TB P E} {
        set n [expr {$n/1024.}]
        if {$n < 1000} {
            set n [string range $n 0 3]
            regexp {(.+)\.$} $n -> n
            set size "$n $unit"
            return $size
        }
    }
    return Inf
 }

namespace eval m00nie {
 namespace eval youtube {
    package require http
    package require json
    package require tls
    tls::init -tls1 true -ssl2 false -ssl3 false
    http::register https 443 tls::socket
    bind pub - .c m00nie::youtube::search
    bind pubm - * m00nie::youtube::autoinfo
    variable version "1.8"
    variable key "AIzaSyANvFnXPCP124fDgK5-45NaYdYO31Z-RtM"
    variable regex {(?:http(?:s|).{3}|)(?:www.|)(?:youtube.com\/watch\?.*v=|youtu.be\/)([\w-]{11})}
    ::http::config -useragent "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/81.0.4044.129 Safari/537.36"

    proc autoinfo {nick uhost hand chan text} {
        if {[regexp -nocase -- $m00nie::youtube::regex $text url id]} {
            putlog "m00nie::youtube::autoinfo is running"
            putlog "m00nie::youtube::autoinfo url is: $url and id is: $id"
            set url "https://www.googleapis.com/youtube/v3/videos?id=$id&key=$m00nie::youtube::key&part=snippet,statistics,contentDetails&fields=items(snippet(title,channelTitle,publishedAt),statistics(viewCount),contentDetails(duration))"
            ##puthelp "PRIVMSG $chan :$url"
            set ids [getinfo $url]
            set title [encoding convertfrom [lindex $ids 0 1 3]]
            set pubiso [lindex $ids 0 1 1]
            regsub {\.000Z} $pubiso "" pubiso
            ##set pubtime [clock format [clock scan $pubiso]]
            set user [encoding convertfrom [lindex $ids 0 1 5]]
        # Yes all quite horrible...
        set isotime [lindex $ids 0 3 1]
        regsub -all {PT|S} $isotime "" isotime
        regsub -all {H|M} $isotime ":" isotime
        if { [string index $isotime end-1] == ":" } {
            set sec [string index $isotime end]
            set trim [string range $isotime 0 end-1]
            set isotime ${trim}0$sec
            } elseif { [string index $isotime 0] == "0" } {
                set isotime "stream"
                } elseif { [string index $isotime end-2] != ":" } {
                    set isotime "${isotime}s"
                }
                set views [lindex $ids 0 5 1]
                puthelp "PRIVMSG $chan :\002\00301,00You\00300,04Tube\003\002 \002$title\002 by $user (duration: $isotime) on $pubiso, $views views"

            }
        }

        proc getinfo { url } {
            for { set i 1 } { $i <= 5 } { incr i } {
                set rawpage [::http::data [::http::geturl "$url" -timeout 5000]]
                if {[string length rawpage] > 0} { break }
            }
            putlog "m00nie::youtube::getinfo Rawpage length is: [string length $rawpage]"
            if {[string length $rawpage] == 0} { error "youtube returned ZERO no data :( or we couldnt connect properly" }
            set ids [dict get [json::json2dict $rawpage] items]
            putlog "m00nie::youtube::getinfo IDS are $ids"
            return $ids

        }

        proc search {nick uhost hand chan text} {
            if {![channel get $chan mp3] } {
                return
            }
            putlog "m00nie::youtube::search is running"
            regsub -all {\s+} $text "%20" text
            set url "https://www.googleapis.com/youtube/v3/search?part=snippet&fields=items(id(videoId),snippet(title))&key=$m00nie::youtube::key&q=$text"
            set ids [getinfo $url]
            set output "\002\00301,00You\00300,04Tube\003\002 "
            for {set i 0} {$i < 5} {incr i} {
                set id [lindex $ids $i 1 1]
                set desc [encoding convertfrom [lindex $ids $i 3 1]]
                regsub -all "&#39;" $desc "\'" desc
                regsub -all "&amp;" $desc "and" desc
                set yout "https://youtu.be/$id"
                append output "\[\00307" $desc "\003 - \00304.mp3 " $yout "\003\] "
            }
            set output [string range $output 0 end]
            puthelp "PRIVMSG $chan :$output"
        }
    }
}
putlog "Mp3 and Mp4 Downloader Loaded ® Presented by uKi`."
