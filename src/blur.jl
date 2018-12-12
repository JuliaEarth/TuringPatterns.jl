# A quick summmed-area table implementation
function sumtable!(table, arr)
    out = arr
    for n in 1:ndims(table)
        out = cumsum!(table, out, dims = n)
    end
    out
end

"Efficient region queries over a summed-area table. Note that
the `table` should be padded by one strip of zeros on the left
and top sides."
function regionquery end

function regionquery(table::Vector, ylo, yhi)
    table[yhi+1] - table[ylo]
end

function regionquery(table::Matrix, ylo, yhi, xlo, xhi)
    yhi += 1
    xhi += 1
    a = table[yhi, xhi]
    b = table[ylo, xhi]
    c = table[yhi, xlo]
    d = table[ylo, xlo]
    a - b - c + d
end

"Specify how to handle boundaries at the edges of the image"
abstract type EdgeCondition end
"Clamp causes smaller blurs to be performed at the edges"
struct Clamp <: EdgeCondition end
"Zero assumes implicit zeroes outside of the image region"
struct Zero  <: EdgeCondition end

#
# I don't like all this but it's the best I've got so far for
# handling multidimensional inputs efficiently.
# CartesianIndexes were slower than otherwise, and I didn't want
# to use generated functions.
#

@inline scale(::Zero,  r, ylo, yhi) = 1 / (2r + 1)^1
@inline scale(::Zero,  r, ylo, yhi, xlo, xhi) = 1 / (2r + 1)^2

@inline scale(::Clamp, r, ylo, yhi, xlo=0, xhi=0) =
    1 / ((yhi-ylo+1) * (xhi-xlo+1))

abstract type Blur end

struct BoxBlur{N} <: Blur
    table::Array{Float64, N}
    tableview::SubArray
    function BoxBlur{N}(sz) where {N}
        # Create a sum table padded with zeros on the starting side
        table = zeros(map(x->x+1, sz))
        tableview = view(table, map(x -> (1:x) .+ 1, sz)...)
        new(table, tableview)
    end
end
BoxBlur(sz) = BoxBlur{length(sz)}(sz)

# Preparing a blur happens once per image. We can subsequently
# blur the same image efficiently at multiple scales.
prepare!(b::BoxBlur, arr) = sumtable!(b.tableview, arr)

function blur!(b::BoxBlur{2}, out, r, edge)
    (sy, sx) = size(out)
    for x in 1:sx, y in 1:sy
        ylo, yhi = max(1, y-r), min(y+r, sy)
        xlo, xhi = max(1, x-r), min(x+r, sx)
        s = scale(edge, r, ylo, yhi, xlo, xhi)
        out[y, x] = s * regionquery(b.table, ylo, yhi, xlo, xhi)
    end
    out
end

function blur!(b::BoxBlur{1}, out, r, edge)
    (sy,) = size(out)
    for y in 1:sy
        ylo, yhi = max(1, y-r), min(y+r, sy)
        s = scale(edge, r, ylo, yhi)
        out[y] = s * regionquery(b.table, ylo, yhi)
    end
    out
end

struct IteratedBoxBlur{N} <: Blur
    box::BoxBlur
    target::Array{Float64, N}
    iters::Int
    IteratedBoxBlur{N}(sz, iters) where {N} = new(BoxBlur(sz), zeros(sz), iters)
end
IteratedBoxBlur(sz, iters) = IteratedBoxBlur{length(sz)}(sz, iters)

prepare!(b::IteratedBoxBlur, arr) = copy!(b.target, arr)

function blur!(b::IteratedBoxBlur, out, r, edge)
    copy!(out, b.target)
    for _ in 1:b.iters
        prepare!(b.box, out)
        blur!(b.box, out, r, edge)
    end
    out
end
