BEGIN { FS="\n"; RS=""}
NR==1 { next }
NR==2 { print $1 "\n" $2 "\n" txt }
NR> 2 { print "\n" $0 }
