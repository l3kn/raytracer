require "../../src/distance_estimatable"
require "../../raytracer"

class SierpinskyTetrahedron < DE::DistanceEstimatable
  def initialize(@iterations = 3, @scale = 2.0)
  end

  def distance_estimate(pos)
    @iterations.times do
      # Folding across some of the symmetry planes
      pos = pos._y_xz if pos.x + pos.y < 0
      pos = pos._zy_x if pos.x + pos.z < 0
      pos = pos.x_z_y if pos.y + pos.z < 0

      pos = Point.new(
        pos.x*@scale - (@scale - 1.0),
        pos.y*@scale - (@scale - 1.0),
        pos.z*@scale - (@scale - 1.0)
      )
    end

    (pos.length - 2) * @scale ** (-@iterations)
  end
end

mat = MatteMaterial.new(UTexture.new(40.0))

de = SierpinskyTetrahedron.new(11, 2.0)
hitables = DistanceEstimator.new(mat, de, maximum_steps: 600)

# width, height = {1920, 1080}
# dimensions = {400, 400}
dimensions = {2480, 3508}

camera = Camera::Perspective.new(
  look_at: Point.new(1.0, 1.0, 1.0),
  look_from: Point.new(0.0, 0.0, 0.0),
  vertical_fov: 22.0,
  dimensions: dimensions
)

# Raytracer
raytracer = Renderer::Color.new(
  dimensions,
  scene: Scene.new(
    [hitables.as(UnboundedHitable)],
    background: Background::Constant.new(Color.new(1.0))
  ),
  camera: camera,
  samples: 2
)

raytracer.render("fractal3.png")
