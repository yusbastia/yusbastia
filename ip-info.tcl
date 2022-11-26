
Ip Check for Eggdrop
 By FordLawnmower on Jun 20, 2011
 9   3954   22
This script grabs some ip information from www.melissadata.com and returns it to irc.
Default trigger is: !ipinfo
Syntax: !ipinfo 1.2.3.4
Chanset: +ipinfo
ScreenShot: Image

##############################################################################################
##  ## Ipinfo.tcl for eggdrop by Ford_Lawnmower irc.geekshed.net #Script-Help    ##  ##
##############################################################################################
##   To use this script you must set channel flag +ipinfo (ie .chanset #chan +ipinfo)     ##
##############################################################################################
##############################################################################################
##  ##                             Start Setup.                                         ##  ##
##############################################################################################
## Change the character between the "" below to change the command character/trigger.       ##
set Ipinfocmdchar "!"
proc Ipinfo {nick host hand chan search} {
  if {[lsearch -exact [channel info $chan] +ipinfo] != -1} {
## Change the format codes between the "" below to change the color/state of the text.      ##
    set titlef "\0034"
    set textf "\003\002"
##  Change ipinforesults to the order and results you want posted to the channel.           ##
    set ipinforesults "ip host country city state area postal isp"
##############################################################################################
##  ##                           End Setup.                                              ## ##
##############################################################################################
    set country ""
    set city ""
    set state ""
    set area ""
    set postal ""
    set isp ""
    set host ""
    set ip ""
    set Ipinfosite "whatismyipaddress.com"
    if {$search == ""} { 
    putserv "PRIVMSG $chan :${textf}You must provide an ip address to check!"
    } else {
      set Ipinfourl "/ip/${search}"
      if {[catch {set Ipinfosock [socket -async $Ipinfosite 80]} sockerr]} {
        putlog "$Ipinfosite $Ipinfourl $sockerr error"
        return 0
      } else {
        puts $Ipinfosock "GET $Ipinfourl HTTP/1.0"
        puts $Ipinfosock "Host: $Ipinfosite"
        puts $Ipinfosock "User-Agent: Opera 9.6"
        puts $Ipinfosock ""
        flush $Ipinfosock
        while {![eof $Ipinfosock]} {
          set Ipinfovar " [gets $Ipinfosock] "
          putlog $Ipinfovar
       if {[regexp {<div align='center' class='Lookupserror'>([^<]*)<b>([^<]*)<\/b>([^<]*)<br>([^<]*)<\/div>} $Ipinfovar]} {
         putserv "PRIVMSG $chan : ${titlef}Syntax error: ${textf}Ip must be in the form of 1.2.3.4"
         close $Ipinfosock
            return 0
       } elseif {[regexp -nocase {ISP\:<[^<]*><[^<]*>([^<]*)<} $Ipinfovar match isp]} {
         set isp "${titlef}ISP:\017${textf}[ipinforecode $isp]"
            if {[regexp -nocase {Hostname\:<[^<]*><[^<]*>([^<]*)<} $Ipinfovar match host]} {
              set host "${titlef}Host:\017${textf}[ipinforecode $host]"
            }
            if {[regexp -nocase {IP\:<[^<]*><[^<]*>([^<]*)<} $Ipinfovar match ip]} {
              set ip "${titlef}IP:\017${textf}[ipinforecode $ip]"
            }
          } elseif {[regexp -nocase {Country\:<[^<]*><[^<]*>([^<]*)<} $Ipinfovar match country]} {
         set country "${titlef}Country:\017${textf}[ipinforecode $country]"
          } elseif {[regexp -nocase {State\/Region\:<[^<]*><[^<]*>([^<]*)<} $Ipinfovar match state]} {
         set state "${titlef}State:\017${textf}[ipinforecode $state]"
          } elseif {[regexp -nocase {City\:<[^<]*><[^<]*>([^<]*)<} $Ipinfovar match city]} {
         set city "${titlef}City:\017${textf}[ipinforecode $city]"
          } elseif {[regexp -nocase {Area\sCode\:<[^<]*><[^<]*>([^<]*)<} $Ipinfovar match area]} {
         set area "${titlef}Area Code:\017${textf}[ipinforecode $area]"
          } elseif {[regexp -nocase {Postal\sCode\:<[^<]*><[^<]*>([^<]*)<} $Ipinfovar match postal]} {
         set postal "${titlef}Postal Code:\017${textf}[ipinforecode $postal]"
          } elseif {[regexp -nocase {<\/body>} $Ipinfovar]} {
            putserv "PRIVMSG $chan : [subst [regsub -all -nocase {(\S+)} $ipinforesults {$\1}]]"
       }
        }
        close $Ipinfosock
        return 0 
      }
    }
  }
}
proc ipinforecode { textin } {
  return [subst [regsub -nocase -all {&#([0-9]{1,5});} $textin {\u\1}]]
}
bind pub - ${Ipinfocmdchar}ipinfo Ipinfo
setudef flag ipinfo
putlog "Ipinfo Script v 1.3 by Ford_Lawnmower successfully loaded! irc.geekshed.net #Script-Help"
