require "../raytracer"

hitables = [] of UnboundedHitable
lights = [] of Light

# File.read("blocks.csv").each_line do |line|
#   tokens = line.split(",")

#   x = tokens[0].to_f
#   y = 16 - tokens[1].to_f
#   z = tokens[2].to_f

#   color = Color.new(tokens[3].to_f, tokens[4].to_f, tokens[5].to_f)
#   opaque = tokens[6] == "true"

#   hitables << Cuboid.new(
#     Point.new(x, y, z),
#     Point.new(x, y, z) + Vector.one,
#     # opaque ? MatteMaterial.new(color) : GlassMaterial.new(1.4, color, color)
#     opaque ? MatteMaterial.new(color) : GlassMaterial.new(1.4, color, color)
#   )
# end

class VoxelGrid < BoundedHitable
  @voxels : Array(Int8)
  @width : Int16
  @height : Int16
  @depth : Int16

  @materials : Array(Material)

  def initialize(@width, @height, @depth)
    # (x, y, z) => material index, 0 encodes empty cell
    @voxels = Array(Int8).new(0, @width * @height * @depth)
    @materials = [] of Material
  end

  def set(x, y, z, material : Material)
    i = @materials.index(material)

    if i.nil?
      set(x, y, z, @materials.size + 1)
      @materials << material
    else
      set(x, y, z, i + 1)
    end
  end

  def set(x, y, z, material : Int8)
    @voxels[x + y*@width + z*@width*@height] = material
  end

  def get(x, y, z)
    res = @voxels[x + y*@width + z*@width*@height]
    if res == 0
      nil
    else
      @material[res - 1]
    end
  end

  def hit(ray)
    res = nil

    t_delta_x = 1.0 / ray.direction.x
    t_delta_y = 1.0 / ray.direction.y
    t_delta_z = 1.0 / ray.direction.z


    t = (@bot.z - ray.origin.z) / ray.direction.z
    return nil if t < ray.t_min || t > ray.t_max

    point = ray.point_at_parameter(t)

    # Hitpoint is outside of the rect
    return nil if point.x < @bot.x || point.x > @top.x
    return nil if point.y < @bot.y || point.y > @top.y

    u = (point.x - @bot.x) / (@top.x - @bot.x)
    v = (point.y - @bot.y) / (@top.y - @bot.y)
    return HitRecord.new(t, point, @normal, @material, self, u, v)
  end
end

dimensions = {800, 800}
camera = PerspectiveCamera.new(
  look_from: Point.new(40.0, 32.0, 40.0),
  look_at: Point.new(16.0, 8.0, 16.0),
  vertical_fov: 40.0,
  dimensions: dimensions
)

raytracer = Renderer::Simple.new(
  dimensions, camera,
  scene: Scene.new(hitables, lights, SkyBackground.new),
  samples: 200
)

raytracer.render("cornell.png")
