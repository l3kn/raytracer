class Raytracer
  record VisiblePoint, point : Point, wo : Vector, bsdf : BSDF, throughput : ::Color

  # NOTE:
  # This needs to be a class instead of a struct
  # bc/ of the way grid and pixels interact and mutate each others values
  class SPPMPixel
    getter radius : Float64, n : Float64, phi : ::Color, m : Int32
    property tau : ::Color, ld : ::Color, vp : VisiblePoint?

    def initialize(
      @radius = 0.0, @ld = ::Color::BLACK, @vp = nil, @m = 0, @n = 0.0,
      @tau = ::Color::BLACK, @phi = ::Color::BLACK
    )
    end

    def add_phi(new_phi)
      @phi += new_phi
      @m += 1
    end

    def update!
      if @m > 0
        vp_ = @vp
        raise "Pixel VisiblePoint should not be nil if m is > 0 " if vp_.nil?

        # Update pixel photon count, search radius, and tau from photons
        gamma = 2.0 / 3.0
        n_new = @n + gamma * @m
        r_new = @radius * Math.sqrt(n_new / (@n + @m))
        tau_old = @tau
        @tau = (tau_old + vp_.throughput * @phi) * (r_new ** 2) / (@radius ** 2)

        @n, @radius = n_new, r_new
        @m, @phi = 0, ::Color::BLACK
      end

      @vp = nil
    end
  end

  class SPPM < Raytracer
    property photons_per_iteration : Int32
    property initial_search_radius : Float64
    property recursion_depth : Int32
    property iterations : Int32

    def initialize(dimensions, camera, samples, scene)
      @photons_per_iteration = dimensions[0] * dimensions[1]
      @initial_search_radius = 1.0
      @iterations = 1024
      @recursion_depth = 5
      super(dimensions, camera, samples, scene)
    end

    def hash(p, size)
      ((p[0] * 73856093) ^ (p[1] * 19349663) ^ (p[2] * 83492791)) % size
    end

    def to_grid(point, bounds, grid_res)
      in_bounds = true
      point_grid = bounds.offset(point)

      point_index = Array(Int32).new(3) do |i|
        v = (grid_res[i] * point_grid[i]).to_i
        in_bounds &= v >= 0 && v < grid_res[i]
        clamp(v, 0, grid_res[i] - 1)
      end

      {in_bounds, {point_index[0], point_index[1], point_index[2]}}
    end

    def render_to_canvas(filename, adaptive = false)
      start = Time.now

      n_pixels = @width * @height
      pixels = Array.new(n_pixels) { SPPMPixel.new(@initial_search_radius) }
      light_distribution = @scene.light_sampling_CDF

      # window = StumpyX11.new(@width, @height)

      @iterations.times do |iter|
        puts "Iteration #{iter + 1} / #{@iterations}"
        Range2.new({@width - 1, @height - 1}).each do |x, y|
          pixel = pixels[x + y * @width]
          path_throughput = ::Color::WHITE
          specular_bounce = false

          # TODO: use some better sampling method
          ray = @camera.generate_ray(x + rand, y + rand, EPSILON, Float64::MAX)

          (0...@recursion_depth).each do |depth|
            hit = @scene.hit(ray)
            if hit.nil?
              pixel.ld += path_throughput * @scene.get_background(ray)
              break
            end

            bsdf = hit.material.bsdf(hit)

            # Accumulate direct illumination at SPPM camera ray intersection
            wo = -ray.direction
            pixel.ld += path_throughput * bsdf.emitted(wo) if depth == 0 || specular_bounce
            pixel.ld += path_throughput * uniform_sample_one_light(hit, bsdf, wo)
            pixel.ld += path_throughput * estimate_background(hit, bsdf, wo)

            if bsdf.diffuse? || (bsdf.glossy? && depth == @recursion_depth - 1)
              pixel.vp = VisiblePoint.new(hit.point, wo, bsdf, path_throughput)
              break
            end

            # Spawn ray from SPPM camera path vertex
            if depth < @recursion_depth - 1
              sample = bsdf.sample_f(wo, BxDF::Type::All)
              break if sample.nil? || !sample.relevant?

              specular_bounce = sample.type.specular?
              path_throughput *= sample.color * sample.dir.dot(hit.normal).abs / sample.pdf

              # TODO: change the equivalent code in
              # path integrator to look more like this
              if path_throughput.max_component < 0.25
                continue_probability = path_throughput.max_component
                break if rand > continue_probability
                path_throughput /= continue_probability
              end

              ray = Ray.new(hit.point, sample.dir)
            end
          end

          pixels[x + y * @width] = pixel
        end

        # Create a grid of all SPPM visible points
        grid = Array.new(n_pixels) { [] of SPPMPixel }

        # Compute grid bounds for SPPM visible points
        # TODO: Test if this could be sped up
        grid_bounds = AABB.new
        max_radius = 0.0

        pixels.each do |pixel|
          vp = pixel.vp
          next if vp.nil?

          grid_bounds = grid_bounds.merge(AABB.around(vp.point, pixel.radius))
          max_radius = max(max_radius, pixel.radius)
        end

        # Compute resolution of SPPM grid in each dimension
        diagonal = grid_bounds.diagonal
        max_diagonal = diagonal.max_component
        base_grid_reg = max_diagonal / max_radius

        grid_res = {
          max(1, (base_grid_reg * diagonal[0] / max_diagonal).to_i),
          max(1, (base_grid_reg * diagonal[1] / max_diagonal).to_i),
          max(1, (base_grid_reg * diagonal[2] / max_diagonal).to_i),
        }

        # Add visible points to SPPM grid
        pixels.each_with_index do |pixel, i|
          vp = pixel.vp
          next if vp.nil? || vp.throughput.black?

          offset = Vector.new(pixel.radius)
          in_bounds, p_min = to_grid(vp.point - offset, grid_bounds, grid_res)
          in_bounds, p_max = to_grid(vp.point + offset, grid_bounds, grid_res)

          Range3.new(p_min, p_max).each do |x, y, z|
            h = hash([x, y, z], n_pixels)
            grid[h].push(pixel)
          end
        end

        # Trace photons and accumulate contributions
        @photons_per_iteration.times do |photon_index|
          # if photon_index % 100 == 0
          #   print "\rTracing photon #{photon_index + 1} of #{@photons_per_iteration}"
          # end
          # Choose light to shoot photon from
          light_n, light_pdf = light_distribution.sample_discrete
          light = @scene.lights[light_n]

          # generate photon_ray from light source & initialize alpha
          l_sample = light.sample_l
          next unless l_sample.relevant?

          photon_ray = l_sample.ray
          path_throughput = (l_sample.color * l_sample.normal.dot(photon_ray.direction.normalize).abs) / (light_pdf * l_sample.pdf)
          next if path_throughput.black?

          (0...@recursion_depth).each do |depth|
            hit = @scene.hit(photon_ray)
            break if hit.nil?

            if depth > 0
              in_bounds, photon_grid_index = to_grid(hit.point, grid_bounds, grid_res)
              if in_bounds
                h = hash(photon_grid_index, n_pixels)

                # Add photon contribution to visible points in grid[h]
                grid[h].each do |pixel|
                  vp = pixel.vp
                  raise "Pixel VisiblePoint should not be nil here: #{pixel}" if vp.nil?
                  next if hit.point.squared_distance(vp.point) > (pixel.radius ** 2)

                  wi = -photon_ray.direction
                  pixel.add_phi(path_throughput * vp.bsdf.f(vp.wo, wi, BxDF::Type::All))
                end
              end
            end
            # Sample new photon ray direction
            # # Compute BSDF at photon intersection point

            photon_bsdf = hit.material.bsdf(hit)
            wo = -photon_ray.direction

            sample = photon_bsdf.sample_f(wo, BxDF::Type::All)
            break if sample.nil? || !sample.relevant?

            new_throughput = path_throughput * sample.color * sample.dir.dot(hit.normal).abs / sample.pdf

            # Possibly terminate photon path w/ russian roulette
            q = max(0.0, 1.0 - new_throughput.max_component / path_throughput.max_component)
            break if rand < q

            path_throughput = new_throughput / (1.0 - q)
            photon_ray = Ray.new(hit.point, sample.dir)
          end
        end

        # Update pixel values from this pass's photons
        pixels.each(&.update!)

        # Update the output image every few iterations
        # window.write(write_to_canvas(pixels, iter))
        # if iter > 0 && iter % 100 == 0
        #   # StumpyPNG.write(
        #   #   write_to_canvas(pixels, iter),
        #   #   "iter#{iter.to_s.rjust(4, '0')}_#{filename}"
        #   )
        # end
      end

      time = Time.now - start
      puts "\nTime: #{(time.total_milliseconds / 1000).round(3)}s"

      write_to_canvas(pixels)
    end

    def write_to_canvas(pixels, n = @iterations)
      np = (n + 1) * @photons_per_iteration

      StumpyPNG::Canvas.new(@width, @height) do |x, y|
        pixel = pixels[x + y * @width]
        l = pixel.ld / (n + 1).to_f
        l += pixel.tau / (np * Math::PI * pixel.radius * pixel.radius)
        l.to_rgba(@gamma_correction)
      end
    end
  end
end
