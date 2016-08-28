struct Quaternion
  getter x : Float64
  getter y : Float64
  getter z : Float64
  getter w : Float64

  def initialize(@x, @y, @z, @w)
  end

  def initialize(@x : Float64, yzw : Vec3)
    @y = yzw.x
    @z = yzw.y
    @w = yzw.z
  end

  def initialize(xyz : Vec3, @w : Float64)
    @x = xyz.x
    @y = xyz.y
    @z = xyz.z
  end

  def squared_length
    @x*@x + @y*@y + @z*@z + @w*@w
  end

  def length
    Math.sqrt(squared_length)
  end

  # Swizzling, generate functions like vec.zzz, vec.xyz, etc
  # prefixing "x", "y", "z" or "w" with "_" means negating the value
  {% for first in %w(x y z w) %}
    {% for second in %w(x y z w) %}
      {% for third in %w(x y z w) %}
        def {{first.id}}{{second.id}}{{third.id}}
          Vec3.new(@{{first.id}}, @{{second.id}}, @{{third.id}})
        end
        def _{{first.id}}{{second.id}}{{third.id}}
          Vec3.new(-@{{first.id}}, @{{second.id}}, @{{third.id}})
        end
        def {{first.id}}_{{second.id}}{{third.id}}
          Vec3.new(@{{first.id}}, -@{{second.id}}, @{{third.id}})
        end
        def _{{first.id}}_{{second.id}}{{third.id}}
          Vec3.new(-@{{first.id}}, -@{{second.id}}, @{{third.id}})
        end
        def {{first.id}}{{second.id}}_{{third.id}}
          Vec3.new(@{{first.id}}, @{{second.id}}, -@{{third.id}})
        end
        def _{{first.id}}{{second.id}}_{{third.id}}
          Vec3.new(-@{{first.id}}, @{{second.id}}, -@{{third.id}})
        end
        def {{first.id}}_{{second.id}}_{{third.id}}
          Vec3.new(@{{first.id}}, -@{{second.id}}, -@{{third.id}})
        end
        def _{{first.id}}_{{second.id}}_{{third.id}}
          Vec3.new(-@{{first.id}}, -@{{second.id}}, -@{{third.id}})
        end
      {% end %}
    {% end %}
  {% end %}

  {% for op in %w(+ - * /) %}
    def {{op.id}}(other : Quaternion)
      Quaternion.new(@x {{op.id}} other.x, @y {{op.id}} other.y, @z {{op.id}} other.z, @w {{op.id}} other.w)
    end

    def {{op.id}}(other : Float)
      Quaternion.new(@x {{op.id}} other, @y {{op.id}} other, @z {{op.id}} other, @w {{op.id}} other)
    end

    def {{op.id}}(other : Int)
      Quaternion.new(@x {{op.id}} other, @y {{op.id}} other, @z {{op.id}} other, @w {{op.id}} other)
    end
  {% end %}
end
