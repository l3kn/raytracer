require "../aabb"
require "../hitable"
require "../eisemann"

class BVHNode < FiniteHitable
  getter left : FiniteHitable
  getter right : FiniteHitable
  getter bounding_box : AABB

  @@hit_both = 0_u32
  @@hit_one = 0_u32
  @@hit_overall = 0_u32

  def initialize(list : Array(FiniteHitable))
    raise "Error, trying to construct an empty BVHNode" if list.empty?

    n = list.size
    if n == 1
      # This should never happen
      @left = @right = list[0]
    elsif n == 2
      @left = list[0]
      @right = list[1]
    else
      # Split on the axis where the range of centroids is the largest
      centroids = list.map { |obj| obj.bounding_box.centroid }

      min = centroids.reduce(Point.new(Float64::MAX)) { |centroid, min| centroid.min(min) }
      max = centroids.reduce(Point.new(-Float64::MAX)) { |centroid, max| centroid.max(max) }
      delta = max - min

      if delta.x >= delta.y && delta.x >= delta.z
        axis = 0
      elsif delta.y >= delta.x && delta.y >= delta.z
        axis = 1
      else
        axis = 2
      end

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

  def hit(ray : Ray, t_min, t_max)
    # Perform precomputations for the Eisemann intersection test
    # hit(ExtendedRay.new(ray), t_min, t_max)
    if @bounding_box.hit(ray)
      @@hit_overall += 1

      hit_left = @left.hit(ray, t_min, t_max)
      hit_right = @right.hit(ray, t_min, t_max)

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

  def hit(ray : ExtendedRay, t_min, t_max)
    if ray.hits_aabb?(@bounding_box)
      @@hit_overall += 1

      hit_left = @left.hit(ray, t_min, t_max)
      hit_right = @right.hit(ray, t_min, t_max)

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
