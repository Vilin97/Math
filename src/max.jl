using Distributions, Plots, QuadGK
import StatsBase: moment

pdf_M(dist, n, x) = n*cdf(dist, x)^(n-1)*pdf(dist, x)
moment(pdf, k, support) = quadgk(x -> pdf(x)*x^k, support[1], support[2])
moment_M(dist, n, k) = moment(
    x -> pdf_M(dist, n, x), 
    k, 
    ( maximum([-100.,support(dist).lb]), minimum([100., support(dist).ub]) ))[1]
mean_M(dist, n) = moment_M(dist, n, 1)
var_M(dist, n) = moment_M(dist, n, 2) - moment_M(dist, n, 1)^2

M(dist, n, m = 1) = maximum(rand(dist, n, m), dims = 1) |> vec
function maxstats(dist, ns, m) 
    means = zeros(size(ns))
    variances = zeros(size(ns))
    for (i,n) in enumerate(ns)
        Mns = M(dist, n, m)
        means[i] = mean(Mns)
        variances[i] = var(Mns)
    end
    means, variances
end
function plot_max_stats(dist, ns, means,  expected_means, variances, expected_variances, dist_name)
    p = plot(ns, means, label = "Monte Carlo mean", title = "maximum of n $dist_name rv's", xaxis = "n", size = (1000,700), legend = :inside);
    plot!(ns, expected_means[1], label = "expected mean: $(expected_means[2])");
    plot!(ns, mean_M.(dist, ns), label = "expected mean: numerical integration");
    plot!(ns, variances, label = "Monte Carlo variance");
    plot!(ns, expected_variances[1], label = "expected variance: $(expected_variances[2])");
    plot!(ns, var_M.(dist, ns), label = "expected variance: numerical integration");
    # savefig(p, "max_$(dist_name)_stats")
    p
end

m = 3*10^2
ns = 10:10^3:10^5
means_exp, variances_exp = maxstats(Exponential(), ns, m)
means_norm, variances_norm = maxstats(Normal(), ns, m)

expected_means_exp = (log.(ns) .+ MathConstants.γ, "log n + γ")
expected_variances_exp = (π^2/6 .* ones(size(ns)), "π²/6")
expected_means_norm = (.√(2 .* log.(ns)), "√(2log n)")
expected_variances_norm = (1 ./ .√(log.(ns)), "1/√log n")

p_exp = plot_max_stats(Exponential(), ns, means_exp, expected_means_exp, variances_exp, expected_variances_exp, "Exponential");

p_norm = plot_max_stats(Normal(), ns, means_norm, expected_means_norm, variances_norm, expected_variances_norm, "Normal");
p = plot(p_exp, p_norm)
savefig(p, "max_stats_norm_exp")