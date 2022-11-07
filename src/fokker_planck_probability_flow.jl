# implementing the algorithm from "probability flow solution of the fokker-planck equation" 2022

using Distributions, Flux

function sbtm(ρ₀, timesteps, b, D, n)
    xs = sample_dist(ρ₀, n)
    trajectories = zeros(n, 1+length(timesteps)) # trajectories[i,k+1] is particle i at time k
    trajectories[:, 1] = xs
    for (k, Δt) in enumerate(timesteps)
        s = optimize(xs)
        x = trajectories[i, k]
        trajectories[i, k+1] = x + Δt * (b(x)) + D(x)*s(x)
    end
    return trajectories
end

sample_dist(d :: Distribution, n) = rand(d, n)

