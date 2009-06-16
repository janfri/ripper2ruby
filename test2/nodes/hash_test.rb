require File.dirname(__FILE__) + '/../test_helper'

class HashTest < Test::Unit::TestCase
  include TestHelper
  
  def hash(src)
    build(src).first
  end

  define_method :'test a hash: { :foo => :bar }' do
    src = '{ :foo => :bar }'
    hash = hash(src)
  
    assert_equal Ruby::Hash, hash.class
    assert_equal src, hash.to_ruby
    assert_equal src, hash.src
    assert_equal({ :foo => :bar }, hash.value)
  end
  
  # define_method :'test a bare hash: t(:foo => :bar)' do
  #   src = 't(:a => :a, :b => :b)'
  #   hash = call(src).arguments.first
  # 
  #   assert_equal Ruby::Hash, hash.class
  #   assert_equal :a, hash.assocs[0].key.value
  #   assert_equal :a, hash.assocs[0].value.value
  # 
  #   assert hash.root.is_a?(Ruby::Program)
  #   assert_equal hash, hash.first.parent
  #   assert_equal hash.first, hash.first.key.parent
  #   assert_equal hash.first, hash.first.value.parent
  # 
  #   assert_equal src, hash.root.src
  #   assert_equal src, hash.first.root.src
  #   assert_equal src, hash.first.key.root.src
  #   assert_equal src, hash.first.value.root.src
  # 
  #   assert_equal ':a => :a, :b => :b', hash.to_ruby
  # 
  #   assert_equal [0, 2], hash.position
  #   assert_equal 0, hash.row
  #   assert_equal 2, hash.column
  #   assert_equal 18, hash.length
  # end
  
  # define_method :'test hash assignment' do
  #   src = "foo[:bar] = :baz"
  #   assert_equal src, build(src).statements.first.to_ruby
  # end
  
  define_method :'test hash length: with and without whitespace' do
    assert_equal 22, hash("  {:a=>:a,:b=>:b,:c=>:c}").length
    assert_equal 30, hash("  {:a => :a, :b => :b, :c => :c}").length
    assert_equal 30, hash("  { :a=>:a ,  :b=>:b  , :c=>:c }").length
    assert_equal 32, hash("  { :a => :a, :b => :b, :c => :c }").length
    assert_equal 34, hash("  { :a => :a, :b => :b, :c => :c }").length(true)
  end
  
  # define_method :'test bare hash length: with and without whitespace' do
  #   assert_equal 20, call("  t(:a=>:a,:b=>:b,:c=>:c)").arguments.first.length
  #   assert_equal 28, call("  t(:a => :a, :b => :b, :c => :c)").arguments.first.length
  #   assert_equal 26, call("  t( :a=>:a ,  :b=>:b  , :c=>:c )").arguments.first.length
  #   assert_equal 28, call("  t( :a => :a, :b => :b, :c => :c )").arguments.first.length
  #   assert_equal 29, call("  t( :a => :a, :b => :b, :c => :c )").arguments.first.length(true)
  # end
  
  define_method :'test hash assoc length: with and without whitespace' do
    hash = hash("  { :a  =>   :b  ,  :c=>:d,:e  => :f }")
    assocs = hash.assocs
    separators = hash.separators
  
    assert_whitespace(assocs[0].key, ' ', 2)
    assert_whitespace(assocs[0].value, '   ', 2)
    assert_whitespace(assocs[0].operator, '  ', 2)
  
    assert_whitespace(assocs[1].key, '  ', 2)
    assert_whitespace(assocs[1].value, '', 2)
    assert_whitespace(assocs[1].operator, '', 2)
  
    assert_whitespace(assocs[2].key, '', 2)
    assert_whitespace(assocs[2].value, ' ', 2)
    assert_whitespace(assocs[2].operator, '  ', 2)
  
    assert_equal 11, assocs[0].length
    assert_equal 12, assocs[0].length(true)
    assert_equal 6,  assocs[1].length
    assert_equal 8,  assocs[1].length(true)
    assert_equal 9,  assocs[2].length
    assert_equal 9,  assocs[2].length(true)
                     
    assert_equal 1,  separators[0].length
    assert_equal 3,  separators[0].length(true)
    assert_equal 1,  separators[1].length
    assert_equal 1,  separators[1].length(true)
  end
  
  def assert_whitespace(node, whitespace, length)
    assert_equal whitespace, node.whitespace
    assert_equal length, node.length
    assert_equal length + whitespace.length, node.length(true)
  end
end