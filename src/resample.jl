

shouldresample(w) = true

resample(pf::ParticleFilter, M=num_particles(pf)) = resample(pf.resampling_strategy, pf.s.w, pf.s.j, pf.s.bins)
resample(T::Type{<:ResamplingStrategy}, s::PFstate, M=num_particles(s)) = resample(T, s.w, s.j, s.bins)
resample(T::Type{<:ResamplingStrategy}, w, M=num_particles(pf)) = resample(T, w, zeros(Int,length(w)), zeros(length(w)))

function resample(::Type{ResampleSystematic}, w, j, bins, M = length(w))
    N = length(w)
    bins[1] = exp(w[1])
    for i = 2:N
        bins[i] = bins[i-1] + exp(w[i])
    end
    s = (rand()/M):(1/M):bins[end]
    bo = 1
    for i = 1:N
        @inbounds for b = bo:N
            if s[i] < bins[b]
                j[i] = b
                bo = b
                break
            end
        end
    end
    return j
end


function resample(::Type{ResampleSystematicExp}, w, j, bins, M = length(w))
    N = length(w)
    cumsum!(bins, w)
    s = (rand()/M):(1/M):bins[end]
    bo = 1
    for i = 1:N
        @inbounds for b = bo:N
            if s[i] < bins[b]
                j[i] = b
                bo = b
                break
            end
        end
    end
    return j
end



# """
# There is probably lots of room for improvement here. All bins need not be formed in the beginning.
# One only has to keep 1 values, the current upper limit, no array needed.
# """
function draw_one_categorical(w)
    bins = cumsum(w)
    s = rand()*bins[end]
    midpoint = round(Int64,length(bins)÷2)
    if s < bins[midpoint]
        for b = 1:midpoint
            if s < bins[b]
                return b
            end
        end
    else
        for b = midpoint:length(bins)
            if s < bins[b]
                return b
            end
        end
    end
end
