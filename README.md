# Multi-Scale Turing Patterns

A quick example:

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

saveframe(
    simulate(
        rand(sz...),    # initial conditions
        patterns,    # patterns
        BoxBlur(sz), # blur
        100          # iterations
    ),
    "picture.png"
)

# `open` on macOS or `xdg-open` on linux
run(`open picture.png`)
```

You should see something like this:

![A multi-scale Turing pattern](docs/picture.png)

## Integration with GeoStats.jl

Multiple images can be generated using the GeoStats.jl API:

```julia
using GeoStats
using TuringPatterns
using Plots

# define simulation problem for a variable "z"
# and ask for 100 realizations (i.e. images)
problem = SimulationProblem(RegularGrid{Float64}(200,200), :z => Float64, 100)

# solver with default parameters
solver = TuringPat()

solution = solve(problem, solver)

plot(solution)
```
![GeoStats.jl solution](docs/geostats.png)

## References

- [McCabe, J. Cyclic Symmetric Multi-Scale Turing Patterns](http://www.jonathanmccabe.com/Cyclic_Symmetric_Multi-Scale_Turing_Patterns.pdf)
- [Example gallery 1](https://www.flickr.com/photos/jonathanmccabe/sets/72157644907151060) and [Example gallery 2](https://www.flickr.com/photos/jonathanmccabe/sets/72157673446623356)
