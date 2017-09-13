require "../raytracer"

class TraversedLengthRaytracer < Raytracer::Base
  # This assumes the detector is shaped like a sphere
  # surrounding the whole scene.
  #
  # An alternative solution would be to start the rays
  # on the detector and trace them back to the focal point
  def cast_ray(ray)
    full_distance = 0.0
    point = ray.origin
    dir = ray.direction

    # If the object is not convex,
    # on its way to the detector a ray might pass through it
    # multiple times.
    #
    # There is one edge case missing,
    # if the detector intersects the object,
    # this will not return the correct traversed length
    # because there is no second hit.
    #
    # For now just find pairs of intersections
    # and add their distance to the full distance
    depth = 0
    loop do
      ray_new = Ray.new(point, dir)
      hit1 = @scene.hit(ray_new)
      break if hit1.nil?

      point = hit1.point

      ray_new = Ray.new(point, dir)
      hit2 = @scene.hit(ray_new)
      break if hit2.nil?

      point = hit2.point

      full_distance += (hit1.point - hit2.point).length
      depth += 1

      if depth == 5
        break
      end
    end

    # A better solution would be to collect all lengths
    # and then use the min and max values to map each
    # to some color
    gray = full_distance / 10.0
    ::Color.new(gray, gray, gray)
  end
end

# The material doesn't matter
mat = Material::Mirror.new(Color.from_hex("#FFD700"))
hitables = OBJ.parse("models/teapot.obj", mat, interpolated: true)

dimensions = {400, 400}

camera = Camera::Perspective.new(
  look_from: Point.new(-1.5, 1.5, -2.0),
  look_at: Point.new(0.0, 0.5, 0.0),
  vertical_fov: 40.0,
  dimensions: dimensions
)

raytracer = TraversedLengthRaytracer.new(
  dimensions,
  scene: Scene.new(hitables.map(&.as(Hitable))),
  camera: camera,
  samples: 5 # No need to use a lot of samples
)

raytracer.render("teapot_traversed_length.png")
