module TuringPatterns

include("util.jl")
include("blur.jl")
include("export.jl")

# optionally load GeoStats.jl API
using Requires
function __init__()
    @require GeoStatsBase="323cb8eb-fbf6-51c0-afd0-f8fba70507b2" include("geostats.jl")
end

export Pattern, Params, SimplePattern, CompositePattern
export Sim, step!, simulate
export Zero, Clamp, BoxBlur, IteratedBoxBlur
export saveframe, saveframes, scale01


"An N-dimensional Turing pattern"
abstract type Pattern{N} end

"The difference between small and large scales in a pattern"
function difference end

"The effect of the pattern"
function effect end

"Allow a pattern to batch work; called once per frame"
function prepare! end

"Represents the parameters for a single Turing pattern"
struct Params
    r::Int
    R::Int
    effectsize::Float64
end

"Represents the simulation of a single Turing pattern"
struct SimplePattern{N} <: Pattern{N}
    params::Params
    blur_r::Array{Float64, N}
    blur_R::Array{Float64, N}
    difference::Array{Float64, N}
end

SimplePattern(params, sz) = SimplePattern(params, zeros(sz), zeros(sz), zeros(sz))

difference(p::SimplePattern, ind) = p.difference[ind]
effect(p::SimplePattern, ind) = p.params.effectsize * sign(difference(p, ind))
function prepare!(p::SimplePattern, blur::Blur, edge::EdgeCondition)
    # Compute small and large-scale averages and differences for all pixels
    blur!(blur, p.blur_r, p.params.r, edge)
    blur!(blur, p.blur_R, p.params.R, edge)
    @. p.difference = p.blur_r - p.blur_R
end

"Represents a pattern made up of multiple simple patterns"
struct CompositePattern{N} <: Pattern{N}
    patterns::Vector{SimplePattern{N}}
    couplings::Matrix{Float64}
end
CompositePattern(patterns) = CompositePattern(patterns, eye(length(patterns)))

difference(p::CompositePattern, ind) = sum(p.couplings * difference.(p.patterns, ind))
effect(p::CompositePattern, ind) = sum(p.couplings * effect.(p.patterns, ind))
prepare!(p::CompositePattern, blur, edge) =
    for p in p.patterns
        prepare!(p, blur, edge)
    end

# Promote heterogenous collections of `Pattern`s to a common type
Base.promote_rule(::Type{CompositePattern{N}}, ::Type{SimplePattern{N}}) where {N} = CompositePattern{N}
Base.convert(::Type{CompositePattern{N}}, p::SimplePattern{N}) where {N} = CompositePattern([p])

"Represents simulation state for multiple patterns acting on a 1D or 2D grid"
struct Sim{N, T<:Pattern}
    fluid::Array{Float64, N}
    patterns::Vector{T}
    edge::EdgeCondition
    blur::Blur
end

"Performs a single simulation step"
function step!(sim::Sim)
    # Prepare the blur and all of the patterns
    prepare!(sim.blur, sim.fluid)
    for p in sim.patterns
        prepare!(p, sim.blur, sim.edge)
    end

    # Select and apply the weakest pattern for every pixel
    for ind in eachindex(sim.fluid)
        p = let ind = ind # hack for better lambda optimization
            findmin(p -> abs(difference(p, ind)), sim.patterns)
        end
        sim.fluid[ind] += effect(p, ind)
    end

    # Re-normalize the fluid to [-1, 1]
    signed_scale01!(sim.fluid)
end

"Convenience method to simulate a set of patterns from some initial conditions"
function simulate(initial, patterns, blur, iters)
    sim = Sim(initial, patterns, Clamp(), blur)
    @time for i in 1:iters
        step!(sim)
    end
    scale01(sim.fluid)
end

end # module
