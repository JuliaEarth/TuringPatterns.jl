using FixedPointNumbers, FileIO, ColorTypes#, ColorVectorSpace, ImageCore

function saveframe(frame::Array{T, 2}, path) where T<:Color
    save(path, frame)
end

function saveframe(frame::Array{T, 2}, path) where T
    saveframe(Gray.(frame), path)
end

function saveframe(frame::Array{T, 1}, path) where T
    # save 1d images horizontally
    saveframe(reshape(frame, 1, length(frame)), path)
end

function saveframe(frame::Array{T, 3}, path) where T
    colors = mapslices(rgb -> RGB(rgb...), frame, 3)
    saveframe(squeeze(colors, 3), path)
end

snapshot(frame, tag) = saveframe(frame, "snapshots/$tag.png")
snap(frame) = snapshot(frame, "latest")

function saveframes(frames)
    length(frames) == 0 && return
    (sy, sx) = size(first(frames))
    try
        open(`ffmpeg -y -f rawvideo -pix_fmt gray -s:v $(sy)x$(sx) -r 25 -i pipe:0 movie.mkv`, "w") do out
            for frame in frames
                write(out, reinterpret.(UInt8, N0f8.(frame)))
            end
        end
    catch err
        println("export to video failed: $(err)")
        println("you may need to install the `ffmpeg` command-line program.")
    end
end

