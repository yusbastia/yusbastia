#encrypter/decrypter tcl by Krasi
#email: kcdenkov@gmail.com
#webpage: http://freeunibg.eu/
#modification by Krasi


bind dcc n encrypt dcc:encrypt
bind dcc n decrypt dcc:decrypt
proc dcc:encrypt {handle idx arg} {
  if {$arg == ""} {
    putidx $idx "* Usage: .en <key> <string>"
    return 0
  }
  set dakey [lindex $arg 0]
  set datext [lindex $arg 1]
  putidx $idx "* Encrypted output: [encrypt $dakey $datext]"
  return 0
}
proc dcc:decrypt {handle idx arg} {
  if {$arg == ""} {
    putidx $idx "* Usage: .dec <key> <string>"
    return 0
  }
  set dakey [lindex $arg 0]
  set datext [lindex $arg 1]
  putidx $idx "Decrypted output: [decrypt $dakey $datext]"
  return 0
}
putlog "* encryter/decrypter by |i-XeS-i|"
