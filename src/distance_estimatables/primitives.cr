require "../distance_estimatable"
require "../vector"

module DE
  class Sphere < DistanceEstimatable
    property radius : Float64

    def initialize(@radius)
    end

    def distance_estimate(pos)
      pos.length - @radius
    end
  end

  class Box < DistanceEstimatable
    property dimensions : Vec3

    def initialize(@dimensions, @radius = 0.0)
    end

    def distance_estimate(pos)
      (pos.abs - @dimensions).max(0.0).length - @radius
    end
  end

  class Torus < DistanceEstimatable
    property radius : Float64
    property width : Float64

    def initialize(@radius, @width)
    end

    def distance_estimate(pos)
      qx = Math.sqrt(pos.x * pos.x + pos.z * pos.z) - radius
      qy = pos.y

      Math.sqrt(qx * qx + qy * qy) - width
    end
  end

  class Prism < DistanceEstimatable
    property height : Float64
    property length : Float64

    def initialize(@height, @length)
    end

    def distance_estimate(pos)
      q = pos.abs
      max(q.z - @length, max(q.x*0.866025 + pos.y*0.5, -pos.y) - @height*0.5)
    end
  end

  class Cylinder < DistanceEstimatable
    property radius : Float64
    property length : Float64

    def initialize(@radius, @length)
    end

    def distance_estimate(pos)
      dx = Math.sqrt(pos.x * pos.x + pos.z * pos.z).abs - @radius
      dy = pos.y.abs - @length

      max_dx = max(dx, 0.0)
      max_dy = max(dy, 0.0)

      min(max(dx, dy), 0.0) + Math.sqrt(max_dx * max_dx + max_dy * max_dy)
    end
  end

  class Plane < DistanceEstimatable
    property normal : Vec3
    property w : Float64

    def initialize(@normal, @w)
    end

    def distance_estimate(pos)
      pos.dot(@normal) + @w
    end
  end
end
