# TODO: Nesting CSGs seems to be broken sometimes,
# maybe because rays starting inside them don't intersect properly
module CSG
  record TaggedHitRecord, hit : HitRecord, tag : Symbol do
    def entering?
      @tag == :entering
    end

    def leaving?
      @tag == :leaving
    end
  end

  record Span, from : HitRecord?, to : HitRecord do
    def intersection(other : Span) : Span?
      other_from = other.from
      self_from = @from
      if self_from && other_from
        if other_from.t > @to.t || other.to.t < self_from.t
          nil
        else
          Span.new(
            other_from.t < self_from.t ? self_from : other_from,
            other.to.t < @to.t ? other.to : @to
          )
        end
      elsif self_from || other_from
        if self_from && other.to.t > self_from.t
          Span.new(
            self_from,
            other.to.t < @to.t ? other.to : @to
          )
        elsif other_from && @to.t > other_from.t
          Span.new(
            other_from,
            other.to.t < @to.t ? other.to : @to
          )
        else
          nil
        end
      else
        Span.new(
          nil,
          other.to.t < @to.t ? other.to : @to
        )
      end
    end

    def inspect
      self_from = @from
      if self_from.nil?
        "(nil...#{to.t})"
      else
        "(#{self_from.t}...#{to.t})"
      end
    end
  end

  class Union < BoundedHitable
    def initialize(@a : BoundedHitable, @b : BoundedHitable)
      @bounding_box = @a.bounding_box.merge(@b.bounding_box)
    end

    def hit(ray : Ray) : HitRecord?
      hit_a = @a.hit(ray)
      hit_b = @b.hit(ray)

      if hit_a && hit_b
        hit_a.t < hit_b.t ? hit_a : hit_b
      elsif hit_a
        hit_a
      else
        hit_b
      end
    end
  end

  # Handling leaving rays is important for transmissive objects,
  # otherwise the calculations could be simpler
  class Intersection < BoundedHitable
    def initialize(@a : BoundedHitable, @b : BoundedHitable)
      @bounding_box = @a.bounding_box.merge(@b.bounding_box)
    end

    def hit(ray : Ray) : HitRecord?
      # NOTE: Just taking the first hit is not a solution,
      # imagine a scenario
      #     \
      #    AAA
      #    AAA\
      #    AAA \
      # BBBBBBBBB
      # BBBBBBBBB
      #    AAA   \
      #    AAA
      #
      # The ray hits both objects but not their intersection
      
      hits_a = CSG.all_hits(ray, @a)
      hits_b = CSG.all_hits(ray, @b)

      if hits_a.empty? || hits_b.empty?
        return nil
      end

      spans_a = CSG.spans(hits_a)
      spans_b = CSG.spans(hits_b)

      spans_a_new = [] of Span
      spans_b.each do |sb|
        spans_a.each do |sa|
          is = sa.intersection(sb)
          spans_a_new << is if is
        end
      end

      spans_a = spans_a_new

      if spans_a.empty?
        nil
      else
        spans_a.first.from
      end
    end
  end

  # This is a surprisingly hard problem,
  # see <https://www.doc.ic.ac.uk/~dfg/graphics/graphics2008/GraphicsSlides10.pdf>
  # for an explanation
  class Difference < BoundedHitable
    # @a - @b
    def initialize(@a : BoundedHitable, @b : BoundedHitable)
      @bounding_box = @a.bounding_box.merge(@b.bounding_box)
    end

    def hit(ray : Ray) : HitRecord?
      # puts "======="

      hits_a = CSG.all_hits(ray, @a)
      hits_b = CSG.all_hits(ray, @b)

      # puts "Hits"
      # p hits_a.map { |h| {h.hit.t, h.tag} }
      # p hits_b.map { |h| {h.hit.t, h.tag} }

      if hits_a.empty?
        return nil
      elsif hits_b.empty?
        # puts [hits_a.first]
        return hits_a.first.hit
      end

      spans_a = CSG.spans(hits_a)
      spans_b = CSG.spans(hits_b)

      # puts "Spans"
      # p spans_a
      # p spans_b

      spans_b.each do |sb|
        spans_a_new = [] of Span
        spans_a.each do |sa|

          sa_from = sa.from
          sb_from = sb.from

          if sa_from && sb_from
            if sa_from.t <= sb_from.t
              if sa.to.t < sb_from.t # AAAAAAA    BBBBB
                spans_a_new << sa
              else
                if sa.to.t < sb.to.t # AAAAA#####BBBBB
                  spans_a_new << Span.new(sa_from, sb_from.flipped)
                else # AAAAA######AAAAA
                  spans_a_new << Span.new(sa_from, sb_from.flipped)
                  spans_a_new << Span.new(sb.to.flipped, sa.to)
                end
              end
            else
              if sb.to.t < sa_from.t # BBBB   AAAAAAA
                spans_a_new << sa
              else
                if sb.to.t < sa.to.t # BB####AAAAAA
                  spans_a_new << Span.new(sb.to.flipped, sa.to)
                else # BBB#########BBBB
                  # Do nothing
                end
              end
            end
          elsif sb_from
            if sa.to.t < sb_from.t # _AAAAAAA    BBBBB
              spans_a_new << sa
            else
              if sa.to.t < sb.to.t # _AAAAA#####BBBBB
                spans_a_new << Span.new(nil, sb.to.flipped)
              else # _AAAAA######AAAAA
                spans_a_new << Span.new(nil, sb_from)
                spans_a_new << Span.new(sb.to.flipped, sa.to)
              end
            end
          elsif sa_from
              if sb.to.t < sa_from.t # _BBBB   AAAAAAA
                spans_a_new << sa
              else
                if sb.to.t < sa.to.t # _BB####AAAAAA
                  spans_a_new << Span.new(sb.to.flipped, sa.to)
                else # _BBB#########BBBB
                  # Do nothing
                end
              end
          else
            if sb.to.t < sa.to.t
              # _#########AAAAAA
              spans_a_new << Span.new(sb.to.flipped, sa.to)
            end
          end
        end

        spans_a = spans_a_new
      end

      # puts "Result"
      # p spans_a

      if spans_a.empty?
        nil
      else
        spans_a.flat_map do |s|
          sf = s.from
          sf ? [sf, s.to] : [s.to]
        end.sort_by(&.t).first
        # first = spans_a.find { |a| a.from }
        # if first
        #   first.from
        # else
        #   spans_a.first.to
        # end
      end
    end

  end

  def self.spans(hits)
    spans = [] of Span
    return spans if hits.empty?

    # Handle rays starting inside the object
    spans << Span.new(nil, hits[0].hit) if hits[0].leaving?

    last = hits[0]
    hits[1..-1].each do |h|
      if h.leaving?
        spans << Span.new(last.hit, h.hit)
      elsif h.entering? && last.entering?
        # Special case, only one intesection with the object
        # e.g. for circles
        spans << Span.new(last.hit, last.hit)
      end

      last = h
    end

    spans << Span.new(last.hit, last.hit) if last.entering?

    spans
  end

  def self.all_hits(ray, object, tracing = false)
    hits = [] of TaggedHitRecord

    t = 0.0
    loop do
      # puts "t : #{t}" if tracing
      hit = object.hit(ray)
      if hit
        t += hit.t
        real_hit = HitRecord.new(
          t, hit.point, hit.normal, hit.material, hit.object, hit.u, hit.v
        )

        if hit.normal.dot(ray.direction) < 0.0
          hits << TaggedHitRecord.new(real_hit, :entering)
        else
          hits << TaggedHitRecord.new(real_hit, :leaving)
        end

        ray = Ray.new(hit.point, ray.direction)
      else
        break
      end
    end

    hits
  end
end
