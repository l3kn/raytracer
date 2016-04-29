# Bounding volume hierarchy

class BVHNode < Hitable
  getter left, right, bounding_box

  def initialize(list)
    axis = rand(0.0...3.0).to_i
    sorted = list.sort_by { |h| h.box_min_on_axis(axis) }

    n = sorted.size
    if n == 1
      @left = @right = sorted[0]
    elsif n == 2
      @left = sorted[0]
      @right = sorted[1]
    else
      half = n / 2
      @left = BVHNode.new(sorted[0...half])
      @right = BVHNode.new(sorted[half..-1])
    end

    @bounding_box = @left.bounding_box.merge(@right.bounding_box)
  end

  def hit(ray, t_min, t_max)
    if @bounding_box.hit(ray, t_min, t_max)
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
    end
  end
end
