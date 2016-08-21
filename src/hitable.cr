record Intersection,
  t : Float64, # Ray parameter of the hitpoint
  point : Vec3,
  normal : Vec3,
  material : Material,
  u : Float64, # Vars for texture mapping
  v : Float64

abstract class Hitable
  abstract def hit(ray : Ray, t_min : Float, t_max : Float) : (Intersection | Nil)
  abstract def bounding_box

  def box_min_on_axis(n)
    bounding_box.min.xyz[n]
  end
end

class HitableConverter
  def self.from_json(json)
    result = [] of Hitable
    json.read_array do
      h = single_from_json(json)
      p h
      unless h.nil?
        result << h
      end
    end
    result
  end
  def self.single_from_json(json)
    type = nil
    center = nil
    radius = nil
    material = nil

    json.read_object do |key|
      case key
      when "type"
        type = json.read_string
      when "center"
        center = Vec3.new(json)
      when "radius"
        radius = json.read_float
      when "material"
        material = MaterialConverter.from_json(json)
      end
    end

    raise "JSON Error, missing field 'material'" if material.nil?
    raise "JSON Error, missing field 'type'" if type.nil?

    case type
    when "sphere"
      raise "JSON Error, missing field 'center'" if center.nil?
      raise "JSON Error, missing field 'radius'" if radius.nil?
      return Sphere.new(center, radius, material)
    else
      raise "JSON Error, missing field 'type'"
    end
  end

  def self.to_json(value, io)
    # TODO
  end
end
