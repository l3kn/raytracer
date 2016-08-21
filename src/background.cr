class Background
  def get(ray)
    return Vec3.new(0.0)
  end
end

class BackgroundConverter
  def self.from_json(json)
    type = nil
    color = nil

    json.read_object do |key|
      case key
      when "type"
        type = json.read_string
      when "color"
        color = Vec3.new(json)
      end
    end

    raise "JSON Error, missing field 'type'" if type.nil?

    case type
    when "sky"
      return SkyBackground.new
    when "constant"
      raise "JSON Error, missing field 'color'" if color.nil?
      return ConstantBackground.new(color)
    else
      return ConstantBackground.new(Vec3.new(1.0))
    end
  end

  def self.to_json(value, io)
  end
end
