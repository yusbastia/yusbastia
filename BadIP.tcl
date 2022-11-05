#########################################################################################
## BadIP.tcl 1.0  (13/03/2021)  		                       		   	  			   ##
##                                                                        		   	   ##
##             	        					Copyright 2008 - 2021 @ WwW.TCLScripts.NET ##
##      	   _   _   _   _   _   _   _   _   _   _   _   _   _   _          	       ##
##      	  / \ / \ / \ / \ / \ / \ / \ / \ / \ / \ / \ / \ / \ / \          	   	   ##
##           ( T | C | L | S | C | R | I | P | T | S | . | N | E | T )       	       ##
##      	  \_/ \_/ \_/ \_/ \_/ \_/ \_/ \_/ \_/ \_/ \_/ \_/ \_/ \_/         	   	   ##
##                                                                        		   	   ##
##                      		 ® BLaCkShaDoW Production ®                            ##
##                                                                         		   	   ##
##                              	 	PRESENTS                                       ##
##		       																		 ® ##
#####################################   BadIP TCL   #####################################
##									   												   ##
##  DESCRIPTION: 							   		  								   ##
##                                                                                     ##
##  Bans onjoin users that have their IP considered as VPN/Proxy/Bad IP. Also can scan ##
## onConnect users (the eggdrop must have IRCOP status) and GLINE their IP. Remember   ##
## to write a valid email on "badip(check_mail)" variable.                             ##
##                                       Script source: http://check.getipintel.net    ##
##       				   		   		   											   ##
##  Tested on Eggdrop v1.9.0 (Debian Linux) Tcl version: 8.6.8             		   	   ##
##									   		   										   ##
#########################################################################################
##								           											   ##
##  INSTALLATION: 						           		   							   ##
##  ++ Edit BadIP.tcl script & place it into your /scripts directory.		  	       ##
##  ++ add "source scripts/BadIP.tcl" to your eggdrop.conf & rehash. 	 	   		   ##
##  ++ Packages required: http                                                         ##
##								           		   								   	   ##
##		For the manual scan to work use: .chanset/.set #chan +badip                	   ##
##      If you want the bot to do onjoin scan use: .chanset/.set #chan +badip_remove   ##
##											   										   ##
#########################################################################################
## Commands:																		   ##
##																					   ##
## !bip <nick>/<host>/<ip> ; manual check                                              ##
## !bip +except <ip/host> [add an exception, will not be scanned]                      ##
## !bip -except <ip/host> [remove an exception]                                        ##
##										   											   ##
#########################################################################################
##											   										   ##
##  		OFFICIAL LINKS:                                                        	   ##
##   		E-mail      : BLaCkShaDoW[at]tclscripts.net                                ##
##  		 Bugs report : http://www.tclscripts.net                               	   ##
##  		 GitHub page : https://github.com/tclscripts/ 			   				   ##
##   		Online help : irc://irc.undernet.org/tcl-help                              ##
##          		       #TCL-HELP / UnderNet        	                          	   ##
##          	 You can ask in english or romanian                       		   	   ##
##					    															   ##
##    	 paypal.me/DanielVoipan = Please consider a donation. Thanks!        	   	   ##
##									  		 										   ##
#########################################################################################
##									  		  										   ##
##         	 You want a customised TCL Script for your eggdrop?          	   		   ##
##    		         Easy-peasy, just tell me what you need!                    	   ##
##  	I can create almost anything in TCL based on your ideas and donations.  	   ##
##   		Email blackshadow@tclscripts.net or info@tclscripts.net with your          ##
##    		request informations and I'll contact you as soon as possible.	   		   ##
##									 		   										   ##
#########################################################################################
##								      		           								   ##
## 		 PERSONAL AND NON-COMMERCIAL USE LIMITATION.                            	   ##
##                                                                        		   	   ##
##  	   This program is provided on an "as is" and "as available" basis,   	   	   ##
##  	   with ABSOLUTELY NO WARRANTY. Use it at your own risk.                  	   ##
##                                                                        		   	   ##
## 	   Use this code for personal and NON-COMMERCIAL purposes ONLY.           	   	   ##
##                                                                        		   	   ##
##  	   Unless otherwise specified, YOU SHALL NOT copy, reproduce, sublicense,      ##
##  	   distribute, disclose, create derivatives, in any way ANY PART OF        	   ##
##  	   THIS CONTENT, nor sell or offer it for sale.                            	   ##
##                                                                         		   	   ##
##  	   You will NOT take and/or use any screenshots of this source code for        ##
##  	   any purpose without the express written consent or knowledge of author.     ##
##                                                                       		   	   ##
## 	   You may NOT alter or remove any trademark, copyright or other notice            ##
##  	   from this source code.                                                      ##
##                                                                         		   	   ##
##       		       Copyright 2008 - 2021 @ WwW.TCLScripts.NET                	   ##
##                                                                         		   	   ##
#########################################################################################

