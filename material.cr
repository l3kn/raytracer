abstract class Material
  abstract def scatter(ray : Ray, hit : Intersection)
end

class Lambertian < Material
  property albedo

  def initialize(@albedo)
  end

  def scatter(ray, hit)
    target = hit.point + hit.normal + random_in_unit_sphere

    scattered = Ray.new(hit.point, target - hit.point)
    {scattered, @albedo}
  end
end

class Metal < Material
  property albedo, fuzz
  def initialize(@albedo, @fuzz = 0.0)
  end

  def scatter(ray, hit)
    reflected = ray.direction.normalize.reflect(hit.normal)
    scattered = Ray.new(hit.point, reflected + random_in_unit_sphere*@fuzz)

    if scattered.direction.dot(hit.normal) > 0
      {scattered, albedo}
    else
      nil
    end
  end
end

class Dielectric < Material
  property reflection_index

  def initialize(@reflection_index)
  end

  def scatter(ray, hit)
    dir = ray.direction
    reflected = dir.reflect(hit.normal)

    dir_normal = dir.dot(hit.normal)

    if dir_normal > 0
      outward_normal = -hit.normal
      ni_over_nt = @reflection_index
      cosine = @reflection_index * dir_normal / ray.direction.length
    else
      outward_normal = hit.normal
      ni_over_nt = 1.0 / @reflection_index
      cosine = -dir_normal / ray.direction.length
    end

    refracted = ray.direction.refract(outward_normal, ni_over_nt)

    if refracted
      reflect_prob = schlick(cosine, @reflection_index)
    else
      scattered = Ray.new(hit.point, reflected)
      return {scattered, Vec3.new(1.0)}
    end

    if rand < reflect_prob
      scattered = Ray.new(hit.point, reflected)
    else
      scattered = Ray.new(hit.point, refracted)
    end

    {scattered, Vec3.new(1.0)}

  end
end
