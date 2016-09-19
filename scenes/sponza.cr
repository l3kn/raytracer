require "../src/raytracer"
require "../src/backgrounds/*"
require "../src/obj"

ct2 = ConstantTexture.new(Vec3.new(0.0, 0.0, 1.0))
mat = Lambertian.new(ct2)

def get_material(name)
  # The materials are to big to include them in this repo,
  # download them here: http://www.crytek.com/cryengine/cryengine3/downloads
  # and convert all .tga files to .png
  # e.g. using `mogrify -format png *.tga
  Lambertian.new(ImageTexture.new("old/models/sponza/materials/#{name}.png"))
end

materials = {
  "leaf" => get_material("thorn"),
  "vase_round" => get_material("vase_round"),
  "Material__57" => get_material("vase_plant"),
  "Material__298" => get_material("background"),
  "16___Default" => Lambertian.new(Vec3.new(0.5880)),
  "bricks" => get_material("bricks"),
  "arch" => get_material("sponza_arch_diff"),
  "column_a" => get_material("sponza_column_a_diff"),
  "column_b" => get_material("sponza_column_b_diff"),
  "column_c" => get_material("sponza_column_c_diff"),
  "floor" => get_material("sponza_floor_a_diff"),
  "details" => get_material("sponza_details_diff"),
  "Material__47" => Lambertian.new(Vec3.new(0.5880)),
  "flagpole" => get_material("sponza_flagpole_diff"),
  "fabric_e" => get_material("sponza_fabric_green_diff"),
  "fabric_d" => get_material("sponza_fabric_blue_diff"),
  "fabric_a" => get_material("sponza_fabric_diff"),
  "fabric_g" => get_material("sponza_curtain_blue_diff"),
  "fabric_c" => get_material("sponza_curtain_diff"),
  "fabric_f" => get_material("sponza_curtain_green_diff"),
  "chain" => get_material("chain_texture"),
  "vase_hanging" => get_material("vase_hanging"),
  "vase" => get_material("vase_dif"),
  "Material__25" => get_material("lion"),
  "roof" => get_material("sponza_roof_diff"),
  "ceiling" => get_material("sponza_ceiling_a_diff"),
}

hitables = OBJ.parse("old/models/sponza/sponza.obj", mat, interpolated: true, textured: true, materials: materials)

light = XZRect.new(
  Vec3.new(-900.0, 1800.0, -80.0),
  Vec3.new(900.0, 1800.0, 80.0),
  DiffuseLight.new(Vec3::ONE, 40.0),
)
hitables << light

# width, height = {1920, 1080}
width, height = 400, 400
node = SAHBVHNode.new(hitables)

camera = Camera.new(
  look_from: Vec3.new(940.0, 600.0, 80.0),
  look_at: Vec3.new(0.0, 400.0, 0.0),
  vertical_fov: 70,
  aspect_ratio: width.to_f / height.to_f,
)

raytracer = Raytracer.new(width, height,
                          hitables: node,
                          focus_hitables: light,
                          camera: camera,
                          samples: 5000,
                          background: ConstantBackground.new(Vec3.new(1.0)))

raytracer.recursion_depth = 4
raytracer.render("sponza.png")

# "Interactive" mode for finding a good camera position
# while true
#   print "> "
#   command = gets || ""
#   next if command.empty?

#   tokens = command.chomp.split
#   case tokens[0]
#   when "quit"
#     break
#   when "look_from"
#     x, y, z = tokens[1,3].map(&.to_f)
#     look_from = Vec3.new(x, y, z)
#   when "look_at"
#     x, y, z = tokens[1,3].map(&.to_f)
#     look_at = Vec3.new(x, y, z)
#   when "size"
#     width, height = tokens[1,2].map(&.to_i)
#   when "render"
#     camera = Camera.new(
#       look_from, look_at, up, vertical_fov, aspect_ratio,
#       aperture: 0.0
#     )
#     raytracer = NormalRaytracer.new(width, height,
#       hitables: node,
#       camera: camera,
#       samples: 10,
#       background: ConstantBackground.new(Vec3.new(1.0)))
#     raytracer.render("sponza.png")
#     puts ""
#   end
# end
