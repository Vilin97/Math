# https://www.janestreet.com/puzzles/current-puzzle/

using LinearAlgebra

const left_rotation_matrix = [0 0 1; 0 1 0; -1 0 0]'
const right_rotation_matrix = convert(Matrix{Int64}, inv(left_rotation_matrix))
const forward_rotation_matrix = [1 0 0; 0 0 -1; 0 1 0]'
const backward_rotation_matrix = convert(Matrix{Int64}, inv(forward_rotation_matrix))

const maze = [57 33 132 268 492 732;
              81 123 240 443 353 508;
              186 42 195 704 452 228;
              -7 2 357 452 317 395;
              5 23 -4 592 445 620;
              0 77 32 403 337 452]

function rotation_matrix(direction)
    direction == :l && return left_rotation_matrix
    direction == :r && return right_rotation_matrix
    direction == :u && return forward_rotation_matrix
    # direction == :d && return backward_rotation_matrix
    return backward_rotation_matrix
end

function move_position(position, direction)
    direction == :l && return position + [0, -1]
    direction == :r && return position + [0, 1]
    direction == :u && return position + [-1, 0]
    # direction == :d && return position + [1, 0]
    return position + [1, 0]
end

move(die :: Dict{T, U}, position, direction) where {T, U} = (Dict{T, U}([(rotation_matrix(direction) * k => v) for (k, v) in die]), move_position(position, direction))

function can_move(die, position, direction, score, turn)
    new_die, new_position = move(die, position, direction)
    die_value = new_die[[0,0,1]]
    inbound_position = 1 <= new_position[1] && new_position[1] <= 6 && 1 <= new_position[2] && new_position[2] <= 6
    if die_value === nothing
        return inbound_position && (maze[new_position...] - score)%turn==0
    else
        new_score = score + die_value*turn
        return inbound_position && new_score == maze[new_position...]
    end
end

function dfs(die, positions, score, turn)
    position = positions[end]
    position == [1,6] && println("positions:\n$positions\ndie:\n$die")
    viable_directions = filter!(d -> can_move(die, position, d, score, turn), [:r, :u, :l, :d])
    # println("$(repeat(' ', turn))turn $turn, position $position")
    for d in viable_directions
        new_die, new_position = move(die, position, d)
        # @show new_die, new_position
        new_score = maze[new_position...]
        new_die[[0,0,1]] = convert(Int64, (new_score - score)/turn)
        new_positions = vcat(positions, [new_position])
        # println("$(repeat(' ', turn+1))direction $d, die value $(new_die[[0,0,1]])")
        dfs(new_die, new_positions, new_score, turn+1)
    end
end

    
initial_die = Dict{Vector{Int64}, Union{Nothing, Int64}}(
    [[1,0,0] => nothing, # x
    [-1,0,0] => nothing,
    [0,1,0] => nothing,  # y
    [0,-1,0] => nothing,
    [0,0,1] => nothing,  # z
    [0,0,-1] => nothing]
)
initial_position = [6,1]
initial_score = 0
initial_turn = 1

dfs(initial_die, [initial_position], initial_score, initial_turn)

positions =
[[5, 1], [5, 2], [5, 3], [6, 3], [6, 2], [5, 2], [4, 2], [3, 2], [2, 2], [1, 2], [1, 3], [2, 3], [2, 2], [2, 1], [3, 1], [3, 2], [3, 3], [4, 3], [4, 4], [5, 4], [6, 4], [6, 5], [6, 6], [5, 6], [4, 6], [4, 5], [4, 4], [3, 4], [2, 4], [2, 5], [2, 6], [1, 6]]
die =
Dict{Vector{Int64}, Union{Nothing, Int64}}([0, 1, 0] => 5, [0, -1, 0] => -9, [1, 0, 0] => -3, [0, 0, 1] => 7, [0, 0, -1] => 9, [-1, 0, 0] => 9)

function direction_from_vector(vector)
    vector == [0, -1] && return :l
    vector == [0, 1] && return :r
    vector == [-1, 0] && return :u
    vector == [1, 0] && return :d
end

function walk(positions, die)
    directions = vcat(:u,[direction_from_vector(positions[i]-positions[i-1]) for i in 2:length(positions)])
    scores = [maze[position...] for position in positions]
    turns = 1:length(positions)
    for (direction, position, score, turn) in zip(directions, positions, scores, turns)
        die_face = Int64(( turn > 1 ? score - scores[turn-1] : score)/turn)
        @assert die_face in values(die)
        println("Turn $turn.")
        println("  Moving $direction to $position.")
        println("  Score $score")
        println("  Die face $die_face")
    end
end

sum([maze[i,j] for i in 1:6 for j in 1:6 if !([i,j] in positions)])