class RangeSet
  attr_accessor :ranges

  def initialize(*ranges)
    @ranges = []
    ranges.each do |r|
      union_with_range!(r)
    end
    self
  end
  
  def intersect!(r)
    if r.is_a?(Range)
      intersect_with_range!(r)
    elsif r.is_a?(RangeSet)
      @ranges = r.ranges.inject(RangeSet.new) do |accum, range|
        accum + (self & range)
      end.ranges
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
      r.each {|r| subtract_range!(r)}
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
      r.each {|r| union_with_range!(r)}
    end
    self
  end
  
  def union(r)
    self.clone.union!(r)
  end
  
  def each
    @ranges.each {|r| yield r}
  end
  
  #returns an array of RangeSets
  def split_at(*boundaries)
    result = []
    rs = RangeSet.new
    ranges = @ranges.clone
    boundaries.compact.sort.uniq.each do |boundary|
      
      while (range = ranges.shift)
        if range.end <= boundary
          rs += range
        elsif range.begin >= boundary
          ranges.unshift(range)
          break
        else
          rs += (range.begin .. boundary)
          ranges.unshift(boundary .. range.end)
          break
        end
      end
      
      unless rs.empty?
        result << rs
        rs = RangeSet.new
      end
    end
    result << RangeSet.new(*ranges) unless ranges.empty?
    result
  end
  
  # TODO : need to be more explicit and careful about
  # whether or not a range's end is inclusive. For now,
  # we just assume that it's NOT inclusive.
  def include?(v)
    if v.is_a?(Range)
      each do |range|
        return true if range.begin <= v.begin && v.begin <= v.end && v.end <= range.end
      end
    elsif v.is_a?(RangeSet)
      v.ranges.each do |range|
        return false unless self.include?(range)
      end
      return true
    else
      each do |range|
        return true if range.begin <= v && v < range.end
      end
    end
    false
  end
  
  def empty?
    @ranges.empty?
  end
  
  alias :- :subtract
  alias :| :union
  alias :+ :union
  alias :& :intersect
  
  private
  
  def subtract_range!(r)
    return if r.begin == r.end
    r = (r.end .. r.begin) unless r.begin < r.end
    result = []
    each do |range|
      if range.end < r.begin
        result << range
      elsif range.begin > r.end
        result << range
      else
        result << (range.begin .. r.begin) if range.begin < r.begin
        result << (r.end .. range.end) if range.end > r.end
      end
    end
    @ranges = result
  end
  
  def intersect_with_range!(r)
    if r.begin == r.end
      @ranges = []
      return
    elsif r.begin > r.end
      r = (r.end .. r.begin)
    end
    result = []
    each do |range|
      r2 = ([range.begin, r.begin].max .. [range.end, r.end].min)
      if (r2.begin < r2.end)
        result << r2
      end
    end
    @ranges = result    
  end
  
  def union_with_range!(r)
    return if r.begin == r.end
    joined = (r.begin < r.end) ? r : (r.end .. r.begin)
    still_need_joined = true
    result = []
    each do |range|
      if range.end < joined.begin
        result << range
      elsif range.end == joined.begin
        joined = (range.begin .. joined.end)
      elsif range.begin > joined.end
        result << joined if still_need_joined
        still_need_joined = false
        result << range
      else
        joined = ([range.begin,joined.begin].min .. [range.end,joined.end].max)
      end
    end
    result << joined if still_need_joined
    @ranges = result
  end
end