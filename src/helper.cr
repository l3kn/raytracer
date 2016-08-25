require "./vec3"

def de_nan(vec)
  if vec.x.nan? || vec.y.nan? || vec.z.nan?
    Vec3::ZERO
  else
    vec
  end
end

def clamp(x, x_min, x_max)
  min(max(x, x_min), x_max)
end

def smoothstep(x)
  x = clamp(x, 0.0, 1.0)
  x * x * (3.0 - 2.0 * x)
end

def pos_random
  rand(0.0...1.0)
end

def random
  rand(-1.0..1.0)
end

def random_vec
  Vec3.new(pos_random, pos_random, pos_random)
end

def random_in_unit_sphere
  point = Vec3::ONE
  while point.squared_length >= 1.0
    point = Vec3.new(random, random, random)
  end

  point
end

def random_on_unit_sphere
  random_in_unit_sphere.normalize
end

def random_in_unit_circle
  point = Vec3::ONE
  while point.squared_length >= 1.0
    point = Vec3.new(random, random, 0.0)
  end

  point
end

def random_on_hemisphere(normal)
  point = random_on_unit_sphere

  # Check if the point lies on the correct hemisphere,
  # if not, invert it
  normal.dot(point) > 0 ? point : -point
end

def random_cosine_direction
  r1 = pos_random
  r2 = pos_random

  z = Math.sqrt(1-r2)
  phi = 2*Math::PI*r1

  sqrt = Math.sqrt(r2)
  x = Math.cos(phi) * 2 * sqrt
  y = Math.sin(phi) * 2 * sqrt

  Vec3.new(x, y, z)
end

def random_to_sphere(radius, distance_squared)
  r1 = pos_random
  r2 = pos_random

  z = 1.0 + r2 * (Math.sqrt(1 - radius*radius / distance_squared) - 1.0)
  phi = 2 * Math::PI * r1

  sqrt = Math.sqrt(1 - z*z)
  x = Math.cos(phi) * sqrt
  y = Math.sin(phi) * sqrt

  Vec3.new(x, y, z)
end

def schlick(cosine, reflection_index)
  r0 = ((1 - reflection_index) / (1 + reflection_index)) ** 2
  r0 + (1 - r0)*((1 - cosine)**5)
end

def min(a, b)
  a < b ? a : b
end

def max(a, b)
  a < b ? b : a
end

def minmax(a, b)
  a < b ? {a, b} : {b, a}
end

def mix(a, b, t)
  a*t + b*(1 - t)
end
