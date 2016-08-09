# Bounding volume hierarchy

class BVHNode < Hitable
  getter left : Hitable
  getter right : Hitable
  getter bounding_box : AABB

  def initialize(list, axis = 0)
    sorted = list.sort_by { |h| h.box_min_on_axis(axis) }

    n = sorted.size

    if n == 1
      @left = @right = sorted[0]
    elsif n == 2
      @left = sorted[0]
      @right = sorted[1]
    else
      half = n / 2
      @left = BVHNode.new(sorted[0...half], (axis + 1) % 3)
      @right = BVHNode.new(sorted[half..-1], (axis + 1) % 3)
    end

    @bounding_box = @left.bounding_box.merge(@right.bounding_box)
  end

  def hit(ray, t_min, t_max)
    if @bounding_box.hit(ray)
      hit_left = @left.hit(ray, t_min, t_max)
      hit_right = @right.hit(ray, t_min, t_max)

      if (hit_left && hit_right)
        if hit_left.t < hit_right.t
          return hit_left
        else
          return hit_right
        end
      elsif hit_left
        return hit_left
      elsif hit_right
        return hit_right
      else
        return nil
      end
    else
      return nil
    end
  end
end
