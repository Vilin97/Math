using Plots

N(n, t, k) = binomial(n,k) * (n+1) * t^k * (1-t)^(n-k)

n = big(100)
t = 1/2
p = plot();
for n in 10:1000
    plot!(p, 0:n, [N(big(n), t, k) for k in 0:n])
end
show(p)
p

