## Descripcion:													  
## my simple try to delnet nickserv@services.chating.id identify 
## and my first try too


# TCL by GoGers

# Goger Identify  TCL
putlog "auto identify to nickserv tcl is loaded - \0034,1Go\00314G\0034ers"

### Setup

# set nick n password to be identified - you must edit this
set nickname "Bonita"
set password "solupa"

### Code

# Change the m to another flag if you like. 
bind pub m .identify  do_identify
bind pub m .release do_release
bind pub m .ghost do_ghost


#    # # # # ## do not edit below # ### # # ## 

#identify  starts #

proc do_identify {nick host handle chan text} { 
global nickname password
putquick "PRIVMSG nickserv@services.chating.id :identify $nickname $password" 
putserv "NOTICE $nick :identifying to nickserv@services.chating.id..."
}
#ends here #

# nick release starts here #

proc do_release {nick host handle chan text} {
global nickname password
putquick "PRIVMSG nickserv@services.chating.id :release $nickname $password"
putserv "NOTICE $nick :releasing nick from  nickserv@services.chating.id..."
}
#ends here #

# nick Ghosting starts here #

proc do_ghost {nick host handle chan text} {
global nickname password
putquick "PRIVMSG nickserv@services.chating.id :ghost $nickname $password"
putserv "NOTICE $nick :Ghosting your Bot nick"
}
#ends here #

set init-server {  
putquick "PRIVMSG nickserv@services.chating.id :identify $nickname $password" 
putserv "MODE $nick +i"
}
 
