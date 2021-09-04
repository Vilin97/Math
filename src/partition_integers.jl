# trying to partition integers in infinitely many orbits of widths n^2, n = 2,3,4,...
using ProgressLogging, LaTeXStrings

"return the last n to fit in x"
function last_n(x)
    for n in 1:length(x)
        width(n) > length(x) && return n-1
    end
end

"find the next spot after idx, ensuring it is no further than width"
function find_next_spot(x, width, idx)
    # if x[idx+width] is open, return. Else, keep going down to x[idx+1]
    for k in width:-1:1
        x[idx+k] == 1 && return idx+k
    end
    # if has not found a spot between idx and idx+width, return -1
    return -1
end

"place the orbit of n"
function place_n!(x, n)
    w = width(n)
    idx = 0 # the first spot will be x[w]
    while idx <= length(x)-w
        new_idx = find_next_spot(x, w, idx)
        if new_idx == -1
            @show n, w, idx
            error("unable to find the next spot")
        end
        idx = new_idx
        x[idx] = n
    end
end

"place all orbits"
function place_ns!(x)
    @progress "placing ns" for n in 2:last_n(x)
        place_n!(x, n)
    end
end

"excess density is the proportion of x that could be removed without increasing width at the abscense of collisions between orbis"
excess_density(x, n) = count(i -> i == n, x)/length(x) - 1/width(n)

"returns an array of excess densities"
function excess_densities(x)
    counts = zeros(Int, last_n(x))
    for n in x
        counts[n] += 1
    end
    res=[count/length(x) - 1/width(n) for (n,count) in enumerate(counts)]
    res[1] += 1.0
    res
end

# placing ns and plotting
plt = plot()
length_x = 10^8
sums_eds = Float64[]
@progress "placing and plotting" for power in 2:-0.2:1.4
    @show power
    x = ones(Int, length_x)
    coefficient = 4
    global width(n) = floor(Int,coefficient*n^power)
    place_ns!(x)

    eds = excess_densities(x)
    push!(sums_eds, sum(eds[2:end]))
    plot!(plt, 2:20, eds[2:20], label = "$coefficient*n^$power")
end
plot!(plt, size = (800,600), xticks = 2:20, yaxis = "excess density", xaxis = "orbits", title = "excess densities with widths below a power", legendtitle = "widths")
savefig(plt, "excess_densities_plot")

# exploring edge cases
power = 1.7
global width(n) = floor(Int,2*n^power)
x = ones(Int, 10^7)
place_ns!(x)
@show sum(eds[2:end])
