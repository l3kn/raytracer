class Triangulate
  def self.isocahedron(mat, iterations = 0)
    t = (1.0 + Math.sqrt(5.0)) / 2.0
    inv = 1.0 / Math.sqrt(1.0 + t*t)
    points = [
      Point.new(-1.0, t, 0.0) * inv,
      Point.new(1.0, t, 0.0) * inv,
      Point.new(-1.0, -t, 0.0) * inv,
      Point.new(1.0, -t, 0.0) * inv,
      Point.new(0.0, -1.0, t) * inv,
      Point.new(0.0, 1.0, t) * inv,
      Point.new(0.0, -1.0, -t) * inv,
      Point.new(0.0, 1.0, -t) * inv,
      Point.new(t, 0.0, -1.0) * inv,
      Point.new(t, 0.0, 1.0) * inv,
      Point.new(-t, 0.0, -1.0) * inv,
      Point.new(-t, 0.0, 1.0) * inv,
    ]

    triangles = [
      Triangle.new(points[0], points[11], points[5], mat),
      Triangle.new(points[0], points[5], points[1], mat),
      Triangle.new(points[0], points[1], points[7], mat),
      Triangle.new(points[0], points[7], points[10], mat),
      Triangle.new(points[0], points[10], points[11], mat),
      Triangle.new(points[1], points[5], points[9], mat),
      Triangle.new(points[5], points[11], points[4], mat),
      Triangle.new(points[11], points[10], points[2], mat),
      Triangle.new(points[10], points[7], points[6], mat),
      Triangle.new(points[7], points[1], points[8], mat),
      Triangle.new(points[3], points[9], points[4], mat),
      Triangle.new(points[3], points[4], points[2], mat),
      Triangle.new(points[3], points[2], points[6], mat),
      Triangle.new(points[3], points[6], points[8], mat),
      Triangle.new(points[3], points[8], points[9], mat),
      Triangle.new(points[4], points[9], points[5], mat),
      Triangle.new(points[2], points[4], points[11], mat),
      Triangle.new(points[6], points[2], points[10], mat),
      Triangle.new(points[8], points[6], points[7], mat),
      Triangle.new(points[9], points[8], points[1], mat),
    ]

    iterations.times do
      triangles = divide_all(triangles)
    end
    triangles
  end

  def self.divide_all(triangles)
    res = [] of Triangle
    triangles.each { |triangle| res += divide(triangle) }
    res
  end

  def self.divide(triangle)
    a = triangle.a
    b = triangle.b
    c = triangle.c
    mat = triangle.material

    ab = ((a + b) * 0.5).normalize
    ac = ((a + c) * 0.5).normalize
    bc = ((b + c) * 0.5).normalize

    [
      Triangle.new(a, ab, ac, mat),
      Triangle.new(ab, b, bc, mat),
      Triangle.new(ac, bc, c, mat),
      Triangle.new(ac, ab, bc, mat),
    ]
  end
end
