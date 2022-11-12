###############################################################################
#  Name:                                        Timebomb
#  Author:                                      jotham.read@gmail.com
#  Web Site:                                    http://radiosaurus.sporkism.org
#  Eggdrop Version:     1.6.x
#  Description:
#
#  This is a small TCL script for Eggdrop.  Timebomb is a game where one person
#  asks the Eggdrop bot to plant a timebomb in another users pants.  The target
#  user then needs to diffuse the bomb by cutting the correct wire, or be
#  kicked from the channel.
#
#  To start the game a user must type:
#    timebomb <nickname>
#  This will cause the target user to have a timebomb "stuffed in their pants"
#  once this occurs the user will have a number of seconds to diffuse the bomb.
#  Diffusing the bomb is done by typing:
#    cutwire <color>
#  The wire colors you can choose from are displayed when the bomb is planted.
#  This script will not allow bots (Users who are +b), or the bot running the
#  script, to be timebombed.
#
#  I know it sounds very silly but it is a rather fun game.
#
###############################################################################

bind  pub   -   bon  doTimebomb
bind  pub   -   cut   doCutWire

###############################################################################
# Configuration
#

set gTimebombMinimumDuration 20
set gTimebombMaximumDuration 60
set gWireChoices "Red Orange Yellow Green Blue Indigo Violet Black White Grey Brown Pink Mauve Beige Aquamarine Chartreuse Bisque Crimson Fuchsia Gold Ivory Khaki Lavender Lime Magenta Maroon Navy Olive Plum Silver Tan Teal Turquoise"
set gMaxWireCount 3

###############################################################################
# Internal Globals
#

set gTheScriptVersion "0.4"
set gTimebombActive 0
set gTimerId 0
set gTimebombTarget ""
set gTimebombChannel ""
set gCorrectWire ""
set gNumberNames "zero one two three four five six seven eight nine ten eleven twelve"

###############################################################################

proc note {msg} {
  putlog "% $msg"
}

proc IRCKick {theNick theChannel theReason} {
  note "Kicking $theNick in $theChannel (Reason: $theReason)"
  putserv "KICK $theChannel $theNick :$theReason"
}

proc IRCPrivMSG {theTarget messageString} {
  putserv "PRIVMSG $theTarget :$messageString"
}

proc IRCAction {theTarget messageString} {
  putserv "PRIVMSG $theTarget :\001ACTION $messageString\001"
}

proc MakeEnglishList {theList} {
  set theListLength [llength $theList]
  set returnString [lindex $theList 0]
  for {set x 1} {$x < $theListLength} {incr x} {
    if { $x == [expr $theListLength - 1] } {
      set returnString "$returnString and [lindex $theList $x]"
    } else {
      set returnString "$returnString, [lindex $theList $x]"
    }
  }
  return $returnString
}

proc SelectWires {wireCount} {
  global gWireChoices
  set totalWireCount [llength $gWireChoices]
  set selectedWires ""
  for {set x 0} {$x < $wireCount} {incr x} {
    set currentWire [lindex $gWireChoices [expr int( rand() * $totalWireCount )]]
    if { [lsearch $selectedWires $currentWire] == -1 } {
      lappend selectedWires $currentWire
    } else {
      set x [expr $x - 1]
    }
  }
  return $selectedWires
}

proc DetonateTimebomb {destroyTimer kickMessage} {
  global gTimebombTarget gTimerId gTimebombChannel gTimebombActive
  if { $destroyTimer } {
    killutimer $gTimerId
  }
  set gTimerId 0
  set gTimebombActive 0
  IRCKick $gTimebombTarget $gTimebombChannel $kickMessage
}

proc DiffuseTimebomb {wireCut} {
  global gTimerId gTimebombActive gTimebombTarget gTimebombChannel
  killutimer $gTimerId
  set gTimerId 0
  set gTimebombActive 0
  IRCPrivMSG $gTimebombChannel "$gTimebombTarget telah memotong kabel $wireCut.  cie ngana selamat, bom nda jadi meledak!"
}

proc StartTimeBomb {theStarter theNick theChannel} {
  global gTimebombActive gTimebombTarget gTimerId gTimebombChannel gNumberNames gCorrectWire
  global gMaxWireCount gTimebombMinimumDuration gTimebombMaximumDuration
  if { $gTimebombActive == 1 } {
    note "Timebomb not started for $theStarter (Reason: timebomb already active)"
    if { $theChannel != $gTimebombChannel } {
      IRCPrivMSG $theChannel "hmmp bom so nyanda ada. :-("
    } else {
      IRCAction $theChannel "siap pasang bom pa $gTimebombTarget bom paling berbahaya."
    }
  } else {
    set timerDuration [expr $gTimebombMinimumDuration + [expr int(rand() * ($gTimebombMaximumDuration - $gTimebombMinimumDuration))]]
    set gTimebombTarget $theNick
    set gTimebombChannel $theChannel
    set numberOfWires [expr 1 + int(rand() * ( $gMaxWireCount - 0 ))]
    set listOfWires [SelectWires $numberOfWires]
    set gCorrectWire [lindex $listOfWires [expr int( rand() * $numberOfWires )]]
    set wireListAsEnglish [MakeEnglishList $listOfWires]
    set wireCountAsEnglish [lindex $gNumberNames $numberOfWires]
    IRCAction $theChannel "tangka kong buka dpe calana kase maso bom dalam cd pa $gTimebombTarget ngana pe waktu cuma \[\002$timerDuration\002\] seconds."
    if { $numberOfWires == 1 } {
      IRCPrivMSG $theChannel "harus hati-hati, potong tu kabel yang bekeng ngana selamat, cuma ada kabel $wireCountAsEnglish. warna $wireListAsEnglish."
    } else {
      IRCPrivMSG $theChannel "harus hati-hati, potong tu kabel yang bekeng ngana selamat, cuma ada kabel $wireCountAsEnglish. warna $wireListAsEnglish."
    }
    note "Timebomb started by $theStarter (Bomb handed to $theNick it will detonate in $timerDuration seconds)"
    set gTimebombActive 1
    set gTimerId [utimer $timerDuration "DetonateTimebomb 0 {\002*BOOM!*\002}"]
  }
}

###############################################################################
# Eggdrop command binds
#

proc doCutWire {nick uhost hand chan arg} {
  global gTimebombActive gCorrectWire gTimebombTarget
  if { $gTimebombActive == 1 } {
    if { [string tolower $nick] == [string tolower $gTimebombTarget] } {
      if { [llength $arg] == 1 } {
        if { [string tolower $arg] == [string tolower $gCorrectWire] } {
          DiffuseTimebomb $gCorrectWire
        } else {
          DetonateTimebomb 1 "\002snip...*BOOM!*\002"
        }
      }
    }
  }
}

proc doTimebomb {nick uhost hand chan arg} {
  global botnick
  set theNick $nick
  if { [llength $arg] == 1 } {
    set theNick [lindex [split $arg] 0]
  }
  if { [string tolower $theNick] == [string tolower $botnick] } {
    set theNick $nick
    IRCKick $theNick $chan "I will not tollerate this!"
    return
  }
  if { [validuser $theNick] == 1 } {
    if { [matchattr $theNick "+b"] == 1 } {
      set theNick $nick
      IRCKick $theNick $chan "I will not tollerate that!"
      return
    }
  }
  StartTimeBomb $nick $theNick $chan
}

###############################################################################

note "timebomb$gTheScriptVersion: loaded";
note " with $gMaxWireCount wire maximum,"
note " and time range of $gTimebombMinimumDuration to $gTimebombMaximumDuration seconds.";
