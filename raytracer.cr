require "../linalg/src/linalg"
require "../stumpy_utils/src/stumpy_utils"
require "stumpy_png"

EPSILON = 0.0001

require "./src/vector"
require "./src/normal"
require "./src/color"
require "./src/point"
require "./src/quaternion"
require "./src/ray"
require "./src/hitable"
# TODO: This needs to be required first, bc/ Cuboid < FiniteHitableList
#       maybe create a separate folder for aggregate hitables
require "./src/hitables/hitable_list"
require "./src/hitables/*"
require "./src/camera"
require "./src/helper"
require "./src/material"
require "./src/bxdf"
require "./src/bxdfs/*"
require "./src/bsdf"
require "./src/texture"
require "./src/background"
require "./src/backgrounds/*"
require "./src/light"
require "./src/onb"
require "./src/scene"
require "./src/debugging"
require "./src/sample"
require "./src/filter"
require "./src/wireframe"
require "./src/raytracer"
require "./src/raytracers/*"
