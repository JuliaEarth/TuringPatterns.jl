# TuringPatterns.jl

[![][build-img]][build-url] [![][codecov-img]][codecov-url]

Multi-scale Turing pattern simulation solver for the
[GeoStats.jl](https://github.com/JuliaEarth/GeoStats.jl) framework.

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

## References

- [McCabe, J. Cyclic Symmetric Multi-Scale Turing Patterns](http://www.jonathanmccabe.com/Cyclic_Symmetric_Multi-Scale_Turing_Patterns.pdf)
- [Example gallery 1](https://www.flickr.com/photos/jonathanmccabe/sets/72157644907151060) and [Example gallery 2](https://www.flickr.com/photos/jonathanmccabe/sets/72157673446623356)

[build-img]: https://img.shields.io/github/actions/workflow/status/JuliaEarth/TuringPatterns.jl/CI.yml?branch=master&style=flat-square
[build-url]: https://github.com/JuliaEarth/TuringPatterns.jl/actions

[codecov-img]: https://codecov.io/gh/JuliaEarth/TuringPatterns.jl/branch/master/graph/badge.svg
[codecov-url]: https://codecov.io/gh/JuliaEarth/TuringPatterns.jl
