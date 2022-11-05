###########################################################################################
## Jokes.tcl 1.0  (20/04/2020)  	      Copyright 2008 - 2020 @ WwW.TCLScripts.NET ##
##                   _   _   _   _   _   _   _   _   _   _   _   _   _   _               ##
##                  / \ / \ / \ / \ / \ / \ / \ / \ / \ / \ / \ / \ / \ / \              ##
##                 ( T | C | L | S | C | R | I | P | T | S | . | N | E | T )             ##
##                  \_/ \_/ \_/ \_/ \_/ \_/ \_/ \_/ \_/ \_/ \_/ \_/ \_/ \_/              ##
##                                                                                       ##
##                               ® BLaCkShaDoW Production ®                    	         ##
##                                                                                       ##
##                                         PRESENTS                                      ##
##									               ® ##
########################################  JOKES TCL   #####################################
##									                 ##
##  DESCRIPTION: 							                 ##
##  Shows jokes from laughfactory.com by specifing category or by search. 		 ##
##			                            					 ##
##  Tested on Eggdrop v1.8.4 (Debian Linux 3.16.0-4-amd64) Tcl version: 8.6.10           ##
##									                 ##
###########################################################################################
##									                 ##
##                                        ########                                       ##
##                       #####        ####        ####                                   ##
##                      #     #    ##                  ##                                ##
##                      #     #   ##      ##    ##       ##                              ##
##                      #    #  ##        ##    ##        ##                             ##
##                       #   #   #                         ##                            ##
##                     ############                         ##                           ##
##                    #            #   ##           ##      ##                           ##
##                   ##            #   ##           ##      ##                           ##
##                  ##   ###########     ##       ##       ##                            ##
##                  #               #      #######        ##        A heart at peace     ##
##                  ##              #                    ##     gives life to the body.  ##
##                   #   ############                   ##                               ##
##                   ##           #   ####         ####                                  ##
##                    ############        #########                                      ##
##									                 ##
###########################################################################################
##									                 ##
##  INSTALLATION: 							                 ##
##     ++ http package is REQUIRED for this script to work.                           	 ##
##									                 ##
##     ++ Edit the Jokes.tcl script and place it into your /scripts directory,           ##
##     ++ add "source scripts/Jokes.tcl" to your eggdrop config and rehash the bot.      ##
##									                 ##
###########################################################################################
###########################################################################################
##									                 ##
##  OFFICIAL LINKS:                                                                      ##
##   E-mail      : BLaCkShaDoW[at]tclscripts.net                                         ##
##   Bugs report : http://www.tclscripts.net                                             ##
##   GitHub page : https://github.com/tclscripts/ 			                 ##
##   Online help : irc://irc.undernet.org/tcl-help                                       ##
##                 #TCL-HELP / UnderNet        	                                         ##
##                 You can ask in english or romanian                                    ##
##									                 ##
##     paypal.me/DanielVoipan = Please consider a donation. Thanks!                      ##
##									                 ##
###########################################################################################
##									                 ##
##              You want a customised TCL Script for your eggdrop?                       ##
##                   Easy-peasy, just tell us what you need!                             ##
##       We can create almost anything in TCL based on your ideas and donations.         ##
##          Email blackshadow@tclscripts.net or info@tclscripts.net with your            ##
##           request informations and we'll contact you as soon as possible.             ##
##									                 ##
###########################################################################################
##											 ##
##  To enable: .chanset +jokes | from BlackTools: .set #channel +jokes                   ##
##											 ##
##  To enable autoshow : .chanset +autojokes | from BlackTools: .set #channel +autojokes ##
##											 ##
##  !joke - shows a random joke.                                                         ##
##											 ##
##  !joke <cat.nr> - shows a random joke from a category.		                 ##
##          (the number is in !joke categ)	                                         ##
##											 ##
##  !joke <search string> - search a random joke using a string	                         ##
##											 ##
##  !joke help - shows the help								 ##
##											 ##
###########################################################################################
##									                 ##
##  LICENSE:                                                                             ##
##   This code comes with ABSOLUTELY NO WARRANTY.                                        ##
##                                                                                       ##
##   This program is free software; you can redistribute it and/or modify it under       ##
##   the terms of the GNU General Public License version 3 as published by the           ##
##   Free Software Foundation.          						 ##
##                                                                                       ##
##   This program is distributed WITHOUT ANY WARRANTY; without even the implied          ##
##   warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.                    ##
##   USE AT YOUR OWN RISK.                                                               ##
##                                                                                       ##
##   See the GNU General Public License for more details.                                ##
##        (http://www.gnu.org/copyleft/library.txt)                                      ##
##                                                                                       ##
##  			          Copyright 2008 - 2020 @ WwW.TCLScripts.NET             ##
##                                                                                       ##
###########################################################################################

