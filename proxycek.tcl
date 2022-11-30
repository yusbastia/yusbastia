##################################################################################
## Check IP From Proxycheck.io                                                  ##
## Simple ProxyCheck TCL By iJoo                                                ##
##                                                                              ##
## Penambahan Region (Wilayah) edited by Lemon                       09/02/2022 ##
##################################################################################

package require http
package require tls
http::register https 443 [list ::tls::socket -autoservername true]

## Siapa yang bisa command? n = owner
set akses ""
set perintah "!cek"

bind pub $akses $perintah ijoo_ganteng

proc ijoo_ganteng {nick uhost hand chan rest} {
        set chkip [lindex $rest 0]
        set theURL "https://proxycheck.io/v2/$chkip?vpn=1&asn=1"
        set token [http::geturl $theURL]
        regexp {"status": "(.*?)"} [http::data $token] -> checkin
        if { [string match "error" $checkin] } {
                putquick "PRIVMSG $chan :Sorry IP Error!"
        } else {
                regexp {"asn": "(.*?)"} [http::data $token] -> ijoo_asn
                regexp {"provider": "(.*?)"} [http::data $token] -> ijoo_prov
                regexp {"city": "(.*?)"} [http::data $token] -> ijoo_city
		regexp {"region": "(.*?)"} [http::data $token] -> ijoo_reg
                regexp {"continent": "(.*?)"} [http::data $token] -> ijoo_cont
                regexp {"country": "(.*?)"} [http::data $token] -> ijoo_cont2
                regexp {"isocode": "(.*?)"} [http::data $token] -> ijoo_code
                regexp {"proxy": "(.*?)"} [http::data $token] -> ijoo_prox
                regexp {"type": "(.*?)"} [http::data $token] -> ijoo_type
                putquick "PRIVMSG $chan :IP:\002 $chkip\002, Provider:\002 $ijoo_prov\002, Lokasi:\002 4$ijoo_city, $ijoo_reg, $ijoo_cont2, $ijoo_cont ($ijoo_code)\002, Status:\002 $ijoo_type ($ijoo_prox proxy)\002"
        }
}

putlog "ProxyCheck is Loaded!"
