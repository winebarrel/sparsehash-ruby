require 'mkmf'

if have_library('stdc++')
  create_makefile('sparsehash')
end
