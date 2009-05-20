#!/usr/bin/env ruby
require 'test/unit'
require 'sparsehash'

class TC_Set < Test::Unit::TestCase
  def setup
    @sets = [
      Sparsehash::SparseHashSet,
      Sparsehash::DenseHashSet,
      STL::Set,
    ].map {|c| c.new }

    @sets << GNU::HashSet.new if defined?(GNU)
  end

  # def teardown
  # end

  def test_empty
    @sets.each do |s|
      assert(s.empty?, "#{__LINE__}:#{s}")
      assert_equal(s, (s << 'bar'), "#{__LINE__}:#{s}")
      assert(!s.empty?, "#{__LINE__}:#{s}")
    end
  end

  def test_size
    @sets.each do |s|
      assert_equal(0, s.size, "#{__LINE__}:#{s}")
      assert_equal(0, s.length, "#{__LINE__}:#{s}")
      assert_equal(s, (s << 'bar'), "#{__LINE__}:#{s}")
      assert_equal(1, s.size, "#{__LINE__}:#{s}")
      assert_equal(1, s.length, "#{__LINE__}:#{s}")
      assert_equal(s, (s << 'baz'), "#{__LINE__}:#{s}")
      assert_equal(2, s.size, "#{__LINE__}:#{s}")
      assert_equal(2, s.length, "#{__LINE__}:#{s}")
    end
  end

  def test_erase
    @sets.each do |s|
      s << 'bar'
      s << 'baz'
      assert_equal(2, s.size, "#{__LINE__}:#{s}")
      assert_equal(2, s.length, "#{__LINE__}:#{s}")
      assert_equal(s, s.erase('bar'), "#{__LINE__}:#{s}")
      assert_equal(1, s.size, "#{__LINE__}:#{s}")
      assert_equal(1, s.length, "#{__LINE__}:#{s}")
      assert_equal(s, s.delete('baz'), "#{__LINE__}:#{s}")
      assert_equal(0, s.size, "#{__LINE__}:#{s}")
      assert_equal(0, s.length, "#{__LINE__}:#{s}")
      assert_equal(s, s.erase('foo'), "#{__LINE__}:#{s}")
      assert_equal(s, s.delete('zoo'), "#{__LINE__}:#{s}")
    end
  end

  def test_add
    @sets.each do |s|
      assert_equal(s, (s << 'bar'), "#{__LINE__}:#{s}")
      assert_equal(s, (s << 'baz'), "#{__LINE__}:#{s}")
    end
  end

  def test_nil
    @sets.each do |s|
      force { s << nil }
      force { s.erase(nil) }
    end
  end

  def test_false
    @sets.each do |s|
      force { s << false }
      force { s.erase(false) }
    end
  end

  def test_each
    @sets.each do |s|
      vals = []
      s << 'bar'
      s << 'baz'

      s.each do |v|
        vals << v
      end

      assert_equal(['bar', 'baz'], vals.sort, "#{__LINE__}:#{s}")
    end
  end

  def test_clear
    @sets.each do |s|
      s << 'bar'
      s << 'baz'
      assert(!s.empty?, "#{__LINE__}:#{s}")
      s.clear
      assert(s.empty?, "#{__LINE__}:#{s}")
    end
  end

  private
  def force
    yield rescue nil
  end
end
