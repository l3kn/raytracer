require "../src/raytracer"
require "../src/scene"

scene = Scene.from_json(File.read("./scenes/benchmark_scene.json"))
scene.render("benchmark.png")
