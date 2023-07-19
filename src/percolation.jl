function grid(n, d, p)
    # n: size of grid
    # d: dimension of grid
    # p: probability of site being open
    # return: grid of size n^d with probability p of being open (1)
    return rand([n for _ in 1:d]...) .< p
end

function is_open(g)
    # return: true if grid g is open, false otherwise
    d = ndims(g)
    # iterate over all indices except last
    for ind in view(CartesianIndices(g), ntuple(Returns(:), d-1)..., 1)
        if dfs(g, ind)
            return true
        end
    end
    return false
end

function dfs(g, ind)
    explored_inds = CartesianIndex[]
    dfs(g, ind, explored_inds)
end

"dfs from ind to reach bottom"
function dfs(g, ind, explored_inds)
    if g[ind] == 0
        return false
    end
    push!(explored_inds, ind)
    d = ndims(g)
    # @show ind
    # @show g[ind] == 1 && last(Tuple(ind)) == size(g, d)
    if g[ind] == 1 && last(Tuple(ind)) == size(g, d)
        return true
    end
    nbr_ind = ind + CartesianIndex(zeros(Int,d-1)...,1)
    # @show nbr_ind
    if nbr_ind in CartesianIndices(g) && g[nbr_ind] == 1 && !(nbr_ind in explored_inds) 
        return dfs(g, nbr_ind, explored_inds)
    end
    for dim in 1:d-1
        offset = CartesianIndex(zeros(Int,dim-1)...,1,zeros(Int,d-dim-1)...,0)
        nbr_ind = ind + offset
        # @show nbr_ind
        if nbr_ind in CartesianIndices(g) && g[nbr_ind] == 1 && !(nbr_ind in explored_inds)
            return dfs(g, nbr_ind, explored_inds)
        end
        nbr_ind = ind - offset
        # @show nbr_ind
        if nbr_ind in CartesianIndices(g) && g[nbr_ind] == 1 && !(nbr_ind in explored_inds)
            return dfs(g, nbr_ind, explored_inds)
        end
    end
    nbr_ind = ind - CartesianIndex(zeros(Int,d-1)...,1)
    # @show nbr_ind
    if nbr_ind in CartesianIndices(g) && g[nbr_ind] == 1 && !(nbr_ind in explored_inds)
        return dfs(g, nbr_ind, explored_inds)
    end
    return false
end

function prob_open(n, d, p; N = 10^3)
    num_open = 0
    for _ in 1:N
        g = grid(n,d,p)
        num_open += is_open(g)
    end
    return num_open/N
end

ns = 2:5:102
ds = 2:11
ps = 0.4:0.2:0.8
@time n_probs = [prob_open(n, 2, 0.6) for n in ns]
@time d_probs = [prob_open(2, d, 0.6) for d in ds]
@time p_probs = [prob_open(20, 2, p) for p in ps]

using Plots
p1 = plot(ns, n_probs, ylabel = "prob of open", xlabel = "n", title = "d = 2, p = 0.6");
p2 = plot(ds, d_probs, ylabel = "prob of open", xlabel = "d", title = "n = 2, p = 0.6");
p3 = plot(ps, p_probs, ylabel = "prob of open", xlabel = "p", title = "n = 20, d = 2");
plot(p1, p2, p3, layout = (3,1), size = (1000, 800))

# timing
n = 10_000
d = 2
p = 0.5
g = grid(n, d, p)
is_open(g)
@time is_open(g) # 0.04 seconds

n = 100
d = 4
p = 0.5
g = grid(n, d, p)
is_open(g)
@time is_open(g) # 0.007-0.02 seconds