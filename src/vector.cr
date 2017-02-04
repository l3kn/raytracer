require "linalg"
require "./helper"

struct Vector < LA::AVector3
  define_class_methods
  define_dot(other_class: Normal)

  def to_normal
    inv = 1.0 / length
    Normal.new(self.x * inv, self.y * inv, self.z * inv)
  end

  # TODO: move this to the normal class
  # and flip the arguments `normal.reflect(vector)
  def reflect(normal)
    dt = self.dot(normal)

    Vector.new(
      self.x - normal.x * dt * 2.0,
      self.y - normal.y * dt * 2.0,
      self.z - normal.z * dt * 2.0,
    )
    # self - normal*dot(normal)*2.0
  end

  # TODO: move this to the normal class
  def refract(normal, eta)
    dt = normalize.dot(normal)
    discriminant = 1.0 - (eta**2) * (1 - dt**2)

    if discriminant > 0
      normalize * eta - normal * (eta * dt + Math.sqrt(discriminant))
    else
      nil
    end
  end

  # TODO, see Normal.to_normal
  def to_vector; self;
  end

  define_vector_swizzling(2)
  define_vector_swizzling(3, signed: true)

  def xyz
    {@x, @y, @z}
  end

  def max(other : Float64)
    Vector.new(max(@x, other), max(@y, other), max(@z, other))
  end
end
