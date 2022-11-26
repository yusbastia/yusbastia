set clock_chans {
    "#basechanel"
}

# Posochete prez kakav interval ot vreme da go kazva (v minuti)
set interval 30

############################################################################

bind pub - !time say_time
timer $interval vreme

proc vreme {} {
    global interval clock_chans
    set Kalimera [time]
    foreach zaek $clock_chans {
	putserv "PRIVMSG $zaek :Chasut e $Kalimera :>"
    }
    timer $interval vreme
}

proc say_time {nick uhost hand kanal kom} {
    set chas [time]
    puthelp "PRIVMSG $kanal :Chasut e $chas ;>"
    return 0
}
