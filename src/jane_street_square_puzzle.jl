using LinearAlgebra

step(a, b, c, d) = abs(a-b), abs(b-c), abs(c-d), abs(d-a)

function f(a, b, c, d, verbose = false)
    counter = 1
    while !(a==0 && b == 0 && c == 0 && d == 0)
        verbose && println("$a, $b, $c, $d")
        a, b, c, d = step(a, b, c, d)
        counter += 1
    end
    return counter
end

function experiment(ranges)
    longest = 0
    best_values = (0,0,0,0)
    for (a,b,c,d) in Iterators.product(ranges...)
        seq_length = f(a, b, c, d)
        if seq_length > longest || (seq_length == longest && a+b+c+d < sum(best_values))
            longest = seq_length
            best_values = (a,b,c,d)
        end
    end
    longest, best_values
end

function random_experiment(ranges, n=10^7)
    longest = 0
    best_values = (0,0,0,0)
    for _ in 1:n
        (a,b,c,d) = rand.(ranges)
        seq_length = f(a, b, c, d)
        if seq_length > longest || (seq_length == longest && a+b+c+d < sum(best_values))
            longest = seq_length
            best_values = (a,b,c,d)
        end
    end
    longest, best_values
end

# ranges = [0:100, 0:100, 0:10, 0:0]
# longest, best_values = experiment(ranges)
# print("Range $(ranges[1]) x $(ranges[2]) x $(ranges[3]) x $(ranges[4]) \n  longest sequence = $longest\n  values $best_values")

# ranges = [0:10^7, 0:10^7, 0:10^7, 0:0]
# longest, best_values = random_experiment(ranges, 10^7)
# print("Range $(ranges[1]) x $(ranges[2]) x $(ranges[3]) x $(ranges[4]) \n  longest sequence = $longest\n  values $best_values\n")

function symmetries(y :: T) where T
    f(y) = T([y[1], y[4], y[3], y[2]])
    y1 = circshift(y, 1)
    y2 = circshift(y1, 1)
    y3 = circshift(y2, 1)
    [y, y1, y2, y3, f(y), f(y1), f(y2), f(y3)]
end

function remove_symmetries(ys :: AbstractVector{T}) where T
    length(ys) == 1 && return ys
    result = Set{T}()
    for y in ys
        if length(findall(s->s in result, symmetries(y))) == 0
            push!(result, y)
        end
    end
    collect(result)
end

const possible_αs = collect(Iterators.product(repeat([[-1,1]], 4)...))

αs(y) = filter(α -> dot(α, y) == 0, possible_αs)

function find_prev(y :: T, αs :: AbstractVector{S}, verbose=1) where {T, S}
    possible_prev_xs = T[]
    # possible_prev_βs = S[]
    for β in [S([1, i, j, k]) for i in (-1,1) for j in (-1,1) for k in (-1,1) if (i, j, k)!=(1,1,1)]
        sum_β = sum(β)
        for α in αs
            K = dot(β[2:end], cumsum(α .* y)[1:3])
            if sum_β == 0 && K != 0 
                continue
            elseif sum_β == 0
                x1 = 10^7
            elseif K % sum_β == 0 # need x_1 = K_/sum_β to be an integer
                x1 = -K ÷ sum_β
            else
                continue
            end
            x2 = x1 + α[1]y[1]
            x3 = x2 + α[2]y[2]
            x4 = x3 + α[3]y[3]
            x = T([x1, x2, x3, x4])
            if x[1] >= 0 && x[2] >= 0 && x[3] >= 0 && x[4] >= 0
                (sum_β == 0) && (x .-= minimum(x)) # make one of the xi's zero if possible
                push!(possible_prev_xs, x)
                # push!(possible_prev_βs, β)
            end
        end
    end
    possible_prev_xs = remove_symmetries(possible_prev_xs)
    # possible_prev_βs = unique(possible_prev_βs)
    verbose>1 && println("Have $(length(possible_prev_xs)) solutions:\n $(hcat(possible_prev_xs...)')")
    possible_prev_xs#, possible_prev_βs
end

function find_prev_recursive!(deepest, y, verbose=1, depth = 2)
    "go up starting from y"
    verbose>0 && println("$(" "^depth)Depth $depth, y = $y")
    if depth == 0
        push!(deepest, y)
        return
    end
    αs_ = αs(y)
    possible_prev_xs = find_prev(y, αs_,verbose)
    for x in possible_prev_xs
        find_prev_recursive!(deepest, x, verbose, depth-1)
    end
end

y = 1*ones(Int, 4)
deepest = Set{typeof(y)}()
find_prev_recursive!(deepest, y, 1, 10)