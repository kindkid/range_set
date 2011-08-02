require File.dirname(__FILE__) + '/../spec_helper'

describe RangeSet do
  before(:each) do
    @rs = RangeSet.new(0..10)
  end

  it "can be initialized with a range" do
    @rs.ranges.should == [(0..10)]
  end

  it "can be initialized with a backwards range" do
    @rs = RangeSet.new(10..0)
    @rs.ranges.should == [(0..10)]
  end
  
  it "can be initialized with multiple ranges" do
    @rs = RangeSet.new(1..2, 99..100)
    @rs.ranges.should == [(1..2),(99..100)]
  end

  describe ".union" do
    it "handles a contiguous range" do
      @rs += 10..20
      @rs.ranges.should == [(0..20)]
    end

    it "handles an overlapping range" do
      @rs += 5..15
      @rs.ranges.should == [(0..15)]
    end

    it "handles a non-contiguous range in back" do
      @rs += 20..30
      @rs.ranges.should == [(0..10), (20..30)]
    end

    it "handles a non-contiguous range in front" do
      @rs += -10..-5
      @rs.ranges.should == [(-10..-5), (0..10)]
    end

    it "handles this funky case" do
      @rs = RangeSet.new(7..8, 9..10)
      @rs += 5..6
      @rs.ranges.should == [(5..6), (7..8), (9..10)]
    end

    it "merges internal ranges as needed" do
      @rs = RangeSet.new(0..10, 20..30)
      @rs += 10..20
      @rs.ranges.should == [(0..30)]
    end

    it "handles reversed ranges" do
      @rs += 20..10
      @rs.ranges.should == [(0..20)]
    end

    it "handles a RangeSet" do
      @rs += RangeSet.new(5..15, 25..30)
      @rs.ranges.should == [(0..15), (25..30)]
    end
  end

  describe ".subtract" do
    it "can shorten a range" do
      @rs -= 0..5
      @rs.ranges.should == [(5..10)]
    end

    it "can remove a range and shorten others at the same time" do
      @rs = RangeSet.new(0..10, 20..30, 40..50)
      @rs -= 5..45
      @rs.ranges.should == [(0..5),(45..50)]
    end

    it "handles a contained range" do
      @rs -= 3..8
      @rs.ranges.should == [(0..3),(8..10)]
    end

    it "handles a containing range" do
      @rs -= -1..10
      @rs.ranges.should == []
    end

    it "handles an empty range" do
      @rs -= 5..5
      @rs.ranges.should == [(0..10)]
    end

    it "handles a missing range" do
      @rs = RangeSet.new(0..10, 20..30)
      @rs -= 12..18
      @rs.ranges.should == [(0..10),(20..30)]
    end

    it "handles a border-case missing range" do
      @rs = RangeSet.new(0..10, 20..30)
      @rs -= 10..20
      @rs.ranges.should == [(0..10),(20..30)]
    end

    it "handles a RangeSet" do
      @rs = RangeSet.new(0..10, 20..30)
      @rs -= RangeSet.new(0..5, 8..21)
      @rs.ranges.should == [(5..8), (21..30)]
    end
  end

  describe ".intersect" do
    it "handles overlapping ranges" do
      @rs &= 5..15
      @rs.ranges.should == [(5..10)]
    end

    it "handles multiple overlaps" do
      @rs = RangeSet.new(0..10, 20..30, 40..50)
      @rs &= 5..45
      @rs.ranges.should == [(5..10), (20..30), (40..45)]
    end

    it "handles contained ranges" do
      @rs &= 3..8
      @rs.ranges.should == [(3..8)]
    end

    it "handles containing ranges" do
      @rs &= -1..11
      @rs.ranges.should == [(0..10)]
    end

    it "handles empty ranges" do
      @rs &= 20..20
      @rs.ranges.should == []
    end

    it "handles reversed ranges" do
      @rs &= 15..5
      @rs.ranges.should == [(5..10)]
    end

    it "handles a RangeSet" do
      @rs = RangeSet.new(0..10, 20..30, 40..50)
      @rs &= RangeSet.new(5..25, 35..55)
      @rs.ranges.should == [(5..10), (20..25), (40..50)]
    end
  end

  describe ".empty?" do
    it "returns true for an empty range" do
      RangeSet.new(1..1).empty?.should be_true
    end

    it "returns false for a non-empty range" do
      RangeSet.new(1..2).empty?.should_not be_true
    end

    it "returns false for multiple ranges" do
      RangeSet.new(-2..-1, 1..2).empty?.should_not be_true
    end
  end

  describe ".include?" do
    it "handles ranges" do
      rs = RangeSet.new(1..3,4..6,7..9)
      rs.include?(1..3).should == true
      rs.include?(1..2).should == true
      rs.include?(2..2).should == true
      rs.include?(3..4).should == false
      rs.include?(1..4).should == false
      rs.include?(10..11).should == false
    end

    it "handles RangeSets" do
      rs = RangeSet.new(1..3,4..6,7..9)
      rs.include?(RangeSet.new(1..3)).should == true
      rs.include?(rs).should == true
      rs.include?(RangeSet.new(1..1)).should == true
      rs.include?(RangeSet.new(1..3,4..6)).should == true
      rs.include?(RangeSet.new(1..3,4..6,10..12)).should == false
      rs.include?(RangeSet.new(1..2,5..6)).should == true
    end

    it "handles scalars" do
      rs = RangeSet.new(1..3,4..6,7..9)
      rs.include?(0).should be_false
      rs.include?(1).should be_true
      rs.include?(2).should be_true
      rs.include?(3).should be_false
      rs.include?(4).should be_true
      rs.include?(9).should be_false
      rs.include?(10).should be_false
    end
  end
end
