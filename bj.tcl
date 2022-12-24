#  _     _                 _ _     _
# | |   | |               | | |   (_)
# | |__ | | ___   ___   __| | |    _ _ __   ___ _ __
# | '_ \| |/ _ \ / _ \ / _` | |   | | '_ \ / _ \ '__|
# | |_) | | (_) | (_) | (_| | |___| | | | |  __/ |
# |_.__/|_|\___/ \___/ \__,_\_____/_|_| |_|\___|_|
#
# Blackjack Script by bloodLiner
#
#
#
# # author: bloodLiner
# # version: 1.1
# # web: http://www.bloodliner.de
# # irc: #bloodLiner @ QuakeNet
# # contact: me@bloodliner.de
#
# # Installation:
#	Lade das Script in den scripts Ordner vom Eggdrop hoch
#	und schreibe 'source scripts/blackjack.tcl' in die eggdrop.conf
#
# # Changelog:
#
#	# 11.12.2006 - v1.0: Public Release!
#	# 12.12.2006 - v1.1: Bug gefixt, der am Ende des Spiels auftrat, durch eine fehlende Variable ;)
#
# # Benutzung:
#	?blackjack 			- Spiel starten
#	?blackjack on 		- Blackjack im Channel ansschalten
#	?blackjack off		- Blackjack im Channel ausschalten
#	?blackjack stats	- Blackjack Statistik über den Channel aufrufen
#	?blackjack version	- Zeigt die Blackjack Script Version
#	?join 				- Spiel beitreten
#	?karte 				- Karte geben lassen
#	?genug				- Aufhören
#	?stop				- Für Bot Owner, falls das Spiel mal hängt mit ?stop im Channel beenden
#
#
# # Copyright
#
# Copyright (C) 2006  Michael 'bloodLiner' Gecht
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
#
#
# # Konfiguration:
#
# Spiel trigger einstellen. Standard wäre ?blackjack
set ::blackjack(trigger) "\?"

# Spielsperre einstellen. 300 = 5 Minuten Pause zwischen jedem Spiel.
set ::blackjack(flood) "300"

#
# # ÄNDERE AB HIER NICHTS MEHR, AUßER DU BIST DIR SICHER WAS DU MACHST!

set bj(author) 		"bloodLiner"
set bj(web) 		"http://www.bloodliner.de"
set bj(name) 		"Blackjack Script"
set bj(version) 	"v1.1"

setudef 	flag 	blackjack
setudef 	str  	blackjackc

bind pub 	* 	$::blackjack(trigger)blackjack 	game:blackjack
bind pub 	* 	$::blackjack(trigger)join 		blackjack:join
bind pub 	* 	$::blackjack(trigger)karte 		blackjack:karte
bind pub 	* 	$::blackjack(trigger)genug	 	blackjack:genug
bind pub 	n 	$::blackjack(trigger)stop 		blackjack:stop

# sendmsg proc by ircscript.de - R.I.P. #ircscript
proc sendmsg {target command message} {
	if {![string match "#*" $target]} {
		putquick "notice $target :\002« $command » «\002 $message \002»\002"
	} else {
		if {[string match "*c*" [getchanmode $target]]} {
			putquick "privmsg $target :« $command » « $message »"
		} else {
			putquick "privmsg $target :\002« $command » «\002 $message \002»\002"
		}
	}
}

# string2pattern proc by CyBex - tclhelp.net
proc str2pat {string} {
	return [string map [list \\ \\\\ \[ \\\[ \] \\\] ] $string]
}

