pdoc() {
  cd ../docs
  pandoc -f markdown  --template=ez.html --toc  --mathjax \
        --highlight-style pygments --css style.css -s ../src/$1.md \
        -o $1.html
}

../etc/pretty keys SE for AI- less but better 
pdoc fyi-simpler 

