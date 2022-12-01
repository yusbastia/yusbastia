bind ctcp - "ACTION" pub_antislap
set slapampun {
  "ampun bosss"
  "siaaaappp bos"
  "Hadirrrr bos"
  "ada apa bos !!!"
  "siaapp grakk"
  "baiklah bosss"
  "oke bebe!!"
}
set slapkick {
  "yiiihaaaaaaaaaaaaaaaaaaaaaaaa"
  "nangisooo ae ... dontslap"
  "yeeeeaaaaahhhhhhhhhh"
  "uhuk uhuk, yeeeeahhhh"
  "faking sitttttt"
  "wooooohoooooooooooo yeeeeaaaahhhhhh"
}
set slapbos {
  "jangan ganggu boskuuuuuu"
  "gooooo awayyyyyy you fakkking sit, dont slap my boss"
  "yiiiiiihaaaaaaaa , my bos is bussy, go away"
  "uhuk uhuk, yeeeeahhhh, what tha fakkk"
  "bos lagi sibuk"
  "bos lagi tidur, mohon jangan di ganggu, yeeeeaaaaaahhhhhh"
}
proc pub_antislap { nick uhost hand dest keyword text } {
     global botnick slapampun slapkick slapbos
     set text [string tolower $text]

     if {[string index $dest 0] != "#"} { return 0 }
     if {[lindex $text 0] == "slaps" || [lindex $text 0] == "slap"} {
       if {$nick == "jes_" || $nick == "sempax"} {
         if {[lindex $text 1] == $botnick} {
           putserv "privmsg $dest :[lindex $slapampun [rand [llength $slapampun]]]"
           return 0
         }
         return 0
       }
       if {[lindex $text 1] == $botnick} {
          putserv "kick $dest $nick : 1[lindex $slapkick [rand [llength $slapkick]]]"
          return 0
       }
       if {[lindex $text 1] == "jes_" || [lindex $text 1] == "sempax" || [lindex $text 1] == "wedush" } {
          putserv "kick $dest $nick : 1[lindex $slapbos [rand [llength $slapbos]]]"
          return 0
       }
       return 0
     }
 }
putlog "busukslap loaded"
