#         Script : Sex Story v1.0 by vian
#                  Copyright 2009
# Many thanks to you who use this TCL if you dont edit my copyright!

bind pub * !story join:story 
proc join:story {nick uhost hand chan rest} { 
  global story_timers 
  set story "sex.txt" 
  if {![info exists story_timers($story)]} { 
    slowmsg $story 
    } else { 
    puthelp "privmsg $nick :already reading..." 
  } 
} 
proc slowmsg {file {pos 0}} { 
  global story_timers 
  set f [open $file] 
  seek $f $pos 
  if {[gets $f line]>-1} { 
    putserv "privmsg #tapaaog :$line" 
    set story_timers($file) [utimer 11 [list slowmsg $file [tell $f]]] 
    } else { 
    utimer 15 [list putserv "Re-reading the story:"] 
    set story_timers($file) [utimer 16 [list slowmsg $file]] 
  } 
  close $f 
}


putlog "vian story.tcl loaded"
