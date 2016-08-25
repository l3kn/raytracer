require "./ray"
require "./vec3"
require "./pdf"

# Either there result contains a pdf or a specular ray
record ScatterRecord,
  albedo : Vec3,
  pdf_or_ray : (PDF | Ray)

class Material
  def scatter(ray : Ray, hit : Intersection)
    nil
  end

  def scattering_pdf(ray_in : Ray, hit : Intersection, scattered : Ray)
    0.0
  end

  def emitted(ray, hit)
    Vec3::ZERO
  end
end