proc game:blackjack {nick host hand chan arg} {
	switch -exact -- [string tolower [lindex [split $arg] 0]] {
		"on" {
			if {![matchattr $hand n|n $chan]} {
				return 0
			}
			if {[channel get $chan "blackjack"]} {
				putserv "notice $nick :Blackjack ist schon in $chan eingeschaltet."
				return 0
			} elseif {![channel get $chan "blackjack"]} {
				channel set $chan +blackjack
				putserv "notice $nick :Blackjack wurde erfolgreich in $chan eingeschaltet."
			}
		}
		"off" {
			if {![matchattr $hand n|n $chan]} {
				return 0
			}
			if {![channel get $chan "blackjack"]} {
				putserv "notice $nick :Blackjack ist schon in $chan ausgeschaltet."
				return 0
			} elseif {[channel get $chan "blackjack"]} {
				channel set $chan -blackjack
				putserv "notice $nick :Blackjack wurde erfolgreich in $chan ausgeschaltet."
			}
		}
		"stats" {
			if {[info exists ::blackjack(flood,count,$chan)] && [expr {[unixtime] - $::blackjack(flood,count,$chan)}] < 300} {
			return 0
			} else {
				if {[channel get $chan "blackjackc"] == ""} {
					sendmsg $chan Blackjack "Ich habe in $chan noch kein einziges Spiel gesehen!"
				} elseif {[channel get $chan "blackjackc"] == "1"} {
					sendmsg $chan Blackjack "Ich habe in $chan erst ein einziges Spiel gesehen!"
				} else {
					sendmsg $chan Blackjack "Ich habe in $chan bisher [channel get $chan "blackjackc"] Spiele gesehen!"
				}
				set ::blackjack(flood,count,$chan) [unixtime]
				utimer 300 [list unset ::blackjack(flood,count,$chan)]
			}
		}
		"version" {
			global bj
			if {[info exists ::blackjack(flood,version,$chan)] && [expr {[unixtime] - $::blackjack(flood,version,$chan)}] < 300} {
			return 0
			} else {
				sendmsg $chan Blackjack "Ich benutze das $bj(name) $bj(version) von $bj(author) - $bj(web)"
				set ::blackjack(flood,version,$chan) [unixtime]
				utimer 300 [list unset ::blackjack(flood,version,$chan)]
			}
		}
		"" {
			if {![channel get $chan "blackjack"]} {
				return 0
			} elseif {[info exists ::blackjack(flood,$chan)] && [expr {[unixtime] - $::blackjack(flood,$chan)}] < $::blackjack(flood)} {
				return 0
			} else {
				if {[info exists ::blackjack(request,$chan)] == "1" || [info exists ::blackjack(started,$chan)] == "1"} {
					puthelp "notice $nick :In $chan ist schon ein Blackjack Spiel gestartet worden!"
					return 0
				} else {
					set ::blackjack(request,$chan) "1"
				}
			}
			if {$::blackjack(request,$chan) == "1"} {
				set ::blackjack(player,$chan) "[str2pat $nick]"
				set ::blackjack(active,$chan) "0"
				sendmsg $chan Blackjack "Das Spiel beginnt in 30 Sekunden! Schreibe $::blackjack(trigger)join um dem Spiel beizutreten!"
				utimer 30 [list blackjack:expire $chan]
				return
			}
		}
	}
}

proc blackjack:join {nick host hand chan arg} {
	if {![channel get $chan "blackjack"]} {
		return 0
	} elseif {[info exists ::blackjack(request,$chan)] == "0"} {
		return 0
	} elseif {[llength $::blackjack(player,$chan)] == 5} {
		puthelp "notice $nick :Das Blackjack Spiel in $chan ist schon voll!"
		return 0
	}
	if {[lsearch $::blackjack(player,$chan) [str2pat $nick]] == "-1"} {
		lappend ::blackjack(player,$chan) $nick
		puthelp "notice $nick :Du bist dem Blackjack Spiel in $chan beigetreten!"
	} else {
		puthelp "notice $nick :Du bist dem Blackjack Spiel in $chan schon längst beigetreten!"
	}
}

proc blackjack:expire {chan} {
	if {[llength $::blackjack(player,$chan)] < 2} {
		sendmsg $chan Blackjack "Die 30 Sekunden sind um und es hat sich niemand gemeldet. Ich geh weiter Karten mischen!"
		unset ::blackjack(player,$chan)
		unset ::blackjack(request,$chan)
	} else {
		unset ::blackjack(request,$chan)
		set ::blackjack(started,$chan) "1"
		foreach player $::blackjack(player,$chan) {
			set ::blackjack(gesamt,wert,$chan,[getchanhost $player]) "0"
			set ::blackjack(gesamt,karten,$chan,[getchanhost $player]) ""
		}
		set ::blackjack(stapel,Kreuz,$chan) "Ass 2 3 4 5 6 7 8 9 10 Bube Dame König"
		set ::blackjack(stapel,Pik,$chan) "Ass 2 3 4 5 6 7 8 9 10 Bube Dame König"
		set ::blackjack(stapel,Herz,$chan) "Ass 2 3 4 5 6 7 8 9 10 Bube Dame König"
		set ::blackjack(stapel,Karo,$chan) "Ass 2 3 4 5 6 7 8 9 10 Bube Dame König"
		set ::blackjack(stapel,alle,$chan) "Kreuz Pik Herz Karo"
		sendmsg $chan Blackjack "Das Spiel beginnt. Die Spieler sind [join $::blackjack(player,$chan) ", "]. Mit ?karte lässt du dir eine Karte geben. Mit ?genug hörst du auf. [lindex $::blackjack(player,$chan) 0] fängt an!"
		set ::blackjack(idletimer,$chan) [utimer 60 [list blackjack:idle [lindex $::blackjack(player,$chan) $::blackjack(active,$chan)] $chan]]
	}
}

