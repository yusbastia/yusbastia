bind pub - lag ping_me
bind pub - ping ping_me
bind ctcr - PING ping_me_reply

proc ping_me {nick uhost hand chan arg} {
     global pingchan pingwho
     set arg [string toupper $arg]
     if {$arg == "" || [string match "#*" $arg]} {
          puthelp "NOTICE $nick :Gunakan: ping me atau lag nick "
          return 0
     } elseif {$arg == "ME"} {
          putserv "PRIVMSG $nick :\001PING [unixtime]\001"
          set pingwho 0
          set pingchan $chan
          return 1
     } else { 
          putserv "PRIVMSG $arg :\001PING [unixtime]\001"
          set pingwho 1
          set pingchan $chan
          return 1
     }
}

proc ping_me_reply {nick uhost hand dest key arg} {
     global pingchan pingwho
     if {$pingwho == 0} {
          puthelp "PRIVMSG $pingchan :12$nick ping: [expr [unixtime] - $arg] detik"
          return 0
     } elseif {$pingwho == 1} {
          puthelp "PRIVMSG $pingchan :12$nick ping: [expr [unixtime] - $arg] detik"
          return 0
     }
}

putlog "- vian PinG Lo@Ded ©-"
