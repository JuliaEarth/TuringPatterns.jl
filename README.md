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
        rand(sz),    # initial conditions
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

![A multi-scale Turing pattern](picture.png)

## References

- [McCabe, J. Cyclic Symmetric Multi-Scale Turing Patterns](http://www.jonathanmccabe.com/Cyclic_Symmetric_Multi-Scale_Turing_Patterns.pdf)
- [Example gallery 1](https://www.flickr.com/photos/jonathanmccabe/sets/72157644907151060) and [Example gallery 2](https://www.flickr.com/photos/jonathanmccabe/sets/72157673446623356)
