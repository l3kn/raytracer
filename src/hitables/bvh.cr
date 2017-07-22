require "../aabb"
require "../hitable"

module Hitable
  # NOTE: This is used for AABB.fast_hit
  struct ExtendedRay
    getter inv_x : Float64, inv_y : Float64, inv_z : Float64
    getter pos_x : Bool, pos_y : Bool, pos_z : Bool
    getter t_min : Float64, t_max : Float64
    getter origin : Point
    getter direction : Vector

    def initialize(ray)
      @origin = ray.origin
      @direction = ray.direction
      @t_min = ray.t_min
      @t_max = ray.t_max

      @inv_x = 1.0 / direction.x
      @inv_y = 1.0 / direction.y
      @inv_z = 1.0 / direction.z

      @pos_x = @inv_x > 0.0
      @pos_y = @inv_y > 0.0
      @pos_z = @inv_z > 0.0
    end

    def point_at_parameter(t)
      @origin + (@direction * t)
    end
  end

  class BVHNode < BoundedHitable
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
end
