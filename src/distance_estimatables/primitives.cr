module DE
  class Sphere < DistanceEstimatable
    def initialize(@radius : Float64); end

    def distance_estimate(pos)
      pos.length - @radius
    end
  end

  class Box < DistanceEstimatable
    def initialize(@dimensions : Point, @radius = 0.0); end

    def distance_estimate(pos)
      (pos.abs - @dimensions).max(0.0).length - @radius
    end
  end

  class Torus < DistanceEstimatable
    def initialize(@radius : Float64, @width : Float64); end

    def distance_estimate(pos)
      qx = Math.sqrt(pos.x * pos.x + pos.z * pos.z) - @radius
      qy = pos.y

      Math.sqrt(qx * qx + qy * qy) - @width
    end
  end

  class Prism < DistanceEstimatable
    def initialize(@height : Float64, @length : Float64); end

    def distance_estimate(pos)
      q = pos.abs
      max(q.z - @length, max(q.x*0.866025 + pos.y*0.5, -pos.y) - @height*0.5)
    end
  end

  class Cylinder < DistanceEstimatable
    def initialize(@radius : Float64, @length : Float64); end

    def distance_estimate(pos)
      dx = Math.sqrt(pos.x * pos.x + pos.z * pos.z).abs - @radius
      dy = pos.y.abs - @length

      max_dx = max(dx, 0.0)
      max_dy = max(dy, 0.0)

      min(max(dx, dy), 0.0) + Math.sqrt(max_dx * max_dx + max_dy * max_dy)
    end
  end

  class Plane < DistanceEstimatable
    def initialize(@normal : Normal, @w : Float64); end

    def distance_estimate(pos)
      pos.dot(@normal) + @w
    end
  end
end
