record Scattered,
  ray : Ray,
  albedo : Vec3

class Material
  def scatter(ray : Ray, hit : Intersection)
    nil
  end

  def emitted(point)
    Vec3.new(0.0)
  end
end

class MaterialConverter
  def self.from_json(json)
    type = nil
    fuzz = nil
    reflection_index = nil
    texture = nil

    json.read_object do |key|
      case key
      when "type"
        type = json.read_string
      when "fuzz"
        fuzz = json.read_float
      when "reflection_index"
        reflection_index = json.read_float
      when "texture"
        texture = TextureConverter.from_json(json)
      end
    end

    raise "JSON Error, missing field 'type'" if type.nil?

    case type
    when "lambertian"
      raise "JSON Error, missing field 'texture'" if texture.nil?
      return Lambertian.new(texture)
    when "metal"
      raise "JSON Error, missing field 'texture'" if texture.nil?
      raise "JSON Error, missing field 'fuzz'" if fuzz.nil?
      return Metal.new(texture, fuzz)
    when "dielectric"
      raise "JSON Error, missing field 'reflection_index'" if reflection_index.nil?
      return Dielectric.new(reflection_index)
    end

    return Lambertian.new(ConstantTexture.new(Vec3.new(0.8)))
  end

  def self.to_json(value, io)
    # TODO
  end
end
