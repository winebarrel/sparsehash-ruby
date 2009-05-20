#!/usr/bin/env ruby
require 'sparsehash'
require 'timeout'

include Sparsehash
include STL
include GNU

def memoryusage()
  status = `cat /proc/#{$$}/status`
  lines = status.split("\n")

  lines.each do |line|
    if line =~ /^VmRSS:/
      line.gsub!(/.*:\s*(\d+).*/, '\1')
      return line.to_i / 1024.0
    end
  end

  return -1;
end

clazz = Object.const_get(ARGV[0]) # Hash, SparseHashMap, DenseHashMap, STL::Map, GNU::HashMap
rnum = ARGV[1].to_i # 100, 10000, 1000000

time = Time.now
size = memoryusage
hash = clazz.new

(0...rnum).each do |i|
  buf = sprintf("%08d", i)
  hash[buf] = buf
end

time = Time.now - time
GC.start
size = memoryusage - size

printf("%.3f,%.3f", time, size)
