package require json
package require http
package require tls

set setroom "#yobayat #TapaAog"

if {![file exists gempa]} {
exec touch gempa
}

bind pub - .gempa gempabumi
proc gempabumi {nick uhost hand chan arg} {
gempa $chan "manual"
}

timer 5 AutoGempa
proc AutoGempa { args } {
putlog "reload"
gempa "room" "auto"
timer 5 AutoGempa
}

proc gempa {chan mode} {

	::http::register https 443 [list ::tls::socket -tls1 1]

	if {[catch {http::geturl "https://data.bmkg.go.id/DataMKG/TEWS/autogempa.json"} tok]} {
		putlog "Socket error: $tok"
		return 0
	}
	if {[http::status $tok] ne "ok"} {
		set status [http::status $tok]

		putlog "TCP error: $status"
		return 0
	}
	if {[http::ncode $tok] != 200} {
		set code [http::code $tok]
		http::cleanup $tok

		putlog "HTTP Error: $code"
		return 0
	}

	set data [http::data $tok]

	set parse [lindex [dict get [json::json2dict $data] Infogempa] 1]
	
    if {$mode == "manual"} {

	set TemP "[lindex $parse 0]: \00314[lindex $parse 1]\017, [lindex $parse 2]: \00314[lindex $parse 3]\017, [lindex $parse 6]: \00314[lindex $parse 7]\017, [lindex $parse 12]: \00314[lindex $parse 13]\017, [lindex $parse 14]: \00314[lindex $parse 15]\017"

	putquick "PRIVMSG $chan :\00305,08\002\037\/!\\\002\017 \00305\002WARNING GEMPA\002\017 \00305,08\002\037\/!\\\002\017"

	putserv "privmsg $chan :[concat $TemP]"

	puthelp "privmsg $chan :[concat [lindex $parse 16]: \00314[lindex $parse 17]]"
	puthelp "privmsg $chan :[concat [lindex $parse 18]: \00314[lindex $parse 19]]"
	puthelp "privmsg $chan :[concat [lindex $parse 20]: \00314[lindex $parse 21]]"
    } else {
	set o [open gempa r] ; set wr [gets $o] ; close $o

	if {$wr == [lindex $parse 3]} { return }

	set TemP "[lindex $parse 0]: \00314[lindex $parse 1]\017, [lindex $parse 2]: \00314[lindex $parse 3]\017, [lindex $parse 6]: \00314[lindex $parse 7]\017, [lindex $parse 12]: \00314[lindex $parse 13]\017, [lindex $parse 14]: \00314[lindex $parse 15]\017"

	set pile [open gempa w]; puts $pile [lindex $parse 3]; close $pile

	mesage PRIVMSG "\00305,08\002\037\/!\\\002\017 \00305\002WARNING GEMPA\002\017 \00305,08\002\037\/!\\\002\017"

	mesage PRIVMSG "[concat $TemP]"

	mesage PRIVMSG "[concat [lindex $parse 16]: \00314[lindex $parse 17]]"
	mesage PRIVMSG "[concat [lindex $parse 18]: \00314[lindex $parse 19]]"
	mesage PRIVMSG "[concat [lindex $parse 20]: \00314[lindex $parse 21]]"
    }
}

proc mesage { mode text } {
 global setroom
   foreach chann [channels] { 
      if {$setroom == "" } { putquick "$mode $chann :$text" } 
      if {$setroom != "" } { 
         if {([lsearch -exact [string tolower $setroom] [string tolower $chann]] != -1)} {putquick "$mode $chann :$text"} 
     }
   }
}

putlog "tcl BMKG INDO by ucup"
