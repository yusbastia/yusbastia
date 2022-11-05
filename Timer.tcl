###########################################################################################
## Timer.tcl 1.0  (14/05/2020)  	      Copyright 2008 - 2020 @ WwW.TCLScripts.NET     ##
##                   _   _   _   _   _   _   _   _   _   _   _   _   _   _               ##
##                  / \ / \ / \ / \ / \ / \ / \ / \ / \ / \ / \ / \ / \ / \              ##
##                 ( T | C | L | S | C | R | I | P | T | S | . | N | E | T )             ##
##                  \_/ \_/ \_/ \_/ \_/ \_/ \_/ \_/ \_/ \_/ \_/ \_/ \_/ \_/              ##
##                                                                                       ##
##                               ® BLaCkShaDoW Production ®                    	         ##
##                                                                                       ##
##                                         PRESENTS                                      ##
##									               									   ® ##
########################################  TIMER TCL   #####################################
##									                    ##
##  DESCRIPTION: 							                 												    ##	
##  Allows you to start/stop processes timers or see the list of active ones.            ##
##			                            					 												    ##
##  Tested on Eggdrop v1.8.4 (Debian Linux 3.16.0-4-amd64) Tcl version: 8.6.10           ##
##									                    												     ##
###########################################################################################
##									                 							         ##
##                        .-'`'-.                                                        ##
##                        ,-'`'.   '._     \     ______                                  ##
##                       /    .'  ___ `-._  |    \ .-'`                                  ##
##                      |   .' ,-' __ `'/.`.'  ___\\        OK timer, counts your time   ##
##              ______  \ .' \',-' 12 '-.  '.  `-._ \                like never before.  ##
##              '`-. /   ` / / 11    7 1 `.  `.    '.\                                   ##
##                 //___  . '10     /    2 \  ;                                          ##
##                / _.-'  | |      O      3|  |  ______                                  ##
##               /.'      | |9      \      '  '  '`-. /                                  ##
##                 ______ '  \ 8     \   4/  /      //___                                ##
##                 \ .-'`  '. `'.7  6  5.'  '      / _.-'                                ##
##               ___\\       `. _ `'''` _.'\\-.   /.'                                    ##
##               `-._ \       .//`''--''   (   )tclscripts.net                           ##
##                   '.\     (   )          '-`                                          ##
##                            `-'                                                        ##
##									                 									 ##
###########################################################################################
##									                    ##
##  INSTALLATION: 							                    ##
##									                    ##
##     ++ Edit the Timer.tcl script and place it into your /scripts directory,           ##
##     ++ add "source scripts/Timer.tcl" to your eggdrop config and rehash the bot.      ##
##									                    ##
###########################################################################################
###########################################################################################
##									                                                     ##
##  OFFICIAL LINKS:                                                                      ##
##   E-mail      : BLaCkShaDoW[at]tclscripts.net                                         ##
##   Bugs report : http://www.tclscripts.net                                             ##
##   GitHub page : https://github.com/tclscripts/ 			                             ##
##   Online help : irc://irc.undernet.org/tcl-help                                       ##
##                 #TCL-HELP / UnderNet        	                                         ##
##                 You can ask in english or romanian                                    ##
##									                                                     ##
##     paypal.me/DanielVoipan = Please consider a donation. Thanks!                      ##
##									                                                     ##
###########################################################################################
##									                                                     ##
##              You want a customised TCL Script for your eggdrop?                       ##
##                   Easy-peasy, just tell us what you need!                             ##
##       We can create almost anything in TCL based on your ideas and donations.         ##
##          Email blackshadow@tclscripts.net or info@tclscripts.net with your            ##
##           request informations and we'll contact you as soon as possible.             ##
##									                                                     ##
###########################################################################################
##											                                             ##
##  !tm list - list all active timers.                                                   ##
##											                                             ##
##  !tm start <Xs/Xm/Xh/Xd> <process args> / <command args> - start a new timer.         ##
##											                                             ##
##  !tm kill <PID> - kill a timer based on a PID taken from !tm list	                 ##
##											                                             ##
##  !tm help - shows the help.								                             ##
##											                                             ##
###########################################################################################
##									                                                     ##
##  LICENSE:                                                                             ##
##   This code comes with ABSOLUTELY NO WARRANTY.                                        ##
##                                                                                       ##
##   This program is free software; you can redistribute it and/or modify it under       ##
##   the terms of the GNU General Public License version 3 as published by the           ##
##   Free Software Foundation.          						                         ##
##                                                                                       ##
##   This program is distributed WITHOUT ANY WARRANTY; without even the implied          ##
##   warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.                    ##
##   USE AT YOUR OWN RISK.                                                               ##
##                                                                                       ##
##   See the GNU General Public License for more details.                                ##
##        (http://www.gnu.org/copyleft/library.txt)                                      ##
##                                                                                       ##
##  			          Copyright 2008 - 2020 @ WwW.TCLScripts.NET                     ##
##                                                                                       ##
###########################################################################################

###########################################################################################
##                           CONFIGURATION FOR TIMER.TCL                                 ##
###########################################################################################

###
# Cmdchar trigger
set timer(char) "!"

###
#Set flags that can use !tm command
set timer(flags) "mn|-"

###########################################################################################
###             DO NOT MODIFY HERE UNLESS YOU KNOW WHAT YOU'RE DOING                    ###
###########################################################################################

