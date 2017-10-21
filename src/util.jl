# Until Base has a version like this one...
function findmin(f::Function, itr)
    local out
    best = Inf
    for x in itr
        score = f(x)
        if score < best
            out, best = x, score
        end
    end
    out
end

function scale01!(arr)
    lo, hi = extrema(arr)
    scale = hi == lo ? zero(lo) : one(lo) / (hi - lo)
    @. arr = scale * (arr - lo)
end
scale01(arr) = scale01!(copy(arr))

signed_scale01!(arr) = arr .= scale01!(arr) .* 2 .- 1

# currently unused, but may come in useful:
# clamp01!(arr) = clamp!(arr, 0, 1)
# clamp01(arr) = clamp01!(copy(arr))
# signed_clamp01!(arr) = clamp!(arr, -1, 1)
