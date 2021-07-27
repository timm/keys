BEGIN { FS="\n"; RS=""}
NR==2 { for(i=1;i<=NF;i++) print "-- " $i;
        exit } 
