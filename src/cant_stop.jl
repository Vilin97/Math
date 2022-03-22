combos(roll) = [(roll[1]+roll[2],roll[3]+roll[4]), (roll[1]+roll[3],roll[2]+roll[4]), (roll[1]+roll[4],roll[2]+roll[3])]

function best_combo(roll, vals)
    cs = combos(roll)
    scores = zeros(Int, length(roll))
    for (i,(v1,v2)) in enumerate(cs)
        if v1 == v2 && v1 in vals
            scores[i] = 3
        elseif v1 in vals && v2 in vals
            scores[i] = 2
        elseif v1 in vals || v2 in vals
            scores[i] = 1
        else
            scores[i] = 0
        end
    end
    best_ind = findmax(scores)[2]
    cs[best_ind]
end

function sim(vals, tops)
    counts = zeros(Int, length(vals))
    while minimum(tops - counts) > 0
        roll = rand(1:6,4)
        can_move = false
        best_c = best_combo(roll, vals)
        for v in best_c
            for (i,val) in enumerate(vals)
                if v == val
                    counts[i] += 1
                    can_move = true
                end
            end
        end
        if !can_move
            return 0, 0
        end
    end
    finished_val_ind = findmin(tops-counts)[2]
    return 1, finished_val_ind
end


vals = [6,7,8]
tops = [10,12,10]

N = 10^6
count = 0
val_counts = [0,0,0]
for i in 1:N
    simulation = sim(vals, tops)
    count += simulation[1]
    if simulation[2] > 0
        val_counts[simulation[2]] += 1
    end
end
prob = count/N
val_probs = val_counts/N