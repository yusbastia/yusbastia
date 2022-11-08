#######################################################################################################
## Covid19.tcl 1.3.6  (20/01/2021)  			  Copyright 2008 - 2021 @ WwW.TCLScripts.NET   						 ##
##                        _   _   _   _   _   _   _   _   _   _   _   _   _   _                      ##
##                       / \ / \ / \ / \ / \ / \ / \ / \ / \ / \ / \ / \ / \ / \                     ##
##                      ( T | C | L | S | C | R | I | P | T | S | . | N | E | T )                    ##
##                       \_/ \_/ \_/ \_/ \_/ \_/ \_/ \_/ \_/ \_/ \_/ \_/ \_/ \_/                     ##
##                                                                                                   ##
##                                        BLaCkShaDoW Production                      	        		 ##
##                                                                                                   ##
##                                              PRESENTS                                             ##
##									                               																									 ##
############################################  Covid-19 TCL   ##########################################
##									                             																										 ##
##  DESCRIPTION: 							                             																					 ##
## Shows realtime stats about the COVID-19 CORONAVIRUS OUTBREAK. These are taken from the site       ##
##  												    																																		 ##
##  https://www.worldometers.info/coronavirus/ by command and also auto if something changes from    ##
##												     																																			 ##
## the last information given. (RSS type)						             																		 ##
##			                            						    																								 ##
##  Tested on Eggdrop v1.8.4 (Debian Linux 3.16.0-4-amd64) Tcl version: 8.6.10                       ##
##									                             																										 ##
#######################################################################################################
##									                             																										 ##
##                                 /===============================\                                 ##
##                                 |      This Space For Rent      |                                 ##
##                                 \===============================/                                 ##
##									                             																										 ##
#######################################################################################################
##									                             																										 ##
##  INSTALLATION: 							                            																			   ##
##     ++ http package is REQUIRED for this script to work.                           		     			 ##
##     ++ tls package is REQUIRED for this script to work. (1.7.18-2 or later)                       ##
##  latest tls https://ubuntu.pkgs.org/19.10/ubuntu-universe-amd64/tcl-tls_1.7.18-2_amd64.deb.html   ##
##     ++ Edit the Covid19.tcl script and place it into your /scripts directory,                     ##
##     ++ add "source scripts/Covid19.tcl" to your eggdrop config and rehash the bot.                ##
##									                            																										 ##
#######################################################################################################
#######################################################################################################
##									                            																										 ##
##  OFFICIAL LINKS:                                                                                  ##
##   E-mail      : BLaCkShaDoW[at]tclscripts.net                                                     ##
##   Bugs report : http://www.tclscripts.net                                                         ##
##   GitHub page : https://github.com/tclscripts/ 			                             								 ##
##   Online help : irc://irc.undernet.org/tcl-help                                                   ##
##                 #TCL-HELP / UnderNet        	                                                     ##
##                 You can ask in english or romanian                                                ##
##									                             																										 ##
##     paypal.me/DanielVoipan = Please consider a donation. Thanks!                                  ##
##									                             																										 ##
#######################################################################################################
##									                            																										 ##
##                           You want a customised TCL Script for your eggdrop?                      ##
##                                Easy-peasy, just tell me what you need!                            ##
##                I can create almost anything in TCL based on your ideas and donations.             ##
##                  Email blackshadow@tclscripts.net or info@tclscripts.net with your                ##
##                    request informations and I'll contact you as soon as possible.                 ##
##									                             																										 ##
#######################################################################################################
##												        																																	 ##
##  Version 1.1 -- If country isnt specificed it will show the total statistics		     	 						 ##
##									                                																								 ##
##  Commmands: !Covid [country] - if not specified it will show the total statistics                 ##
##											                																														 ##
##                                                                                                   ##
##  Settings: .chanset/.set #chan +covid - enable the !covid <city> command                          ##
##            							                                        																 ##
##                                                                                                   ##
##            .chanset/.set #chan +autocovid - enable the auto message on timer if the               ##
##             information changes (like RSS feed)		                                       				 ##
##           											         																													 ##
##            .chanset/.set #chan covid-country [your country] - setup the default country           ##
##            for the Covid19 RSS (auto show information)					        												   ##
##												         																																	 ##
##            .chanset/.set #chan covid-lang Ro/En/Es - setup the default language for the scrip     ##
##												          																																 ##
##   Version 1.2.1 -- Added some new countries and places					          												 ##
##   Version 1.2.2 -- Solved an issue related to https connection 			 	          								 ##
##    												          																														 ##
##   Version 1.3 -- Solved some issues related to page layout		                         						 ##
##		 -- Added some more details from the page                                             			   ##
##												         																															     ##
##   Version 1.3.1 -- added difference between today and yesterday for active cases, recovered,      ##
##		      serious cases, tests for countries				                														   ##
##		   -- solved some bugs related to settng your default country		        											 ##
##		   -- added spanish language support                                                 			     ##
##												        																																	 ##
##   Version 1.3.2 -- added last updated entry to channel output				         										 ##
##												         																																	 ##
##   Version 1.3.3 -- added total stats for continents Europe, North America, Asia, South America,   ##
##                    Africa, Oceania								          																		   ##
##                 -- soved issue with GLOBAL stats output                                           ##
##												          																																 ##
##   Version 1.3.4 -- solved some issues due to page info modification                               ##
##                 -- solved some little bugs                                                        ##
##                                                                                                   ##
##   Version 1.3.5 -- solved some issues due to page info modification                               ##
##                 -- added population for countries                                                 ##
##                 -- added difference between today and yesterday for active cases, recovered,      ##
##                    serious cases for global and continents                                        ##
##												         																																	 ##
##   Version 1.3.6 -- added "1 case/death/test every X:" info from https://www.worldometers.info/    ##
##                 -- added vaccine information for some countries from                              ##
##									  https://github.com/owid/covid-19-data/tree/master/public/data/vaccinations     ##
##                    The source sais they rely on figures that are verifiable based on public        ##
##                    official sources. Stored in vaccinations.csv																	 ##
##																																																   ##
#######################################################################################################
#######################################################################################################
##									                             																										 ##
##  LICENSE:                                                                                         ##
##   This code comes with ABSOLUTELY NO WARRANTY.                                                    ##
##                                                                                                   ##
##   This program is free software; you can redistribute it and/or modify it under the terms of      ##
##   the GNU General Public License version 3 as published by the Free Software Foundation.          ##
##                                                                                                   ##
##   This program is distributed WITHOUT ANY WARRANTY; without even the implied warranty of          ##
##   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.                                            ##
##   USE AT YOUR OWN RISK.                                                                           ##
##                                                                                                   ##
##   See the GNU General Public License for more details.                                            ##
##        (http://www.gnu.org/copyleft/library.txt)                                                  ##
##                                                                                                   ##
##  			          Copyright 2008 - 2021 @ WwW.TCLScripts.NET                         							 ##
##                                                                                                   ##
#######################################################################################################
#######################################################################################################
##                                   CONFIGURATION FOR Covid19.TCL                                   ##
#######################################################################################################


###
#Default country for corona virus checking uppon command or timer
#put "GLOBAL" for total stats
#
set corona(country) "GLOBAL"

