require "./distance_estimatables/*"
require "./hitable"

module DE
  class DistanceEstimator < Hitable
    property material : Material
    property object : DistanceEstimatable
    property step : Float64

    MAXIMUM_RAY_STEPS = 1000

    def initialize(@material, @object, @step = 0.1)
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

      x_dir = Vec3.new(@step, 0.0,   0.0)
      y_dir = Vec3.new(0.0,   @step, 0.0)
      z_dir = Vec3.new(0.0,   0.0,   @step)

      normal = Vec3.new(distance_estimate(point + x_dir) - distance_estimate(point - x_dir),
                        distance_estimate(point + y_dir) - distance_estimate(point - y_dir),
                        distance_estimate(point + z_dir) - distance_estimate(point - z_dir)).normalize

      return ::Intersection.new(total_distance, point + normal * 2 * t_min, normal, @material, u: 0.0, v: 0.0)
    end

    def distance_estimate(pos)
      @object.distance_estimate(pos)
    end

    def bounding_box
      # TODO: Clean up, maybe add Hitable.infinite?
      AABB.new(Vec3.new(0.0), Vec3.new(0.0))
    end
  end
end
