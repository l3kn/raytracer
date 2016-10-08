require "../raytracer"
require "../phong/light"

module Phong
  class Raytracer < ::NormalRaytracer
    property lights : Array(Light)
    property ambient : Float64

    def initialize(width, height, hitables, camera, samples, @lights, @ambient = 0.0, background = nil)
      super(width, height, hitables, camera, samples, background)
    end

    def color(ray, hit, recursion_depth)
      material = hit.material

      # Because we are inside the Phong module,
      # Material = Phong::Material
      if material.is_a?(Material)
        color = material.texture.value(hit.point, hit.u, hit.v)
        diffuse = 0.0
        specular = 0.0

        @lights.each do |light|
          l = (light.position - hit.point).normalize
          hit2 = @hitables.hit(Ray.new(hit.point, l, 0.001, (light.position - hit.point).length))
          if hit2
            Color::BLACK
          else
            n = hit.normal
            v = -ray.direction.normalize
            r = ((n * l.dot(hit.normal)) * 2 - l).normalize

            diffuse += light.intensity * max(l.dot(n), 0.0)
            specular += light.intensity * (max(r.dot(v), 0.0) ** material.shininess)
          end
        end

        material.k_a * color * @ambient + material.k_d * color * diffuse + material.k_s * specular
      else
        Color::BLACK
      end
    end
  end
end
