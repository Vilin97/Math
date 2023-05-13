function sumsto(x::Float64)
    0 <= x < exp2(970) || throw(ArgumentError("sum must be in [0,2^970)"))
    n, p₀ = Base.decompose(x) # integers such that `n*exp2(p₀) == x`
    [floatmax(); [exp2(p) for p in -1074:969 if iseven(n >> (p-p₀))]
    -floatmax(); [exp2(p) for p in -1074:969 if isodd(n >> (p-p₀))]]
end

randx() = reinterpret(Float64, reinterpret(UInt64, floatmax()/2^54) & rand(UInt64))

using Random
x = randx()
v = sumsto(x)
foldl(+, v)


n = 10^5
summation_results = zeros(n)
for i in 1:n
    summation_results[i] = foldl(+, shuffle(v))
end
sorted = sort(summation_results .+ eps())
#remove Inf
sorted = sorted[sorted .!= Inf]
using Plots
plot(sorted, xscale = :log10)
histogram(log.(2, sorted), title = "distribution of summation results for random shuffle of sumsto(x)", xlabel = "power of 2", size = (1200, 900))
plot(log.(2, summation_results .+ eps()))

# sorted = sort(v)
sum(log.(2, sorted))/length(sorted)