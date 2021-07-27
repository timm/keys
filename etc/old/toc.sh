#!/usr/bin/env gawk -f

BEGIN {print "<details> <summary>Contents</summary>\n" }
/^#/  {toc=""
       txt  = $0;  sub(/^[#]*[ \t]*/, "",  txt); 
       link = txt; gsub(/[ \t]+/,     "-", link); 
       toc  = "- ["txt"](#"tolower(link)")" 
       if      (/^####### /) {print "          " toc}
       else if (/^###### /)  {print "        "   toc}
       else if (/^##### /)   {print "      "     toc}
       else if (/^#### /)    {print "    "       toc}
       else if (/^### /)     {print "  "         toc}
       else if (/^## /)      {print ""           toc};
       next}
END   {print "\n</details>\n" }
