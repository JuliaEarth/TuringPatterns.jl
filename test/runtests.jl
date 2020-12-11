using TuringPatterns
using GeoStatsBase
using Plots, VisualRegressionTests
using Test, Pkg, Random

# workaround GR warnings
ENV["GKSwstype"] = "100"

# environment settings
isCI = "CI" ∈ keys(ENV)
islinux = Sys.islinux()
visualtests = !isCI || (isCI && islinux)
if !isCI
  Pkg.add("Gtk")
  using Gtk
end
datadir = joinpath(@__DIR__,"data")

@testset "TuringPatterns.jl" begin
  @testset "Basic usage" begin
    # TODO:
  end

  @testset "GeoStats.jl API" begin
    Random.seed!(2019)
    problem = SimulationProblem(RegularGrid(200,200), :z => Float64, 3)
    solution = solve(problem, TPS())

    if visualtests
      @plottest plot(solution,size=(900,300)) joinpath(datadir,"GeoStatsAPI.png") !isCI
    end
  end
end
