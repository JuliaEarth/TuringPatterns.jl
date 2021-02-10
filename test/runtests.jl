using TuringPatterns
using GeoStatsBase
using Plots; gr(size=(600,400))
using ReferenceTests, ImageIO
using Test, Random

# workaround GR warnings
ENV["GKSwstype"] = "100"

# environment settings
isCI = "CI" ∈ keys(ENV)
islinux = Sys.islinux()
visualtests = !isCI || (isCI && islinux)
datadir = joinpath(@__DIR__,"data")

# helper functions for visual regression tests
function asimage(plt)
  io = IOBuffer()
  show(io, "image/png", plt)
  seekstart(io)
  ImageIO.load(io)
end
macro test_ref_plot(fname, plt)
  esc(quote
    @test_reference $fname asimage($plt)
  end)
end

@testset "TuringPatterns.jl" begin
  @testset "Basic usage" begin
    # TODO:
  end

  @testset "GeoStats.jl API" begin
    Random.seed!(2019)
    problem = SimulationProblem(RegularGrid(200,200), :z => Float64, 3)
    solution = solve(problem, TPS())

    if visualtests
      @test_ref_plot "data/GeoStatsAPI.png" plot(solution,size=(900,300))
    end
  end
end
