require "../hitable"
require "../aabb"

class Translate < Hitable
  getter offset : Vec3
  getter object : Hitable
  getter bounding_box : AABB

  def initialize(@object, @offset)
    @bounding_box = AABB.new(
      @object.bounding_box.min + @offset,
      @object.bounding_box.max + @offset,
    )
  end

  def hit(ray, t_min, t_max)
    moved_ray = Ray.new(ray.origin - @offset, ray.direction)

    hit = @object.hit(moved_ray, t_min, t_max)
    if hit
      HitRecord.new(
        hit.t,
        hit.point + @offset,
        hit.normal,
        hit.material,
        hit.u, hit.v
      )
    else
      nil
    end
  end

  def pdf_value(origin, direction)
    @object.pdf_value(origin - @offset, direction)
  end

  def random(origin)
    @object.random(origin - @offset)
  end
end
