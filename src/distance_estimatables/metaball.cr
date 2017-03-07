module DE
  class Metaball < DE::BruteForceDistanceEstimatable
    def initialize(@points : Array(Tuple(Point, Float64)), @threshold : Float64); end

    def inside?(pos)
      potential = 0.0
      @points.each do |p_i, r_i|
        potential += r_i / (pos - p_i).squared_length
      end
      potential > @threshold
    end

    def normal(pos)
      n = Vector.zero
      @points.each do |p_i, r_i|
        a = -2.0 * r_i
        b = p_i - pos
        c = (p_i - pos).squared_length
        n = n + b * (a / c)
      end

      n.to_normal
    end
  end
end
