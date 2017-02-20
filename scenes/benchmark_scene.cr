require "../src/raytracer"
require "../src/backgrounds/*"
require "../src/triangulate"

hitables = [] of Hitable

hitables.push(
  TransformationWrapper.new(
    Sphere.new(
      MirrorMaterial.new(Color.new(0.8))
    ),
    VS.new(Vector.new(0.0, -100.5, -1.0), 100.0)
  )
)

hitables.push(
  TransformationWrapper.new(
    Sphere.new(
      MirrorMaterial.new(Color.new(0.8, 0.6, 0.2))
    ),
    VS.new(Vector.new(1.0, 0.0, -1.0), 0.5)
  )
)

hitables.push(
  TransformationWrapper.new(
    Sphere.new(
      MatteMaterial.new(Color.new(0.1, 0.2, 0.5))
    ),
    VS.new(Vector.new(0.0, 0.0, -1.0), 0.5)
  )
)


hitables.push(
  TransformationWrapper.new(
    Sphere.new(
      GlassMaterial.new(Color::WHITE, Color::WHITE, 1.8)
    ),
    VS.new(Vector.new(-1.0, 0.0, -1.0), 0.5)
  )
)

scene = Scene.new(
  hitables,
  [] of Light,
  SkyBackground.new
)

width, height = {800, 400}

camera = PerspectiveCamera.new(
# camera = EnvironmentCamera.new(
  look_from: Point.new(-1.5, 1.5, 1.5),
  look_at: Point.new(0.0, 0.0, -1.0),
  vertical_fov: 30.0,
  dimensions: {width, height}
)

raytracer = WhittedRaytracer.new(
# raytracer = SimpleRaytracer.new(
  width, height,
  scene: scene,
  camera: camera,
  samples: 1
)

# # p = camera.foo(0.0, 0.0)
# puts p
# puts camera.corresponding(p)

# puts camera.corresponding(Point.new(0.0, 0.0, -1.0))

# raytracer = DirectLightingRaytracer.new(
#   width, height,
#   scene: scene,
#   camera: camera,
#   samples: 10,
#   # strategy: :sample_all,
#   strategy: :sample_one,
#   light_samples: 10,
# )

# def transform_triangle(triangle, transformation)
#   Triangle.new(
#     transformation.object_to_world(triangle.a),
#     transformation.object_to_world(triangle.b),
#     transformation.object_to_world(triangle.c),
#     triangle.material
#   )
# end

# triangles = [] of Triangle

# triangles += Triangulate.isocahedron(
#   MatteMaterial.new(Color.new(0.1, 0.2, 0.5)),
#   2
# ).map { |t| transform_triangle(t, VS.new(Vector.new(0.0, 0.0, -1.0), 0.5)) }

# triangles += Triangulate.isocahedron(
#   MatteMaterial.new(Color.new(0.1, 0.2, 0.5)),
#   2
# ).map { |t| transform_triangle(t, VS.new(Vector.new(-1.0, 0.0, -1.0), 0.5)) }

# triangles += Triangulate.isocahedron(
#   MatteMaterial.new(Color.new(0.1, 0.2, 0.5)),
#   2
# ).map { |t| transform_triangle(t, VS.new(Vector.new(1.0, 0.0, -1.0), 0.5)) }

# triangles += Triangulate.isocahedron(
#   MatteMaterial.new(Color.new(0.1, 0.2, 0.5)),
#   4
# ).map { |t| transform_triangle(t, VS.new(Vector.new(0.0, -100.5, -1.0), 100.0)) }

# wireframe = Wireframe.new(
#   width, height,
#   camera: camera,
#   triangles: triangles
# )

raytracer.recursion_depth = 5
canvas = raytracer.render_to_canvas("benchmark2.png")
cc = CameraCanvas.new(camera, canvas)

cc.line(
  Point.new(-1.0, 0.0, -1.0),
  Point.new( 1.0, 0.0, -1.0),
)

canvas = cc.canvas

# StumpyPNG.write(wireframe.render(canvas), "benchmark2.png")
StumpyPNG.write(canvas, "benchmark.png")

# raytracer.render("benchmark.png", adaptive: false)
