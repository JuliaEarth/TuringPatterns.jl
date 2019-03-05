# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENCE in the project root.
# ------------------------------------------------------------------

using .GeoStatsBase
import .GeoStatsBase: preprocess, solve_single

export TuringPat, PARAMS1

const PARAMS1 = [
  Params(2,  4,   0.01),
  Params(5,  10,  0.02),
  Params(10, 20,  0.03),
  Params(20, 40,  0.04),
  Params(50, 100, 0.05)
]

"""
    TuringPat(var₁=>param₁, var₂=>param₂, ...)

Turing pattern simulation.

## Parameters

* `params` - basic parameters (default to `PARAMS1`)
* `blur`   - blur algorithm (default to `BoxBlur`)
* `edge`   - edge condition (default to `Clamp`)
* `iter`   - number of iterations (default to `100`)

### References

Turing 1952. *The chemical basis of morphogenesis.*
"""
@simsolver TuringPat begin
  @param params = PARAMS1
  @param blur = BoxBlur
  @param edge = Clamp
  @param iter = 100
end

function preprocess(problem::SimulationProblem, solver::TuringPat)
  # retrieve domain size
  sz = size(domain(problem))

  # result of preprocessing
  preproc = Dict{Symbol,NamedTuple}()

  for (var, V) in variables(problem)
    # get user parameters
    if var ∈ keys(solver.params)
      varparams = solver.params[var]
    else
      varparams = TuringPatParam()
    end

    # determine simulation parameters
    params = varparams.params
    blur = varparams.blur(sz)
    edge = varparams.edge()
    iter = varparams.iter

    # construct patterns from parameters
    patterns = [SimplePattern(param, sz) for param in params]

    preproc[var] = (patterns=patterns,blur=blur,edge=edge,iter=iter)
  end

  preproc
end

function solve_single(problem::SimulationProblem, var::Symbol,
                      solver::TuringPat, preproc)
  # retrieve domain size
  sz = size(domain(problem))

  # unpack preprocessed parameters
  patterns, blur, edge, iter = preproc[var]

  # determine result type
  V = variables(problem)[var]

  # perform simulation
  sim = Sim(rand(V, sz), patterns, edge, blur)
  for i in 1:iter
    step!(sim)
  end
  real = scale01(sim.fluid)

  # flatten result
  vec(real)
end
