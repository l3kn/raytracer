require "../raytracer"
require "../cube_map"

class CubeMapRaytracer < Raytracer
  getter cube_map : CubeMap

  def initialize(width, height, world, camera, samples, cube_map_filename)
    super(width, height, world, camera, samples)
    @cube_map = CubeMap.new(cube_map_filename)
  end

  def color(ray, world, recursion_level = 0)
    hit = world.hit(ray, 0.0001, 9999.9)
    if hit
      scatter = hit.material.scatter(ray, hit)
      if scatter && recursion_level < RECURSION_LIMIT
        scatter.albedo * color(scatter.ray, world, recursion_level + 1)
      else
        Vec3.new(0.0)
      end
    else
      @cube_map.read(ray)
    end
  end
end
