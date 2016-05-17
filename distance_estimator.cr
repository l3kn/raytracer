class DistanceEstimator < Hitable
  property material : Material
  property object : DistanceEstimatable

  MAXIMUM_RAY_STEPS = 1000

  def initialize(@material, @object)
  end

  def hit(ray, t_min, t_max)
    total_distance = 0.0
    steps = 0

    point = ray.origin

    return nil if distance_estimate(point) <= t_min

    (0...MAXIMUM_RAY_STEPS).each do |step|
      point = ray.point_at_parameter(total_distance)
      distance = distance_estimate(point)
      total_distance += distance

      return nil if total_distance >= t_max

      steps += 1
      break if distance < 0.0001
    end

    step = 0.01
    x_dir = Vec3.new(step, 0.0, 0.0)
    y_dir = Vec3.new(0.0, step, 0.0)
    z_dir = Vec3.new(0.0, 0.0, step)

    normal = Vec3.new(distance_estimate(point + x_dir) - distance_estimate(point - x_dir),
                      distance_estimate(point + y_dir) - distance_estimate(point - y_dir),
                      distance_estimate(point + z_dir) - distance_estimate(point - z_dir)).normalize

    # point += normal * 0.01 # TODO: find a better fix, without this reflected rays would hit the sphere again
    return Intersection.new(total_distance, point, normal, @material, u: 0.0, v: 0.0)
  end

  def distance_estimate(pos)
    @object.distance_estimate(pos)
  end

  def bounding_box
    AABB.new(Vec3.new(0.0), Vec3.new(0.0))
  end
end

abstract class DistanceEstimatable
  abstract def distance_estimate(pos : Vec3)
end

class SphereDE < DistanceEstimatable
  property radius : Float64

  def initialize(@radius)
  end

  def distance_estimate(pos)
    # max(pos.length - @radius, 0.0)
    pos.length - @radius
  end
end

class RepeatDE < DistanceEstimatable
  property object : DistanceEstimatable
  property mod : Vec3

  def initialize(@object, @mod)
  end

  def distance_estimate(pos)
    new_pos = Vec3.new(@mod.x == 0.0 ? pos.x : (pos.x % @mod.x) - @mod.x / 2,
                       @mod.y == 0.0 ? pos.y : (pos.y % @mod.y) - @mod.y / 2,
                       @mod.z == 0.0 ? pos.z : (pos.z % @mod.z) - @mod.z / 2)
      
    @object.distance_estimate(new_pos)
  end
end

class FractalDE < DistanceEstimatable
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
