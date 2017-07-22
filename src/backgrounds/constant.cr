module Background
  class Constant < Abstract
    def initialize(@color : Color)
    end

    def get(ray)
      @color
    end
  end
end
