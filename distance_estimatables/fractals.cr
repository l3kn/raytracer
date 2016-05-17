require "../distance_estimatable"

module DE
  class Mandelbulb < DistanceEstimatable
    def initialize(@iterations = 10, @power = 8)
    end

    def distance_estimate(pos)
      z = pos.clone
      dr = 1.0
      r = 0.0

      @iterations.times do
        r = z.length

        break if r > 1000.0

        theta = Math.acos(z.z / r)
        phi = Math.atan2(z.y, z.x)

        dr = (r ** (@power-1)) * @power * dr + 1.0

        zr = r ** @power
        theta = theta*@power
        phi = phi*@power

        z = Vec3.new(Math.sin(theta) * Math.cos(phi),
                     Math.sin(theta) * Math.sin(phi),
                     Math.cos(theta)) * zr
        z += pos
      end

      0.5 * Math.log(r) * r / dr
    end
  end
end
