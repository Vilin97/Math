# symbolics
using Symbolics
@variables x1 x2 x3
@variables z1 z2 z3
x = [x1, x2, x3]
z = [z1, z2, z3]
x*z'*z - z*z'*x

@variables x1 x2 x3
@variables y1 y2 y3
x = [x1, x2, x3]
y = [y1, y2, y3]
@variables sx1 sx2 sx3
@variables sy1 sy2 sy3
sx = [sx1, sx2, sx3]
sy = [sy1, sy2, sy3]

z = x - y
A(z, x) = x*z'*z - z*z'*x
A(x-y, sx - sy)

@variables x[1:3] y[1:3] sx[1:3] sy[1:3]
A(x-y, sx - sy)


# numerics
using Distributions, LinearAlgebra, Zygote
Kt(t) = 1 - exp(-t/6)
const K = Kt(5.5)
Z = MvNormal(I(3) * K)
p(x) = pdf(Z, x) * ((5K - 3)/(2K) + (1-K)/(2K^2) * (x'*x))
s(x) = gradient(x -> log(p(x)), x)[1]

x = zeros(3)
x[1] = 0.1
s(x)
y = zeros(3)
y[1] = 0.1
y[2] = 0.2
s(y)
s(x) - s(y)
A(x-y, s(x) - s(y)) * p(y)

integrand(x,y) = A(x-y, s(x) - s(y)) * p(y)
x = zeros(3)
plots = []
for x1 in 0.1:0.2:1
    x[1] = x1
    plt = plot(0:0.1:4, y -> (s(x) - integrand(x, [0., y, 0.]))[1], label = "1", title = "x = $x")
    plot!(plt, 0:0.1:4, y -> (s(x) - integrand(x, [0., y, 0.]))[2], label = "2")
    plot!(plt, 0:0.1:4, y -> (s(x) - integrand(x, [0., y, 0.]))[3], label = "3")
    push!(plots, plt)
end
plot(plots..., layout = (length(plots), 1), size = (1200, 1600))


v(x) = solve(IntegralProblem((y,_) -> integrand(x,y), zeros(3), 5ones(3)), HCubatureJL(), reltol = 1e-3, abstol = 1e-3)
v([2,0,0])
maybe_neg(x) = # this does not work

using Integrals
f(x, p) = sum(sin.(x))
prob = IntegralProblem(f, ones(2), 3ones(2))
sol = solve(prob, HCubatureJL(), reltol = 1e-3, abstol = 1e-3)

using Integrals
f(x, p) = sin(x * p)
p = 1.7
prob = IntegralProblem(f, -2, 5, p)
sol = solve(prob, QuadGKJL())