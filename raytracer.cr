
class Raytracer
  property width, height

  def initialize(@width, @height)
  end

  def render(world, camera, samples, filename)
    file = File.open(filename, "w")

    file.puts "P3"
    file.puts "#{width} #{height}"
    file.puts "255"
    (0...@height).reverse_each do |y|
      (0...@width).each do |x|
        col = Vec3.new(0.0)
        samples.times do
          u = (x + rand).to_f / @width
          v = (y + rand).to_f / @height

          ray = camera.get_ray(u, v)

          col += color(ray, world)
        end
        col /= samples.to_f
        col *= 255.99

        file.puts "#{col.x.to_i} #{col.y.to_i} #{col.z.to_i}"
      end
    end
  end

  RECURSION_LIMIT = 10

  def color(ray, world, recursion_level = 0)
    hit = world.hit(ray, 0.0001, 9999.9)
    if hit
      scatter = hit.material.scatter(ray, hit)
      if scatter && recursion_level < RECURSION_LIMIT
        scatter[1] * color(scatter[0], world, recursion_level + 1)
      else
        Vec3.new(0.0)
      end
    else
      t = 0.5 * (ray.direction.normalize.y + 1.0)
      Vec3.new(1.0)*(1.0 - t) + Vec3.new(0.5, 0.7, 1.0)*t
    end
  end
end
