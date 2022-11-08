#tcl.pinglag
#this script pings returns the lag time of a user
#written for eggdrop 1.0 and up.. tested on eggdrop 1.0f
#written by Lorna MacTavish  (macgirl@poboxes.com)
#direct all questions/comments about this proc to me (macgirl)
#  syntax:  !ping
#    do this on the channel.. not by /msg

bind pub - "!ping" pub_ping

proc pub_ping {nick uhost hand chan arg} {
  putserv "PRIVMSG $nick :\001PING [unixtime]\001"
  putlog "!ping received from $nick"
  return 0
}


bind ctcr - PING lag_reply

proc lag_reply {nick uhost hand dest key arg} {
  if {$key == "PING"} {
    set endd [unixtime]
    set lagg [expr $endd - $arg]
    if {$lagg > "30"} {
      putserv "PRIVMSG $nick :Geez!  You are horribly lagged!! Yer $lagg seconds behind the rest of us!  :(  Switch servers QUICK!"
      putlog "$nick is lagged by $lagg secs"
      return 1
    }
    if {$lagg > "15"} {
      putserv "PRIVMSG $nick :You are quite lagged!! Your ping time is $lagg secs! :("
      putlog "$nick is lagged by $lagg secs"
      return 1
    }
    putserv "PRIVMSG $nick :You are lagged by $lagg secs!  Not too bad! :)"
    putlog "$nick is lagged by $lagg secs"
  }
}


bind ctcp - PING ping_resp

proc ping_resp {nick uhost hand botnick key arg} {
  if {$key == "PING"} {
    putserv "NOTICE $nick :heehee that tickles!"
  }
}
