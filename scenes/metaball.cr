require "../../raytracer"
require "../src/distance_estimatables/*"

mat = Material::Mirror.new(Color.new(0.8))

bfde = DE::Metaball.new(
  [
    {Point.new(1.0, -0.5, -0.2), 1.0},
    {Point.new(0.0, 0.5, 0.2), 1.0},
    {Point.new(-1.0, -0.5, 0.0), 1.0},
  ],
  3.4
)
hitables = [BruteForceDistanceEstimator.new(mat, bfde, 5.0).as(UnboundedHitable)]

dimensions = {800, 400}

camera = Camera::Perspective.new(
  look_from: Point.new(0.0, 0.0, 2.0),
  look_at: Point.new(0.0, 0.0, 0.0),
  vertical_fov: 70.0,
  dimensions: dimensions,
)

raytracer = Raytracer::Simple.new(
  dimensions,
  scene: Scene.new(hitables, background: Background::CubeMap.new("cube_maps/Yokohama")),
  camera: camera,
  samples: 10
)

raytracer.render("metaball.png")
