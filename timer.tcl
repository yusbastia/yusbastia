#
# By Alim Akkaya , as ayna on IRCnet
#
#    Hello again a new script, a new sense , heh now ....... in this
# script I ve tryed to make some controling commands on timers for dcc.
# And think it's ok now , You can trace your bot with this script , when 
# and what is she doing !!! Well I wrote this script to trace the script 
# named (limit) and some unstable situations accured on my eggie. Commands 
# that you can use with this script are .timer(to list timers and utimers) 
# .killt(to kill the timer before the related command is executed).
# .chtimer replaces the time left for the timer and .stimer starts a new
# timer with given proc and time.
#
#    You can freely use this script on your bot , just drop me an email at
# akkaya@gandalf.physics.metu.edu.tr , and you can also write for your bug
# reports , and comments. 
#
# TODO
# For the next relase planning to add clonned timer check procedure,
# timer tracking ability , ( warns before the proc executed, before itis
# being triggered, and checks weahter the program has started a new timer
# andif yes it immedietly changes to that timer if no it returns that the
# timer is not alive anymore.. and maybe multiple timer tracking at once)
#
# Please write me if you do any changes on this script or if you add the
# ideas at TODO part, and please do not remove my name from this reading
# part .
#

# You shold not need anything to edit below this line :p

bind dcc m timer do_timer   
bind dcc n killt do_ktimer
bind dcc m thelp do_thelp
bind dcc n chtimer do_chtime
bind dcc n stimer start_timer

set f_o 0
 
proc do_thelp {hand idx arg} {
putdcc $idx "###  ------------------ timer.tcl help ------------------"
putdcc $idx "###  Current commands are :"
putdcc $idx "###    .timer (simply gives timers active at that time)"
putdcc $idx "###    .killt (raw kills timer before the related command"
putdcc $idx "###  is executed ( owner only )"
putdcc $idx "###    .chtimer (replaces the remaining time by given"
putdcc $idx "###  argument, automaticly assumed seconds for utimers "
putdcc $idx "###  minute for timers)"
putdcc $idx "###    .stimer starts a new timer of minues or seconds"
putdcc $idx "###  this command is also for only owners."
putdcc $idx "###    .thelp gives thie help screen."
putdcc $idx "###  By the way you can kill multiple timers by .killt"
putdcc $idx "###  "
putdcc $idx "###  You may get extra help by typing the command if help"
putdcc $idx "###  available, .thelp gives this output."
putdcc $idx "###  ----------------------------------------------------"

}

proc start_timer {hand idx arg} {
putdcc $idx "###"
	if {$arg == "" } {
		putdcc $idx "###   This command is used to add a timered execution."
		putdcc $idx "###   Ex : stimer do_proc 1 m"
		putdcc $idx "###   This line sets a 1 minute timer for the execution of"
		putdcc $idx "###   proc `do_proc'"
		putdcc $idx "###   You don't have to give a valid proc name."
		return 2
		}
	
	if {[lindex $arg 1] == "" } {
		putdcc $idx "###   You should include time of proc"
		putdcc $idx "###   Ex: stimer do_proc 1000 s"
		putdcc $idx "###   timer stats from 1000 second"
		return 3
		}

	if {[lindex $arg 2] == "" } {
		putdcc $idx "###   You shold  give me correct time unit"
		putdcc $idx "###   Ex: stimer do_proc XXX s"
		putdcc $idx "###   `s' for second `m' for minute"
		return 4
		} 

	if {([lindex $arg 2] == "s") || ([lindex $arg 2] =="S") } {
		utimer [lindex $arg 1] [lindex $arg 0]
		putdcc $idx "###   Started a [lindex $arg 1] seconds timer for [lindex $arg 0]"
		return 0
		}

	if {([lindex $arg 2] == "m") || ([lindex $arg 2] == "M") } {
		timer [lindex $arg 1] [lindex $arg 0]
		putdcc $idx "###   Started a [lindex $arg 1] minutes timer for [lindex $arg 0]"
		return 0
		}
putdcc $idx "###   Time unit must be one of s (second) or m (minute)"
return 5
}