###
#Set script language (Ro/En/Es)
#
set corona(language) "en"


###
#Flags required to use !covid [country] command
#
set corona(flags) "-|-"


###
# FLOOD PROTECTION
#Set the number of minute(s) to ignore flooders
###
set corona(ignore_prot) "1"

###
# FLOOD PROTECTION
#Set the number of requests within specifide number of seconds to trigger flood protection.
# By default, 4:10, which allows for upto 3 queries in 10 seconds. 4 or more quries in 10 seconds would cuase
# the forth and later queries to be ignored for the amount of time specifide above.
###
set corona(flood_prot) "3:10"

###
#COVID RSS (minutes)
#Set here the time for the script to check if the info changed
#If the info changed it will be shown on chan
#only when the option is enabled with +autocovid
###
set corona(time_check) "60"

########################################################################################################

#Continents list

set corona(continent_list) {
"Europe"
"North America"
"Asia"
"South America"
"Africa"
"Oceania"
}


#Country list

set corona(country_list) {
"USA"
"Spain"
"Italy"
"France"
"Germany"
"UK"
"Turkey"
"China"
"Iran"
"Russia"
"Brazil"
"Belgium"
"Canada"
"Netherlands"
"Switzerland"
"Portugal"
"India"
"Peru"
"Ireland"
"Austria"
"Sweden"
"Israel"
"Japan"
"S. Korea"
"Chile"
"Ecuador"
"Saudi Arabia"
"Poland"
"Romania"
"Pakistan"
"Mexico"
"Denmark"
"Norway"
"UAE"
"Czechia"
"Australia"
"Singapore"
"Indonesia"
"Serbia"
"Philippines"
"Ukraine"
"Qatar"
"Malaysia"
"Belarus"
"Dominican Republic"
"Panama"
"Finland"
"Colombia"
"Luxembourg"
"South Africa"
"Egypt"
"Morocco"
"Argentina"
"Thailand"
"Algeria"
"Moldova"
"Bangladesh"
"Greece"
"Hungary"
"Kuwait"
"Bahrain"
"Croatia"
"Iceland"
"Kazakhstan"
"Uzbekistan"
"Iraq"
"Estonia"
"New Zealand"
"Azerbaijan"
"Slovenia"
"Lithuania"
"Armenia"
"Bosnia and Herzegovina"
"Oman"
"North Macedonia"
"Slovakia"
"Cuba"
"Hong Kong"
"Cameroon"
"Afghanistan"
"Bulgaria"
"Tunisia"
"Ivory Coast"
"Djibouti"
"Ghana"
"Cyprus"
"Latvia"
"Andorra"
"Diamond Princess"
"Lebanon"
"Costa Rica"
"Niger"
"Guinea"
"Burkina Faso"
"Albania"
"Kyrgyzstan"
"Nigeria"
"Bolivia"
"Uruguay"
"Channel Islands"
"Honduras"
"San Marino"
"Palestine"
"Malta"
"Taiwan"
"Jordan"
"R�union"
"Georgia"
"Senegal"
"Mauritius"
"DRC"
"Montenegro"
"Isle of Man"
"Sri Lanka"
"Mayotte"
"Kenya"
"Vietnam"
"Guatemala"
"Venezuela"
"Mali"
"Paraguay"
"El Salvador"
"Faeroe Islands"
"Jamaica"
"Tanzania"
"Somalia"
"Martinique"
"Guadeloupe"
"Rwanda"
"Congo"
"Brunei"
"Gibraltar"
"Cambodia"
"Madagascar"
"Trinidad and Tobago"
"Myanmar"
"Gabon"
"Ethiopia"
"Aruba"
"French Guiana"
"Monaco"
"Liberia"
"Bermuda"
"Togo"
"Liechtenstein"
"Equatorial Guinea"
"Barbados"
"Sint Maarten"
"Sudan"
"Guyana"
"Zambia"
"Cabo Verde"
"Cayman Islands"
"Bahamas"
"French Polynesia"
"Uganda"
"Maldives"
"Guinea-Bissau"
"Libya"
"Haiti"
"Macao"
"Syria"
"Eritrea"
"Mozambique"
"Saint Martin"
"Benin"
"Sierra Leone"
"Chad"
"Mongolia"
"Nepal"
"Zimbabwe"
"Angola"
"Antigua and Barbuda"
"Eswatini"
"Botswana"
"Laos"
"Timor-Leste"
"Belize"
"New Caledonia"
"Malawi"
"Fiji"
"Dominica"
"Namibia"
"Saint Lucia"
"Cura�ao"
"Grenada"
"Saint Kitts and Nevis"
"CAR"
"St. Vincent Grenadines"
"Turks and Caicos"
"Falkland Islands"
"Greenland"
"Montserrat"
"Seychelles"
"Nicaragua"
"Gambia"
"Suriname"
"MS Zaandam"
"Vatican City"
"Mauritania"
"Papua New Guinea"
"St. Barth"
"Western Sahara"
"Burundi"
"Bhutan"
"Caribbean Netherlands"
"British Virgin Islands"
"Sao Tome and Principe"
"South Sudan"
"Anguilla"
"Saint Pierre Miquelon"
"Yemen"
"Lesotho"
"Comoros"
}

###############################################################################################################
#
#			Try to edit only the language :-)
#
###############################################################################################################

package require tls
package require http

bind pub $corona(flags) !covid corona:pub

setudef flag covid
setudef flag autocovid

setudef str covid-country
setudef str covid-lang


###
if {![info exists corona(timer_start)]} {
	timer $corona(time_check) corona:auto_timer
	set corona(timer_start) 1
}

###
proc corona:auto_timer {} {
	global corona
	set channels ""
foreach chan [channels] {
	if {[channel get $chan autocovid] && [validchan $chan]} {
	lappend channels $chan
		}
	}
if {$channels != ""} {
	set data [corona:getdata]
	corona:auto_check $data $channels 0
	} else {
	timer $corona(time_check) corona:auto_timer
	}
}

