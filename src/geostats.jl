# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENCE in the project root.
# ------------------------------------------------------------------

const PARAMS1 =
  [Params(2, 4, 0.01), Params(5, 10, 0.02), Params(10, 20, 0.03), Params(20, 40, 0.04), Params(50, 100, 0.05)]

"""
    TPS(var₁=>param₁, var₂=>param₂, ...)

Turing pattern simulation.

## Parameters

* `params` - basic parameters (default to `PARAMS1`)
* `blur`   - blur algorithm (default to `BoxBlur`)
* `edge`   - edge condition (default to `Clamp`)
* `iter`   - number of iterations (default to `100`)

### References

Turing 1952. *The chemical basis of morphogenesis.*
"""
@simsolver TPS begin
  @param params = PARAMS1
  @param blur = BoxBlur
  @param edge = Clamp
  @param iter = 100
end

function preprocess(problem::SimulationProblem, solver::TPS)
  # retrieve domain of simulation
  pdomain = domain(problem)
  ptopo = topology(pdomain)

  # assert grid topology
  @assert ptopo isa GridTopology "simulation only defined over grid topology"

  # retrieve simulation size
  sz = size(ptopo)

  # result of preprocessing
  preproc = Dict{Symbol,NamedTuple}()

  for covars in covariables(problem, solver)
    for var in covars.names
      # get user parameters
      varparams = covars.params[Set([var])]

      # determine simulation parameters
      params = varparams.params
      blur = varparams.blur(sz)
      edge = varparams.edge()
      iter = varparams.iter

      # construct patterns from parameters
      patterns = [SimplePattern(param, sz) for param in params]

      preproc[var] = (patterns=patterns, blur=blur, edge=edge, iter=iter)
    end
  end

  preproc
end

function solvesingle(problem::SimulationProblem, covars::NamedTuple, ::TPS, preproc)
  # retrieve domain size
  sz = size(topology(domain(problem)))

  varreal = map(collect(covars.names)) do var
    # unpack preprocessed parameters
    patterns, blur, edge, iter = preproc[var]

    # determine value type
    V = variables(problem)[var]

    # perform simulation
    sim = Sim(rand(V, sz), patterns, edge, blur)
    for i in 1:iter
      step!(sim)
    end
    real = scale01(sim.fluid)

    # flatten result
    var => vec(real)
  end

  Dict(varreal)
end
