module TuringPatterns

include("util.jl")
include("blur.jl")
include("simulation.jl")

export Pattern, Params, SimplePattern, CompositePattern
export Zero, Clamp, BoxBlur, IteratedBoxBlur
export Sim, step!, simulate
export scale01

end # module
