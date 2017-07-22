require "../aabb"
require "../hitable"

class Hitable::BVHNode < BoundedHitable
  getter left : BoundedHitable, right : BoundedHitable
  getter bounding_box : AABB

  @@hit_both = 0_u32
  @@hit_one = 0_u32
  @@hit_overall = 0_u32

  def initialize(list : Array(BoundedHitable))
    n = list.size
    assert(n > 1, "BVHNode should have at least 2 elements")

    if n == 2
      @left, @right = list[0], list[1]
    else
      # Split on the axis where the range of centroids is the largest
      centroids = list.map { |obj| obj.bounding_box.centroid }
      bb = AABB.from_points(centroids)
      axis = bb.diagonal.max_axis

      sorted = list.sort_by { |h| h.bounding_box.centroid[axis] }
      half = n / 2

      # Handle the case where n = 3
      if half == 1
        @left = sorted[0]
      else
        @left = BVHNode.new(sorted[0...half])
      end
      @right = BVHNode.new(sorted[half..-1])
    end

    @bounding_box = @left.bounding_box.merge(@right.bounding_box)
  end

  def hit(ray)
    if @bounding_box.fast_hit(ray)
      @@hit_overall += 1

      hit_left = @left.hit(ray)
      hit_right = @right.hit(ray)

      if hit_left && hit_right
        @@hit_both += 1
        hit_left.t < hit_right.t ? hit_left : hit_right
      else
        @@hit_one += 1
        hit_left || hit_right
      end
    else
      nil
    end
  end

  def benchmark
    "\noverall: #{@@hit_overall}\nboth: #{@@hit_both}\none: #{@@hit_one}"
  end
end
