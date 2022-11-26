### eggping.tcl v1.0.6, 27 December 2003
### by Graeme Donaldson
### (Souperman @ #eggdrop @ Undernet)
### Visit http://www.eggdrop.za.net/ for updates and other Tcl scripts.
###
### Lets your eggdrop listen for ping requests on channel or /msg
### Not the world's best script, but somebody asked for it. =)
###
### To use:
###  - Extract the files to your eggdrop scripts dir.
###  - Add a 'source scripts/eggping.tcl' to your eggdrop's config file.
###  - Edit the settings below if necessary, then .rehash your eggdrop.
### Anyone can now type request a ping from the bot using (defaults):
###  - !ping or !pingme on a channel, or
###  - /msg bot ping or /msg bot pingme
###
### Multiple triggers can be configured for both public and /msg requests.
### Can accept ping requests only from users with specific flags.
### Can reply to ping requests only from specific channels.
### Can ignore ping requests made on certain channels.
### Can calculate the ping reply in milliseconds (requires Tcl 8.3 or higher)
### Can tell the user what server the bot is currently on.
###
### History:
###
### 1.0.0 29-Mar-2002 First release.
### 1.0.1 01-Apr-2002 Removed a small bit of code which I'd used for debugging.
###                   Show website address when the script loads.
### 1.0.2 11-May-2003 Fixed calculation bug on some systems with Tcl 8.3+.
### 1.0.3 21-May-2003 Modified wording of bot's reply to make it clearer.
### 1.0.4 19-Nov-2003 Fixed another calculation bug.
###                   Added option to specify whether you want to show ping
###                    time in milliseconds (if Tcl version allows this).
###                   Made telling the user the bot's current server an option.
### 1.0.5 23-Nov-2003 Added an option to specify which channels to respond to
###                    ping requests on.
###                   Added an option to specify that ping requests only be
###                    accepted by users with certain flags.
###                   Removed a debugging message I had left behind from the
###                    previous version.
### 1.0.6 27-Dec-2003 Fixed a bug caused by come clients refusing to reply
###                    to a CTCP PING with a negative number.
################################################################################

### You can change these settings if you want ###

# Public triggers, seperated by spaces.
set pingpubwords "!ping !pingme"
set pingpubwords "lag lagme"
set pingpubwords "ping pingme"

# /msg triggers, seperated by spaces.
set pingmsgwords "ping pingme"

# If you want to restrict ping requests to users with certain flags, change this.
set pingreqdflags "-|-"

# If you only want the bot to respond to requests from specific channels,
# set them here, separated by spaces, e.g. "#foo #bar #baz".  Setting one
# or more channels here makes the bot ignore the disabled chans setting.
set pingenabledchans ""

# If there are channels where you don't want the bot to listen for !ping
# requests, set them here, seperated by spaces, e.g. "#lame #lamer #lamest".
# This setting is meaningless if a specific list of channels have been given
# in the enabled chans setting.
set pingdisabledchans ""

# Do you want to calculate ping replies in milliseconds (1) or not (0)?
# Millisecond calculation only works on Tcl 8.3 and above, but you can safely
# leave this enabled, the script will detect your Tcl version and disable this
# if necessary.
set pingmilli 1

# Do you want the bot to tell the user what server it is currently on (1)
# or not (0)?
set pingtellserver 1


### YOU SHOULDN'T NEED TO EDIT ANYTHING BEYOND THIS POINT! ###
# Misc. stuff
set pingver "1.0.6"
set pingnver "100006"
putlog "Loading eggping.tcl $pingver by Souperman..."
if { ([info tclversion] < 8.3) && ($pingmilli == 1) } {
	set pingmilli 0
	putlog " eggping.tcl: warning: cannot calculate PINGs in milliseconds (requires Tcl 8.3 or higher). PINGs will be calculated in seconds."
}

# binds
foreach trigger [split $pingpubwords] { bind pub $pingreqdflags $trigger pingnickpub }
foreach trigger [split $pingmsgwords] { bind msg $pingreqdflags $trigger pingnickmsg }
bind ctcr $pingreqdflags PING pingreply

# triggered by ping command on channel
proc pingnickpub {nick uhost hand chan text} {
	if {$::pingenabledchans != ""} {
		foreach channel [split $::pingenabledchans] {
			if {[string tolower $channel] == [string tolower $chan]} {
				pingnick $nick
				return 1
			}
		}
		return 0
	} else {
		foreach channel [split $::pingdisabledchans] {
			if {[string tolower $channel] == [string tolower $chan]} {
				return 0
			}
		}
		pingnick $nick
		return 1
	}
}

# triggered by ping command via msg
proc pingnickmsg {nick uhost hand text} {
	pingnick $nick
	return 1
}

# called by pingnickpub or pingnickmsg, sends a CTCP PING to $nick.
proc pingnick {nick} {
	if {$::pingmilli} {
		putquick "PRIVMSG $nick :\001PING [expr {abs([clock clicks -milliseconds])}]\001"
	} else {
		putquick "PRIVMSG $nick :\001PING [unixtime]\001"
	}
}

# processes a CTCP PING reply.
proc pingreply {nick uhost hand dest key args} {
	set pingnum [lindex $args 0]
	set pingserver [lindex [split $::server :] 0]
	# sanity check -- only processes the CTCP PING reply if it's value is a number
	if {[regexp -- {^-?[0-9]+$} $pingnum]} {
		if {$::pingmilli} {
			puthelp "NOTICE $nick :Ping reply from $::botnick[expr $::pingtellserver?\" (currently on $pingserver) \":\" \"]to $nick: [expr {abs([expr [expr {abs([clock clicks -milliseconds])} - $pingnum] / 1000.000])}] seconds"
		} else {
			puthelp "NOTICE $nick :Ping reply from $::botnick[expr $::pingtellserver?\" (currently on $pingserver) \":\" \"]to $nick: [expr [unixtime] - $pingnum] seconds"
		}
	}
}
putlog " Visit http://www.eggdrop.za.net/ for updates and other Tcl scripts."
putlog "Successfully loaded eggping.tcl $pingver by Souperman!"
