scene = Scene.new

vars = {} of String => (Color | Material | Hitable)

loop do
  print "> "
  input = gets
  break if input.nil?

  command = input.chomp
  break if command == "q" || command == "quit"
end

# (add :sphere (0 0 0) 1.0)

def parse_vec
