require "../aabb"
require "../hitables/bvh"

class BucketInfo
  property count : Int32
  property bounds : AABB

  def initialize
    @count = 0
    @bounds = AABB.new(Point.new(Float64::MAX), Point.new(-Float64::MAX))
  end
end

# A special kind of BVH,
# trying to minimize the overlap of the left and right bounding boxes.
# Construction takes longer but the resulting BVH is (probably) faster
class SAHBVHNode < BVHNode
  BUCKETS = 12

  def initialize(list)
    n = list.size
    assert(n > 1, "BVHNode should have at least 2 elements")

    if n == 2
      @left, @right = list[0], list[1]
    else
      centroids = list.map { |obj| obj.bounding_box.centroid }
      bb = AABB.from_points(centroids)
      min, max = bb.min, bb.max
      axis = (max - min).max_axis
      buckets = Array.new(BUCKETS) { BucketInfo.new }

      # Generate buckets
      sorted = list.sort_by { |h| h.bounding_box.centroid[axis] }
      sorted.each do |object|
        b = (BUCKETS * (object.bounding_box.centroid[axis] - min[axis]) / (max[axis] - min[axis])).to_i
        b = BUCKETS - 1 if b == BUCKETS

        buckets[b].count += 1
        if buckets[b].count == 1
          buckets[b].bounds = object.bounding_box
        else
          buckets[b].bounds = buckets[b].bounds.merge(object.bounding_box)
        end
      end

      cost = Array.new(BUCKETS - 1, 0.0)

      # Rate buckets
      (0...(BUCKETS - 1)).each do |i|
        count0 = 0
        count1 = 1

        b0 = buckets[0].bounds
        (0..i).each do |j|
          b0 = b0.merge(buckets[j].bounds)
          count0 += buckets[j].count
        end

        b1 = buckets[i + 1].bounds
        ((i + 1)...BUCKETS).each do |j|
          b1 = b1.merge(buckets[j].bounds)
          count1 += buckets[j].count
        end

        # TODO: is using bb.area here correct?
        cost[i] = 0.125 + (count0*b0.area + count1*b1.area) / bb.area
      end

      min_cost = cost[0]
      min_cost_split = 0

      # Find best split
      cost.each_with_index do |c, index|
        if c < min_cost
          min_cost = c
          min_cost_split = index
        end
      end

      left_ = [] of FiniteHitable
      right_ = [] of FiniteHitable

      # Perform split
      sorted.each do |obj|
        b = (BUCKETS * (obj.bounding_box.centroid[axis] - min[axis]) / (max[axis] - min[axis])).to_i
        b = BUCKETS - 1 if b == BUCKETS

        b <= min_cost_split ? left_ << obj : right_ << obj
      end

      @left = left_.size == 1 ? left_[0] : SAHBVHNode.new(left_)
      @right = right_.size == 1 ? right_[0] : SAHBVHNode.new(right_)
    end
    @bounding_box = @left.bounding_box.merge(@right.bounding_box)
  end
end
