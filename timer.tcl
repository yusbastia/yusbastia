set timemessage_setting(message) {
	"This is a message."
	"You can add as many lines as you wish."
}
set timemessage_setting(channel) "#basechanel #chan2"

set timemessage_setting(time) "5"

if {![string match 1.6.* $version]} { putlog "\002TIMEMESSAGE:\002 \002WARNING:\002 This script is intended to run on eggdrop 1.6.x or later." }
if {[info tclversion] < 8.2} { putlog "\002TIMEMESSAGE:\002 \002WARNING:\002 This script is intended to run on Tcl Version 8.2 or later." }

if {[string compare [string index $timemessage_setting(time) 0] "!"] == 0} { set timemessage_timer [string range $timemessage_setting(time) 1 end] } { set timemessage_timer [expr $timemessage_setting(time) * 60] }
if {[lsearch -glob [utimers] "* timemessage_go *"] == -1} { utimer $timemessage_timer timemessage_go }

proc timemessage_go {} {
	foreach chan $::timemessage_setting(channel) {
		if {![validchan $chan] || ![botonchan $chan]} { continue }
		foreach line $::timemessage_setting(message) { putserv "PRIVMSG $chan :$line" }
	}
	if {[lsearch -glob [utimers] "* timemessage_go *"] == -1} { utimer $::timemessage_timer timemessage_go }
}
putlog "\002TIMEMESSAGE:\002 TimeMessage.tcl Version 1.0 by Wcc is loaded."