###
#Set here who can use the !bip command
set badip(flags) "mn|-"

###
#Please supply a valid mail (it is required on check)
set badip(check_mail) "PleaseWriteAnValidEmail"

###
#Set here the exceptions filename (located in eggdrop directory)
set badip(file) "badip_excepts.txt"

###
#Please choose verification type for IP's (1 - strict (will catch more ip's) ; 0 - medium)
set badip(level) "1"

###
#Except hostmasks (it will not be scanned)
set badip(except_hostmasks) {
  "*.undernet.org"
}

############################## Channel act #################################
###
#If channel has +badip_remove choose here for what to act ? (0 - VPN/Proxy ; 1 - BadIP ; 2 - all)
set badip(act_for) "2"

###
#BAN METHOD
#Reason
set badip(act_ban_reason) "We dont appreciate VPN/Proxy or badIP's here ! :-) \[Country: %country%\]"

#Time (minutes)
set badip(act_ban_time) "60"

###
#Default ban type
#1 - *!*@$host
#2 - *!$ident@$host
#3 - $user!$ident@$host
#4 - $user!*@*
#5 - *!$ident@*
set badip(act_ban_type) "1"
#
###

############################# OnConnect act ###############################

###
#If you want the bot to check for VPN/Proxy/Bad IP on connect (must be Oper)
#and GLINE as method, set here 1, If not set 0

set badip(act_onconnect) "0"

###
#GLINE DETAILS

# Gline command
set badip(act_gline_cmd) "gline *@%hostname% 60 No VPN/Proxy or badIP on our server. \[Country: %country%\]"
#
###

###########################################################################

###
# CMD FLOOD PROTECTION
#Set the number of minute(s) to ignore flooders, 0 to disable flood protection
###
set badip(ignore_prot) "1"

###
# CMD FLOOD PROTECTION
#Set the number of requests within specifide number of seconds to trigger flood protection.
# By default, 3:10, which allows for upto 3 queries in 10 seconds. 3 or more quries in 10 seconds would cuase
# the forth and later queries to be ignored for the amount of time specifide above.
###
set badip(flood_prot) "3:5"

############################################################################

setudef flag badip
setudef flag badip_remove

package require http

bind join - * badip:join
bind pub $badip(flags) !bip badip:cmd
bind raw - NOTICE badip:onconnect

if {![file exists $badip(file)]} {
    set file [open $badip(file) w]
    close $file
}

