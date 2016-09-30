struct Point
  getter x, y, z

  def initialize
    @x, @y, @z = 0.0, 0.0, 0.0
  end

  def initialize(value : Float64)
    @x, @y, @z = value, value, value
  end

  def initialize(@x : Float64, @y : Float64, @z : Float64)
  end

  # Allow construction like this: foo = Point.new(bar.xy, 1.0)
  def initialize(xy : Tuple(Float64, Float64), @z)
    @x, @y = xy
  end

  def initialize(@x, yz : Tuple(Float64, Float64))
    @y, @z = yz
  end

  {% for op in %w(+ -) %}
    def {{op.id}}(other : Vector)
      Point.new(@x {{op.id}} other.x, @y {{op.id}} other.y, @z {{op.id}} other.z)
    end
  {% end %}

  def -(other : Point)
    Vector.new(@x - other.x, @y - other.y, @z - other.z)
  end

  def *(other : (Float64 | Int32))
    Point.new(@x * other, @y * other, @z * other)
  end

  def max(other : Point)
    Point.new(max(@x, other.x), max(@y, other.y), max(@z, other.z))
  end

  def min(other : Point)
    Point.new(min(@x, other.x), min(@y, other.y), min(@z, other.z))
  end

  def dot(other : (Vector | Normal | Point))
    @x * other.x + @y * other.y + @z * other.z
  end

  # TODO: the methods below are only needed for some DE Primitives
  def abs
    Point.new(@x.abs, @y.abs, @z.abs)
  end

  def squared_length
    dot(self)
  end

  def length
    Math.sqrt(squared_length)
  end

  # Swizzling, generate functions like vec.zzz, vec.xyz, etc
  # prefixing "x", "y" or "z" with "_" means negating the value
  {% for first in %w(x y z) %}
    {% for second in %w(x y z) %}
      {% for third in %w(x y z) %}
        def {{first.id}}{{second.id}}{{third.id}}
          Point.new(@{{first.id}}, @{{second.id}}, @{{third.id}})
        end
        def _{{first.id}}{{second.id}}{{third.id}}
          Point.new(-@{{first.id}}, @{{second.id}}, @{{third.id}})
        end
        def {{first.id}}_{{second.id}}{{third.id}}
          Point.new(@{{first.id}}, -@{{second.id}}, @{{third.id}})
        end
        def _{{first.id}}_{{second.id}}{{third.id}}
          Point.new(-@{{first.id}}, -@{{second.id}}, @{{third.id}})
        end
        def {{first.id}}{{second.id}}_{{third.id}}
          Point.new(@{{first.id}}, @{{second.id}}, -@{{third.id}})
        end
        def _{{first.id}}{{second.id}}_{{third.id}}
          Point.new(-@{{first.id}}, @{{second.id}}, -@{{third.id}})
        end
        def {{first.id}}_{{second.id}}_{{third.id}}
          Point.new(@{{first.id}}, -@{{second.id}}, -@{{third.id}})
        end
        def _{{first.id}}_{{second.id}}_{{third.id}}
          Point.new(-@{{first.id}}, -@{{second.id}}, -@{{third.id}})
        end
      {% end %}
    {% end %}
  {% end %}

  # TODO: this is somewhat inconsistent with the swizzling methods above
  def xyz
    {@x, @y, @z}
  end

  {% for first in %w(x y z) %}
    {% for second in %w(x y z) %}
      def {{first.id}}{{second.id}}
        { @{{first.id}}, @{{second.id}} }
      end
    {% end %}
  {% end %}
end


