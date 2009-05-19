require 'sparsehash'
require 'timeout'

include Sparsehash
include STL
include GNU if defined?(GNU)

if RUBY_PLATFORM.downcase =~ /mswin(?!ce)|mingw|cygwin|bccwin/
  def memoryusage()
    tasks = `tasklist`
    lines = tasks.split("\n")
    lines.each do |line|
      row = line.split(/\s+/)
      if row[1].to_i == $$
        return row[3].gsub(',', '').to_i / 1024.0
      end
    end
    return -1;
  end
else
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
end

clazz = Object.const_get(ARGV[0]) # Hash, SparseHashMap, DenseHashMap
rnum = ARGV[1].to_i # 100, 10000, 1000000

puts("#{clazz}: #{rnum}")
time = Time.now
size = memoryusage
hash = clazz.new

begin
  timeout(120) do
    (0...rnum).each do |i|
      buf = sprintf("%08d", i)
      hash[buf] = buf
    end

    time = Time.now - time
    GC.start
    size = memoryusage - size

    printf("Time: %.3f sec.\n", time)
    printf("Usage: %.3f MB\n", size)
  end
rescue Timeout::Error
  printf("-----\n\n")
end
