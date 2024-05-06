# Given 2 eggs and a 100 floor building, find the minimum number of steps to find the floor at which the egg breaks.

function find_min_floor(building_floor, num_eggs)
    # res[i, j] == (K, r), where K is the minimum number of steps to find the floor, and r is the floor to drop an egg
    res = fill((0, 0), building_floor, num_eggs)
    for floor in 1:building_floor, egg in 1:num_eggs
        if floor == 1 # 1 step to find the floor if there is only 1 floor
            res[floor, egg] = (1, 1)
        elseif egg == 1 # if there is only 1 egg, we have to check every floor, starting from the bottom
            res[floor, egg] = (res[floor-1, egg][1] + 1, 1)
        else
            res[floor, egg] = minimum([(1 + max(r==1 ? 0 : res[r-1, egg-1][1], r==floor ? 0 : res[floor-r, egg][1]), r) for r in 1:floor])
        end
    end
    return res
end

function reconstruct_steps(res, threshold_floor; verbose=true)
    building_floor, num_eggs = size(res)
    current_relative_floor = building_floor
    base_floor = 0
    eggs_left = num_eggs
    floors = []
    while eggs_left > 0 && current_relative_floor > 0
        _, next_relative_floor = res[current_relative_floor, eggs_left]
        egg_breaks = base_floor + next_relative_floor >= threshold_floor
        push!(floors, base_floor + next_relative_floor)

        verbose && println("You throw an egg from floor $(lpad(base_floor + next_relative_floor, length(string(building_floor)))). The egg $(egg_breaks ? "breaks." : "does not break.")")
        threshold_guess = base_floor + next_relative_floor + (egg_breaks ? 0 : 1)
        
        if egg_breaks
            current_relative_floor = next_relative_floor - 1
            eggs_left -= 1
            verbose && println("  You now have $eggs_left eggs left.")
        else
            current_relative_floor = current_relative_floor - next_relative_floor
            base_floor += next_relative_floor
        end
        verbose && (eggs_left == 0 || current_relative_floor == 0) && println("You found the threshold floor at $(lpad(threshold_guess, length(string(building_floor)))) in $(length(floors)) throws.")
    end
    return floors
end

function find_hardest_threshold_floors(building_floor, eggs)
    res = find_min_floor(building_floor, eggs)
    most_throws = maximum(threshold_floor -> length(reconstruct_steps(res, threshold_floor, verbose=false)), 1:building_floor)
    hardest_thresholds = filter(threshold_floor -> length(reconstruct_steps(res, threshold_floor, verbose=false)) == most_throws, 1:building_floor)
    return hardest_thresholds
end

function main(building_floor, num_eggs)
    res = find_min_floor(building_floor, num_eggs)
    println("The minimum number of steps to find the floor is: ", res[end, end][1])
    hardest_thresholds = find_hardest_threshold_floors(building_floor, num_eggs)
    println("There are $(length(hardest_thresholds)) hardest threshold floors to find: \n", hardest_thresholds)
    sample_threshold = building_floor ÷ 2
    println("Here is what the sequence of throws with threshold = $sample_threshold looks like")
    reconstruct_steps(res, sample_threshold)

    sample_threshold = building_floor+1
    println("Here is what the sequence of throws with threshold = $sample_threshold looks like")
    reconstruct_steps(res, sample_threshold)
    nothing
end

using Plots
P = 4
eggs = 2:round(Int, log(10^P))
building_heights = 10 .^ (2:P)
@time res = find_min_floor(building_heights[end], eggs[end])

plt = plot(xlabel = "number of eggs", ylabel = "min number of throws needed", title = "Number of throws needed to find the threshold floor");
for building_height in building_heights
    plot!(plt, eggs, egg -> res[building_height, egg][1], label="$building_height floors, $(res[building_height, 2][1]) throws with 2 eggs")
end
plt