###########################################################################################
##                           CONFIGURATION FOR Jokes.TCL                                 ##
###########################################################################################


###
#  Jokes categories:
##
# 1 - LATEST
# 2 - ANIMAL
# 3 - BLONDE
# 4 - BOYCOTT THESE
# 5 - CLEAN
# 6 - FAMILY
# 7 - FOOD
# 8 - HOLIDAY
# 9 - HOW TO BE INSULTING
#10 - INSULT
#11 - MISCELLANEOUS
#12 - NATIONAL
#13 - OFFICE
#14 - POLITICAL
#15 - POP CULTURE
#16 - RELATIONSHIP
#17 - RELIGIOUS
#18 - SCHOOL
#19 - SCIENCE
#20 - SEX
#21 - SEXIST
#22 - SPORTS
#23 - TECHNOLOGY
#24 - WORD PLAY
#25 - YO MOMMA
##

# Joke AutoShow Time (minutes)
##
set joke(autoshow_time) "30"


# Cmdchar trigger
##
set joke(char) "!"


#What flags can use the !joke command ? (-|- for all)
##
set joke(flags_use) "-|-"

###########################################################################################
###             DO NOT MODIFY HERE UNLESS YOU KNOW WHAT YOU'RE DOING                    ###
###########################################################################################

package require http

###
# Bindings
# - using commands
bind pub $joke(flags_use) $joke(char)joke joke:cmd

###
# Channel flags
setudef flag jokes
setudef flag autojokes


if {![info exists joke(timer_start)]} {
	timer $joke(autoshow_time) joke:autoshow
	set joke(timer_start) 1
}

###
proc joke:get_info {categ} {
	global joke
switch $categ {
	1 {
	return [list "LATEST" "http://www.laughfactory.com/jokes/latest-jokes"]
	}
	2 {
	return [list "ANIMAL" "http://www.laughfactory.com/jokes/animal-jokes"]
	}
	3 {
	return [list "BLONDE" "http://www.laughfactory.com/jokes/blonde-jokes"]
	}
	4 {
	return [list "BOYCOTT THESE" "http://www.laughfactory.com/jokes/boycott-these-jokes"]
	}
	5 {
	return [list "CLEAN" "http://www.laughfactory.com/jokes/clean-jokes"]
	}
	6 {
	return [list "FAMILY" "http://www.laughfactory.com/jokes/family-jokes"]
	}
	7 {
	return [list "FOOD" "http://www.laughfactory.com/jokes/food-jokes"]
	}
	8 {
	return [list "HOLIDAY" "http://www.laughfactory.com/jokes/holiday-jokes"]
	}		
	9 {
	return [list "HOW TO BE INSULTING" "http://www.laughfactory.com/jokes/how-to-be-insulting"]
	}
	10 {
	return [list "INSULT" "http://www.laughfactory.com/jokes/insult-jokes"]
	}
	11 {
	return [list "MISCELLANEOUS" "http://www.laughfactory.com/jokes/miscellaneous-jokes"]
	}
	12 {
	return [list "NATIONAL" "http://www.laughfactory.com/jokes/national-jokes"]
	}
	13 {
	return [list "OFFICE" "http://www.laughfactory.com/jokes/office-jokes"]
	}
	14 {
	return [list "POLITICAL" "http://www.laughfactory.com/jokes/political-jokes"]
	}
	15 {
	return [list "POP CULTURE" "http://www.laughfactory.com/jokes/pop-culture-jokes"]
	}
	16 {
	return [list "RELATIONSHIP" "http://www.laughfactory.com/jokes/relationship-jokes"]
	}
	17 {
	return [list "RELIGIOUS" "http://www.laughfactory.com/jokes/religious-jokes"]
		}
	18 {
	return [list "SCHOOL" "http://www.laughfactory.com/jokes/school-jokes"]
		}
	19 {
	return [list "SCIENCE" "http://www.laughfactory.com/jokes/science-jokes"]
		}
	20 {
	return [list "SEX" "http://www.laughfactory.com/jokes/sex-jokes"]
		}
	21 {
	return [list "SEXIST" "http://www.laughfactory.com/jokes/sexist-jokes"]
		}
	22 {
	return [list "SPORTS" "http://www.laughfactory.com/jokes/sports-jokes"]
		}
	23 {
	return [list "TECHNOLOGY" "http://www.laughfactory.com/jokes/technology-jokes"]
		}
	24 {
	return [list "WORD PLAY" "http://www.laughfactory.com/jokes/word-play-jokes"]
		}
	25 {
	return [list "YO MOMMA" "http://www.laughfactory.com/jokes/yo-momma-jokes"]
		}
	}
}


