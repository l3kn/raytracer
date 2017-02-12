require "linalg"

struct Normal < LA::AVector3
  def initialize(@x : Float64, @y : Float64, @z : Float64)
    {% if flag?(:release) %}
      if (self.dot(self) - 1.0).abs > EPSILON
        raise "Error, length of normal is != 1"
      end
    {% end %}
  end

  def *(other : Float64)
    Vector.new(@x * other, @y * other, @z * other)
  end

  define_vector_op(:+, other_class: Normal, result_class: LA::Vector3)
  define_vector_op(:-, other_class: Normal, result_class: LA::Vector3)

  define_dot(other_class: Vector)

  def flip
    Normal.new(-@x, -@y, -@z)
  end

  # TODO: this is only used by onb.cr:14
  # in combination with pdf distributions around a normal
  def normalize; self; end
  def to_vector; Vector.new(@x, @y, @z); end
  def to_tuple; {@x, @y, @z}; end

  def face_forward(v)
    dot(v) < 0.0 ? -self : self
  end

  def refract(wi : Vector, eta : Float64) : Vector?
    cos_theta_i = dot(wi.normalize)
    sin_2_theta_i = max(0.0, 1.0 - cos_theta_i * cos_theta_i)
    sin_2_theta_t = eta * eta * sin_2_theta_i

    if sin_2_theta_t >= 1.0
      nil
    else
      cos_theta_t = Math.sqrt(1.0 - sin_2_theta_t)
      -wi * eta + self * (eta * cos_theta_i - cos_theta_t)
    end
  end
end
