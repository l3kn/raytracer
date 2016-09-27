require "../src/raytracer"
require "../src/backgrounds/*"

# Instructions
#
# The .png cubemaps for this example
# are to big to upload them to github (~200MB)
#
# To run this example:
#
# 1. Download a set of cubemap images from
#    http://www.humus.name/index.php?page=Textures
#
# 2. Unzip it into into some folder
#
# 3. Convert each .jpg to .png (uncompressed)
#    e.g. using `convert negx.jpg -compress none negx.png` etc.
#
# 4. Change the value for `cube_map_filename`
#    to match the path of the unzipped folder
#
# 5. (optional)
#    Create an animated gif
#    e.g. using `convert cube*.png cube.gif`

sphere = Sphere.new(
  Point.new(0.0),
  1.0,
  Metal.new(Color.new(0.8), 0.0)
)

width, height = {400, 400}

# Camera params
look_from = Point.new(0.0, 0.0, 2.5)
look_at = Point.new(0.0)
fov = 60
aspect_ratio = width.to_f / height.to_f

camera = Camera.new(look_from, look_at, fov, aspect_ratio)

# Raytracer
raytracer = SimpleRaytracer.new(width, height,
  hitables: sphere,
  camera: camera,
  samples: 20,
  background: CubeMap.new("cube_maps/Yokohama"))

(0...360).each do |p|
  # Rotate the camera around the y-axis
  x = 0.0
  z = 2.5

  angle = p / 180.0 * Math::PI

  s = Math.sin(angle)
  c = Math.cos(angle)

  look_from = Point.new(x * c - z * s, 0.5, x * s + z * c)
  camera = Camera.new(look_from, look_at, fov, aspect_ratio)

  raytracer.camera = camera
  raytracer.render("cube#{p.to_s.rjust(3, '0')}.png")
end
