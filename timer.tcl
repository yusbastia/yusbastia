############
##  Time  ##
############
bind pub - .time timecheck
bind pub - !time timecheck
bind pub - .jam timecheck
bind pub - !jam timecheck
bind RAW - 391 timereply

set servtime "irc.chating.id"

proc timecheck { nick uhost hand chan text } {
 global botnick servtime
 putquick "TIME $servtime"
 set ::timechan $chan
}
proc timereply { from keyword arguments } {
 set channel $::timechan
 time:output $channel $arguments
}
proc time:output { channel arguments } {
global botnick servtime
 set day [lindex [split $arguments] 2]
 if {$day == ":Monday"} { set hari "Senin" }
 if {$day == ":Tuesday"} { set hari "Selasa" }
 if {$day == ":Wednesday"} { set hari "Rabu" }
 if {$day == ":Thursday"} { set hari "Kamis" }
 if {$day == ":Friday"} { set hari "Jum'at" }
 if {$day == ":Saturday"} { set hari "Sabtu" }
 if {$day == ":Sunday"} { set hari "Minggu" }
 set tanggal [lindex [split $arguments] 4]
 set month [lindex [split $arguments] 3]
 if {$month == "January"} { set bulan "Januari" }
 if {$month == "February"} { set bulan "Februari" }
 if {$month == "March"} { set bulan "Maret" }
 if {$month == "April"} { set bulan "April" }
 if {$month == "May"} { set bulan "Mei" }
 if {$month == "June"} { set bulan "Juni" }
 if {$month == "July"} { set bulan "Juli" }
 if {$month == "August"} { set bulan "Agustus" }
 if {$month == "September"} { set bulan "September" }
 if {$month == "October"} { set bulan "Oktober" }
 if {$month == "November"} { set bulan "November" }
 if {$month == "December"} { set bulan "Desember" }
 set tahun [lindex [split $arguments] 5]
 set jam [lindex [split $arguments] 7]
 putquick "PRIVMSG $channel :03Time :04 $hari - $tanggal $bulan $tahun - $jam \(07$servtime\)"
}
