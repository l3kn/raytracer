class Background
  class Constant < Background
    def initialize(@color : Color)
    end

    def get(ray)
      @color
    end
  end
end
