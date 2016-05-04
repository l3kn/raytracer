require "../raytracer"

world_ = [] of Hitable

tex_white = ConstantTexture.new(Vec3.new(0.73))
tex_red   = ConstantTexture.new(Vec3.new(0.65, 0.05, 0.05))
tex_green = ConstantTexture.new(Vec3.new(0.12, 0.45, 0.15))

tex_light = ConstantTexture.new(Vec3.new(15.0))

white = Lambertian.new(tex_white)
red   = Lambertian.new(tex_red)
green = Lambertian.new(tex_green)

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

world = HitableList.new([left, right, bottom, top, back, light_])

width, height = {400, 400}

raytracer = Raytracer.new(width, height)

# Camera params
look_from = Vec3.new(278.0, 278.0, -800.0)
look_at = Vec3.new(278.0, 278.0, 0.0)

up = Vec3.new(0.0, 1.0, 0.0)

aspect_ratio = width.to_f / height.to_f
# dist_to_focus = (look_from - look_at).length
dist_to_focus = 10.0
aperture = 0.05
fov = 40

samples = 4000

camera = Camera.new(look_from, look_at, up, fov, aspect_ratio, aperture, dist_to_focus)
filename = "cornell.ppm"
raytracer.render(world, camera, samples, filename)
