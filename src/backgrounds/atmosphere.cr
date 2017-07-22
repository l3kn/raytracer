module Background
  class Atmosphere < Abstract
    @sun_direction : Vector
    @earth_radius : Float64
    @atmosphere_radius : Float64
    @h_r : Float64 # if density was uniform
    @h_m : Float64 # same as above, but for Mie scattering

    def initialize(@sun_direction,
                   @earth_radius = 6360e3,
                   @atmosphere_radius = 6420e3,
                   @h_r = 7994.0,
                   @h_m = 1200.0)
    end

    BETA_R = Color.new(3.8e-6, 13.5e-6, 33.1e-6)
    BETA_M = Color.new(21e-6)

    def get(ray)
      ray = Ray.new(
        Point.new(
          ray.origin.x,
          ray.origin.y + @earth_radius,
          ray.origin.z
        ),
        ray.direction
      )

      t_min = ray.t_min
      t_max = ray.t_max

      hit = ray_sphere_intersect(ray)
      return Color.new(1.0, 0.0, 0.0) if hit.nil?

      t0, t1 = hit
      t_min = t0 if t0 > t_min && t0 > 0
      t_max = t1 if t1 < t_max

      samples = 16
      light_samples = 8

      segment_length = (t_max - t_min) / samples
      t_current = t_min

      sum_r = Color.new(0.0)
      sum_m = Color.new(0.0)

      optical_depth_r = 0.0
      optical_depth_m = 0.0

      mu = ray.direction.dot(@sun_direction)
      phase_r = 3.0 / (samples.to_f * Math::PI) * (1.0 + mu * mu)
      g = 0.76
      phase_m = 3.0 / (light_samples.to_f * Math::PI) * ((1.0 - g * g) * (1.0 + mu * mu))
      phase_m /= (2.0 + g * g) * ((1.0 + g * g - 2.0 * g * mu) ** 1.5)

      samples.times do |i|
        sample_position = ray.point_at_parameter(t_current + segment_length * 0.5)
        height = sample_position.length - @earth_radius

        # compute optical depth
        h_r = Math.exp(-height / @h_r) * segment_length
        h_m = Math.exp(-height / @h_m) * segment_length

        optical_depth_r += h_r
        optical_depth_m += h_m

        # light optical depth
        sun_ray = Ray.new(sample_position, @sun_direction)
        hit = ray_sphere_intersect(sun_ray)

        raise "Error, hit with sun" if hit.nil?

        t0_light, t1_light = hit

        segment_length_light = t1_light / light_samples
        t_current_light = 0.0

        optical_depth_light_r = 0.0
        optical_depth_light_m = 0.0

        j = 0
        light_samples.times do
          sample_position_light = sun_ray.point_at_parameter(t_current_light + segment_length_light * 0.5)
          height_light = sample_position_light.length - @earth_radius

          break if height_light < 0

          optical_depth_light_r += Math.exp(-height_light / @h_r) * segment_length_light
          optical_depth_light_m += Math.exp(-height_light / @h_m) * segment_length_light

          t_current_light += segment_length_light
          j += 1
        end

        if j == light_samples
          tau = BETA_R * (optical_depth_r + optical_depth_light_r)
          tau += BETA_M * 1.1 * (optical_depth_m + optical_depth_light_m)
          attenuation = Color.new(
            Math.exp(-tau.r),
            Math.exp(-tau.g),
            Math.exp(-tau.b)
          )

          sum_r += attenuation * h_r
          sum_m += attenuation * h_m
        end

        t_current += segment_length
      end

      (sum_r * BETA_R * phase_r + sum_m * BETA_M * phase_m) * 20.0
    end

    def ray_sphere_intersect(ray)
      oc = ray.origin

      a = ray.direction.squared_length
      b = 2.0 * oc.dot(ray.direction)
      c = oc.squared_length - @atmosphere_radius**2

      ts = solve_quadratic(a, b, c)
      return nil if ts.nil?

      t0, t1 = ts
      # We know that t0 < t1
      #     t0 > t_max
      # => t1 > t_max
      # => no hit
      return nil if t0 > ray.t_max || t1 < ray.t_min

      t_hit = t0
      if t0 < ray.t_min
        t_hit = t1
        return nil if t_hit > ray.t_max
      end

      return {t0, t1}
    end
  end
end
