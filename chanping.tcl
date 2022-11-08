# TCL to ping every channel, and return ping time.
# For EggDrop 1.1 and 1.2(May work on 1.0[untested]) - requires alltools.tcl
# by David Sesno
#
# Small note: cping is a piece of shit. It was ripped off me by a 
# former friend, because I never released this.
#

# This script will ping each channel, every $pingtimr seconds. 
# Set how often you want this here.
set pingtimr "500"

bind ctcr p PING pingtime

proc pingchan {} {
  global botnick lastchan
  if {![info exists lastchan]} {set lastchan [lindex [channels] 0]}
  set lastonenum [lsearch -exact [channels] $lastchan]
  set lastchan [lindex [channels] [expr $lastonenum + 1]]
  putmsg $lastchan "PING [unixtime]"
  if {![string match "*pingchan*" [utimers]]} { utimer $pingtimr pingchan }  
}

proc pingtime {nick uhost hand botnick key arg} {
  set m 0
  if {"$arg" < 0 || "$arg" > 999999999} {
    putnotc $nick "Your ping reply was: $arg"
    return 0
  }
  set s [expr [unixtime] - $arg]
  if {$s > 60} {
    set m "[expr $s / 60] minute(s) and"
    set s "[expr $s % 60]"
  }
  set s "$s seconds."
  if {$m == "0"} {
    putnotc $nick "Your ping reply was $s"
  } {
    putnotc $nick "Your ping reply was $m $s"
  }
}
if {![string match "*pingchan*" [utimers]]} { utimer 120 pingchan }
