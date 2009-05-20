#!/usr/bin/env ruby
require 'test/unit'
require 'sparsehash'

class TC_Map < Test::Unit::TestCase
  def setup
    @maps = [
      Sparsehash::SparseHashMap,
      Sparsehash::DenseHashMap,
      STL::Map,
    ].map {|c| c.new }

    @maps << GNU::HashMap.new if defined?(GNU)
  end

  # def teardown
  # end

  def test_empty
    @maps.each do |m|
      assert(m.empty?, "#{__LINE__}:#{m}")
      assert_equal('bar', (m['foo'] = 'bar'), "#{__LINE__}:#{m}")
      assert(!m.empty?, "#{__LINE__}:#{m}")
    end
  end

  def test_size
    @maps.each do |m|
      assert_equal(0, m.size, "#{__LINE__}:#{m}")
      assert_equal(0, m.length, "#{__LINE__}:#{m}")
      assert_equal('bar', (m['foo'] = 'bar'), "#{__LINE__}:#{m}")
      assert_equal(1, m.size, "#{__LINE__}:#{m}")
      assert_equal(1, m.length, "#{__LINE__}:#{m}")
      assert_equal('baz', (m['zoo'] = 'baz'), "#{__LINE__}:#{m}")
      assert_equal(2, m.size, "#{__LINE__}:#{m}")
      assert_equal(2, m.length, "#{__LINE__}:#{m}")
    end
  end

  def test_erase
    @maps.each do |m|
      m['foo'] = 'bar'
      m['zoo'] = 'baz'
      assert_equal(2, m.size, "#{__LINE__}:#{m}")
      assert_equal(2, m.length, "#{__LINE__}:#{m}")
      assert_equal('bar', m.erase('foo'), "#{__LINE__}:#{m}")
      assert_equal(1, m.size, "#{__LINE__}:#{m}")
      assert_equal(1, m.length, "#{__LINE__}:#{m}")
      assert_equal('baz', m.delete('zoo'), "#{__LINE__}:#{m}")
      assert_equal(0, m.size, "#{__LINE__}:#{m}")
      assert_equal(0, m.length, "#{__LINE__}:#{m}")
      assert_nil(m.erase('foo'), "#{__LINE__}:#{m}")
      assert_nil(m.delete('zoo'), "#{__LINE__}:#{m}")
    end
  end

  def test_set_get
    @maps.each do |m|
      assert_equal('bar', (m['foo'] = 'bar'), "#{__LINE__}:#{m}")
      assert_equal('baz', (m['zoo'] = 'baz'), "#{__LINE__}:#{m}")
      assert_equal('bar', m['foo'], "#{__LINE__}:#{m}")
      assert_equal('baz', m['zoo'], "#{__LINE__}:#{m}")
    end
  end

  def test_nil
    @maps.each do |m|
      force { m[nil] = '' }
      force { m[nil] }
      force { m.erase(nil) }
    end
  end

  def test_false
    @maps.each do |m|
      force { m[false] = '' }
      force { m[false] }
      force { m.erase(false) }
    end
  end

  def test_each
    @maps.each do |m|
      keys = []
      vals = []
      m['foo'] = 'bar'
      m['zoo'] = 'baz'

      m.each do |k, v|
        keys << k
        vals << v
      end

      assert_equal(['foo', 'zoo'], keys.sort, "#{__LINE__}:#{m}")
      assert_equal(['bar', 'baz'], vals.sort, "#{__LINE__}:#{m}")
    end
  end

  def test_clear
    @maps.each do |m|
      m['foo'] = 'bar'
      m['zoo'] = 'baz'
      assert(!m.empty?, "#{__LINE__}:#{m}")
      m.clear
      assert(m.empty?, "#{__LINE__}:#{m}")
    end
  end

  private
  def force
    yield rescue nil
  end
end