proc blackjack:karte {nick host hand chan arg} {
	if {![channel get $chan "blackjack"]} {
		return 0
	} elseif {![info exists ::blackjack(started,$chan)]} {
		return 0
	} elseif {$nick != [lindex $::blackjack(player,$chan) $::blackjack(active,$chan)]} {
		return 0
	}

	if {[info exists ::blackjack(idletimer,$chan)]} {
		killutimer $::blackjack(idletimer,$chan)
		unset ::blackjack(idletimer,$chan)
	}

	foreach stapel $::blackjack(stapel,alle,$chan) {
		if {[llength $::blackjack(stapel,$stapel,$chan)] < 1} {
			set ::blackjack(stapel,alle,$chan) "[lrange $::blackjack(stapel,alle,$chan) 0 [expr {[lsearch -exact $::blackjack(stapel,alle,$chan) $stapel] - 1}]] [lrange $::blackjack(stapel,alle,$chan) [expr {[lsearch -exact $::blackjack(stapel,alle,$chan) $stapel] + 1}] end]"
			set ::blackjack(stapel,$chan) "[rand [llength $::blackjack(stapel,alle,$chan)]]"
			set ::blackjack(stapelw,$chan) "[lindex $::blackjack(stapel,alle,$chan) $::blackjack(stapel,$chan)]"
			set ::blackjack(karte,$chan) "[rand [llength $::blackjack(stapel,$::blackjack(stapelw,$chan),$chan)]]"
			set ::blackjack(wert,$chan) "[lindex $::blackjack(stapel,[lindex $::blackjack(stapel,alle,$chan) $::blackjack(stapel,$chan)],$chan) $::blackjack(karte,$chan)]"
		} else {
			set ::blackjack(stapel,$chan) "[rand [llength $::blackjack(stapel,alle,$chan)]]"
			set ::blackjack(stapelw,$chan) "[lindex $::blackjack(stapel,alle,$chan) $::blackjack(stapel,$chan)]"
			set ::blackjack(karte,$chan) "[rand [llength $::blackjack(stapel,$::blackjack(stapelw,$chan),$chan)]]"
			set ::blackjack(wert,$chan) "[lindex $::blackjack(stapel,[lindex $::blackjack(stapel,alle,$chan) $::blackjack(stapel,$chan)],$chan) $::blackjack(karte,$chan)]"
		}
	}
	if {$::blackjack(stapelw,$chan) == "Kreuz" || $::blackjack(stapelw,$chan) == "Pik"} {
		set blackjack(farbe,$chan) "\0031,0"
	} elseif {$::blackjack(stapelw,$chan) == "Herz" || $::blackjack(stapelw,$chan) == "Karo"} {
		set blackjack(farbe,$chan) "\0030,2"
	}

	if {$::blackjack(gesamt,wert,$chan,$host) == 21 || $::blackjack(gesamt,wert,$chan,$host) > 21} {
		puthelp "notice $nick :Du hast schon $::blackjack(gesamt,wert,$chan,$host) Punkte! Gib nun ?genug ein."
		return 0
	} elseif {$::blackjack(wert,$chan) == "Bube" || $::blackjack(wert,$chan) == "Dame" ||  $::blackjack(wert,$chan) == "König"} {
		set ::blackjack(gesamt,wert,$chan,$host) "[expr {$::blackjack(gesamt,wert,$chan,$host) + 10}]"
	} elseif {$::blackjack(wert,$chan) == "Ass"} {
		if {[expr {$::blackjack(gesamt,wert,$chan,$host) + 11}] > 21} {
			set ::blackjack(gesamt,wert,$chan,$host) "[expr {$::blackjack(gesamt,wert,$chan,$host) + 1}]"
		} else {
			set ::blackjack(gesamt,wert,$chan,$host) "[expr {$::blackjack(gesamt,wert,$chan,$host) + 11}]"
		}
	} else {
		set ::blackjack(gesamt,wert,$chan,$host) "[expr {$::blackjack(gesamt,wert,$chan,$host) + $::blackjack(wert,$chan)}]"
	}

	set ::blackjack(gesamt,karten,$chan,$host) " $::blackjack(gesamt,karten,$chan,$host) $blackjack(farbe,$chan)$::blackjack(stapelw,$chan) $::blackjack(wert,$chan)\003"

	putquick "notice $nick :Deine Karten:$::blackjack(gesamt,karten,$chan,$host) - Gesamt Wert: $::blackjack(gesamt,wert,$chan,$host)"
	set ::blackjack(stapel,[lindex $::blackjack(stapel,alle,$chan) $::blackjack(stapel,$chan)],$chan) "[lrange $::blackjack(stapel,[lindex $::blackjack(stapel,alle,$chan) $::blackjack(stapel,$chan)],$chan) 0 [expr {$::blackjack(karte,$chan)-1}]] [lrange $::blackjack(stapel,[lindex $::blackjack(stapel,alle,$chan) $::blackjack(stapel,$chan)],$chan) [expr {$::blackjack(karte,$chan)+1}] end]"
}

