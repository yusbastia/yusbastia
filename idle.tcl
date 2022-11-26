

# Nov 29, 2012

# reference:  http://forum.egghelp.org/viewtopic.php?t=19178


# Hero
#   
# New postPosted: Today at 1:13 pm    Post subject: Need Idle Check TCL    Reply with quote
# Hello I Wanna Request Idle Check Tcl
# Like:
# <+Hero> !Idle Hero
# <&Bot> Hero Idle Time Is: 5hrs 20mins 36secs
# Thanks In Advance




###################### Method - have bot do /whois on user, and get the idle time from return.  Should give resolution in seconds, as requested ########


bind pub - ".idle" get_idle_time_whois

proc get_idle_time_whois {nick uhost handle chan text} {
global working_chan

   if {[lindex [split $text] 0] == ""} {
      putserv "privmsg $chan :Syntax: !idle <nick>"
      return 0
         }

   set user [lindex [split $text] 0]

   if {![onchan $user $chan]} {
      putserv "privmsg $chan :Sorry, $user is not on $chan"
      return 0
         }
   
   set working_chan $chan

   bind raw - 317 got_whois

   putserv "whois $user $user"


}


proc got_whois {from keyword text} {
global working_chan
   
   putserv "privmsg $working_chan :[lindex [split $text] 1] idle time is: [duration [lindex [split $text] 2]]"   


   utimer 5 [list unbind raw - 317 got_whois]
 
}
