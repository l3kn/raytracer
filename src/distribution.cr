class Distribution1D
  getter func : Array(Float64)
  getter func_integral : Float64
  getter cdf : Array(Float64)
  getter count : Int32

  # Compute a 1D distrubution
  # from a piecewise constant function
  # by converting it to a CDF
  def initialize(f : Array(Float64))
    @count = f.size
    @func = f.clone
    @cdf = Array.new(@count + 1, 0.0)

    (1..f.size).each do |i|
      @cdf[i] = @cdf[i-1] + func[i-1] / @count
    end

    @func_integral = @cdf[@count]

    @cdf.map!(&./(@func_integral))
  end

  # returns a sample point + its pdf
  def sample : {Float64, Float64}
    u = rand

    offset = @cdf.size - 1

    while @cdf[offset] > u
      offset -= 1
      break if offset == 0
    end

    du = (u - @cdf[offset]) / (@cdf[offset+1] - @cdf[offset])
    pdf = @func[offset] / @func_integral

    {(offset + du) / @count, pdf}
  end
end
