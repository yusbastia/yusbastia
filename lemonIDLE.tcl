######################################
#[ KocHiWalker@Gmail.Com            ]#
#[ uKi` @ Dalnet&Allnetwork         ]#
#[ - idleversion.tcl (Ocr 2018)     ]#
#[ for eggdrop 1.8.*                ]#
######################################

bind pub - .idle kwhois:nick
bind pub - !idle kwhois:nick
bind pub - idle kwhois:nick
bind pub - .version kversion:nick
bind pub - !version kversion:nick
#bind pub - .ver kversion:nick
bind pub - version kversion:nick

proc kwhois:nick {nickname hostname handle channel arguments} {
  global kwhois
  set target [lindex [split $arguments] 0]
  if {$target == ""} {
    putquick "PRIVMSG $channel :[kchi_vern]"
    return 0
  }
  putquick "WHOIS $target $target"
  set ::whoischannel $channel
  set ::whoistarget $target
  bind RAW - 402 kwhois:nosuch
  bind RAW - 317 kwhois:idle
  bind RAW - 318 kwhois:end
}
proc kwhois:putmsg { channel arguments } {
  putquick "PRIVMSG $channel :$arguments"
}
proc kwhois:nosuch { from keyword arguments } {
  set channel $::whoischannel
  set target $::whoistarget
  kwhois:putmsg $channel "No such nickname \"$target\""
  kwhois:end
}
proc kwhois:idle { from keyword arguments } {
  set channel $::whoischannel
  set target $::whoistarget
  set idletime [lindex [split $arguments] 2]
  set signon [lindex [split $arguments] 3]
  set formatidle "%I:%M:%S%p \u1d42\u1d35\u1d40\u1d2c %A, %d %B %Y"
  set signon2 [clock format $signon -timezone :Asia/Makassar -format $formatidle]
   regsub -all {0} $signon2 "\uff10" signon2
   regsub -all {1} $signon2 "\uff11" signon2
   regsub -all {2} $signon2 "\uff12" signon2
   regsub -all {3} $signon2 "\uff13" signon2
   regsub -all {4} $signon2 "\uff14" signon2
   regsub -all {5} $signon2 "\uff15" signon2
   regsub -all {6} $signon2 "\uff16" signon2
   regsub -all {7} $signon2 "\uff17" signon2
   regsub -all {8} $signon2 "\uff18" signon2
   regsub -all {9} $signon2 "\uff19" signon2
  regsub -all {Sunday} $signon2 "\00304Min\003" signon2
  regsub -all {Monday} $signon2 "\00303Sen\003" signon2
  regsub -all {Tuesday} $signon2 "\00303Sel\003" signon2
  regsub -all {Wednesday} $signon2 "\00303Rab\003" signon2
  regsub -all {Thursday} $signon2 "\00303Kam\003" signon2
  regsub -all {Friday} $signon2 "\00303Jum\003" signon2
  regsub -all {Saturday} $signon2 "\00303Sab\003" signon2
  regsub -all {January} $signon2 "\00305Jan\003" signon2
  regsub -all {February} $signon2 "\00313Feb\003" signon2
  regsub -all {March} $signon2 "\00302Mar\003" signon2
  regsub -all {April} $signon2 "\00310Apr\003" signon2
  regsub -all {May} $signon2 "\00314Mei\003" signon2
  regsub -all {June} $signon2 "\00308Jun\003" signon2
  regsub -all {July} $signon2 "\00307Jul\003" signon2
  regsub -all {August} $signon2 "\00311Agu\003" signon2
  regsub -all {September} $signon2 "\00304Sep\003" signon2
  regsub -all {October} $signon2 "\00309Okt\003" signon2
  regsub -all {November} $signon2 "\00313Nov\003" signon2
  regsub -all {December} $signon2 "\00303Des\003" signon2
  regsub -all {AM} $signon2 "\00303\u1d43\u1d50\003" signon2
  regsub -all {PM} $signon2 "\00303\u1d56\u1d50\003" signon2
  set nidle [duration $idletime]
   regsub -all {0} $nidle "\uff10" nidle
   regsub -all {1} $nidle "\uff11" nidle
   regsub -all {2} $nidle "\uff12" nidle
   regsub -all {3} $nidle "\uff13" nidle
   regsub -all {4} $nidle "\uff14" nidle
   regsub -all {5} $nidle "\uff15" nidle
   regsub -all {6} $nidle "\uff16" nidle
   regsub -all {7} $nidle "\uff17" nidle
   regsub -all {8} $nidle "\uff18" nidle
   regsub -all {9} $nidle "\uff19" nidle
  regsub -all "years" $nidle "tahun" nidle
  regsub -all "year" $nidle "tahun" nidle
  regsub -all "months" $nidle "bulan" nidle
  regsub -all "month" $nidle "bulan" nidle
  regsub -all "weeks" $nidle "minggu" nidle
  regsub -all "week" $nidle "minggu" nidle
  regsub -all "days" $nidle "hari" nidle
  regsub -all "day" $nidle "hari" nidle
  regsub -all "hours" $nidle "jam" nidle
  regsub -all "hour" $nidle "jam" nidle
  regsub -all "minutes" $nidle "menit" nidle
  regsub -all "minute" $nidle "menit" nidle
  regsub -all "seconds" $nidle "detik" nidle
  regsub -all "second" $nidle "detik" nidle
  kwhois:putmsg $channel "\00304\[\003$target\00304\]\003 \x1didle\x1d \002-=(\002$nidle\002)=-\002 \x1dOn Sejak\x1d : \002-=(\002$signon2\002)=-\002"
}
proc kwhois:end { from keyword arguments } {
  unbind RAW - 402 kwhois:nosuch
  unbind RAW - 317 kwhois:idle
  unbind RAW - 318 kwhois:end
}
###########################################################
bind ctcr * VERSION mocekdloke
set movers "off"
proc kversion:nick {nickname hostname handle channel arguments} {
   global verchan movers
   if {$movers == "on"} {
      putserv "NOTICE $nickname :tunggu beberapa saat lagi"
      return 0
   }
   set verchan $channel
   set target [lindex $arguments 0]
   putserv "PRIVMSG $target :\001VERSION\001"
   bind RAW - 401 kversion:nosuch
   bind RAW - 492 kversion:noctcp
   set movers "on"
   utimer 10 [list cekmovers $movers $channel]
}

proc kversion:nosuch {from keyword arguments} {
   global verchan movers
   unbind RAW - 401 kversion:nosuch
   set outpot [lrange $arguments 1 end]
   putserv "PRIVMSG $verchan :$outpot"
   set movers "off"
}
proc kversion:noctcp {from keyword arguments} {
   global verchan movers
   unbind RAW - 492 kversion:noctcp
   set outpot [lrange $arguments 1 end]
   regsub -all "\:" $outpot "" outpot
   putserv "PRIVMSG $verchan :$outpot"
   set movers "off"
}

proc mocekdloke {nick uhost hand dest key txt} {
   global verchan movers
   regsub -all "mIRC" $txt "\00302m\00304IR\00308C\003" txt
   putserv "PRIVMSG $verchan :\00304\[\003$nick\00304\]\003 $txt"
   set movers "off"
}

proc cekmovers {moverscek chan} {
   global movers
   if {$moverscek == "on"} {
      set movers "off"
   }
}
putlog "idleversion    write_ by KocHi (uKi`/akai) -: LoadeD :-"