###
proc badip:cmd {nick host hand chan arg} {
    global badip
if {![channel get $chan badip]} {
    return
}
     set who [lindex [split $arg] 0]
     set except [lindex [split $arg] 1]
     set flood_protect [badip:flood:prot $chan $host]
if {$flood_protect == "1"} {
    return
}
   
switch $who {
    +except {
if {$except == ""} {
    putserv "NOTICE $nick :-= BadIP =- Please specify a hostname/ip."
    return
}
    set find [badip:except_exists $except]
if {$find > -1} {
    putserv "NOTICE $nick :-= BadIP =- \002$except\002 already exists as exception"
    return
}
    set file [open $badip(file) a]
    puts $file $except
    close $file
    putserv "NOTICE $nick :-= BadIP =- Added \002$except\002 as exception"
    }
    -except {
if {$except == ""} {
    putserv "NOTICE $nick :-= BadIP =- Please specify a hostname/ip."
    return
}
     set find [badip:except_exists $except]
if {$find < 0} {
    putserv "NOTICE $nick :-= BadIP =- \002$except\002 doesn't exist as exception"
    return
}
    badip:except:remove $except
    putserv "NOTICE $nick :-= BadIP =- Removed \002$except\002 from exception list"
    }
    default {
if {$who == ""} {
    putserv "NOTICE $nick :-= BadIP =- Please specify a \002nickname/host/ip\002"
    return
}

if {![regexp {:|\.} $who]} {
  	putserv "USERHOST :$who"
  	set ::badipchan $chan
  	set ::badip_search $who
  	set ::badip_check ""
    set ::badip_from $nick
  	bind RAW - 302 badip:for:nick
  	return
  }
    set hostname [badip:valid_ip $who]
if {$hostname == 0} {
    putserv "PRIVMSG $chan :-= BadIP =- can't get dns for $who."
  return
}
    set status_get [badip:check $hostname]
if {$status_get == 0} {
    putserv "PRIVMSG $chan :-= BadIP =- Could not contact source. Try again later."
    return
}
    set status1 [lindex $status_get 0]
    set status2 [lindex $status_get 1]
    set country [lindex $status_get 2]
    putserv "PRIVMSG $chan :-= BadIP =- \002IP\002: $hostname ; \002VPN/Proxy\002: $status1 ; \002BadIP\002: $status2 ; \002Country\002: $country"
        }
    }
}

###
proc badip:except:remove {host} {
    global badip
    set file [open $badip(file) r]
    set timestamp [clock format [clock seconds] -format {%Y%m%d%H%M%S}]
	set temp "${badip(file)}.$timestamp"
	set tempwrite [open $temp w]
while {[gets $file line] != -1} {
if {[string equal -nocase $host $line]} {
    continue
} else {
    puts $tempwrite $line
    }
}
    close $tempwrite
	close $file
    file rename -force $temp $badip(file)
}

###
proc badip:except_exists {host} {
    global badip
    set found_it -1
    set file [open $badip(file) r]
    set data [read -nonewline $file]
    close $file
    set split_data [split $data "\n"]
foreach line $split_data {
if {[string match -nocase $line $host]} {
    set found_it 0
    break
    }
}
    return $found_it
}

###
proc badip:onconnect {from key text} {
    global badip
if {$badip(act_onconnect) == 0} {return}
if {[regexp {Client connecting: (.*?) \((.*?)\) \[(.*?)\]} $text string a b c]} {
    set ip $c
} elseif {[regexp {CONNECT: Client connecting on port (.*?) \(class main\): (.*?) \((.*?)\)} $text string a b c]} {
    set ip $c
}
if {[info exists ip]} {
    set found_it 0
    set except [badip:except_exists $ip]
if {$except > -1} {return}
    set status_get [badip:check $ip]
if {$status_get == 0} {
    return
}
    set status1 [lindex $status_get 0]
    set status2 [lindex $status_get 1]
    set country [lindex $status_get 2]
switch $badip(act_for) {
    0 {
if {![string equal -nocase "OK" $status1]} {
    set found_it 1
    }
}
    1 {
if {![string equal -nocase "OK" $status2]} {
    set found_it 1
    }       
}
    2 {
if {![string equal -nocase "OK" $status1] || ![string equal -nocase "OK" $status2]} {
    set found_it 1
            }  
        }   
    }
if {$found_it == 1} {
    set replace(%hostname%) $ip
    set replace(%country%) $country
    set gline_cmd [string map [array get replace] $badip(act_gline_cmd)]
    putserv "$gline_cmd"
        }
    }
}

