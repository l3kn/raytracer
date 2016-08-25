require "../aabb"
require "../hitable"

class BVHNode < Hitable
  getter left : Hitable
  getter right : Hitable
  getter bounding_box : AABB

  def initialize(list)
    n = list.size

    if n == 2
      @left = list[0]
      @right = list[1]
    else
      # Split on the axis where the range of centroids is the largest
      centroids = list.map { |obj| obj.bounding_box.centroid }

      min_x, max_x = centroids.minmax_by(&.x)
      min_y, max_y = centroids.minmax_by(&.y)
      min_z, max_z = centroids.minmax_by(&.z)

      delta_x = max_x.x - min_x.x
      delta_y = max_y.y - min_y.y
      delta_z = max_z.z - min_z.z

      if delta_y > delta_x 
        if delta_z > delta_y
          axis = 2
        else
          axis = 1
        end
      else
        if delta_z > delta_x
          axis = 2
        else
          axis = 0
        end
      end

      sorted = list.sort_by { |h| h.bounding_box.centroid.xyz[axis] }
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

  def hit(ray, t_min, t_max)
    if @bounding_box.hit(ray)
      hit_left = @left.hit(ray, t_min, t_max)
      hit_right = @right.hit(ray, t_min, t_max)

      if (hit_left && hit_right)
        (hit_left.t < hit_right.t) ? hit_left : hit_right
      elsif hit_left
        hit_left
      elsif hit_right
        hit_right
      else
        nil
      end
    else
      nil
    end
  end
end
