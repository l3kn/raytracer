require "../src/raytracer"

tex_white = ConstantTexture.new(Vec3.new(0.73))
tex_red   = ConstantTexture.new(Vec3.new(0.65, 0.05, 0.05))
tex_green = ConstantTexture.new(Vec3.new(0.12, 0.45, 0.15))

tex_light = ConstantTexture.new(Vec3.new(15.0))

white = Lambertian.new(tex_white)
red   = Lambertian.new(tex_red)
green = Lambertian.new(tex_green)

aluminum = Metal.new(ConstantTexture.new(Vec3.new(0.8, 0.85, 0.88)), 0.0)

light = DiffuseLight.new(tex_light)

left   = YZRect.new(Vec3.new(555.0, 0.0, 0.0),
                    Vec3.new(555.0, 555.0, 555.0),
                    green)
left.flip!

right  = YZRect.new(Vec3.new(0.0, 0.0, 0.0),
                    Vec3.new(0.0, 555.0, 555.0),
                    red)

bottom = XZRect.new(Vec3.new(0.0, 0.0, 0.0),
                    Vec3.new(555.0, 0.0, 555.0),
                    white)

top    = XZRect.new(Vec3.new(0.0, 555.0, 0.0),
                    Vec3.new(555.0, 555.0, 555.0),
                    white)
top.flip!

back   = XYRect.new(Vec3.new(0.0, 0.0, 555.0),
                    Vec3.new(555.0, 555.0, 555.0),
                    white)
back.flip!

light_ = XZRect.new(Vec3.new(213.0, 554.0, 227.0),
                    Vec3.new(343.0, 554.0, 332.0),
                    light)
light_.flip!

cube1 = Translate.new(
  RotateY.new(
    Cuboid.new(Vec3.new(0.0), Vec3.new(165.0), white),
    -18.0
  ),
  Vec3.new(130.0, 0.0, 65.0)
)

cube2 = Translate.new(
  RotateY.new(
    Cuboid.new(Vec3.new(0.0), Vec3.new(165.0, 330.0, 165.0), aluminum),
    15.0
  ),
  Vec3.new(265.0, 0.0, 295.0)
)

sphere = Sphere.new(
  Vec3.new(190.0, 90.0, 190.0),
  90.0,
  Dielectric.new(1.5)
)

# world = [left, right, bottom, top, back, light_, cube1, cube2]
world = [left, right, bottom, top, back, light_, sphere, cube2]

width, height = {400, 400}

# Camera params
look_from = Vec3.new(278.0, 278.0, -800.0)
look_at = Vec3.new(278.0, 278.0, 0.0)

up = Vec3.new(0.0, 1.0, 0.0)

aspect_ratio = width.to_f / height.to_f
dist_to_focus = 10.0
aperture = 0.05
fov = 40

camera = Camera.new(look_from, look_at, up, fov, aspect_ratio, aperture, dist_to_focus)

# Raytracer
raytracer = Raytracer.new(width, height,
                          world: HitableList.new(world),
                          camera: camera,
                          samples: 100,
                          light_shape: HitableList.new([light_, sphere]),
                          background: ConstantBackground.new(Vec3.new(0.0)))

raytracer.render("cornell.png")
