# Math
Random math scripts

## Empirical Bayes
This code implements the discrete Wasserstein gradient flow for the empirical Bayes model \( Y_i = \theta_i + \epsilon_i \), where \( \theta_i \) are uniformly sampled from the perimeter of a circle and \( \epsilon_i \sim N(0, I) \). At each iteration, the particles \( \{x_i^{(t)}\}_{i=1}^m \) are updated by
\[
x_i^{(t+1)} = x_i^{(t)} - \frac{1}{n} \sum_{k=1}^n \frac{ \nabla \phi(Y_k - x_i^{(t)}) }{ \frac{1}{m} \sum_{\ell=1}^m \phi(Y_k - x_\ell^{(t)}) },
\]
where \(\phi\) is the RBF kernel. The resulting animation visualizes the evolution of these particles as they are transported to match the distribution of the observed data \(\{Y_i\}\).

![Empirical Bayes animation](empirical_bayes.gif)

## Throwing eggs from a building
Given n eggs and an M-floor building, find the minimum number of egg throws to identify the lowest floor at which eggs break.
![plot: number of egg throws to find threshold floor](number_of_egg_throws_to_find_threshold_floor.png)

## How many steps to bingo?
Given an n x n bingo card, each step a random empty cell gets marked. How many steps are needed to get a bingo, on average?

Answer: $n^2 - n \log(n)$.
![plot: number steps to bingo](bingo_simulation_results.png)

The answer $n^2 - n \log(n)$ was given by ChatpGPT-o1-mini in *one-shot*.
