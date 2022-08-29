# Multi-Scale Turing Patterns

[![][build-img]][build-url] [![][codecov-img]][codecov-url]

## Low-level API

```julia
using TuringPatterns

sz = (200, 200)

patterns = [
    SimplePattern(Params(2,   4,   0.01), sz),
    SimplePattern(Params(5,   10,  0.02), sz),
    SimplePattern(Params(10,  20,  0.03), sz),
    SimplePattern(Params(20,  40,  0.04), sz),
    SimplePattern(Params(50,  100, 0.05), sz),
]

simulate(
    rand(sz...), # initial conditions
    patterns,    # patterns
    BoxBlur(sz), # blur
    100          # iterations
)
```
![docs/picture.png](docs/picture.png)

## High-level API

Multiple images can be generated using:

```julia
using GeoStats
using TuringPatterns

using Plots, GeoStatsPlots

# define simulation problem for a variable "z"
# request 3 realizations (i.e. images)
problem = SimulationProblem(CartesianGrid(200,200), :z => Float64, 3)

# define Turing patterns solver
# see docstring for options
solver  = TPS()

# solve problem over any domain
# that has grid topology
solution = solve(problem, solver)

plot(solution)
```
![docs/geostats.png](docs/geostats.png)

## References

- [McCabe, J. Cyclic Symmetric Multi-Scale Turing Patterns](http://www.jonathanmccabe.com/Cyclic_Symmetric_Multi-Scale_Turing_Patterns.pdf)
- [Example gallery 1](https://www.flickr.com/photos/jonathanmccabe/sets/72157644907151060) and [Example gallery 2](https://www.flickr.com/photos/jonathanmccabe/sets/72157673446623356)

[build-img]: https://img.shields.io/github/workflow/status/JuliaEarth/TuringPatterns.jl/CI
[build-url]: https://github.com/JuliaEarth/TuringPatterns.jl/actions

[codecov-img]: https://codecov.io/gh/JuliaEarth/TuringPatterns.jl/branch/master/graph/badge.svg
[codecov-url]: https://codecov.io/gh/JuliaEarth/TuringPatterns.jl
