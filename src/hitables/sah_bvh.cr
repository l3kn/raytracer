require "../aabb"
require "../hitables/bvh"

class BucketInfo
  property count : Int32
  property bounds : AABB

  def initialize
    @count = 0
    @bounds = AABB.new(Vec3::ZERO, Vec3::ZERO)
  end
end

# A special kind of BVH,
# trying to minimize the overlap of the left and right bounding boxes.
# Construction takes longer but the resulting BVH is (probably) faster
class SAHBVHNode < BVHNode
  def initialize(list)
    n = list.size
    if n == 1
      # This should never happen
      @left = @right = list[0]
    elsif n == 2
      @left = list[0]
      @right = list[1]
    else
      centroids = list.map { |obj| obj.bounding_box.centroid }
      min = centroids.reduce(Vec3.new(Float64::MAX)) { |centroid, min| centroid.min(min) }
      max = centroids.reduce(Vec3.new(-Float64::MAX)) { |centroid, max| centroid.max(max) }
      delta = max - min

      if delta.x >= delta.y && delta.x >= delta.z
        axis = 0
      elsif delta.y >= delta.x && delta.y >= delta.z
        axis = 1
      else
        axis = 2
      end

      n_buckets = 12
      buckets = Array.new(n_buckets) { BucketInfo.new }

      # Generate buckets
      sorted = list.sort_by { |h| h.bounding_box.centroid[axis] }
      sorted.each do |object|
        b = (n_buckets * (object.bounding_box.centroid[axis] - min[axis]) / (max[axis] - min[axis])).to_i
        b = n_buckets - 1 if b == n_buckets

        buckets[b].count += 1
        if buckets[b].count == 1
          buckets[b].bounds = object.bounding_box
        else
          buckets[b].bounds = buckets[b].bounds.merge(object.bounding_box)
        end
      end

      cost = Array.new(n_buckets - 1, 0.0)

      # Rate buckets
      (0...(n_buckets - 1)).each do |i|
        count0 = 0
        count1 = 1

        b0 = buckets[0].bounds
        (0..i).each do |j|
          b0 = b0.merge(buckets[j].bounds)
          count0 += buckets[j].count
        end

        b1 = buckets[i+1].bounds
        ((i+1)...n_buckets).each do |j|
          b1 = b1.merge(buckets[j].bounds)
          count1 += buckets[j].count
        end

        cost[i] = 0.125 + (count0*area(b0.min, b0.max) + count1*area(b1.min, b1.max)) / area(min, max)
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
        b = (n_buckets * (obj.bounding_box.centroid[axis] - min[axis]) / (max[axis] - min[axis])).to_i
        b = n_buckets - 1 if b == n_buckets

        if b <= min_cost_split
          left_ << obj
        else
          right_ << obj
        end
      end

      if left_.size == 1
        @left = left_[0]
      else
        @left = SAHBVHNode.new(left_)
      end

      if right_.size == 1
        @right = right_[0]
      else
        @right = SAHBVHNode.new(right_)
      end
    end

    @bounding_box = @left.bounding_box.merge(@right.bounding_box)
  end

  def area(min, max)
    delta = max - min
    (delta.x * delta.y + delta.x * delta.z + delta.y * delta.z) * 2.0
  end
end
