record Photon,
  point : Point,
  alpha : Color,
  wi : Vector

record RadiancePhoton,
  point : Point,
  normal : Normal,
  lo : Color = Color::BLACK

# TODO: Currently, this doesn't create any Photons for the background
class PhotonMappingRaytracer < BaseRaytracer
  def initialize(width, height, camera, samples, scene, filter = BoxFilter.new(0.5))
    super(width, height, camera, samples, scene, filter)

    @n_caustic_photons = 10000
    @n_indirect_photons = 10000

    @n_caustic_photons_wanted = @n_caustic_photons
    @n_indirect_photons_wanted = @n_indirect_photons

    @max_photon_depth = 10

    @final_gather = true

    @caustic_photons = [] of Photon
    @direct_photons = [] of Photon
    @indirect_photons = [] of Photon

    @radiance_photons = [] of RadiancePhoton
    @radiance_photon_reflectances = [] of Color
    @radiance_photon_transmissions = [] of Color

    gather_photons
  end

  def gather_photons
    return if @scene.lights.size == 0

    # Declare shared variables
    n_direct_paths = 0
    n_shoot = 0

    # compute light power CDF

    light_distribution = @scene.light_sampling_CDF

    # run photon shooting

    loop do
      # choose light to shoot from
      light_n, light_pdf = light_distribution.sample
      light = @scene.lights[light_n.to_i]

      # generate photon_ray from light source & initialize alpha
      le, photon_ray, normal, pdf = light.sample_l
      next if pdf == 0.0 || le.black?

      # TODO: Should the direction be normalized first?
      #       for the currently supported lights it should already be normalize
      alpha = le * normal.dot(photon_ray.direction) / (pdf * light_pdf)

      unless alpha.black?
        # follow photon path through scene and record intersections

        specular_path = true
        n_intersections = 0

        loop do
          photon_hit = @scene.hit(photon_ray)
          break if photon_hit.nil?

          n_intersections += 1

          # Handle photon/surface intersection
          photon_bsdf = photon_hit.material.bsdf(photon_hit)

          specular_type = BxDFType::SPECULAR | BxDFType::REFLECTION | BxDFType::TRANSMISSION
          has_non_specular = photon_bsdf.num_components > photon_bsdf.num_components(specular_type)

          wo = -photon_ray.direction

          # We don't use photons for rendering reflections from specular surfaces
          if has_non_specular
            # Deposit photon at surface

            photon = Photon.new(photon_hit.point, alpha, wo)
            deposited_photon = false

            if specular_path && n_intersections > 1
              unless caustic_done?
                deposited_photon = true
                @caustic_photons << photon
                @n_caustic_photons_wanted -= 1
              end
            else
              # Deposit either direct or indirect photon
              if n_intersections == 1 && !indirect_done? && @final_gather
                @direct_photons << photon
                
                # TODO: remove
                @n_indirect_photons_wanted -= 1
              elsif !indirect_done?
                @indirect_photons << photon
                @n_indirect_photons_wanted -= 1
              end
            end

            # Possibly create radiance photon at photon intersection point
            if deposited_photon && @final_gather && rand < 0.125
              n = photon_hit.normal
              n = n.face_forward(-photon_ray.direction)

              @radiance_photons << RadiancePhoton.new(photon_hit.point, n)

              @radiance_photon_reflectances << photon_bsdf.rho(BxDFType::ALLREFLECTION)
              @radiance_photon_transmissions << photon_bsdf.rho(BxDFType::ALLTRANSMISSION)
            end
          end

          break if n_intersections >= @max_photon_depth

          # Sample new photon ray direction
          
          sample = photon_bsdf.sample_f(wo, BxDFType::ALL)
          break if sample.nil?

          fr, wi, pdf, sampled_type = sample
          break if pdf == 0.0

          a_new = alpha * fr * wi.dot(photon_hit.normal).abs / pdf

          # Possibly terminate w/ russian roulette
          # TODO: use maximum of path_throughput here
          continue_prob = min(1.0, a_new.g / alpha.g)
          break if rand > continue_prob
          alpha = a_new / continue_prob

          specular_path &= ((sampled_type & BxDFType::SPECULAR) != 0)
          break if indirect_done? && caustic_done?

          photon_ray = Ray.new(photon_hit.point, wi)
        end
        break if indirect_done? && caustic_done?
      end
    end

    # build kd-trees for incident & caustic photons

    # precompute radiance at a subset of the photons
  end

  def render(canvas : StumpyPNG::Canvas)
    @caustic_photons.each do |cp|
      x, y = @camera.corresponding(cp.point)
      canvas.safe_set(x, y, StumpyPNG::RGBA.from_hex("#ff0000"))
    end

    @indirect_photons.each do |cp|
      x, y = @camera.corresponding(cp.point)
      canvas.safe_set(x, y, StumpyPNG::RGBA.from_hex("#00ff00"))
    end

    @radiance_photons.each do |cp|
      x, y = @camera.corresponding(cp.point)
      canvas.safe_set(x, y, StumpyPNG::RGBA.from_hex("#0000ff"))
    end
  end

  def render(filename : String)
    canvas = StumpyPNG::Canvas.new(@width, @height, StumpyPNG::RGBA.from_hex("#000000"))
    render(canvas)
    StumpyPNG.write(canvas, filename)
  end

  def caustic_done?
    @n_caustic_photons_wanted == 0
  end

  def indirect_done?
    @n_indirect_photons_wanted == 0
  end
end
