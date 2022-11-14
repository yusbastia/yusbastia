set help_chans "*"

##  help  ##
set Reponden5.v "help respon"
bind pub - ?help help_speak
bind pub - .help help_speak
set ranhelp {
  "0,4 .seen <nick> 0,2 .w whois <nick> 0,3 !dns dns <nick> 0,8 !dns <host> 0,5 !port <host> 0,7 .ip <host> 0,6 Bom <nick> "
}

proc help_speak {nick uhost hand chan text} {
 global botnick help_chans ranhelp
if {(([lsearch -exact [string tolower $help_chans] [string tolower $chan]] != -1) || ($help_chans == "*"))} {
set helps [lindex $ranhelp [rand [llength $ranhelp]]]
putserv "NOTICE $nick :$helps"
  }
} 

set ping_chans "*"

##  ping  ##
set Reponden5.v "ping respon"
bind pub - ping ping_speak
bind pub - lag ping_speak
set ranping {
  "Sama gua juga lemot boz..!!"
  "ping"
  "Preetttttttt...!!!"
  "Capek Dehhh..!!!"
}

proc ping_speak {nick uhost hand chan text} {
 global botnick ping_chans ranping
if {(([lsearch -exact [string tolower $ping_chans] [string tolower $chan]] != -1) || ($ping_chans == "*"))} {
set pings [lindex $ranping [rand [llength $ranping]]]
putserv "PRIVMSG $chan :$pings"
  }
}

set wk_chans "*"

##  wk  ##
set Reponden5.v "wk respon"
bind pub - .wk wk_speak
set ranwk {
  "4W12a4K12a4K12a4K12a ... 7H3i13k12s ... 4H12a4H12a4H12a ... 7H3i13k12s"
}

proc wk_speak {nick uhost hand chan text} {
 global botnick wk_chans ranwk
if {(([lsearch -exact [string tolower $wk_chans] [string tolower $chan]] != -1) || ($wk_chans == "*"))} {
set wks [lindex $ranwk [rand [llength $ranwk]]]
putserv "PRIVMSG $chan :$wks"
 }
}
