Gem::Specification.new do |spec|
  spec.name              = 'sparsehash'
  spec.version           = '0.1.1'
  spec.platform          = 'mswin32'
  spec.summary           = 'Ruby bindings for Google Sparse Hash.'
  spec.require_paths     = %w(lib/i386-mswin32)
  spec.files             = %w(lib/i386-mswin32/sparsehash.so README etc/anymap.rb etc/anyset.rb)
  spec.author            = 'winebarrel'
  spec.email             = 'sgwr_dts@yahoo.co.jp'
  spec.homepage          = 'http://sparsehash.rubyforge.org'
  spec.has_rdoc          = true
  spec.rdoc_options      << '--title' << 'sparsehash - Ruby bindings for Google Sparse Hash.'
  spec.extra_rdoc_files  = %w(README etc/anymap.rb etc/anyset.rb)
  spec.rubyforge_project = 'sparsehash'
end
