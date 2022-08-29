module TuringPatterns

using Meshes
using GeoStatsBase

using FixedPointNumbers

import GeoStatsBase: preprocess, solvesingle

include("util.jl")
include("blur.jl")
include("simulation.jl")
include("geostats.jl")

export Pattern, Params, SimplePattern, CompositePattern
export Zero, Clamp, BoxBlur, IteratedBoxBlur
export Sim, step!, simulate
export scale01

# GeoStats.jl API
export TPS, PARAMS1

end # module
