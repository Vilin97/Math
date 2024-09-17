# Import necessary packages
using Random
using Statistics
using Plots

# Function to run a single trial and return the time it takes to get bingo
function run_trial(n::Int)
    # Precompute cell to row and column mappings
    rows = repeat(1:n, inner=n)  # Row for each cell
    cols = repeat(1:n, outer=n)  # Column for each cell

    # Precompute whether each cell is on the main diagonals
    diag1 = [i == j for i in 1:n, j in 1:n]
    diag2 = [i + j == n + 1 for i in 1:n, j in 1:n]

    # Flatten the diagonal matrices
    is_diag1 = vec(diag1)
    is_diag2 = vec(diag2)

    # Initialize counts for rows, columns, and diagonals
    row_counts = zeros(Int, n)
    col_counts = zeros(Int, n)
    diag1_count = 0
    diag2_count = 0

    # Create a random permutation of cell indices
    cell_order = shuffle(1:(n^2))

    # Iterate through the shuffled cells
    for t in 1:(n^2)
        cell = cell_order[t]
        row = rows[cell]
        col = cols[cell]

        # Update counts
        row_counts[row] += 1
        col_counts[col] += 1

        if is_diag1[cell]
            diag1_count += 1
        end

        if is_diag2[cell]
            diag2_count += 1
        end

        # Check if any line is completed
        if row_counts[row] == n || col_counts[col] == n || diag1_count == n || diag2_count == n
            return t  # Return the time it took to get bingo
        end
    end

    return n^2  # Fallback (in case all cells are marked without completing a line, unlikely)
end

# Function to estimate E[T] for a given n using multiple trials
function estimate_E_T(n::Int, trials::Int)
    times = zeros(Int, trials)
    for trial in 1:trials
        times[trial] = run_trial(n)
    end
    return mean(times)
end

# Function to plot the simulated and theoretical values along with relative error
function plot_results(ns, E_T_simulated, E_T_theoretical)
    plt = plot(layout = (2, 1), size=(800, 600))  # Create a 2-row subplot layout
    
    # Plot Simulated vs Theoretical E[T]
    plot!(plt[1], ns, E_T_simulated, label="Simulated E[T]", marker=:circle, markersize=3, linewidth=2)
    plot!(plt[1], ns, E_T_theoretical, label="Theoretical n² - n ln(n)", linestyle=:dash, linewidth=2)
    xlabel!(plt[1], "Grid Size n")
    ylabel!(plt[1], "Expected Time E[T]")
    title!(plt[1], "Expected Time Until Bingo on an n×n Grid")
    
    # Calculate and plot relative error
    relative_error = abs.((E_T_simulated .- E_T_theoretical) ./ E_T_theoretical)
    plot!(plt[2], ns, relative_error, label="Relative Error", marker=:circle, markersize=3, linewidth=2)
    xlabel!(plt[2], "Grid Size n")
    ylabel!(plt[2], "Relative Error")
    title!(plt[2], "Relative Error Between Simulated and Theoretical E[T]")
    
    plt  # Return the plot object
end

# Main simulation parameters
n_min = 10
n_max = 500
n_step = 10
trials = 1000  # Number of trials per n

# Initialize arrays to store results
ns = n_min:n_step:n_max
E_T_simulated = zeros(Float64, length(ns))
E_T_theoretical = zeros(Float64, length(ns))

# Run simulations for each n
println("Starting simulations...")
for (idx, n) in enumerate(ns)
    println("Simulating for n = $n...")
    E_T_simulated[idx] = estimate_E_T(n, trials)
    E_T_theoretical[idx] = n^2 - n * log(n)
end
println("Simulations completed.")

# Call the function to plot the results and relative error
plt = plot_results(ns, E_T_simulated, E_T_theoretical)
savefig(plt, "bingo_simulation_results.png")  # Save the plot as an image file