# look_from = Vec3.new(0.0, 0.8, 3.0)
# look_at = Vec3.new(0.0, 0.3, -1.0)
# up = Vec3.new(0.0, 1.0, 0.0)
# fov = 20

def random_scene
  world = [] of Hitable

  world.push(Sphere.new(Vec3.new(0.0, -1000.0, 0.0), 1000, Lambertian.new(Vec3.new(0.5))))

  # (-11..11).each do |a|
    # (-11..11).each do |b|
  (-50..50).each do |a|
    (-50..50).each do |b|
      center = Vec3.new(a + 0.9*pos_random, 0.2, b + 0.9*pos_random)
      if (center - Vec3.new(4.0, 0.2, 0.0)).length > 0.9
        choose_mat = pos_random

        if choose_mat < 0.4 # diffuse
          mat = Lambertian.new(random_vec)
        elsif choose_mat < 0.8 # metal
          mat = Metal.new(random_vec, 0.5 * pos_random)
        else
          mat = Dielectric.new(1.5)
        end

        world.push(Sphere.new(center, 0.2, mat))
      end
    end
  end

  world
end