###
proc corona:auto_check {data channels num} {
	global corona
	set total 0
	set chan [lindex $channels $num]
	set country [string toupper [channel get $chan covid-country]]
if {$country == ""} { set country $corona(country) }
if {[string tolower $country] != "global"} {
	set find_continent [lsearch -nocase $corona(continent_list) $country]
	set find_country [lsearch -nocase $corona(country_list) $country]
if {$find_country < 0 && $find_continent < 0} {
	set country "GLOBAL"
} elseif {$find_continent > -1} {
	set country [lindex $corona(continent_list) $find_continent]
	set total 2
} else {
	set country [lindex $corona(country_list) $find_country]
	}
}
if {[string tolower $country] == "global"} {
	set total 1
}
	set extract [corona:extract $data $country $total]
	set total_cases [lindex $extract 0]
	set new_cases [lindex $extract 1]
	set total_deaths [lindex $extract 2]
	set new_deaths [lindex $extract 3]
	set total_recovered [lindex $extract 4]
	set active_cases [lindex $extract 5]
	set serious_critical [lindex $extract 6]
	set totalcases_per_milion [lindex $extract 7]
	set deaths_per_milion [lindex $extract 8]
	set total_tests [lindex $extract 9]
	set totaltests_per_milion [lindex $extract 10]
	set type [lindex $extract 11]
	set last_updated [lindex $extract 12]
	set other_details [lindex $extract 14]
	set extract [string map [list $last_updated ""] $extract]
if {$new_cases == ""} { set new_cases - }
if {$total_deaths == ""} { set total_deaths - }
if {$new_deaths == ""} { set new_deaths - }
if {$total_recovered == ""} { set total_recovered - }
if {$active_cases == ""} { set active_cases - }
if {$totalcases_per_milion == ""} { set totalcases_per_milion - }
if {$deaths_per_milion == ""} { set deaths_per_milion - }
if {$total_tests == ""} { set total_tests - }
if {$totaltests_per_milion == ""} { set totaltests_per_milion - }

if {[info exists corona($chan:autocovid:entry)]} {
if {$corona($chan:autocovid:entry) != $extract} {
	set corona($chan:autocovid:entry) $extract
if {$type == "1"} {
	if {$other_details != 0} {
		set case_every_x [lindex $other_details 0]
		set death_every_x [lindex $other_details 1]
		set test_every_x [lindex $other_details 2]
		corona:say "" $chan [list $country $total_cases $new_cases $total_deaths $new_deaths $total_recovered $active_cases $serious_critical $totalcases_per_milion $deaths_per_milion $total_tests $totaltests_per_milion $last_updated $case_every_x $death_every_x $test_every_x] 8
} else {
	corona:say "" $chan [list $country $total_cases $new_cases $total_deaths $new_deaths $total_recovered $active_cases $serious_critical $totalcases_per_milion $deaths_per_milion $total_tests $totaltests_per_milion $last_updated] 4
	}
} else {
	corona:say "" $chan [list $country $total_cases $new_cases $total_deaths $new_deaths $total_recovered $active_cases $serious_critical $totalcases_per_milion $deaths_per_milion $last_updated] 6
		}
	}
} else {
	set corona($chan:autocovid:entry) $extract
if {$type == "1"} {
	if {$other_details != 0} {
		set case_every_x [lindex $other_details 0]
		set death_every_x [lindex $other_details 1]
		set test_every_x [lindex $other_details 2]
		corona:say "" $chan [list $country $total_cases $new_cases $total_deaths $new_deaths $total_recovered $active_cases $serious_critical $totalcases_per_milion $deaths_per_milion $total_tests $totaltests_per_milion $last_updated $case_every_x $death_every_x $test_every_x] 8
} else {
	corona:say "" $chan [list $country $total_cases $new_cases $total_deaths $new_deaths $total_recovered $active_cases $serious_critical $totalcases_per_milion $deaths_per_milion $total_tests $totaltests_per_milion $last_updated] 4
	}
} else {
	corona:say "" $chan [list $country $total_cases $new_cases $total_deaths $new_deaths $total_recovered $active_cases $serious_critical $totalcases_per_milion $deaths_per_milion $last_updated] 6
	}
}
	set next_num [expr $num + 1]
if {[lindex $channels $next_num] != ""} {
	utimer 5 [list corona:auto_check $data $channels $next_num]
	} else {
	timer $corona(time_check) corona:auto_timer
	}
}


###
proc corona:getdata {} {
	global corona
	set link "https://www.worldometers.info/coronavirus/"
	set cookies "7=false 16=true 17=true 18=true"
	http::register https 443 [list ::tls::socket -autoservername true]
	set ipq [http::config -useragent "lynx"]
	set ipq [::http::geturl "$link" -headers [list Cookie [join $cookies ";"]] -timeout 5000]
	set status [::http::status $ipq]
if {$status != "ok"} {
	::http::cleanup $ipq
	return
}
	set data [http::data $ipq]
	::http::cleanup $ipq
	return $data
}

###
proc corona:vaccine {country} {
	global corona
if {[string equal -nocase $country "USA"]} {
	set country "United States"
} elseif {[string equal -nocase $country "UK"]} {
	set country "United Kingdom"
}
	set country [join $country "%20"]
	http::register https 443 [list ::tls::socket -autoservername true]
	set link "https://raw.githubusercontent.com/owid/covid-19-data/master/public/data/vaccinations/country_data/$country.csv"
	set ipq [http::config -useragent "lynx"]
	set ipq [::http::geturl "$link" -timeout 5000]
	set status [::http::status $ipq]
if {$status != "ok"} {
	::http::cleanup $ipq
	return 0
}
	set data [http::data $ipq]
if {[string match -nocase "*404: Not Found*" $data]} {
	return 0
}
	set split_data [split $data "\n"]
	::http::cleanup $ipq
	set length [llength $split_data]
	set line [lindex $split_data [expr $length - 2]]
	regexp {"(.*)"} $line -> get_vacine
	if {[info exists get_vacine]} {
	set line [string map [list $get_vacine ""] $line]
}
	set split_line [split $line ","]
	set last_check [lindex $split_line 1]
if {![info exists get_vacine]} {
	set get_vacine [lindex $split_line 2]
}
	set total_vaccinations [lindex $split_line 4]
	set people_vaccinated [lindex $split_line 5]
	set people_fully_vaccinated [lindex $split_line 6]
	return [list $last_check $get_vacine $total_vaccinations $people_vaccinated $people_fully_vaccinated]
}

