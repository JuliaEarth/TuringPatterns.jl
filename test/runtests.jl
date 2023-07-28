using TuringPatterns
using Meshes
using GeoStatsBase
using Test, Random

@testset "TuringPatterns.jl" begin
  @testset "GeoStats.jl API" begin
    Random.seed!(2019)
    problem = SimulationProblem(CartesianGrid(200, 200), :z => Float64, 3)
    solution = solve(problem, TPS())
  end
end
