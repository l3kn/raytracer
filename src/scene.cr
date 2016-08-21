require "json"
require "./raytracer"

class JSONScene
  JSON.mapping(
    height:  Float64,
    width:   Float64,
    samples: Float64,
    objects: {type: Array(Hitable), converter: HitableConverter},
    camera: {type: Camera, converter: CameraConverter},
    background: {type: Background, converter: BackgroundConverter}
  )
end

class Scene
  property height : Int32
  property width : Int32
  property samples : Int32

  property camera : Camera
  property objects : Array(Hitable)

  property background : Background

  property raytracer_type : String
  property container_type : String

  def initialize(@width, @height, @samples, @camera, @objects, @background, @raytracer_type, @container_type)
  end

  def initialize(@width, @height, @samples, @objects, @camera, @background)
    @raytracer_type = "normal"
    @container_type = "list"
  end

  def render(filename)
    if @container_type == "BVH"
      world = BVHNode.new(@objects)
    else
      world = HitableList.new(@objects)
    end

    raytracer = Raytracer.new(@width, @height,
                              world: world,
                              camera: @camera,
                              samples: @samples,
                              background: @background)

    raytracer.render("benchmark.png")
  end

  def self.from_json(json)
    json_scene = JSONScene.from_json(json)
    self.new(
      json_scene.width.to_i,
      json_scene.height.to_i,
      json_scene.samples.to_i,
      json_scene.objects,
      json_scene.camera,
      json_scene.background,
    )
  end
end
