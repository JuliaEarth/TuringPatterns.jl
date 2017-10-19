# Patternshop is a sort of Photoshop for exploring Turing patterns.
# The name is temporary until I think of something I like better.

using TuringPatterns
using HTTP, JSON

write2d(stream, frame) = save(FileIO.DataFormat{:PNG}, stream, Gray.(frame))

# Parameter sweeping
swept(v, x, y) = v
swept(v::Dict, x, y) = haskey(v, "xsweep") ? v["xsweep"][x] : v["ysweep"][y]
# todo: can we use `pairs` in 1.0?
sweep!(d::Dict, x, y) = for (key, val) in d
    d[key] = swept(val, x, y)
end
sweep!(d::Array, x, y) = for (key, val) in enumerate(d)
    d[key] = swept(val, x, y)
end

function handler(req, res)
    params = req |> HTTP.uri |> HTTP.query |> HTTP.unescape |> JSON.parse

    println("Handling request:")
    @show params

    ix, iy = params["ix"], params["iy"]
    sweep!(params, ix, iy)

    width, height, iters, dims, seed = params["width"], params["height"], params["iters"], params["dims"], params["seed"]
    sz = (width, height)
    patterns = []

    for spec in params["patterns"]
        sweep!(spec, ix, iy)
        if spec["type"] == "simple"
            push!(patterns, SimplePattern(Params(spec["r"], spec["R"], spec["effectsize"]), sz))
        else # composite
            sweep!(spec["couplings"], ix, iy)
            subpatterns = SimplePattern{Int(dims)}[]
            for subspec in spec["patterns"]
                sweep!(subspec, ix, iy)
                push!(subpatterns, SimplePattern(Params(subspec["r"], subspec["R"], subspec["effectsize"]), sz))
            end
            len = length(subpatterns)
            couplings = convert(Matrix{Float64}, reshape(spec["couplings"], (len, len)))
            push!(patterns, CompositePattern(subpatterns, couplings))
        end
    end

    srand(seed)

    frame = simulate(
        rand(sz),
        collect(promote(patterns...)),
        BoxBlur(sz),
        iters
    )

    buf = FIFOBuffer()
    write2d(buf, frame)
    close(buf)

    HTTP.Response(
      headers=HTTP.Headers(
        "Access-Control-Allow-Origin" => "*",
        "Content-Type" => "image/png",
      ),
      body=buf
    )
end

function serve()
    server = HTTP.Server(handler, DevNull, ratelimit=100//1)
    HTTP.serve(server, IPv4(127,0,0,1), 8002)
end

serve()
