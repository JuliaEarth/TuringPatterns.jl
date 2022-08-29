module TuringPatterns

using Meshes
using GeoStatsBase

using FixedPointNumbers
using ColorTypes
using FileIO

import GeoStatsBase: preprocess, solvesingle

include("util.jl")
include("blur.jl")
include("simulation.jl")
include("saving.jl")
include("geostats.jl")

export Pattern, Params, SimplePattern, CompositePattern
export Sim, step!, simulate
export Zero, Clamp, BoxBlur, IteratedBoxBlur
export saveframe, saveframes, scale01

# GeoStats.jl API
export TPS, PARAMS1

end # module
