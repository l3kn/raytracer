require "./vec3"

def clamp(x, x_min, x_max)
  max(min(x, x_min), x_max)
end

def random_vec
  Vec3.new(pos_random, pos_random, pos_random)
end

def pos_random
  rand(0.0..1.0)
end

def random
  rand(-1.0..1.0)
end

def random_in_unit_sphere
  point = Vec3.new(1.0)

  while point.squared_length >= 1.0
    point = Vec3.new(random, random, random)
  end

  point
end

def random_on_unit_sphere
  random_in_unit_sphere.normalize
end

def random_in_unit_circle
  point = Vec3.new(1.0)

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
