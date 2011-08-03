require 'rbtree'

class RangeSet

  def ranges
    @rbtree.values
  end

  def initialize(*ranges)
    @rbtree = RBTree.new
    ranges.each do |r|
      union_with_range!(r)
    end
    self
  end

  def clone
    result = super
    result.send(:rbtree=, result.send(:rbtree).clone)
    result
  end
  
  def intersect!(r)
    if r.is_a?(Range)
      intersect_with_range!(r)
    elsif r.is_a?(RangeSet)
      intersect_with_rangeset!(r)
    end
    self
  end
  
  def intersect(r)
    self.clone.intersect!(r)
  end
  
  def subtract!(r)
    if r.is_a?(Range)
      subtract_range!(r)
    elsif r.is_a?(RangeSet)
      subtract_rangeset!(r)
    end
    self
  end
  
  def subtract(r)
    self.clone.subtract!(r)
  end
  
  def union!(r)
    if r.is_a?(Range)
      union_with_range!(r)
    elsif r.is_a?(RangeSet)
      union_with_rangeset!(r)
    end
    self
  end
  
  def union(r)
    self.clone.union!(r)
  end
  
  def each
    @rbtree.each_value {|r| yield r}
  end
  
  # #returns an array of RangeSets
  # def split_at(*boundaries)
  #   result = []
  #   rs = RangeSet.new
  #   ranges = @rbtree.clone
  #   boundaries.compact.sort.uniq.each do |boundary|
  #     while (range = ranges.shift)
  #       if range.end <= boundary
  #         rs += range
  #       elsif range.begin >= boundary
  #         ranges.unshift(range)
  #         break
  #       else
  #         rs += (range.begin .. boundary)
  #         ranges.unshift(boundary .. range.end)
  #         break
  #       end
  #     end
  #     unless rs.empty?
  #       result << rs
  #       rs = RangeSet.new
  #     end
  #   end
  #   result << RangeSet.new(*ranges) unless ranges.empty?
  #   result
  # end
  
  # TODO : need to be more explicit and careful about
  # whether or not a range's end is inclusive. For now,
  # we just assume that it's NOT inclusive.
  def include?(v)
    case v
    when Range
      include_range?(v)
    when RangeSet
      include_rangeset?(v)
    else
      include_scalar?(v)
    end
  end
  
  def empty?
    @rbtree.empty?
  end
  
  alias :- :subtract
  alias :| :union
  alias :+ :union
  alias :& :intersect
  
  private

  attr_accessor :rbtree
  
  def subtract_range!(r)
    return if r.begin == r.end
    r = (r.end .. r.begin) unless r.begin < r.end
    x, previous_range = @rbtree.upper_bound(r.begin)
    @rbtree.bound([x,r.begin].compact.min, r.end).each do |key, range|
      @rbtree.delete(key)
      front_range = (range.begin .. [r.begin, range.end].min)
      back_range = ([range.begin,r.end].max .. range.end)
      @rbtree[front_range.begin] = front_range if front_range.begin < front_range.end
      @rbtree[back_range.begin] = back_range if back_range.begin < back_range.end
    end
  end

  def subtract_rangeset!(r)
    r.each do |range|
      subtract_range!(range)
    end
  end
  
  def intersect_with_range!(r)
    if r.begin == r.end
      @rbtree = RBTree.new
      return
    elsif r.begin > r.end
      r = (r.end .. r.begin)
    end
    replacement = RBTree.new
    x, previous_range = @rbtree.upper_bound(r.begin)
    @rbtree.bound([x,r.begin].compact.min, r.end) do |key, range|
      range = ([range.begin,r.begin].max .. [range.end,r.end].min)
      replacement[range.begin] = range if range.begin < range.end
    end
    @rbtree = replacement
  end

  def intersect_with_rangeset!(r)
    #TODO: This could be greatly optimized!
    replacement = RangeSet.new
    r.each do |range|
      replacement += self & range
    end
    @rbtree = replacement.send(:rbtree)
  end
  
  def union_with_range!(r)
    return if r.begin == r.end
    r = (r.begin < r.end) ? r : (r.end .. r.begin)
    @rbtree.bound(r.begin, r.end) do |key, range|
      range = @rbtree.delete(key)
      r = ([r.begin, range.begin].min .. [r.end, range.end].max)
    end
    x, previous_range = @rbtree.upper_bound(r.begin)
    if previous_range && previous_range.end >= r.begin
      @rbtree.delete(x)
      r = (x .. r.end)
    end
    @rbtree[r.begin] = r
  end

  def union_with_rangeset!(r)
    r.each do |range|
      union_with_range!(range)
    end
  end

  def include_scalar?(v)
    x, previous_range = @rbtree.upper_bound(v)
    previous_range && v < previous_range.end
  end

  def include_range?(r)
    x, previous_range = @rbtree.upper_bound(r.begin)
    previous_range && r.end <= previous_range.end
  end

  def include_rangeset?(r)
    r.each do |range|
      return false unless include_range?(range)
    end
    true
  end

end