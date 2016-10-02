require "./point"
require "./vector"
require "./aabb"
require "./ray"
require "./color"
require "./normal"
require "./materials/*"
require "./hitable"

struct ExtendedRay
  getter origin : Point
  getter direction : Vector

  getter s_yx : Float64, s_xy : Float64, s_zy : Float64, s_yz : Float64, s_xz : Float64, s_zx : Float64
  getter c_yx : Float64, c_xy : Float64, c_zy : Float64, c_yz : Float64, c_xz : Float64, c_zx : Float64
  getter x_type : Symbol
  getter y_type : Symbol
  getter z_type : Symbol

  def classifyComponent(c : Float64)
    if c.abs < 0.0001 # TODO: add global epsilon constant
      :o
    else
      c > 0.0 ? :p : :m
    end
  end

  def initialize(ray : Ray)
    @origin = ray.origin
    @direction = ray.direction

    @x_type = classifyComponent(@direction.x)
    @y_type = classifyComponent(@direction.y)
    @z_type = classifyComponent(@direction.z)

    inv_x = 1.0 / @direction.x
    inv_y = 1.0 / @direction.y
    inv_z = 1.0 / @direction.z

    # Slopes
    @s_yx = @direction.x * inv_y
    @s_xy = @direction.y * inv_x
    @s_zy = @direction.y * inv_z
    @s_yz = @direction.z * inv_y
    @s_xz = @direction.z * inv_x
    @s_zx = @direction.x * inv_z

    # Precomputation
    @c_xy = @origin.y - @s_xy * @origin.x
    @c_yx = @origin.x - @s_yx * @origin.y
    @c_zy = @origin.y - @s_zy * @origin.z
    @c_yz = @origin.z - @s_yz * @origin.y
    @c_xz = @origin.z - @s_xz * @origin.x
    @c_zx = @origin.x - @s_zx * @origin.z
  end

  # TODO: why do we even need this?
  def point_at_parameter(t)
    @origin + (@direction * t)
  end

  def hits_aabb?(box : AABB)
    {% for x_type in %w(M O P) %}
      {% if x_type == "M" %} if @x_type == :m
      {% elsif x_type == "O" %} elsif @x_type == :o
      {% else %} else {% end %}
      {% for y_type in %w(M O P) %}
        {% if y_type == "M" %} if @y_type == :m
        {% elsif y_type == "O" %} elsif @y_type == :o
        {% else %} else {% end %}
        {% for z_type in %w(M O P) %}
          {% if z_type == "M" %} if @z_type == :m
          {% elsif z_type == "O" %} elsif @z_type == :o 
          {% else %} else {% end %}
            !(
              {% if x_type == "M" %}
                @origin.x < box.min.x ||
              {% elsif x_type == "O" %}
                @origin.x < box.min.x || @origin.x > box.max.x ||
              {% else %}
                @origin.x > box.max.x ||
              {% end %}

              {% if y_type == "M" %}
                @origin.y < box.min.y ||
              {% elsif y_type == "O" %}
                @origin.y < box.min.y || @origin.y > box.max.y ||
              {% else %}
                @origin.y > box.max.y ||
              {% end %}

              {% if z_type == "M" %}
                @origin.z < box.min.z ||
              {% elsif z_type == "O" %}
                @origin.z < box.min.z || @origin.z > box.max.z ||
              {% else %}
                @origin.z > box.max.z ||
              {% end %}

              {% if x_type != "O" && y_type != "O" %}
                @s_yx * \
                {% if y_type == "P" %} box.max.y {% else %} box.min.y {% end %} - \
                {% if x_type == "M" %} box.max.x {% else %} box.min.x {% end %} \
                + @c_yx \
                {% if x_type == "P" %} < {% else %} > {% end %} 0 ||
                @s_xy * \
                {% if x_type == "P" %} box.max.x {% else %} box.min.x {% end %} - \
                {% if y_type == "M" %} box.max.y {% else %} box.min.y {% end %} \
                + @c_xy \
                {% if y_type == "P" %} < {% else %} > {% end %} 0 ||
              {% end %}

              {% if y_type != "O" && z_type != "O" %}
                @s_zy * \
                {% if z_type == "P" %} box.max.z {% else %} box.min.z {% end %} - \
                {% if y_type == "M" %} box.max.y {% else %} box.min.y {% end %} \
                + @c_zy \
                {% if y_type == "P" %} < {% else %} > {% end %} 0 ||
                @s_yz * \
                {% if y_type == "P" %} box.max.y {% else %} box.min.y {% end %} - \
                {% if z_type == "M" %} box.max.z {% else %} box.min.z {% end %} \
                + @c_yz \
                {% if z_type == "P" %} < {% else %} > {% end %} 0 ||
              {% end %}

              {% if z_type != "O" && x_type != "O" %}
                @s_zx * \
                {% if z_type == "P" %} box.max.z {% else %} box.min.z {% end %} - \
                {% if x_type == "M" %} box.max.x {% else %} box.min.x {% end %} \
                + @c_zx \
                {% if x_type == "P" %} < {% else %} > {% end %} 0 ||
                @s_xz * \
                {% if x_type == "P" %} box.max.x {% else %} box.min.x {% end %} - \
                {% if z_type == "M" %} box.max.z {% else %} box.min.z {% end %} \
                + @c_xz \
                {% if z_type == "P" %} < {% else %} > {% end %} 0 ||
              {% end %}
              false # This is necessary so that inside the macros we can add || all the time
            )
          {% if z_type == "P" %} {{ "end".id }} {% end %}
        {% end %}
        {% if y_type == "P" %} {{ "end".id }} {% end %}
      {% end %}
      {% if x_type == "P" %} {{ "end".id }} {% end %}
    {% end %}
  end
end
