using TuringPatterns
using Meshes
using GeoStatsBase
using Plots; gr(size=(600,400))
using GeoStatsPlots # TODO: replace by GeoStatsViz
using ReferenceTests, ImageIO
using Test, Random

# workaround GR warnings
ENV["GKSwstype"] = "100"

# environment settings
isCI = "CI" ∈ keys(ENV)
islinux = Sys.islinux()
visualtests = !isCI || (isCI && islinux)
datadir = joinpath(@__DIR__,"data")

@testset "TuringPatterns.jl" begin
  @testset "GeoStats.jl API" begin
    Random.seed!(2019)
    problem = SimulationProblem(CartesianGrid(200,200), :z => Float64, 3)
    solution = solve(problem, TPS())

    if visualtests
      @test_reference "data/GeoStatsAPI.png" plot(solution,size=(900,300))
    end
  end
end
