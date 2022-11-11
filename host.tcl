###### HOST.TCL - Some people have problems using DNS to lookup
######            names on the Internet. This TCL gives them the
######            the ability to lookup names without having to
######            have DNS working. As long as they can get on IRC
######            then they can lookup names. :-)
######            (I've seen it happen, hence this script.)

######		05/10/99 - Added a msg cmd (!host) and a DCC cmd (.host)

###### Instructions -
######            All you need to do is add the line 'source scripts/host.tcl' to
######            the bottom of your config file and the bot will do the rest.

###### Credits - I got the idea by looking through J.Ede's <j.d.ede@sheffield.ac.uk> dns_lookups-1.1.tcl
######           script. So my thanks to him for helping me learn about the open, close, puts, and catch
######           calls.

###### Bugs - If you have modified the script and then the error happened, you are on your own because
######        you broke the warrenty. ;-)
######
######        If everything is like it should be, and you know the script should work then email me at
######        buddha@ih8dos.com and I will try to help you fix whatever is fubarred.
######
######
###### Don't modify anything from here down. You are on your own if you do because it should work
###### perfectly out of the box. Good Luck, and you have been forewarned.
#################################################################################################
set hostpath [exec pwd]/host.pl

if {![file exists $hostpath]} {
	putlog "Uh oh, couldn't find 'host.pl' so I will create it for you. :-)"
	append out "#\!/usr/bin/perl\n"
	append out "# Automatically Generated, do not edit anything but the path above!\n"
	append out "\n"
	append out "\$host \= \`host \@ARGV 2\>/dev/null\`\;\n"
	append out "if \(\$host eq \"\"\) \{\n"
	append out "        print \"Host not found, try again.\\n\"\;\n"
	append out "\} else \{\n"
	append out "        foreach \$line \(\$host\) \{\n"
	append out "                print \"\$line\"\;\n"
	append out "        \}\n"
	append out "\}\n"
	set fd [open "$hostpath" w]
	puts $fd $out
	unset out
	close $fd
	exec chmod 755 $hostpath
}

bind pub - !host pub_dnslookup
bind pub - .h pub_dnslookup
bind pub - !dns pub_dnslookup



proc pub_dnslookup {nick uhost hand chan text} {
	global hostpath
	set host [lindex $text 0]
	if {$host == ""} {
		putserv "PRIVMSG $chan :$nick, apa yang harus aku cari."
		return 0
	} else {
		putserv "PRIVMSG $chan :Ok $nick, saya akan perlihatkan hasilnya \002$host\002 untukmu :-)"
		set input [open "|$hostpath $host" r]
		while {![eof $input]} {
			catch {[set contents [gets $input]]}
			if {$contents == "Host not found, try again."} {
				putserv "PRIVMSG $chan :I'm sorry $nick, saya mencoba cari \002$host\002, namun tidak ada informasi apapun."
				catch {close $input}
				putlog "<<$hand>> $nick ($chan) !host $text"
				return 0
			} elseif {$contents != ""} {
				putserv "PRIVMSG $chan :\002$contents\002"
			} else { }
		}
		close $input	
	}
	putlog "<<$hand>> $nick ($chan) !host $text"
	return 0
}

bind msg - !host msg_dnslookup

proc msg_dnslookup {nick uhost hand text} {
	global hostpath
	set host [lindex $text 0]
	if {$host == ""} {
		putserv "PRIVMSG $nick :apa yang harus aku cari."
		return 0
	} else {
		putserv "PRIVMSG $nick :Ok, saya akan perlihatkan hasilnya \002$host\002 untukmu. :-)"
		set input [open "|$hostpath $host" r]
		while {![eof $input]} {
			catch {[set contents [gets $input]]}
			if {$contents == "Host tidak di temukan, coba lagi."} {
				putserv "PRIVMSG $nick :maaf, saya mencari \002$host\002, namun tidak menemukan informasi apapun."
				catch {close $input}
				putlog "($hand) $nick !host $text"
				return 0
			} elseif {$contents != ""} {
				putserv "PRIVMSG $nick :\002$contents\002"
			} else { }
		}
		close $input	
	}
	putlog "($hand) $nick !host $text"
	return 0
}

bind dcc - host dcc_dnslookup

proc dcc_dnslookup {hand idx text} {
	global hostpath
	set host [lindex $text 0]
	if {$host == ""} {
		putidx $idx "apa yang harus aku."
		return 0
	} else {
		putidx $idx "Ok, saya akan cari \002$host\002 untukmu. :-)"
		set input [open "|$hostpath $host" r]
		while {![eof $input]} {
			catch {[set contents [gets $input]]}
			if {$contents == "Host tidak ditemukan, silahkan coba lagi."} {
				putidx $idx "maaf sayan mencari \002$host\002, namun tidak menemukan informasi apapun."
				catch {close $input}
				putlog "#$hand# host $text"
				return 0
			} elseif {$contents != ""} {
				putidx $idx "\002$contents\002"
			} else { }
		}
		close $input	
	}
	putlog "#$hand# host $text"
	return 0
}

putlog "HOST 1.1 (ported to eggdrop 1.3.x) by Lemon <yuslemon91@gmail.com> loaded."
