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

# ] activate Zygote
using Zygote: gradient
using Flux

const D = 5
s = Chain(
    Dense(D => 10, σ),
    Dense(10 => D))
∇s(s, x) = sum((gradient(x -> s(x)[i], x))[1][i] for i in 1:D)
loss_grad(x) = gradient(s -> ∇s(s, x), s)
loss_grad(rand(5))




x = [2, 1];

y = [2, 0];

gs = gradient(Flux.params(x, y)) do
         f(x, y)
       end

gs[x]

gs[y]



W = rand(2, 5)
b = rand(2)

predict(x) = W*x .+ b

function loss(x, y)
  ŷ = predict(x)
  sum((y .- ŷ).^2)
end

x, y = rand(5), rand(2) # Dummy data
loss(x, y) # ~ 3

gs = gradient(() -> loss(x, y), Flux.params(W, b, x))

W -= 0.1*gs[W]
b -= 0.1*gs[b]

loss(x,y)



W1 = rand(3, 5)
b1 = rand(3)
layer1(x) = W1 * x .+ b1

W2 = rand(2, 3)
b2 = rand(2)
layer2(x) = W2 * x .+ b2

model(x) = layer2(σ.(layer1(x)))

model(rand(5)) # => 2-element vector

  
using Flux, Zygote, LinearAlgebra

d = 5

s = Chain(
    Dense(d => 10, σ),
    Dense(10 => d))

∇s(x) = sum(diag(jacobian(s, x)[1])) # one way of getting divergence
loss_grad(x) = gradient(() -> ∇s(x), Flux.params(s)) #errors
loss_grad(rand(5)) # ERROR: Mutating arrays is not supported -- called copyto!(SubArray{Float64, 1, Matrix{Float64}, Tuple{Int64, Base.Slice{Base.OneTo{Int64}}}, true}, ...)

∇s(x) = sum((gradient(x -> s(x)[i], x))[1][i] for i in 1:d) # another way of getting divergence
loss_grad(x) = gradient(() -> ∇s(x), Flux.params(s)) #errors
loss_grad(rand(5)) # ERROR: Can't differentiate foreigncall expression $(Expr(:foreigncall, :(:jl_eqtable_get), Any, svec(Any, Any, Any), 0, :(:ccall), %5, %3, %4)).


# loss(xs) = sum([sum(s(x).^2) + 2*∇s(x) for x in xs])





using Zygote: gradient
g(x,y) = x+y 
dxg(x,y) = gradient(x -> g(x,y), x)[1] #partial wrt x
dxyg(x,y) = gradient(y -> dxg(x,y), y)[1] #mixed second derivative
dxyg(1,1) # 0.0, as expected

g1(x,y) = (x+y)[1]
dxg1(x,y) = gradient(x -> g1(x,y), x)[1][1] #partial of g₁ wrt x₁
dxg1(ones(2), ones(2)) # 1.0, as expected
dxyg1(x,y) = gradient(y -> dxg1(x,y), y)[1][1] #partial of dxg1 wrt y₁
dxyg1(ones(2), ones(2)) # ERROR: Need an adjoint for constructor Zygote.OneElement{Float64, 1, Tuple{Int64}, Tuple{Base.OneTo{Int64}}}. Gradient is of type Zygote.OneElement{Float64, 1, Tuple{Int64}, Tuple{Base.OneTo{Int64}}}

g2(x,y) = transpose(x)*y
dxg2(x,y) = gradient(x -> g2(x,y), x)[1][1] 
dxyg2(x,y) = gradient(y -> dxg2(x,y), y)[1][1] 
dxyg2(ones(2), ones(2)) # 1.0, as expected

g3(x,y) = sum(x.*y)
dxg3(x,y) = gradient(x -> g3(x,y), x)[1][1] 
dxyg3(x,y) = gradient(y -> dxg3(x,y), y)[1][1] 
dxyg3(ones(2),ones(2)) # 1.0, as expected

g4(x,y) = x[1]*y[1] + x[2]*y[2]
dxg4(x,y) = gradient(x -> g4(x,y), x)[1][1] #partial wrt x
dxyg4(x,y) = gradient(y -> dxg4(x,y), y)[1][1] #mixed second derivative
dxyg4(ones(2),ones(2)) # ERROR: Need an adjoint for constructor Zygote.OneElement{Float64, 1, Tuple{Int64}, Tuple{Base.OneTo{Int64}}}. Gradient is of type Vector{Float64}

