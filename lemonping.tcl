# Begin - Utility, LAG Checker. (utl_ping.tcl)
#	Designed & Written by Unknown
#	Modified and re-coded by Ninja_baby (Jaysee@Jaysee.Tv), © May 2000

# This TCL was modified from simple Anti-Idle script by Slennox (aidle.tcl v1.1 - www.ozemail.com.au/~slenny/eggdrop/).
# I add new features and re-code this script in purpose to have better performance and flexibility. Developing stuffs ;)

# This TCL will send CTCP PING to everyone who ever request it. I add new features for-
# reply announcement to the requester when the bot got they ping replied.
# You can either set your bot to notice the requester about the ping reply, either-
# send a message to a particular channel where the requester sent the request from.
# Also, I add new feature for you to send request to your bot, to ping someone else.
# For example, you type !ping Lamer, then the bot will ping anyone who has nick "Lamer".

# Set this to "0" if you like to bot to notice the PING requester about the ping reply.
# If you set this "1", the bot will send message to a channel where the requester is on,
# and the message will contains their ping replies.
set pinginfo 1

# Set this as the request parameter. For example, when you set this to "!", means-
# someone must type !ping on channel to get pinged.
set PINGPRM "!"

# This is for your benefit hehe ;), you can either set your own LOGO here, your logo will appear-
# when the bot notice you, or when it makes msgs/notices/kicks or scripts loading. So keep smiling-
# and set this variable as you wish ;), you can either set this to "" to leave it blank.
set utlpnglg "\[4x]:"

######### Please do not edit anything below unless you know what you are doing ;) #########

proc ping_req {nick uhost hand chan arg} {
	global botnick PINGPRM pinginfo pingchan utlpnglg
	if {[isbotnick $arg]} {putquick "NOTICE $nick :$utlpnglg usage PING or ${PINGPRM}PING <nickname/me> (I will not ping myself)." ; return 0}
	set arg [string toupper $arg]
	if {[string match "#*" $arg]} {putquick "NOTICE $nick :$utlpnglg usage: PING or ${PINGPRM}PING <nickname/me> (I will not ping $arg)." ; return 0}
	if {$arg == "ME" || $arg == "" || $arg == [string toupper $nick]} {putquick "PRIVMSG $nick :\001PING [unixtime]\001"} else {putquick "PRIVMSG $arg :\001PING [unixtime]\001"}
	if {$pinginfo} {if {![info exist pingchan]} {set pingchan ""} ; append pingchan "$chan "} ; return 0
}

proc ping_reply {nick uhost hand dest key arg} {
	global botnick pinginfo pingchan utlpnglg
	if {[isbotnick $nick]} {return 0}
	if {$pinginfo} {
		set pchan ""
		foreach x $pingchan {
			if {[validchan $x]} {
				if {[onchan $nick $x]} {set pchan $x ; set pingchan [string trim $pingchan $x]}
			} else {putquick "NOTICE $nick :$utlpnglg your PING reply is [expr [unixtime] - $arg] sec(s)." ; return 0}
		}
		if {$pchan != ""} {
			if {[validchan $pchan]} {putquick "PRIVMSG $pchan :$utlpnglg $nick's current PING reply is [expr [unixtime] - $arg] sec(s)."
			} else {putquick "NOTICE $nick :$utlpnglg your PING reply is [expr [unixtime] - $arg] sec(s)."}
		} else {putquick "NOTICE $nick :$utlpnglg your PING reply is [expr [unixtime] - $arg] sec(s)."}
	} else {putquick "NOTICE $nick :$utlpnglg your PING reply is [expr [unixtime] - $arg] sec(s)."} ; return 0
}

bind pub -|- ${PINGPRM}ping ping_req
bind pub -|- ping ping_req
bind ctcr - PING ping_reply
putlog "${utlpnglg} Utility, LAG Checker. Loaded."

# End of - Utility, LAG Checker. (utl_ping.tcl)