# Backgrounds are used to determine the color
# of a `Ray` if it misses all objects in the `Scene`.
abstract class Background
  abstract def get(ray : Ray) : Color
end
