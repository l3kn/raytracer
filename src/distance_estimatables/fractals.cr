module DE
  class Mandelbulb < DistanceEstimatable
    def initialize(@iterations = 10, @power = 8); end

    def distance_estimate(pos)
      z = pos
      dr = 1.0
      r = 0.0

      @iterations.times do
        r = z.length
        break if r > 1000.0

        theta = Math.acos(z.z / r)
        phi = Math.atan2(z.y, z.x)

        dr = (r ** (@power - 1)) * @power * dr + 1.0

        zr = r ** @power
        theta = theta*@power
        phi = phi*@power

        sin_theta = Math.sin(theta)

        z = Point.new(
          sin_theta * Math.cos(phi) * zr + pos.x,
          sin_theta * Math.sin(phi) * zr + pos.y,
          Math.cos(theta) * zr + pos.z
        )
      end

      0.5 * Math.log(r) * r / dr
    end
  end

  class MengerSponge < DE::DistanceEstimatable
    property iterations : Int32
    property scale : Float64
    property offset : Vector
    property transformation : Transformation

    def initialize(@iterations = 4, @scale = 3.0, @offset = Vector.one, @transformation = Transformation::ID)
    end

    def distance_estimate(pos)
      @iterations.times do
        pos = @transformation.world_to_object(pos)
        pos = pos.abs

        pos = pos.yxz if pos.x < pos.y
        pos = pos.xzy if pos.y < pos.z
        pos = pos.yxz if pos.x < pos.y

        pos = pos * @scale - @offset * (@scale - 1.0)
        pos = Point.new(pos.xy, pos.z + @offset.z * (@scale - 1.0)) if pos.z < -0.5 * @offset.z * (@scale - 1.0)
      end

      pos.length * (@scale ** (-@iterations))
    end
  end
end
