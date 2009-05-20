#!/bin/sh
VERSION=0.1.1

rm *.gem *.tar.bz2 2> /dev/null
rm -rf doc

FILES='README etc/anymap.rb etc/anyset.rb'
rdoc -w 4 -SHN -f darkfish -m README --title 'sparsehash - Ruby bindings for Google Sparse Hash.' $FILES
cp etc/*.png doc

mkdir work
cp -r * work 2> /dev/null
cd work

tar jcf sparsehash-${VERSION}.tar.bz2 --exclude=.svn README *.gemspec ext doc
gem build sparsehash.gemspec
gem build sparsehash-mswin32.gemspec
cp sparsehash-${VERSION}-x86-mswin32.gem sparsehash-${VERSION}-mswin32.gem

rm -rf lib
mv lib1.9 lib
gem build sparsehash1.9-mswin32.gemspec
cp *.gem *.tar.bz2 ..
cd ..

rm -rf work
