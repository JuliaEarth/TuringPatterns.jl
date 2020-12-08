using TuringPatterns
using GeoStatsBase
using Plots, VisualRegressionTests
using Test, Pkg, Random

# workaround GR warnings
ENV["GKSwstype"] = "100"

# environment settings
islinux = Sys.islinux()
istravis = "TRAVIS" ∈ keys(ENV)
datadir = joinpath(@__DIR__,"data")
visualtests = !istravis || (istravis && islinux)
if !istravis
  Pkg.add("Gtk")
  using Gtk
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
      @plottest plot(solution,size=(900,300)) joinpath(datadir,"GeoStatsAPI.png") !istravis
    end
  end
end
