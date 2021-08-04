.PHONY: help pdf

help: # print options
	@echo "options:";
	@gawk '/^[a-z].*:.*#/{  \
      s=$$1; $$1="";       \
      gsub(/^.*#/,"");      \
      gsub(/:/,"",s);      \
      print "\tmake " s "\t" $$0 }  ' Makefile

#html: ../docs/keys.html  # sadas
#../docs/keys.html : keys
#	bash ../etc/pretty keys  

docs: ../docs/keys.html

../docs/keys.html: ../src/keys # doc
	- rm $@
	pycco -d ../docs -l lua $<
	cp ../etc/pycco.css ../docs
