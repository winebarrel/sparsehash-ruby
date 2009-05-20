#!/bin/sh
rm -rf doc
FILES='README etc/anymap.rb etc/anyset.rb'
rdoc -w 4 -SHN -f darkfish -m README --title 'sparsehash - Ruby bindings for Google Sparse Hash.' $FILES
cp etc/*.png doc
