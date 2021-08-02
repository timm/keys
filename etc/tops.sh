#!/usr/bin/env bash

here=$1

top1() {
  cat $here/README.md | gawk '
        BEGIN { FS="\n"; RS="" }
              { print; exit 0  }'
  cat $1 | gawk '
        BEGIN { FS="\n"; RS="" }
        NR==1 && $1~/name=top/ { next }
              { print ""; print }'
}

if [ -d "$here" ]; then
   f=$(find $here  -type f -name '*.md')
   for g in $f;  do
     h=$(mktemp)
     echo "# updating $g ..."
     top1 $g > $h
     mv $h $g
   done
fi
