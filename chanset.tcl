######################################################################
#
# Acest TCL este utilizat pentru a activa comenzile din DCC/BOTNET prin #intermediul privatului! L-am creat pentru a va usura sa numai intrati #in BOTNET..cu user si parola..pentru a activa, acum este mult mai #simplu :)
#                                        BLaCkShaDoW Productions
#
######################################################################

#Pentru activare folositi in privatul botului : setinfo #canal +flag #sau prin comanda /query <BOT> setinfo #canal +flag
#De exemplu : setinfo #channel +protectops

#Aici poti seta accessul care trebuie sa il ai pentru a putea folosii #aceasta comanda

set access "nm|MANm"

bind msg $access setinfo msg:setinfos

proc msg:setinfos {nick uhost hand arg} {
  	global botnick
set chans [lindex $arg 0]
set flag [lindex $arg 1]
set type [lindex $arg 2]
 if {$type == ""} {
if {[botisop $chans] || ![botisop $chans]} { channel set $chans $flag ; putquick "PRIVMSG $nick :Am setat $flag pe $chans" } 
} else { channel set $chans $flag $type ; putquick "PRIVMSG $nick :Am setat $flag $type pe $chans" 
 }
 

}

 putlog "chanset tcl by BLaCkShaDoW Loaded !"