###
proc badip:for:nick { from keyword arguments } {
	global badip
	set ip $::badip_search
	set chan $::badipchan
	set check $::badip_check
    set from $::badip_from
	set hosts [lindex [split $arguments] 1]
	set hostname [lindex [split $hosts "="] 1]
	regsub {^[-+]} $hostname "" mask
	set nickname [lindex [split $hosts "="] 0]
	regsub {^:} $nickname "" nick
if {$nick == ""} {
    putserv "PRIVMSG $chan :-= BadIP =- $ip is not online"
    unbind RAW - 302 badip:for:nick
    unset ::badip_check
    unset ::badipchan
    unset ::badip_search
    unset ::badip_from
	return
}
    set hostname [lindex [split $mask @] 1]
    set except_host [badip:except_mask $hostname]
if {$except_host == 1} {
    putserv "NOTICE $chan :-= BadIP =- $hostname is an excepted mask."
    unbind RAW - 302 badip:for:nick
    unset ::badip_check
    unset ::badipchan
    unset ::badip_search
    unset ::badip_from
    return
}
    set hostname [badip:valid_ip $hostname]
if {$hostname == 0} {
    putserv "NOTICE $from :-= BadIP =- Error: can't get dns for $hostname."
    unbind RAW - 302 badip:for:nick
    unset ::badip_check
    unset ::badipchan
    unset ::badip_search
    unset ::badip_from
    return
}
    set status_get [badip:check $hostname]
if {$status_get == 0} {
    putserv "PRIVMSG $chan :-= BadIP =- Could not contact source. Try again later."
    return
}
    set status1 [lindex $status_get 0]
    set status2 [lindex $status_get 1]
    set country [lindex $status_get 2]
    putserv "PRIVMSG $chan :-= BadIP =- \002Nick\002: $nick ; \002IP\002: $hostname ; \002VPN/Proxy\002: $status1 ; \002BadIP\002: $status2 ; \002Country\002: $country"

    unbind RAW - 302 badip:for:nick
    unset ::badip_check
    unset ::badipchan
    unset ::badip_search
    unset ::badip_from
}

###
proc badip:except_mask {hostname} {
  global badip
    set except_host 0
foreach h $badip(except_hostmasks) {
if {[string match -nocase $h $hostname]} {
    set except_host 1
    break
        }
    }
    return $except_host
}

###
proc badip:check {hostname} {
    global badip
    set check_badip [badip:process $hostname]
if {$check_badip == 0} { return 0}
    set status [lindex $check_badip 0]
    set message [lindex $check_badip 3]
    set result [lindex $check_badip 1]
    set badip_status [lindex $check_badip 2]
    set country [lindex $check_badip 4]
if {$status == "error"} {
    return 0
}
    set status1 "OK"
    set status2 "OK"
if {$result > "0.995" && $badip_status == 1} {
    set status1 "\00304FOUND\003"
    set status2 "\00304FOUND\003"
} elseif {$result == 1} {
    set status1 "\00304FOUND\003"
} elseif {$badip_status == 1} {
    set status2 "\00304FOUND\003"
    }
    return [list $status1 $status2 $country]
}

###
proc badip:join {nick host hand chan} {
    global badip
if {![channel get $chan badip_remove]} {
    return
}
    set shost [lindex [split $host @] 1]
    set except [badip:except_exists $shost]
if {$except > -1} {return}
    set hostname [badip:valid_ip $shost]
if {$hostname == 0} {
  return
}
    set status_get [badip:check $hostname]
if {$status_get == 0} {return 0}
    set status1 [lindex $status_get 0]
    set status2 [lindex $status_get 1]
    set country [lindex $status_get 2]
    set replace(%country%) $country
    set replace(%hostname%) $shost
    set found_it 0
switch $badip(act_for) {
    0 {
if {![string equal -nocase "OK" $status1]} {
    set found_it 1
    }
}
    1 {
if {![string equal -nocase "OK" $status2]} {
    set found_it 1
    }       
}
    2 {
if {![string equal -nocase "OK" $status1] || ![string equal -nocase "OK" $status2]} {
    set found_it 1
            }  
        }   
    }
if {$found_it == 1} {
    set reason [string map [array get replace] $badip(act_ban_reason)]
    set bhostname [badip:host_return $badip(act_ban_type) $nick $host]
    newchanban $chan $bhostname $badip(act_ban_time) $reason
    }
}

###
proc badip:process {ip} {
    global badip
    set status ""
    set message ""
    set country ""
    set result 0
    set badip_status 0
    set data [badip:data $ip]
if {$data == 0} {return 0}
    regexp {"status":"(.*?)"} $data -> status
    regexp {"result":"(.*?)"} $data -> result
    regexp {"BadIP":"(.*?)"} $data -> badip_status
    regexp {"Country":"(.*?)"} $data -> country
    regexp {"message":"(.*?)"} $data -> message
    return [list $status $result $badip_status $message $country]
}