proc do_chtime {hand idx arg} {

if {$arg == ""} {
		putdcc $idx "###  Think you need some help.             "
		putdcc $idx "###  This is a command to replace time left"
		putdcc $idx "###  For the exectution of related command."
		putdcc $idx "###  Ex: chtimer timer100 5                 "
		putdcc $idx "###  If timer100 is `timer' then 5 is 5 min"
		putdcc $idx "###  if it's `utimer' it's 5 seconds       "
		return 1
}

if {[lindex $arg 1] == ""} {
		putdcc $idx "###  I do also need the time to replace"
		putdcc $idx "###  or should I guess ? "
		putdcc $idx "###  Ex: chtimer [lindex $arg 0] 5"

  foreach j [timers] {if {[lindex $j 2] == $arg } {return 0} }
  foreach j [utimers] {if {[lindex $j 2] == $arg } {return 0} }
 		putdcc $idx "###  By the way [lindex $arg 0] is not a walid timer"
       
		return 2
}

	

foreach j [timers] {
		if {[lindex $j 2] == [lindex $arg 0] } {
		set t1 ""
		set t1 [lindex $j 1]
		killtimer [lindex $j 2]
		putdcc $idx "###  Killed old timer [lindex $j 2] for $t1"
		timer [lindex $arg 1] $t1
		putdcc $idx "###  Started new timer with [lindex $arg 1] min for $t1."
		} 
	}
foreach j [utimers] {
		if {[lindex $j 2] == [lindex $arg 0] } {
		set t1 ""
		set t1 [lindex $j 1]
		killutimer [lindex $j 2]
		putdcc $idx "###  Killed old timer [lindex $j 2] for $t1"
		utimer [lindex $arg 1] $t1
		putdcc $idx "###  Started new timer with [lindex $arg 1] sec for $t1."
		} 
	}



#=========================================================================
}

proc do_timer {hand idx arg} {
putdcc $idx "###  -=-=-=-=-=- Current  Timers -=-=-=-=-=-"
   foreach j [timers] {
	putdcc $idx "###  $j"
      }
putdcc $idx "###  -=-=-=-=-=- Current Utimers -=-=-=-=-=-"
   foreach j [utimers] {
	putdcc $idx "###  $j"
      }

putdcc $idx "###  -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-"
putdcc $idx ""
}


proc do_ktimer {hand idx arg} {

	global f_o	

set f_o 0

if {$arg == "" } { 
		putdcc $idx "###  Oooops no argument given."
		putdcc $idx "###           You should give me the timer name .."
		putdcc $idx "###           Have a look at the timers by typing (.timer)"
		putdcc $idx "###           Ex: killt timer100 "
		putdcc $idx "###  PS: Remember that killing a timer is an action with no return."
		putdcc $idx "###  There is no startup option for this script."
		return 2
		}
#=========>
   foreach j [timers] {
	if {[lindex $j 2] == $arg } { 
				    killtimer [lindex $j 2]
				    putdcc $idx "###    Killed timer [lindex $j 2]"
				    incr f_o
				    }
	if {[lindex $j 1] == $arg } {
				    killtimer [lindex $j 2]
				    putdcc $idx "###    Killed timer [lindex $j 2]"
				    incr f_o
				    }
	if {[lindex $j 0] == $arg } {
				    killtimer [lindex $j 2]
				    putdcc $idx "###    Killed timer [lindex $j 2]"
				    incr f_o
				    }					
      }
#--------->
   foreach j [utimers] {
        if {[lindex $j 2] == $arg } {
                                    killutimer [lindex $j 2]
                                    putdcc $idx "###    Killed utimer [lindex $j 2]"
				    incr f_o
                                    }

        if {[lindex $j 2] == $arg } {
                                    killutimer [lindex $j 2]
                                    putdcc $idx "###    Killed utimer [lindex $j 2]"
				    incr f_o
                                    }

        if {[lindex $j 2] == $arg } {
                                    killutimer [lindex $j 2]
                                    putdcc $idx "###    Killed utimer [lindex $j 2]"
				    incr f_o
                                    }

	}
#==========>


if {$f_o == 0} {
		putdcc $idx "###    No matching timers found with `$arg'"
		putdcc $idx "###    Try .timers"
		return 1
		}

if {$f_o != 0} {
	putdcc $idx "###"
	putdcc $idx "###    Completed timer destruction ..."
	}	   
	return 0
      

}

putlog "### Timer tools by messanger of the lost valley loaded -=ayna=-"

