require "../vector"
require "../distance_estimatable"

module DE
  class Metaball < DE::BruteForceDistanceEstimatable
    getter points : Array(Tuple(Vec3, Float64))
    getter threshold : Float64

    def initialize(@points, @threshold)
    end

    def inside?(pos)
      potential = 0.0

      @points.each do |p_i, r_i|
        potential += r_i / (pos - p_i).squared_length
      end

      potential > @threshold
    end

    def normal(pos)
      n = Vec3::ZERO
      @points.each do |p_i, r_i|
        a = -2.0 * r_i
        b = p_i - pos
        c = (p_i - pos).squared_length
        n = n + b * (a / c) 
      end

      n.normalize
    end
  end
end