###
proc corona:pub {nick host hand chan arg} {
	global corona
if {![channel get $chan covid]} {
	return
}
	set total 0
	set flood_protect [corona:flood:prot $chan $host]

if {$flood_protect == "1"} {
	set get_seconds [corona:get:flood_time $host $chan]
	corona:say $nick "NOTC" [list $get_seconds] 2
	return
}
	set country [join [lrange [split $arg] 0 end]]
if {$country == ""} {
	set total 1
	set country "GLOBAL"
} else {
	set find_continent [lsearch -nocase $corona(continent_list) $country]
	set find_country [lsearch -nocase $corona(country_list) $country]
if {$find_country < 0 && $find_continent < 0} {
	corona:say $nick $chan "" 1
	return
} elseif {$find_continent > -1} {
	set country [lindex $corona(continent_list) $find_continent]
	set total 2
} else {
	set country [lindex $corona(country_list) $find_country]
	}
}
	set data [corona:getdata]
	set extract [corona:extract $data $country $total]
	set total_cases [lindex $extract 0]
	set new_cases [lindex $extract 1]
	set total_deaths [lindex $extract 2]
	set new_deaths [lindex $extract 3]
	set total_recovered [lindex $extract 4]
	set active_cases [lindex $extract 5]
	set serious_critical [lindex $extract 6]
	set totalcases_per_milion [lindex $extract 7]
	set deaths_per_milion [lindex $extract 8]
	set total_tests [lindex $extract 9]
	set totaltests_per_milion [lindex $extract 10]
	set type [lindex $extract 11]
	set last_updated [lindex $extract 12]
	set population [lindex $extract 13]
	set other_details [lindex $extract 14]
if {$new_cases == ""} { set new_cases - }
if {$total_deaths == ""} { set total_deaths - }
if {$new_deaths == ""} { set new_deaths - }
if {$total_recovered == ""} { set total_recovered - }
if {$active_cases == ""} { set active_cases - }
if {$totalcases_per_milion == ""} { set totalcases_per_milion - }
if {$serious_critical == ""} { set serious_critical - }
if {$deaths_per_milion == ""} { set deaths_per_milion - }
if {$total_tests == ""} { set total_tests - }
if {$totaltests_per_milion == ""} { set totaltests_per_milion - }
if {$type > "0"} {
if {$other_details != 0} {
	set case_every_x [lindex $other_details 0]
	set death_every_x [lindex $other_details 1]
	set test_every_x [lindex $other_details 2]
	corona:say $nick $chan [list $country $total_cases $new_cases $total_deaths $new_deaths $total_recovered $active_cases $serious_critical $totalcases_per_milion $deaths_per_milion $total_tests $totaltests_per_milion $last_updated $population $case_every_x $death_every_x $test_every_x] 7
} else {
	corona:say $nick $chan [list $country $total_cases $new_cases $total_deaths $new_deaths $total_recovered $active_cases $serious_critical $totalcases_per_milion $deaths_per_milion $total_tests $totaltests_per_milion $last_updated $population] 3
	}
} else {
	corona:say $nick $chan [list $country $total_cases $new_cases $total_deaths $new_deaths $total_recovered $active_cases $serious_critical $totalcases_per_milion $deaths_per_milion $last_updated] 5
	}
	set vaccine_data [corona:vaccine $country]
if {$vaccine_data != "0"} {
	set last_update [lindex $vaccine_data 0]
	set vaccine_type [lindex $vaccine_data 1]
	set total_vaccinations [corona:commify [lindex $vaccine_data 2]]
	set people_vaccinated [corona:commify [lindex $vaccine_data 3]]
	set people_fully_vaccinated [corona:commify [lindex $vaccine_data 4]]
	corona:say $nick $chan [list $country $total_vaccinations $people_vaccinated $people_fully_vaccinated $vaccine_type $last_update] 9
	}
}