###
# Bindings
# - using commands
bind pub $timer(flags) $timer(char)tm timer:proc

###
proc timer:time_return {the_time} {
	global timer
	set minutes ""
if {[regexp {^[0-9]} $the_time] && ![regexp {[A-Za-z]} $the_time]} {
	return [list $the_time 0]
}
if {![regexp {^[0-9](.*)[A-Za-z]} $the_time]} {
	return -1
}
regsub -all {[A-Za-z]} $the_time "" number
regsub -all {[0-9]} $the_time "" type	
switch [string tolower $type] {
	d {
	set return_time [list [expr $number * 1440] 0]
	}
	m {
	set return_time [list "$number" 0]
	}
	h {
	set return_time [list [expr $number * 60] 0]
	}
	s {
	set return_time [list "$number" 1]
	}
	default {
	return -1
		}
	}
	return $return_time
}

###
proc timer:proc {nick host hand chan arg} {
	global timer
	set counter 0
	set cmd [lindex [split $arg] 0]
switch [string tolower $cmd] {
	list {
	set counter 0
	putserv "NOTICE $nick :Eggdrop \002TIMERS\002 list:"
foreach tmr [timers] {
	incr counter
	set time [lindex $tmr 0]
	set process [join [lindex $tmr 1]]
	set pid [lindex $tmr 2]
	putserv "NOTICE $nick : \#$counter: \002PID\002: $pid ; \002Time\002: $time minutes ; \002Process\002: $process"
		}
foreach tmr [utimers] {
	incr counter
	set time [lindex $tmr 0]
	set process [join [lindex $tmr 1]]
	set pid [lindex $tmr 2]
	putserv "NOTICE $nick : \#$counter: \002PID\002: $pid ; \002Time\002: $time seconds ; \002Process\002: $process"
	}
if {$counter > 0} {
	putserv "NOTICE $nick :To kill a timer, use !tm kill <pid>"
	} else {
	putserv "NOTICE $nick :No \002TIMERS\002 started yet."
		}
	}
kill {
	set found_pid 0
	set pid [lindex [split $arg] 1]
if {![regexp {timer[0-9]} $pid]} {
	putserv "NOTICE $nick :Error. Use \002!tm del <PID>\002 (PID syntax is: timerXXXX \[XXXX are numbers\])"
	return
}
foreach tmr [timers] {
	set getpid [lindex $tmr 2]
if {[string equal -nocase $getpid $pid]} {
	set found_pid 1
	killtimer $getpid
	break
	}
}
if {$found_pid == 0} {		
foreach tmr [utimers] {
	set getpid [lindex $tmr 2]
if {[string equal -nocase $getpid $pid]} {
	set found_pid 1
	killutimer $getpid
	break
		}
	}
}
if {$found_pid == "1"} {
	putserv "NOTICE $nick :Killed process with PID: \002$pid\002"
			} else {
	putserv "NOTICE $nick :There no such process with PID: \002$pid\002"
		}
	}
start {
	set time [lindex [split $arg] 1]
	set process [lindex [split $arg] 2]
	set arg_timer [join [lrange [split $arg] 2 end]]
	set arg_utimer [join [lrange [split $arg] 3 end]]
	set return_time [timer:time_return $time]
if {$return_time == "-1"} {
	putserv "NOTICE $nick :Error, invalid time specified. Use !tm start <Xs/Xm/Xh/Xd> <process args>/<command args> (X - number)"
	return
}
	set found_timer 0
foreach tm [timers] {
	set read_proc [join [lindex $tm 1]]
if {[string equal -nocase $read_proc $process]} {
	set found_timer 1
	}
}
if {$found_timer == "1"} {
	putserv "NOTICE $nick :Error, there is already a TIMER with that process name running."
	return
}
	set timer_type [lindex $return_time 1]
	set return_time [lindex $return_time 0]
if {$timer_type == 0} {
	set error [catch {set check_timer [timer $return_time $arg_timer]} string]
} else {
	set error [catch {set check_timer [utimer $return_time [list $process $arg_utimer]]} string]
	}
if {$error == "1"} {
	putserv "NOTICE $nick :Error, cannot start timer. Reason: \"$string\""
	return
	}
	putserv "NOTICE $nick :Started timer with PID \002$check_timer\002"
}
help {
	putserv "NOTICE $nick :\002HELP\002: !tm start <Xs/Xm/Xh/Xd> <process args> / <command args>"
	putserv "NOTICE $nick :\002HELP\002: !tm list (list all timers)"
	putserv "NOTICE $nick :\002HELP\002: !tm kill <PID> (kill a timer based on a PID taken from !tm list)"
		}
default {
	putserv "NOTICE $nick :Error, use !tm help for more help"
		}
	}
}

###
# Credits
set timer(projectName) "Timer.tcl"
set timer(author) "BLaCkShaDoW"
set timer(website) "wWw.TCLScriptS.NeT"
set timer(email) "blackshadow\[at\]tclscripts.net"
set timer(version) "v1.0"

putlog "\002$timer(projectName) $timer(version)\002 coded by\002 $timer(author)\002 ($timer(website)): Loaded & initialized.."

#######################
#######################################################################################
###                  *** END OF TCL ***                                             ###
#######################################################################################
