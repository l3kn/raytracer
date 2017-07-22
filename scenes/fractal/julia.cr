require "../../src/distance_estimatable"
require "../../raytracer"

class Julia < DE::DistanceEstimatable
  def initialize(@iterations = 8)
    # @d = Quaternion.new(0.18, 0.88, 0.24, 0.16)
    @d = Quaternion.new(-0.137, -0.630, -0.475, -0.046)
    # @d = Quaternion.new(-0.218,-0.113,-0.181,-0.496)
  end

  def distance_estimate(pos)
    p = Quaternion.new(pos, 0.0)
    dp = Quaternion.new(1.0, 0.0, 0.0, 0.0)

    @iterations.times do
      dp = p*dp*2.0
      p = p * p + @d
      break if p.squared_length > 10000000.0
    end

    r = p.length
    0.5 * r * Math.log(r) / dp.length
  end
end

mat = MatteMaterial.new(UTexture.new(20.0))

de = Julia.new(100)
hitables = DistanceEstimator.new(
  mat,
  de,
  maximum_steps: 1000,
  minimum_distance: 0.0001
)

dimensions = {400, 400}

camera = Camera::Perspective.new(
  look_from: Point.new(4.0, 0.0, 0.0),
  look_at: Point.new(0.0, 0.0, 0.0),
  vertical_fov: 30.0,
  dimensions: dimensions
)

raytracer = Renderer::Color.new(
  dimensions,
  scene: Scene.new(
    [hitables.as(UnboundedHitable)],
    background: Background::Constant.new(Color.new(1.0))
  ),
  camera: camera,
  samples: 1
)

raytracer.render("fractal5.png")
