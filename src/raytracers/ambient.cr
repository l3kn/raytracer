class AORaytracer < NormalRaytracer
  def color(ray, hit, recursion_depth)
    scatter = hit.material.scatter(ray, hit)
    if scatter
      uvw = ONB.from_w(hit.normal)
      ao_samples = 10
      count = 0

      ao_samples.times do
        dir = uvw.local(random_cosine_direction)
        point = hit.point + dir * @t_min * 2
        unless @hitables.hit(Ray.new(point, dir), @t_min, @t_max)
          count += 1
        end
      end

      Color.new(count / 10.0)
      # scatter.albedo *
    else
      Color::BLACK
    end
  end
end
