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

  class MengerSponge < DistanceEstimatable
    def initialize(@iterations = 10)
      @box = DE::Box.new(Vec3.new(1.0))
    end

    def distance_estimate(pos)
      pos *= 0.5
      pos += Vec3.new(0.5)

      x = pos.x
      y = pos.y
      z = pos.z

      xx = (x - 0.5).abs - 0.5
      yy = (y - 0.5).abs - 0.5
      zz = (z - 0.5).abs - 0.5

      d1 = max(xx, max(yy, zz))
      d = d1
      p = 1.0

      @iterations.times do
        xa = (3.0 * x * p) % 3.0
        ya = (3.0 * y * p) % 3.0
        za = (3.0 * z * p) % 3.0

        p *= 3.0

        xx = 0.5 - (xa - 1.5).abs
        yy = 0.5 - (ya - 1.5).abs
        zz = 0.5 - (za - 1.5).abs

        d1 = min(max(xx, zz), min(max(xx, yy), max(yy, zz))) / p
        d = max(d, d1)
      end

      return d
    end

    def cross(pos)
      da = max(pos.x.abs, pos.y.abs)
      db = max(pos.y.abs, pos.z.abs)
      dc = max(pos.z.abs, pos.x.abs)

      min(da, min(db, dc)) - 1.0
    end
  end
end
