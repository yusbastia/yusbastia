###################################
# News Gateways for www.detik.com #
###################################

bind pub - !news pub_news
bind msg m !newsuser msg:newsadduser

set fnewsuser scripts/newsuser.txt
set countday 0
set ketemu 0
set nbody 0
set tmparg ""
set limetitle ""
set yellotitle ""
set newsdone 0
set newsurl ""
set goturl 0
set hariini ""
set newsnick ""

timer 4 timernews

set mhari {
 Senin
 Selasa
 Rabu
 Kamis
 Jumat
 Sabtu
 Minggu
}

set mday {
 Mon
 Tue
 Wed
 Thu
 Fri
 Sat
 Sun
}

proc timernews {} {
   pub_news "" "" "" "" ""
   timer 4 timernews
}

proc pub_news {nick uhost hand channel arg} {
global botnick countday ketemu nbody tmparg newsdone newsurl goturl mhari mday hariini fnewsuser newsnick limetitle yellotitle

   if {![file exists $fnewsuser]} {
        set fd [open $fnewsuser w]
        close $fd
   }
   set fd [open $fnewsuser r]
   set j 0
   while {![eof $fd]} {
     lappend newsusers [gets $fd]
     set j [incr j] 
   }
   close $fd
   
   if {[lsearch $newsusers $nick] == -1 && $nick != ""} {
     putserv "NOTICE $nick :\0030,12 NEWS \00311,1 Sekali² Beli Koran Dong :p "      
     return 0
   }
   set countday 0
   set ketemu 0
   set nbody 0
   set tmparg ""
   set limetitle ""
   set yellotitle ""
   set newsdone 0
   set goturl 0
   set newsurl ""
   set hariini [lindex $mhari [lsearch $mday [string range [ctime [unixtime]] 0 2]]]
   set newsnick $nick
   
   if {$newsnick != ""} {
      putlog "\[NEWS\] <$newsnick>!news"
      putserv "NOTICE $newsnick :\0030,12 NEWS \0038,1 News Gateways"
      putserv "NOTICE $newsnick :\0030,12 NEWS \0038,1 Please wait when reading news from detik.com ..."
   }
   
   putlog "Connection to http://www.detik.com"
   catch {connect jkt1.detik.com 80} tidx
   control $tidx newsbuffer
   putdcc $tidx "GET /index.php HTTP/1.1"
   putdcc $tidx "HOST: www.detik.com"
   putdcc $tidx ""
   putlog "..."
   return
}

proc newsbuffer {idx arg} {
global countday ketemu nbody tmparg limetitle yellotitle newsdone newsurl goturl hariini newsnick

   if {[string first $hariini $arg] != -1} {
         incr countday
   }
   if {$countday == 2} {
        set ketemu 1
   }
   set nurl [string first "class=\"hl\"" $arg]
   if {$ketemu == 1 && $goturl == 0 && $nurl != -1} {
     set nurl [expr $nurl -130]
     set tmpurl [string range $arg $nurl 150]
     set nurl [expr [string first "href" $tmpurl] +6]
     set nakhir [expr [string first "\" class" $tmpurl] -1]
     set newsurl [string range $tmpurl $nurl $nakhir]
     set goturl 1
   }
   set nlime [string first "subjudul" $arg]
   if {$ketemu == 1 && $nlime != -1} {
	putlog "\[NEWS\] Get Lime Title"
   	set nlime [expr $nlime +10]
   	set nakhir [expr [string first "\<" $arg] -1]
   	set limetitle [string range $arg $nlime $nakhir]
   }
   set nyello [string first "strJudul" $arg]
   if {$ketemu == 1 && $nyello != -1} {
	putlog "\[NEWS\] Get Yello Title"
   	set nyello [expr $nyello +10]
	set tmpyello [string range $arg $nyello [expr $nyello + 100]]
   	set nakhir [expr [string first "\<" $tmpyello] -1]
   	set yellotitle [string range $tmpyello 0 $nakhir]
	set nbody 1
	set tmparg $arg
   }
   if {$nbody == 1 && $tmparg != $arg} {
   	set nawal [expr [string first "summary" $arg] +9]
   	set nakhir [expr [string first "</span>" $arg] -1]
   	set newsbody $arg
   	if {$nakhir > 1} {
   	set newsbody [string range $arg $nawal $nakhir]
   	}
   	set newsdone 1
   	killdcc $idx
   }
   if {$newsdone == 1} {
      putlog "\[NEWS\] Download News Done"
      if {$newsnick == ""} {
           foreach ruang [channels] {
              putserv "PRIVMSG $ruang :\0034,9\[DETIKnews\] \0039,2$limetitle \0038,2$yellotitle \0030,2$newsbody \00311,2$newsurl"
           }
      } else {
              putserv "NOTICE $newsnick :\0034,9\[DETIKnews\] \0039,2$limetitle \0038,2$yellotitle \0030,2$newsbody \00311,2$newsurl"
      }
   }
   return 0
}

proc msg:newsadduser {nick uhost hand arg} {
     global fnewsuser

     putlog "\[NEWS\] <$nick> !newsadduser"
     set fd [open $fnewsuser a]
     puts $fd $arg
     close $fd
     putserv "NOTICE $nick :\0030,12 NEWS \00311,1 New User ---> \0038$arg "
     putserv "NOTICE $arg :\0030,12 NEWS \0038,1 Welcome to Our News Gateways"
     putserv "NOTICE $arg :\0030,12 NEWS \0038,1 Type !news to get news from detik.com, remember this is realtime news"
     return
}

