BEGIN { img="https://raw.githubusercontent.com/timm/keys/main/etc/img/padlock.png"
        FS="\n"; RS=""    }
NR==1 { next              }
NR==2 { print "-- <img width=150 align=right src=\""img"\">"
        print $0 "\n" txt }
NR> 2 { print "\n" $0     }
