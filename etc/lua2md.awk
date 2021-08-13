BEGIN { header($0,Fname) }
      { /^--/ ? comment($0) : code($0) }

function  header(b4,name) {
  if (getline > 0) {
    if (! /^[ \t]*$/) 
      header($0,name)
    else {
      print "---\ntitle: "FILENAME"\nlayout: page\n---\n" }}}

function comments(b4,tail) {
  if(tail) print(tail)
  gsub(/^--/,"",b4)
  gsub(/^ /,"",b4)
  print b4
  if (getline > 0) { /^--/ ? comments($0) : code($0) }}

function code(b4)  { print "\n```lua"; code1(b4) }

function code1(b4) {
  print b4
  if (getline > 0) { /^[^-]/ ? code1($0) : comments($0,  "```\n") }}
