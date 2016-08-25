class Mandelbulb < Hitable
  property material : Material

  def initialize(@material)
  end

  def hit(ray, t_min, t_max)
    maximum_ray_steps = 1000
    total_distance = 0.0
    steps = 0

    point = ray.origin

    (0...maximum_ray_steps).each do |step|
      point = ray.point_at_parameter(total_distance)
      distance = distance_estimate(point)

      total_distance += distance

      return nil if total_distance >= t_max

      steps += 1
      break if distance < 0.01
    end

    step = 0.001
    x_dir = Vec3.new(step, 0.0, 0.0)
    y_dir = Vec3.new(0.0, step, 0.0)
    z_dir = Vec3.new(0.0, 0.0, step)

    normal = Vec3.new(distance_estimate(point + x_dir) - distance_estimate(point - x_dir),
                      distance_estimate(point + y_dir) - distance_estimate(point - y_dir),
                      distance_estimate(point + z_dir) - distance_estimate(point - z_dir)).normalize

    point += normal * 0.01 # TODO: find a better fix, without this reflected rays would hit the sphere again
    return HitRecord.new(total_distance, point, normal, @material, u: 0.0, v: 0.0)
  end

  # http://blog.hvidtfeldts.net/index.php/2011/09/distance-estimated-3d-fractals-v-the-mandelbulb-different-de-approximations/
  def distance_estimate(pos)
    power = 8

    z = pos.clone
    dr = 1.0
    r = 0.0

    (0..100).each do |i|
      r = z.length
      break if (r > 10.0)

      # convert to polar coordinates
      theta = Math.acos(z.z / r)
      phi = Math.atan2(z.y, z.x)

      # scale and rotate the point

      zr = r ** power
      theta = theta * power
      phi = phi * power

      # convert back to cartesian coordinates
      z = Vec3.new(Math.sin(theta) * Math.cos(phi),
                   Math.sin(phi) * Math.sin(theta),
                   Math.cos(theta))
      z += pos
    end

    0.5 * Math.log(r) * r / dr
  end

  def distance_estimate(pos)
    q = Vec3.new(pos.x.abs, pos.y.abs, pos.z.abs)
    max(q.z - 1.0, max(q.x * 0.866025 + pos.y * 0.5, -pos.y)-1.0*0.5)
  end

  def distance_estimate(z)
    a1 = Vec3.new( 1.0, 1.0, 1.0)
    a2 = Vec3.new(-1.0,-1.0, 1.0)
    a3 = Vec3.new( 1.0,-1.0,-1.0)
    a4 = Vec3.new(-1.0, 1.0,-1.0)
    scale = 2.0

    c = Vec3::ZERO
    n = 0
    dist = 0.0
    d = 0.0

    while n < 10
      c = a1
      dist = (z - a1).length

      d = (z-a2).length
      if d < dist
        c = a2
        dist = d
      end

      d = (z-a3).length
      if d < dist
        c = a3
        dist = d
      end

      d = (z-a4).length
      if d < dist
        c = a4
        dist = d
      end

      z = z*scale - c*(scale-1.0)
      n += 1
    end

    z.length * (scale ** (-n).to_f)
  end

  def distance_estimate(z)
    r = 0.0
    n = 0

    scale = 2.0
    while n < 10
      if z.x + z.y < 0
        buf = Vec3.new(-z.y, -z.x, z.z)
        z = buf
      end

      if z.x + z.z < 0
        buf = Vec3.new(-z.z, z.y, -z.x)
        z = buf
      end

      if z.y + z.z < 0
        buf = Vec3.new(z.x, -z.z, -z.y)
        z = buf
      end

      z = z*scale - Vec3.new(scale-1.0)
      n += 1
    end

    z.length * (scale ** (-n).to_f)
  end

  def bounding_box
    raise "Error, this feature is not supported yet"
  end
end

