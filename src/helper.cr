macro assert(pred)
  {% if !flag?(:release) %}
    raise "Assertion failed: {{pred}}" unless {{pred}}
  {% end %}
end

macro assert(pred, message)
  {% if !flag?(:release) %}
    raise {{message}} unless {{pred}}
  {% end %}
end

RADIANTS = (Math::PI / 180)

# TODO: Use these constants everywhere
TWOPI  = 2.0 * Math::PI
FOURPI = 4.0 * Math::PI

INV_PI     = 1.0 / Math::PI
INV_TWOPI  = 1.0 / TWOPI
INV_FOURPI = 1.0 / FOURPI

PI_OVER_TWO  = Math::PI / 2
PI_OVER_FOUR = Math::PI / 4

# TODO: Create a class Point2
# to use instead of u1, u2
# and for all 2D sampling methods

def radiants(n)
  n * RADIANTS
end

def same_hemisphere?(v1, v2)
  v1.z * v2.z > 0.0
end

def clamp(x, min, max)
  min(max(x, min), max)
end

def smoothstep(x)
  x = clamp(x, 0.0, 1.0)
  x * x * (3.0 - 2.0 * x)
end

def random
  rand * 2 - 1.0
end

# TODO: this is a litte bit different in pbrt
def stratified_sample_1D(nx : Int32, jitter = true)
  dx = 1.0 / nx
  res = Array(Float64).new(nx, 0.0)
  (0...nx).each do |x|
    jx = jitter ? rand : 0.5
    res[x] = (x + jx) * dx
  end

  res
end

# TODO: this is a litte bit different in pbrt
def stratified_sample_2D(nx : Int32, ny : Int32, jitter = true)
  dx = 1.0 / nx
  dy = 1.0 / ny

  res = Array({Float64, Float64}).new(nx * ny, {0.0, 0.0})

  (0...ny).each do |y|
    (0...nx).each do |x|
      jx = jitter ? rand : 0.5
      jy = jitter ? rand : 0.5
      res[y * nx + x] = {(x + jx) * dx, (y + jy) * dy}
    end
  end

  res
end

def uniform_sample_hemisphere(u1 : Float64 = rand, u2 : Float64 = rand)
  z = u1
  r = Math.sqrt(1.0 - z*z)
  phi = TWOPI * u2

  x = r * Math.cos(phi)
  y = r * Math.sin(phi)

  Vector.new(x, y, z)
end

def uniform_hemisphere_pdf
  INV_TWOPI
end

def uniform_sample_sphere(u1 : Float64 = rand, u2 : Float64 = rand)
  z = 1.0 - 2.0 * u1
  r = Math.sqrt(1.0 - z*z)
  phi = TWOPI * u2
  x = r * Math.cos(phi)
  y = r * Math.sin(phi)

  Vector.new(x, y, z)
end

def uniform_sphere_pdf
  INV_FOURPI
end

def uniform_sample_disk(u1 : Float64 = rand, u2 : Float64 = rand) : {Float64, Float64}
  r = Math.sqrt(u1)
  theta = TWOPI * u2
  {
    r * Math.cos(theta),
    r * Math.sin(theta),
  }
end

def concentric_sample_disk(u1 : Float64 = rand, u2 : Float64 = rand) : {Float64, Float64}
  sx = 2.0 * u1 - 1.0
  sy = 2.0 * u2 - 1.0

  return {0.0, 0.0} if sx == 0.0 && sy == 0.0

  r = 0.0
  theta = 0.0

  if sx.abs > sy.abs
    r = sx
    theta = PI_OVER_FOUR * (sy / sx)
  else
    r = sy
    theta = PI_OVER_TWO - PI_OVER_FOUR * (sx / sy)
  end

  {r * Math.cos(theta), r * Math.sin(theta)}
end

def cosine_sample_hemisphere(u1 : Float64 = rand, u2 : Float64 = rand) : Vector
  x, y = concentric_sample_disk(u1, u2)
  Vector.new(x, y, Math.sqrt(1.0 - x*x - y*y))
end

def cosine_hemisphere_pdf(cos_theta : Float64)
  cos_theta * INV_PI
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

def solve_quadratic(a, b, c) : {Float64, Float64}?
  discriminant = b * b - 4.0 * a * c
  return nil if discriminant <= 0.0

  root_discriminant = Math.sqrt(discriminant)
  if b < 0.0
    q = -0.5 * (b - root_discriminant)
  else
    q = -0.5 * (b + root_discriminant)
  end

  t0 = q / a
  t1 = c / q
  t0 < t1 ? {t0, t1} : {t1, t0}
end

# Monte Carlo heuristics

def balance_heuristic(nf : Int32, f_pdf : Float64, ng : Int32, g_pdf : Float64)
  (nf * f_pdf) / (nf * f_pdf + ng * g_pdf)
end

def power_heuristic(nf : Int32, f_pdf : Float64, ng : Int32, g_pdf : Float64)
  f = nf * f_pdf
  g = ng * g_pdf
  (f*f) / (f*f + g*g)
end

struct Range2
  @min : {Int32, Int32}
  @max : {Int32, Int32}

  def initialize(@max)
    @min = {0, 0}
  end

  def initialize(@min, @max); end

  def each
    (@min[1]..@max[1]).each do |y|
      (@min[0]..@max[0]).each do |x|
        yield x, y
      end
    end
  end
end

struct Range3
  @min : {Int32, Int32, Int32}
  @max : {Int32, Int32, Int32}

  def initialize(@max)
    @min = {0, 0, 0}
  end

  def initialize(@min, @max); end

  def each
    (@min[2]..@max[2]).each do |z|
      (@min[1]..@max[1]).each do |y|
        (@min[0]..@max[0]).each do |x|
          yield x, y, z
        end
      end
    end
  end
end
