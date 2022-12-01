using Distributions, Plots
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
function plot_max_stats(dist, ns, means, variances, dist_name)
    p = plot(ns, means, label = "mean", title = "maximum of n $dist_name rv's", xaxis = "n", size = (1000,700));
    plot!(ns, log.(ns), label = "expected mean: O(log n)");
    plot!(ns, mean_M.(dist, ns), label = "expected mean: numerical integration");
    plot!(ns, variances, label = "variance");
    plot!(ns, ones(size(ns)), label = "expected variance: O(1)");
    plot!(ns, var_M.(dist, ns), label = "expected variance: numerical integration");
    # savefig(p, "max_$(dist_name)_stats")
    p
end
m = 10^3
ns = 10:10^3:10^5

dist = Exponential()
means_exp, variances_exp = maxstats(dist, ns, m)
p_exp = plot_max_stats(Exponential(), ns, means_exp, variances_exp, "Exponential");

dist = Normal()
means_norm, variances_norm = maxstats(dist, ns, m)
p_norm = plot_max_stats(Normal(), ns, means_norm, variances_norm, "Normal");
p = plot(p_exp, p_norm)
savefig(p, "max_stats_norm_exp")