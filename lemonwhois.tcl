	# I've made it for linkchat but i assume if the ircd you want to use it on has the same RAW's you can use it just fine.
	set whois(author) "harie on medancyberteam"	

	# Version History
	# 0.1      - Made a start, first expermimental test.
	# 0.2-0.5  - Finished some more code
	# 0.6-0.8  - The script was fully functional
	# 0.9      - Removed some silly crap that didnt work for Quakenet anyhow (shows which server he was on)
	# 1.0      - Cleaned some of the code, and it works fine on Quakenet, It also shows idle time and signon time now.
	set whois(version) "0.10"
	# End of Version History

	# Config:
	# What is the minimum access someone needs to perform a whois with the bot?
	# o = global op, m = global master, n = global owner
	# |o = channel op, |m = channel master, |n = channel owner
	set whois(acc) ""
	# End of Config

	bind pub $whois(acc) ".w" whois:nick
              bind pub $whois(acc) "!whois" whois:nick
              bind pub $whois(acc) ".sapa" whois:nick
              bind pub $whois(acc) ".whois" whois:nick




	proc whois:nick { nickname hostname handle channel arguments } {
	global whois
      set target [lindex [split $arguments] 0]
	if {$target == ""} {
	putquick "PRIVMSG $channel :embeeeeeek -winampv9- ."
	return 0
	}
	# if {[string length $target] >= "14"} {
	# putquick "PRIVMSG $channel :Sorry, That nickname is too long. Please try a user with less than 14 characters."; return
	# }
	# if {[regexp -all -- {[~\[\]\{\}\|\_\\]} $target]} {
	# putquick "PRIVMSG $channel :Sorry, I can't whois a user with special characters in it."; return
	# }
	putquick "WHOIS $target $target"
      set ::whoischannel $channel
	set ::whoistarget $target
	bind RAW - 401 whois:nosuch
	bind RAW - 311 whois:info
	bind RAW - 319 whois:channels
	bind RAW - 301 whois:away
	bind RAW - 313 whois:ircop
	bind RAW - 330 whois:auth
	bind RAW - 317 whois:idle
	}

	proc whois:putmsg { channel arguments } {
		putquick "PRIVMSG $channel :$arguments"
	}

	proc whois:info { from keyword arguments } {
		set channel $::whoischannel
		set nickname [lindex [split $arguments] 1]
		set ident [lindex [split $arguments] 2]
		set host [lindex [split $arguments] 3]
		set realname [string range [join [lrange $arguments 5 end]] 1 end]
		whois:putmsg $channel "$nickname - $ident@$host * $realname"
		unbind RAW - 311 whois:info
	}

	proc whois:ircop { from keyword arguments } {
		set channel $::whoischannel
		set target $::whoistarget
		whois:putmsg $channel "$target is an IRC Operator"
		unbind RAW - 313 whois:ircop
	}

	proc whois:away { from keyword arguments } {
		set channel $::whoischannel
		set target $::whoistarget
		set awaymessage [string range [join [lrange $arguments 2 end]] 1 end]
		whois:putmsg $channel "$target is away: $awaymessage"
		unbind RAW - 301 whois:away
	}

	proc whois:channels { from keyword arguments } {
		set channel $::whoischannel
		set channels [string range [join [lrange $arguments 2 end]] 1 end]
		set target $::whoistarget
		whois:putmsg $channel "$target on $channels"
		unbind RAW - 319 whois:channels
	}

	proc whois:auth { from keyword arguments } {
		set channel $::whoischannel
		set target $::whoistarget
		set authname [lindex [split $arguments] 2]
		whois:putmsg $channel "$target is authed as $authname"
		unbind RAW - 330 whois:auth
	}

	proc whois:nosuch { from keyword arguments } {
		set channel $::whoischannel
		set target $::whoistarget
		whois:putmsg $channel "No such nickname \"$target\""
		unbind RAW - 401 whois:nosuch
	}

	proc whois:idle { from keyword arguments } {
		set channel $::whoischannel
		set target $::whoistarget
		set idletime [lindex [split $arguments] 2]
		set signon [lindex [split $arguments] 3]
		whois:putmsg $channel "$target has been idle for [duration $idletime]. signon time [ctime $signon]"
		unbind RAW - 317 whois:idle
	}

	putlog "Public whois script $whois(version) by $whois(author)"
