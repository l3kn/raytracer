module Background
  class Sky < ABackground
    def get(ray)
      t = 0.5 * (ray.direction.normalize.y + 1.0)
      Color.new(0.5, 0.7, 1.0).mix(Color::WHITE, t)
    end
  end
end
