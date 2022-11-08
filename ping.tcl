# dccping.tcl by LSC
# little script to ping people or channels if you decide to do irc from
# your bot, works relatively well.

bind dcc m ping dcc_ping
bind ctcr - PING pingtime

# uncomment the bind below if you want your bot to return only a ping
# message and no time when someone pings it.
#bind ctcp - PING ping_response

# set this as whatever ping message you want after uncommenting above line.
set pingreply "blahhhh"

	proc dcc_ping {hand idx arg} {
	global who
	set who [idx2hand $idx]
	putserv "PRIVMSG [lindex $arg 0] :\001PING [unixtime]\001"
	return 1
	}

	proc pingtime {nick uhost hand botnick key arg} {
	global who
	  if {[hand2idx $who] != "-1"} {
	  putdcc [hand2idx $who] "### CTCP PING reply from ${nick}: [expr [unixtime] - $arg] seconds"
	  }
	}

	proc ping_response {nick uhost hand botnick key arg} {
 	global pingreply 
	putserv "NOTICE $nick :$pingreply"
	return 1
	} 

