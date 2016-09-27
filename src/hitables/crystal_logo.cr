class CrystalLogo
  def self.create(material)
    vertices = [
      Point.new(0.550563524346, 0.758024984088, -0.349682612032),
      Point.new(0.62319582135, 0.436643142534, 0.648821804759),
      Point.new(0.975676690271, -0.177816333299, -0.12820432003),
      Point.new(-0.32007250628, 0.0780544757795, 0.944172171553),
      Point.new(0.437594031513, -0.598061218782, 0.671441912732),
      Point.new(0.32007250628, -0.0780544757795, -0.944172171553),
      Point.new(0.250253520018, -0.916161840828, -0.313082508502),
      Point.new(-0.437594031513, 0.598061218782, -0.671441912732),
      Point.new(-0.62319582135, -0.436643142534, -0.648821804759),
      Point.new(-0.250253520018, 0.916161840828, 0.313082508502),
      Point.new(-0.975676690271, 0.177816333299, 0.12820432003),
      Point.new(-0.550563524346, -0.758024984088, 0.349682612032),
    ]

    FiniteHitableList.new([
      Triangle.new(vertices[0], vertices[1], vertices[2], material),
      Triangle.new(vertices[1], vertices[3], vertices[4], material),
      Triangle.new(vertices[0], vertices[2], vertices[5], material),
      Triangle.new(vertices[2], vertices[4], vertices[6], material),
      Triangle.new(vertices[0], vertices[5], vertices[7], material),
      Triangle.new(vertices[5], vertices[6], vertices[8], material),
      Triangle.new(vertices[0], vertices[7], vertices[9], material),
      Triangle.new(vertices[7], vertices[8], vertices[10], material),
      Triangle.new(vertices[0], vertices[9], vertices[1], material),
      Triangle.new(vertices[9], vertices[10], vertices[3], material),
      Triangle.new(vertices[4], vertices[2], vertices[1], material),
      Triangle.new(vertices[11], vertices[4], vertices[3], material),
      Triangle.new(vertices[6], vertices[5], vertices[2], material),
      Triangle.new(vertices[11], vertices[6], vertices[4], material),
      Triangle.new(vertices[8], vertices[7], vertices[5], material),
      Triangle.new(vertices[11], vertices[8], vertices[6], material),
      Triangle.new(vertices[10], vertices[9], vertices[7], material),
      Triangle.new(vertices[11], vertices[10], vertices[8], material),
      Triangle.new(vertices[3], vertices[1], vertices[9], material),
      Triangle.new(vertices[11], vertices[3], vertices[10], material),
    ])
  end
end
