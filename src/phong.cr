class Light
  property position : Vec3
  property i_d : Vec3
  property i_s : Vec3

  def initialize(@position, intensity)
    @i_d = intensity
    @i_s = intensity
  end
end

class Phong < Material
  property k_a : Vec3 # Ambient reflection constant
  property k_d : Vec3 # Diffuse reflection constant
  property k_s : Vec3 # Specular reflection constant
  property a : Float64 # Shininess constant

  def initialize(@k_a, @k_d, @k_s, @a = 1.0)
  end

  def shade(hit, viewer_vec, light_vec, light, lambda)
    normal = hit.normal

    h = (viewer_vec + light_vec) / (viewer_vec + light_vec).length

    l_d = @k_d * light.i_d * [0, normal.dot(light_vec)].max # Diffuse
    l_s = @k_s * light.i_s * ([0, normal.dot(h)].max ** @a) # Specular

    l_d + l_s
  end
end

class Glazed < Material
  property k_a : Vec3 # Ambient reflection constant
  property k_d : Vec3 # Diffuse reflection constant

  def initialize(@k_a, @k_d)
  end

  def shade(hit, viewer_vec, light_vec, light, lambda)
    normal = hit.normal

    reflected = Ray.new(hit.point, (-viewer_vec).reflect(normal))
    l_d = @k_d * light.i_d * [0, normal.dot(light_vec)].max # Diffuse
    l_m = lambda.call(reflected) # Reflection

    l_d + l_m
  end
end
