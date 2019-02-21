using GeoStatsBase
using GeoStatsDevTools
using TuringPatterns
using Plots; gr()
using VisualRegressionTests
using Test, Pkg, Random

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
    problem = SimulationProblem(RegularGrid{Float64}(200,200), :z => Float64, 3)

    solver = TuringPat()

    Random.seed!(2019)
    solution = solve(problem, solver)

    if visualtests
      @plottest plot(solution,size=(1000,300)) joinpath(datadir,"GeoStatsAPI.png") !istravis
    end
  end
end