proc blackjack:idle {nick chan} {
	sendmsg $chan Blackjack "$nick ist eingeschlafen... Wieso zum Teufel mach ich das hier eigentlich!?"
	unset ::blackjack(idletimer,$chan)
	blackjack:genug $nick [getchanhost $nick] [nick2hand $nick] $chan keyed
}

proc blackjack:kick {nick chan} {
	set ::player(kick,$chan) "$::blackjack(player,$chan)"
	set ::blackjack(player,$chan) ""
	foreach players $::player(kick,$chan) {
		if {$players != $nick} {
			lappend ::blackjack(player,$chan) "$players"
		} else {
			continue;
		}
	}
	unset ::player(kick,$chan)
}

proc blackjack:genug {nick host hand chan arg} {
	if {![channel get $chan "blackjack"]} {
		return 0
	} elseif {![info exists ::blackjack(started,$chan)]} {
		return 0
	}
	if {$nick != [lindex $::blackjack(player,$chan) $::blackjack(active,$chan)]} {
		return 0
	}
	if {$::blackjack(gesamt,wert,$chan,$host) == 0 && [llength $::blackjack(gesamt,karten,$chan,$host)] == 0 && $arg != "keyed"} {
		puthelp "notice $nick :Du musst dir mindestens einmal eine Karte geben lassen, bevor du ?genug machen kannst"
		return 0
	} elseif {$::blackjack(gesamt,wert,$chan,[getchanhost [lindex $::blackjack(player,$chan) $::blackjack(active,$chan)]]) > 21 || $::blackjack(gesamt,wert,$chan,[getchanhost [lindex $::blackjack(player,$chan) $::blackjack(active,$chan)]]) == "0" && $arg == "keyed"} {
		blackjack:kick [lindex $::blackjack(player,$chan) $::blackjack(active,$chan)] $chan
	} else {
		incr ::blackjack(active,$chan)
	}
	if {[expr {[llength $::blackjack(player,$chan)]-1}] < $::blackjack(active,$chan)} {
		if {[llength $::blackjack(player,$chan)] < 1} {
			sendmsg $chan Blackjack "Unentschieden! Alle Spieler sind ausgeschieden!"
		} else {
			set ::blackjack(winner,$chan,check) "$::blackjack(gesamt,wert,$chan,[getchanhost [lindex $::blackjack(player,$chan) 0]])"
			set ::blackjack(winner,$chan) "[lindex $::blackjack(player,$chan) 0]"
			set ::blackjack(winner,$chan,zahl) "1"
			foreach player $::blackjack(player,$chan) {
				if {$::blackjack(winner,$chan) == $player} {
					continue;
				} elseif {$::blackjack(gesamt,wert,$chan,[getchanhost $player]) > 21} {
					continue;
				} elseif {$::blackjack(gesamt,wert,$chan,[getchanhost $player]) > $::blackjack(winner,$chan,check)} {
					set ::blackjack(winner,$chan) "$player"
					set ::blackjack(winner,$chan,check) "$::blackjack(gesamt,wert,$chan,[getchanhost $player])"
					continue;
				} elseif {$::blackjack(gesamt,wert,$chan,[getchanhost $player]) == $::blackjack(winner,$chan,check)} {
					lappend ::blackjack(winner,$chan) "$player"
					continue;
				}
			}
			if {[llength $::blackjack(winner,$chan)] > 1} {
				set ::blackjack(player,$chan) "$::blackjack(winner,$chan)"
				foreach player $::blackjack(player,$chan) {
					set ::blackjack(gesamt,wert,$chan,[getchanhost $player $chan]) "0"
					set ::blackjack(gesamt,karten,$chan,[getchanhost $player $chan]) ""
				}
				set ::blackjack(stapel,Kreuz,$chan) "Ass 2 3 4 5 6 7 8 9 10 Bube Dame König"
				set ::blackjack(stapel,Pik,$chan) "Ass 2 3 4 5 6 7 8 9 10 Bube Dame König"
				set ::blackjack(stapel,Herz,$chan) "Ass 2 3 4 5 6 7 8 9 10 Bube Dame König"
				set ::blackjack(stapel,Karo,$chan) "Ass 2 3 4 5 6 7 8 9 10 Bube Dame König"
				set ::blackjack(stapel,alle,$chan) "Kreuz Pik Herz Karo"
				set ::blackjack(active,$chan) "0"
				sendmsg $chan Blackjack "Die Spieler [join $::blackjack(player,$chan) ", "] haben mit $::blackjack(winner,$chan,check) die gleiche Punktzahl, deswegen gibt es nun ein Stechen! [lindex $::blackjack(player,$chan) 0] fängt an."
				set ::blackjack(idletimer,$chan) [utimer 60 [list blackjack:idle [lindex $::blackjack(player,$chan) 0] $chan]]
				return 0
			} else {
				sendmsg $chan Blackjack "Der Gewinner ist $::blackjack(winner,$chan) mit $::blackjack(gesamt,wert,$chan,[getchanhost $::blackjack(winner,$chan) $chan]) Punkten!"
			}
			unset ::blackjack(winner,$chan)
			unset ::blackjack(winner,$chan,zahl)
			unset ::blackjack(winner,$chan,check)
		}
		if {[channel get $chan "blackjackc"] == ""} {
			set bjcount "0"
		} else {
		set bjcount "[channel get $chan blackjackc]"
		}
		incr bjcount
		channel set $chan blackjackc "$bjcount"
		set ::blackjack(flood,$chan) [unixtime]
		utimer 300 [list unset ::blackjack(flood,$chan)]
		foreach player $::blackjack(player,$chan) {
			unset ::blackjack(gesamt,wert,$chan,[getchanhost $player $chan])
		}
		unset ::blackjack(player,$chan)
		unset ::blackjack(started,$chan)
		unset ::blackjack(stapel,Kreuz,$chan)
		unset ::blackjack(stapel,Pik,$chan)
		unset ::blackjack(stapel,Herz,$chan)
		unset ::blackjack(stapel,Karo,$chan)
		unset ::blackjack(stapel,alle,$chan)
		unset ::blackjack(stapel,$chan)
		unset ::blackjack(stapelw,$chan)
		unset ::blackjack(karte,$chan)
		unset ::blackjack(wert,$chan)
		return 0
	} else {
		sendmsg $chan Blackjack "Ok, [lindex $::blackjack(player,$chan) $::blackjack(active,$chan)] du bist an der Reihe!"
		set ::blackjack(idletimer,$chan) [utimer 60 [list blackjack:idle [lindex $::blackjack(player,$chan) $::blackjack(active,$chan)] $chan]]
	}
}

proc blackjack:stop {nick host hand chan arg} {
	if {[info exists ::blackjack(request,$chan)]} {
		unset ::blackjack(request,$chan)
		putquick "notice $nick :Done! Die Variable \$::blackjack(request,$chan) ist in $chan resettet!"
	}
	if {[info exists ::blackjack(started,$chan)]} {
		unset ::blackjack(started,$chan)
		putquick "notice $nick :Done! Die Variable \$::blackjack(started,$chan) ist in $chan resettet!"
	}
}

putlog "$bj(name) $bj(version) von $bj(author) - $bj(web) erfolgreich geladen!"

#EOF
