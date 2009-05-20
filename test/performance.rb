#!/usr/bin/env ruby
require 'rubygems'
require 'gruff'

classes = {
  'Hash'          => 'Hash',
  'SparseHashMap' => 'SparseHashMap',
  'DenseHashMap'  => 'DenseHashMap',
  'SLT::Map'      => 'Map',
  'GNU::HashMap'  => 'HashMap',
}

$rnums = {}
min = '10000'
max = '10000000'

(max.length - min.length).times do |i|
  $rnums[i] = min + '0' * i
end

tdata = {}
mdata = {}

classes.each do |name, c|
  ts = []
  ms = []

  $rnums.values.each do |rnum|
    wd = File.expand_path(File.dirname(__FILE__))
    t, m = (`ruby #{wd}/performance0.rb #{c} #{rnum}`).split(',')
    ts << t.to_f
    ms << m.to_f
  end

  tdata[name] = ts
  mdata[name] = ms
end

def draw(title, data, y_axis_label, filename)
  g = Gruff::Bar.new 350
  g.theme_pastel
  g.title = title

  data.each do |name, ds|
    g.data(name, ds)
  end

  g.labels = $rnums
  g.x_axis_label = 'number of keys'
  g.y_axis_label = y_axis_label

  g.write(filename)
end

draw('Time', tdata, 'sec', 'time.png')
draw('Memory', mdata, 'MB', 'memory.png')
