########################################
# News Gateways for www.detik.com
# Dibuat oleh: AresU[at]Bosen.NET
# Create Date: 01/06/2002 21:52
# Update Date: 04/11/2004 02:14
# Anda diperbolehkan melakukan perubahan pada program tetapi tidak pada Copyright Header ini.
# Program ini boleh di distribusikan sebebas-bebasnya tanpa ada batasnya sampek beeebbbaaaasss sekali :-)
# Ucapan terima kasih untuk temen2xku:
#   Bosen, TioEuy, SakitJiwa, Brain, syzwz, HeltZ, Petrix, w4n, Alphacentury, Zen, all family on #romance@centrin.net.id
# Our base at: http://www.bosen.net/releases
########################################

bind pub - !news pub_news

set detikchan "#yobayat"
set detiktimer 20
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
set newschan ""

proc timernews_start {} {
  global detiktimer
  if {[string match *timernews_read* [timers]]} {return 0}
  timer $detiktimer timernews_read
}

timernews_start

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

proc timernews_read {} {
  global detiktimer
  pub_news "" "" "" "" ""
  timer $detiktimer timernews_read
}

proc pub_news {nick uhost hand chan arg} {
global botnick countday ketemu nbody tmparg newsdone newsurl goturl mhari mday hariini newsnick limetitle yellotitle newschan

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
   set newschan [string tolower $chan]
  
   putlog "Connection to http://jkt1.detik.com"
   catch {connect jkt1.detik.com 80} tidx
   control $tidx newsbuffer
   putdcc $tidx "GET /index.htm HTTP/1.0"
   putdcc $tidx "HOST: jkt1.detik.com"
   putdcc $tidx ""
   putlog "..."
   return
}

proc newsbuffer {idx arg} {
global countday ketemu nbody tmparg limetitle yellotitle newsdone newsurl goturl hariini newsnick detikchan newschan
global detikchan detiktimer

   if {[string first $hariini $arg] != -1} {
         incr countday
   }
   if {$countday == 2} {
        set ketemu 1
   }
   set nurl [string first "class=\"hl\"" $arg]
   if {$ketemu == 1 && $goturl == 0 && $nurl != -1} {
     set nurl [expr $nurl -180]
     set tmpurl [string range $arg $nurl 200]
     set nurl [expr [string first "href" $tmpurl] +6]
     set nakhir [expr [string first "\" class" $tmpurl] -1]
     set newsurl [string range $tmpurl $nurl $nakhir]
     if {[string length $newsurl] > 120} {
       set nurl [expr [string first "url" $newsurl] + 4]
       set nakhir [string length $newsurl]
       set newsurl [string range $newsurl $nurl $nakhir]
     }
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
       if {$limetitle == ""} {
         foreach zz $detikchan {
           putserv "PRIVMSG $zz :\0034,1\[DETIKnews\]\0038,1 $yellotitle\00315,1 $newsbody\00311,1 $newsurl"
         }
       } else {
         foreach zz $detikchan {
           putserv "PRIVMSG $zz :\0034,1\[DETIKnews\]\0037,1 $limetitle\0038,1 $yellotitle\00315,1 $newsbody\00311,1 $newsurl"
         }
       }
     }
     if {$newsnick != ""} {
       foreach zz $detikchan {
         if {$newschan == $zz} {
           if {$limetitle == ""} {
             putserv "PRIVMSG $newsnick :\0034,1\[DETIKnews\]\0038,1 $yellotitle\00315,1 $newsbody\00311,1 $newsurl"
           } else {
             putserv "PRIVMSG $newsnick :\0034,1\[DETIKnews\]\0037,1 $limetitle\0038,1 $yellotitle\00315,1 $newsbody\00311,1 $newsurl"
           }
         }
       }
     }
   }
   return 0
}
