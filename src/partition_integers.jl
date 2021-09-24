# trying to partition integers in infinitely many orbits of widths n^2, n = 2,3,4,...
using ProgressLogging, LaTeXStrings
using Plots

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

"place N orbits"
function place_ns!(x, N = last_n(x))
    @progress "placing ns" for n in 2:N
        place_n!(x, n)
    end
end

"excess density is the proportion of x that could be removed without increasing width at the abscense of collisions between orbis"
excess_density(x, n) = count(i -> i == n, x)/length(x) - 1/width(n)

"returns an array of excess densities"
function excess_densities(x, N = last_n(x))
    counts = zeros(Int, N)
    for n in x
        counts[n] += 1
    end
    res=[count/length(x) - 1/width(n) for (n,count) in enumerate(counts)]
    res[1] = counts[1]/length(x)
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
global width(n) = ceil(Int,1.05429 * n^power)
x = ones(Int, 10^8)
place_ns!(x)

# trying to break greedy by choosing widths as small as possible while keeping the sum of reciprocals below 1
greedy_widths = ones(Int, 7)
greedy_widths[2] = 2
for index in 3:length(greedy_widths)
    greedy_widths[index] = greedy_widths[index-1]^2 - greedy_widths[index-1] + 1
end

global width(n) = ceil(Int,1.01*greedy_widths[n])
x = ones(Int, 10^7)
place_ns!(x, 7)
@show x[1:20]
eds = excess_densities(x, 7)