###
proc badip:data {ip} {
    global badip
    set contact [::http::formatQuery contact $badip(check_mail)]
if {$badip(level) == 1} {
    set flags "b"
} else {
    set flags "m"
    }
    set link "http://check.getipintel.net/check.php?ip=${ip}&${contact}&format=json&flags=${flags}&oflags=b,c"
    ::http::config -useragent "lynx"
    set ipq [::http::geturl $link -timeout 10000]
    set status [::http::status $ipq]
if {$status != "ok"} { return 0}
    set data [::http::data $ipq]
    ::http::cleanup $ipq
    return $data
}

###
proc badip:flood:prot {chan host} {
	global badip
	set number [scan $badip(flood_prot) %\[^:\]]
	set timer [scan $badip(flood_prot) %*\[^:\]:%s]
if {[info exists badip(flood:$host:$chan:act)]} {
	return 1
}
foreach tmr [utimers] {
if {[string match "*badip:remove:flood $host $chan*" [join [lindex $tmr 1]]]} {
	killutimer [lindex $tmr 2]
	}
}
if {![info exists badip(flood:$host:$chan)]} {
	set badip(flood:$host:$chan) 0
}
	incr badip(flood:$host:$chan)
	utimer $timer [list badip:remove:flood $host $chan]
if {$badip(flood:$host:$chan) > $number} {
	set badip(flood:$host:$chan:act) 1
	utimer [expr $badip(ignore_prot) * 60] [list badip:expire:flood $host $chan]
	return 1
	} else {
	return 0
	}
}


###
proc badip:remove:flood {host chan} {
	global badip
if {[info exists badip(flood:$host:$chan)]} {
	unset badip(flood:$host:$chan)
	}
}

###
proc badip:expire:flood {host chan} {
	global badip
if {[info exists badip(flood:$host:$chan:act)]} {
	unset badip(flood:$host:$chan:act)
	}
}

###
proc badip:valid_ip {hostname} {
  global badip
  set check_ipv4 [regexp {^[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}$} $hostname]
  set check_ipv6 [regexp {^([0-9A-Fa-f]{0,4}:){2,7}([0-9A-Fa-f]{1,4}$|((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)(\.|$)){4})$} $hostname]
if {$check_ipv4 == "0" && $check_ipv6 == "0"} {
  set dns_hostname [badip:getdns $hostname]
if {[lindex $dns_hostname 0] != ""} {
  set hostname [lindex [lindex $dns_hostname 0] 0]
    } elseif {[lindex $dns_hostname 1] != ""} {
  set hostname [lindex [lindex $dns_hostname 1] 0]
  } else {
    return 0
    }
  }
  return $hostname
}


set badip(projectName) "BadIP.tcl"
set badip(author) "BLaCkShaDoW"
set badip(website) "wWw.TCLScriptS.NeT"
set badip(version) "v1.0"

###
proc badip:getdns {ip} {
	global badip
	set ipv4 ""
	set ipv6 ""
	set gethost [catch {exec host $ip 2>/dev/null} results]
	set res [lrange [split $results] 0 end]
	set inc 0
	set llength [llength $res]
for {set i 0} { $i <= $llength} { incr i } {
	set word [lindex $res $i]
if {[string match -nocase "IPv6" $word]} {
	lappend ipv6 [join [lindex $res [expr $i + 2]]]
	}
if {[string match -nocase "*address*" $word] && ![string match -nocase "IPv6" [lindex $res [expr $i - 1]]]} {
	lappend ipv4 [join [lindex $res [expr $i + 1]]]
	}
}
if {$ipv4 == "" && $ipv6 == ""} {
	return 0
	}
	return [list $ipv4 $ipv6]
}

###
proc badip:host_return {type user host} {
	global badip
	set ident [lindex [split $host "@"] 0]
	set uhost [lindex [split $host @] 1]
	switch $type {
1 {
	return "*!*@$uhost"
}
2 {
	return "*!$ident@$uhost"
}
3 {
	return "$user!$ident@$uhost"
}
4 {
	return "$user!*@*"
}
5 {
	return "*!$ident@*"
		}
	}
}

putlog "\002$badip(projectName) $badip(version)\002 coded by $badip(author) ($badip(website)): Loaded."

##############
##########################################################
##   END                                                 #
##########################################################