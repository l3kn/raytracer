require "../distance_estimatable"
require "../hitable"

class DistanceEstimator < Hitable
  property material : Material
  property object : DE::DistanceEstimatable
  property step : Float64
  property maximum_steps : Int32
  property minimum_distance : Float64

  def initialize(@material, @object, @step = 0.1, @maximum_steps = 1000, @minimum_distance = 0.0001)
  end

  def hit(ray, t_min, t_max)
    total_distance = 0.0
    steps = 0

    point = ray.origin

    return nil if distance_estimate(point) <= t_min

    maximum_steps.times do
      point = ray.point_at_parameter(total_distance)
      distance = distance_estimate(point)
      total_distance += distance

      return nil if total_distance >= t_max

      steps += 1
      break if distance < @minimum_distance
    end

    x_dir = Vec3.new(@step, 0.0, 0.0)
    y_dir = Vec3.new(0.0, @step, 0.0)
    z_dir = Vec3.new(0.0, 0.0, @step)

    normal = Vec3.new(distance_estimate(point + x_dir) - distance_estimate(point - x_dir),
      distance_estimate(point + y_dir) - distance_estimate(point - y_dir),
      distance_estimate(point + z_dir) - distance_estimate(point - z_dir)).normalize

    return ::HitRecord.new(
      t: total_distance,
      point: point + normal * @minimum_distance * 2.0,
      normal: normal,
      material: @material,
      u: steps.to_f / @maximum_steps, v: 0.0
    )
  end

  def distance_estimate(pos)
    @object.distance_estimate(pos)
  end

  def bounding_box
    raise "Error, this feature is not supported yet"
  end
end

class BruteForceDistanceEstimator < Hitable
  property material : Material
  property object : DE::BruteForceDistanceEstimatable
  property maximum : Float64

  def initialize(@material, @object, @maximum = 1000.0)
  end

  def hit(ray, t_min, t_max)
    steps = 1000
    closest = @maximum

    steps.times do
      t = closest * pos_random
      point = ray.point_at_parameter(t)
      if object.inside?(point)
        closest = t
      end
    end

    unless closest == @maximum
      point = ray.point_at_parameter(closest)
      normal = @object.normal(point)
      ::HitRecord.new(
        t: closest,
        point: point + normal * 0.1,
        normal: normal,
        material: @material,
        u: closest / @maximum, v: 0.0
      )
    else
      nil
    end
  end

  def bounding_box
    raise "Error, this feature is not supported yet"
  end
end
