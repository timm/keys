BEGIN { img="https://i.dlpng.com/static/png/6933553_preview.png"
        FS="\n"; RS=""    }
NR==1 { next              }
NR==2 { print "-- <img width=150 align=right src=\""img"\">"
        print $0 "\n" txt }
NR> 2 { print "\n" $0     }
