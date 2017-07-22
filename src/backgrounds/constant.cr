class Background
  # A backgound that has the same color everywhere
  class Constant < Background
    def initialize(@color : Color)
    end

    def get(ray)
      @color
    end
  end
end