proc corona:extract {data country total} {
	global corona
	set last_updated "N/A"
	set yesterday_data ""
	set today_data ""
	set var_lastupdated "<div style=\"font-size:13px; color:#999; margin-top:5px; text-align:center\">Last updated:(.*)</div>(.*)"
	regexp {<div style=\"font-size:13px; color:#999; margin-top:5px; text-align:center\">(.*)</div>(.*)} $data -> last_updated
	regsub {</div>(.*)} $last_updated "" last_updated
	set last_updated [concat [string map {"Last updated:" ""} $last_updated]]

	regexp {<table id="main_table_countries_yesterday" class="table table-bordered table-hover main_table_countries" style="width:100%;margin-top: 0px !important;display:none;">(.*)} $data yesterday_data
	regsub {</table>(.*)} $yesterday_data "" yesterday_data

	regexp {<table id="main_table_countries_today" class="table table-bordered table-hover main_table_countries" style="width:100%;margin-top: 0px !important;display:none;">(.*)} $data today_data
	regsub {</table>(.*)} $today_data "" today_data

	set split_today_data [split $today_data "\n"]
	set split_yesterday_data [split $yesterday_data "\n"]

	set information_today ""
	set information_yesterday ""
	set c 0
	set first_line 0
	set last_line 0
	set case_details_found 0
switch $total {
	0 {
	set var "<td style=\"font-weight: bold; font-size:15px; text-align:left;\">$country</td>|<td style=\"font-weight: bold; font-size:15px; text-align:left;\"><a class=\"mt_a\" href=\"(.*)\">$country</a></td>(.*)"
	}
	1 {
	set var "<td style=\"text-align:left;\">World</td>"
	}
	2 {
	set var "<nobr>$country</nobr>"
	}
}

foreach line $split_today_data {
	set line [concat $line]
if {[regexp -nocase $var $line]} {
	set first_line $c
	continue
	}
if {[string match -nocase "*</tr>" $line] && $first_line > 0} {
	set last_line $c
	break
	}
	set c [expr $c + 1]
}

	set new_data [lrange $split_today_data $first_line $last_line]
foreach line $new_data {
	set test [regexp {<td style="(.*)">\d*(.*)\d*</td>|<td>(.*)</td>|text-align:right;(.*)\">\d*(.*)\d*</td>|<td>\d*(.*)\d*</td>} $line match]
if {$test > 0} {
	regsub {</td>(.*)} $match "" m
if {[string match -nocase "*population*" $m]} {
	regexp {<a href="/world-population/(.*)/">(.*)} $m -> a m
}
	lappend information_today $m
	}
	set test2 [regexp {<td>(.+)</td><td>(.+)</td><td>(.+)</td>} $line string case_every_x death_every_x test_every_x]
if {$test2 > 0} {
	lappend information_today [list $case_every_x $death_every_x $test_every_x]
	set case_details_found 1
	}
}

	set first_line 0
	set last_line 0
	set c 0
foreach line $split_yesterday_data {
	set line [concat $line]
if {[regexp -nocase $var $line]} {
	set first_line $c
	continue
	}
if {[string match -nocase "*</tr>" $line] && $first_line > 0} {
	set last_line $c
	break
}
	set c [expr $c + 1]
}

	set new_data [lrange $split_yesterday_data $first_line $last_line]
foreach line $new_data {
	set test [regexp {<td style="(.*)">\d*(.*)\d*</td>|<td>(.*)</td>|text-align:right;(.*)\">\d*(.*)\d*</td>|<td>\d*(.*)\d*</td>} $line match]
if {$test > 0} {
	regsub {</td>(.*)} $match "" m
	lappend information_yesterday $m
	}
}

if {$total == "2"} {
	set total_cases [corona:filter [lindex $information_today 0] 0]
	set new_cases [corona:filter [lindex $information_today 1] 0]
	set total_deaths [corona:filter [lindex $information_today 2] 0]
	set new_deaths [corona:filter [lindex $information_today 3] 0]
	set total_recovered [corona:filter [lindex $information_today 4] 0]
	set active_cases [corona:filter [lindex $information_today 6] 0]
	set serious_cases [corona:filter [lindex $information_today 7] 0]
	set totalcases_per_milion [corona:filter [lindex $information_today 8] 0]
	set deaths_per_milion [corona:filter [lindex $information_today 9] 0]
	set total_tests [corona:filter [lindex $information_today 10] 0]
	set totaltests_per_milion [corona:filter [lindex $information_today 11] 0]

	set dif_total_recovered 0
	set dif_active_cases 0
	set dif_serious_cases 0

	set yesterday_total_recovered [corona:comma [corona:filter [lindex $information_yesterday 4] 0]]
	set yesterday_active_cases [corona:comma [corona:filter [lindex $information_yesterday 6] 0]]
	set yesterday_serious_cases [corona:comma [corona:filter [lindex $information_yesterday 7] 0]]

if {$total_recovered != "" && $yesterday_total_recovered != "" && $total_recovered != $yesterday_total_recovered} {
if {[corona:comma $total_recovered] > $yesterday_total_recovered} {
	set dif_total_recovered +[expr [corona:comma $total_recovered] - $yesterday_total_recovered]
} else {
	set dif_total_recovered -[expr $yesterday_total_recovered - [corona:comma $total_recovered]]
	}
}
if {$active_cases != "" && $yesterday_active_cases != "" && $active_cases != $yesterday_active_cases} {
if {[corona:comma $active_cases] > $yesterday_active_cases} {
	set dif_active_cases +[expr [corona:comma $active_cases] - $yesterday_active_cases]
} else {
	set dif_active_cases -[expr $yesterday_active_cases - [corona:comma $active_cases]]
	}
}
if {$serious_cases != "" && $yesterday_serious_cases != "" && $serious_cases != $yesterday_serious_cases} {
if {[corona:comma $serious_cases] > $yesterday_serious_cases} {
	set dif_serious_cases +[expr [corona:comma $serious_cases] - $yesterday_serious_cases]
} else {
	set dif_serious_cases -[expr $yesterday_serious_cases - [corona:comma $serious_cases]]
	}
}
if {$total_tests != "" && $yesterday_total_tests != "" && $total_tests != $yesterday_total_tests} {
if {[corona:comma $total_tests] > $yesterday_total_tests} {
	set dif_total_tests +[expr [corona:comma $total_tests] - $yesterday_total_tests]
} else {
	set dif_total_tests -[expr $yesterday_total_tests - [corona:comma $total_tests]]
	}
}

if {$dif_total_recovered != "0"} {
	set total_recovered $total_recovered\[[corona:commify $dif_total_recovered]\]
}
if {$dif_active_cases != "0"} {
	set active_cases $active_cases\[[corona:commify $dif_active_cases]\]
}

if {$dif_serious_cases != "0"} {
	set serious_cases $serious_cases\[[corona:commify $dif_serious_cases]\]
}

	return [list $total_cases $new_cases $total_deaths $new_deaths $total_recovered $active_cases $serious_cases $totalcases_per_milion $deaths_per_milion $total_tests $totaltests_per_milion 0 $last_updated 0]
} elseif {$total == "1"} {
	set total_cases [corona:filter [lindex $information_today 1] 0]
	set new_cases [corona:filter [lindex $information_today 2] 0]
	set total_deaths [corona:filter [lindex $information_today 3] 0]
	set new_deaths [corona:filter [lindex $information_today 4] 0]
	set total_recovered [corona:filter [lindex $information_today 5] 0]
	set active_cases [corona:filter [lindex $information_today 7] 0]
	set serious_cases [corona:filter [lindex $information_today 8] 0]
	set totalcases_per_milion [corona:filter [lindex $information_today 9] 0]
	set deaths_per_milion [corona:filter [lindex $information_today 10] 0]
	set total_tests [corona:filter [lindex $information_today 11] 0]
	set totaltests_per_milion [corona:filter [lindex $information_today 12] 0]

	set yesterday_total_recovered [corona:comma [corona:filter [lindex $information_yesterday 5] 0]]
	set yesterday_active_cases [corona:comma [corona:filter [lindex $information_yesterday 7] 0]]
	set yesterday_serious_cases [corona:comma [corona:filter [lindex $information_yesterday 8] 0]]

	set dif_total_recovered 0
	set dif_active_cases 0
	set dif_serious_cases 0

	if {$total_recovered != "" && $yesterday_total_recovered != "" && $total_recovered != $yesterday_total_recovered} {
if {[corona:comma $total_recovered] > $yesterday_total_recovered} {
	set dif_total_recovered +[expr [corona:comma $total_recovered] - $yesterday_total_recovered]
} else {
	set dif_total_recovered -[expr $yesterday_total_recovered - [corona:comma $total_recovered]]
	}
}
if {$active_cases != "" && $yesterday_active_cases != "" && $active_cases != $yesterday_active_cases} {
if {[corona:comma $active_cases] > $yesterday_active_cases} {
	set dif_active_cases +[expr [corona:comma $active_cases] - $yesterday_active_cases]
} else {
	set dif_active_cases -[expr $yesterday_active_cases - [corona:comma $active_cases]]
	}
}
if {$serious_cases != "" && $yesterday_serious_cases != "" && $serious_cases != $yesterday_serious_cases} {
if {[corona:comma $serious_cases] > $yesterday_serious_cases} {
	set dif_serious_cases +[expr [corona:comma $serious_cases] - $yesterday_serious_cases]
} else {
	set dif_serious_cases -[expr $yesterday_serious_cases - [corona:comma $serious_cases]]
	}
}
if {$total_tests != "" && $yesterday_total_tests != "" && $total_tests != $yesterday_total_tests} {
if {[corona:comma $total_tests] > $yesterday_total_tests} {
	set dif_total_tests +[expr [corona:comma $total_tests] - $yesterday_total_tests]
} else {
	set dif_total_tests -[expr $yesterday_total_tests - [corona:comma $total_tests]]
	}
}

if {$dif_total_recovered != "0"} {
	set total_recovered $total_recovered\[[corona:commify $dif_total_recovered]\]
}
if {$dif_active_cases != "0"} {
	set active_cases $active_cases\[[corona:commify $dif_active_cases]\]
}

if {$dif_serious_cases != "0"} {
	set serious_cases $serious_cases\[[corona:commify $dif_serious_cases]\]
}

	return [list $total_cases $new_cases $total_deaths $new_deaths $total_recovered $active_cases $serious_cases $totalcases_per_milion $deaths_per_milion $total_tests $totaltests_per_milion 0 $last_updated 0]
} elseif {$total == "0"} {
	set country [corona:filter [lindex $information_today 0] 0]
	set total_cases [corona:filter [lindex $information_today 1] 0]
	set new_cases [corona:filter [lindex $information_today 2] 0]
	set total_deaths [corona:filter [lindex $information_today 3] 0]
	set new_deaths [corona:filter [lindex $information_today 4] 0]
	set total_recovered [corona:filter [lindex $information_today 5] 0]
	set active_cases [corona:filter [lindex $information_today 7] 0]
	set serious_cases [corona:filter [lindex $information_today 8] 0]
	set totalcases_per_milion [corona:filter [lindex $information_today 9] 0]
	set deaths_per_milion [corona:filter [lindex $information_today 10] 0]
	set total_tests [corona:filter [lindex $information_today 11] 0]
	set totaltests_per_milion [corona:filter [lindex $information_today 12] 0]
	set population [concat [string map {"</a>" ""} [lindex $information_today 13]]]

	if {$case_details_found == 1} {
		set case_details [lindex $information_today 16]
	} else {
		set case_details 0
	}

	set yesterday_total_recovered [corona:comma [corona:filter [lindex $information_yesterday 5] 0]]
	set yesterday_active_cases [corona:comma [corona:filter [lindex $information_yesterday 7] 0]]
	set yesterday_serious_cases [corona:comma [corona:filter [lindex $information_yesterday 8] 0]]
	set yesterday_total_tests [corona:comma [corona:filter [lindex $information_yesterday 11] 0]]

	set dif_total_recovered 0
	set dif_active_cases 0
	set dif_serious_cases 0
	set dif_total_tests 0

if {$total_recovered != "" && $yesterday_total_recovered != "" && $total_recovered != $yesterday_total_recovered} {
if {[corona:comma $total_recovered] > $yesterday_total_recovered} {
	set dif_total_recovered +[expr [corona:comma $total_recovered] - $yesterday_total_recovered]
} else {
	set dif_total_recovered -[expr $yesterday_total_recovered - [corona:comma $total_recovered]]
	}
}
if {$active_cases != "" && $yesterday_active_cases != "" && $active_cases != $yesterday_active_cases} {
if {[corona:comma $active_cases] > $yesterday_active_cases} {
	set dif_active_cases +[expr [corona:comma $active_cases] - $yesterday_active_cases]
} else {
	set dif_active_cases -[expr $yesterday_active_cases - [corona:comma $active_cases]]
	}
}
if {$serious_cases != "" && $yesterday_serious_cases != "" && $serious_cases != $yesterday_serious_cases} {
if {[corona:comma $serious_cases] > $yesterday_serious_cases} {
	set dif_serious_cases +[expr [corona:comma $serious_cases] - $yesterday_serious_cases]
} else {
	set dif_serious_cases -[expr $yesterday_serious_cases - [corona:comma $serious_cases]]
	}
}
if {$total_tests != "" && $yesterday_total_tests != "" && $total_tests != $yesterday_total_tests} {
if {[corona:comma $total_tests] > $yesterday_total_tests} {
	set dif_total_tests +[expr [corona:comma $total_tests] - $yesterday_total_tests]
} else {
	set dif_total_tests -[expr $yesterday_total_tests - [corona:comma $total_tests]]
	}
}

if {$dif_total_recovered != "0"} {
	set total_recovered $total_recovered\[[corona:commify $dif_total_recovered]\]
}
if {$dif_active_cases != "0"} {
	set active_cases $active_cases\[[corona:commify $dif_active_cases]\]
}

if {$dif_serious_cases != "0"} {
	set serious_cases $serious_cases\[[corona:commify $dif_serious_cases]\]
}
if {$dif_total_tests != "0"} {
	set total_tests $total_tests\[[corona:commify $dif_total_tests]\]
		}
	return [list $total_cases $new_cases $total_deaths $new_deaths $total_recovered $active_cases $serious_cases $totalcases_per_milion $deaths_per_milion $total_tests $totaltests_per_milion 1 $last_updated $population $case_details]
	}
}

###
proc corona:filter {text type} {
if {$type == "0"} {
	set split_text [split $text ">"]
	return [concat [lindex $split_text 1]]
} else {
	set text [string map {"<td>" ""
			      "<nobr>" ""
			      "</nobr>" ""
			} $text]
	return [concat $text]
	}
}

proc corona:comma {num} {
	global corona
	set text [string map {"," ""} $num]
	return $text
}

###
proc corona:flood:prot {chan host} {
	global corona
	set number [scan $corona(flood_prot) %\[^:\]]
	set timer [scan $corona(flood_prot) %*\[^:\]:%s]
if {[info exists corona(flood:$host:$chan:act)]} {
	return 1
}
foreach tmr [utimers] {
if {[string match "*corona:remove:flood $host $chan*" [join [lindex $tmr 1]]]} {
	killutimer [lindex $tmr 2]
	}
}
if {![info exists corona(flood:$host:$chan)]} {
	set corona(flood:$host:$chan) 0
}
	incr corona(flood:$host:$chan)
	utimer $timer [list corona:remove:flood $host $chan]
if {$corona(flood:$host:$chan) > $number} {
	set corona(flood:$host:$chan:act) 1
	utimer 60 [list corona:expire:flood $host $chan]
	return 1
	} else {
	return 0
	}
}

###
proc corona:expire:flood {host chan} {
	global corona
if {[info exists corona(flood:$host:$chan:act)]} {
	unset corona(flood:$host:$chan:act)
	}
}

###
proc corona:remove:flood {host chan} {
	global corona
if {[info exists corona(flood:$host:$chan)]} {
	unset corona(flood:$host:$chan)
	}
}

###
proc corona:get:flood_time {host chan} {
	global corona
		foreach tmr [utimers] {
if {[string match "*corona:expire:flood $host $chan*" [join [lindex $tmr 1]]]} {
	return [lindex $tmr 0]
		}
	}
}


###
proc corona:wrap {str {len 100} {splitChr { }}} {
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
proc corona:say {nick chan arg num} {
	global corona
	set inc 0
if {$chan == "NOTC"} {
	set lang [string tolower $corona(language)]
} else {
	set lang [string tolower [channel get $chan covid-lang]]
if {$lang == ""} {
	set lang [string tolower $corona(language)]
} else {
if {[info exists corona($lang.lang.1)]} {
	set lang $lang
	} else {
	set lang [string tolower $corona(language)]
		}
	}
}
foreach s $arg {
	set inc [expr $inc + 1]
	set replace(%msg.$inc%) $s
}
	set reply [string map [array get replace] $corona($lang.lang.$num)]
if {$chan == "NOTC"} {
foreach w [corona:wrap $reply 450] {
	putserv "NOTICE $nick :$w"
	}
} else {
foreach w [corona:wrap $reply 450] {
	putserv "PRIVMSG $chan :$w"
		}
	}
}


###
proc corona:commify {num {sep ,}} {
    fixpoint num {
        regsub {^([-+]?\d+)(\d\d\d)} $num "\\1$sep\\2"
    }
}


###
#http://wiki.tcl.tk/5000
proc fixpoint {varName script} {
    upvar 1 $varName arg
    while {[set res [uplevel 1 $script]] ne $arg} {
        set arg $res
    }
    return $arg
}

set corona(name) "Covid-19"
set corona(owner) "BLaCkShaDoW"
set corona(site) "WwW.TclScripts.Net"
set corona(version) "1.3.6"

####
#Language
#
###
set corona(en.lang.1) "Invalid country specified or NO CASES"
set corona(en.lang.2) "You exceded the number of commands. Please wait \002%msg.1%\002 seconds."
set corona(en.lang.3) "\002COVID-19\002 stats -- \002%msg.1%\002 -- Total Cases: \002%msg.2%\002 ; New Cases: \037%msg.3%\037 ; Total Deaths: \002%msg.4%\002 ; New Deaths: \037%msg.5%\037 ; Recovered: \002%msg.6%\002 ; Active Cases: \037%msg.7%\037 ; Critical: \002%msg.8%\002 ; Total Cases/1M pop: \002%msg.9%\002 ; Deaths/1M pop: \002%msg.10%\002 ; Total tests: \002%msg.11%\002 ; Tests/1M pop: \002%msg.12%\002 ; Population: \002%msg.14%\002 ; Last Updated: \002%msg.13%\002"
set corona(en.lang.4) "(AUTO) \002COVID-19\002 stats -- \002%msg.1%\002 -- Total Cases: \002%msg.2%\002 ; New Cases: \037%msg.3%\037 ; Total Deaths: \002%msg.4%\002 ; New Deaths: \037%msg.5%\037 ; Recovered: \002%msg.6%\002 ; Active Cases: \037%msg.7%\037 ; Critical: \002%msg.8%\002 ; Total Cases/1M pop: \002%msg.9%\002 ; Deaths/1M pop: \002%msg.10%\002 ; Total tests: \002%msg.11%\002 ; Tests/1M pop: \002%msg.12%\002 ; Last Updated: \002%msg.13%\002"
set corona(en.lang.5) "\002COVID-19\002 stats -- \002%msg.1%\002 -- Total Cases: \002%msg.2%\002 ; New Cases: \037%msg.3%\037 ; Total Deaths: \002%msg.4%\002 ; New Deaths: \037%msg.5%\037 ; Recovered: \002%msg.6%\002 ; Active Cases: \037%msg.7%\037 ; Critical: \002%msg.8%\002 ; Total Cases/1M pop: \002%msg.9%\002 ; Deaths/1M pop: \002%msg.10%\002 ; Last Updated: \002%msg.11%\002"
set corona(en.lang.6) "(AUTO) \002COVID-19\002 stats -- \002%msg.1%\002 -- Total Cases: \002%msg.2%\002 ; New Cases: \037%msg.3%\037 ; Total Deaths: \002%msg.4%\002 ; New Deaths: \037%msg.5%\037 ; Recovered: \002%msg.6%\002 ; Active Cases: \037%msg.7%\037 ; Critical: \002%msg.8%\002 ; Total Cases/1M pop: \002%msg.9%\002 ; Deaths/1M pop: \002%msg.10%\002 ; Last Updated: \002%msg.11%\002"
set corona(en.lang.7) "\002COVID-19\002 stats -- \002%msg.1%\002 -- Total Cases: \002%msg.2%\002 ; New Cases: \037%msg.3%\037 ; Total Deaths: \002%msg.4%\002 ; New Deaths: \037%msg.5%\037 ; Recovered: \002%msg.6%\002 ; Active Cases: \037%msg.7%\037 ; Critical: \002%msg.8%\002 ; Total Cases/1M pop: \002%msg.9%\002 ; Deaths/1M pop: \002%msg.10%\002 ; Total tests: \002%msg.11%\002 ; Tests/1M pop: \002%msg.12%\002 ; 1 case/death/test every X: (\002%msg.15%\002/\002%msg.16%\002/\002%msg.17%\002) ; Population: \002%msg.14%\002 ; Last Updated: \002%msg.13%\002"
set corona(en.lang.8) "(AUTO) \002COVID-19\002 stats -- \002%msg.1%\002 -- Total Cases: \002%msg.2%\002 ; New Cases: \037%msg.3%\037 ; Total Deaths: \002%msg.4%\002 ; New Deaths: \037%msg.5%\037 ; Recovered: \002%msg.6%\002 ; Active Cases: \037%msg.7%\037 ; Critical: \002%msg.8%\002 ; Total Cases/1M pop: \002%msg.9%\002 ; Deaths/1M pop: \002%msg.10%\002 ; Total tests: \002%msg.11%\002 ; Tests/1M pop: \002%msg.12%\002 ; 1 case/death/test every X: (\002%msg.14%\002/\002%msg.15%\002/\002%msg.16%\002) ; Last Updated: \002%msg.13%\002"
set corona(en.lang.9) "\002COVID-19\002 vaccine stats -- \002%msg.1%\002 -- Total Vaccinations: \002%msg.2%\002 ; People Vaccinated: \002%msg.3%\002 ; People Fully Vaccinated: \002%msg.4%\002 ; Vaccine: \002%msg.5%\002 ; Last Update: \002%msg.6%\002"


set corona(ro.lang.1) "Tara invalida sau nu sunt cazuri."
set corona(ro.lang.2) "Ai depasit number de comenzi. Te rog asteapta \002%msg.1%\002 secunde."
set corona(ro.lang.3) "Statistici \002COVID-19\002 -- \002%msg.1%\002 -- Cazuri totale: \002%msg.2%\002 ; Cazuri noi: \037%msg.3%\037 ; Total decedati: \002%msg.4%\002 ; Noi decedati: \037%msg.5%\037 ; Recuperati: \002%msg.6%\002 ; Cazuri active: \037%msg.7%\037 ; Cazuri critice: \002%msg.8%\002 ; Total cazuri/1M pop: \002%msg.9%\002 ; Decedati/1M pop: \002%msg.10%\002 ; Total teste: \002%msg.11%\002 ; Teste/1M pop: \002%msg.12%\002 ; Populatie: \002%msg.14%\002 ; Ultimul update: \002%msg.13%\002"
set corona(ro.lang.4) "(AUTO) Statistici \002COVID-19\002 pentru -- %msg.1% -- Cazuri totale: \002%msg.2%\002 ; Cazuri noi: \037%msg.3%\037 ; Total decedati: \002%msg.4%\002 ; Noi decedati: \037%msg.5%\037 ; Recuperati: \002%msg.6%\002 ; Cazuri active: \037%msg.7%\037 ; Cazuri critice: \002%msg.8%\002 ; Total cazuri/1M pop: \002%msg.9%\002 ; Decedati/1M pop: \002%msg.10%\002 ; Total teste: \002%msg.11%\002 ; Teste/1M pop: \002%msg.12%\002 ; Ultimul update: \002%msg.13%\002"
set corona(ro.lang.5) "Statistici \002COVID-19\002 -- \002%msg.1%\002 -- Cazuri totale: \002%msg.2%\002 ; Cazuri noi: \037%msg.3%\037 ; Total decedati: \002%msg.4%\002 ; Noi decedati: \037%msg.5%\037 ; Recuperati: \002%msg.6%\002 ; Cazuri active: \037%msg.7%\037 ; Cazuri critice: \002%msg.8%\002 ; Total cazuri/1M pop: \002%msg.9%\002 ; Decedati/1M pop: \002%msg.10%\002 ; Ultimul update: \002%msg.11%\002"
set corona(ro.lang.6) "(AUTO) Statistici \002COVID-19\002 pentru -- %msg.1% -- Cazuri totale: \002%msg.2%\002 ; Cazuri noi: \037%msg.3%\037 ; Total decedati: \002%msg.4%\002 ; Noi decedati: \037%msg.5%\037 ; Recuperati: \002%msg.6%\002 ; Cazuri active: \037%msg.7%\037 ; Cazuri critice: \002%msg.8%\002 ; Total cazuri/1M pop: \002%msg.9%\002 ; Decedati/1M pop: \002%msg.10%\002 ; Ultimul update: \002%msg.11%\002"
set corona(ro.lang.7) "Statistici \002COVID-19\002 -- \002%msg.1%\002 -- Cazuri totale: \002%msg.2%\002 ; Cazuri noi: \037%msg.3%\037 ; Total decedati: \002%msg.4%\002 ; Noi decedati: \037%msg.5%\037 ; Recuperati: \002%msg.6%\002 ; Cazuri active: \037%msg.7%\037 ; Cazuri critice: \002%msg.8%\002 ; Total cazuri/1M pop: \002%msg.9%\002 ; Decedati/1M pop: \002%msg.10%\002 ; Total teste: \002%msg.11%\002 ; Teste/1M pop: \002%msg.12%\002; 1 caz/deces/test la X: (\002%msg.15%\002/\002%msg.16%\002/\002%msg.17%\002) ; Populatie: \002%msg.14%\002 ; Ultimul update: \002%msg.13%\002"
set corona(ro.lang.8) "(AUTO) Statistici \002COVID-19\002 pentru -- %msg.1% -- Cazuri totale: \002%msg.2%\002 ; Cazuri noi: \037%msg.3%\037 ; Total decedati: \002%msg.4%\002 ; Noi decedati: \037%msg.5%\037 ; Recuperati: \002%msg.6%\002 ; Cazuri active: \037%msg.7%\037 ; Cazuri critice: \002%msg.8%\002 ; Total cazuri/1M pop: \002%msg.9%\002 ; Decedati/1M pop: \002%msg.10%\002 ; Total teste: \002%msg.11%\002 ; Teste/1M pop: \002%msg.12%\002 ; 1 caz/deces/test la X: (\002%msg.14%\002/\002%msg.15%\002/\002%msg.16%\002) ; Ultimul update: \002%msg.13%\002"
set corona(ro.lang.9) "\002COVID-19\002 statistici vaccinare -- \002%msg.1%\002 -- Total vaccinuri: \002%msg.2%\002 ; Persoane vaccinate: \002%msg.3%\002 ; Persoane vaccinate total (2 doze): \002%msg.4%\002 ; Tip vaccin: \002%msg.5%\002 ; Ultimul Update: \002%msg.6%\002"


#Translated in spanish by charls_a
#Ayuda @ Undernet.org
set corona(es.lang.1) "Nombre de pais invalido, o no presenta casos."
set corona(es.lang.2) "Has excedido el numero de intentos. Por favor espera \002%msg.1%\002 segundos."
set corona(es.lang.3) "\002COVID-19\002 Estadisticas -- \002%msg.1%\002 -- Total de Casos: \002%msg.2%\002 ; Nuevos Casos: \037%msg.3%\037 ; Total de personas fallecidas: \002%msg.4%\002 ; Nuevos casos de personas fallecidas: \037%msg.5%\037 ; Recuperados: \002%msg.6%\002 ; Casos activos: \037%msg.7%\037 ; En estado critico: \002%msg.8%\002 ; Total de Casos/1M pob: \002%msg.9%\002 ; Fallecimientos/1M pob: \002%msg.10%\002 ; Total de pruebas: \002%msg.11%\002 ; Pruebas/1M pob: \002%msg.12%\002 ; Poblaci�n: \002%msg.14%\002 ; Ultima actualizacion: \002%msg.13%\002"
set corona(es.lang.4) "(AUTO) \002COVID-19\002 Estadisticas -- \002%msg.1%\002 -- Total de Casos: \002%msg.2%\002 ; Nuevos Casos: \037%msg.3%\037 ; Total de personas fallecidas: \002%msg.4%\002 ; Nuevoss casos de personas fallecidas: \037%msg.5%\037 ; Recuperados: \002%msg.6%\002 ; Casos activos: \037%msg.7%\037 ; En estado critico: \002%msg.8%\002 ; Total de Casos/1M pob: \002%msg.9%\002 ; Fallecimientos/1M pob: \002%msg.10%\002 ; Total de pruebas: \002%msg.11%\002 ; Pruebas/1M pob: \002%msg.12%\002 ; Ultima actualizacion: \002%msg.13%\002"
set corona(es.lang.5) "\002COVID-19\002 Estadisticas -- \002%msg.1%\002 -- Total de Casos: \002%msg.2%\002 ; Nuevos Casos: \037%msg.3%\037 ; Total de personas fallecidas: \002%msg.4%\002 ; Nuevos casos de personas fallecidas: \037%msg.5%\037 ; Recuperados: \002%msg.6%\002 ; Casos activos: \037%msg.7%\037 ; En estado critico: \002%msg.8%\002 ; Total de Casos/1M pob: \002%msg.9%\002 ; Fallecimientos/1M pob: \002%msg.10%\002 ; Ultima actualizacion: \002%msg.11%\002"
set corona(es.lang.6) "(AUTO) \002COVID-19\002 Estadisticas -- \002%msg.1%\002 -- Total de Casos: \002%msg.2%\002 ; Nuevos Casos: \037%msg.3%\037 ; Total de personas fallecidas: \002%msg.4%\002 ; Nuevos casos de personas fallecidas: \037%msg.5%\037 ; Recuperados: \002%msg.6%\002 ; Casos activos: \037%msg.7%\037 ; En estado critico: \002%msg.8%\002 ; Total de Casos/1M pob: \002%msg.9%\002 ; Fallecimientos/1M pob: \002%msg.10%\002 ; Ultima actualizacion: \002%msg.11%\002"
set corona(es.lang.7) "\002COVID-19\002 Estadisticas -- \002%msg.1%\002 -- Total de Casos: \002%msg.2%\002 ; Nuevos Casos: \037%msg.3%\037 ; Total de personas fallecidas: \002%msg.4%\002 ; Nuevos casos de personas fallecidas: \037%msg.5%\037 ; Recuperados: \002%msg.6%\002 ; Casos activos: \037%msg.7%\037 ; En estado critico: \002%msg.8%\002 ; Total de Casos/1M pob: \002%msg.9%\002 ; Fallecimientos/1M pob: \002%msg.10%\002 ; Total de pruebas: \002%msg.11%\002 ; Pruebas/1M pob: \002%msg.12%\002;
1 caso/muerte/prueba cada X: (\002%msg.15%\002/\002%msg.16%\002/\002%msg.17%\002) ; Poblacion: \002%msg.14%\002 ; Ultima actualizacion: \002%msg.13%\002"
set corona(es.lang.8) "(AUTO) \002COVID-19\002 Estadisticas -- \002%msg.1%\002 -- Total de Casos: \002%msg.2%\002 ; Nuevos Casos: \037%msg.3%\037 ; Total de personas fallecidas: \002%msg.4%\002 ; Nuevoss casos de personas fallecidas: \037%msg.5%\037 ; Recuperados: \002%msg.6%\002 ; Casos activos: \037%msg.7%\037 ; En estado critico: \002%msg.8%\002 ; Total de Casos/1M pob: \002%msg.9%\002 ; Fallecimientos/1M pob: \002%msg.10%\002 ; Total de pruebas: \002%msg.11%\002 ; Pruebas/1M pob: \002%msg.12%\002 ; 1 caso/muerte/prueba cada X: (\002%msg.14%\002/\002%msg.15%\002/\002%msg.16%\002) ; Ultima actualizacion: \002%msg.13%\002"
set corona(es.lang.9) "\002COVID-19\002 estadisticas de vacunas -- \002%msg.1%\002 -- Vacunas totales: \002%msg.2%\002 ; Personas vacunadas: \002%msg.3%\002 ; Personas totalmente vacunadas: \002%msg.4%\002 ; Vacuna: \002%msg.5%\002 ; Ultima actualizacion: \002%msg.6%\002"


putlog "$corona(name) $corona(version) TCL by $corona(owner) loaded. For more tcls visit -- $corona(site) --"
