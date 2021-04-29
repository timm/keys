BEGIN { FS="\n"; RS=""}
NR==2 { print "-- " $1
        for(i=2;i<=NF;i++) print " " $i;
        exit } 
