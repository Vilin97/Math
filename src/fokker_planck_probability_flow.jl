# implementing the algorithm from "probability flow solution of the fokker-planck equation" 2022

using Distributions, Flux, LinearAlgebra, Plots
using Zygote: gradient
using Flux.Optimise: Adam
using Flux: params, train!

maybewrap(x) = x
maybewrap(x::T) where {T <: Number} = T[x]

function plot_s_1d(s, xs)
  x_coordinates = minimum(xs) : (maximum(xs) - minimum(xs))/99 : maximum(xs)
  s_values = vcat(s.(eachcol(reshape(x_coordinates, 1, 100)))...)
  p = plot(x_coordinates, s_values)
  scatter!(p, reshape(xs, size(xs, 2)), vcat(s.(eachcol(xs))...))
end

# divergence of vector field s at x
divergence(s, x) = sum(gradient(x -> s(x)[i], x)[1][i] for i in 1:length(x))
loss(s, xs) = sum(sum(s(x).^2) + 2.0*divergence(s, x) for x in xs)
loss(s, xs :: Matrix) =  loss(s, eachcol(xs)) 

function custom_train!(s, xs; optimiser = Adam(), num_steps = 25)
  θ = params(s)
  grads = gradient(() -> loss(s, xs), θ)
  for _ in 1:num_steps
    Flux.update!(optimiser, θ, grads)
  end
end

propagate(x, t, Δt, b, D, s) = x + Δt * b(x, t) + D(x, t)*s(x)

"""
xs  : sample from initial probability distribution
Δts : list of Δt's
b   : Rᵈ → Rᵈ
D   : Rᵈ → Rᵈˣᵈ
n   : number of particles
s   : NN to approximate score ∇log ρ
"""
function sbtm(xs, Δts, b, D, s)
  trajectories = zeros(size(xs)..., 1+length(Δts)) # trajectories[:, i, k+1] is particle i at time k
  trajectories[:, :, 1] = xs
  sbtm!(trajectories, Δts, b, D, s)
  trajectories
end

function sbtm!(trajectories, Δts, b, D, s)
  t = zero(eltype(Δts))
  for (k, Δt) in enumerate(Δts)
    xs_k = trajectories[:, :, k]
    custom_train!(s, xs_k)
    for (i, x) in enumerate(eachcol(xs_k))
      trajectories[:, i, k+1] = propagate(x, t, Δt, b, D, s)
    end
    t += Δt
  end
end

# learning to animate
function animate_2d(trajectories, fps = 5)
  p = scatter(trajectories[1,:,1], trajectories[2,:,1], 
  title = "time 0",
  label = nothing, 
  color=RGB(0.0, 0.0, 1.0), 
  xlims = (-1.5, 1.5), ylims = (-1.5, 1.5));
  anim = @animate for k ∈ axes(trajectories, 3)
    λ = k/size(trajectories, 3)
    red = λ > 0.5 ? 2. *(λ - 0.5) : 0.
    green = 1. - abs(1. - 2. * λ)
    blue = λ < 0.5 ? 2. * (0.5-λ) : 0.
    scatter!(p, trajectories[1,:,k], trajectories[2,:,k], 
    title = "time $k",
    label = nothing, 
    color = RGB(red, green, blue), 
    xlims = (-1.5, 1.5), ylims = (-1.5, 1.5))
  end
  gif(anim, "anim_fps$fps.gif", fps = fps)
end

# experimenting with all particles attracting to the origin
function attractive_origin()
  d = 2
  # ρ₀ = MvNormal(I(d))
  # n = 10
  # xs = rand(ρ₀, n)
  Δts = 0.01*ones(50)
  b(x, t) = -x
  D(x, t) = 0.1
  s = Chain(
    Dense(d => 50, relu),
    Dense(50 => d))
  xs = Float64[-1  0  1 -1  0  1 -1  0  1;
        -1 -1 -1  0  0  0  1  1  1];
  sbtm(xs, Δts, b, D, s)
end
trajectories = attractive_origin()
animation = animate_2d(trajectories)

# reproducing first numerical experiment: repelling particles attracted to a moving trap
function repel_attract()
  d_bar = 2
  N = 50
  d = d_bar*N
  a = 2.
  w = 1.
  β(t) = a*[cos(π*w*t), sin(π*w*t)]'




end


















# learning the sin function
function learn_sin()
  s = Chain(
    maybewrap,
    Dense(1 => 50, relu),
    Dense(50 => 50, relu),
    Dense(50 => 50, relu),
    Dense(50 => 50, relu),
    Dense(50 => 1))
  f(x) = sin.(6.28 .* x .+ 3.14)
  x_train = hcat(0.5 : 3/100 : 3.5 ...)
  data = [(x_train, f.(x_train))]
  mse_loss(x, y) = Flux.Losses.mse(s(x), y)
  p = plot(x_train[1,:], vcat(s.(x_train)[1,:]...));
  for i in 1:5*10^3
    train!(mse_loss, params(s), data, Descent(10^-1))
    if i%10^3 == 0
      @show mse_loss(data[1]...)
      plot!(p, x_train[1,:], vcat(s.(x_train)[1,:]...))
    end
  end
  s, p
end

# experimenting with (over)fitting on 3 points
s, p = learn_sin()
xs = [1. 2. 3.;] 
custom_train!(s, xs, optimiser = Descent(10^-4), num_steps = 100)
loss(s, xs)
plot_s_1d(s,xs)

