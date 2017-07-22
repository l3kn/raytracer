class Raytracer
  class Normal < Base
    def cast_ray(ray)
      hit = @scene.hit(ray)
      if hit.nil?
        @scene.get_background(ray)
      else
        ::Color.new(
          (1.0 + hit.normal.x) * 0.5,
          (1.0 + hit.normal.y) * 0.5,
          (1.0 + hit.normal.z) * 0.5,
        )
      end
    end
  end

  class Point < Base
    def cast_ray(ray)
      hit = @scene.hit(ray)
      if hit.nil?
        @scene.get_background(ray)
      else
        ::Color.new(
          hit.point.x % 10.0 / 10.0, 
          hit.point.y % 10.0 / 10.0,
          hit.point.z % 10.0 / 10.0
        )
      end
    end
  end

  class Color < Base
    def cast_ray(ray)
      hit = @scene.hit(ray)
      if hit.nil?
        @scene.get_background(ray)
      else
        bsdf = hit.material.bsdf(hit)
        sample = bsdf.sample_f(-ray.direction, BxDF::Type::All)
        sample.nil? ? ::Color::BLACK : sample.color
      end
    end
  end
end
