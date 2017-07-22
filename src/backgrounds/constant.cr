module Background
  class Constant < ABackground
    def initialize(@color : Color)
    end

    def get(ray)
      @color
    end
  end
end
