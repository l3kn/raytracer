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
    assert(@func_integral > 0.0)

    @cdf.map!(&./(@func_integral))
  end

  def sample_discrete : {Int32, Float64}
    u = rand
    offset = @cdf.size - 1

    while @cdf[offset] > u
      offset -= 1
      break if offset == 0
    end

    pdf = @func[offset] / (@func_integral * @count)
    {offset, pdf}
  end
end