###
proc joke:utf8_text {string} {
    set map {}
	set string [string map {";" ""} $string]
    foreach {entity number} [regexp -all -inline {&#(\d+)} $string] {
        lappend map $entity [format \\u%04x [scan $number %d]]
    }
    set string [string map [subst -nocomm -novar $map] $string]
	return $string
}



#http://wiki.tcl.tk/989
proc joke:wsplit {string sep} {
    set first [string first $sep $string]
    if {$first == -1} {
        return [list $string]
    } else {
        set l [string length $sep]
        set left [string range $string 0 [expr {$first-1}]]
        set right [string range $string [expr {$first+$l}] end]
        return [concat [list $left] [joke:wsplit $right $sep]]
    }
}


###
proc joke:wrap {str {len 100} {splitChr { }}} { 
   set out [set cur {}]; set i 0 
   foreach word [split [set str][unset str] $splitChr] { 
     if {[incr i [string len $word]]>$len} { 
         lappend out [join $cur $splitChr]
         set cur [list [encoding convertfrom utf-8 $word]] 
         set i [string len $word] 
      } { 
         lappend cur $word 
      } 
      incr i 
   } 
   lappend out [join $cur $splitChr] 
}


###
proc joke:likes_dislikes {data num} {
	global joke
	set num [joke:filter $num]
	set like "N/A"
	set dislike "N/A"

	set regex_like "<a class=\"like\" href=\"(.*)\" id=\"(.*)\" onclick=\"(.*)\"><img src=\"(.*)\" /><span id=\"thumbs_up_number_$num\">(.*)"
	set regex_like_2 "<span id=\"thumbs_up_number_$num\">(.*)"
	regexp $regex_like $data like
	regexp $regex_like_2 $like -> like
	regsub {</span></a>(.*)} $like "" like

	set regex_dislike "<a class=\"dislike\" href=\"(.*)\" onclick=\"(.*)\"><img src=\"(.*)\" \/><span  id=\"thumbs_down_number_$num\">(.*)"
	set regex_dislike_2 "<span  id=\"thumbs_down_number_$num\">(.*)"
	regexp $regex_dislike $data dislike
	regexp $regex_dislike_2 $dislike -> dislike
	regsub {</span></a>(.*)} $dislike "" dislike
	return [list $like $dislike]
}

###
proc joke:show {chan output num type likes dislikes search} {
	global joke botnick
if {![onchan $botnick $chan]} {
if {[info exists joke(show:$chan)]} {
	unset joke(show:$chan)
	return
	}
}
	set line [lindex $output $num]
	set nr_mesaj 0
if {$num == "0"} {
if {$search == 0} {
	set categ [lindex [joke:get_info $type] 0]
	puthelp "PRIVMSG $chan :\002Category\002: \"$categ\"  [joke:utf8_text &#10004] $likes   [joke:utf8_text &#10008] $dislikes"    
	} else {
	puthelp "PRIVMSG $chan :\002Search\002: \"$search\"  [joke:utf8_text &#10004] $likes   [joke:utf8_text &#10008] $dislikes"
	}
}
foreach l [joke:wrap $line 400] {
if {$nr_mesaj == "0"} {
	puthelp "PRIVMSG $chan :\[\002[joke:utf8_text &#8492]\002\] [encoding convertfrom "utf-8" [concat $l]]"	
		} else {
	puthelp "PRIVMSG $chan :[encoding convertfrom "utf-8" [concat $l]]"
		}
	incr nr_mesaj		
	}
	set inc [expr $num + 1]
if {[lindex $output $inc] != ""} {
	utimer 1 [list joke:show $chan $output $inc $type $likes $dislikes $search]
	} else {
	puthelp "PRIVMSG $chan :---= \002End\002 =---"
if {[info exists joke(show:$chan)]} {
	unset joke(show:$chan)
	return
		}
	}
}

###
proc joke:get {chan type search} {
	global joke
if {$search == 0} {
	set link [lindex [joke:get_info $type] 1]
if {$type > 1} {
if {![info exists joke($type:categ)]} {
	set data [joke:data $link]
	} else {
	set rand_categ [rand $joke($type:categ)]
if {$rand_categ == "0"} { set rand_categ 1 }
	set link [lindex [joke:get_info $type] 1]/$rand_categ
	set data [joke:data $link]
		}	
	} else {
	set data [joke:data $link]
	}
} else {
	set search_kw [join $search "+"]
	set link "http://www.laughfactory.com/jokes/search/?kw=$search_kw"
	set data [joke:data $link]
}

if {$data == "0"} {
	return 0	
}
	regexp {<div class="main-right-content">(.*)} $data data
	regsub -all {<div class="pagination-sec" style="margin-top:15px;">(.*)} $data "" data
if {$search != "0"} {
	regexp {<h4>No jokes found matching your search terms.</h4>} $data no_matches
if {[info exists no_matches]} {
	puthelp "PRIVMSG $chan :\[\002[joke:utf8_text &#8492]\002\] No joke found matching your search terms"
	return
	}
}
	set split_data [split $data "\n"]
	array set itemlist [list]
	set j 0
	set start 0
	set end 0
	set inc 0
	set lines ""
	set b ""
foreach line $split_data {
	incr j
	set line [concat $line]
if {[regexp {<div class="joke-text">} $line]} {
	set start $j
	incr inc
	lappend itemlist($inc) $start
	continue
		}
if {[regexp {</div>} $line] && $start != "0"} {
	set end $j
	lappend itemlist($inc) [expr $end - 3]
	continue
	}
}
if {[array size itemlist] == 0} {
	return 0
}
	set a [rand [array size itemlist]]
if {$a == "0"} { set a 1 }
	set b [lindex $itemlist($a) 0]
	set c [lindex $itemlist($a) 1]
for {set i $b} {$i <= $c} { incr i} {
	lappend lines [concat [lindex $split_data $i]]
}
	set jk [string map {"</p>" ""
} [lindex $lines 1]]
	set joke_num [lindex $lines 0]
	set likes_dislikes [joke:likes_dislikes $data $joke_num]
	set likes [lindex $likes_dislikes 0]
	set dislikes [lindex $likes_dislikes 1]
	set total_joke [joke:filter [joke:total_joke $data]]
	
	set pages [expr $total_joke / 12]
if {![info exists joke($type:categ)]} {
	set joke($type:categ) $pages
}
	set output [joke:wsplit $jk "<br>"]
	set joke(show:$chan) 1
	joke:show $chan $output 0 $type $likes $dislikes $search
}


###
proc joke:autoshow {} {
	global joke
	set channels ""
foreach chan [channels] {
if {[channel get $chan autojokes]} {
	lappend channels $chan
	}
}
if {$channels != ""} {
	joke:autoshow:now $channels 0
	} else {
	timer $joke(autoshow_time) joke:autoshow
	}
}

###
proc joke:autoshow:now {channels num} {
	global joke botnick
	set chan [lindex $channels $num]
if {[onchan $botnick $chan]} {
if {![info exists joke(show:$chan)]} {	
	set rand_cat [rand 25]
if {$rand_cat == "0"} { set rand_cat 1 }
	joke:get $chan $rand_cat 0
		}
	}
	set inc [expr $num + 1]
if {[lindex $channels $inc] != ""} {
	utimer 10 [list joke:autoshow:now $channels $inc]
	} else {
	timer $joke(autoshow_time) joke:autoshow
	}
}

###
proc joke:cmd {nick host hand chan arg} {
	global joke
	set what [join [lrange [split $arg] 0 end]]
if {![channel get $chan jokes]} {
	return
}
if {[info exists joke(show:$chan)]} {
	putserv "NOTICE $nick :\[\002[joke:utf8_text &#8492]\002\] I'm showing a good joke at the moment.."
	return
}
if {$what == ""} {
	set rand_cat [rand 25]
if {$rand_cat == "0"} { set rand_cat 1 }
	set status [joke:get $chan $rand_cat 0]
if {$status == "0"} {
	putserv "NOTICE $nick :\[\002[joke:utf8_text &#8492]\002\] Cannot get jokes at the moment. Try again later"
	return
	}
	return
}
switch $what {
	categ {
	putserv "PRIVMSG $chan :\[\002[joke:utf8_text &#8492]\002\] Jokes categories : \#1 LATEST, \#2 ANIMAL, \#3 BLONDE, \#4 BOYCOTT THESE, \#5 CLEAN, \#6 FAMILY, \#7 FOOD, \#8 HOLIDAY, \#9 HOW TO BE INSULTING, \#10 INSULT, \#11 MISCELLANEOUS, \#12 NATIONAL, \#13 OFFICE, \#14 POLITICAL, \#15 POP CULTURE, \#16 RELATIONSHIP, \#17 RELIGIOUS, \#18 SCHOOL, \#19 SCIENCE, \#20 SEX, \#21 SEXIST, \#22 SPORTS, \#23 TECHNOLOGY, \#24 WORD PLAY, \#25 YO MOMMA."
	putserv "PRIVMSG $chan :\[\002[joke:utf8_text &#8492]\002\] Use !joke <cat. nr>"
}
	help {
	putserv "PRIVMSG $chan :\[\002[joke:utf8_text &#8492]\002\] To show jokes categories use: \002!joke categ\002"
	putserv "PRIVMSG $chan :\[\002[joke:utf8_text &#8492]\002\] To show a random joke use: \002!joke\002"
	putserv "PRIVMSG $chan :\[\002[joke:utf8_text &#8492]\002\] To show a random joke from a specific category use: \002!joke <cat. nr>\002"
	putserv "PRIVMSG $chan :\[\002[joke:utf8_text &#8492]\002\] To search a random joke by a given string use: \002!joke <string>\002"
}
    version {
	putserv "PRIVMSG $chan :\[\002[joke:utf8_text &#8492]\002\] \002$joke(projectName) $joke(version)\002 coded by\002 $joke(author)\002 ($joke(email)) --\002 $joke(website)\002. PRIVATE TCL available only on donations."
}
	default {
if {[regexp {^[0-9]} $what]} {
if {$what < 1 || $what > 25} {
	putserv "NOTICE $nick :\[\002[joke:utf8_text &#8492]\002\] Inexistent category number, use \002!joke categ\002 to list categories."
	return
		}
	set status [joke:get $chan $what 0]
if {$status == "0"} {
	putserv "NOTICE $nick :\[\002[joke:utf8_text &#8492]\002\] Cannot get jokes at the moment. Try again later."
	return
				}
	return
			}
	set status [joke:get $chan 0 $what]
if {$status == "0"} {
	putserv "NOTICE $nick :\[\002[joke:utf8_text &#8492]\002\] Cannot get jokes at the moment. Try again later"
	return
			}
		}
	}
}



###
proc joke:data {link} {
	http::register https 443 [list ::tls::socket -tls1 1]
	set ipq [::http::config -useragent "lynx"]
	set ipq [::http::geturl $link -timeout 5000]
	set status [::http::status $ipq]
if {$status != "ok"} { return 0 }
	set data [http::data $ipq]
	::http::cleanup $ipq
	return $data
}


###
proc joke:total_joke {data} {
	global joke
	set total_joke ""
	set joke_per_page ""
	regexp {<input type="hidden" value="(.*)" id="total_jokes" \/>} $data total_joke
	return $total_joke
}

###
proc joke:filter {line} {
	global joke
	set text [string map {
			       "<p>" ""
				"</p>" ""
				"&amp;" "&"
				"&apos;" "'"
				"&gt;" ">"
				"&lt;" "<"
				"&lsquo" "'"
				"id=\"total_jokes\" \/>" ""
				"<input type=\"hidden\" value=" ""
				"\"" ""
				"  " ""
				"<p id=\"joke_" ""
				">" ""
	} $line]
	return $text
}


###
# Credits
set joke(projectName) "Jokes.tcl"
set joke(author) "BLaCkShaDoW"
set joke(website) "wWw.TCLScriptS.NeT"
set joke(email) "blackshadow\[at\]tclscripts.net"
set joke(version) "v1.0"


putlog "\002$joke(projectName) $joke(version)\002 coded by\002 $joke(author)\002 ($joke(website)): Loaded & initialized.."

#######################
#######################################################################################
###                  *** END OF TCL ***                                             ###
#######################################################################################
